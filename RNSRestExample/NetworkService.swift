//
//  File.swift
//  RNSRestExample
//
//  Created by Mark Descalzo on 3/13/20.
//  Copyright © 2020 Ringneck Software, LLC. All rights reserved.
//

import Foundation

enum NetworkError : Error {
    case invalidURL
    case emptyData
}

struct ServiceResponse: Codable {
    let status: String
    let message: String
    let data: [EmployeeModel]
}

struct FetchResult {
    let restults: [EmployeeModel]?
    let error: Error?
}

class NetworkService {
    
    fileprivate let endpoint: String = "https://dummy.restapiexample.com/api/v1/employees"
    
    fileprivate var task: URLSessionTask?
    
    func fetchRecords(completion: @escaping (FetchResult) -> Void) {
        
        func errorCompletion(_ error: Error) {
            completion(FetchResult(restults: nil, error: error))
        }
        
        guard let url = URL(string: endpoint) else {
            errorCompletion(NetworkError.invalidURL)
            return
        }
        
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                guard (error as NSError).code != NSURLErrorCancelled else {
                    return
                }
                errorCompletion(error)
                return
            }
            guard let data = data else {
                errorCompletion(NetworkError.emptyData)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ServiceResponse.self, from: data)
                completion(FetchResult(restults: result.data, error: nil))
            } catch {
                errorCompletion(error)
            }
        }
        task?.resume()
    }
    
}
