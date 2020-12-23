//
//  ViewController2.swift
//  ZInfinityScrollView_Example
//
//  Created by sudayn on 11/16/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZInfinityScrollView

class ViewController2: UIViewController {
    
    @IBOutlet weak var zInfinityView: ZInfinityView!
    
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
                let datas = d?.hits.map({res in
                    return res.previewURL
                })
                if page == 1 {
//                    ?[0...2]
                    self.contents = Array(datas ?? []) ///loading just 3 items from api
                    DispatchQueue.main.async {
                        if datas == nil {
                            self.zInfinityView.stopPagination()
                        } else {
                            self.zInfinityView.reloadData(data: Array(datas ?? []))
                      
                        }
                    }
                } else {
                    self.contents.append(contentsOf: Array(datas?[0...2] ?? []))
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

    override func viewDidLoad() {
        super.viewDidLoad()
        

        zInfinityView.setupCollectionView(delegate: self, datasource: self, handler: {collectionView in
            collectionView?.register(UINib(nibName: "collectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionviewcell")
            collectionView?.backgroundColor = .white
        })
        zInfinityView.paginationDelegate = self
        getData(page: 1, handler: nil)
    }

}

extension ViewController2: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcell", for: indexPath) as! collectionViewCell
        cell.imageCellView.loadImage(from: contents[indexPath.row], completed: {
            
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - 24, height: collectionView.frame.width/2 - 24)
    }
    
}

extension ViewController2: ZInfinityViewDelegate {
    func zInfinityView(zInfinityView: ZInfinityView, didPaginateTo page: Int) {
        getData(page: page, handler: nil)
    }
    
    func zInfinityView(willPaginateTo zInfinityView: ZInfinityView, currentPage: Int) -> Int {
        return currentPage + 1
    }
}

extension UIImageView {
    func loadImage(from url: String, completed: @escaping () -> ()) {
        
        
        
        let imageURL = URL(string: url)
        
        DispatchQueue.global().async { [weak self] in
            
            if let data = try? Data(contentsOf: imageURL!) {
                
                if let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        self?.image = image
                        completed()
                    }
                }
            }
        }
    }
}
