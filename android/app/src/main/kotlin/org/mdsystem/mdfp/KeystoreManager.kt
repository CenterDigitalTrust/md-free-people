package org.mdsystem.mdfp

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.math.BigInteger
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.ECGenParameterSpec

/**
 * Апаратний модуль Android Keystore для платформи MD Free People.
 * Реалізує створення апаратно захищених ключів ECDSA P-256 (secp256r1),
 * перевірку StrongBox/TEE, запит ланцюжка атестації та формування підписів
 * за стандартом канонічного протоколу MDFP1.
 */
class KeystoreManager(private val context: Context) {

    companion object {
        const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        const val EC_CURVE = "secp256r1"
        const val SIGNATURE_ALGORITHM = "SHA256withECDSA"
        const val DEFAULT_ALIAS = "mdfp_device_key"
    }

    /**
     * Отримання відомостей про апаратну платформу та підтримку StrongBox/TEE.
     */
    fun getDeviceInfo(): Map<String, Any> {
        val hasStrongBox = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
        } else {
            false
        }

        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "device" to Build.DEVICE,
            "apiLevel" to Build.VERSION.SDK_INT,
            "hasStrongBox" to hasStrongBox,
            "recommendedAlgorithm" to "ecdsa-p256-sha256",
            "isHardwareSupported" to true
        )
    }

    /**
     * Перевірка наявності згенерованого ключа в апаратному сховищі.
     */
    fun hasKey(alias: String = DEFAULT_ALIAS): Boolean {
        return try {
            val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
            keyStore.containsAlias(alias)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Генерація пари ключів ECDSA P-256 із пріоритетом StrongBox (API 28+) та фолбеком на TEE.
     * За наявності attestationChallenge встановлюється запит апаратного сертифіката.
     */
    fun generateKey(alias: String = DEFAULT_ALIAS, challenge: ByteArray? = null): Map<String, Any> {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        if (keyStore.containsAlias(alias)) {
            keyStore.deleteEntry(alias)
        }

        var isStrongBox = false
        val keyPair: KeyPair = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
        ) {
            try {
                val kp = createEcKeyPair(alias, challenge, useStrongBox = true)
                isStrongBox = true
                kp
            } catch (e: Exception) {
                isStrongBox = false
                createEcKeyPair(alias, challenge, useStrongBox = false)
            }
        } else {
            isStrongBox = false
            createEcKeyPair(alias, challenge, useStrongBox = false)
        }

        val pubKey = keyPair.public as ECPublicKey
        val spkiBytes = pubKey.encoded
        val uncompressedBytes = getUncompressedPoint(pubKey)

        // Отримання сертифікатів атестації
        val certChain = keyStore.getCertificateChain(alias)
        val certList = certChain?.map {
            Base64.encodeToString(it.encoded, Base64.NO_WRAP)
        } ?: emptyList()

        val attestationLevel = if (certList.isNotEmpty()) {
            if (isStrongBox) "strongbox" else "tee"
        } else {
            "none"
        }

        return mapOf(
            "alias" to alias,
            "algorithm" to "ecdsa-p256-sha256",
            "publicKeySpki" to Base64.encodeToString(spkiBytes, Base64.NO_WRAP),
            "publicKeySpkiHex" to bytesToHex(spkiBytes),
            "publicKeyUncompressedHex" to bytesToHex(uncompressedBytes),
            "securityLevel" to (if (isStrongBox) "StrongBox" else "TEE"),
            "isStrongBox" to isStrongBox,
            "attestationChain" to certList,
            "attestationLevel" to attestationLevel
        )
    }

    private fun createEcKeyPair(alias: String, challenge: ByteArray?, useStrongBox: Boolean): KeyPair {
        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, KEYSTORE_PROVIDER)
        val builder = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec(EC_CURVE))
            .setDigests(KeyProperties.DIGEST_SHA256)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && useStrongBox) {
            builder.setIsStrongBoxBacked(true)
        }

        if (challenge != null && challenge.isNotEmpty()) {
            builder.setAttestationChallenge(challenge)
        }

        kpg.initialize(builder.build())
        return kpg.generateKeyPair()
    }

    /**
     * Отримання публічного ключа з апаратного сховища.
     */
    fun getPublicKey(alias: String = DEFAULT_ALIAS): Map<String, Any>? {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        if (!keyStore.containsAlias(alias)) return null

        val cert = keyStore.getCertificate(alias) ?: return null
        val pubKey = cert.publicKey as? ECPublicKey ?: return null
        val spkiBytes = pubKey.encoded
        val uncompressedBytes = getUncompressedPoint(pubKey)

        return mapOf(
            "alias" to alias,
            "algorithm" to "ecdsa-p256-sha256",
            "publicKeySpki" to Base64.encodeToString(spkiBytes, Base64.NO_WRAP),
            "publicKeySpkiHex" to bytesToHex(spkiBytes),
            "publicKeyUncompressedHex" to bytesToHex(uncompressedBytes)
        )
    }

    /**
     * Апаратний підпис довільних байт (SHA256withECDSA) всередині Keystore чипа.
     */
    fun signData(alias: String = DEFAULT_ALIAS, data: ByteArray): Map<String, Any> {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        val privateKey = keyStore.getKey(alias, null) as? PrivateKey
            ?: throw IllegalStateException("Private key not found for alias: $alias")

        val signer = Signature.getInstance(SIGNATURE_ALGORITHM)
        signer.initSign(privateKey)
        signer.update(data)
        val signatureBytes = signer.sign()

        return mapOf(
            "signature" to Base64.encodeToString(signatureBytes, Base64.NO_WRAP),
            "signatureHex" to bytesToHex(signatureBytes),
            "format" to "der",
            "algorithm" to "ecdsa-p256-sha256"
        )
    }

    /**
     * Отримання ланцюжка сертифікатів атестації.
     */
    fun getAttestationChain(alias: String = DEFAULT_ALIAS): List<String> {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        val chain = keyStore.getCertificateChain(alias) ?: return emptyList()
        return chain.map { Base64.encodeToString(it.encoded, Base64.NO_WRAP) }
    }

    /**
     * Видалення ключа з Keystore.
     */
    fun deleteKey(alias: String = DEFAULT_ALIAS): Boolean {
        return try {
            val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
            if (keyStore.containsAlias(alias)) {
                keyStore.deleteEntry(alias)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Експорт точки EC у нестиснений стандартний формат 65 байт: 0x04 || X(32) || Y(32)
     */
    private fun getUncompressedPoint(ecPublicKey: ECPublicKey): ByteArray {
        val x = toFixed32Bytes(ecPublicKey.w.affineX)
        val y = toFixed32Bytes(ecPublicKey.w.affineY)
        val out = ByteArray(65)
        out[0] = 0x04.toByte()
        System.arraycopy(x, 0, out, 1, 32)
        System.arraycopy(y, 0, out, 33, 32)
        return out
    }

    private fun toFixed32Bytes(value: BigInteger): ByteArray {
        val raw = value.toByteArray()
        if (raw.size == 32) return raw
        val out = ByteArray(32)
        if (raw.size > 32) {
            // Видаляємо провідний нульовий байт знаку BigInteger
            System.arraycopy(raw, raw.size - 32, out, 0, 32)
        } else {
            // Доповнюємо нулями зліва
            System.arraycopy(raw, 0, out, 32 - raw.size, raw.size)
        }
        return out
    }

    private fun bytesToHex(bytes: ByteArray): String {
        val hexChars = "0123456789abcdef"
        val result = StringBuilder(bytes.size * 2)
        for (b in bytes) {
            val i = b.toInt() and 0xFF
            result.append(hexChars[i shr 4])
            result.append(hexChars[i and 0x0F])
        }
        return result.toString()
    }
}
