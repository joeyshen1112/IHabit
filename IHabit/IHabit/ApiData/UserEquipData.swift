//
//  UserEquipData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/29.
//

import Foundation

struct UserEquipData: Codable {
    var money: Int?
    var userProps: [UserProps]
    // 道具內容
    struct UserProps: Codable {
        var propId: Int?
        var propName: String?
        var type: Int?
        var icon: String?
        var buildPrice: Int?
        var upLevelPrice: Int?
        var multipleType: Int?
        var level: Int?
        var propData: Int?
    }
}
