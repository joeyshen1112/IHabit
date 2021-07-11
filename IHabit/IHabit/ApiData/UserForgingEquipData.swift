//
//  UserForgingEquipData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/29.
//

import Foundation

struct UserForgingEquipData: Codable {
    var message: String?
    var data: ResultData

    struct ResultData: Codable {
        var propData: Int?
        var buildData: Int?
        var money: Int?
    }
}
