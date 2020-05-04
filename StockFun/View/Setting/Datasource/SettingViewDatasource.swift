//
//  SettingViewDatasource.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import UIKit

class CellStock: UITableViewCell {
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbName: UILabel!
    var model:StockItemCellModel! {
        didSet {
            self.updateCell(self.model)
        }
    }
    
    override func awakeFromNib() {
        
    }
    
    private func updateCell(_ item: StockItemCellModel) {
        lbName.text = item.name
        lbStatus.text = item.status.rawValue
    }
}

class SettingViewDatasource:  NSObject {
    var listItems: [StockItemCellModel] = []
    var tableView: UITableView!
    var onDeleteItem:((String)->())?
    init(_ tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    func updateData(_ items: [StockItemCellModel]) {
        self.listItems = items
        self.tableView.reloadData()
    }
}

extension SettingViewDatasource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.listItems[indexPath.row]
            self.onDeleteItem?(item.id)
        }
    }
}

extension SettingViewDatasource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellStockSetting", for: indexPath) as? CellStock else {
            return UITableViewCell()
        }
        cell.model = self.listItems[indexPath.row]
        return cell
    }
}
