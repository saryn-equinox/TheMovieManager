//
//  Poster.swift
//  TheMovieManager
//
//  Created by 邱浩庭 on 26/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct Image: Codable {
    let aspectRatio: Double?
    let filePath: String?
    let height: Double?
    let iso6391: String?
    let voteAverage: Double?
    let width: Double?
    let voteCount: Double?
    
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case height
        case voteAverage = "vote_average"
        case width
        case iso6391 = "iso_639_1"
        case voteCount = "vote_count"
    }
}
