/* 
Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Fields {
	public var money : Int?
	public var wine : Int?
	public var userID : String?
	public var shots : Int?
	public var beer : Int?
	public var hardliquor : Int?
	public var day : String?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let fields_list = Fields.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Fields Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Fields]
    {
        var models:[Fields] = []
        for item in array
        {
            models.append(Fields(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let fields = Fields(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Fields Instance.
*/
	required public init?(dictionary: NSDictionary) {

		money = dictionary["money"] as? Int
		wine = dictionary["wine"] as? Int
		userID = dictionary["userID"] as? String
		shots = dictionary["shots"] as? Int
		beer = dictionary["beer"] as? Int
		hardliquor = dictionary["hardliquor"] as? Int
		day = dictionary["day"] as? String
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.money, forKey: "money")
		dictionary.setValue(self.wine, forKey: "wine")
		dictionary.setValue(self.userID, forKey: "userID")
		dictionary.setValue(self.shots, forKey: "shots")
		dictionary.setValue(self.beer, forKey: "beer")
		dictionary.setValue(self.hardliquor, forKey: "hardliquor")
		dictionary.setValue(self.day, forKey: "day")

		return dictionary
	}

}