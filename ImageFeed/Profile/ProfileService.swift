//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Ульта on 01.06.2025.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else { return nil }
        guard let url = URL(string: "/me", relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService] Не удалось создать запрос")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let profileResult = try decoder.decode(ProfileResult.self, from: data)
                        let profile = Profile(
                            username: profileResult.username,
                            name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces),
                            loginName: "@\(profileResult.username)",
                            bio: profileResult.bio ?? ""
                        )
                        self.profile = profile
                        completion(.success(profile))
                    } catch {
                        print("[ProfileService] Ошибка декодирования: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("[ProfileService] Сетевая ошибка: \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
}

enum ProfileServiceError: Error {
    case invalidRequest
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}
