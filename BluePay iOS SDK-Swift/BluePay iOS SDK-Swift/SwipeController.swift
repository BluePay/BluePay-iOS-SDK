import UIKit
import PassKit
import Security
import CoreFoundation
import AddressBook
import AVFoundation
import AudioToolbox
import MediaPlayer

class SwipeController: UIViewController, UITabBarDelegate {
    
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
    @IBOutlet weak var attachedLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var textResponse: UITextField!
    @IBOutlet weak var hexResponse: UITextField!
    
    var uniMagViewController: UniMagViewController = UniMagViewController()
    //var prompt_connecting: UIAlertController!
    //var prompt_waitingForSwipe: UIAlertController!
    let alertController = UIAlertController(title:"UniMag", message: "Powering up...", preferredStyle: .Alert)
    let okAction: UIAlertAction = UIAlertAction(title:"OK", style: .Default, handler: {(action: UIAlertAction) -> Void in
        // optional: clear all fields
    })
    var track1String : String = ""
    var track1EncString : String = ""
    var KSN : String = ""
    var attachedLabelState: Bool {
        get {
            return self.attachedLabelState
        }
        set (isAttached){
            if isAttached {
                self.attachedLabel.text = "ATTACHED"
                self.attachedLabel.backgroundColor = UIColor(red: 0, green: 170 / 255.0, blue: 78 / 255.0, alpha: 1)
            }
            else {
                self.attachedLabel.text = "DETACHED"
                self.attachedLabel.backgroundColor = UIColor(red: 170 / 255.0, green: 170 / 255.0, blue: 170 / 255.0, alpha: 1.0)
            }
        }
    }
    var connectedLabelState: Bool = false
    
    /*override func viewWillAppear(animated: Bool) {
        print("OK1")
        super.viewWillAppear(animated)
        //self.svRoot.contentSize = self.vvRoot.frame.size
        //register enter background notif (only available on iOS 4)
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "applicationDidEnterBackground", name: "UIApplicationDidEnterBackgroundNotification", object: nil)
        print("OK2")
        //keyboard
        //self.registerForKeyboardNotifications(TRUE)
        //init alert views
        //prompt_connecting = UIAlertView(title: "UniMag", message: "Connecting with UniMag.", cancelButtonTitle: "Cancel", otherButtonTitles: "")
        //prompt_waitingForSwipe = UIAlertView(title: "UniMag", message: "\n\n", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "")
        //reset ui state
        self.attachedLabelState = false
        self.connectedLabelState = false
        self.btnConnect.enabled = false
        self.btnSwipe.enabled = false
        print("OK3")
        //activate SDK
        uniMagViewController.umsdk_activate()
        //patch UI bug
        print("OK4")
        //uniMagViewController.subvcThatNeedsViewWillAppearEvent.viewWillAppear(animated)
        print("OK6")
        uniMagViewController.connectReader()
        print("OK5")
    }*/
    
    func displayUmRet(operation: String, returnValue ret: UmRet) {
        var s: String
        repeat {
            switch ret {
            case UMRET_SUCCESS:
                s = ""
            case UMRET_NO_READER:
                s = "No reader attached"
            case UMRET_SDK_BUSY:
                s = "Communication with reader in progress"
            case UMRET_MONO_AUDIO:
                s = "Mono audio enabled"
            case UMRET_ALREADY_CONNECTED:
                s = "Already connected"
            case UMRET_LOW_VOLUME:
                s = "Low volume"
            case UMRET_NOT_CONNECTED:
                s = "Not connected"
            case UMRET_NOT_APPLICABLE:
                s = "Not applicable to reader type"
            case UMRET_INVALID_ARG:
                s = "Invalid argument"
            case UMRET_UF_INVALID_STR:
                s = "Invalid firmware update string"
            case UMRET_UF_NO_FILE:
                s = "Firmware file not found"
            case UMRET_UF_INVALID_FILE:
                s = "Invalid firmware file"
            default:
                s = "<unknown code>"
            }
            
        } while false
        self.textResponse.text = "\(operation) \(UMRET_SUCCESS == ret ? "..." : "failed:")\n\(s)"
        self.hexResponse.text = ""
    }
    
    func umDevice_attachment(notification: NSNotification) {
        self.attachedLabelState = true
        //self.btnConnect.enabled = true
        //self.dismissAllAlertViews()
        self.textResponse.text = ""
        self.hexResponse.text = ""
        self.connectReader()
    }
    
    @IBAction func connectReader() {
        //UmRet ret = [uniReader startUniMag:TRUE];
        uniMagViewController.umsdk_activate()
        uniMagViewController.connectReader()
        //uniReader.startUniMag(true)
    }
    
    @IBAction func swipeCard() {
        //start the swipe task. ie, cause SDK to start waiting for a swipe to be made
        //UmRet ret = [uniReader requestSwipe];
        //uniReader.requestSwipe()
        //[self displayUmRet: @"Starting read swipe" returnValue: ret];
    }
    
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwipeController.uniMagConnected(_:)), name: uniMagDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwipeController.swipeReceived(_:)), name: uniMagDidReceiveDataNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwipeController.uniMagDisconnected(_:)), name: uniMagDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwipeController.uniMagPowering(_:)), name: uniMagPoweringNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwipeController.uniMagTimeout(_:)), name: uniMagTimeoutNotification, object: nil)

        
        uniMagViewController.umsdk_activate()
        uniMagViewController.connectReader()
        alertController.addAction(okAction)
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        //super.didReceiveMemoryWarning()
    }
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    @IBAction func readerTapped(sender: UIButton) {
        //uniMagViewController.startUniMag(true)
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        uniMagViewController.swipeCard()
    }
    
    func uniMagPowering(notification: NSNotification) {
        alertController.message = "Powering up..."
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func uniMagConnected(notification: NSNotification) {
        self.alertController.dismissViewControllerAnimated(true, completion: nil)
        print("CONNECTED")
        //self.btnSwipe.enabled = true
        //self.attachedLabel.text = "ATTACHED"
        //self.attachedLabel.backgroundColor = UIColor(red: 0, green: 170 / 255.0, blue: 78 / 255.0, alpha: 1)
        uniMagViewController.swipeCard()
    }
    
    func uniMagDisconnected(notification: NSNotification) {
        print("DISCONNECTED")
        //self.btnSwipe.enabled = false
        //self.attachedLabel.text = "DETACHED"
        //self.attachedLabel.backgroundColor = UIColor(red: 170 / 255.0, green: 170 / 255.0, blue: 170 / 255.0, alpha: 1.0)
    }
    
    func uniMagTimeout(notification: NSNotification) {
        self.alertController.dismissViewControllerAnimated(true, completion: nil)
        alertController.message = "The last operation timed out."
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func swipeReceived(notification: NSNotification) {
        alertController.title = "Swipe"
        let data = notification.object as! NSData
        // parse and do stuff with the swipe information
        //uniMagViewController.swipeCard()
        let cd: UMCardData = UMCardData(bytes: data)
        let msg: NSMutableString = ""
        msg.appendFormat("%@\n", (cd.isValid ? "+++++++VALID+++++++" : "xxxxxxxINVALIDxxxxxxx"))
        if cd.track1 == nil || cd.track1_encrypted == nil || cd.KSN == nil {
            print("Invalid swipe. Please try again.")
            alertController.message = "Invalid swipe. Please try again."
            self.presentViewController(alertController, animated: true, completion: nil)
            uniMagViewController.swipeCard()
            return
        }
        //append plain text tracks
        if cd.isValid && cd.isEncrypted {
            track1String = String(data: cd.track1, encoding: NSUTF8StringEncoding)!
            track1EncString = cd.track1_encrypted.hexString
            KSN = cd.KSN.hexString
        }
        if false == cd.isEncrypted {
            let str = String(data: cd.byteData, encoding: NSUTF8StringEncoding)
            msg.appendFormat("%@", str!)
            
            self.textResponse.text = msg as String
            self.hexResponse.text = data.description
            uniMagViewController.swipeCard()
            return
        }
        //append KSN
        if (cd.KSN != nil) {
            msg.appendFormat("KSN: %@\n", cd.KSN.description)
        }
        
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
        let customerInformation: [String: String] = ["FirstName": "FSDGSDFG",
                                                     "LastName": "DSFSDF",
                                                     "Street": addr1.text!,
                                                     "Street2" : addr2.text!,
                                                     "City": city.text!,
                                                     "State": state.text!,
                                                     "ZIP": zip.text!,
                                                     "Country": "US",
                                                     "Phone": "",
                                                     "Email": "",
                                                     "EncryptedTrack1" : track1EncString.uppercaseString,
                                                      "Track1Length"  : String(track1String.characters.count),
                                                       "KSN" : KSN,
                                                     "Amount": transAmount]
        let bluepay: BluePay = BluePay(transactionType: transType)
        // Pass transaction data to BluePayRequest, then do POST to the BluePay gateway
        BluePayRequest.Post(bluepaySetup: bluepay.getBluePaySetup() as! [String : String], customer: customerInformation) { (succeeded: Bool, msg: String) in
            // Get transaction response from the BluePay gateway
            let response: NSMutableDictionary = BluePayResponse.ParseResponse(msg)
            if BluePayResponse.isApproved(response) {
                print("The transaction was processed and approved.\nTransaction ID: ", (response["TRANS_ID"] as! String))
                self.alertController.message = "The transaction was processed and approved.\nTransaction ID:\(response["TRANS_ID"] as! String)"
            } else if BluePayResponse.isDeclined(response) {
                print("The transaction has been declined.")
                self.alertController.message = "The transaction has been declined."
                // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
            } else {
                print("There was an error when processing the payment. Reason: ", (response["MESSAGE"] as! String))
                self.alertController.message = "There was an error when processing the payment. Reason: \(response["MESSAGE"] as! String)"
            }
            
            //alertController.modalPresentationStyle = UIModalPresentationPopover
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(self.alertController, animated: true, completion: nil)
            })
        }
        // This readies the UniMag device for another swipe
        uniMagViewController.swipeCard()
    }
    
    func umSwipe_invalid(notification: NSNotification) {
        print("Failed to read a valid swipe. Please try again.")
        self.textResponse.text = "Failed to read a valid swipe. Please try again."
        self.hexResponse.text = ""
    }
    
}