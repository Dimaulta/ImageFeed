//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Ульта on 10.07.2025.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableAnimated(oldCount: Int, newCount: Int)
    func reloadTable()
    func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func didTapLike(at index: Int)
    func willDisplayCell(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListService
    private(set) var photos: [Photo] = []
    
    init(imagesListService: ImagesListService = ImagesListService()) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        if oldCount == newCount { return }
        photos = imagesListService.photos
        view?.updateTableAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func didTapLike(at index: Int) {
        let photo = photos[index]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let oldPhoto = self.photos[index]
                let newPhoto = Photo(
                    id: oldPhoto.id,
                    size: oldPhoto.size,
                    createdAt: oldPhoto.createdAt,
                    welcomeDescription: oldPhoto.welcomeDescription,
                    thumbImageURL: oldPhoto.thumbImageURL,
                    largeImageURL: oldPhoto.largeImageURL,
                    isLiked: !oldPhoto.isLiked
                )
                self.photos[index] = newPhoto
                self.view?.reloadTable()
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
    
    func willDisplayCell(at index: Int) {
        if index + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
} 