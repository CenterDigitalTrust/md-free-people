package org.mdsystem.mdfp

import android.content.Intent
import androidx.core.content.FileProvider
import java.io.File
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "org.mdsystem.mdfp/keystore"
    private lateinit var keystoreManager: KeystoreManager
    private lateinit var audioRecorder: AudioRecorder

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        keystoreManager = KeystoreManager(applicationContext)
        audioRecorder = AudioRecorder(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.mdsystem.mdfp/files").setMethodCallHandler { call, result ->
            // Restrict exported content to captured evidence, never key or index files.
            try {
                if (call.method != "share") {
                    result.notImplemented()
                } else {
                    val source = File(requireNotNull(call.argument<String>("path"))).canonicalFile
                    val allowed = File(applicationInfo.dataDir, "app_flutter/mdfp_evidence").canonicalFile
                    require(source.path.startsWith(allowed.path + File.separator) && source.isFile) { "Not an evidence file" }
                    val directory = File(cacheDir, "evidence_exports").apply { mkdirs() }
                    val copy = File(directory, source.name)
                    source.copyTo(copy, overwrite = true)
                    val uri = FileProvider.getUriForFile(this, "$packageName.evidence.files", copy)
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = call.argument<String>("mime") ?: "application/octet-stream"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(Intent.createChooser(intent, call.argument<String>("title") ?: "Share original file"))
                    result.success(null)
                }
            } catch (error: Exception) { result.error("EXPORT_FAILED", error.message, null) }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.mdsystem.mdfp/audio").setMethodCallHandler(audioRecorder::handle)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                handleKeystoreCall(call, result)
            } catch (e: Exception) {
                result.error("KEYSTORE_ERROR", e.message, e.stackTraceToString())
            }
        }
    }

    override fun onDestroy() {
        // Free microphone when Android destroys the activity.
        if (::audioRecorder.isInitialized) audioRecorder.release()
        super.onDestroy()
    }

    private fun handleKeystoreCall(call: MethodCall, result: MethodChannel.Result) {
        val alias = call.argument<String>("alias") ?: KeystoreManager.DEFAULT_ALIAS

        when (call.method) {
            "getDeviceInfo" -> {
                result.success(keystoreManager.getDeviceInfo())
            }
            "hasKey" -> {
                result.success(keystoreManager.hasKey(alias))
            }
            "generateKey" -> {
                val challengeRaw = call.argument<Any>("challenge")
                val challengeBytes = parseBytes(challengeRaw)
                val keyInfo = keystoreManager.generateKey(alias, challengeBytes)
                result.success(keyInfo)
            }
            "getPublicKey" -> {
                val pubKeyInfo = keystoreManager.getPublicKey(alias)
                if (pubKeyInfo != null) {
                    result.success(pubKeyInfo)
                } else {
                    result.error("KEY_NOT_FOUND", "No key pair found for alias $alias", null)
                }
            }
            "signData" -> {
                val dataRaw = call.argument<Any>("data")
                    ?: return result.error("INVALID_ARGUMENT", "Missing 'data' argument to sign", null)
                val dataBytes = parseBytes(dataRaw)
                    ?: return result.error("INVALID_ARGUMENT", "Cannot parse 'data' to bytes", null)

                val signatureInfo = keystoreManager.signData(alias, dataBytes)
                result.success(signatureInfo)
            }
            "getAttestationChain" -> {
                result.success(keystoreManager.getAttestationChain(alias))
            }
            "deleteKey" -> {
                result.success(keystoreManager.deleteKey(alias))
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun parseBytes(value: Any?): ByteArray? {
        if (value == null) return null
        return when (value) {
            is ByteArray -> value
            is List<*> -> {
                val bytes = ByteArray(value.size)
                for (i in value.indices) {
                    bytes[i] = (value[i] as Number).toByte()
                }
                bytes
            }
            is String -> {
                val str = value.trim()
                if (str.matches(Regex("^[0-9a-fA-F]+$")) && str.length % 2 == 0) {
                    hexToBytes(str)
                } else {
                    Base64.decode(str, Base64.DEFAULT)
                }
            }
            else -> null
        }
    }

    private fun hexToBytes(hex: String): ByteArray {
        val len = hex.length
        val data = ByteArray(len / 2)
        var i = 0
        while (i < len) {
            data[i / 2] = ((Character.digit(hex[i], 16) shl 4) +
                    Character.digit(hex[i + 1], 16)).toByte()
            i += 2
        }
        return data
    }
}
