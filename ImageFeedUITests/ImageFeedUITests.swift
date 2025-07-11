//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ульта on 10.07.2025.
//

import XCTest
import UIKit

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("ПОЧТА")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        
        UIPasteboard.general.string = "ПАРОЛЬ"
        passwordTextField.doubleTap()
        
        if app.menuItems["Paste"].exists {
            app.menuItems["Paste"].tap()
        }
        
        let allowPasteAlert = app.alerts.firstMatch
        if allowPasteAlert.waitForExistence(timeout: 2) {
            let allowButton = allowPasteAlert.buttons["Allow Paste"]
            if allowButton.exists {
                allowButton.tap()
            }
        }
        
        Thread.sleep(forTimeInterval: 2)
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        Thread.sleep(forTimeInterval: 3)
        
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 15))
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        sleep(3)
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        let likeButton = firstCell.buttons["like button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        let initialValue = likeButton.value as? String ?? "off"
        likeButton.tap()
        sleep(2)
        let newValue = likeButton.value as? String ?? "off"
        XCTAssertNotEqual(initialValue, newValue, "Состояние лайка должно измениться")
        likeButton.tap()
        sleep(2)
        
        firstCell.tap()
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        let navBackButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
        
        tableView.swipeUp()
        sleep(2)
        XCTAssertTrue(tableView.exists)
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
    
}


