//
//  main.swift
//  UUIDGenerator
//
//  Created by 涼麵 on 2023/8/22.
//

import Foundation
import CommonCrypto

let clearText = "Hello"

var key: SecKey?
var cipherTextData: Data?
var signature: Data?

var keyName: String {
    return  "uuid.generator.sampleKey"
}
extension Data {
    public func toHexString() -> String {
        return reduce("", {$0 + String(format: "%02X ", $1)})
    }
}
private func showPublicKey() {
    
    guard let key = key, let publicKey = SecKeyCopyPublicKey(key) else {
        print("Can't get public key")
        return
    }
    var error: Unmanaged<CFError>?
    if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
        print( "Public Key: " + keyData.toHexString())
    } else {
        print( "Public Key: none")
    }
}

private func prepareKey() -> Bool {
    defer {
        showPublicKey()
    }
    guard key == nil else {
        return true
    }
    key = KeychainHelper.loadKey(name: keyName)
    guard key == nil else {
        return true
    }
    do {
        key = try KeychainHelper.makeAndStoreKey(name: keyName,  requiresBiometry:false)
        return true
    } catch let error {
        print (error.localizedDescription)
    }
    return false
}
func encrypt() {
   guard prepareKey() else {
       return
   }
    print(key!)
   
   guard let publicKey = SecKeyCopyPublicKey(key!) else {
       print("Can't get public key")
       return
   }
   let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
   guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
       print("Algorith not supported")
       return
   }
   var error: Unmanaged<CFError>?
   let clearTextData = clearText.data(using: .utf8)!
   cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm,
                                              clearTextData as CFData,
                                              &error) as Data?
   guard cipherTextData != nil else {
       print((error!.takeRetainedValue() as Error).localizedDescription)
       return
   }
   let cipherTextHex = cipherTextData!.toHexString()
   print("Cipher Text: " + cipherTextHex)
}
encrypt()

