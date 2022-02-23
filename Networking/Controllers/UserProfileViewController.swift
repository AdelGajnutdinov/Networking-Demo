//
//  UserProfileViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 07.11.2021.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

class UserProfileViewController: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32, y: 520, width: view.frame.width - 64, height: 50)
        button.backgroundColor = UIColor(hex: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: PRIMARY_COLOR, bottomColor: SECONDARY_COLOR)
        view.addSubview(logoutButton)
        usernameLabel.isHidden = true
    }
    
    private func fetchUserData() {
        if let userName = Auth.auth().currentUser?.displayName {
            activityIndicator.stopAnimating()
            usernameLabel.isHidden = false
            usernameLabel.text = getGreetings(for: userName)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference()
                .child("users")
                .child(uid)
                .observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let userData = snapshot.value as? [String : Any] else { return }
                    self?.activityIndicator.stopAnimating()
                    self?.usernameLabel.isHidden = false
                    self?.currentUser = CurrentUser(uid: uid, data: userData)
                    self?.usernameLabel.text = self?.getGreetings(for: self?.currentUser?.name ?? "Noname")
                } withCancel: { error in
                    print(error.localizedDescription)
                }
        }

    }
}

extension UserProfileViewController {
    private func openLoginViewController() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
                return
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func signOut() {
        guard let providerData = Auth.auth().currentUser?.providerData else { return }
        for userInfo in providerData {
            switch userInfo.providerID {
            case "facebook.com":
                LoginManager().logOut()
                print("User did log out of Facebook")
                openLoginViewController()
            case "google.com":
                GIDSignIn.sharedInstance.signOut()
                print("User did log out of Google")
                openLoginViewController()
            case "password":
                try! Auth.auth().signOut()
                print("User did log out")
                openLoginViewController()
            default:
                print("User still signed in with", userInfo.providerID)
            }
        }
    }
    
    private func getGreetings(for userName: String) -> String {
        var greetings = ""
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    self.provider = "Facebook"
                case "google.com":
                    self.provider = "Google"
                case "password":
                    self.provider = "Email"
                default:
                    self.provider = "Unknown"
                }
            }
            greetings = "Hello, \(userName)! You have logged in using \(self.provider!)"
        }
        return greetings
    }
}
