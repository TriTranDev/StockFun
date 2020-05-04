//
//  SettingViewController.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var tbListStock: UITableView!
    @IBOutlet weak var tfInputStock: UITextField!
    var model: SettingViewModel!
    var datasource: SettingViewDatasource!
    override func viewDidLoad() {
        super.viewDidLoad()
        model = SettingViewModel()
        datasource = SettingViewDatasource(tbListStock)
        bindDatasource()
        bindEvent()
        model.loadData()
    }
    
    func bindDatasource() {
        datasource.onDeleteItem = { [weak self] id in
            self?.model.removeItem(id)
        }
    }
    
    func bindEvent() {
        model.onReloadData = { [weak self] items in
            self?.datasource.updateData(items)
        }
        
        model.onClearTfName = { [weak self] in
            self?.tfInputStock.text = ""
        }
    }
    
    @IBAction func actionAddStock(_ sender: Any) {
        guard let nameStock = self.tfInputStock.text else {return}
        self.model.addItem(nameStock)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
