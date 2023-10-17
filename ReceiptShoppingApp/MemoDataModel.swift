//
//  MemoDataModel.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import RealmSwift

class MemoDataModel: Object {
    
   @objc enum Tax: Int, RealmEnum {
        case tax8
        case tax10
        case taxFree
    }
    
    @objc dynamic var memo: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var tax = Tax.taxFree
    
}

// コピーするメソッドを追加
extension MemoDataModel {
    func copyModel() -> MemoDataModel {
            let copiedModel = MemoDataModel()
            copiedModel.memo = self.memo
            copiedModel.price = self.price
            copiedModel.isChecked = self.isChecked
            copiedModel.tax = self.tax
            return copiedModel
        }
}
