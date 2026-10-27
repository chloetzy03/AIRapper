//
//  ChatBubbleCell.swift
//  AIRapper
//

import UIKit

final class ChatBubbleCell: UITableViewCell {
    static let reuseID = "ChatBubbleCell"

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private let bubble = UIView()
    private let label = UILabel()
    private let timeLabel = UILabel()
    private let dots = UIStackView()
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var textConstraints: [NSLayoutConstraint] = []
    private var dotsConstraints: [NSLayoutConstraint] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bubble.layer.cornerRadius = 16
        bubble.layer.shadowColor = UIColor.black.cgColor
        bubble.layer.shadowOpacity = 0.08
        bubble.layer.shadowRadius = 1
        bubble.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubble)

        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(label)

        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(timeLabel)

        dots.axis = .horizontal
        dots.spacing = 5
        dots.translatesAutoresizingMaskIntoConstraints = false
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .secondaryLabel
            dot.layer.cornerRadius = 4
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            dots.addArrangedSubview(dot)
        }
        bubble.addSubview(dots)

        leadingConstraint = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        trailingConstraint = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)

        textConstraints = [
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 7),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),
            timeLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -5),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bubble.leadingAnchor, constant: 12)
        ]
        dotsConstraints = [
            dots.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 15),
            dots.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -15),
            dots.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
            dots.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16)
        ]

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        dots.arrangedSubviews.forEach { $0.layer.removeAllAnimations() }
    }

    func configure(with message: ChatLine) {
        let isUser = message.isFromUser
        leadingConstraint.isActive = !isUser
        trailingConstraint.isActive = isUser

        // Telegram-style "tail": the bottom corner next to the sender stays square.
        bubble.layer.maskedCorners = isUser
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        let isTyping = message.kind == .typing
        label.isHidden = isTyping
        timeLabel.isHidden = isTyping
        dots.isHidden = !isTyping
        NSLayoutConstraint.deactivate(isTyping ? textConstraints : dotsConstraints)
        NSLayoutConstraint.activate(isTyping ? dotsConstraints : textConstraints)

        label.text = isTyping ? nil : message.text
        timeLabel.text = Self.timeFormatter.string(from: message.date)

        switch message.kind {
        case .user:
            bubble.backgroundColor = UIColor(red: 0.89, green: 0.99, blue: 0.80, alpha: 1)
            label.textColor = .black
            timeLabel.textColor = UIColor(red: 0.35, green: 0.62, blue: 0.27, alpha: 1)
        case .assistant:
            bubble.backgroundColor = .white
            label.textColor = .black
            timeLabel.textColor = .systemGray
        case .error:
            bubble.backgroundColor = UIColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
            label.textColor = .systemRed
            timeLabel.textColor = .systemRed
        case .typing:
            bubble.backgroundColor = .white
            animateDots()
        }
    }

    private func animateDots() {
        for (index, dot) in dots.arrangedSubviews.enumerated() {
            dot.alpha = 0.3
            UIView.animate(
                withDuration: 0.5,
                delay: 0.15 * Double(index),
                options: [.repeat, .autoreverse],
                animations: { dot.alpha = 1 }
            )
        }
    }
}
