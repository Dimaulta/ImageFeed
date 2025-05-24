//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ульта on 21.05.2025.
//

import UIKit

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
}
