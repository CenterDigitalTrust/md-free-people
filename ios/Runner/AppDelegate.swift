import AVFoundation
import Flutter
import Security
import UIKit

/// Hardware-backed ECDSA P-256 (secp256r1) signer for iOS using Apple Secure Enclave
/// with automatic fallback to iOS Keychain when running inside the iOS Simulator.
final class KeystoreManager {
    static let defaultAlias = "mdfp_device_key"

    // Fixed 26-byte ASN.1 DER SubjectPublicKeyInfo (SPKI) header for P-256 (secp256r1) uncompressed point (65 bytes)
    private static let p256SpkiHeader: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86,
        0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A,
        0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    private func tagData(for alias: String) -> Data {
        return Data("org.mdsystem.mdfp.key.\(alias)".utf8)
    }

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    func getDeviceInfo() -> [String: Any] {
        let ver = ProcessInfo.processInfo.operatingSystemVersion
        let secureEnclaveSupported = !isSimulator
        return [
            "manufacturer": "Apple",
            "model": UIDevice.current.model,
            "device": UIDevice.current.systemName,
            "apiLevel": ver.majorVersion,
            "hasStrongBox": secureEnclaveSupported,
            "recommendedAlgorithm": "ecdsa-p256-sha256",
            "isHardwareSupported": true
        ]
    }

    func hasKey(alias: String = defaultAlias) -> Bool {
        return loadPrivateKey(alias: alias) != nil
    }

    private func loadPrivateKey(alias: String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tagData(for: alias),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let key = item else {
            return nil
        }
        return (key as! SecKey)
    }

    @discardableResult
    func deleteKey(alias: String = defaultAlias) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tagData(for: alias)
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    func generateKey(alias: String = defaultAlias, challenge: Data? = nil) throws -> [String: Any] {
        _ = deleteKey(alias: alias)

        var usedSecureEnclave = false
        var privateKey: SecKey?

        if !isSimulator {
            var acError: Unmanaged<CFError>?
            if let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                [.privateKeyUsage],
                &acError
            ) {
                let seAttributes: [String: Any] = [
                    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                    kSecAttrKeySizeInBits as String: 256,
                    kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
                    kSecPrivateKeyAttrs as String: [
                        kSecAttrIsPermanent as String: true,
                        kSecAttrApplicationTag as String: tagData(for: alias),
                        kSecAttrAccessControl as String: access
                    ]
                ]
                var error: Unmanaged<CFError>?
                if let key = SecKeyCreateRandomKey(seAttributes as CFDictionary, &error) {
                    privateKey = key
                    usedSecureEnclave = true
                }
            }
        }

        if privateKey == nil {
            let kcAttributes: [String: Any] = [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeySizeInBits as String: 256,
                kSecPrivateKeyAttrs as String: [
                    kSecAttrIsPermanent as String: true,
                    kSecAttrApplicationTag as String: tagData(for: alias),
                    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                ]
            ]
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(kcAttributes as CFDictionary, &error) else {
                let msg = error?.takeRetainedValue().localizedDescription ?? "SecKeyCreateRandomKey failed"
                throw NSError(domain: "org.mdsystem.mdfp.keystore", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
            }
            privateKey = key
            usedSecureEnclave = false
        }

        guard let secKey = privateKey,
              let pubInfo = exportPublicKeyInfo(from: secKey, alias: alias) else {
            throw NSError(domain: "org.mdsystem.mdfp.keystore", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to export P-256 public key"])
        }

        var result = pubInfo
        result["securityLevel"] = usedSecureEnclave ? "SecureEnclave" : "Keychain"
        result["isStrongBox"] = usedSecureEnclave
        result["attestationChain"] = [String]()
        result["attestationLevel"] = usedSecureEnclave ? "secure_enclave" : "none"
        return result
    }

    func getPublicKey(alias: String = defaultAlias) -> [String: Any]? {
        guard let privateKey = loadPrivateKey(alias: alias) else {
            return nil
        }
        return exportPublicKeyInfo(from: privateKey, alias: alias)
    }

    private func exportPublicKeyInfo(from privateKey: SecKey, alias: String) -> [String: Any]? {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let rawCFData = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            return nil
        }
        let uncompressedData = rawCFData as Data
        guard uncompressedData.count == 65, uncompressedData.first == 0x04 else {
            return nil
        }

        var spkiData = Data(Self.p256SpkiHeader)
        spkiData.append(uncompressedData)

        return [
            "alias": alias,
            "algorithm": "ecdsa-p256-sha256",
            "publicKeySpki": spkiData.base64EncodedString(),
            "publicKeySpkiHex": bytesToHex(spkiData),
            "publicKeyUncompressedHex": bytesToHex(uncompressedData)
        ]
    }

    func signData(alias: String = defaultAlias, data: Data) throws -> [String: Any] {
        guard let privateKey = loadPrivateKey(alias: alias) else {
            throw NSError(domain: "org.mdsystem.mdfp.keystore", code: -3, userInfo: [NSLocalizedDescriptionKey: "Private key not found for alias: \(alias)"])
        }
        var error: Unmanaged<CFError>?
        guard let sigCFData = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            &error
        ) else {
            let msg = error?.takeRetainedValue().localizedDescription ?? "SecKeyCreateSignature failed"
            throw NSError(domain: "org.mdsystem.mdfp.keystore", code: -4, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        let sigData = sigCFData as Data
        return [
            "signature": sigData.base64EncodedString(),
            "signatureHex": bytesToHex(sigData),
            "format": "der",
            "algorithm": "ecdsa-p256-sha256"
        ]
    }

    func getAttestationChain(alias: String = defaultAlias) -> [String] {
        return []
    }

    private func bytesToHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
}

/// Native MPEG-4 AAC (.m4a) audio recorder for iOS matching Android MediaRecorder contract.
final class AudioRecorder: NSObject {
    private var recorder: AVAudioRecorder?
    private var outputPath: String?

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "start":
                guard recorder == nil else {
                    throw NSError(domain: "org.mdsystem.mdfp.audio", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording is already running"])
                }
                guard let args = call.arguments as? [String: Any],
                      let path = args["path"] as? String else {
                    throw NSError(domain: "org.mdsystem.mdfp.audio", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing recording path"])
                }

                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try session.setActive(true)

                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderBitRateKey: 128000,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                let url = URL(fileURLWithPath: path)
                let next = try AVAudioRecorder(url: url, settings: settings)
                guard next.prepareToRecord(), next.record() else {
                    throw NSError(domain: "org.mdsystem.mdfp.audio", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to start AVAudioRecorder"])
                }
                recorder = next
                outputPath = path
                result(nil)

            case "stop":
                guard let active = recorder else {
                    throw NSError(domain: "org.mdsystem.mdfp.audio", code: -4, userInfo: [NSLocalizedDescriptionKey: "No recording is running"])
                }
                active.stop()
                let saved = outputPath
                releaseRecorder()
                result(saved)

            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            releaseRecorder()
            result(FlutterError(code: "AUDIO_RECORDING_FAILED", message: error.localizedDescription, details: nil))
        }
    }

    func releaseRecorder() {
        recorder?.stop()
        recorder = nil
        outputPath = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let keystoreManager = KeystoreManager()
    private let audioRecorder = AudioRecorder()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {
            registerChannels(with: controller)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerChannels(with controller: FlutterViewController) {
        let messenger = controller.binaryMessenger

        // 1. Safe Evidence File Share Channel
        let filesChannel = FlutterMethodChannel(name: "org.mdsystem.mdfp/files", binaryMessenger: messenger)
        filesChannel.setMethodCallHandler { [weak controller] call, result in
            guard call.method == "share" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let args = call.arguments as? [String: Any],
                  let rawPath = args["path"] as? String else {
                result(FlutterError(code: "EXPORT_FAILED", message: "Missing path", details: nil))
                return
            }

            let sourceURL = URL(fileURLWithPath: rawPath).standardizedFileURL
            let pathStr = sourceURL.path
            var isFile: ObjCBool = false
            guard FileManager.default.fileExists(atPath: pathStr, isDirectory: &isFile), !isFile.boolValue,
                  pathStr.contains("/mdfp_evidence/") else {
                result(FlutterError(code: "EXPORT_FAILED", message: "Not an evidence file", details: nil))
                return
            }

            do {
                let exportDir = FileManager.default.temporaryDirectory.appendingPathComponent("evidence_exports", isDirectory: true)
                try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
                let copyURL = exportDir.appendingPathComponent(sourceURL.lastPathComponent)
                if FileManager.default.fileExists(atPath: copyURL.path) {
                    try FileManager.default.removeItem(at: copyURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: copyURL)

                DispatchQueue.main.async {
                    guard let presenter = controller else {
                        result(FlutterError(code: "EXPORT_FAILED", message: "No active presenter", details: nil))
                        return
                    }
                    let activityVC = UIActivityViewController(activityItems: [copyURL], applicationActivities: nil)
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = presenter.view
                        popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
                    }
                    presenter.present(activityVC, animated: true) {
                        result(nil)
                    }
                }
            } catch {
                result(FlutterError(code: "EXPORT_FAILED", message: error.localizedDescription, details: nil))
            }
        }

        // 2. Native Audio Recorder Channel (.m4a)
        let audioChannel = FlutterMethodChannel(name: "org.mdsystem.mdfp/audio", binaryMessenger: messenger)
        audioChannel.setMethodCallHandler { [weak self] call, result in
            self?.audioRecorder.handle(call, result: result)
        }

        // 3. Hardware Keystore / Secure Enclave Channel (ECDSA P-256 / SHA-256)
        let keystoreChannel = FlutterMethodChannel(name: "org.mdsystem.mdfp/keystore", binaryMessenger: messenger)
        keystoreChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            let args = call.arguments as? [String: Any]
            let alias = (args?["alias"] as? String) ?? KeystoreManager.defaultAlias

            do {
                switch call.method {
                case "getDeviceInfo":
                    result(self.keystoreManager.getDeviceInfo())
                case "hasKey":
                    result(self.keystoreManager.hasKey(alias: alias))
                case "generateKey":
                    let challengeData = Self.parseBytes(args?["challenge"])
                    let keyInfo = try self.keystoreManager.generateKey(alias: alias, challenge: challengeData)
                    result(keyInfo)
                case "getPublicKey":
                    if let pubKey = self.keystoreManager.getPublicKey(alias: alias) {
                        result(pubKey)
                    } else {
                        result(FlutterError(code: "KEY_NOT_FOUND", message: "No key pair found for alias \(alias)", details: nil))
                    }
                case "signData":
                    guard let dataBytes = Self.parseBytes(args?["data"]) else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid 'data' argument to sign", details: nil))
                        return
                    }
                    let sigInfo = try self.keystoreManager.signData(alias: alias, data: dataBytes)
                    result(sigInfo)
                case "getAttestationChain":
                    result(self.keystoreManager.getAttestationChain(alias: alias))
                case "deleteKey":
                    result(self.keystoreManager.deleteKey(alias: alias))
                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                result(FlutterError(code: "KEYSTORE_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        audioRecorder.releaseRecorder()
        super.applicationWillTerminate(application)
    }

    private static func parseBytes(_ value: Any?) -> Data? {
        guard let value = value else { return nil }
        if let typed = value as? FlutterStandardTypedData {
            return typed.data
        }
        if let data = value as? Data {
            return data
        }
        if let list = value as? [NSNumber] {
            return Data(list.map { UInt8(truncating: $0) })
        }
        if let str = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if str.count % 2 == 0, str.range(of: "^[0-9a-fA-F]+$", options: .regularExpression) != nil {
                var bytes = Data(capacity: str.count / 2)
                var index = str.startIndex
                while index < str.endIndex {
                    let nextIndex = str.index(index, offsetBy: 2)
                    if let b = UInt8(str[index..<nextIndex], radix: 16) {
                        bytes.append(b)
                    }
                    index = nextIndex
                }
                return bytes
            }
            return Data(base64Encoded: str)
        }
        return nil
    }
}
