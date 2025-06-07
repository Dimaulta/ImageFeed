//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ульта on 21.05.2025.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
