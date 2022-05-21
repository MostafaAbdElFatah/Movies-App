//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import UIKit
import SDWebImage

class MovieCell: UITableViewCell {

    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    
    func config(movie:MovieDisplay){
        movieLabel.text = movie.name
        movieImageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        movieImageView.sd_setImage(with: URL(string: movie.image))
    }
    
}
