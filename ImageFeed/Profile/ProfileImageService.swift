//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Ульта on 02.06.2025.
//

import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private init() {}
    
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else { return nil }
        guard let url = URL(string: "/users/\(username)", relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileImageRequest(username: username) else {
            print("[ProfileImageService] Не удалось создать запрос")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let userResult):
                    let profileImageURL = userResult.profileImage.small
                    self.avatarURL = profileImageURL
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL]
                        )
                case .failure(let error):
                    print("[ProfileImageService] Сетевая ошибка: \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
}

enum ProfileImageServiceError: Error {
    case invalidRequest
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}


