//
//  WeatherModel.swift
//  WeatherApplication
//
//  Created by Shahad Nasser on 24/12/2021.
//

import Foundation
class WeatherModel {
    static func getWeather(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=24.774265&lon=46.738586&appid=0d027b3b0aaf99e6a36d20a4c4a429b8")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: completionHandler)
        task.resume()
    }
}
