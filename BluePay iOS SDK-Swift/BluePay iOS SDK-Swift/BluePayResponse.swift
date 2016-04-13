import Foundation
class BluePayResponse: NSObject {
    class func ParseResponse(queryString: String) -> NSMutableDictionary {
        let queryStringDictionary = NSMutableDictionary()
        let urlComponents: [String] = queryString.componentsSeparatedByString("&")
        for keyValuePair: String in urlComponents {
            let pairComponents: NSArray = keyValuePair.componentsSeparatedByString("=")
            let key = pairComponents.firstObject!.stringByRemovingPercentEncoding
            let value : String?! = pairComponents.lastObject!.stringByRemovingPercentEncoding
            queryStringDictionary.setValue(value!, forKey: key!!)
        }
        return queryStringDictionary
    }

    class func isApproved(response: NSDictionary) -> Bool {
        if ((response["STATUS"] as! String) == "1") && !(response["MESSAGE"] as! String).isEqual("DUPLICATE") {
            return true
        }
        return false
    }

    class func isDeclined(response: NSDictionary) -> Bool {
        if ((response["STATUS"] as! String) == "0") && !(response["MESSAGE"] as! String).isEqual("DUPLICATE") {
            return true
        }
        return false
    }
}