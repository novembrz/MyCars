//
//  ViewController.swift
//  MyCars
//
//  Created by Дарья on 10.09.2020.
//  Copyright © 2020 novembrz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var markLabel: UILabel! 
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet{
            updateSegmentedControl()
        }
    }
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var startEngineButton: UIButton!
    @IBOutlet weak var rateItButton: UIButton!
    @IBOutlet weak var futureTripsButton: UIButton!
    
    lazy var dateFormatted: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .short
        
        return df
    }()
    
    var context: NSManagedObjectContext!
    var car: Car!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createInterface()
        getDataFromFile()
        
    }
    
    private func createInterface(){
        
        greenView.layer.cornerRadius = 40
        
        startEngineButton.layer.cornerRadius = 20
        rateItButton.layer.cornerRadius = 20
        futureTripsButton.layer.borderWidth = 1.2
        futureTripsButton.layer.borderColor = UIColor.white.cgColor
        futureTripsButton.layer.cornerRadius = 13
    }
    
    
    //MARK: Work with buttons
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        car.timesDriver += 1
        car.lastStarted = Date()
        
        do{
            try context.save()
            insertData(with: car)
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Rate it", message: "Rate this car please", preferredStyle: .alert)
        let rateAction = UIAlertAction(title: "Rate", style: .default) { action in
            if let text = alertController.textFields?.first?.text {
                self.update(rating: (text as NSString).doubleValue)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(rateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func update(rating: Double) {
        car.rating = rating
        
        do {
            try context.save()
            insertData(with: car)
        } catch let error as NSError {
            let alertController = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: Segmented Pressed
    
    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        updateSegmentedControl()
    }
    
    private func updateSegmentedControl(){
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            car = results.first
            insertData(with: car!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}

//MARK: Work with data and model

extension ViewController{
    
    private func getDataFromFile(){
           
           let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "mark != nil")
           
           var records = 0
           
           do {
               records = try context.count(for: fetchRequest)
               print("Is Data there already?")
           } catch let error as NSError {
               print(error.localizedDescription)
           }
           
           guard records == 0 else { return }
           
           guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
           let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
           
           for dictionary in dataArray {
               let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
               let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
               
               let carDictionary = dictionary as! [String : AnyObject]
               car.mark = carDictionary["mark"] as? String
               car.model = carDictionary["model"] as? String
               car.rating = carDictionary["rating"] as! Double
               car.lastStarted = carDictionary["lastStarted"] as? Date
               car.timesDriver = carDictionary["timesDriven"] as! Int16
               car.myChoice = carDictionary["myChoice"] as! Bool
               
               let imageName = carDictionary["imageName"] as? String
               let image = UIImage(named: imageName!)
               let imageData = image!.pngData()
               car.imageData = imageData
               
               if let colorDictionary = carDictionary["tintColor"] as? [String : Float] {
                   car.tintColor = getColor(colorDictionary: colorDictionary)
               }
           }
       }
       
       private func getColor(colorDictionary: [String : Float]) -> UIColor {
           guard let red = colorDictionary["red"],
               let green = colorDictionary["green"],
               let blue = colorDictionary["blue"] else { return UIColor() }
           return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1.0)
       }
       
       
       private func insertData(with car: Car) {
           
           carImageView.image = UIImage(data: car.imageData!)
           markLabel.text = car.mark
           modelLabel.text = car.model
           myChoiceImageView.isHidden = !(car.myChoice)
           ratingLabel.text = "Rating: \(car.rating) / 10"
           numberOfTripsLabel.text = "Number of trips: \(car.timesDriver)"
           segmentedControl.tintColor = car.tintColor as? UIColor
           lastTimeLabel.text = "Last time strted: \(dateFormatted.string(from: car.lastStarted!))"
       }
    
}
