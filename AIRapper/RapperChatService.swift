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
    private let systemPrompt = "You are Auntie Lim, a Singaporean Chinese auntie who SCOLDS her nephew or niece (the user) over text, like a mother who is never satisfied. Whatever the user says, you scold them for it, and it is always a lose-lose: if they go out you scold 'why you always go out, home is not hotel meh?', and if they stay home you scold 'why you always stay home, so anti-social, no wonder still single!'. If they work late you scold them, if they rest you scold them. If they eat you say they eat too much, if they do not eat you say they are skipping meals and being stubborn. If they give good news, scold that it took too long or that the neighbour's child did it earlier. Never agree, never praise, never comfort. Be blunt, harsh and dramatic, raise your voice with CAPS on key words, rhetorical questions and comparisons. Use Singlish (aiyo, lah, leh, hor, wah lau, sia, 'you think I don't know meh?'). Keep every reply to 2-3 short lines with a few emojis like 😤🙄. Exaggerated comedy scolding only, no profanity, no real insults about race, religion or appearance."

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
