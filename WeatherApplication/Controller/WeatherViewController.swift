//
//  ViewController.swift
//  WeatherApplication
//
//  Created by Shahad Nasser on 23/12/2021.
//

import UIKit

class WeatherViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentDescriptionLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    
    
    var current: Current?
    var hourlyList: [Current]?
    var dailyList: [Daily]?

    private var pendingWorkItem: DispatchWorkItem?
    let queue = DispatchQueue(label: "GetWeather")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showUIElements(false)
        customizeCollectionViews()
        hourlyCollectionView.dataSource = self
        dailyCollectionView.dataSource = self
        fetch()
    }
    
    func fetch(){
        pendingWorkItem?.cancel()
        let newWorkItem = DispatchWorkItem {
             self.getTasks()
        }
        pendingWorkItem = newWorkItem
        queue.sync(execute: newWorkItem)
    }
    
    func getTasks(){
        WeatherModel.getWeather(completionHandler: {data,response,error in
            guard let weatherData = data else { return }
            do{
                let decoder = JSONDecoder()
                let jsonResult = try decoder.decode(WeatherResponse.self, from: weatherData)

                self.current = jsonResult.current
                self.hourlyList = jsonResult.hourly
                self.dailyList = jsonResult.daily
//                self.items = jsonResult
//                print(jsonResult)
                DispatchQueue.main.async {
                    self.currentDateLabel.text = self.date(timestamp: self.current?.dt, format: "d MMM yyyy  h:mm a")
                    self.currentDescriptionLabel.text =  self.current?.weather[0].weatherDescription.rawValue
                    self.currentWeatherLabel.text = self.convertTempreture(temp: self.current?.temp ?? 0, from: .kelvin, to: .celsius)
                    
                    
                    self.windLabel.text = "\(self.current?.windSpeed ?? 0)"
                    self.humidityLabel.text = "\(self.current?.humidity ?? 0)"
                    self.pressureLabel.text = "\(self.current?.pressure ?? 0)"
                    self.feelsLikeLabel.text = self.convertTempreture(temp: self.current?.feelsLike ?? 0, from: .kelvin, to: .celsius)
                    
                    self.showUIElements(true)
                    self.hourlyCollectionView.reloadData()
                    self.dailyCollectionView.reloadData()
//                    self.tableView.reloadData()
                }
            }catch{
                print(error)
            }
        })
    }
    
    func date(timestamp: Int?, format: String)-> String{
        let date = Date(timeIntervalSince1970: Double(timestamp ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    func convertTempreture(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature)-> String{
        let mf = MeasurementFormatter()
        mf.numberFormatter.maximumFractionDigits = 0
            mf.unitOptions = .providedUnit
            let input = Measurement(value: temp, unit: inputTempType)
            let output = input.converted(to: outputTempType)
            return mf.string(from: output)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hourlyCollectionView {
            return hourlyList?.count ?? 0
        }else{
            return dailyList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == hourlyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath as IndexPath) as! HourlyCollectionViewCell
            cell.tempLabel.text = convertTempreture(temp: hourlyList?[indexPath.row].temp ?? 0, from: .kelvin, to: .celsius)
            cell.timeLabel.text = date(timestamp: hourlyList?[indexPath.row].dt, format: "h a")
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath as IndexPath) as! DailyCollectionViewCell
            cell.dayLabel.text = date(timestamp: dailyList?[indexPath.row].dt, format: "EEEE")
            cell.descriptionLabel.text = dailyList?[indexPath.row].weather[0].weatherDescription.rawValue
            cell.minimumLabel.text = convertTempreture(temp: dailyList?[indexPath.row].temp.min ?? 0, from: .kelvin, to: .celsius)
            cell.maximumLabel.text = convertTempreture(temp: dailyList?[indexPath.row].temp.max ?? 0, from: .kelvin, to: .celsius)
            return cell
        }
    }
    
    
    func customizeCollectionViews(){
        let hourlyLayout = UICollectionViewFlowLayout()
        hourlyLayout.scrollDirection = .horizontal
        hourlyLayout.minimumInteritemSpacing = 8
        hourlyLayout.itemSize = CGSize(width: 90, height: 90)
        hourlyCollectionView.collectionViewLayout = hourlyLayout
        
        let dailyLayout = UICollectionViewFlowLayout()
        dailyLayout.scrollDirection = .horizontal
        dailyLayout.minimumInteritemSpacing = 8
        dailyLayout.itemSize = CGSize(width: 200, height: 200)
        dailyCollectionView.collectionViewLayout = dailyLayout

    }
    
    func showUIElements(_ flag: Bool){
        cityLabel.isHidden = !flag
        currentDateLabel.isHidden = !flag
        currentDescriptionLabel.isHidden = !flag
        currentWeatherLabel.isHidden = !flag
        windLabel.isHidden = !flag
        humidityLabel.isHidden = !flag
        pressureLabel.isHidden = !flag
        feelsLikeLabel.isHidden = !flag
    }
    
    func isDark(_ flag: Bool){
        
    }

}


