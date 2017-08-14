//
//  PopDateViewController.swift
//  SafeNights
//
//  Created by Zachary Skemp on 8/13/17.
//  Copyright © 2017 SafeNights. All rights reserved.
//

import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(_ date : Date?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var okButton: UIButton!
    
    weak var delegate : DataPickerViewControllerDelegate?
    
    var currentDate : Date? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
        // Set maximum date as current date so can't log future
        datePicker.maximumDate = Date()
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
}
