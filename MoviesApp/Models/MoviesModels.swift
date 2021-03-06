//
//  MoviesModels.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import GRDB
import Foundation


// MARK: - MoviesReponse
struct MoviesReponse: Codable {
    let photosList: PhotosList
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case photosList = "photos"
        case stat
    }
}

// MARK: - Photos
struct PhotosList: Codable {
    let page, pages, perpage, total: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
        case page, pages, perpage, total
    }
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

extension Photo: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        owner = row["owner"]
        secret = row["secret"]
        server = row["server"]
        farm = row["farm"]
        title = row["title"]
        ispublic = row["ispublic"]
        isfriend = row["isfriend"]
        isfamily = row["isfamily"]
    }
}


struct MovieDisplay {
    let name:String
    let image:String
    
    init(movie:Photo){
        name = movie.title.ifBlank(use:"No title".localized)
        //http://farm​{farm}​.static.flickr.com/​{server}​/​{id}​_​{secret}​.jpg
        //https://farm66.static.flickr.com/65535/50397567507_855de8e6a9.jpg
        image = "https://farm\(movie.farm).static.flickr.com/\(movie.server)/\(movie.id)_\(movie.secret).jpg"
    }
}
