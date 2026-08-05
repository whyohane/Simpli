//
//  Item.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 05/08/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
