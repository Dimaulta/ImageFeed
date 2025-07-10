//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Ульта on 10.07.2025.
//

import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var didTapLikeIndex: Int?
    var willDisplayCellIndex: Int?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLike(at index: Int) {
        didTapLikeIndex = index
    }
    
    func willDisplayCell(at index: Int) {
        willDisplayCellIndex = index
    }
} 