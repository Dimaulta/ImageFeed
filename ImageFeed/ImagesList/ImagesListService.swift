//
//  ImagesListService.swift
//  ImageFeed
// /
//  Created by Ульта on 19.06.2025.
//

import UIKit

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let perPage = 10
    private let accessKey = "dUaraL4pnNKKk33SBBErYg7636WPwKbCDkx3N5y5mTo"
    private let urlSession = URLSession.shared
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { result in
                        Photo(
                            id: result.id,
                            size: CGSize(width: result.width, height: result.height),
                            createdAt: ISO8601DateFormatter().date(from: result.createdAt ?? ""),
                            welcomeDescription: result.description,
                            thumbImageURL: result.urls.thumb,
                            largeImageURL: result.urls.full,
                            isLiked: result.likedByUser
                        )
                    }
                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: newPhotos)
                        self.lastLoadedPage = nextPage
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                }
            } else if let error = error {
                print("Ошибка загрузки: \(error)")
            }
        }
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(ProfileServiceError.invalidRequest))
                }
            }
        }
        task.resume()
    }
}
