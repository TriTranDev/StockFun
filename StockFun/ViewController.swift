//
//  ViewController.swift
//  StockFun
//
//  Created by Tran Minh Tri on 4/17/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import UIKit
import SnapKit

public enum TypeVC {
    case Chart
    case Process
    case Setting
}

public struct ParamStoryBoard {
    var nameStoryBoard: String
    var nameViewController: String
    var type: TypeVC
    init (nameStoryBoard: String,nameViewController: String,type: TypeVC) {
        self.nameStoryBoard = nameStoryBoard
        self.nameViewController = nameViewController
        self.type = type
    }
}

class Storyboard: NSObject{
    static let shared = Storyboard()
    private override init() {
        
    }
    
    func createWithName(_ name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
    
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true

    }
}

class ViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    private var settingVC: SettingViewController!
    private var chartVC: UIViewController!
    private var processVC: ProcessViewController!
    private var currentIndex: Int = 0 {
        didSet {
            //TODO
            createMainView(self.currentIndex)
        }
    }
    private var listVCParams: [ParamStoryBoard] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listVCParams = self.createListVCParam()
        self.currentIndex = 0
    }
    
    private func createListVCParam() -> [ParamStoryBoard] {
        let chartVC = ParamStoryBoard(nameStoryBoard: "Chart", nameViewController: "ChartViewController",type: .Chart)
        let processVC = ParamStoryBoard(nameStoryBoard: "Process", nameViewController: "ProcessViewController", type: .Process)
        let settingVC = ParamStoryBoard(nameStoryBoard: "Setting", nameViewController: "SettingViewController", type: .Setting)
        return [chartVC,processVC,settingVC]
    }
    
    @IBAction func actionOpenSetting(_ sender: Any) {
        self.currentIndex = 2
    }
    
    @IBAction func actionOpenChart(_ sender: Any) {
        self.currentIndex = 0
    }
    
    @IBAction func actionOpenProcess(_ sender: Any) {
        self.currentIndex = 1
    }
    
    func createMainView(_ index: Int) {
        removeSubViewContainer()
        guard !self.listVCParams.isEmpty else {
            return
        }
        let currentParam = self.listVCParams[index]
        let tempVC = Storyboard.shared.createWithName(currentParam.nameStoryBoard).instantiateViewController(withIdentifier: currentParam.nameViewController)
        self.addSubViewControllerToSelf(tempVC)
        switch currentParam.type {
        case .Chart:
            self.chartVC = tempVC
            break
        case .Process:
            self.processVC = tempVC as? ProcessViewController
            break
        case .Setting:
            self.settingVC = tempVC as? SettingViewController
            break
        }
    }
    
    private func addSubViewControllerToSelf(_ VC: UIViewController) {
        VC.willMove(toParent: self)
        self.containerView.addSubview(VC.view)
        VC.view.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        self.addChild(VC)
        VC.didMove(toParent: self)
    }
    
    private func removeSubViewContainer() {
        for item in self.containerView.subviews {
            item.removeFromSuperview()
        }
    }
    
    

}

