//
//  Model.swift
//  StockFun
//
//  Created by Tri Tran on 5/13/20.
//  Copyright © 2020 Universal. All rights reserved.
//

import Foundation
public struct Config: Codable {
    var inputNeurons: Int
    var outputNeurons: Int
    var hiddenNeurons: Int
    var numEpochs: Int
    var learningRate: Float
    init(inputNeurons: Int,outputNeurons: Int,hiddenNeurons: Int,numEpochs: Int,learningRate: Float) {
        self.inputNeurons = inputNeurons
        self.outputNeurons = outputNeurons
        self.hiddenNeurons = hiddenNeurons
        self.numEpochs = numEpochs
        self.learningRate = learningRate
    }
}

public struct InputParamNetwork: Codable {
    var countRow: Int
    var inputData: [Float]
    var outputData: [Float]
    var countRowTest: Int
    var testData: [Float]
    var labelData: [Float]
    
    init(countRow: Int,inputData: [Float],outputData: [Float],countRowTest: Int,testData: [Float],
         labelData: [Float]) {
        self.countRow = countRow
        self.inputData = inputData
        self.outputData = outputData
        self.countRowTest = countRowTest
        self.testData = testData
        self.labelData = labelData
    }
}

public struct InputPredictParam: Codable {
    var rows: Int
    var inputData: [Float]
    init(rows: Int,inputData: [Float]) {
        self.rows = rows
        self.inputData = inputData
    }
}

public struct ResultNetWork: Codable {
    var wHidden: [Float]
    var bHidden: [Float]
    var wOut: [Float]
    var bOut: [Float]
    var correlationValue: Float
    init(wHidden: [Float],bHidden: [Float],wOut: [Float],bOut: [Float],correlationValue: Float) {
        self.wHidden = wHidden
        self.bHidden = bHidden
        self.wOut = wOut
        self.bOut = bOut
        self.correlationValue = correlationValue
    }
}
