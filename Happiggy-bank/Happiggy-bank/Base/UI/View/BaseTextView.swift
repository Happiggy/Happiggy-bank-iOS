//
//  BaseTextView.swift
//  Happiggy-bank
//
//  Created by sun on 2022/12/25.
//

import Combine
import UIKit

/// 커스텀 폰트를 적용하기 위한 UITextView
final class BaseTextView: UITextView {

    // MARK: - Properties

    private let fontManager: FontPublishing = FontManager.shared
    private var cancellable: AnyCancellable?
    private var customFont: CustomFont?


    // MARK: - Inits

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        self.subscribeToFontPublisher()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.subscribeToFontPublisher()
    }


    // MARK: - Attribute Modifying Functions

    /// 강조 처리
    func bold() {
        self.updateFont(to: self.customFont ?? .system, isBold: true)
    }


    // MARK: - Configuration Functions

    private func subscribeToFontPublisher() {
        self.cancellable = fontManager.fontPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateFont(to: $0, isBold: self?.font?.isBold == true) }
    }

    private func updateFont(to newFont: CustomFont, isBold: Bool) {
        self.customFont = newFont
        let fontName = isBold ? newFont.bold : newFont.regular
        self.font = UIFont(name: fontName, size: self.font?.pointSize ?? FontSize.body1)
    }
}
