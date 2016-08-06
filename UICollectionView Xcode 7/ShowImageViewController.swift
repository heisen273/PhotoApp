//
//  NewViewController.swift
//  10/10 AMAZING APP
//
//  Created by antoha on 7/1/15.
//  Copyright © 2016 ANTOHIN APP. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController, UIScrollViewDelegate, UIApplicationDelegate
{
    
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var exitButton: UIButton!

    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let img: UIImage = imageView.image!
        
        
        let shareItems:Array = [img]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    
    
    
    var image = UIImage()
    var scrollViewDragging: Bool = false
    var text: String?
    var currentPhotoIndex: Int = 0

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.label.text = text
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        
        self.imageView.image = self.image
        
        
        
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        let tap = UITapGestureRecognizer(target:self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = true
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView && scrollViewDragging {
            currentPhotoIndex = getCurrentPageIndex()
            //updateTitle()
        }
    }
    
    // MARK: Utility Methods
    
    private func getCurrentPageIndex() -> Int {
        return Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    }
    
    /*private func updateTitle(){
        label.text = ImageCell.text
    }*/
    
    
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func doubleTapped(){
        if scrollView.zoomScale==1{
            do {
                self.scrollView.setZoomScale(2.0, animated: true)
            }
        }
        else {
                self.scrollView.setZoomScale(1.0, animated: true)
            
            
        }
        
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

