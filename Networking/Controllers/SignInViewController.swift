//
//  SignInViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 14.11.2021.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var continueButtonCenter: CGPoint!
    lazy var continueButton: UIButton = {
        var button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = continueButtonCenter
        button.backgroundColor = .white
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(SECONDARY_COLOR, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: PRIMARY_COLOR, bottomColor: SECONDARY_COLOR)
        self.continueButtonCenter = CGPoint(x: view.center.x, y: view.frame.height - 200)
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = SECONDARY_COLOR
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
        view.addSubview(activityIndicator)
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setContinueButton(enabled: Bool) {
        if enabled {
            self.continueButton.alpha = 1
            self.continueButton.isEnabled = true
        } else  {
            self.continueButton.alpha = 0.5
            self.continueButton.isEnabled = false
        }
    }
    
    @objc private func handleSignIn() {
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                print(error.localizedDescription)
                self?.setContinueButton(enabled: true)
                self?.continueButton.setTitle("Continue", for: .normal)
                self?.activityIndicator.stopAnimating()
                return
            } else {
                print("Successfully signed in with Email")
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
        }
    }
    
    @objc private func textFieldChanged() {
        
        guard let email = self.emailTextField.text,
              let password = self.passwordTextField.text else { return }
        let isDisabled = email.isEmpty || password.isEmpty
        setContinueButton(enabled: !isDisabled)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityIndicator.center = continueButton.center
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        continueButton.center = continueButtonCenter
        activityIndicator.center = continueButton.center
    }
}
