//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse(data:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        // 1.get request token
        //    2.  specify webAuth url and redirect url
        // 3. UIApplication open an url
        
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    
    func handleRequestTokenResponse(data: RequestTokenResponse?, error: Error?) {
        if (data?.success ?? false) {
            TMDBClient.Auth.requestToken = data!.requestToken!
            DispatchQueue.main.async {
                TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(data:error:))
            }
        }
    }
    
    func handleLoginResponse(data: RequestTokenResponse?, error: Error?) {
        if (data!.success ?? false) {
            TMDBClient.Auth.requestToken = data!.requestToken! // update request token
            print("Login Success")
            TMDBClient.createSession(completion: handleSessionResponse(data:error:))
        } else {
            print("Login Failed")
            return
        }
    }
    
    func handleSessionResponse(data: SessionResponse?, error: Error?) {
        if (data!.success ?? false) {
            TMDBClient.Auth.sessionId = data!.sessionID!
            print("\(TMDBClient.Auth.sessionId)")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
    
    class func handleGetWatchListReponse(data: MovieResults?, error: Error?) {
        guard let data = data else {
            print(error!)
            return
        }
        MovieModel.watchlist = data.results
    }

}
