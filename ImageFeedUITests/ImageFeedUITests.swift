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
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("ВАША_ПОЧТА")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        
       
        UIPasteboard.general.string = "ВАШ_ПАРОЛЬ"
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
        
        Thread.sleep(forTimeInterval: 1)
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    // 1. Тест загрузки ленты
    func testFeedLoading() throws {
        let tablesQuery = app.tables
        
        // Подождать, пока открывается и загружается экран ленты
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        // Ждем загрузки данных
        sleep(3)
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }
    
    // 2. Тест лайков
    func testFeedLikes() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Ждем загрузки ячейки
        sleep(3)
        
        // Пробуем найти любую кнопку в ячейке
        let anyButton = firstCell.buttons.firstMatch
        if anyButton.exists {
            print("Найдена кнопка: \(anyButton.identifier)")
            anyButton.tap()
            sleep(2)
            
            // Пробуем нажать еще раз (если это была кнопка лайка)
            anyButton.tap()
            sleep(1)
        } else {
            print("Кнопки в ячейке не найдены!")
        }
    }
    
    // 3. Тест навигации
    func testFeedNavigation() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Нажать на верхнюю ячейку
        firstCell.tap()
        sleep(2)
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // Вернуться на экран ленты
        let navBackButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        
        // Проверяем, что вернулись к ленте
        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
    }
    
    // 4. Тест скролла
    func testFeedScrolling() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        tableView.swipeUp()
        sleep(2)
        
        // Проверяем, что скролл работает
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
    
    
