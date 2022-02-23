//
//  ImageViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 29.10.2021.
//

import UIKit

private let urlString = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
private let largeImageUrlString = "https://i.imgur.com/3416rvl.jpg"

class ImageViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    func fetchImage() {
        NetworkManager.downloadImage(from: urlString) { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
        }
    }
    
    func fetchImageAlamofire() {
        AlamofireNetworkRequest.fetchData(urlString: urlString) { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
        }
    }
    
    func fetchLargeImageAlamofire() {
        AlamofireNetworkRequest.onProgress = { [weak self] progress in
            self?.progressView.isHidden = false
            self?.progressView.progress = Float(progress)
        }
        AlamofireNetworkRequest.completed = { [weak self] completed in
            self?.progressView.isHidden = false
            self?.progressLabel.text = completed
        }
        AlamofireNetworkRequest.fetchDataWithProgress(urlString: urlString) { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.progressView.isHidden = true
            self?.progressLabel.isHidden = true
            self?.imageView.image = image
        }
    }
}
