//
//  Server.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/21.
//

import Foundation
import Alamofire

class Server {
    static let shared = Server()

    typealias NetworkRequestResult = Result<Data, Error>

    typealias NetworkRequestCompltion = (NetworkRequestResult) -> Void

    private var baseUrl = "http://34.80.130.206"

    private init() {
    }
    // completion 代表完成請求後，執行的閉包
    // Get
    func requestGet(path: String, parameters: Parameters?, completion: @escaping NetworkRequestCompltion) -> Void {
        AF.request(baseUrl + path, parameters: parameters).response { response in
            switch response.result {
            case let .success(data):
                guard let data = data else {
                    print("???get\(response.response?.statusCode as Any)")
                    return
                }
                // 測試
                print("!!!get\(response.response?.statusCode as Any)")

                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    // Post
    func requestPost(path: String, parameters: Parameters?, completion: @escaping NetworkRequestCompltion) -> Void {
        AF.request(baseUrl + path,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).response { response in
                    switch response.result {
                    case let .success(data):
                        guard let data = data else {
                            print("???post\(response.response?.statusCode as Any)")
                            completion(.success(Data()))
                            return
                        }
                        // 測試
                        print("!!!post\(response.response?.statusCode as Any)")

                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                   }
    }
    // Put
    func requestPut(path: String, parameters: Parameters?, completion: @escaping NetworkRequestCompltion) -> Void {
        AF.request(baseUrl + path,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default).response { response in
                    switch response.result {
                    case let .success(data):
                        guard let data = data else {
                            print("???put\(response.response?.statusCode as Any)")
                            return
                        }
                        // 測試
                        print("!!!put\(response.response?.statusCode as Any)")

                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                   }
    }
    // Delete
    func requestDelete(path: String, parameters: Parameters?, completion: @escaping NetworkRequestCompltion) -> Void {
        AF.request(baseUrl + path,
                   method: .delete,
                   parameters: parameters,
                   encoding: JSONEncoding.default).response { response in
                    switch response.result {
                    case let .success(data):
                        guard let data = data else {
                            print("???put\(response.response?.statusCode as Any)")
                            return
                        }
                        // 測試
                        print("!!!put\(response.response?.statusCode as Any)")

                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                   }
    }
}
