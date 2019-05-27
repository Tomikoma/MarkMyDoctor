//
//  AddDoctorViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 25..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

struct MyMessage: Decodable {
    let message:String
}

class AddDoctorViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var orgTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func addDoctor(_ sender: UIButton) {
        var msg:String?
        var title:String?
        if let name = nameTF.text, let org = orgTF.text {
            if(name == "" || org == "" ){
                //makeAlert(title:"Hiba", msg: "Mindkét mezőt ki kell tölteni!")
                title="Hiba"
                msg="Mindkét mezőt ki kell tölteni!"
            } else {
                let parameters: [String:Any] = ["name" : name, "org" : org]
                guard let url = URL(string: "http://localhost:3000/api/doctor") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters , options: [] ) else {
                    makeAlert(title:"Hiba", msg: "Hiba történt a doktor hozzáadása közben!")
                    return
                }
                request.httpBody = httpBody
                
                let session = URLSession.shared
                let sem = DispatchSemaphore.init(value: 0)
                session.dataTask(with: request) { (data,response,error) in
                    if let data = data {
                        do {
                            let json = try JSONDecoder().decode(MyMessage.self, from: data)
                            title = "Információ"
                            msg = json.message
                        } catch {
                            print(error)
                        }
                    }
                    sem.signal()
                }.resume()
                sem.wait()
            }
        }
        if let title = title, let msg = msg {
            makeAlert(title: title, msg: msg)
        }
    }
    
    func makeAlert(title:String,msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
