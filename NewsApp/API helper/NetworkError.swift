//
//  NetworkError.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case noInternetConnection
    case requestFailed(String)
    case decodingFailed
    case cancelled
    case unknown

    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "That request couldn't be built. Please try again."
        case .noInternetConnection:
            return "No internet connection. Check your network and try again."
        case .requestFailed(let message):
            return message
        case .decodingFailed:
            return "We couldn't read the server's response. Please try again."
        case .cancelled:
            return "Request cancelled."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
