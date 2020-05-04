//
//  ProcessViewModel.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import Foundation
import SwiftCSV
import NeuralNetwork

public struct RowData {
    var date: String
    var data: [Float]
    init(date: String,data: [Float]) {
        self.date = date
        self.data = data
    }
}

public struct TrainObject: Codable {
    var countRow: Int
    var inputData: [Float]
    init(countRow: Int,inputData: [Float]) {
        self.countRow = countRow
        self.inputData = inputData
    }
}

class ProcessViewModel : NSObject {
    var stockName: String!
    var fileName: String = "vcb.csv"
    override init() {
        super.init()
        stockName = "vcb"
    }
    
    func downloadData() {
        guard let dataString = self.getData(fileName) else {
            let url = URL(string: "https://www.cophieu68.vn/exportexcel.php?id=vcb")
            
            let task = URLSession.shared.downloadTask(with: url!) { (localUrl, response, error) in
                if let localUrl = localUrl {
                    print(localUrl)
                    if let string = try? String(contentsOf: localUrl) {
                        self.writeFile(string, fileName: self.fileName)
                        print(string)
                    }
                }
            }
            
            task.resume()
            return
        }
        
        self.processData(dataString)
        
    }
    
    private func getDir() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir
    }
    
    private func writeFile(_ string: String, fileName: String) {
        guard let dir = self.getDir() else {return}
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            try string.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            
        }
    }
    
    private func getData(_ fileName:String) -> String? {
        guard let dir = self.getDir() else {return nil}
        let fileURL = dir.appendingPathComponent(fileName)
        var result: String? = nil
        do {
            result = try String(contentsOf: fileURL, encoding: .utf8)
        }catch {
            
        }
        return result
    }
    
    func processData(_ string: String) {
        do {
            let tempCSV = try CSV(string: string)
            print(tempCSV.enumeratedColumns[2])
            normalizeData(tempCSV)
            
        } catch let error {
            print(error)
        }
    }
    
    func normalizeData(_ tempCSV: CSV) {
        var listDate: [String] = tempCSV.enumeratedColumns[1].rows
        let openPrice: [Float] = tempCSV.enumeratedColumns[2].rows.map({Float($0) ?? 0.0})
        let maxPrice: [Float] = tempCSV.enumeratedColumns[3].rows.map({Float($0) ?? 0.0})
        let lowPrice: [Float] = tempCSV.enumeratedColumns[4].rows.map({Float($0) ?? 0.0})
        let closePrice: [Float] = tempCSV.enumeratedColumns[5].rows.map({Float($0) ?? 0.0})
        let weight: [Float] = tempCSV.enumeratedColumns[6].rows.map({Float($0) ?? 0.0})
        let closePricePredict: [Float] = tempCSV.enumeratedColumns[5].rows.map({Float($0) ?? 0.0})
        
        var maxClosePrice: Float = 1
        if let tempMax = closePrice.max() {
            maxClosePrice = tempMax * 2
        }
        
        var maxWeight:Float = 1
        if let tempMax = weight.max() {
            maxWeight = tempMax * 2
        }
        
        let newOpenPrice = openPrice.map{$0/maxClosePrice}
        let newMaxPrice = maxPrice.map{$0/maxClosePrice}
        let newLowPrice = lowPrice.map{$0/maxClosePrice}
        let newClosePrice = closePrice.map{$0/maxClosePrice}
        let newClosePricePredict = closePricePredict.map{$0/maxClosePrice}
        let newWeight = closePrice.map{$0/maxWeight}
        
        var allData: [RowData] = []
        var predictData: [RowData] = []
        var testData: [RowData] = []
        var trainData: [RowData] = []
        let length = newOpenPrice.count
        let lenghtPredict = 100
        let lengthTest = Int(Double(length - lenghtPredict) * 0.2)
        let lengthTrain = length - lenghtPredict - lengthTest
        
        for i in 0..<length {
            let tempData: [Float] = [newOpenPrice[i],newMaxPrice[i],newLowPrice[i],newClosePrice[i],newWeight[i],newClosePricePredict[i]]
            let tempRow = RowData(date: listDate[i], data: tempData)
            allData.append(tempRow)
        }
        
        predictData = Array(allData[0..<lenghtPredict])
        testData = Array(allData[lenghtPredict..<lenghtPredict+lengthTest])
        trainData = Array(allData[(lenghtPredict+lengthTest)...])
        
        let newTestData = testData.map({$0.data})
        let newTrainData = trainData.map({$0.data})
        
    }
    
    func trainData() {
        
        let configValue = self.getData("config.json")
        let inputTrainValue = self.getData("data.json")
        let predictDataValue = self.getData("dataPredict.json")
        
        let model = NeuralNetworkProcessNeuralWithJSON(configValue, inputTrainValue)
        print("model demo: ",model)
        let result = NeuralNetworkPredictNeuralWithJSON(model, configValue, predictDataValue)
        print("Result demo: ",result)
    }
    
}
