//
//  MainViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 29.10.2021.
//

import UIKit
import UserNotifications
import FBSDKLoginKit
import FirebaseAuth

private let reuseIdentifier = "Cell"
private let urlString = "https://jsonplaceholder.typicode.com/posts"
private let imgurApiUrl = "https://api.imgur.com/3/upload"

enum Controls: String, CaseIterable {
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download file"
    case ourCoursesAlamofire = "Our Courses (Alamofire)"
    case responseDataAlamofire = "Response Data (Alamofire)"
    case largeImageAlamofire = "Download Large Image (Alamofire)"
    case postAlamofire = "POST (Alamofire)"
    case uploadImageAlamofire = "Upload Image (Alamofire)"
}

class MainViewController: UICollectionViewController {

    let controls = Controls.allCases
    private var alert: UIAlertController!
    private var dataProvider = DataProvider()
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()
        registerForNotifications()
        dataProvider.fileLocation = { [weak self] location in
            print("Download finished: \(location.absoluteString)")
            self?.filePath = location.absoluteString
            self?.alert.dismiss(animated: true)
            self?.postNotification()
        }
    }
    
    private func showAlert() {
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        
        let heightConstraint = NSLayoutConstraint(item: alert.view!,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 0,
                                                  constant: 170)
        alert.view.addConstraint(heightConstraint)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [weak self] action in
            self?.dataProvider.stopDownload()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            let progressView = UIProgressView(frame: CGRect(x: 0,
                                                            y: self.alert.view.frame.height - 44,
                                                            width: self.alert.view.frame.width,
                                                            height: 2))
            progressView.tintColor = .blue
            self.dataProvider.onProgress = { [weak self] progress in
                progressView.progress = Float(progress)
                self?.alert.message = "\(Int(progress * 100))%"
            }
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.label.text = controls[indexPath.row].rawValue
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let control = self.controls[indexPath.row]
        switch control {
        case .downloadImage:
            performSegue(withIdentifier: "imageSegue", sender: self)
        case .get:
            NetworkManager.getRequest(from: urlString)
        case .post:
            NetworkManager.postRequest(from: urlString)
        case .ourCourses:
            performSegue(withIdentifier: "coursesSegue", sender: self)
        case .uploadImage:
            NetworkManager.uploadImage(to: imgurApiUrl)
        case .downloadFile:
            showAlert()
            dataProvider.startDownload()
        case .ourCoursesAlamofire:
            performSegue(withIdentifier: "coursesSegueAlamofire", sender: self)
        case .responseDataAlamofire:
            performSegue(withIdentifier: "imageSegueAlamofire", sender: self)
        case .largeImageAlamofire:
            performSegue(withIdentifier: "largeImageSegue", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "postSegueAlamofire", sender: self)
        case .uploadImageAlamofire:
            AlamofireNetworkRequest.uploadImage(to: imgurApiUrl)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let coursesViewController = segue.destination as? CoursesTableViewController
        let imageViewController = segue.destination as? ImageViewController
        
        switch segue.identifier {
        case "coursesSegue":
            coursesViewController?.fetchCourses()
        case "coursesSegueAlamofire":
            coursesViewController?.fetchCoursesWithAlamofire()
        case "imageSegue":
            imageViewController?.fetchImage()
        case "imageSegueAlamofire":
            imageViewController?.fetchImageAlamofire()
        case "largeImageSegue":
            imageViewController?.fetchLargeImageAlamofire()
        case "postSegueAlamofire":
            coursesViewController?.postAlamofire()
        default:
            break
        }
    }
}

// MARK: Notifications

extension MainViewController {
    
    private func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func postNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Download completed!"
        content.body = "Background fetch has completed. File path: \(filePath!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Transfer completed", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: Facebook SDK

extension MainViewController {
    private func checkLoggedIn() {
//        if AccessToken.current == nil || AccessToken.current!.isExpired {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: false)
                return
            }
        }
    }
}
