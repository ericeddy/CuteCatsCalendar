//
//  APIService.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-28.
//

import Foundation
import Network

class APIService<Router: APIServiceRequest>: NSObject, ObservableObject {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
        super.init()
    }
        
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    func request<T: Decodable>(_ returnType: T.Type, router: Router) async throws -> T {
        do {
            let request = try router.makeURLRequest()
            let (data, response) = try await urlSession.data(for: request)
//            print("gotData")// convenient data breakpoint
            try handleResponse(data: data, response: response)
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(returnType, from: data)
//            print("DecodedData", decodedData)
            return decodedData
        } catch let error {
            let err: NSError = error as NSError
            switch err.code {
            case NSURLErrorTimedOut, NSURLErrorNotConnectedToInternet:
                throw NetworkError.offline
            default:
                throw NetworkError.dataConversionFailure
            }
        }
    }
}

protocol APIServiceRequest {
    var config: APIServiceConfig { get }
    var endpoint: String { get }
    var method: String { get }
    var composedURL: String { get }
    func makeURLRequest() throws -> URLRequest
}

extension APIServiceRequest {
    func makeURLRequest() throws -> URLRequest {
        guard let url = URL(string: composedURL), let key = Bundle.main.infoDictionary?["CAT_KEY"] as? String else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(key, forHTTPHeaderField: "x-api-key")
        request.httpMethod = method
        return request
    }
}

protocol APIServiceConfig {
    var baseURL: String { get }
    func getParams(_ page: Int, _ limit: Int) -> String // Makes call with default params //
    func getParams(_ page: Int, _ limit: Int, _ size: String, _ mime_types: String, _ format: String, _ has_breeds: String, _ order: String) -> String
}

enum NetworkError: Error {
    case offline
    case invalidURL
    case requestFailed(statusCode: Int)
    case invalidResponse
    case dataConversionFailure
}
