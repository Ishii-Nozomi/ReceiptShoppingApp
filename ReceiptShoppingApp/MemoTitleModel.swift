//
//  MemoTitleModel.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import RealmSwift

class MemoTitleModel: Object {
    @objc dynamic var memoTitle: String = ""
    
    var memoDataList = List<MemoDataModel>() // ここにMemoDataModelの配列を持たせる

}
