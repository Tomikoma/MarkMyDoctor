//
//  ViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 21..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let url = URL(string: "http://localhost:3000/api/doctor") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                //print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let json2 = json as! [String: Any]
                    print(((json2["doctors"]! as! [Any])[0] as! [String: Any])["organization"]!)
                } catch {
                    print(error)
                }
                
            }
            }.resume()
        
        //print(UIDevice.current.identifierForVendor!.uuidString)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationvc = segue.destination
        
        if let addvc = destinationvc as? AddDoctorViewController {
            addvc.navigationItem.title = "Orvos Hozzáadása"
        }
        
        
        
    }

}

