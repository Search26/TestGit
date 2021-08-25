//
//  ViewController.swift
//  YoutubeAPI
//
//  Created by Ney on 24/08/2021.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController {

    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    
    private let service = GTLRYouTubeService()
    let signInButton = GIDSignInButton()
    let output = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignIn()
        signInButton.frame = CGRect(x: 100, y: 100, width: 100, height: 30)
        view.addSubview(signInButton)
        
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output)
    }
    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func fetchChannelResource() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet,statistics")
        //query.identifier = ""
        query.mine = true
        service.executeQuery(query, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket , finishedWithObject response : GTLRYouTube_ChannelListResponse , error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        if let channels = response.items , !channels.isEmpty {
            let channel = response.items![0]
            let title = channel.snippet!.title
            let description = channel.snippet?.descriptionProperty
            let viewCount = channel.statistics?.viewCount
            outputText += "title: \(title!)\n"
            outputText += "description: \(description!)\n"
            outputText += "view count : \(viewCount!)\n"
            
        }
        output.text = outputText
        
    }
    
    func showAlert(title  : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        }
        else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchChannelResource()
        }
    }
    
    
}

extension ViewController: GIDSignInUIDelegate {
    
}


