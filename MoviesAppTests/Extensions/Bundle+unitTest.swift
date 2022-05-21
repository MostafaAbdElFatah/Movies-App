//
//  File.swift
//  MoviesAppTests
//
//  Created by Mostafa Abd ElFatah on 5/21/22.
//

import Foundation


extension Bundle{
    
    public class var unitTest:Bundle{
        Bundle(for: MoviesAPIsManagerTests.self)
    }
}
