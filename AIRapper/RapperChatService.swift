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
    private let model = "openai/gpt-5-mini"
    private let systemPrompt = "You are Ah Beng GPT, a larger-than-life hip-hop hype artist. Answer with playful, witty rap bars packed with internal rhymes, Singlish slang, and good vibes. Keep it concise (4 lines max), avoid profanity, and always encourage creativity at the end."

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

    func respond(to text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RapperChatError.emptyInput }

        let result = try await client.chat.send(
            ChatRequest(
                messages: [.system(systemPrompt), .user(trimmed)],
                model: model
            )
        )

        guard let reply = result.text, !reply.isEmpty else {
            throw RapperChatError.emptyResponse
        }
        return reply
    }
}
