//
//  DateParser.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

/// SNAPI returns two ISO8601 shapes:
///   published_at: "2026-09-16T16:12:01Z"                 (no fractional seconds)
///   updated_at:   "2026-09-16T16:20:23.252359Z"           (fractional seconds)
/// This tries the fractional formatter first, then falls back.
enum DateParser {

    private static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let standard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func date(from string: String) -> Date {
        withFractionalSeconds.date(from: string)
            ?? standard.date(from: string)
            ?? Date()
    }
}
