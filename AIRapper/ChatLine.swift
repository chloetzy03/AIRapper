//
//  ChatLine.swift
//  AIRapper
//

import Foundation

struct ChatLine: Identifiable {
    enum Kind {
        case user
        case assistant
        case error
        case typing
    }

    let id = UUID()
    let kind: Kind
    let date = Date()
    var text: String = ""

    var isFromUser: Bool { kind == .user }
    var isError: Bool { kind == .error }
}
