//
//  ViewController.swift
//  MarkMyDoctor
//
//  Created by Tamás Szabó on 2019. 05. 21..
//  Copyright © 2019. Tamás Szabó. All rights reserved.
//

import UIKit

struct Doctor: Decodable {
    let _id: String
    let name: String
    let organization: String
}

struct MyJson: Decodable {
    let doctors: [Doctor]
    let maxDoctors: Int
    let message: String

}

struct Org: Decodable {
    let organizations: [String]
}

class MainViewController: UIViewController {
    
    var doctors: [Doctor] = []
    var organizations: [String] = []
    var currentOrg: String?
    var currentDoctor: Doctor?
    var sem = DispatchSemaphore.init(value: 1)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orgPickerView: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchOrganizations()
        currentOrg = organizations.first!
        fetchDoctors(organizations.first!)
        
        orgPickerView.dataSource = self
        orgPickerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchOrganizations()
        fetchDoctors(currentOrg!)
    }
    
    

    func fetchOrganizations(){
        guard let url = URL(string: "http://localhost:3000/api/doctor/org") else { return }
        let session = URLSession.shared
        //var doctors: [Doctor] = []
        let sem = DispatchSemaphore.init(value: 0)
        
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                //print(response)
            }
            
            if let data = data {
                do {
                    let myjson = try JSONDecoder().decode(Org.self, from: data)
                    self.organizations = myjson.organizations
                } catch {
                    print(error)
                }
                sem.signal()
                
            }
            }.resume()
        sem.wait()
        //self.doctors = doctors
        //tableView.reloadData()

    }
    
    func fetchDoctors(_ organization: String) {
        let parameters: [String:Any] = ["organization" : organization]
        guard let url = URL(string: "http://localhost:3000/api/doctor/organization") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters , options: [] ) else {
            //makeAlert(title:"Hiba", msg: "Hiba történt a doktor hozzáadása közben!")
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        let sem = DispatchSemaphore.init(value: 0)
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(MyJson.self, from: data)
                    self.doctors = json.doctors
                } catch {
                    print(error)
                }
            }
            sem.signal()
            }.resume()
        sem.wait()
        tableView.reloadData()
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationvc = segue.destination
        
        if let addvc = destinationvc as? AddDoctorViewController {
            addvc.navigationItem.title = "Orvos Hozzáadása"
        }
        if let doctorvc = destinationvc as? DoctorViewController {
            if let doc = currentDoctor {
                doctorvc.navigationItem.title = doc.name
                doctorvc.doctor = doc
            }
        }
        
        
        
        
        
    }

}

extension MainViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let doctor = doctors[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        cell.textLabel?.text = doctor.name
        cell.detailTextLabel?.text = doctor.organization
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentDoctor = doctors[indexPath.row]
        let destinationvc = DoctorViewController()
        if let dc = currentDoctor {
            destinationvc.doctor = dc
            self.performSegue(withIdentifier: "doctorSegue", sender: dc)
            
        }
       
    }
    
    
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return organizations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(organizations[row])
        currentOrg = organizations[row]
        fetchDoctors(organizations[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return organizations[row]
    }
}

