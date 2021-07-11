//
//  TalentList.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/28.
//

import Foundation

struct TalentListData: Codable {
    var talentPoint: Int?
    var nodes: [Nodes]

    struct Nodes: Codable {
        var nodeId: Int?
        var hasNode: Bool?
        var lastNode: Int?
    }
}
