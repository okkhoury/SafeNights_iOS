//
//  HistoryController.swift
//  SafeNights
//
//  Created by Owen Khoury on 5/13/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit
import Siesta
import Charts

/**
 * Controller for getting history of previous nights.
 * Currently just tests that controller can get previous night 
 * history from database.
 */
class HistoryController: UIViewController {
    
    @IBOutlet weak var moneyChartView: LineChartView!
    
    @IBOutlet weak var alcoholChartView: LineChartView!
    
    
     let API = MyAPI()
    let preferences = UserDefaults.standard
    
    var moneyArray : [Double] = [1, 2, 3, 5, 4]
    var alcoholArray : [Double] = [1, 2, 6, 7, 4]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        styling()
        
        updateGraph()
        
        callGetHistoryAPI()

    }
    
    
    func callGetHistoryAPI() {
        print("Hello")
        
        let resource = API.getHistory
        
        // Get the global values for username and password
        let username = self.preferences.string(forKey: "username")!
        let password = self.preferences.string(forKey: "password")!
        
        let postData = ["username": username,
                        "pwd": password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            //var response = data.jsonDict
            //let answer = response["passed"]
            
            //            var json: Any?
            //            do {
            //                json = try JSONSerialization.jsonObject(with: data)
            //            } catch {
            //                print(error)
            //            }
            //            guard let item = json?.first as? [String: Any],
            //                let person = item["person"] as? [String: Any],
            //                let age = person["age"] as? Int else {
            //                    return
            //            }
        }
    }
    
    func updateGraph(){
        var money_lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        var alcohol_lineChartEntry  = [ChartDataEntry]()
        
        //here is the for loop
        for i in 0..<moneyArray.count {
            let newMoneyEntry = ChartDataEntry(x: Double(i), y: moneyArray[i]) // here we set the X and Y status in a data chart entry
            money_lineChartEntry.append(newMoneyEntry) // here we add it to the data set
            
            let newAlcoholEntry = ChartDataEntry(x: Double(i), y: alcoholArray[i]) // here we set the X and Y status in a data chart entry
            alcohol_lineChartEntry.append(newAlcoholEntry) // here we add it to the data set
        }
        
        let moneySet = LineChartDataSet(values: money_lineChartEntry, label: "money") //Here we convert lineChartEntry to a LineChartDataSet
        let alcoholSet = LineChartDataSet(values: alcohol_lineChartEntry, label: "alcohol") //Here we convert lineChartEntry to a LineChartDataSet
        
        // Styling #1 - some of styling needs to be done to the set
        moneySet.lineWidth = 3.0
        moneySet.circleRadius = 4.0
        moneySet.setColor(UIColor.purple)
        moneySet.circleColors = [UIColor.purple]
        moneySet.circleHoleColor = UIColor.purple
        moneySet.drawValuesEnabled = false
        
        alcoholSet.lineWidth = 3.0
        alcoholSet.circleRadius = 4.0
        alcoholSet.setColor(UIColor.red)
        alcoholSet.circleColors = [UIColor.red]
        alcoholSet.circleHoleColor = UIColor.red
        alcoholSet.drawValuesEnabled = false
        
        // Add the set to the chart, then we style the chart
        let moneyData = LineChartData() //This is the object that will be added to the chart
        moneyData.addDataSet(moneySet) //Adds the line to the dataSet
        let alcoholData = LineChartData() //This is the object that will be added to the chart
        alcoholData.addDataSet(alcoholSet) //Adds the line to the dataSet
        
        moneyChartView.data = moneyData //finally - it adds the chart data to the chart and causes an update
        alcoholChartView.data = alcoholData
    }
    
    func styling() {
        // WHAT IF THERE IS NO DATA?!?!?!
        moneyChartView.noDataText = "No Data!" + "\n" + "Please record any activity in Confess"
        alcoholChartView.noDataText = "No Data!" + "\n" + "Please record any activity in Confess"
        
        // Styling #2
        //      moneySet.setAxisDependency(YAxis.AxisDependency.LEFT);
        //        moneyChartView.leftAxis.axisDependency = true
        //FIX TOUCH
        moneyChartView.isMultipleTouchEnabled = false
        moneyChartView.xAxis.drawGridLinesEnabled = false
        moneyChartView.leftAxis.drawGridLinesEnabled = false
        moneyChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        moneyChartView.rightAxis.enabled = false
        moneyChartView.legend.enabled = false
        moneyChartView.chartDescription?.enabled = false
        moneyChartView.xAxis.axisMinimum = 0.0
        moneyChartView.xAxis.axisMaximum = 31.0
        moneyChartView.xAxis.labelCount = 3
        moneyChartView.leftAxis.labelCount = 5
        moneyChartView.xAxis.labelFont.withSize(10.0)
        moneyChartView.leftAxis.labelFont.withSize(14.0)
        moneyChartView.leftAxis.labelTextColor = UIColor.white
        moneyChartView.xAxis.labelTextColor = UIColor.white
        moneyChartView.leftAxis.axisLineColor = UIColor.white
        moneyChartView.xAxis.axisLineColor = UIColor.white
        moneyChartView.backgroundColor = UIColor.black
        
        //Axis Dependency and Touch
        alcoholChartView.isMultipleTouchEnabled = false
        alcoholChartView.xAxis.drawGridLinesEnabled = false
        alcoholChartView.leftAxis.drawGridLinesEnabled = false
        alcoholChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        alcoholChartView.rightAxis.enabled = false
        alcoholChartView.legend.enabled = false
        alcoholChartView.chartDescription?.enabled = false
        alcoholChartView.xAxis.axisMinimum = 0.0
        alcoholChartView.xAxis.axisMaximum = 31.0
        alcoholChartView.xAxis.labelCount = 3
        alcoholChartView.leftAxis.labelCount = 5
        alcoholChartView.xAxis.labelFont.withSize(10.0)
        alcoholChartView.leftAxis.labelFont.withSize(14.0)
        alcoholChartView.leftAxis.labelTextColor = UIColor.white
        alcoholChartView.xAxis.labelTextColor = UIColor.white
        alcoholChartView.leftAxis.axisLineColor = UIColor.white
        alcoholChartView.xAxis.axisLineColor = UIColor.white
        alcoholChartView.backgroundColor = UIColor.black
        
        //Styling #3 - Axis Scaling and Such
        
        moneyChartView.autoScaleMinMaxEnabled = true
        moneyChartView.leftAxis.axisMinimum = 0.0
        moneyChartView.leftAxis.valueFormatter = DollarFormatter()
        
        alcoholChartView.leftAxis.axisMinimum = 0.0
        alcoholChartView.leftAxis.axisMaximum = 100.0
        alcoholChartView.leftAxis.valueFormatter = PercentFormatter()
    }
    
    
    class DollarFormatter: NSObject, IAxisValueFormatter {
        let numFormatter: NumberFormatter
        override init() {
            numFormatter = NumberFormatter()
            numFormatter.minimumFractionDigits = 0
            numFormatter.maximumFractionDigits = 1
            // if number is less than 1 add 0 before decimal
            numFormatter.minimumIntegerDigits = 1 // how many digits do want before decimal
            numFormatter.paddingPosition = .beforePrefix
            numFormatter.paddingCharacter = "0"
        }
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return "$" + numFormatter.string(from: NSNumber(floatLiteral: value))!
        }
    }
    
    class PercentFormatter: NSObject, IAxisValueFormatter {
        let numFormatter: NumberFormatter
        override init() {
            numFormatter = NumberFormatter()
            numFormatter.minimumFractionDigits = 0
            numFormatter.maximumFractionDigits = 1
            // if number is less than 1 add 0 before decimal
            numFormatter.minimumIntegerDigits = 1 // how many digits do want before decimal
            numFormatter.paddingPosition = .beforePrefix
            numFormatter.paddingCharacter = "0"
        }
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return numFormatter.string(from: NSNumber(floatLiteral: value))! + "%"
        }
    }
    
}
