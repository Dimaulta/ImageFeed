//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Ульта on 20.05.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private let tokenStorage = OAuth2TokenStorage()
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { return nil }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    struct OAuthTokenResponseBody: Decodable {
        let access_token: String
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] Не удалось создать запрос")
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос"])))
            return
        }
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = response.access_token
                    DispatchQueue.main.async {
                        completion(.success(response.access_token))
                    }
                } catch {
                    print("[OAuth2Service] Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[OAuth2Service] Сетевая ошибка: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
