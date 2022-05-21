//
//  MoviesListVC.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//
//

import UIKit

final class MoviesListVC: UIViewController {

    // MARK: - Public properties -

    // MARK: - Private properties -
    private var viewModel = MoviesListViewModel()
    
    // MARK: - Lifecycle -
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Extensions -
extension MoviesListVC {
    
}
