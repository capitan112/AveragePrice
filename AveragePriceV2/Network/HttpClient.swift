//
//  HttpClient.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Combine
import Foundation

protocol HTTPClientProtocol {
    func fetchProperties(url: String) async throws -> [Property]
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case responseError(Int)
    case decodingError(Error)
}

class HTTPClient: HTTPClientProtocol {
    func fetchProperties(url: String) async throws -> [Property] {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.responseError(-1)
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.responseError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data).properties
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
