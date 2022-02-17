//
//  MainPageViewController.swift
//  Happiggy-bank
//
//  Created by 권은빈 on 2022/02/16.
//

import UIKit

/// 메인 화면 전체를 관리하는 컨트롤러
class MainViewController: UIViewController {
    
    /// 메인 뷰
    var mainView: UIView!
    
    /// 환경설정 버튼
    var settingsButton: UIButton!
    
    /// 개봉 버튼
    var openBeforeFinishedButton: UIButton!
    
    /// 유리병 리스트 버튼
    var userJarListButton: UIButton!
    
    /// 현재까지의 쪽지와 목표치를 나타내는 라벨
    var noteProgressLabel: UIView!
    
    /// 페이지 뷰를 관리하는 컨트롤러
    var pageViewController: UIPageViewController!
    
    /// 각 페이지에 들어갈 이미지 이름 배열
    var pageImages: [String]!
    
    /// 현재 페이지 인덱스
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageImages = ["image1", "image2", "image3", "image4"]
        configureView()
        configurePageViewController()
        configureConstraints()
    }
    
    func makePageContentViewController(with index: Int) -> PageContentViewController {
        let pageContentViewController: PageContentViewController = PageContentViewController()
        
        pageContentViewController.imageName = self.pageImages[index]
        pageContentViewController.index = index
        
        return pageContentViewController
    }
    
    // MARK: UI Configuration
    
    private func configureView() {
        configureMainView()
        configureButtons()
        configureLabel()
    }
    
    private func configureMainView() {
        self.mainView = MainView()
        self.view.addSubview(mainView)
    }
    
    private func configureButtons() {
        self.settingsButton = SettingsButton()
        self.openBeforeFinishedButton = OpenBeforeFinishedButton()
        self.userJarListButton = UserJarListButton()
        self.view.addSubview(settingsButton)
        self.view.addSubview(openBeforeFinishedButton)
        self.view.addSubview(userJarListButton)
        self.settingsButton.addTarget(
            self,
            action: #selector(settingsButtonDidTap(_:)),
            for: .touchUpInside
        )
        self.openBeforeFinishedButton.addTarget(
            self,
            action: #selector(openBeforeFinishedButtonDidTap(_:)),
            for: .touchUpInside
        )
        self.userJarListButton.addTarget(
            self,
            action: #selector(userJarListButtonDidTap(_:)),
            for: .touchUpInside
        )
    }
    
    private func configureLabel() {
        self.noteProgressLabel = NoteProgressLabel()
        self.view.addSubview(noteProgressLabel)
    }
    
    // MARK: Controller Configuration
    
    private func configurePageViewController() {
        let startViewController: PageContentViewController = self.makePageContentViewController(
            with: currentIndex
        )
        let viewControllerArray: NSArray = NSArray(object: startViewController)
        
        self.pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.setViewControllers(
            viewControllerArray as? [UIViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
        self.addChild(self.pageViewController)
        self.mainView.addSubview(self.pageViewController.view)
    }
    
    // MARK: Constraints
    
    private func configureConstraints() {
        configurePageViewController()
        configureButtonConstraints()
        configureLabelConstraints()
    }
    
    private func configureButtonConstraints() {
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        self.openBeforeFinishedButton.translatesAutoresizingMaskIntoConstraints = false
        self.userJarListButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            settingsButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -24
            ),
            openBeforeFinishedButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 24
            ),
            openBeforeFinishedButton.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            userJarListButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 88
            ),
            userJarListButton.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            settingsButton.widthAnchor.constraint(equalToConstant: 48),
            settingsButton.heightAnchor.constraint(equalToConstant: 48),
            openBeforeFinishedButton.widthAnchor.constraint(equalToConstant: 48),
            openBeforeFinishedButton.heightAnchor.constraint(equalToConstant: 48),
            userJarListButton.widthAnchor.constraint(equalToConstant: 48),
            userJarListButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configurePageViewConstraints() {
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(
                equalTo: self.mainView.topAnchor
            ),
            pageViewController.view.bottomAnchor.constraint(
                equalTo: self.mainView.bottomAnchor
            ),
            pageViewController.view.leadingAnchor.constraint(
                equalTo: self.mainView.leadingAnchor
            ),
            pageViewController.view.trailingAnchor.constraint(
                equalTo: self.mainView.trailingAnchor
            )
        ])
    }
    
    private func configureLabelConstraints() {
        self.noteProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noteProgressLabel.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            noteProgressLabel.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -24
            ),
            noteProgressLabel.widthAnchor.constraint(equalToConstant: 126),
            noteProgressLabel.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: Button Action
    
    @objc func settingsButtonDidTap(_ sender: UIButton) {
        print("Move to Settings View")
    }
    
    @objc func openBeforeFinishedButtonDidTap(_ sender: UIButton) {
        print("Open the jar")
    }
    
    @objc func userJarListButtonDidTap(_ sender: UIButton) {
        print("Move to User Jar List View")
    }
}
