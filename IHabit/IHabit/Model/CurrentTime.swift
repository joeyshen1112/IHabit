//
//  CurrentTime.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import Foundation

struct CurrentTime {
    // 取得現在時間
    let calendar = Calendar(identifier: .iso8601)
    var setTime = Set<Calendar.Component>()
    var currentTime: String = ""

    init() {
        setTime.insert(Calendar.Component.year)
        setTime.insert(Calendar.Component.month)
        setTime.insert(Calendar.Component.day)
        let time = calendar.dateComponents(setTime, from: Date())
        if let year = time.year, let month = time.month, let day = time.day {
            var monthString = "\(month)"
            if month < 10 {
                monthString = "0\(month)"
            }
            var dayString = "\(day)"
            if day < 10 {
                dayString = "0\(day)"
            }
            currentTime = "\(year)-\(monthString)-\(dayString)"
        }
    }
    func getCurrentTime() -> String {
        return currentTime
    }
}
