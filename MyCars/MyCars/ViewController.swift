//
//  ViewController.swift
//  MyCars
//
//  Created by Ivan Akulov on 08/02/20.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
    }
    
    private func getDataFromFile(){
        
        guard let pathToFie = Bundle.main.path(forResource: "data", ofType: "plist"), let dataArray = NSArray(contentsOfFile: pathToFie) else {return}
        
        
        for dic in dataArray{
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Car", in: context) else {return}
            
            let car = NSManagedObject(entity: entity, insertInto: context) as! Car
            let carDic = dic as! [String: AnyObject]
            
            car.mark = carDic["mark"] as? String
            car.model = carDic["model"] as? String
            car.lastStarted = carDic["lastStarted"] as? Date
            car.myChoice = carDic["myChoice"] as! Bool
            car.rating = carDic["rating"] as! Double
            car.timesDriver = carDic["timesDriver"] as! Int16
            
            let imageName = carDic["imageName"] as! String
            let image = UIImage(named: imageName)
            let imageData = image?.pngData()
            car.imageData = imageData
            
            if let colorDic = carDic["tintColor"] as? [String: Float] {
                car.tintColor = getColor(colorDic: colorDic)
            }
            
        }
    }
    
    
    private func getColor(colorDic: [String: Float]) -> UIColor {
        guard let red = colorDic["red"],
            let green = colorDic["green"],
            let blue = colorDic["blue"] else {return UIColor()}
        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
}

