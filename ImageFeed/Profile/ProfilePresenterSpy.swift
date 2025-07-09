//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Ульта on 09.07.2025.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled: Bool = false
    var didTapLogoutButtonCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
} 