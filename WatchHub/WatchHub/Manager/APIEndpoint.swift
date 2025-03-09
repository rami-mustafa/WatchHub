//
//  APIEndpoint.swift
//  WatchHub
//
//  Created by Rami Mustafa on 01.02.25.
//

import Foundation

protocol Endpoint {
    var url: String { get }
    var method: String { get }
    var body: Data? { get }
    var headers: [String: String] { get }
}

/// API için kullanılacak endpoint'ler
enum APIEndpoint: Endpoint  {
    case getUsers
    case getUserDetail(userID: Int)
    case createUser(name: String, email: String)

    /// Endpoint'e göre URL döner
    var url: String {
        switch self {
        case .getUsers:
            return getURLComponent(endpoint: APIPath.order)
        case .getUserDetail(let userID):
            return getURLComponent(endpoint: APIPath.product(orderStatusID: userID))
        case .createUser:
            return getURLComponent(endpoint: APIPath.order)
        }
    }

    /// HTTP Method belirleme
    var method: String {
        switch self {
        case .getUsers, .getUserDetail:
            return "GET"
        case .createUser:
            return "POST"
        }
    }

    /// Request için body oluşturma
    var body: Data? {
        switch self {
        case .createUser(let name, let email):
            let parameters: [String: Any] = ["name": name, "email": email]
            return try? JSONSerialization.data(withJSONObject: parameters)
        default:
            return nil
        }
    }
    
    var headers: [String: String] {
        switch self {
        default:
            var defaultHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
            
            // Eğer authentication gerekiyorsa ekleyelim
            let authToken = "Bearer XYZ123TOKEN" // Burada dinamik olarak çekilebilir
            defaultHeaders["Authorization"] = authToken
            
            return defaultHeaders
        }
    }

    func getURLComponent(
        endpoint: String
    ) -> String {
            var urlComponents: URLComponents = URLComponents()
            urlComponents.scheme = APIPath.scheme
            urlComponents.host   = APIPath.baselURL
            urlComponents.path   = endpoint
            
            guard var urlString = urlComponents.url?.absoluteString else {
                print("🟥 AlamofireService--> URL oluşturulamadı.")
                return ""
            }
            
            print("🔥 AlamofireService--> \(urlString) adresine istek atılıyor...")
            return urlString
        }
}

/// Kullanıcı Modeli
struct User: Codable {
    let id: Int
    let name: String
    let email: String
    
    /// JSON'daki key'leri farklı isimlerde map'lemek için CodingKeys kullanıyoruz.
    enum CodingKeys: String, CodingKey {
        case id 
        case name
        case email
    }
}
