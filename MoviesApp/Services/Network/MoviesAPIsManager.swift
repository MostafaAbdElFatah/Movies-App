//
//  MoviesAPIsManager.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import Foundation

protocol MoviesAPIsManagerProtocol {
    
    func fetchMovies(from url:URL, handler:@escaping (Result<MoviesReponse, NetworkAPIError>) -> Void)
}

class MoviesAPIsManager: MoviesAPIsManagerProtocol  {
    
    // MARK: - fetch moovies list -
    func fetchMovies(from url: URL, handler: @escaping (Result<MoviesReponse, NetworkAPIError>) -> Void) {
        APIsManager.fetch(url: url, MoviesReponse.self) { [weak self] result in
            guard self != nil else { return }
            handler(result)
        }
    }
    
    
    
    
}
