//
//  MemoDataModel.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import RealmSwift

class MemoDataModel: Object {
    override static func primaryKey() -> String? {
        return "id"
    }
    
   @objc enum Tax: Int, RealmEnum {
        case tax8
        case tax10
        case taxFree
    }
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var memo: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var tax = Tax.taxFree
    let optionalEnumProperty = RealmProperty<Tax?>()
}
