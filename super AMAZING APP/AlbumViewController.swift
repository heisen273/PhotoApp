//
//  ViewController.swift
//  10/10 AMAZING APP
//
//  Created by antoha on 7/1/15.
//  Copyright © 2016 ANTOHIN APP. All rights reserved.
//

import UIKit
import Kingfisher



class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIApplicationDelegate
{
 @IBOutlet weak var albumCollectionView: UICollectionView!
    
    
    var cache = KingfisherManager.sharedManager.cache
    
    var images = [String]()
    var labels = [String]()
    var albumids = [Int]()
    let link = "https://api.vk.com/method/photos.getAlbums?owner_id=-40886007&need_covers=1&photo_sizes=1"
    
    var numberOfItemsPerSection: Int = 0
    var reachability: Reachability?
    
    override func viewWillAppear(animated: Bool) {
        
        
        
        cache.maxCachePeriodInSecond = 60
        
        cache.maxDiskCacheSize = 125 * 1024 * 1024
        
        
        cache.cleanExpiredDiskCache()
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlbumViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if !reachability.isReachable() {
            print("Network not reachable")
            let alert = UIAlertController(title: "No Internet Connection", message:"GET FIWI NEEGRO.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OKay.jpg", style: .Default) { _ in })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        get_json()
        
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        
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
    
    internal func scrollViewDidScroll(scrollView: UIScrollView) {
        //numberOfItemsPerSection = abs(10 - images.count)
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            numberOfItemsPerSection += 10
            self.albumCollectionView.reloadData()
            print("CLICK")
            print(numberOfItemsPerSection)
        }
    }
    
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let albumCell:AlbumCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("albumCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
        
        //et rect = self.albumCollectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        
        albumCell.layer.borderWidth=2.0
        albumCell.layer.borderColor=UIColor.darkGrayColor().CGColor
        
        
        autoreleasepool
            {albumCell.albumTitleLabel.text = self.labels[indexPath.row]
        
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
        autoreleasepool{
        let jsonData:NSData = data.dataUsingEncoding(NSUnicodeStringEncoding)!
        //let jsonData:NSData = data.dataUsingEncoding(NSASCIIStringEncoding)!
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
        
        
        dispatch_async(dispatch_get_main_queue(), refresh)
        }
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
        
        autoreleasepool{
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
        {
            (
            let data, let response, let error) in
            
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
        autoreleasepool{
            
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

