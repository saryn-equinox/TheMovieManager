//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TMDBClient.getImages(id: movie.id, comletion: handleGetImagesResponse(data:error:))
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markWatchList(movie: movie, isWatchlist: !isWatchlist, completion: handleMarkWatchlistReponse(data:error:))
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markFavorite(movie: movie, isFavorite: !isFavorite, completion: handleMarkFavoirteResponse(data:error:))
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    func handleGetImagesResponse(data: ImageResults?, error: Error?) {
        guard let data = data else {
            print(error!)
            return
        }
        
        TMDBClient.fetchImage(width: "w500", filePath: data.posters?[0].filePath ?? "", completion: handleFetchImageResponse(data:error:))
    }
    
    func handleFetchImageResponse(data: Data?, error: Error?){
        guard let data = data else {
            print(error!)
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.image = UIImage(data: data)
        }
    }
    
    func handleMarkFavoirteResponse(data: RequestTokenResponse?, error: Error?) {
        guard let data = data else {
            print(error!)
            return
        }
        print(data.statusMessage!)
        print(data.statusCode!)
        if (data.statusCode! == 1 || data.statusCode! == 12 || data.statusCode! == 13) {
            TMDBClient.getFavorites { (data, error) in
                guard let data = data else {
                    print("Fetch favorite list fail")
                    return
                }
                MovieModel.favorites = data.results
                DispatchQueue.main.async {
                    self.toggleBarButton(self.favoriteBarButtonItem, enabled: self.isFavorite)
                }
            }
        }
    }
    
    func handleMarkWatchlistReponse(data: RequestTokenResponse?, error: Error?) {
        guard let data = data else  {
            print(error!)
            return
        }
        print(data.statusMessage!)
        print(data.statusCode!)
        if (data.statusCode! == 1 || data.statusCode! == 12 || data.statusCode! == 13) {
            //update watch list
            TMDBClient.getWatchlist { (movies, error) in
                MovieModel.watchlist = movies!.results
                DispatchQueue.main.async {
                    self.toggleBarButton(self.watchlistBarButtonItem, enabled: self.isWatchlist)
                }
            }
        }
    }
}
