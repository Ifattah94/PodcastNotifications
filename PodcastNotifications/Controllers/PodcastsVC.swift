//
//  PodcastsVC.swift
//  PodcastNotifications
//
//  Created by C4Q on 10/30/19.
//  Copyright © 2019 Iram Fattah. All rights reserved.
//

import UIKit

class PodcastsVC: UIViewController {
    
    //MARK: Properties
    
 
       private var currentSelectedPodCast: Podcast!
       private var currentImage: UIImage!
    
       private var podcasts = [Podcast]() {
           didSet {
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
    

    
    //MARK: UI Objects
    
    lazy var tableView: UITableView = {
           let tv = UITableView(frame: view.bounds)
           tv.register(PodcastCell.self, forCellReuseIdentifier: "PodcastCell")
           tv.dataSource = self
           tv.delegate = self
           tv.rowHeight = 80
           return tv
       }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    //MARK: Private methods
    
    

    

}
extension PodcastsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        cell.selectionStyle = .none
        let podcast = podcasts[indexPath.row]
        //TODO: configure cell
        return cell
    }
    
    
}
