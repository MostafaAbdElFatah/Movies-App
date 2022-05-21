//
//  MoviesListViewModel.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import RxSwift
import Foundation


final class MoviesListViewModel{
    
    // MARK: - Public properties -
    var state = BehaviorSubject<State>(value: .empty)
    public var movies = BehaviorSubject<[Any]>(value: [])
    
    
    // MARK: - Private properties -
    private var totalPages:Int = 1
    private var currentPage:Int = 1
    private var apisManager:MoviesAPIsManagerProtocol
    
    init(apisManager:MoviesAPIsManagerProtocol = MoviesAPIsManager()) {
        self.apisManager = apisManager
    }
    
    // MARK: - fetchMovies -
    func fetchMoviesList() {
        if currentPage > totalPages {
            state.onNext(.fetched)
            return
        }
        
        let urlString = URLs.moviesListURL(page: currentPage)
        guard let url = URL(string: urlString) else {
            state.onNext(.error(NetworkAPIError.invalidURL.localizedDescription))
            return
        }
        
        if let currentState = try? state.value(), case .empty = currentState {
            state.onNext(.loading)
        }
        
        apisManager.fetchMovies(from: url) { [weak self] result in
            guard let self = self else { return }
            self.state.onNext(.fetched)
            
            switch result {
            case .success(let response):
                self.state.onNext(.fetched)
                self.totalPages = response.photosList.pages
                self.currentPage = response.photosList.page + 1
                guard var moviesList = try? self.movies.value() else { return }
                moviesList.append(contentsOf: response.photosList.photos)
                moviesList = moviesList.filter({ $0 is Photo })
                
                // inject ad banners between movies
                let list = moviesList.injectAdBanners()
                
                self.movies.onNext(list)
            case .failure(let error):
                self.state.onNext(.error(error.localizedDescription))
            }
            
        }
    }
    
    // MARK: - create movie cell display object -
    func createCellDispaly(photo:Photo) -> MovieDisplay {
        MovieDisplay(movie: photo)
    }

    // MARK: - isAdBanner cell at this row -
    func isBanner(row:Int)-> Bool {
        guard let moviesList = try? self.movies.value() else { return false }
        return moviesList[row] is String
    }
    
    // MARK: - get photo object at this row -
    func getObject(at row:Int) -> Photo?{
        guard let moviesList = try? self.movies.value() else { return nil }
        return moviesList[row] as? Photo
    }
    
    func openAdBanner() {
        openLink("https://www.getkoinz.com/")
    }
    
    private func openLink(_ link:String){
        let application = UIApplication.shared
        guard let url = URL(string: link) else { return }
        application.open( url, options: [:])
    }
}
