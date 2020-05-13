//
//  ProcessViewModel.swift
//  StockFun
//
//  Created by Tran Minh Tri on 5/2/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import Foundation
import SwiftCSV
import Neuralnetworkmobile

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
        self.createConfigFileIfNeed()
    }
    
    private func writeData(_ data: Data, fileName: String) {
        if let tempStringData = String(data: data, encoding: .utf8) {
            self.writeFile(tempStringData, fileName: fileName)
        }
    }
    
    private func createConfigFileIfNeed() {
        guard self.getData("config.json") != nil else {
            let tempConfig = Config(inputNeurons:5,outputNeurons:1,hiddenNeurons:5,numEpochs:5000,learningRate:0.01)
            if let configData = try? JSONEncoder().encode(tempConfig) {
                self.writeData(configData, fileName: "config.json")
            }
            return
        }
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
        print("file write \(dir)")
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
//            print(tempCSV.enumeratedColumns[2])
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
        let newWeight = weight.map{$0/maxWeight}
        
        var allData: [RowData] = []
        var predictDataRows: [RowData] = []
        var testDataRows: [RowData] = []
        var trainDataRows: [RowData] = []
        let length = newOpenPrice.count
        let lenghtPredict = 100
        let lengthTest = Int(Double(length - lenghtPredict) * 0.2)
        let lengthTrain = length - lenghtPredict - lengthTest
        
        for i in 0..<length {
            let tempData: [Float] = [newOpenPrice[i],newMaxPrice[i],newLowPrice[i],newClosePrice[i],newWeight[i],newClosePricePredict[i]]
            let tempRow = RowData(date: listDate[i], data: tempData)
            allData.append(tempRow)
        }
        
        predictDataRows = Array(allData[0..<lenghtPredict])
        testDataRows = Array(allData[lenghtPredict..<lenghtPredict+lengthTest])
        trainDataRows = Array(allData[(lenghtPredict+lengthTest)...])
        
        let trainData = self.generateDataFromRawData(trainDataRows)
        let testData = self.generateDataFromRawData(testDataRows)
        
        let tempInputParam = InputParamNetwork(countRow: trainDataRows.count, inputData: trainData.input, outputData: trainData.label, countRowTest: testDataRows.count, testData: testData.input, labelData: testData.label)
        if let dataInput = try? JSONEncoder().encode(tempInputParam) {
            self.writeData(dataInput, fileName: "data.json")
        }
        
        let predictData = self.generateDataFromRawData(predictDataRows)
        let inputParamPredict = InputPredictParam(rows: predictDataRows.count, inputData: predictData.input)
        if let dataPredict = try? JSONEncoder().encode(inputParamPredict) {
            self.writeData(dataPredict, fileName: "dataPredict.json")
        }
        
    }
    
    private func generateDataFromRawData(_ datas:[RowData]) -> (input: [Float], label: [Float]) {
        let inputData = datas.map({$0.data[0...4]}).flatMap({$0})
        let labelData: [Float] = datas.map({$0.data.last!})
        return (input:inputData, label: labelData)
    }
    
    func trainData() {
        
        let configValue = self.getData("config.json")
        let inputTrainValue = self.getData("data.json")
        let predictDataValue = self.getData("dataPredict.json")
        
        let model = NeuralnetworkmobileProcessNeuralWithJSON(configValue, inputTrainValue)
        print("model demo: ",model)
        let result = NeuralnetworkmobilePredictNeuralWithJSON(model, configValue, predictDataValue)
        print("Result demo: ",result)
    }
    
}
