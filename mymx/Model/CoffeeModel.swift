//
//  CoffeeModel.swift
//  mymx
//
//  Created by ice on 2024/7/6.
//

import Foundation
import UIKit

struct CoffeeModel: Codable, Equatable, Identifiable {
    var id: Int = 0
    var name: String = ""
    var type: String = CoffeeType.espresso.rawValue
    var roastLevel: String = RoastLevel.medium.rawValue
    var origin: String = ""
    var price: Double = 0.0
    var createTime: Int?
    var imageUrl: String = ""
    var description: String = ""
    
    var typeModel: CoffeeTypeModel {
        get {
            CoffeeTypeModel.getModel(type)
        }
        set {
            type = newValue.id.rawValue
        }
    }
    
    var roastLevelModel: RoastLevelModel {
        get {
            RoastLevelModel.getModel(roastLevel)
        }
        set {
            roastLevel = newValue.id.rawValue
        }
    }
}

struct CoffeeTypeModel: Codable, Identifiable {
    let id: CoffeeType
    let en: String
    let cn: String
    let systemName: String
    
    static let typeDict: [CoffeeType: CoffeeTypeModel] = [
        .espresso: CoffeeTypeModel(id: .espresso, en: "Espresso ☕", cn: "浓缩咖啡 ☕", systemName: "cup.and.saucer"),
        .latte: CoffeeTypeModel(id: .latte, en: "Latte 🥛", cn: "拿铁 🥛", systemName: "mug"),
        .cappuccino: CoffeeTypeModel(id: .cappuccino, en: "Cappuccino ☁️", cn: "卡布奇诺 ☁️", systemName: "cloud"),
        .americano: CoffeeTypeModel(id: .americano, en: "Americano 🇺🇸", cn: "美式咖啡 🇺🇸", systemName: "flag"),
        .mocha: CoffeeTypeModel(id: .mocha, en: "Mocha 🍫", cn: "摩卡 🍫", systemName: "cup.and.saucer.fill"),
        .other: CoffeeTypeModel(id: .other, en: "Other", cn: "其他", systemName: "ellipsis.circle"),
    ]
    
    static func getModel(_ type: CoffeeType) -> CoffeeTypeModel {
        CoffeeTypeModel.typeDict[type] ?? CoffeeTypeModel(id: type, en: type.rawValue, cn: type.rawValue, systemName: "cup.and.saucer")
    }
    
    static func getModel(_ type: String) -> CoffeeTypeModel {
        let typeEnum = CoffeeType(rawValue: type)!
        return CoffeeTypeModel.typeDict[typeEnum] ?? CoffeeTypeModel(id: typeEnum, en: type, cn: type, systemName: "cup.and.saucer")
    }
}

enum CoffeeType: String, CaseIterable, Codable, Identifiable {
    case espresso
    case latte
    case cappuccino
    case americano
    case mocha
    case other
    var id: String { self.rawValue }
}

struct RoastLevelModel: Codable, Identifiable {
    let id: RoastLevel
    let en: String
    let cn: String
    
    static func getModel(_ roastLevel: RoastLevel) -> RoastLevelModel {
        switch roastLevel {
        case .light:
            return RoastLevelModel(id: roastLevel, en: "Light Roast", cn: "浅度烘焙")
        case .medium:
            return RoastLevelModel(id: roastLevel, en: "Medium Roast", cn: "中度烘焙")
        case .dark:
            return RoastLevelModel(id: roastLevel, en: "Dark Roast", cn: "深度烘焙")
        }
    }
}

enum RoastLevel: String, CaseIterable, Codable, Identifiable {
    case light
    case medium
    case dark
    var id: String { self.rawValue }
}