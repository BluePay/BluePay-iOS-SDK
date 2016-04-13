import UIKit
import PassKit
import Security
import CoreFoundation
import AddressBook

class ProcessController: UIViewController {
    
    @IBOutlet weak var name1: UITextField!
    @IBOutlet weak var name2: UITextField!
    @IBOutlet weak var addr1: UITextField!
    @IBOutlet weak var addr2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv2: UITextField!
    
    @IBOutlet weak var expiryDatePicker: MonthYearPickerView!
    
    //let expiryDatePicker = MonthYearPickerView(frame: CGRectZero)
    var expirationDate : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            var expMonth : String
            var expYear : String
            //self.expirationDate = String(format: "%02d/%d", month, year)
            expMonth = String(format: "%02d", month)
            expYear = String(format: "%d", year)
            self.expirationDate = expMonth + expYear.substringFromIndex(expYear.startIndex.advancedBy(2))
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        //super.didReceiveMemoryWarning()
    }
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        var transAmount: String = ""
        var transType: String = "SALE"
        // If the amount has been set, use the user-inputted value. Else, set amount to $0.00 and trans type to AUTH to initiate a $0 auth (token generation)
        if amount != nil && amount.text != "" {
            transAmount = amount.text!
        }
        else {
            transAmount = "0.00"
            transType = "AUTH"
        }
        let customerInformation: [String: String] = ["FirstName": name1.text!, "LastName": name2.text!, "Street": addr1.text!, "City": city.text!, "State": state.text!, "ZIP": zip.text!, "Country": "US", "Phone": "", "Email": "", "CardNumber": cardNumber.text!, "CardExpirationDate": self.expirationDate, "Amount": transAmount]
        let bluepay: BluePay = BluePay(transactionType: transType)
        // Pass transaction data to BluePayRequest, then do POST to the BluePay gateway
        BluePayRequest.Post(bluepaySetup: bluepay.getBluePaySetup() as! [String : String], customer: customerInformation) { (succeeded: Bool, msg: String) in
            let alertController = UIAlertController(title:"Transaction Result", message: "", preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title:"OK", style: .Default, handler: {(action: UIAlertAction) -> Void in
                // optional: clear all fields
            })
            
            // Get transaction response from the BluePay gateway
             let response: NSMutableDictionary = BluePayResponse.ParseResponse(msg)
             if BluePayResponse.isApproved(response) {
                print("The transaction was processed and approved.\nTransaction ID: ", (response["TRANS_ID"] as! String))
                alertController.message = "The transaction was processed and approved.\nTransaction ID:\(response["TRANS_ID"] as! String)"
             } else if BluePayResponse.isDeclined(response) {
                print("The transaction has been declined.")
                alertController.message = "The transaction has been declined."
                // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
             } else {
                print("There was an error when processing the payment. Reason: ", (response["MESSAGE"] as! String))
                alertController.message = "There was an error when processing the payment. Reason: \(response["MESSAGE"] as! String)"
             }
            
            //alertController.modalPresentationStyle = UIModalPresentationPopover
            dispatch_async(dispatch_get_main_queue(), {
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
}