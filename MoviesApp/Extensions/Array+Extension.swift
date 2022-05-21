//
//  Array+Extesion.swift
//  MoviesApp
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import Foundation


extension Array {
    
    
    // inject ad banners between list at every five elements of list
    func injectAdBanners()->[Any]{
        let insertions:[String] = [Int](0...7).map({ "adBanner\($0)" })
        
        var list:[Any] = self
        for index in self.indices.dropFirst().reversed() where index.isMultiple(of: 4) {
            list.insert(insertions.randomItem(), at: index)
        }
        return list
    }
    
    func randomItem() -> Element{
        self[Int.random(in: 0...7)]
    }
    
}
