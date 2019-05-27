//
//  ViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 21..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

struct Doctor: Decodable {
    let name: String
    let organization: String
}

struct MyJson: Decodable {
    let doctors: [Doctor]
    let maxDoctors: Int
    let message: String

}

class MainViewController: UIViewController {
    

    var doctors: [Doctor] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(UIDevice.current.identifierForVendor!.uuidString)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchDoctors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchDoctors()
    }
    
    


    
    func fetchDoctors() {
        guard let url = URL(string: "http://localhost:3000/api/doctor") else { return }
        let session = URLSession.shared
        var doctors: [Doctor] = []
        let sem = DispatchSemaphore.init(value: 0)
        
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                //print(response)
            }
            
            if let data = data {
                do {
                    let myjson = try JSONDecoder().decode(MyJson.self, from: data)
                    print(myjson.doctors)
                    doctors = myjson.doctors
                } catch {
                    print(error)
                }
            sem.signal()
                
            }
            }.resume()
        sem.wait()
        self.doctors = doctors
        tableView.reloadData()
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

extension MainViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let doctor = doctors[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = doctor.name
        return cell
    }
    
    
}

