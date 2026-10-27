//
//  ViewController.swift
//  AIRapper
//
//  Created by Chloe Tay on 27/10/26.
//

import UIKit
import OpenRouter

final class ViewController: UIViewController {
    private let promptField: UITextField = {
        let field = UITextField()
        field.placeholder = "Ask the rap mentor…"
        field.borderStyle = .roundedRect
        field.returnKeyType = .send
        return field
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hit it!", for: .normal)
        return button
    }()
    
    private let responseView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.text = "Your rhymes will land here."
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    private var service: RapperChatService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
        
        do {
            service = try RapperChatService()
        } catch {
            responseView.text = error.localizedDescription
        }
        
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    @objc
    private func sendTapped() {
        guard let service else { return }
        let prompt = promptField.text ?? ""
        responseView.text = "Loading..."
        sendButton.isEnabled = false
        
        Task {
            do {
                let reply = try await service.respond(to: prompt)
                responseView.text = reply
            } catch let error as OpenRouterError {
                responseView.text = "OpenRouter error \(error.statusCode): \(error.message)"
            } catch {
                responseView.text = error.localizedDescription
            }
            sendButton.isEnabled = true
        }
    }
    
}

//class ViewController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        if let apiKey = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"] {
//            print("API Key loaded successfully!")
//        } else {
//            print("API Key missing! Check scheme arguments.")
//        }
//    }
//    
//    
//}


#Preview {
    ViewController()
}

