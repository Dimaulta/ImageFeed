//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ульта on 01.05.2025.
///

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    private var presenter: ProfilePresenterProtocol!
    
    func configure<T: ProfilePresenterProtocol>(_ presenter: inout T) {
        self.presenter = presenter
        presenter.view = self
    }
    
    private var avatarImageView: UIImageView!
    private var userNameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    @objc
    func didTapLogoutButton() {
        presenter.didTapLogoutButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        setupUI()
        presenter.viewDidLoad()
        
        avatarImageView.image = UIImage(named: "Stub")
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        userNameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        avatarImageView.image = UIImage(named: "Stub")
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        let cache = ImageCache.default
        
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        avatarImageView.kf.indicatorType = .activity
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub"),
            options: [
                .processor(processor),
                .transition(.fade(0.5))
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("Изображение успешно загружено")
                print("Источник: \(value.source)")
                print("Тип кэша: \(value.cacheType)")
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                self.avatarImageView.image = UIImage(named: "Stub")
            }
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        present(alert, animated: true)
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
    
    private func setupUI() {
        avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        userNameLabel = UILabel()
        userNameLabel.textColor = UIColor(named: "YP White")
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.accessibilityIdentifier = "Name Lastname"
        
        loginNameLabel = UILabel()
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.accessibilityIdentifier = "@username"
        
        descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let exitButton: UIButton
        do {
            guard let exitImage = UIImage(named: "Exit") else {
                throw NSError(domain: "ImageLoading", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load exit image"])
            }
            exitButton = UIButton.systemButton(
                with: exitImage.withRenderingMode(.alwaysOriginal),
                target: self,
                action: #selector(Self.didTapLogoutButton)
            )
        } catch {
            print("Error loading exit image: \(error.localizedDescription)")
            exitButton = UIButton(type: .system)
            exitButton.setTitle("Exit", for: .normal)
            exitButton.addTarget(self, action: #selector(Self.didTapLogoutButton), for: .touchUpInside)
        }
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.accessibilityIdentifier = "logout button"
        
        view.addSubview(avatarImageView)
        view.addSubview(userNameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            loginNameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
