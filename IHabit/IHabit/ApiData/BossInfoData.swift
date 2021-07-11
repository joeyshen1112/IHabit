//
//  BossInfoData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/7/1.
//

import Foundation

struct BossInfoData: Codable {
    var monsterId: Int?
    var monsterName: String?
    var level: Int?
    var icon: String?
    var hp: Int?
    var lightAttack: Int?
    var normalAttack: Int?
    var criticalStrike: Int?
}
