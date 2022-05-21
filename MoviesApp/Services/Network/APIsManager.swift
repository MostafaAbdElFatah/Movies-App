//
//  APIsManager.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import Foundation


enum APIsManager {

    
    // MARK: - fetch model data -
    public static func fetch<Model>(url:URL, _ val:Model.Type, handler:@escaping (Result<Model, NetworkAPIError>)-> Void) where Model:Encodable, Model: Decodable{
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            if let error = error{ handler(.failure(.custom(error.localizedDescription))) }
            
            guard let data = data else {
                handler(.failure(.invalidData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(Model.self, from: data)
                handler(.success(decodedResponse))
            } catch {
                print(error)
                handler(.failure(.custom(error.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
}
