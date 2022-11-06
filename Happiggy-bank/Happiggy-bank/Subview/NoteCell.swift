//
//  NoteCell.swift
//  Happiggy-bank
//
//  Created by sun on 2022/03/30.
//

import UIKit

import Then

// 쪽지 디테일 뷰에서 사용하는 쪽지 셀
final class NoteCell: UITableViewCell {

    // MARK: - Properties

    var viewModel: PhotoNoteCellViewModel? {
        didSet { self.render() }
    }

    /// 셀 간 여백 설정을 위한 뷰
    private let validView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 작성 날짜 레이블
    private let dateLabel = UILabel().then {
        $0.changeFontSize(to: FontSize.secondaryLabel)
    }

    /// 몇 번째 쪽지인지 나타내는 레이블
    private let indexLabel = UILabel().then {
        $0.changeFontSize(to: FontSize.secondaryLabel)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.textColor = .customGray
    }

    /// 내용 레이블
    private let contentLabel = UILabel().then {
        $0.changeFontSize(to: FontSize.body)
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = .zero
    }

    /// 배경 이미지 뷰
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage.borderedNoteBackground?.resizableImage(
            withCapInsets: Metric.imageCapInsets,
            resizingMode: .stretch
        )
        $0.autoresizingMask.update(with: [.flexibleWidth, .flexibleHeight])
    }

    /// 날짜와 인덱스 레이블을 담고 있는 스택 뷰
    private let dateAndIndexStack = UIStackView()

    /// 모든 UI 요소를 담고 있는 스택 뷰
    private let contentStack = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = Metric.spacing
    }


    // MARK: - Init(s)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.configureViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.configureViews()
    }


    // MARK: - Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
    }


    // MARK: - Functions

    /// 셀을 내용을 채우는 메서드
    private func render() {
        self.validView.backgroundColor = self.viewModel?.basicColor
        self.backgroundImageView.tintColor = self.viewModel?.tintColor
        self.dateLabel.attributedText = self.viewModel?.attributedDateString
        self.dateLabel.configureParagraphStyle()
        self.indexLabel.attributedText = self.viewModel?.attributedIndexString
        self.indexLabel.configureParagraphStyle()
        self.contentLabel.attributedText = self.viewModel?.attributedContentString
        self.contentLabel.configureParagraphStyle()
    }

    /// 뷰 초기 설정
    private func configureViews() {
        self.selectionStyle = .none
        self.configureViewHierarchy()
        self.configureViewLayout()
    }

    /// 하위 뷰 추가
    private func configureViewHierarchy() {
        self.contentView.addSubview(self.validView)
        self.validView.addSubviews(self.backgroundImageView, self.contentStack)
        self.contentStack.addArrangedSubviews(self.dateAndIndexStack, self.contentLabel)
        self.dateAndIndexStack.addArrangedSubviews(self.dateLabel, self.indexLabel)
    }

    /// 뷰 레이아웃 설정
    private func configureViewLayout() {
        self.configureValidViewLayout()
        self.configureBackgroundImageViewLayout()
        self.configureContentStackLayout()
    }

    /// 셀 간 간격이 있는 것처럼 나타내기 위해 validView의 레이아웃을 설정
    private func configureValidViewLayout() {
        NSLayoutConstraint.activate([
            self.validView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.validView.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -Metric.spacing
            ),
            self.validView.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor
            ),
            self.validView.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor
            )
        ])
    }

    /// backgroundImageView 레이아웃 설정
    private func configureBackgroundImageViewLayout() {
        self.backgroundImageView.frame = self.validView.bounds
    }

    /// contentStack 레이아웃 설정
    private func configureContentStackLayout() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: self.validView.topAnchor,
                constant: Metric.inset
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: self.validView.bottomAnchor,
                constant: -Metric.inset
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: self.validView.leadingAnchor,
                constant: Metric.inset
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: self.validView.trailingAnchor,
                constant: -Metric.inset
            )
        ])
    }
}


// MARK: - Constants
fileprivate extension NoteCell {

    /// 상수
    enum Metric {

        /// 간격: 16
        static let spacing: CGFloat = 16

        /// 상하좌우 여백: 24
        static let inset: CGFloat = 24

        /// 배경 이미지의 UIEdgeInsets: (15, 15, 15, 15)
        static let imageCapInsets = UIEdgeInsets(
            top: imageInset,
            left: imageInset,
            bottom: imageInset,
            right: imageInset
        )

        /// 배경 이미지 고정 inset 값: 15
        private static let imageInset: CGFloat = 15
    }
}
