//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Ульта on 10.07.2025.
//

import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableAnimatedCalled = false
    var reloadTableCalled = false
    var showLikeErrorCalled = false
    var oldCount: Int?
    var newCount: Int?
    
    func updateTableAnimated(oldCount: Int, newCount: Int) {
        updateTableAnimatedCalled = true
        self.oldCount = oldCount
        self.newCount = newCount
    }
    
    func reloadTable() {
        reloadTableCalled = true
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
} 