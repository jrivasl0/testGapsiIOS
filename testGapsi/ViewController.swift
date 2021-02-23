//
//  ViewController.swift
//  testGapsi
//
//  Created by Rivas on 22/02/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchController : UISearchController!
    var resultsController = UITableViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = UserDefaults.standard
    
    var items : [JSON] = []
    
    var searching = false
    
    var searches :[String] = []
    var searchesOriginal:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search(search: "")
        if((defaults.stringArray(forKey: "searches")?.isEmpty) != nil){
            searches = defaults.stringArray(forKey: "searches")!
            searchesOriginal = defaults.stringArray(forKey:  "searches")!
        }
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func search(search: String){
        let headers: HTTPHeaders = ["X-IBM-Client-Id": "adb8204d-d574-4394-8c1a-53226a40876e"]
        let request = AF.request("https://00672285.us-south.apigw.appdomain.cloud/demo-gapsi/search?query="+search, headers: headers)
        request.responseJSON { (data) in
            let json2 = JSON(data.data!)
            self.items = json2["items"].array!
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if(searching) {return searches.count}
        else {return items.count}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(searching) {return 40}
        else {return 150}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(searching){
            let cell:UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = searches[indexPath.row]
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
            cell.title.text = items[indexPath.row]["title"].string
            cell.price.text = String(format: "$%.2f", items[indexPath.row]["price"].float!)
            let url = URL(string: items[indexPath.row]["image"].string!)
            downloadImage(from: url!, imageView: cell.img)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searching){
            self.searchBar.text = searches[indexPath.row]
            searching = false
            self.tableView.reloadData()
            search(search: searches[indexPath.row])
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) {
            data, response, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(search: searchBar.text!)
        searchesOriginal.append(searchBar.text!)
        defaults.set(searchesOriginal, forKey: "searches")
        searching = false
        self.searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searching = true
        tableView.reloadData()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searching = false
            self.searchBar.endEditing(true)
            searching = true
            searches = []
            for valueString in searchesOriginal{
                searches.append(valueString)
            }
            tableView.reloadData()
        } else{
            searching = true
            searches = []
            for valueString in searchesOriginal{
                if(valueString.lowercased().contains(searchText.lowercased())){
                    searches.append(valueString)
                }
            }
            tableView.reloadData()
        }
    }
}
