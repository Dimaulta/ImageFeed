//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Ульта on 09.07.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        var presenter = ProfilePresenterSpy()
        viewController.configure(&presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        let testProfile = Profile(username: "test", name: "Test Name", loginName: "@test", bio: "Test Bio")
        profileServiceMock.setProfile(testProfile)
        var presenter = ProfilePresenter(profileService: profileServiceMock)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.receivedName, "Test Name")
        XCTAssertEqual(viewController.receivedLoginName, "@test")
        XCTAssertEqual(viewController.receivedBio, "Test Bio")
    }
    
    func testPresenterCallsShowLogoutAlert() {
        //given
        let viewController = ProfileViewControllerSpy()
        var presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.didTapLogoutButton()
        
        //then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testViewControllerCallsDidTapLogoutButton() {
        //given
        let viewController = ProfileViewController()
        var presenter = ProfilePresenterSpy()
        viewController.configure(&presenter)
        
        //when
        viewController.didTapLogoutButton()
        
        //then
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
} 