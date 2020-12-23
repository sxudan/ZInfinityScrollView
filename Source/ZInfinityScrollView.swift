//
//  ZInfinityScrollView.swift
//  Pods-ZInfinityScrollView_Example
//
//  Created by sudansuwal on 8/31/20.
//

import Foundation
import UIKit

public protocol ZInfinityViewDelegate {
    func zInfinityView(willPaginateTo zInfinityView: ZInfinityView, currentPage: Int) -> Int
    func zInfinityView(zInfinityView: ZInfinityView, didPaginateTo page: Int)
    func zInfinityView(zInfinityView: ZInfinityView, stateView state: ZInfinityView.State) -> UIView?
//    func zInfinityView(startPaginationOffset zInfinityView: ZInfinityView) -> CGFloat
}

public extension ZInfinityViewDelegate {
    func zInfinityView(zInfinityView: ZInfinityView, stateView state: ZInfinityView.State) -> UIView? {
        return nil
    }
    
    func zInfinityView(startPaginationOffset zInfinityView: ZInfinityView) -> CGFloat {
        return 60
    }
}

public class ZInfinityView: UIScrollView {
    
    var tableView: UITableView?
    var collectionView: UICollectionView?
    
    var heightContraint: NSLayoutConstraint?
    
    public var paginationDelegate: ZInfinityViewDelegate?
    
    var tableViewDelegate: UITableViewDelegate?
    var tableViewDataSource: UITableViewDataSource?
    
    public override var delegate: UIScrollViewDelegate? {
        didSet {
            super.delegate = self
        }
    }

    
    var page: Int = 1
    
    var stack: UIStackView!
    
    var loadingFooterView: UIView? {
        didSet {
            self.removeSecondStack()
            stack.insertArrangedSubview(self.loadingFooterView!, at: 1)
            self.loadingFooterView?.translatesAutoresizingMaskIntoConstraints = false
            self.loadingFooterView?.constraints.forEach({c in
                self.removeConstraint(c)
            })
            self.loadingFooterView?.heightAnchor.constraint(equalToConstant: self.loadingFooterView!.frame.height).isActive = true
        }
    }
    
    public enum State {
        case Loading
        case Ready
        case Ended
    }
    
    var state: State = .Ready {
        didSet {
            switch state {
            case .Loading:
                self.loadingFooterView = self.getLoaderView()
                self.loadingFooterView?.isHidden = false
            case .Ready:
                self.loadingFooterView?.isHidden = true
            case .Ended:
                self.loadingFooterView = self.getLoaderView()
                self.loadingFooterView?.isHidden = false
            }
        }
    }
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        
        stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.delegate = self
    }
    
    func initTableView() {
        self.tableView = nil
        for v in self.subviews {
            if v is UITableView {
                v.removeFromSuperview()
                print("I am here")
                self.tableView = v as? UITableView
                
                self.tableView?.constraints.forEach({c in
                    self.removeConstraint(c)
                })
            }
        }
        
        if tableView == nil {
            print("table view is nil")
            self.tableView = UITableView(frame: self.frame, style: .plain)
        }
        self.tableView?.isScrollEnabled = false
        self.removeFirstStack()
        stack.insertArrangedSubview(self.tableView!, at: 0)
        self.tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.contentSize.height = self.frame.size.height
        heightContraint = self.tableView?.heightAnchor.constraint(equalToConstant: self.frame.size.height)
        heightContraint?.isActive = true
    }
    
    func initCollectionView(layout: UICollectionViewLayout) {
        self.collectionView = nil
        for v in self.subviews {
            if v is UICollectionView {
                v.removeFromSuperview()
                print("I am here")
                self.collectionView = v as? UICollectionView
                
                self.collectionView?.constraints.forEach({c in
                    self.removeConstraint(c)
                })
            }
        }
        
        if collectionView == nil {
            print("collection view is nil")
            self.collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        }
        self.collectionView?.isScrollEnabled = false
        removeFirstStack()
        stack.insertArrangedSubview(self.collectionView!, at: 0)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.contentSize.height = self.frame.size.height
        heightContraint = self.collectionView?.heightAnchor.constraint(equalToConstant: self.frame.size.height)
        heightContraint?.isActive = true
    }
    
    public func setupTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource, handler: ((_ tableView: UITableView?) -> Void)?) {
        initTableView()
        handler?(self.tableView)
        self.tableView?.delegate = delegate
        self.tableView?.dataSource = datasource
    }
    
    public func setupCollectionView(layout: UICollectionViewLayout? = nil,delegate: UICollectionViewDelegateFlowLayout, datasource: UICollectionViewDataSource, handler: ((_ collectionView: UICollectionView?) -> Void)?) {
        
        let layout = layout ?? UICollectionViewFlowLayout()
        
        initCollectionView(layout: layout)
        handler?(self.collectionView)
        self.collectionView?.delegate = delegate
        self.collectionView?.dataSource = datasource

        
    }
    
    func updateHeightCalculation() {
        guard heightContraint != nil else {
            return
        }
        self.layoutIfNeeded()
        if let tv = tableView {
            self.heightContraint?.constant = tv.contentSize.height
        } else if let cv = collectionView {
            self.heightContraint?.constant = cv.collectionViewLayout.collectionViewContentSize.height
        }
        self.contentSize.height = self.heightContraint?.constant ?? 0
        if (self.heightContraint?.constant ?? 0) < self.frame.height && self.state == .Ready {
            print("loading due to less height")
            paginate()
            self.layoutIfNeeded()
        }
        
    }
    
    func removeFirstStack() {
        stack.arrangedSubviews.enumerated().forEach({(index, v) in
            if index == 0 {
                v.removeFromSuperview()
            }
        })
    }
    
    func removeSecondStack() {
        stack.arrangedSubviews.enumerated().forEach({(index, v) in
            if index == 1 {
                v.removeFromSuperview()
            }
        })
    }
    
    func paginate() {
        print("I am going to paginate")
        self.state = .Loading
        self.page = (self.paginationDelegate?.zInfinityView(willPaginateTo: self, currentPage: self.page)) ?? 1
        
        self.paginationDelegate?.zInfinityView(zInfinityView: self, didPaginateTo: self.page + 1)
    }
    
    private func hardReload() {
        self.tableView?.reloadData()
        self.collectionView?.reloadData()
        self.updateHeightCalculation()
        self.state = .Ready
    }
    
    public func reloadData(data: [Any]? = nil) {
        
        if data != nil {
            
            if data?.count == 0 {
                hardReload()
                return
            }
            
            var indexPathsToReload = [IndexPath]()
            
            let section = 0
            var row: Int = 0
            
            if collectionView != nil {
                row = (self.collectionView?.numberOfItems(inSection: section) ?? 0)
            } else if tableView != nil {
                row = (self.tableView?.numberOfRows(inSection: section) ?? 0)
                
            }
            
            
            if row < 0 {
                row = 0
            }
            
            //add new data from server response
            for _ in data ?? [] {
                let indexPath = IndexPath(row: row, section: section)
                indexPathsToReload.append(indexPath)
                row+=1
            }
            
            
            
            print(indexPathsToReload)
            
            if tableView != nil {
                self.hardReload()
            }
            
            
            self.collectionView?.performBatchUpdates {
                self.collectionView?.insertItems(at: indexPathsToReload)
            }
            
            self.updateHeightCalculation()
            self.state = .Ready
        } else {
            self.hardReload()
        }
        
        
    }
    
    public func stopPagination() {
        self.state = .Ended
    }
    
    public func restart() {
        self.page = 1
        self.reloadData(data: [])
    }
    
    
    func getLoaderView() -> UIView {
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 60))
        //add childView
        var childView: UIView!
        if let v = self.paginationDelegate?.zInfinityView(zInfinityView: self, stateView: self.state) {
            childView = v
        } else {
            if self.state == .Loading {
                let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                indicator.startAnimating()
                childView = indicator
            } else if self.state == .Ended {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                label.text = "No Content"
                label.sizeToFit()
                label.textColor = .lightGray
                label.font = UIFont(name: "System", size: 13)
                label.textAlignment = .center
                childView = label
            }
        }
        bottomView.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        //Adding Constraints
        childView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        childView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        childView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
        childView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return bottomView
    }
    
}

public class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ZInfinityView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        self.layoutIfNeeded()
        let hiddenHeight = (self.heightContraint!.constant + self.contentInset.top + self.contentInset.bottom) - self.frame.size.height
        
        if hiddenHeight <= 0 {
            //nothing
        } else {
            if offset >= (hiddenHeight - (self.paginationDelegate?.zInfinityView(startPaginationOffset: self) ?? 60)) && self.state == .Ready {
                paginate()
            } else {

            }
        }
   
    }
}
