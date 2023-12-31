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
        footerView.totalTextLabel.text = String(totalPrice())

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
            let price = Int(info.price) ?? 0
            total += Int(price)
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
            array.remove(at: indexPath.row)
            footerView.totalTextLabel.text = String(totalPrice())
            tableView.reloadData()
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
        if let row = indexPath?.row {
            // 一時的なMemoDataModelを作成し、データを変更(直接編集するとクラッシュするため)
            let tempMemoData = array[row].copyModel()
            tempMemoData.isChecked = cell.checkButton.isChecked
            // 一時的なデータでarrayを更新
            array[row] = tempMemoData
        }
        
        footerView.totalTextLabel.text = String(totalPrice())
    }
    
    // cellに入力された内容をarrayに保存する
    func textFieldShouldEndEditingInCell(cell: TableViewCell) {
        // 何行目のcellなのか（indexPath.row）を取得する
        let indexPath = memoTableView.indexPath(for: cell)
        memoTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath!)
        let row = indexPath?.row
        // arrayの該当番号のMemoDataModelにcell.memoTextの値とcell.priceTextの値を格納
        // 一時的なMemoDataModelを作成し、データを変更(直接編集するとクラッシュするため)
        let tempMemoData = MemoDataModel()
        tempMemoData.memo = cell.memoText.text!
        tempMemoData.price = cell.priceText.text!
        
        // TODO: taxFreeの時はどうすれば良いでしょうか？ ロジックを考えてみましょう。
                if cell.tax8Button.isSelected {
                    tempMemoData.tax = .tax8
                } else if cell.tax10Button.isSelected {
                    tempMemoData.tax = .tax10
                } else {
                    tempMemoData.tax = .taxFree
                }
        
        // 一時的なデータでarrayを更新
        array[row!] = tempMemoData
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

