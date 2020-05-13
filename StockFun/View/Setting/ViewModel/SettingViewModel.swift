//
//  SettingViewModel.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import Foundation

public enum StatusTrainStock: String {
    case notYet
    case done
}

public struct StockItemCellModel {
    var id: String
    var name: String
    var status: StatusTrainStock

    init(id: String,name: String,status: StatusTrainStock) {
        self.id = id
        self.name = name
        self.status = status
    }
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.status = .notYet
    }
}

class SettingViewModel: NSObject {
    private var listItems: [StockItemCellModel] = [] {
        didSet {
            //TODO:- reload Data
            self.onReloadData?(self.listItems)
        }
    }
    
    var onReloadData:((_ items: [StockItemCellModel])->())?
    var onClearTfName:(()->())?
    
    override init() {
        super.init()
        
    }
    
    func loadData() {
        //TODO:- load from DB
        listItems = []
    }
    
    func addItem(_ name:String) {
        let newStock = StockItemCellModel(name: name)
        self.listItems.append(newStock)
        self.onClearTfName?()
    }
    
    func removeItem(_ id: String) {
        self.listItems = listItems.filter({$0.id != id})
    }
}
