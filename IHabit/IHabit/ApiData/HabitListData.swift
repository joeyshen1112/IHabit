//
//  HabitListData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/23.
//

import Foundation

struct HabitListData: Codable {
    var habitId: Int?
    var habitName: String?
    var icon: String?
    var tags: [Tags]
    var isInform: Bool?
    var informTime: String?
    var period: String?
    var isDone: Bool?
    var isClose: Bool?

    struct Tags: Codable {
        var tagId: Int?
        var tagName: String?
    }
}
