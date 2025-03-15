//
//  NetworkService.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    
    func performRequest<T: Decodable>(endpoint: APIEndpoint, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> AnyPublisher<T, Error> {
        guard let url = endpoint.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                if let httpResponse = output.response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                }
                print("Raw Response: \(String(data: output.data, encoding: .utf8) ?? "")")
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
