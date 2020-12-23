//
//  ViewController.swift
//  ZInfinityScrollView
//
//  Created by sxudan on 08/31/2020.
//  Copyright (c) 2020 sxudan. All rights reserved.
//

import UIKit
import ZInfinityScrollView

struct ImgResp: Codable {
    let hits : [Img]
}

struct Img: Codable {
    let previewURL : String
    let user: String
    let tags: String
}


class ViewController1: UIViewController {

    
    @IBOutlet weak var zInfinityView: ZInfinityView!
    
    
    let refreshControl = UIRefreshControl()
    
    var page: Int = 1
    
    var data = ["Anderson", "Ashwoon", "Aikin", "Bateman", "Bongard", "Bowers", "Boyd", "Cannon", "Cast", "Deitz", "Dewalt", "Ebner", "Frick", "Hancock", "Haworth", "Hesch", "Hoffman", "Kassing", "Knutson", "Lawless", "Lawicki", "Mccord", "McCormack", "Miller", "Myers", "Nugent", "Ortiz", "Orwig", "Ory", "Paiser", "Pak", "Pettigrew", "Quinn", "Quizoz", "Ramachandran", "Resnick", "Sagar", "Schickowski", "Schiebel", "Sellon", "Severson", "Shaffer", "Solberg", "Soloman", "Sonderling", "Soukup", "Soulis", "Stahl", "Sweeney", "Tandy", "Trebil", "Trusela", "Trussel", "Turco", "Uddin", "Uflan", "Ulrich", "Upson", "Vader", "Vail", "Valente", "Van Zandt", "Vanderpoel", "Ventotla", "Vogal", "Wagle", "Wagner", "Wakefield", "Weinstein", "Weiss", "Woo", "Yang", "Yates", "Yocum", "Zeaser", "Zeller", "Ziegler", "Bauer", "Baxster", "Casal", "Cataldi", "Caswell", "Celedon", "Chambers", "Chapman", "Christensen", "Darnell", "Davidson", "Davis", "DeLorenzo", "Dinkins", "Doran", "Dugelman", "Dugan", "Duffman", "Eastman", "Ferro", "Ferry", "Fletcher", "Fietzer", "Hylan", "Hydinger", "Illingsworth", "Ingram", "Irwin", "Jagtap", "Jenson", "Johnson", "Johnsen", "Jones", "Jurgenson", "Kalleg", "Kaskel", "Keller", "Leisinger", "LePage", "Lewis", "Linde", "Lulloff", "Maki", "Martin", "McGinnis", "Mills", "Moody", "Moore", "Napier", "Nelson", "Norquist", "Nuttle", "Olson", "Ostrander", "Reamer", "Reardon", "Reyes", "Rice", "Ripka", "Roberts", "Rogers", "Root", "Sandstrom", "Sawyer", "Schlicht", "Schmitt", "Schwager", "Schutz", "Schuster", "Tapia", "Thompson", "Tiernan", "Tisler"]
    
    var contents = [String]()
    
    
    func getData(page: Int, handler: ((Int?) -> Void)?) {
        
        let url = "https://pixabay.com/api/?key=18062679-8456879942546e226c204d6ca&q=girl&image_type=photo&page=\(page)"
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        
        
        let session = URLSession.shared.dataTask(with: request, completionHandler: {(data, res, err) in
            guard err == nil else {
                print("error : \(String(describing: err))")
                return
            }
            
            if let data = data {
                let d = try? JSONDecoder().decode(ImgResp.self, from: data)
                let datas = d?.hits.map({data in
                    return data.tags
                })
                if page == 1 {
                    self.contents = Array(datas?[0...2] ?? []) ///loading just 3 items from api
                    DispatchQueue.main.async {
                        if datas == nil {
                            self.zInfinityView.stopPagination()
                        } else {
                            self.zInfinityView.reloadData(data: Array(datas?[0...2] ?? []))
                      
                        }
                    }
                } else {
                    self.contents.append(contentsOf: datas ?? [])
                    DispatchQueue.main.async {
                        if datas == nil {
                            self.zInfinityView.stopPagination()
                        } else {
                            self.zInfinityView.reloadData(data: Array(datas?[0...2] ?? []))
                      
                        }
                    }
                }
                
                
            }
        })
        
        session.resume()
    }
    
    var cancelled: Bool = false
    
    var v: ZInfinityView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        zInfinityView.refreshControl = refreshControl
        
        self.zInfinityView.setupTableView (delegate: self, datasource: self, handler: { tableview in
            // access tableview here
        })
        self.zInfinityView.paginationDelegate = self
        self.getData(page: 1, handler: nil)
    }
    
    @objc func onRefresh() {
        refreshControl.endRefreshing()
        self.contents = []
        self.zInfinityView.restart()
        self.getData(page: 1, handler: nil)
    }

    
}

extension ViewController1: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.contents[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}
extension ViewController1: ZInfinityViewDelegate {
    
    func zInfinityView(willPaginateTo zInfinityView: ZInfinityView, currentPage: Int) -> Int {
        /** Next page number*/
        return currentPage + 1
    }
    
    func zInfinityView(zInfinityView: ZInfinityView, didPaginateTo page: Int) {
        /**API calls here*/
        getData(page: page, handler: nil)
    }

}
