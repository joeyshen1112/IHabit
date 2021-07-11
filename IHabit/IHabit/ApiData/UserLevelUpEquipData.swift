//
//  UserLevelUpEquipData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/30.
//

import Foundation

struct UserLevelUpEquipData: Codable {
    var message: String?
    var data: ResultData?

    struct ResultData: Codable {
        var propId: Int?
        var propName: String?
        var type: Int?
        var icon: String?
        var buildPrice: Int?
        var upLevelPrice: Int?
        var multipleType: Int?
        var level: Int?
        var propData: Int?
        var money: Int?
    }
}
