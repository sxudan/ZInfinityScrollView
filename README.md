# ZInfinityScrollView

[![CI Status](https://img.shields.io/travis/sxudan/ZInfinityScrollView.svg?style=flat)](https://travis-ci.org/sxudan/ZInfinityScrollView)
[![Version](https://img.shields.io/cocoapods/v/ZInfinityScrollView.svg?style=flat)](https://cocoapods.org/pods/ZInfinityScrollView)
[![License](https://img.shields.io/cocoapods/l/ZInfinityScrollView.svg?style=flat)](https://cocoapods.org/pods/ZInfinityScrollView)
[![Platform](https://img.shields.io/cocoapods/p/ZInfinityScrollView.svg?style=flat)](https://cocoapods.org/pods/ZInfinityScrollView)

## About `ZInfinityScrollView`
ZInfinityScrollView is created for only one purpose and that is for the purpose for pagination. With ZInfinityScroll view, you can perform pagination quickly. ZInfinityScrollView is subclass of UIScrollView and uses UITableView for listing datas.

## Documentation

1.  Add a UIScrollView in storyboard and make it of class ZInfinityView and add a outlet to a viewcontroller.
`@IBOutlet weak var zInfinityView: ZInfinityView!`
2. Setup tableview with this code
`self.zInfinityView.setupTableView (delegate: self, datasource: self, handler: { tableview in`
            // access tableview here
`})`
3. Add pagination delegate to the view
`self.zInfinityView.paginationDelegate = self`

4. Call API
        // Get Data from API

        // After fetching data call reloadData

        self.zInfinityView.reloadData()
        
    // If you want to stop pagination 
       
        self.zInfinityView.stopPagination()
        
    // If you want to restart pagination ie restart the page counter.
       
        self.zInfinityView.restart()

5. Confirm delegates to view controller
        
        extension ViewController: UITableViewDelegate, UITableViewDataSource {
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

        extension ViewController: ZInfinityViewDelegate {
        func zInfinityView(willPaginateTo zInfinityView: ZInfinityView, currentPage: Int) -> Int {
        /** Next page number*/
        return currentPage + 1
        }
        
        func zInfinityView(zInfinityView: ZInfinityView, didPaginateTo page: Int) {
        /**API calls here*/
        getData(page: page, handler: nil)
        }
        }


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZInfinityScrollView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZInfinityScrollView'
```

## Author

sxudan, sudan.suwal@spiralogics.com

## License

ZInfinityScrollView is available under the MIT license. See the LICENSE file for more info.
