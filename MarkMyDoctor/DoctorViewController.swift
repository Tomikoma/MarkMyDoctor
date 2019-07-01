//
//  DoctorViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 27..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

struct Rates: Decodable {
    let exp: Float
    let price: Float
    let kindness: Float
    let sexiness: Float
    let count: Int
}


class DoctorViewController: UIViewController {

    var doctor: Doctor?
    var exp: Float?
    var price: Float?
    var kindness: Float?
    var sexiness: Float?
    var count: Int?
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sexyLabel: UILabel!
    @IBOutlet weak var avgExpLabel: UILabel!
    @IBOutlet weak var avgKindLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var avgSexinessLabel: UILabel!
    @IBOutlet weak var statisticLabel: UILabel!
    
    
    @IBAction func expValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        expLabel.text = "\(currentValue)"
    }
    
    @IBAction func priceValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        priceLabel.text = "\(currentValue)"
    }
    
    @IBAction func sexyValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        sexyLabel.text = "\(currentValue)"
    }
    
    @IBAction func kindnessValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        kindLabel.text = "\(currentValue)"
    }
    @IBAction func rateDoctor(_ sender: UIButton) {
        var msg:String?
        var title:String?
        if let doc = doctor, let exp = expLabel.text, let kindness = kindLabel.text, let price = priceLabel.text, let sexiness = sexyLabel.text {
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            let id = doc._id
            let parameters: [String:Any] = ["uuid" : uuid, "id" : id, "exp" : exp, "kindness" : kindness, "price" : price, "sexiness" : sexiness ]
            guard let url = URL(string: "http://localhost:3000/api/doctor/rate") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters , options: [] ) else {
                makeAlert(title:"Hiba", msg: "Hiba történt a doktor értékelése közben!")
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
        if let title = title, let msg = msg {
            makeAlert(title: title, msg: msg)
        }
        fetchRatings()
    }
    
    func fetchRatings() {
        guard let url = URL(string: "http://localhost:3000/api/doctor/rate/\(doctor!._id)") else { return }
        let session = URLSession.shared
        let sem = DispatchSemaphore.init(value: 0)
        
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                //print(response)
            }
            
            if let data = data {
                do {
                    let myjson = try JSONDecoder().decode(Rates.self, from: data)
                    self.exp = myjson.exp
                    self.price = myjson.price
                    self.kindness = myjson.kindness
                    self.sexiness = myjson.sexiness
                    self.count = myjson.count
                } catch {
                    print(error)
                }
                sem.signal()
                
            }
            }.resume()
        sem.wait()
        if let doc = doctor, let exp = exp, let price = price, let kindness = kindness, let sexiness = sexiness, let count = count {
            orgLabel.text = doc.organization
            avgExpLabel.text = "\(exp)"
            avgPriceLabel.text = "\(price)"
            avgKindLabel.text = "\(kindness)"
            avgSexinessLabel.text = "\(sexiness)"
            statisticLabel.text = "Statisztika (\(count))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRatings()
        expLabel.text = "5"
        kindLabel.text = "5"
        priceLabel.text = "5"
        sexyLabel.text = "5"
        

    }
    
    func makeAlert(title:String,msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    

}
