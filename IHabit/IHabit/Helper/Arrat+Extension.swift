//
//  Arrat+Extension.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/19.
//

import Foundation
// 自製新增Array remove的func，讓他可以一次刪除陣列中多個index的位置
extension Array {
    mutating func remove(at indexes: [Int]) {
        var lastIndex: Int?
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}
