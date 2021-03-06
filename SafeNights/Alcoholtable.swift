import Foundation

public class Alcoholtable {
	public var pk : Int?
	public var model : String?
	public var fields : Fields?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let alcoholtable_list = Alcoholtable.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Alcoholtable Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Alcoholtable]
    {
        var models:[Alcoholtable] = []
        for item in array
        {
            models.append(Alcoholtable(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let alcoholtable = Alcoholtable(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Alcoholtable Instance.
*/
	required public init?(dictionary: NSDictionary) {

		pk = dictionary["pk"] as? Int
		model = dictionary["model"] as? String
		if (dictionary["fields"] != nil) { fields = Fields(dictionary: dictionary["fields"] as! NSDictionary) }
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.pk, forKey: "pk")
		dictionary.setValue(self.model, forKey: "model")
		dictionary.setValue(self.fields?.dictionaryRepresentation(), forKey: "fields")

		return dictionary
	}

}
