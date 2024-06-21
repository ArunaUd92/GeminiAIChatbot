//
//  APIKey.swift
//  GeminiAIChatbot
//
//  Created by Aruna Udayanga on 12/06/2024.
//

import Foundation

enum APIKey {
    static var `default`: String {
        do {
            return try fetchAPIKey()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func fetchAPIKey() throws -> String {
        guard let fileURL = Bundle.main.url(forResource: "GenerativeAISwift-Info", withExtension: "plist") else {
            throw APIKeyError.fileNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw APIKeyError.dataLoadFailed
        }

        let plist: [String: Any]
        do {
            plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] ?? [:]
        } catch {
            throw APIKeyError.plistDeserializationFailed
        }

        guard let value = plist["API_KEY"] as? String else {
            throw APIKeyError.keyNotFound
        }

        guard !value.isEmpty, !value.starts(with: "_") else {
            throw APIKeyError.invalidKey
        }

        return value
    }
    
    enum APIKeyError: LocalizedError {
        case fileNotFound
        case dataLoadFailed
        case plistDeserializationFailed
        case keyNotFound
        case invalidKey
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Couldn't find file 'GenerativeAISwift-Info.plist'."
            case .dataLoadFailed:
                return "Couldn't load data from 'GenerativeAISwift-Info.plist'."
            case .plistDeserializationFailed:
                return "Couldn't deserialize 'GenerativeAISwift-Info.plist'."
            case .keyNotFound:
                return "Couldn't find key 'API_KEY' in 'GenerativeAISwift-Info.plist'."
            case .invalidKey:
                return "Invalid API_KEY. Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
            }
        }
    }
}
