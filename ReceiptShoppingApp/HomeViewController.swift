//
//  HomeViewController.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import Foundation
import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    let realm = try! Realm()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    
    var memoDataList: [MemoTitleModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        configureButton()
        setMemoData()

    }
    
    
    
    @IBAction func addButton(_ sender: Any) {
        let memoDetilViewController = MemoDetailViewController()
        memoDetilViewController.presentationController?.delegate = self
        present(memoDetilViewController, animated: true)
    }
    
    
    func setMemoData() {
        let result = realm.objects(MemoTitleModel.self)
        memoDataList = Array(result)
        tableView.reloadData()
    }
    
    func configureButton() {
        addButton.layer.cornerRadius = addButton.bounds.width / 2
    }
    
    

}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        // indexPath.row->UITableviewに表示されるcellの(0から始まる)通し番号が順番に渡される
        let memoDataModel: MemoTitleModel = memoDataList[indexPath.row]
        cell.textLabel?.text = memoDataModel.memoTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetMemo = memoDataList[indexPath.row]
                try! realm.write {
                    realm.delete(targetMemo)
                }
                memoDataList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoDetaileView = MemoDetailViewController()
        memoDetaileView.presentationController?.delegate = self
        let memoData = memoDataList[indexPath.row]
        memoDetaileView.configure(memo: memoData)
        self.present(memoDetaileView, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let result = realm.objects(MemoTitleModel.self)
        memoDataList = Array(result)
        tableView.reloadData()
    }
}

