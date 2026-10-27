//
//  ViewController.swift
//  AIRapper
//
//  Created by Chloe Tay on 27/10/26.
//

import UIKit
import OpenRouter

final class ViewController: UIViewController {
    private let topics = ["I'm still single", "I got a new job", "I'm going gym", "I'm not hungry", "I bought a new phone"]
    private let wallpaper = UIColor(red: 0.84, green: 0.91, blue: 0.80, alpha: 1)
    private let telegramBlue = UIColor(red: 0.16, green: 0.62, blue: 0.89, alpha: 1)
    private let statusLabel = UILabel()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let chipsScroll = UIScrollView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let inputBar = UIView()

    private var lines: [ChatLine] = []
    private var service: RapperChatService?
    private var isSending = false
    private let haptics = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = wallpaper
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: makeHeader())
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        setUpTable()
        setUpInputBar()
        setUpChips()
        layoutViews()

        do {
            service = try RapperChatService()
        } catch {
            lines.append(ChatLine(kind: .error, text: error.localizedDescription))
        }
        lines.insert(ChatLine(kind: .assistant, text: "Aiyo, finally you message me! So long never reply, you forget your auntie ah? 😤"), at: 0)
        tableView.reloadData()
    }

    // MARK: - Setup

    private func setUpTable() {
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setUpInputBar() {
        inputBar.backgroundColor = .white
        inputBar.translatesAutoresizingMaskIntoConstraints = false

        inputField.placeholder = "Message"
        inputField.borderStyle = .none
        inputField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        inputField.layer.cornerRadius = 20
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        inputField.leftViewMode = .always
        inputField.returnKeyType = .send
        inputField.delegate = self
        inputField.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.up")
        config.baseBackgroundColor = telegramBlue
        config.cornerStyle = .capsule
        sendButton.configuration = config
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputBar.addSubview(inputField)
        inputBar.addSubview(sendButton)
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            inputField.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 8),
            inputField.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            sendButton.leadingAnchor.constraint(equalTo: inputField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setUpChips() {
        chipsScroll.showsHorizontalScrollIndicator = false
        chipsScroll.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        for topic in topics {
            var config = UIButton.Configuration.filled()
            config.title = topic
            config.baseBackgroundColor = .white
            config.baseForegroundColor = telegramBlue
            config.background.backgroundColor = .white
            config.cornerStyle = .capsule
            let chip = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                self?.send(topic)
            })
            row.addArrangedSubview(chip)
        }
        chipsScroll.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.bottomAnchor),
            row.heightAnchor.constraint(equalTo: chipsScroll.frameLayoutGuide.heightAnchor)
        ])
    }

    private func layoutViews() {
        view.addSubview(tableView)
        view.addSubview(chipsScroll)
        let bottomBacking = UIView()
        bottomBacking.backgroundColor = .white
        bottomBacking.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBacking)
        view.addSubview(inputBar)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: chipsScroll.topAnchor),

            chipsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsScroll.heightAnchor.constraint(equalToConstant: 44),
            chipsScroll.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            bottomBacking.topAnchor.constraint(equalTo: inputBar.topAnchor),
            bottomBacking.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBacking.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBacking.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    private func makeHeader() -> UIView {
        let avatar = UILabel()
        avatar.text = "👵"
        avatar.font = .systemFont(ofSize: 20)
        avatar.textAlignment = .center
        avatar.backgroundColor = telegramBlue.withAlphaComponent(0.2)
        avatar.layer.cornerRadius = 18
        avatar.clipsToBounds = true
        avatar.widthAnchor.constraint(equalToConstant: 36).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let name = UILabel()
        name.text = "Auntie Lim"
        name.font = .systemFont(ofSize: 16, weight: .semibold)

        statusLabel.text = "online"
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = telegramBlue

        let texts = UIStackView(arrangedSubviews: [name, statusLabel])
        texts.axis = .vertical
        texts.alignment = .leading

        let header = UIStackView(arrangedSubviews: [avatar, texts])
        header.axis = .horizontal
        header.spacing = 10
        header.alignment = .center
        return header
    }

    // MARK: - Sending

    @objc private func sendTapped() {
        send(inputField.text ?? "")
    }

    private func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let service, !trimmed.isEmpty, !isSending else { return }

        isSending = true
        sendButton.isEnabled = false
        inputField.text = ""
        chipsScroll.isHidden = true
        append(ChatLine(kind: .user, text: trimmed))
        append(ChatLine(kind: .typing))
        statusLabel.text = "typing…"

        let history = lines.filter { $0.kind == .user || $0.kind == .assistant }

        Task {
            let result: ChatLine
            do {
                let reply = try await service.respond(to: history)
                result = ChatLine(kind: .assistant, text: reply)
                haptics.notificationOccurred(.success)
            } catch let error as OpenRouterError {
                result = ChatLine(kind: .error, text: "OpenRouter error \(error.statusCode): \(error.message)")
                haptics.notificationOccurred(.error)
            } catch {
                result = ChatLine(kind: .error, text: error.localizedDescription)
                haptics.notificationOccurred(.error)
            }
            statusLabel.text = "online"
            lines.removeAll { $0.kind == .typing }
            tableView.reloadData()
            append(result)
            isSending = false
            sendButton.isEnabled = true
        }
    }

    private func append(_ line: ChatLine) {
        lines.append(line)
        let indexPath = IndexPath(row: lines.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - Table

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.reuseID, for: indexPath) as! ChatBubbleCell
        cell.configure(with: lines[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let line = lines[indexPath.row]
        guard line.kind == .assistant || line.kind == .user else { return nil }
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = line.text
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let sheet = UIActivityViewController(activityItems: [line.text], applicationActivities: nil)
                sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                self?.present(sheet, animated: true)
            }
            return UIMenu(children: [copy, share])
        })
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}

#Preview {
    UINavigationController(rootViewController: ViewController())
}
