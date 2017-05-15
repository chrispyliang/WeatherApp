//
//  ViewController.swift
//  WeatherApp
//
//  Created by Chris Liang on 2017-05-14.
//  Copyright © 2017 Chrispy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var degreeLabel: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    // variables
    var degree: Int!
    var condition: String!
    var city: String!
    var imgURL: String!
    
    var found = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=427abdc13af34425b1714751171505&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    if let current = json["current"] as? [String : AnyObject] {
                        
                        if let temp = current["temp_c"] as? Int {
                            self.degree = temp
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            // print(condition)
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imgURL = "http:\(icon)"
                        }
                    }
                    if let location = json["location"] as? [String : AnyObject] {
                        self.city = location["name"] as! String
                    }
                    if let _ = json["error"] {
                        self.found = false
                    }
                    
                    DispatchQueue.main.async {
                        if self.found {
                            self.degreeLabel.isHidden = false
                            self.conditionLabel.isHidden = false
                            self.imgView.isHidden = false
                            self.degreeLabel.text = "\(self.degree.description)°"
                            self.cityLabel.text = self.city
                            self.conditionLabel.text = self.condition
                            self.imgView.downloadedFrom(link: self.imgURL)
                            print(self.imgURL)
                        } else {
                            self.degreeLabel.isHidden = true
                            self.conditionLabel.isHidden = true
                            self.imgView.isHidden = true
                            self.cityLabel.text = "No Matching City Found"
                            self.found = true
                        }
                    }
                    
                }
                catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        
        task.resume()
        
        
        
        
    }
}

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


