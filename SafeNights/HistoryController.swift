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
    
    @IBOutlet weak var totalSpendingLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var monthStepper: UIStepper!
    @IBOutlet weak var loadingMoneyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingAlcoholIndicator: UIActivityIndicatorView!
    
     let API = MyAPI()
    let preferences = UserDefaults.standard
    
    var allData : [Fields] = []
    var monthsDictionary = [String: [Fields]]()
    
    var todayKey : String = ""
    var displayMonth : Int = 1
    var displayYear : Int = 2017
    var totalSpent : Int = 0
    //Used to track the months the stepper will go. Starts on max so user can't go into future
    var stepperOldVal : Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        // Do any additional setup after loading the view, typically from a nib.
        // Clear old data because they can persist from last on appear not load (when user toggles between tabs after initial load
        self.allData.removeAll()
        self.monthsDictionary.removeAll()
        self.totalSpent = 0
        //Starts loading indicator while API is called 
        loadingMoneyIndicator.isHidden = false
        loadingAlcoholIndicator.isHidden = false
        loadingMoneyIndicator.startAnimating()
        loadingAlcoholIndicator.startAnimating()
        // Sets up all the styling for the graph
        styling()
        // Calls API to get the information. Only needs once, it is parsed so can just update dictionary array in future
        callGetHistoryAPI()
    }
    
    
    @IBAction func monthStepperAction(_ sender: Any) {
        
        if (Int(monthStepper.value) > stepperOldVal) {
            stepperOldVal=stepperOldVal+1;
            //Your Code You Wanted To Perform On Increment
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.year = self.displayYear
            dateComponents.month = self.displayMonth
            let thisCalMonth = calendar.date(from: dateComponents)
            let nextCalMonth = calendar.date(byAdding: .month, value: 1, to: thisCalMonth!)
            let components = calendar.dateComponents([.year, .month, .day], from: nextCalMonth!)
            self.displayMonth = components.month!
            self.displayYear = components.year!
            monthLabel.text = getMonthFromInt(month: components.month!)
            // Update Graph Again
            updateGraph()
        }
        else {
            stepperOldVal=stepperOldVal-1;
            //Your Code You Wanted To Perform On Decrement
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.year = self.displayYear
            dateComponents.month = self.displayMonth
            let thisCalMonth = calendar.date(from: dateComponents)
            let nextCalMonth = calendar.date(byAdding: .month, value: -1, to: thisCalMonth!)
            let components = calendar.dateComponents([.year, .month, .day], from: nextCalMonth!)
            self.displayMonth = components.month!
            self.displayYear = components.year!
            monthLabel.text = getMonthFromInt(month: components.month!)
            // Update Graph Again
            updateGraph()
        }
    }
    
    
    
    
    func callGetHistoryAPI() {
        let resource = API.getHistory
        
        // Get the global values for username and password
        let username = self.preferences.string(forKey: "username")!
        let password = self.preferences.string(forKey: "password")!
        
        let postData = ["username": username,
                        "pwd": password]
        
        resource.request(.post, urlEncoded: postData).onSuccess() { data in
            var response = data.jsonDict
            let answer = response["alcoholtable"] as! NSArray!
            
            let arr = Alcoholtable.modelsFromDictionaryArray(array: answer!)
            
            for item in arr {
                self.allData.append(item.fields!)
            }
            
            // Then we parse months. Should only do this once, so after this we can update graph
            self.parseDataByMonths()
        }
    }
    
    func parseDataByMonths() {
        let calendar = Calendar.current
        for night in allData {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
            let day = dateFormatter.date(from: night.day!)
            let components = calendar.dateComponents([.year, .month, .day], from: day!)
            let key = String(components.month!) + String(components.year!)
            if self.monthsDictionary[key] != nil {
                // now val is not nil and the Optional has been unwrapped, so use it
                self.monthsDictionary[key]?.append(night)
            } else {
                var newMonth : [Fields] = []
                newMonth.append(night)
                monthsDictionary[key] = newMonth
            }
        }
        // This is done for a check to make this months graph nicer and not look at future months
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        self.displayMonth = components.month!
        self.displayYear = components.year!
        todayKey = String(components.month!) + String(components.year!)
        monthLabel.text = getMonthFromInt(month: components.month!)
        //Stop the loading animation. Update graph takes less that 1 second and so can do this now
        loadingMoneyIndicator.stopAnimating()
        loadingAlcoholIndicator.stopAnimating()
        loadingMoneyIndicator.isHidden = true
        loadingAlcoholIndicator.isHidden = true
        // This should only be called once, so we now update the Graph.
        // Note- update graph will be called again every other time when Month is updated
        updateGraph()
    }
    
    func calculateDrunkness(field : Fields) -> Double {
        let total = 100.0*((Double(field.beer!) + Double(field.wine!) + Double(field.hardliquor!) + Double(field.shots!))/40.0)
        return Double(total)
    }
    
    //Logic for setting up months. Called every time month changed
    func updateGraph(){
        let thisMonthKey = String(displayMonth) + String(displayYear)
        
        // Null check so no error thrown.
        if(monthsDictionary[thisMonthKey] == nil){
            // Clears data. No data text is set up in styling()
            moneyChartView.clear();
            alcoholChartView.clear();
            //Change Label so it doesn't show last months spending
            totalSpendingLabel.text = "Total= $0"
            return
        }
        
        //Booleans are to give start and end to month if there is no data for the 1st and 31st
        var missing1st = true
        var missing31st = true
        totalSpent = 0
        
        //Start Charts logic
        var money_lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        var alcohol_lineChartEntry  = [ChartDataEntry]()
        
        //here is the for loop
        for datapoint in monthsDictionary[thisMonthKey]! {
            let alcoholY = calculateDrunkness(field: datapoint)
            // Checking for the 1st and 31st
            if(getDay(date: datapoint.day!) == 0) {
                missing1st = false
            } else if(getDay(date: datapoint.day!) == 31) {
                missing31st = false
            }
            
            let newMoneyEntry = ChartDataEntry(x: getDay(date: datapoint.day!), y: Double(datapoint.money!)) // here we set the X and Y status in a data chart entry
            money_lineChartEntry.append(newMoneyEntry) // here we add it to the data set
            
            let newAlcoholEntry = ChartDataEntry(x: getDay(date: datapoint.day!), y: alcoholY) // here we set the X and Y status in a data chart entry
            alcohol_lineChartEntry.append(newAlcoholEntry) // here we add it to the data set
            
            totalSpent += datapoint.money!
        }
        
        // Set label for total spending
        totalSpendingLabel.text = "Total= $" + String(totalSpent)
        
        //Add Missing if Needed
        if(missing1st) {
            money_lineChartEntry.append(ChartDataEntry(x: 0.0, y: 0.0))
            alcohol_lineChartEntry.append(ChartDataEntry(x: 0.0, y: 0.0))
        }
        if(todayKey != thisMonthKey) {
            if(missing31st) {
                money_lineChartEntry.append(ChartDataEntry(x: 31.0, y: 0.0))
                alcohol_lineChartEntry.append(ChartDataEntry(x: 31.0, y: 0.0))
            }
        }
        
        //Needs to be sorted to work :)
        money_lineChartEntry = money_lineChartEntry.sorted { $0.x < $1.x }
        alcohol_lineChartEntry = alcohol_lineChartEntry.sorted { $0.x < $1.x }
        
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
        moneyChartView.noDataTextColor = UIColor.white
        alcoholChartView.noDataTextColor = UIColor.white
        
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
    
    func getDay(date : String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
        let day = dateFormatter.date(from: date)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: day!)
        return Double(components.day!)
    }
    
    func getMonthFromInt(month : Int) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        let months = dateFormatter.shortMonthSymbols
        let monthSymbol = months?[month-1]
        return monthSymbol!
    }
    
}
