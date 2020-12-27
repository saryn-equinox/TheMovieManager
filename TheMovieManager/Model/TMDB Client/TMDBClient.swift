//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TMDBClient {
    
    static let apiKey = "ffe906e8e9fd638ab1d3d5e538421132"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionID
        case logout
        case getFavorites
        case serach(String)
        case markWatchlist
        case markFavorite
        case fetchImage(String, String)
        case getImages(Int)
        
        var stringValue: String {
            switch self {
            case .getImages(let movieId):
                return Endpoints.base + "/movie/\(movieId)/images" + Endpoints.apiKeyParam
            case .fetchImage(let width, let path):
                return "https://image.tmdb.org/t/p/\(width)\(path)"
            case .markFavorite:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite" +
                    Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .markWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getFavorites:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken:
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .login:
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionID:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case .logout:
                return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case .serach(let name):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(name)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // POST&DELETE functions - including httpBody
    class func markFavorite(movie: Movie, isFavorite: Bool, completion: @escaping (RequestTokenResponse?, Error?) -> Void) {
        let url = Endpoints.markFavorite.url
        let body = MarkFavorite(mediaType: "movie", mediaId: movie.id, favorite: isFavorite)
        taskForPostRequest(url: url, requestMethod: "POST", requestBody: body, responseType: RequestTokenResponse.self, completion: completion)
    }
    
    class func markWatchList(movie: Movie, isWatchlist: Bool, completion: @escaping (RequestTokenResponse?, Error?) -> Void) {
        let url = Endpoints.markWatchlist.url
        let body = MarkWatchlist(mediaType: "movie", mediaId: movie.id, watchlist: isWatchlist)
        taskForPostRequest(url: url, requestMethod: "POST", requestBody: body, responseType: RequestTokenResponse.self, completion: completion)
    }
    
    class func createSession(completion: @escaping (SessionResponse?, Error?) -> Void) {
        let url = self.Endpoints.createSessionID.url
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPostRequest(url: url, requestMethod: "POST", requestBody: body, responseType: SessionResponse.self, completion: completion)
    }
    
    // This is the only DELETE request, and it has preety much same parameters as POST request in this app, so I call the same helper function as POST requests
    class func logout(completion: @escaping (SessionResponse?, Error?) -> Void) {
        let url = self.Endpoints.logout.url
        let body = LogoutRequest(sessionId: self.Auth.sessionId)
        taskForPostRequest(url: url, requestMethod: "DELETE", requestBody: body, responseType: SessionResponse.self, completion: completion)
    }
    
    class func login(username: String, password: String, completion: @escaping (RequestTokenResponse?, Error?) -> Void) {
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        let url = self.Endpoints.login.url
        taskForPostRequest(url: url, requestMethod: "POST", requestBody: body, responseType: RequestTokenResponse.self, completion: completion)
    }
    
    class func taskForPostRequest<ResponseType: Codable, RequestBody: Codable>(url: URL, requestMethod: String, requestBody: RequestBody, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(responseType.self, from: data)
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
                return
            }
        }
        task.resume()
    }
    
    
    // GET requests
    class func fetchImage(width: String, filePath: String, completion: @escaping(Data?, Error?) -> Void) {
        let url = Endpoints.fetchImage(width, filePath).url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
    
    class func getImages(id: Int, comletion: @escaping(ImageResults?, Error?) -> Void) {
        let url = Endpoints.getImages(id).url
        taskForGetRequest(url: url, responseType: ImageResults.self, completionHandler: comletion)
    }
    
    class func getSearch(name: String, completion: @escaping (MovieResults?, Error?) -> Void) {
        let url = self.Endpoints.serach(name).url
        print(self.Endpoints.serach(name).stringValue)
        self.taskForGetRequest(url: url, responseType: MovieResults.self, completionHandler: completion)
    }
    
    class func getFavorites(completion: @escaping(MovieResults?, Error?) -> Void) {
        let url = self.Endpoints.getFavorites.url
        self.taskForGetRequest(url: url, responseType: MovieResults.self, completionHandler: completion)
    }
    
    class func getWatchlist(completion: @escaping (MovieResults?, Error?) -> Void) {
        let url = self.Endpoints.getWatchlist.url
        self.taskForGetRequest(url: url, responseType: MovieResults.self, completionHandler: completion)
    }
        
    class func getRequestToken(completion: @escaping (RequestTokenResponse?, Error?) -> Void) {
        let url = self.Endpoints.getRequestToken.url
        taskForGetRequest(url: url, responseType: RequestTokenResponse.self, completionHandler: completion)
    }
    
    // Mark: Refactor GET request functions
    class func taskForGetRequest<ResponseType: Codable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                completionHandler(responseObject, nil)
            } catch {
                completionHandler(nil, error)
                return
            }
        }
        task.resume()
    }
}
