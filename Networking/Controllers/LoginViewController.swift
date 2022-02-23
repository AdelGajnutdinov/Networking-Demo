//
//  LoginViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 06.11.2021.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let indent: CGFloat = 32
    var userProfile: UserProfile?
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: indent, y: 400, width: view.frame.width - indent * 2, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFBLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hex: "#3B5999")
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: indent, y: 400 + 60, width: view.frame.width - indent * 2, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: indent, y: 400 + 60 + 60, width: view.frame.width - indent * 2, height: 50)
        loginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var customGoogleLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = .white
        loginButton.setTitle("Login with Google", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.gray, for: .normal)
        loginButton.frame = CGRect(x: indent, y: 400 + 60 + 60 + 60, width: view.frame.width - indent * 2, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var signInButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.frame = CGRect(x: indent, y: 400 + 60 + 60 + 60 + 60, width: view.frame.width - indent * 2, height: 50)
        loginButton.addTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
        return loginButton
    }()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: PRIMARY_COLOR, bottomColor: SECONDARY_COLOR)
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInButton)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func saveToFirebase() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let values = [id : ["name" : userProfile?.name,
                            "email" : userProfile?.email]]
        Database.database().reference().child("users").updateChildValues(values) { [weak self] error, _ in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Successfully saved user data into Firebase!")
            self?.openMainViewController()
        }
    }
}

// MARK: Facebook SDK
extension LoginViewController: LoginButtonDelegate {
    @objc private func handleCustomFBLogin() {
        LoginManager().logIn(permissions: [.publicProfile, .email], viewController: self) { [weak self] result in
            switch result {
            case .success(granted: let permissions, _, _):
                print(permissions)
                self?.signIntoFirebase()
            case .cancelled:
                break
            case .failed(let error):
                print(error.localizedDescription)
            @unknown default:
                break
            }
        }
    }
    
    private func signIntoFirebase() {
        let accessToken = AccessToken.current
        guard let token = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credentials) { [weak self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Successfully signed in with:", user!)
            self?.fetchFacebookProfileInfo()
        }
    }
    
    private func fetchFacebookProfileInfo() {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { [weak self] _, result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let profileData = result as? [String: Any] {
                self?.userProfile = UserProfile(profileData: profileData)
                self?.saveToFirebase()
            }
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let token = AccessToken.current, !token.isExpired else { return }
        print("Logged in!")
        signIntoFirebase()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Log out")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
}

// MARK: Google SDK
extension LoginViewController {
    
    @objc func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Logged into Google!")
            if let userName = user?.profile?.name, let email = user?.profile?.email {
                let userData = ["name" : userName, "email" : email]
                self.userProfile = UserProfile(profileData: userData)
            }
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("Logged into Firebase with Google!")
                self.saveToFirebase()
            }
        }
    }
}

//MARK: Sign In with email
extension LoginViewController {
    @objc private func signInWithEmail() {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
}
