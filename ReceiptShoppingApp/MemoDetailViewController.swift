//
//  MemoDetailViewController.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import UIKit
import RealmSwift


class MemoDetailViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var inputTitleTextField: UITextField!
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var footerView: TableFooterView!
    
    let realm = try! Realm()

    var array: [MemoDataModel] = []
    
    var record = MemoDataModel()
    
    var titleRecord = MemoTitleModel()
        
    enum Cell: Int, CaseIterable {
        case TableViewCell
        case AddButtonTableViewCell
        
        var cellIdentifier: String {
            switch self {
            case.TableViewCell: return "cell"
            case.AddButtonTableViewCell: return "ButtonCell"
            }
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        // アラートを表示させる
        let alert = UIAlertController(title: "メモの保存", message: "メモの変更が保存されていませんが、よろしいですか？", preferredStyle: .alert)
        // メモの変更なしでホーム画面に戻る
        let close = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        // メモ詳細画面に戻る
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(close)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        saveRecord(with: titleRecord)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTableView.dataSource = self
        memoTableView.delegate = self
        memoTableView.register(UINib(nibName: "TableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        memoTableView.register(UINib(nibName: "AddButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
        memoTableView.register(UINib(nibName: "TableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableFooterView")
        inputTitleTextField.placeholder = "タイトル"
        displayData()
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                tapGR.cancelsTouchesInView = false
                self.view.addGestureRecognizer(tapGR)

    }
    
    
    
    func configure(memo: MemoTitleModel) {
        titleRecord = memo
        array = Array(memo.memoDataList)
        print("このデータは\(memo.memoTitle)です！")
    }
    
    func displayData() {
        inputTitleTextField.text = titleRecord.memoTitle
        memoTableView.delegate = titleRecord.memoDataList as? any UITableViewDelegate
    }

    private func totalPrice() -> Int {
        var total = 0
        
        // filter -> {}内の条件で絞る
        // forEach -> 配列の中身を全部ループさせる
        array.filter{ $0.isChecked }.forEach{ info in
            let price = Double(info.price) ?? 0.0
            let taxInPrice: Double
                  switch info.tax {
                  case .tax8:
                    // 8%計算
                      taxInPrice = price * 1.08
                    break
                  case .tax10:
                    // 10%計算
                      taxInPrice = price * 1.1
                    break
                  case .taxFree:
                    // そのまま
                      taxInPrice = price
                    break
                  }
            total += Int(taxInPrice)
        }
        return total
    }
    
    @objc func dismissKeyboard() {
            self.view.endEditing(true)
        }
    

}


extension MemoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // arrayに格納されているShoppingInfoの数だけセルが生成される
        // 追加ボタンセルを作りたいので +1　する
        return array.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType: Cell
        if indexPath.row == array.count {
            // 最後のセルを追加ボタンセルにする
            // 全部でarray.count+1個あるので、最後のセルのインデックスはarray.countになる
            cellType = .AddButtonTableViewCell
        } else {
            cellType = .TableViewCell
        }
        switch cellType {
        case.TableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellIdentifier) as! TableViewCell
            cell.delegate = self
            // セルの行番号に該当する情報を取得
            let info = array[indexPath.row]
            
            // 税率ボタンの選択状態の初期化
            cell.tax8Button.isSelected = false
            cell.tax10Button.isSelected = false
            cell.checkButton.isChecked = false
            
            // 取得した情報をセルにセット
            cell.memoText.text = info.memo
            cell.priceText.text = info.price
            cell.checkButton.isChecked = info.isChecked
            
           
            // 情報に合わせて選択状態をセット
            if info.tax == .tax8 {
                cell.tax8Button.isSelected = true
            } else if info.tax == .tax10 {
                cell.tax10Button.isSelected = true
            }
            return cell
        case .AddButtonTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellIdentifier) as! AddButtonTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .systemBlue
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetMemo = array[indexPath.row]
                try! realm.write {
                    realm.delete(targetMemo)
                }
                array.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func saveRecord(with: MemoTitleModel) {
        let realm = try! Realm()
        try! realm.write {
            if let existingMemoTitle = realm.objects(MemoTitleModel.self).first(where: { $0.id == titleRecord.id}) {
                // すでにデータがある場合の条件分岐
                // 一度memoDataListを中身を削除
                existingMemoTitle.memoDataList.removeAll()
                // タイトルテキスト設定
                existingMemoTitle.memoTitle = inputTitleTextField.text!
                // memoDataList再設定
                existingMemoTitle.memoDataList.append(objectsIn: array)
            } else {
                // データ新規作成
                titleRecord.memoTitle = inputTitleTextField.text!
                titleRecord.memoDataList.append(objectsIn: array)
                realm.add(titleRecord)
            }
        }
        dismiss(animated: true)
    }
    
    
}

extension MemoDetailViewController: TableViewDelegate {
    func buttonTapAction() {
        // 追加ボタンを押した時の処理
//        let cell: TableViewCell = TableViewCell.initForomNid()
//        array.append(cell)
        
        // 空の買い物情報を追加する
        let newInfo = MemoDataModel()
        array.append(newInfo)
        
        memoTableView.reloadData()
    }
}

extension MemoDetailViewController: TableViewCellDelegate {
    func didChengeTax() {
        footerView.totalTextLabel.text = String(totalPrice())

    }
    
    func checkBoxSelectedForCell(cell: TableViewCell) {
        let indexPath = memoTableView.indexPath(for: cell)
        memoTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath!)
        let row = indexPath?.row
        array[row!].isChecked = cell.checkButton.isChecked
        
        footerView.totalTextLabel.text = String(totalPrice())
    }
    
    // cellに入力された内容をarrayに保存する
    func textFieldShouldEndEditingInCell(cell: TableViewCell) {
        // 何行目のcellなのか（indexPath.row）を取得する
        let indexPath = memoTableView.indexPath(for: cell)
        memoTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath!)
        let row = indexPath?.row
        // arrayの該当番号のMemoDataModelにcell.memoTextの値とcell.priceTextの値を格納
        array[row!].memo = cell.memoText.text!
        array[row!].price = cell.priceText.text!
    }
}

extension MemoDetailViewController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
            guard let presentationController = presentationController else {
                return
            }
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        }
}

