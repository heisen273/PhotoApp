//
//  CellViewController.swift
//  PhotoApp
//
//  Created by Walter White on 7/28/16.
//  Copyright © 2016 TOHANI4 SOFTWARE. All rights reserved.
//

import UIKit
import Kingfisher
import MWPhotoBrowserSwift
import MapleBacon



class ImageViewController: UIViewController, UICollectionViewDelegate, UIApplicationDelegate, PhotoBrowserDelegate
{

    @IBOutlet var imagCollectionView: UIView!

    var cache = KingfisherManager.sharedManager.cache
    var images = [MyImage]()
    var labels = [String]()
    var album_id: Int?
    var link: String?{
        return "https://api.vk.com/method/photos.get?owner_id=-40886007&album_id=\(Int(album_id!))"
    }
    var reachability: Reachability?
    var photos = [Photo]()
    
    
    override func viewWillAppear(animated: Bool)
    {
        cache.maxCachePeriodInSecond = 60 * 15
        self.navigationItem.hidesBackButton = true
        cache.clearMemoryCache()
        do{
            reachability = try Reachability.reachabilityForInternetConnection()
        }
        catch{
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
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func showImageBrowser(images: [MyImage])
    {
        photos.removeAll(keepCapacity: true)
        for image in images
        {
            if let url = NSURL(string: image.url)
            {
                photos.append(MWPhoto(url: url, caption: image.label))
            }
        }
        
        let browser = PhotoBrowser(delegate: self)
        //browser colors
        browser.navBarTintColor = UIColor.blackColor()
        browser.navBarBarTintColor = UIColor.whiteColor()
        browser.previousNavBarBarTintColor = UIColor.whiteColor()
        browser.toolbarBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        browser.toolbarBarTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        //browser functionality
        browser.displayActionButton = true
        browser.displayNavArrows = false
        browser.displaySelectionButtons = false
        browser.zoomPhotosToFill = true
        browser.alwaysShowControls = false
        browser.autoPlayOnAppear = false
        browser.startOnGrid = photos.count > 1
        browser.enableGrid = photos.count > 1
        browser.hideControlsOnStartup = 1 == photos.count
        
        let browserNavi = UINavigationController(rootViewController: browser)
        browserNavi.modalTransitionStyle = .CrossDissolve
        if 1 == photos.count
        {
            browserNavi.modalPresentationStyle = .FullScreen
        }
        navigationController?.presentViewController(browserNavi, animated: true, completion: nil)
    }
    
    
    
    func actionButtonPressedForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser)
    {
        let img: UIImage = photoAtIndex(index, photoBrowser: photoBrowser).underlyingImage!
        let shareItems:Array = [img]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        photoBrowser.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: PhotoBrowser) -> Int{
        return photos.count
    }
       
    func photoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo{
        return photos[index]
    }
    
    func thumbPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo{
        return photos[index]
    }
    
    
    
    func photoBrowserDidFinishModalPresentation(photoBrowser: PhotoBrowser)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController!.popViewControllerAnimated(false)
        
        let maxAgeOneDay: NSTimeInterval = 60 * 15
        DiskStorage.sharedStorage.maxAge = maxAgeOneDay
        cache.clearMemoryCache()
        cache.cleanExpiredDiskCache()
    }
    
    
    
    func extract_json_data(data:NSString)
    {
        autoreleasepool{
        let jsonData:NSData = data.dataUsingEncoding(NSUnicodeStringEncoding)!
        let json: AnyObject?
        
        do{
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        }
        catch{
            print("error")
            return
        }
        if let images_array = json!["response"] as? [[String: AnyObject]]
        {
            for img in images_array
            {
                if let name = img["src_big"] as? String
                {
                    let lbl = img["text"] as? String
                    images.append(MyImage(url: name, label: lbl!))
                    
                }
            }
        }
        else
        {
            print("error")
            return
        }
        dispatch_async(dispatch_get_main_queue(), {self.showImageBrowser(self.images)})
        
                    }
    }
    
    
    
    func refresh(){
        self.imagCollectionView.reloadInputViews()
    }
    
    
    
    func get_json()
    {
        let url:NSURL = NSURL(string: link!)!
        print(url)
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        
        autoreleasepool{
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
    
    
}
