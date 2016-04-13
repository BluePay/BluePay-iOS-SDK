import Foundation
class BluePayRequest: NSObject {
    class func Post(bluepaySetup bpSetup: [String: String], customer customerInfo: [String: String], postCompleted : (succeeded: Bool, msg: String) -> ()) {
        if !bpSetup["TransType"]!.isEqual("SALE") && !bpSetup["TransType"]!.isEqual("AUTH") {
            postCompleted(succeeded: false, msg: "Error: Transaction type must be either SALE or AUTH")
        }
        // Create POST string to send to BluePay
        var post = ""
        post += "ACCOUNT_ID=%@"
        post += "&MODE=%@"
        post += "&TRANS_TYPE=%@"
        post += "&NAME1=%@"
        post += "&NAME2=%@"
        post += "&ADDR1=%@"
        post += "&CITY=%@"
        post += "&STATE=%@"
        post += "&ZIP=%@"
        post += "&COUNTRY=%@"
        post += "&PHONE=%@"
        post += "&EMAIL=%@"
        var postString = String(format: post, bpSetup["AccountID"]!, bpSetup["TransMode"]!, bpSetup["TransType"]!, customerInfo["FirstName"]!, customerInfo["LastName"]!, customerInfo["Street"]!, customerInfo["City"]!, customerInfo["State"]!, customerInfo["ZIP"]!, customerInfo["Country"]!, customerInfo["Phone"]!, customerInfo["Email"]!)
        post = ""
        if (customerInfo["pubKey"] != nil) {
            let tps: String = BluePay.calcTPS(bpSetup["SecretKey"]!, accID: bpSetup["AccountID"]!, transType: bpSetup["TransType"]!, transAmount: "", fullName: customerInfo["FirstName"]!, paymentAcct: "")
            post += "&TAMPER_PROOF_SEAL=%@"
            post += "&APPLE_EPK=%@"
            post += "&APPLE_DATA=%@"
            post += "&APPLE_SIG=%@"
            postString += String(format: post, tps, customerInfo["pubKey"]!.stringByAddingPercentEncodingForRFC3986(), customerInfo["data"]!.stringByAddingPercentEncodingForRFC3986(), customerInfo["signature"]!.stringByAddingPercentEncodingForRFC3986())
        }
        else if (customerInfo["EncryptedTrack1"] != nil) {
            let tps: String = BluePay.calcTPS(bpSetup["SecretKey"]!, accID: bpSetup["AccountID"]!, transType: bpSetup["TransType"]!, transAmount: customerInfo["Amount"]!, fullName: customerInfo["FirstName"]!, paymentAcct: "")
            post += "&TAMPER_PROOF_SEAL=%@"
            post += "&AMOUNT=%@"
            post += "&TRACK1_ENC=%@"
            post += "&TRACK1_EDL=%@"
            post += "&KSN=%@"
            postString += String(format: post, tps, customerInfo["Amount"]!, customerInfo["EncryptedTrack1"]!, customerInfo["Track1Length"]!, customerInfo["KSN"]!)
        }
        else {
            let tps: String = BluePay.calcTPS(bpSetup["SecretKey"]!, accID: bpSetup["AccountID"]!, transType: bpSetup["TransType"]!, transAmount: customerInfo["Amount"]!, fullName: customerInfo["FirstName"]!, paymentAcct: customerInfo["CardNumber"]!)
            post += "&TAMPER_PROOF_SEAL=%@"
            post += "&AMOUNT=%@"
            post += "&PAYMENT_ACCOUNT=%@"
            post += "&CARD_EXPIRE=%@"
            postString += String(format: post, tps, customerInfo["Amount"]!, customerInfo["CardNumber"]!, customerInfo["CardExpirationDate"]!)
        }
            // POST to the bp20post API of the BluePay gateway
        let postURL: String = "https://secure.bluepay.com/interfaces/bp20post"
        let postRequest: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: postURL)!)
        postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("BluePay iOS SDK", forHTTPHeaderField: "User-Agent")
        postRequest.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        // Create the POST request and specify its body data
        postRequest.HTTPMethod = "POST"
        
        postRequest.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(postRequest) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                postCompleted(succeeded: false, msg: "error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            postCompleted(succeeded: true, msg: responseString as! String)
        }
        task.resume()
        return
        // Return the body of the HTTPS POST response from BluePay
        //return responseBody
    }
}