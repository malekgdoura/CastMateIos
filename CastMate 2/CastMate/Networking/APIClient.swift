import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed(Error)
    case underlying(Error)
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide."
        case let .requestFailed(statusCode, message):
            if let message, !message.isEmpty {
                return message
            } else {
                return "La requête a échoué (code \(statusCode))."
            }
        case let .decodingFailed(error):
            return "Échec du décodage de la réponse: \(error.localizedDescription)"
        case let .underlying(error):
            return error.localizedDescription
        case .missingAccessToken:
            return "Le serveur n’a pas renvoyé de jeton d’accès."
        }
    }
}

struct APIConfig {
    static var baseURL: URL = {
        guard let url = URL(string: "https://cast-mate.vercel.app") else {
            fatalError("Base URL invalide")
        }
        return url
    }()
}

struct APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<Request: Encodable, Response: Decodable>(
        _ path: String,
        method: HTTPMethod,
        body: Request,
        headers: [String: String] = [:]
    ) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.underlying(error)
        }

        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.underlying(error)
        }
    }

    func request<Response: Decodable>(
        _ path: String,
        method: HTTPMethod,
        headers: [String: String] = [:]
    ) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.underlying(error)
        }
    }

    private func handleResponse<Response: Decodable>(
        data: Data,
        response: URLResponse
    ) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(statusCode: -1, message: "Réponse invalide.")
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

