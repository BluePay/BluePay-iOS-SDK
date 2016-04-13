import UIKit
import PassKit
import Security
import CoreFoundation
import AddressBook

class ApplePayController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    let alertController = UIAlertController(title:"Transaction Result", message: "", preferredStyle: .Alert)
    let okAction: UIAlertAction = UIAlertAction(title:"OK", style: .Default, handler: {(action: UIAlertAction) -> Void in
    })

    override func viewDidLoad() {
        alertController.addAction(okAction)
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buttonTapped(sender: UIButton) {
        // Verify that the user's device can accept Apple Pay transactions
        if PKPaymentAuthorizationViewController.canMakePayments() {
            let request: PKPaymentRequest = PKPaymentRequest()
                // Set up sample app test items
            let widget1: PKPaymentSummaryItem = PKPaymentSummaryItem(label: "Widget 1", amount: NSDecimalNumber(string: "4.99"))
            let widget2: PKPaymentSummaryItem = PKPaymentSummaryItem(label: "Widget 2", amount: NSDecimalNumber(string: "1.00"))
            let sum: NSDecimalNumber = NSDecimalNumber(float: (CFloat(widget1.amount) + CFloat(widget2.amount)))
            let total: PKPaymentSummaryItem = PKPaymentSummaryItem(label: "Grand Total", amount: sum)
            
            // Request setup portion
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
            request.merchantCapabilities = [PKMerchantCapability.Capability3DS, PKMerchantCapability.CapabilityEMV]
            request.merchantIdentifier = "merchant.test.justin"
            request.paymentSummaryItems = [widget1, widget2, total]
            // Payment will include *all* shipping and billing fields
            request.requiredShippingAddressFields = .All
            request.requiredBillingAddressFields = .All
            let paymentPane = PKPaymentAuthorizationViewController.init(paymentRequest:request)
            paymentPane.delegate = self
            self.presentViewController(paymentPane, animated: true, completion: { _ in })
        }
        else {
            // User's device cannot accept Apple Pay transactions. Display a payment form here for them to enter their payment info into.
            print("Device cannot make Apple Pay payments.")
            self.alertController.message = "Device cannot make Apple Pay payments."
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        self.handlePaymentAuthorizationWithPayment(payment, completion: completion)
    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        self.dismissViewControllerAnimated(true, completion: { _ in })
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func handlePaymentAuthorizationWithPayment(payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        // Grab the customer's name, billing address, phone #, and email address
        var customerInformation: [String: String] = BluePay.getCustomerInformation(payment)
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(payment.token.paymentData, options: []) as! [String: AnyObject]
            customerInformation.updateValue(json["header"]!["ephemeralPublicKey"]! as! String, forKey: "pubKey")
            customerInformation.updateValue(json["data"]! as! String, forKey: "data")
            customerInformation.updateValue(json["signature"]! as! String, forKey: "signature")
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        let bluepay: BluePay = BluePay()
        // Pass Apple Pay transaction data to BluePayRequest, then do POST to the BluePay gateway
        BluePayRequest.Post(bluepaySetup: bluepay.getBluePaySetup() as! [String : String], customer: customerInformation) { (succeeded: Bool, msg: String) in
            let response: NSMutableDictionary = BluePayResponse.ParseResponse(msg)
            // Get transaction response from the BluePay gateway
            
            dispatch_async(dispatch_get_main_queue(), {
                // If transaction was approved, return PKPaymentAuthorizationStatusSuccess
                if BluePayResponse.isApproved(response) {
                    completion(PKPaymentAuthorizationStatus.Success)
                    print("The transaction was processed and approved.")
                    self.alertController.message = "The transaction was processed and approved.\nTransaction ID:\(response["TRANS_ID"] as! String)"
                // If transaction was declined, return PKPaymentAuthorizationStatusFailure
                }
                else if BluePayResponse.isDeclined(response) {
                    completion(PKPaymentAuthorizationStatus.Failure)
                    print("The transaction has been declined.")
                    self.alertController.message = "The transaction has been declined."
                // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
                }
                else {
                    completion(PKPaymentAuthorizationStatus.Failure)
                    print("There was an error when processing the payment. Reason: %@", (response["MESSAGE"] as! String))
                    self.alertController.message = "There was an error when processing the payment. Reason: \(response["MESSAGE"] as! String)"

                }
            })
            
        }

    }
}