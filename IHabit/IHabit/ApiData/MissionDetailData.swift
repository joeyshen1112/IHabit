//
//  MissionDetailData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/23.
//

import Foundation

struct MissionDetailData: Codable {
    var habitId: Int?
    var habitName: String?
    var startDate: String?
    var period: String?
    var message: String?
    var isHide: Bool?
    var isInform: Bool?
    var informTime: String?
    var icon: String?
    var isClose: Bool?
    var isSocailized: Bool?
    var tags: [Tags]
    var continueDays: Int?
    var completeDaysOfMonth: Int?

    struct Tags: Codable {
        var tagId: Int?
        var tagName: String?
    }
}
