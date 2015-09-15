//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Mukesh Jain on 9/10/15.
//  Copyright (c) 2015 walmart. All rights reserved.
//

import UIKit
private let CELL_NAME = "com.walmart.rottentomatoes.moviecell"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var movies:NSArray?
    var refreshControl: UIRefreshControl!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("the row \(indexPath.row)")
        
        let movieDictionary = movies![indexPath.row] as! NSDictionary
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_NAME) as! MovieCell
        cell.movieTitleLabel.text = movieDictionary["title"] as? String
        cell.movieDescriptionLable.text = movieDictionary["synopsis"] as? String
        
        //let url = NSURL(string: movieDictionary.valueForKeyPath("posters.thumbnail") as! String)!
        
        var url = movieDictionary.valueForKeyPath("posters.thumbnail") as! String
        
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        let url1 = NSURL(string: url)!
        
        
        cell.moviePosterView.setImageWithURL(url1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //NSLog("TableView? \(movieTableView.frame)")
        self.errorView.hidden = true
        self.errorLabel.text = " "
        loadMovies()

    }
    
    
    func loadMovies()
    {        
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.center = view.center
        view.addSubview(indicator)

        dispatch_async(dispatch_get_main_queue()) {
            // Make UI changes
            indicator.startAnimating()

        }

        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=f2fk8pundhpxf77fscxvkupy"
        let request = NSMutableURLRequest(URL: NSURL(string:RottenTomatoesURLString)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    // Make UI changes
                    indicator.stopAnimating()
                    
                }

                if let error = error{
                    print("my error message:\(error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        // Make UI changes
                        self.errorView.hidden = false
                        self.errorLabel.text = "Network Error"
                    }
                    
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        // Make UI changes
                        self.errorView.hidden = true
                        self.errorLabel.text = " "
                    }
                    
                    if let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        dispatch_async(dispatch_get_main_queue()){
                            self.movies = dictionary["movies"] as? NSArray
                            self.movieTableView.reloadData()
                            
                        }
                        //NSLog("Dictionary: \(dictionary)")
                        
                    } else {
                    }
                }
        }
        task.resume()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie as! NSDictionary

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        movieTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        
        loadMovies()
    
        delay(5, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    

    
}

class MovieCell:UITableViewCell{
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLable: UILabel!
    @IBOutlet weak var moviePosterView: UIImageView!
}
