//
//  AddDoctorViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 25..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

class AddDoctorViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var orgTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func addDoctor(_ sender: UIButton) {
        if let name = nameTF.text, let org = orgTF.text {
            if(name == "" || org == "" ){
                makeAlert(msg: "Mindkét mezőt ki kell tölteni!")
            } else {
                let parameters: [String:Any] = ["name" : name, "org" : org]
                guard let url = URL(string: "http://localhost:3000/api/doctor") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters , options: [] ) else {
                    makeAlert(msg: "Hiba történt a doktor hozzáadása közben!")
                    return
                }
                request.httpBody = httpBody
                
                let session = URLSession.shared
                session.dataTask(with: request) { (data,response,error) in
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [] )
                            print(json)
                        } catch {
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
    
    func makeAlert(msg: String) {
        let alert = UIAlertController(title: "Hiba", message: msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
