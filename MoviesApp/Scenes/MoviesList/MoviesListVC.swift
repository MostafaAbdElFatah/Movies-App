//
//  MoviesListVC.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//
//

import UIKit
import RxCocoa
import RxSwift
import KafkaRefresh

final class MoviesListVC: UIViewController {

    // MARK: - Public properties -
    lazy var tableView:UITableView = {
       let tableview = UITableView()
        tableview.register(UINib(nibName: "AdBannerCell", bundle: nil), forCellReuseIdentifier: "AdBannerCell")
        tableview.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        tableview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableview)
        NSLayoutConstraint.activate([
            tableview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        return tableview
    }()

    // MARK: - Private properties -
    private let disposeBag = DisposeBag()
    private var viewModel = MoviesListViewModel()
    
    // MARK: - Dim View
    private let dimViewAlpha: CGFloat = 0.5
    private lazy var dimView: UIView = {
        let v = UIView(frame: .zero)
        v.alpha = 0
        v.backgroundColor = .black.withAlphaComponent(dimViewAlpha)
        v.isUserInteractionEnabled = false
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }()
    
    // MARK: - Lifecycle -
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchMoviesList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront( dimView)
    }
    
    // MARK: - setupLayoutUI -
    private func setupLayoutUI() {
        addDimView()
        bindTableView()
        bindLoadingView()
        title = "Movies List"
        view.backgroundColor = .white
    }
    
    func bindLoadingView()  {
        viewModel.state.bind { state in
            DispatchQueue.main.async {
                switch state {
                case .empty:
                    //show empty text
                    self.showingLoadingView(isLoading: false)
                    self.tableView.setEmptyMessage("No Data Found".localized)
                    break
                case .loading:
                    // show loading view
                    self.tableView.hiddenEmptyMessage()
                    self.showingLoadingView(isLoading: true)
                    break
                case .fetched:
                    //loading tableView and hiddenEmptyMessag
                    self.tableView.hiddenEmptyMessage()
                    self.showingLoadingView(isLoading: false)
                case .error(let error):
                    // show error message
                    self.showingLoadingView(isLoading: false)
                    self.tableView.setEmptyMessage("No Data Found".localized)
                    self.showAlert(title: "Error".localized, message: error)
                }
                self.tableView.footRefreshControl.endRefreshing()
            }
        }.disposed(by: disposeBag)
    }
    
    func bindTableView(){
        tableView.bindFootRefreshHandler({ [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchMoviesList()
        }, themeColor: .blue, refreshStyle: .replicatorAllen)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.itemSelected.subscribe(onNext:{ [weak self] indexPath in
            guard let self = self else { return }
            if self.viewModel.isBanner(row: indexPath.row) {
                //open adBanner link
                self.viewModel.openAdBanner()
            }else{
                // move to movie details
                self.moveTo(photo: self.viewModel.getObject(at: indexPath.row))
            }
        }).disposed(by: disposeBag)
        viewModel.movies.bind(to: tableView.rx.items){
            [weak self](tbv, row, item) in
            guard let self = self else { return UITableViewCell() }
            if !self.viewModel.isBanner(row: row){
                let cell = tbv.dequeueReusableCell(withIdentifier: "MovieCell", for: IndexPath(row: row, section: 0)) as! MovieCell
                cell.config(movie: self.viewModel.createCellDispaly(photo: item as! Photo))
                return cell
            }else {
                let cell = tbv.dequeueReusableCell(withIdentifier: "AdBannerCell", for: IndexPath(row: row, section: 0)) as! AdBannerCell
                cell.config(imageNamed: item as! String)
                return cell
            }
        }.disposed(by: disposeBag)
    }
    
    
    private func moveTo(photo:Photo?) {
        let vc = MovieDetailsVC()
        vc.viewModel.movie.onNext(photo)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addDimView() {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showingLoadingView(isLoading:Bool){
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = isLoading ? 1:0
        }
    }

}

// MARK: - UITableViewDelegate Extension -
extension MoviesListVC : UITableViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            tableView.footRefreshControl.beginRefreshing()
        }
    }
}
