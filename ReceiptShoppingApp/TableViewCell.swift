//
//  TableViewCell.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import UIKit

protocol TableViewCellDelegate {
    func textFieldShouldEndEditingInCell(cell: TableViewCell)
    
    func checkBoxSelectedForCell(cell: TableViewCell)
    
    func didChengeTax()
}

class TableViewCell: UITableViewCell {
    // 10%の税率計算ボタン
    @IBOutlet weak var tax10Button: UIButton!
    // 8%の税率計算ボタン
    @IBOutlet weak var tax8Button: UIButton!
    // 単位（円）の表示
    @IBOutlet weak var yenLable: UILabel!
    // メモ内容のテキスト
    @IBOutlet weak var memoText: UITextField!
    // 値段入力テキスト
    @IBOutlet weak var priceText: UITextField!
    // チェックボックス
    @IBOutlet weak var checkButton: Checkbox!
    
    var delegate: TableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memoText.delegate = self
        priceText.delegate = self
        checkButton.delegate = self
        delegate?.textFieldShouldEndEditingInCell(cell: self)
       }
    
    
    
    class func initForomNid() -> TableViewCell {
        // xibファイルのオブジェクトをインスタンス化
        let className: String = String(describing: TableViewCell.self)
        return Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as! TableViewCell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        memoText.placeholder = "買うもの"
        priceText.placeholder = "0"
        priceText.keyboardType = .numberPad

        
    }
    
    
    
    @IBAction func tax8Button(_ sender: Any) {
        // テキストから金額を取得（ボタンの切り替え前に取得しておく）
        guard let price = Double(priceText.text!) else {
            return
        }
        // 金額を一度税抜きにもどす
        let withoutTaxPrice = removeTax(price: price)

        // ON, OFFを切り替える
        tax8Button.isSelected = !tax8Button.isSelected
        // 10%ボタンをOFFにする
        tax10Button.isSelected = false
        
        // 税込金額を計算する（ボタンを切り替えた後に再計算）
        let taxInPrice = addTax(price: withoutTaxPrice)
        // テキストフィールドにセット
        priceText.text = String(Int(taxInPrice))
        // MemoViewControllerに金額を再計算
        delegate?.didChengeTax()
        delegate?.textFieldShouldEndEditingInCell(cell: self)
        delegate?.checkBoxSelectedForCell(cell: self)
    }
    
    @IBAction func tax10Button(_ sender: Any) {
        // テキストから金額を取得（ボタンの切り替え前に取得しておく）
        guard let price = Double(priceText.text!) else {
            return
        }
        // 金額を一度税抜きにもどす
        let withoutTaxPrice = removeTax(price: price)

        // ON, OFFを切り替える
        tax10Button.isSelected = !tax10Button.isSelected
        // 8%ボタンをOFFにする
        tax8Button.isSelected = false
        
        // 税込金額を計算する（ボタンを切り替えた後に再計算）
        let taxInPrice = addTax(price: withoutTaxPrice)
        // テキストフィールドにセット
        priceText.text = String(Int(taxInPrice))
        // MemoViewControllerに金額を再計算
        delegate?.didChengeTax()
        delegate?.textFieldShouldEndEditingInCell(cell: self)
        delegate?.checkBoxSelectedForCell(cell: self)
    }
    
    /// 税抜き金額を取得
    private func removeTax(price: Double) -> Double {
        // 税率の計算
        var tax: Double = 1.0
        if tax8Button.isSelected {
            // 8%ボタンがONの場合
            tax = 1.08
        } else if tax10Button.isSelected {
            // 10%ボタンがONの場合
            tax = 1.1
        }
        // 税抜き金額を返す（round: 四捨五入）
        return round(price / tax)
    }
    
    /// 税込金額を取得
    private func addTax(price: Double) -> Double {
        // 税率の計算
        var tax: Double = 1.0
        if tax8Button.isSelected {
            // 8%ボタンがONの場合
            tax = 1.08
        } else if tax10Button.isSelected {
            // 10%ボタンがONの場合
            tax = 1.1
        }
        // 税込金額を返す（round: 四捨五入）
        return round(price * tax)
    }
    
}

extension TableViewCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("キーボードを閉じるによばれる")
        
        delegate?.textFieldShouldEndEditingInCell(cell: self)
        
        return true
    }
}

extension TableViewCell: CheckBoxDelegate {
    func checkBoxSelected(isSelected: Bool) {
        delegate?.checkBoxSelectedForCell(cell: self)
    }
    
    
}

