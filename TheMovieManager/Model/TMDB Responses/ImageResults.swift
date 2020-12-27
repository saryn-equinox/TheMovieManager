//
//  ImageResults.swift
//  TheMovieManager
//
//  Created by 邱浩庭 on 26/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

struct ImageResults: Codable {
    let id: Int?
    let backdrops: [Image]?
    let posters: [Image]?
}
