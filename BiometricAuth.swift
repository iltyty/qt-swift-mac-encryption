import Foundation
import LocalAuthentication
import CryptoKit

let keyKey = "com.qttouchidauth.key"
let encryptedKey = "com.qttouchidauth.encryptedkey"

func saveToKeychain(key: String, data: Data) -> Bool {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]
    SecItemDelete(query as CFDictionary)

    let attributes: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    let status = SecItemAdd(attributes as CFDictionary, nil)
    return status == errSecSuccess
}

func readFromKeychain(key: String) -> Data? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var item: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    return (status == errSecSuccess) ? (item as? Data) : nil
}

func getAESKey() -> SymmetricKey? {
    if let keyData = readFromKeychain(key: keyKey) {
        return SymmetricKey(data: keyData)
    }
    return nil
}

func getOrCreateAESKey() -> SymmetricKey {
    if let key = getAESKey() {
        print(key.withUnsafeBytes { Data($0) }.map { String(format: "%02hhx", $0) }.joined())
        return key
    }
    print("create key")
    let key = SymmetricKey(size: .bits256)
    _ = saveToKeychain(key: keyKey, data: key.withUnsafeBytes { Data($0) })
    return key
}

@objc public class BiometricAuth: NSObject {
    @objc public static func authenticateAndEncrypt(_ input: String, completion: @escaping (String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Identity yourself!") { success, _ in
                if success {
                    let key = getOrCreateAESKey()
                    let data = input.data(using: .utf8)!
                    let sealedBox = try! AES.GCM.seal(data, using: key)
                    let encrypted = sealedBox.combined!.base64EncodedString()
                    DispatchQueue.main.async {
                        completion(encrypted)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }

    @objc public static func authenticateAndDecrypt(_ base64: String, completion: @escaping (String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Identify yourself!") { success, _ in
                if success {
                    guard let key = getAESKey(),
                          let data = Data(base64Encoded: base64),
                          let sealedBox = try? AES.GCM.SealedBox(combined: data),
                          let decrypted = try? AES.GCM.open(sealedBox, using: key),
                          let str = String(data: decrypted, encoding: .utf8)
                    else {
                        DispatchQueue.main.async {
                            completion("")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(str)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
