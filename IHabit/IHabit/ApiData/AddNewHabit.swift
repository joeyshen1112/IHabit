//
//  AddNewHabit.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/23.
//

import Foundation

struct AddNewHabit: Codable {
    var userId: Int?
    var habitName: String?
    var startDate: String?
    var period: String?
    var message: String?
    var isHide: Bool?
    var isInform: Bool?
    var informTime: String?
    var icon: String?
    var isSocailized: Bool?
    var isClose: Bool?
    var tags: [Int]
}
