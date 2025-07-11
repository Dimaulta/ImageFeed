//
//  ProfileServiceMock.swift
//  ImageFeed
//
//  Created by Ульта on 09.07.2025.
//

import ImageFeed
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
    
    func setProfile(_ profile: Profile) {
        self.profile = profile
    }
} 