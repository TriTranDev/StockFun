//
//  ProcessViewController.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import UIKit

class ProcessViewController: UIViewController {

    
    @IBOutlet weak var processStatus: UIProgressView!
    @IBOutlet weak var nameStock: UITextField!
    var model: ProcessViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ProcessViewModel()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionDownloadData(_ sender: Any) {
        model.downloadData()
    }
    
    @IBAction func actionProcessData(_ sender: Any) {
    }
    
    @IBAction func actionTrain(_ sender: Any) {
        model.trainData()
    }
    
    @IBAction func actionPredict(_ sender: Any) {
        
    }
    
    @IBAction func actionSaveData(_ sender: Any) {
        
    }
    
}

//MARK:- Download Data
extension ProcessViewController {
    
}


