//
//  RapperChatService.swift
//  AIRapper
//
//  Created by Chloe Tay on 27/10/26.
//
import Foundation
import OpenRouter

enum RapperChatError: LocalizedError {
    case missingAPIKey
    case emptyInput
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "No API key found."
        case .emptyInput: return "Please type something first."
        case .emptyResponse: return "The rapper had nothing to say."
        }
    }
}

final class RapperChatService {
    private let client: OpenRouterClient
    private let model = "anthropic/claude-haiku-5.5"
    private let systemPrompt = "You are Auntie Lim, a sarcastic Singaporean Chinese auntie texting her nephew or niece (the user). Whatever the user says, even good news, greetings or compliments, you ALWAYS scold them for it. Find something wrong with every single message: they are too thin or too fat, too lazy, too slow, wasting money, not married yet, no kids yet, not visiting, not as successful as the neighbour's doctor child. Never agree and never just praise; any praise must immediately turn into a scolding. Mention 'your mother always worry about you' now and then. Speak in Singlish (aiyo, lah, leh, hor, wah lau, sia, 'eat already?'). Keep every reply to 2-3 short lines, funny and dramatic, with a few emojis. Affectionate underneath, never truly cruel, no profanity."

    init(apiKey: String? = nil) throws {
        let key: String
        if let apiKey, !apiKey.isEmpty {
            key = apiKey
        } else if let envKey = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"], !envKey.isEmpty {
            key = envKey
        } else if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String, !plistKey.isEmpty {
            key = plistKey
        } else {
            throw RapperChatError.missingAPIKey
        }
        client = OpenRouterClient(apiKey: key)
    }

    /// Sends the whole conversation so the AI remembers earlier messages.
    func respond(to history: [ChatLine]) async throws -> String {
        var messages: [ChatMessage] = [.system(systemPrompt)]
        for message in history where !message.isError {
            messages.append(message.isFromUser ? .user(message.text) : .assistant(message.text))
        }
        guard history.contains(where: { $0.isFromUser }) else { throw RapperChatError.emptyInput }

        var request = ChatRequest(messages: messages, model: model)
        request.temperature = 1.1
        let result = try await client.chat.send(request)

        guard let reply = result.text, !reply.isEmpty else {
            throw RapperChatError.emptyResponse
        }
        return reply
    }
}
