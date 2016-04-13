/*
This example app shows how to set up a project to use the UniMag SDK

================================================================================
Project setup:
- Add UniMag static library and header (IDTECH_UniMag.a, uniMag.h) to project
- Add AVFoundation, AudioToolbox, MediaPlayer framework to project

================================================================================
SDK initialization:
- Register NSNotification observers for all notifications listed in the uniMag class header
- Instantiate an uniMag object ie. [[uniMag alloc] init], this makes the SDK active.
- After that the SDK will start firing notifications, for example,
  uniMagAttachmentNotification

================================================================================
Reading card swipe:
- SDK's state must be `connected` before it will read swipes. See the below 
  section titled 'Connecting with reader'
- Call [uniReader requestSwipe] to make the SDK begin waiting for a swipe. When a
  swipe is made, a uniMagDidReceiveDataNotification with the card data will be fired
- To stop the SDK waiting before a swipe is made, call [uniReader cancelTask]

================================================================================
Connecting with reader:
- SDK's state changes to `connected` after it has successfully performed 
  a `connection` task with the UniMag device
- To start the connection task, call [uniReader startUniMag:TRUE]. When it is
  successfully finished, uniMagDidConnectNotification will fire, and 
  [uniReader getConnectionStatus] will become TRUE


For more information, please refer to the SDK manual.
*/

import UIKit
class UniMagViewController: UIViewController, UITabBarDelegate {
    var uniReader: uniMag

    //Exposed
    var uniReader: uniMag {
        get {
            return self.uniReader
        }
    }


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

        } while 0
        self.textResponse.text = "\(operation) \(UMRET_SUCCESS == ret ? "..." : "failed:")\n\(s)"
        self.hexResponse.text = ""
    }

    func tabBarInit() {
        //select first tab
        self.tabBar.selectedItem = self.tabList_tbi[0]
        self.tabBar(self.tabBar, didSelectItem: self.tabBar.selectedItem)
    }
    //Actions

    @IBAction func connectReader() {
        //UmRet ret = [uniReader startUniMag:TRUE];
        uniReader.startUniMag(TRUE)
        //[self displayUmRet: @"Starting connection" returnValue: ret];
        self.connectionStartTime = NSDate()
    }

    @IBAction func swipeCard() {
        //start the swipe task. ie, cause SDK to start waiting for a swipe to be made
        //UmRet ret = [uniReader requestSwipe];
        uniReader.requestSwipe()
        //[self displayUmRet: @"Starting read swipe" returnValue: ret];
    }
    //Outlets
    // root
    @IBOutlet var svRoot: UIScrollView!
    @IBOutlet var vvRoot: UIView!
    // header view
    @IBOutlet var vHeader: UIView!
    @IBOutlet var textResponse: UITextView!
    @IBOutlet var hexResponse: UITextView!
    // reader tab
    @IBOutlet var subvcThatNeedsViewWillAppearEvent: UIViewController!
    @IBOutlet var attachedLabel: UILabel!
    @IBOutlet var connectedLabel: UILabel!
    @IBOutlet var btnConnect: UIButton!
    // swipe tab
    @IBOutlet var btnSwipe: UIButton!
    // send command tab
    @IBOutlet var btnSendCommand: UIButton!
    // help tab
    // tab bar
    @IBOutlet var tabBar: UITabBar! {
        get {
            //nav bar title
            self.navigationItem.title = item.title
            //clear vvRoot subviews
            for sub: UIView in self.vvRoot.subviews {
                sub.removeFromSuperview()
            }
                //get index and corresponding view
            var tabIndex: Int = self.tabList_tbi.indexOfObject(item)
            var vc: UIViewController = self.tabList_vc[tabIndex]
            var v: UIView = vc.view!
            //do special layout if selected help tab (the last tab)
            if tabIndex == self.tabList_tbi.count - 1 {
                    //adjust width
                var rectHelp: CGRect = v.frame
                rectHelp.size.width = self.vvRoot.frame.size.width
                v.frame = rectHelp
                    //add help tab wrapped in a scroll view
                var scrollView: UIScrollView = UIScrollView(frame: self.vvRoot.bounds)
                scrollView.addSubview(v)
                scrollView.contentSize = v.frame.size
                self.vvRoot.addSubview(scrollView)
            }
            else {
                    //height of vHeader is vvRoot height minus v height
                var vHeaderHeight: CGFloat = self.vvRoot.frame.size.height - v.frame.size.height
                    //add header, at top inside vvRoot. Resize height
                var rectH: CGRect = self.vHeader.frame
                rectH.size.height = vHeaderHeight
                self.vHeader.frame = rectH
                self.vvRoot.addSubview(self.vHeader)
                    //add v, place at bottom inside vvRoot. No resize height
                var rectV: CGRect = v.frame
                rectV.origin.y = vHeaderHeight
                rectV.size.width = self.vvRoot.frame.size.width
                v.frame = rectV
                self.vvRoot.addSubview(v)
            }
        }
    }

    // these two parallel arrays are used to map between tab bar button and the corresponding view controller
    @IBOutlet var tabList_tbi: [UITabBarItem]!
    @IBOutlet var tabList_vc: [UIViewController]!
    @IBOutlet weak var addr1: UITextField!
    @IBOutlet weak var addr2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var amount: UITextField!

    var ksnString: String
    var track1EncryptedString: String
    var track1String: String
        //get C source code representation of a byte string
    var repr: String
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.svRoot.contentSize = self.vvRoot.frame.size
            //register enter background notif (only available on iOS 4)
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "applicationDidEnterBackground", name: "UIApplicationDidEnterBackgroundNotification", object: nil)
        //keyboard
        self.registerForKeyboardNotifications(TRUE)
        //init alert views
        prompt_connecting = UIAlertView(title: "UniMag", message: "Connecting with UniMag.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "")
        prompt_waitingForSwipe = UIAlertView(title: "UniMag", message: "\n\n", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "")
        //reset ui state
        self.attachedLabelState = FALSE
        self.connectedLabelState = FALSE
        self.btnConnect.enabled = FALSE
        self.btnSendCommand.enabled = FALSE
        self.btnSwipe.enabled = FALSE
        //activate SDK
        self.umsdk_activate()
        //patch UI bug
        self.subvcThatNeedsViewWillAppearEvent.viewWillAppear(animated)
        self.connectReader()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
            //unregister enter background notif (iOS 4+)
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: "UIApplicationDidEnterBackgroundNotification", object: nil)
        //keyboard
        self.registerForKeyboardNotifications(FALSE)
        //deallocate alert views
        //[prompt_connecting release];
        prompt_connecting = nil
        //[prompt_waitingForSwipe release];
        prompt_waitingForSwipe = nil
        //deactivate SDK
        self.umsdk_deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //set up nav bar buttons
        //tab bar
        self.tabBarInit()
    }

    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
    }

    func viewDidUnload() {
        self.vvRoot = nil
        self.tabBar = nil
        self.attachedLabel = nil
        self.btnSwipe = nil
        self.vHeader = nil
        self.btnConnect = nil
        self.btnSendCommand = nil
        self.tabList_tbi = nil
        self.tabList_vc = nil
        self.svRoot = nil
        super.viewDidUnload()
    }

    func applicationDidEnterBackground() {
        //leave main screen (deactivate sdk at the same time)
        self.dismissAllAlertViews()
        self.navigationController!.popToRootViewControllerAnimated(false)
        //stop any running task
        self.dismissAllAlertViews()
        uniReader.cancelTask()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
    - (void)dealloc
    {
    	[_connectedLabel release];
    	[_textResponse release];
    	[_hexResponse release];
        
        [_connectionStartTime release];
        [_swipeStartTime release];
    
        [_vvRoot release];
        [_tabBar release];
        [_attachedLabel release];
        [_btnSwipe release];
        [_vHeader release];
        [_btnConnect release];
        [_btnSendCommand release];
        [_tabList_tbi release];
        [_tabList_vc release];
        [_svRoot release];
        [super dealloc];
    }
    */
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView == prompt_connecting {
            //selected cancel connection at the connecting prompt.
            // This aborts the connect task
            if 0 == buttonIndex {
                uniReader.cancelTask()
            }
        }
        else if alertView == prompt_waitingForSwipe {
            //selected cancel swipe at the swipe waiting prompt. 
            // This aborts the swipe task
            if 0 == buttonIndex {
                uniReader.cancelTask()
                self.textResponse.text = "Reading swipe canceled"
            }
        }

    }
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    func umsdk_registerObservers(reg: Bool) {
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        if nil == s_noteAndSel_t {
            s_noteAndSel_t = [AnyObject]()
                //NSAutoreleasePool* pool=[[NSAutoreleasePool alloc] init];
            var cd01: noteAndSel_t = noteAndSel_t()
            var cd02: noteAndSel_t = noteAndSel_t()
            var cd03: noteAndSel_t = noteAndSel_t()
            var cd04: noteAndSel_t = noteAndSel_t()
            var cd05: noteAndSel_t = noteAndSel_t()
            var cd06: noteAndSel_t = noteAndSel_t()
            var cd07: noteAndSel_t = noteAndSel_t()
            var cd08: noteAndSel_t = noteAndSel_t()
            var cd09: noteAndSel_t = noteAndSel_t()
            var cd10: noteAndSel_t = noteAndSel_t()
            var cd11: noteAndSel_t = noteAndSel_t()
            var cd12: noteAndSel_t = noteAndSel_t()
            var cd13: noteAndSel_t = noteAndSel_t()
            var cd14: noteAndSel_t = noteAndSel_t()
            var cd15: noteAndSel_t = noteAndSel_t()
            var cd16: noteAndSel_t = noteAndSel_t()
            var cd17: noteAndSel_t = noteAndSel_t()
            cd01.setV(uniMagAttachmentNotification, umDevice_attachment)
            cd02.setV(uniMagDetachmentNotification, umDevice_detachment)
            cd03.setV(uniMagInsufficientPowerNotification, umConnection_lowVolume)
            cd04.setV(uniMagMonoAudioErrorNotification, umConnection_monoAudioError)
            cd05.setV(uniMagPoweringNotification, umConnection_starting)
            cd06.setV(uniMagTimeoutNotification, umConnection_timeout)
            cd07.setV(uniMagDidConnectNotification, umConnection_connected)
            cd08.setV(uniMagDidDisconnectNotification, umConnection_disconnected)
            cd09.setV(uniMagSwipeNotification, mSwipe_starting)
            cd10.setV(uniMagTimeoutSwipeNotification, umSwipe_timeout)
            cd11.setV(uniMagDataProcessingNotification, umDataProcessing)
            cd12.setV(uniMagInvalidSwipeNotification, umSwipe_invalid)
            cd13.setV(uniMagDidReceiveDataNotification, umSwipe_receivedSwipe)
            cd14.setV(uniMagCmdSendingNotification, umCommand_starting)
            cd15.setV(uniMagCommandTimeoutNotification, umCommand_timeout)
            cd16.setV(uniMagDidReceiveCmdNotification, umCommand_receivedResponse)
            cd17.setV(uniMagSystemMessageNotification, umSystemMessage)
            s_noteAndSel_t.append(cd01)
            s_noteAndSel_t.append(cd02)
            s_noteAndSel_t.append(cd03)
            s_noteAndSel_t.append(cd04)
            s_noteAndSel_t.append(cd05)
            s_noteAndSel_t.append(cd06)
            s_noteAndSel_t.append(cd07)
            s_noteAndSel_t.append(cd08)
            s_noteAndSel_t.append(cd09)
            s_noteAndSel_t.append(cd10)
            s_noteAndSel_t.append(cd11)
            s_noteAndSel_t.append(cd12)
            s_noteAndSel_t.append(cd13)
            s_noteAndSel_t.append(cd14)
            s_noteAndSel_t.append(cd15)
            s_noteAndSel_t.append(cd16)
            s_noteAndSel_t.append(cd17)
            //[pool drain];
        }
            /*
                //list of notifications and their corresponding selector
                const struct {NSString *n; SEL s;} noteAndSel[] = {
                    //
                    {uniMagAttachmentNotification       , @selector(umDevice_attachment:)},
                    {uniMagDetachmentNotification       , @selector(umDevice_detachment:)},
                    //
                    {uniMagInsufficientPowerNotification, @selector(umConnection_lowVolume:)},
                    {uniMagMonoAudioErrorNotification   , @selector(umConnection_monoAudioError:)},
                    {uniMagPoweringNotification         , @selector(umConnection_starting:)},
                    {uniMagTimeoutNotification          , @selector(umConnection_timeout:)},
                    {uniMagDidConnectNotification       , @selector(umConnection_connected:)},
                    {uniMagDidDisconnectNotification    , @selector(umConnection_disconnected:)},
                    //
                    {uniMagSwipeNotification            , @selector(umSwipe_starting:)},
                    {uniMagTimeoutSwipeNotification     , @selector(umSwipe_timeout:)},
                    {uniMagDataProcessingNotification   , @selector(umDataProcessing:)},
                    {uniMagInvalidSwipeNotification     , @selector(umSwipe_invalid:)},
                    {uniMagDidReceiveDataNotification   , @selector(umSwipe_receivedSwipe:)},
                    //
                    {uniMagCmdSendingNotification       , @selector(umCommand_starting:)},
                    {uniMagCommandTimeoutNotification   , @selector(umCommand_timeout:)},
                    {uniMagDidReceiveCmdNotification    , @selector(umCommand_receivedResponse:)},
                    //
                    {uniMagSystemMessageNotification    , @selector(umSystemMessage:)},
                    
                    {nil, nil},
                };
                */
        var len: Int = Int(s_noteAndSel_t.count)
        //register or unregister
        for var i = 0; i < len; i++ {
            var cd: noteAndSel_t = (s_noteAndSel_t[i] as! noteAndSel_t)
            if reg {
                nc.addObserver(self, selector: cd.s, name: cd.n, object: nil)
            }
            else {
                nc.removeObserver(self, name: cd.n, object: nil)
            }
        }
    }

    override func umsdk_activate() {
        //register observers for all uniMag notifications
        self.umsdk_registerObservers(TRUE)
        //enable info level NSLogs inside SDK
        // Here we turn on before initializing SDK object so the act of initializing is logged
        uniMag.enableLogging(TRUE)
        //initialize the SDK by creating a uniMag class object
        uniReader = uniMag()
        /*
            //Set the reader type. The default is UniMag Pro.
            uniReader.readerType = ?;
            */
        /*
            //set SDK to perform the connect task automatically when headset is attached
            [uniReader setAutoConnect:TRUE]; 
        	*/
        //set swipe timeout to infinite. By default, swipe task will timeout after 20 seconds
        uniReader.swipeTimeoutDuration = 0
        //make SDK maximize the volume automatically during connection
        uniReader.autoAdjustVolume = TRUE
        //By default, the diagnostic wave file logged by the SDK is stored under the temp directory
        // Here it is set to be under the Documents folder in the app sandbox so the log can be accessed
        // through iTunes file sharing. See UIFileSharingEnabled in iOS doc.
        //[uniReader setWavePath: [NSHomeDirectory() stringByAppendingPathComponent: @"/Documents/audio.wav"]];
    }

    func umsdk_deactivate() {
        //deallocating the uniMag object deactivates the uniMag SDK
        //[uniReader release];
        uniReader = nil
        //it is the responsibility of SDK client to unregister itself as notification observer
        self.umsdk_registerObservers(FALSE)
    }
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    //called when uniMag is physically attached

    func umDevice_attachment(notification: NSNotification) {
        self.attachedLabelState = TRUE
        self.btnConnect.enabled = TRUE
        self.btnSendCommand.enabled = TRUE
        self.dismissAllAlertViews()
        self.textResponse.text = ""
        self.hexResponse.text = ""
        self.connectReader()
    }
    //called when uniMag is physically detached

    func umDevice_detachment(notification: NSNotification) {
        self.attachedLabelState = FALSE
        self.btnConnect.enabled = FALSE
        self.btnSendCommand.enabled = FALSE
        self.dismissAllAlertViews()
    }
    //called when attempting to start the connection task but iDevice's headphone playback volume is too low

    func umConnection_lowVolume(notification: NSNotification) {
        self.showAlertView("Volume too low. Please maximize volume then re-attach UniMag.")
    }
    //called when attempting to start a task but iDevice's mono audio accessibility
    // feature is enabled

    func umConnection_monoAudioError(notification: NSNotification) {
        self.showAlertView("Mono audio setting is enabled. Please disable it from iOS's Settings app.")
    }
    //called when successfully starting the connection task

    func umConnection_starting(notification: NSNotification) {
        prompt_connecting.show()
    }
    //called when SDK failed to handshake with reader in time. ie, the connection task has timed out

    func umConnection_timeout(notification: NSNotification) {
        //self.textResponse.text = [NSString stringWithFormat: @"Connection timedout in %.2fs", -self.connectionStartTime.timeIntervalSinceNow];
        self.connectionStartTime = nil
        self.hexResponse.text = ""
        self.showAlertView("Connecting with UniMag timed out. Please try again.")
    }
    //called when the connection task is successful. SDK's connection state changes to true

    func umConnection_connected(notification: NSNotification) {
        self.btnSwipe.enabled = TRUE
        self.dismissAllAlertViews()
        //self.textResponse.text = [NSString stringWithFormat: @"Connected in %.2fs", -self.connectionStartTime.timeIntervalSinceNow];
        self.connectionStartTime = nil
        self.hexResponse.text = ""
        self.connectedLabelState = TRUE
        //go to the swipe card page
        self.tabBar.selectedItem = self.tabList_tbi[1]
        self.tabBar(self.tabBar, didSelectItem: self.tabBar.selectedItem)
        self.swipeCard()
    }
    //called when SDK's connection state changes to false. This happens when reader becomes 
    // physically detached or when a disconnect API is called

    func umConnection_disconnected(notification: NSNotification) {
        self.dismissAllAlertViews()
        self.btnSwipe.enabled = FALSE
        self.connectedLabelState = FALSE
    }
    //called when the swipe task is successfully starting, meaning the SDK starts to 
    // wait for a swipe to be made

    func umSwipe_starting(notification: NSNotification) {
        prompt_waitingForSwipe.message = "Waiting for card swipe..."
        prompt_waitingForSwipe.show()
        return
    }
    //called when the SDK hasn't received a swipe from the device within a configured
    // "swipe timeout interval".

    func umSwipe_timeout(notification: NSNotification) {
        self.showAlertView("Waiting for swipe timed out. Please try again.")
    }
    //called when the SDK has read something from the uniMag device 
    // (eg a swipe, a response to a command) and is in the process of decoding it
    // Use this to provide an early feedback on the UI 

    func umDataProcessing(notification: NSNotification) {
        self.textResponse.text = "data processing..."
        self.hexResponse.text = ""
    }
    //called when SDK failed to read a valid card swipe

    func umSwipe_invalid(notification: NSNotification) {
        self.showAlertView("Failed to read a valid swipe. Please try again.")
        self.textResponse.text = ""
        self.hexResponse.text = ""
    }
    //called when SDK received a swipe successfully

    func umSwipe_receivedSwipe(notification: NSNotification) {
        self.dismissAllAlertViews()
        var data: NSData = notification.object
        var cd: UMCardData = UMCardData(bytes: data)
            //append general info
        var msg: NSMutableString = NSMutableString.string()
        msg.appendFormat("%@\n", (cd.isValid ? "+++++++VALID+++++++" : "xxxxxxxINVALIDxxxxxxx"))
        if false == cd.isEncrypted {
            msg.appendFormat("%@", repr(cd.byteData))
            self.textResponse.text = msg
            self.hexResponse.text = data.description
            return
        }
            //append plain text tracks
        var tracks: NSData = NSData()
            tracks.cd.track1
            tracks.cd.track2
            tracks.cd.track3
        for var i = 0; i < 3; i++ {
            if !tracks[i] {

            }
            msg.appendFormat("Track %i:\n%@\n", i + 1, repr(tracks[i]))
        }
        //append encrypted tracks
        if cd.isValid && cd.isEncrypted {
            var tracks_enc: NSData = NSData()
                tracks_enc.cd.track1_encrypted
                tracks_enc.cd.track2_encrypted
                tracks_enc.cd.track3_encrypted
            for var i = 0; i < 3; i++ {
                if !tracks_enc[i] {

                }
                msg.appendFormat("Encrypted Track %i:\n%@\n", i + 1, tracks_enc[i].description)
            }
        }
        //append serial number
        if cd.serialNumber {
            msg.appendFormat("Serial number: %@\n", cd.serialNumber.description)
        }
        //append KSN
        if cd.KSN {
            msg.appendFormat("KSN: %@\n", cd.KSN.description)
        }
        track1EncryptedString = cd.track1_encrypted.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        track1String = repr(tracks[0]).description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        ksnString = cd.KSN.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        var alertController: UIAlertController = UIAlertController.alertControllerWithTitle("Swipe Result", message: "", preferredStyle: .Alert)
        var okAction: UIAlertAction = UIAlertAction.actionWithTitle("OK", style: .Default, handler: {(action: UIAlertAction) -> Void in
                // optional: clear all fields
            })
        if track1EncryptedString == nil || track1String == nil {
            alertController.message = "Invalid swipe. Please try swiping the card again."
            alertController.modalPresentationStyle = UIModalPresentationPopover
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: { _ in })
            return
        }
        self.textResponse.text = msg
        self.hexResponse.text = data.description
        var transAmount: String = ""
        var transType: String = "SALE"
        // If the amount has been set, use the user-inputted value. Else, set amount to $0.00 and trans type to AUTH
        if amount.tag == 1 {
            transAmount = amount.text!
        }
        else {
            transAmount = "0.00"
            transType = "AUTH"
        }
        var names: [AnyObject] = track1String.componentsSeparatedByString("^")
        var firstAndLastName: [AnyObject] = names[1].componentsSeparatedByString("/")
        var bluepaySetup: [NSObject : AnyObject] = ["AccountID": "100013391447", "SecretKey": "5YRFNRBCZN/6Y4OPZNWPYDRNAVX7BMMD", "TransMode": "TEST", "TransType": transType]
        var customerInformation: [NSObject : AnyObject] = ["FirstName": firstAndLastName[1], "LastName": firstAndLastName[0], "Street": addr1.text, "City": city.text, "State": state.text, "ZIP": zip.text, "Country": "US", "Phone": "", "Email": "", "Amount": transAmount, "EncryptedTrack1": track1EncryptedString, "Track1Length": Int(track1String.characters.count), "KSN": ksnString]
        var jsonError: NSError
        var paymentData: NSData = NSJSONSerialization.dataWithJSONObject(customerInformation, options: 0, error: jsonError)
        if jsonError != nil {
            // check the error description
            NSLog("json error : %@", jsonError.localizedDescription())
        }
        else {
            //NSLog(paymentData);
            // use the jsonDictionaryOrArray
        }
        var bluepay: BluePay = BluePay.initSetup(bluepaySetup)
            // Pass transaction data to BluePayRequest, then do POST to the BluePay gateway
        var results: String = BluePayRequest.Post(paymentData, bluepaySetup: bluepay.getBluePaySetup(), customer: customerInformation)
            // Get transaction response from the BluePay gateway
        var response: [NSObject : AnyObject] = BluePayResponse.ParseResponse(results)
        if BluePayResponse.isApproved(response) {
            NSLog("The transaction was processed and approved.\nTransaction ID:%@", (response["TRANS_ID"] as! String))
            alertController.message = "The transaction was processed and approved.\nTransaction ID:\(response["TRANS_ID"] as! String)"
        }
        else if BluePayResponse.isDeclined(response) {
            NSLog("The transaction has been declined.")
            alertController.message = "The transaction has been declined."
            // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
        }
        else {
            NSLog("There was an error when processing the payment. Reason: %@", (response["MESSAGE"] as! String))
            alertController.message = "There was an error when processing the payment. Reason: \(response["MESSAGE"] as! String)"
        }

        alertController.modalPresentationStyle = UIModalPresentationPopover
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: { _ in })
    }
    //called when SDK successfully starts to send a command. SDK starts the command
    // task

    func umCommand_starting(notification: NSNotification) {
    }
    //called when SDK failed to receive a command response within a configured
    // "command timeout interval"

    func umCommand_timeout(notification: NSNotification) {
        self.showAlertView("Waiting for command response timed out. Please try again.")
        self.textResponse.text = "command timed out"
    }
    //called when SDK successfully received a response to a command

    func umCommand_receivedResponse(notification: NSNotification) {
        var data: NSData = notification.object
        self.textResponse.text = repr(data)
        self.hexResponse.text = data.description
    }
    //this is a observer for a generic and extensible notification. It's currently only used during firmware update

    func umSystemMessage(notification: NSNotification) {
        var err: NSError? = nil
        err = notification.object
        self.textResponse.text = "\(Int(err!.code)): \(err!.userInfo[NSLocalizedDescriptionKey])"
        self.hexResponse.text = ""
    }
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    func dismissAllAlertViews() {
        prompt_connecting.dismissWithClickedButtonIndex(-1, animated: FALSE)
        prompt_waitingForSwipe.dismissWithClickedButtonIndex(-1, animated: FALSE)
    }

    func showAlertView(msg: String) {
        self.dismissAllAlertViews()
        var alertView: UIAlertView = UIAlertView(title: "UniMag", message: msg, delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
        alertView.show()
        //[alertView release];
    }

    func setConnectedLabelState(isConnected: Bool) {
        if isConnected {
            self.connectedLabel.text = "CONNECTED"
            self.connectedLabel.backgroundColor = UIColor(red: 0, green: 170 / 255.0, blue: 78 / 255.0, alpha: 1)
        }
        else {
            self.connectedLabel.text = "DISCONNECTED"
            self.connectedLabel.backgroundColor = UIColor(red: 170 / 255.0, green: 170 / 255.0, blue: 170 / 255.0, alpha: 1.0)
        }
    }

    func setAttachedLabelState(isAttached: Bool) {
        if isAttached {
            self.attachedLabel.text = "ATTACHED"
            self.attachedLabel.backgroundColor = UIColor(red: 0, green: 170 / 255.0, blue: 78 / 255.0, alpha: 1)
        }
        else {
            self.attachedLabel.text = "DETACHED"
            self.attachedLabel.backgroundColor = UIColor(red: 170 / 255.0, green: 170 / 255.0, blue: 170 / 255.0, alpha: 1.0)
        }
    }
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    func registerForKeyboardNotifications(reg: Bool) {
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        var n1: String = UIKeyboardWillShowNotification
        var n2: String = UIKeyboardWillHideNotification
        if reg {
            nc.addObserver(self, selector: "keyboardWillShow:", name: n1, object: nil)
            nc.addObserver(self, selector: "keyboardWillBeHidden:", name: n2, object: nil)
        }
        else {
            nc.removeObserver(self, name: n1, object: nil)
            nc.removeObserver(self, name: n2, object: nil)
        }
    }

    func keyboardWillShow(aNotification: NSNotification) {
        var info: [NSObject : AnyObject] = aNotification.userInfo
        var kbH: CGFloat = (info[UIKeyboardFrameBeginUserInfoKey] as! CGFloat).CGRectValue.size.height
        var tabBarH: CGFloat = self.tabBar.frame.size.height
        var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbH - tabBarH, 0.0)
        self.svRoot.contentInset = contentInsets
        self.svRoot.scrollIndicatorInsets = contentInsets
            //scroll content into view
        var rVisible: CGRect = CGRectMake(0, self.vvRoot.frame.size.height, 1, 1)
        self.svRoot.scrollRectToVisible(rVisible, animated: true)
    }

    func keyboardWillBeHidden(aNotification: NSNotification) {
        self.svRoot.contentInset = UIEdgeInsetsZero
        self.svRoot.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    var prompt_connecting: UIAlertView
    var prompt_waitingForSwipe: UIAlertView


    var connectionStartTime: NSDate
    var swipeStartTime: NSDate
}
class noteAndSel_t: NSObject {

    var n: String
    var s: Selector

    func setV(nn: String, ss: Selector) {
        self.n = nn
        self.s = ss
    }

    convenience override init() {
        self.init()
        self.n = ""
            self.s = nil
    }
}
var s_noteAndSel_t: [AnyObject]? = nil

func repr(_: byteArray) -> String {
    var ret: NSMutableString = NSMutableString.string()
            let len: Int = Int(byteArray.length)
        let bytes: Byte = byteArray.bytes
        var chr: String? = nil
        var oneCharStr: Character = Character()
            oneCharStr.0
            oneCharStr.0
        for var i = 0; i < len; i++ {
            //special escaped char
            if bytes[i] == "\t" {
                chr = "\\t"
            }
            else if bytes[i] == "\n" {
                chr = "\\n"
            }
            else if bytes[i] == "\r" {
                chr = "\\r"
            }
            else if bytes[i] == "\\" {
                chr = "\\"
            }
            else if bytes[i] >= 0x20 && bytes[i] <= 0x7E {
                oneCharStr[0] = bytes[i]
                chr = String.stringWithCString(oneCharStr, encoding: NSASCIIStringEncoding)
            }
            else {
                chr = String(format: "\\x%02x", bytes[i])
            }

            //
            ret.appendString(chr!)
        }

    return ret
}