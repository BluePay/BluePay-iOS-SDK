import Foundation
import CommonCrypto
import AddressBook
import PassKit
class BluePay {
    var bluepaySetup = [String: String]()
    var AccountID: String = "100013391447" // 12 digit Account ID
    var SecretKey: String = "5YRFNRBCZN/6Y4OPZNWPYDRNAVX7BMMD" // 32 digit Secret Key
    var TransMode: String = "TEST" // TEST or LIVE mode
    var TransType: String = "SALE" // SALE or AUTH; defaults to SALE unless explicitly specified

    init(transactionType: String? = nil) {
        bluepaySetup = ["AccountID" : self.AccountID,
                        "SecretKey" : self.SecretKey,
                        "TransMode" : self.TransMode,
                        "TransType" : self.TransType]
        if transactionType != nil {
            bluepaySetup["TransType"] = transactionType
        }
    }

    func getBluePaySetup() -> NSDictionary {
        return bluepaySetup
    }

    class func calcTPS(secretKey: String, accID accountID: String, transType transactionType: String, transAmount amount: String, fullName name: String, paymentAcct paymentAccount: String) -> String {
            // Calculates the TAMPER_PROOF_SEAL needed for each transaction for the bp20post API
        var tps = ""
        tps += secretKey
        tps += accountID
        tps += transactionType
        tps += amount
        tps += name
        tps += paymentAccount
        let md5 = MD5(tps)
        return md5
    }

    class func getCustomerInformation(payment: PKPayment) -> [String : String] {
        // Grab the first and last name plus address values from the billing address
        let firstName: String = payment.billingContact!.name!.givenName!
        let lastName: String = payment.billingContact!.name!.familyName!
        let addr1: String = payment.billingContact!.postalAddress!.street
        let city: String = payment.billingContact!.postalAddress!.city
        let state: String = payment.billingContact!.postalAddress!.state
        let zip: String = payment.billingContact!.postalAddress!.postalCode
        let country: String = payment.billingContact!.postalAddress!.country
        // Grab the phone and email values from the shipping address
        let phone: String = payment.shippingContact!.phoneNumber!.stringValue
        let email: String = payment.shippingContact!.emailAddress!
        // Add customer first name, last name, phone, and email to the customerInformation NSDict
        var customerInformation: [String : String] = [String : String]()
        customerInformation["FirstName"] = firstName
        customerInformation["LastName"] = lastName
        customerInformation["Street"] = addr1
        customerInformation["City"] = city
        customerInformation["State"] = state
        customerInformation["ZIP"] = zip
        customerInformation["Country"] = country
        customerInformation["Phone"] = phone
        customerInformation["Email"] = email
        return customerInformation
    }
}

    func MD5(tps: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.alloc(1)
        var digest = Array<UInt8>(count:Int(CC_MD5_DIGEST_LENGTH), repeatedValue:0)
        CC_MD5_Init(context)
        CC_MD5_Update(context, tps,
                      CC_LONG(tps.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        CC_MD5_Final(&digest, context)
        context.dealloc(1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }

extension NSString {
    func stringByAddingPercentEncodingForRFC3986() -> String {
        let unreserved: String = "-._~/"
        let allowed: NSMutableCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
    }
}

extension NSData {
    
    var hexString : String {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(i: UInt8) -> UInt8 {
            return (i > 9) ? (charA + i - 10) : (char0 + i)
        }
        
        let p = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        
        for i in 0..<length {
            p[i*2] = itoh((buf[i] >> 4) & 0xF)
            p[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return NSString(bytesNoCopy: p, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)! as String
    }
}