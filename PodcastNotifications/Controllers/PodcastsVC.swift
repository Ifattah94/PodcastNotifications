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
       private var unNotificationCenter: UNUserNotificationCenter!
    
       private var podcasts = [Podcast]() {
           didSet {
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
    
    private var alarmTime: TimeInterval = 0.0 {
        didSet {
            triggerTimeNotification()
        }
    }
    

    
    //MARK: UI Objects
    
    lazy var tableView: UITableView = {
           let tv = UITableView(frame: view.bounds)
           tv.register(PodcastCell.self, forCellReuseIdentifier: "PodcastCell")
           tv.dataSource = self
           tv.delegate = self
        tv.backgroundColor = .green
           tv.rowHeight = 80
           return tv
       }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationCenter()
        constrainTableView()
        loadData()
        

    }
    
    
    //MARK: Private methods
    
    private func loadData() {
        self.podcasts = JSONParser.parsePodcastJSONFile()
    }
    
    
    private func setupNotificationCenter() {
        unNotificationCenter = UNUserNotificationCenter.current()
               unNotificationCenter.delegate = self
               unNotificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                   if let error = error{
                       print(error)
                       return
                   }
                   print("access granted")
        }
    }
    
   private func triggerTimeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(currentSelectedPodCast.collectionName) Reminder "
        content.body = "\(currentSelectedPodCast.collectionName) will start live feed very shortly"
        content.sound = .default
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageIdentifier = "image.png"
        let filePath = documentDirectory.appendingPathComponent(imageIdentifier)
        
    let imageData = currentImage.pngData()
        do {
            try imageData?.write(to: filePath) //writes to documents folder
            let attachment = try UNNotificationAttachment.init(identifier: imageIdentifier, url: filePath, options: nil)
            content.attachments = [attachment]
        } catch {
            print("error writing to path \(error)")
            
        }
        //configure trigger
        
        
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: alarmTime, repeats: false)
         content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "PodcastAlarm", content: content, trigger: trigger)
        
        unNotificationCenter.add(request) { (error) in
            if let error = error {
                print("request notification error \(error)")
            }
        }
    }
    
    
    
    private func showAlertSheet() {
        let alertController = UIAlertController(title: "Reminder", message: "Live feed of Podcast Starting Soon", preferredStyle: .actionSheet)
        let twentySecondsAction = UIAlertAction(title: "20 Seconds", style: .default, handler: {action in self.alarmTime = 20})
        let oneMinuteAction = UIAlertAction(title: "1 minute", style: .default, handler: {action in self.alarmTime = 60})
        let oneHourAction = UIAlertAction(title: "1 hour", style: .default, handler: {action in self.alarmTime = 3600})
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(twentySecondsAction)
        alertController.addAction(oneMinuteAction)
        alertController.addAction(oneHourAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func constrainTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }

    

}
extension PodcastsVC: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        cell.selectionStyle = .none
        let podcast = podcasts[indexPath.row]
        cell.hostLabel.text = podcast.artistName
        cell.podcastTitleLabel.text = podcast.collectionName
        
        if let image = ImageHelper.shared.image(forKey: podcast.artworkUrl600 as NSString) {
            cell.podcastImage.image = image
        } else {
            ImageHelper.shared.getImage(urlStr: podcast.artworkUrl600) { (result) in
                DispatchQueue.main.async {
                    switch result {
                        
                    case .success(let image):
                        cell.podcastImage.image = image
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        
       
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedPodCast = podcasts[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! PodcastCell
               currentImage = cell.podcastImage.image
          showAlertSheet()
    }
    
    
    
}

extension PodcastsVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
