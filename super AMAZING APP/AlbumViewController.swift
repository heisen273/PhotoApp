//
//  ViewController.swift
//  10/10 AMAZING APP
//
//  Created by antoha on 7/1/15.
//  Copyright © 2016 ANTOHIN APP. All rights reserved.
//

import UIKit
import Kingfisher
import SVPullToRefresh


extension Array {
    mutating func shuffle () {
        for i in (0..<self.count).reverse() {
            let ix1 = i
            let ix2 = Int(arc4random_uniform(UInt32(i+1)))
            (self[ix1], self[ix2]) = (self[ix2], self[ix1])
        }
    }
}

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIApplicationDelegate
{
 @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var cache = KingfisherManager.sharedManager.cache
    var images = [String]()
    var labels = [String]()
    var albumids = [Int]()
    var images_shuf = [String]()
    var labels_shuf = [String]()
    var albumids_shuf = [Int]()
    let link = "https://api.vk.com/method/photos.getAlbums?owner_id=-40886007&need_covers=1&photo_sizes=1"
    var numberOfItemsPerSection: Int = 0
    var reachability: Reachability?
    
    
    override func viewWillAppear(animated: Bool)
    {
        self.automaticallyAdjustsScrollViewInsets = true
        cache.maxCachePeriodInSecond = 60
        cache.maxDiskCacheSize = 125 * 1024 * 1024
        cache.cleanExpiredDiskCache()
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        }
        catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlbumViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }
        catch{
            print("could not start reachability notifier")
        }
    }
    
    
    func reachabilityChanged(note: NSNotification)
    {
        let reachability = note.object as! Reachability
        
        if !reachability.isReachable()
        {
            print("Network not reachable")
            let alert = UIAlertController(title: "No Internet Connection", message:"GET FIWI NEEGRO.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OKay.jpg", style: .Default) { _ in })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        get_json()
    
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.pullToRefreshView.self
        
    }
    
    
    func loadData()
    {
        autoreleasepool
            {
                images.removeAll()
                albumids.removeAll()
                labels.removeAll()
                images_shuf.removeAll()
                albumids_shuf.removeAll()
                labels_shuf.removeAll()
            
                dispatch_async(dispatch_get_main_queue(),{self.get_json()})
                cache.clearMemoryCache()
            }
    }
    
    
    func stopRefresher()
    {
        albumCollectionView.pullToRefreshView.stopAnimating()
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if numberOfItemsPerSection >= images.count
        {
            return images.count
        }
        else
        {
            return numberOfItemsPerSection
        }
    }
    
    
    internal func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height
        {
            numberOfItemsPerSection += 10
            self.albumCollectionView.reloadData()
            print("CLICK")
            print(numberOfItemsPerSection)
        }
        
        if offsetY < -130
        {
            self.albumCollectionView.addPullToRefreshWithActionHandler
                {
                self.loadData()
                let delayInSeconds = 0.75
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {() -> Void in
                    self.stopRefresher()}
                
                self.albumCollectionView.setContentOffset(CGPointMake(0, self.albumCollectionView.contentOffset.y), animated: true)
                }
            self.albumCollectionView.pullToRefreshView.setSubtitle("randomize", forState: 1)
            self.albumCollectionView.pullToRefreshView.setTitle("Release to randomize", forState: 1)
        }
    }
    
    
    
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let albumCell:AlbumCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("albumCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
        albumCell.layer.borderWidth=2.0
        albumCell.layer.borderColor=UIColor.darkGrayColor().CGColor
        
        autoreleasepool
            {
        albumCell.albumTitleLabel.text = self.labels[indexPath.row]
        let resource = Resource(downloadURL: NSURL(string: images[indexPath.row])!)
        albumCell.albumImageView.kf_showIndicatorWhenLoading = true
        albumCell.albumImageView.kf_setImageWithResource(resource, placeholderImage: UIImage(named:"asd"))
            }
        return albumCell
    }
    
    internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
   
    
    
    func extract_json_data(data:NSString)
    {
        autoreleasepool
            {
        let jsonData:NSData = data.dataUsingEncoding(NSUnicodeStringEncoding)!
        let json: AnyObject?
        do
        {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        }
        catch
        {
            print("error")
            return
        }
        
        if let images_array = json!["response"] as? [[String: AnyObject]]
        {
            for img in images_array
            {
                let aid = img["aid"] as? Int
                let lbl = img["title"] as? String
                //images.append(name)
                labels.append(lbl!)
                albumids.append(Int(aid!))
                
                if let name = img["sizes"] as? [[String: AnyObject]]
                {
                    for element in name
                    {
                        if let a = element["type"] as? String
                        {
                            if a == "r"
                            {
                                let imag = element["src"] as? String
                                images.append(imag!)
                                
                            }
                       }
                    }
                    
                    
                }
        
        else
            {
            print("error")
            return
            }
        }
    }
        
        }
        var indexes = [Int](0...images.count-1)
        indexes.shuffle()
        
        for i in indexes{
            images_shuf.append(images[i])
            labels_shuf.append(labels[i])
            albumids_shuf.append(albumids[i])}
        images = images_shuf
        labels = labels_shuf
        albumids = albumids_shuf
        dispatch_sync(dispatch_get_main_queue(), refresh)
        print(labels)
        print(albumids)
        
    }
    
    
    
    func refresh()
    {
        self.albumCollectionView.reloadData()
    }
    
    
    
    func get_json()
    {
       let url:NSURL = NSURL(string: link)!
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        
        autoreleasepool
            {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
        {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else
            {
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            self.extract_json_data(dataString!)
            
        }
            task.resume()
            }
        
    }
    

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let tmp = UIImageView()
        tmp.image = cache.retrieveImageInDiskCacheForKey(images[indexPath.row])
        autoreleasepool
            {
            if tmp.image != nil
                {
                    self.performSegueWithIdentifier("showAlbumImages", sender: self)
                }
            }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        autoreleasepool
        {
        if segue.identifier == "showAlbumImages"
            {
            let indexPaths = self.albumCollectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destinationViewController as! ImageViewController
            
            
            vc.album_id = Int(self.albumids[indexPath.row])
            cache.clearMemoryCache()
            }
        }
    }
    
}

