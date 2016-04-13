/* Copyright 2010-2014 ID TECH. All rights reserved.
*/
import Foundation
//Versioning
let UMSDK_VERSION = "7.16"
let UMSDK_CUSTOMIZATION = 0
//Notification identifiers used with NSNotificationCenter
//physical attachment related
let uniMagAttachmentNotification = "uniMagAttachmentNotification"
let uniMagDetachmentNotification = "uniMagDetachmentNotification"
//connection related
let uniMagInsufficientPowerNotification = "uniMagInsufficientPowerNotification"
let uniMagMonoAudioErrorNotification = "uniMagMonoAudioErrorNotification"
let uniMagPoweringNotification = "uniMagPoweringNotification"
let uniMagTimeoutNotification = "uniMagTimeoutNotification"
let uniMagDidConnectNotification = "uniMagDidConnectNotification"
let uniMagDidDisconnectNotification = "uniMagDidDisconnectNotification"
//swipe related
let uniMagSwipeNotification = "uniMagSwipeNotification"
let uniMagTimeoutSwipeNotification = "uniMagTimeoutSwipe"
let uniMagDataProcessingNotification = "uniMagDataProcessingNotification"
let uniMagInvalidSwipeNotification = "uniMagInvalidSwipeNotification"
let uniMagDidReceiveDataNotification = "uniMagDidReceiveDataNotification"
//command related
let uniMagCmdSendingNotification = "uniMagCmdSendingNotification"
let uniMagCommandTimeoutNotification = "uniMagCommandTimeout"
let uniMagDidReceiveCmdNotification = "uniMagDidReceiveCmdNotification"
//misc
let uniMagSystemMessageNotification = "uniMagSystemMessageNotification"
//Reader types
enum UmReader : Int {
    case UMREADER_UNKNOWN
    case UMREADER_UNIMAG_ORIGINAL
    case UMREADER_UNIMAG_PRO
    case UMREADER_UNIMAG_II
    case UMREADER_SHUTTLE
}

func UmRet_lookup() -> inline NSString {
    switch c {
        case UMREADER_UNKNOWN:
            return "Unknown"
        case UMREADER_UNIMAG_ORIGINAL:
            return "UniMag (original)"
        case UMREADER_UNIMAG_PRO:
            return "UniMag Pro"
        case UMREADER_UNIMAG_II:
            return "UniMag II"
        case UMREADER_SHUTTLE:
            return "Shuttle"
        default:
            return "<unknown code>"
    }

}

//SDK async task types
enum UmTask : Int {
    case UMTASK_NONE
    //no async task running. SDK idle.
    case UMTASK_CONNECT
    //connection task
    case UMTASK_SWIPE
    //swipe task
    case UMTASK_CMD
    //command task
    case UMTASK_FW_UPDATE
}

//async task methods return value
//Description                                 |Applicable task
//                                            |Connect|Swipe|Cmd|Update
enum UmRet : Int    //--------------------------------------------+-------+-----+---+------
 {
    case UMRET_SUCCESS
    //no error, beginning task                    | *     | *   | * | *
    case UMRET_NO_READER
    //no reader attached                          | *     | *   | * | *
    case UMRET_SDK_BUSY
    //SDK is doing another task                   | *     | *   | * | *
    case UMRET_MONO_AUDIO
    //mono audio is enabled                       | *     |     | * |
    case UMRET_ALREADY_CONNECTED
    //did connection already                      | *     |     |   |
    case UMRET_LOW_VOLUME
    //audio volume is too low                     | *     |     |   |
    case UMRET_NOT_CONNECTED
    //did not do connection                       |       | *   |   |
    case UMRET_NOT_APPLICABLE
    //operation not applicable to the reader type |       |     | * |
    case UMRET_INVALID_ARG
    //invalid argument passed to API              |       |     | * |
    case UMRET_UF_INVALID_STR
    //UF wrong string format                      |       |     |   | *
    case UMRET_UF_NO_FILE
    //UF file not found                           |       |     |   | *
    case UMRET_UF_INVALID_FILE
}

func () -> inline NSString {
    switch c {
    }

}

func () {
}

func () {
}

func () {
}

func () {
}

func () {
}

func () {
    //updateFirmware: codes return from notifications identifying their type
enum UmUfCode : Int {
        case UMUFCODE_SENDING_BLOCK = 21
        case UMUFCODE_VERIFYING_CHECKSUM = 30
        case UMUFCODE_RESENDING_BLOCK = 40
        case UMUFCODE_FAILED_TO_ENTER_BOOTLOADER_MODE = 303
        case UMUFCODE_FAILED_TO_SEND_BLOCK = 305
        case UMUFCODE_FAILED_TO_VERIFY_CHECKSUM = 306
        case UMUFCODE_CANCELED = 307
}
}

//updateFirmware: dict key for block number from applicable notifications
let UmUfBlockNumberKey = "block_num"
//tag used by SDK internally when logging
// look for NSLog entries with these tags
let UMLOG_ERROR = "[UM Error] "
let UMLOG_WARNING = "[UM Warning] "
let UMLOG_INFO = "[UM Info] "
class uniMag: NSObject {
    //version
    class func SDK_version() -> String {
    }
    //status

    func isReaderAttached() -> Bool {
    }

    func getConnectionStatus() -> Bool {
    }

    func getRunningTask() -> UmTask {
    }

    func getVolumeLevel() -> Float {
    }
    //config
    var readerType: UmReader

    func setAutoConnect(autoConnect: Bool) {
    }

    func setSwipeTimeoutDuration(seconds: Int) -> Bool {
    }

    func setAutoAdjustVolume(b: Bool) {
    }

    func setDeferredActivateAudioSession(b: Bool) {
    }
    //task

    func cancelTask() {
    }
    //connect

    func startUniMag(start: Bool) -> UmRet {
    }
    //swipe

    func requestSwipe() -> UmRet {
    }

    func getFlagByte() -> NSData {
    }
    //commands

    func sendCommandGetVersion() -> UmRet {
    }

    func sendCommandGetSettings() -> UmRet {
    }

    func sendCommandEnableTDES() -> UmRet {
    }

    func sendCommandEnableAES() -> UmRet {
    }

    func sendCommandDefaultGeneralSettings() -> UmRet {
    }

    func sendCommandGetSerialNumber() -> UmRet {
    }

    func sendCommandGetNextKSN() -> UmRet {
    }

    func sendCommandEnableErrNotification() -> UmRet {
    }

    func sendCommandDisableErrNotification() -> UmRet {
    }

    func sendCommandEnableExpDate() -> UmRet {
    }

    func sendCommandDisableExpDate() -> UmRet {
    }

    func sendCommandEnableForceEncryption() -> UmRet {
    }

    func sendCommandDisableForceEncryption() -> UmRet {
    }

    func sendCommandSetPrePAN(prePAN: Int) -> UmRet {
    }

    func sendCommandClearBuffer() -> UmRet {
    }

    func sendCommandResetBaudRate() -> UmRet {
    }

    func sendCommandCustom(cmd: NSData) -> UmRet {
    }
    // firmware updating

    func getAuthentication() -> UmRet {
    }

    func setFirmwareFile(location: String) -> Bool {
    }

    func updateFirmware(encrytedBytes: String) -> UmRet {
    }

    func updateFirmware2(string: String, withFile path: String) -> UmRet {
    }
    // troubleshooting

    class func enableLogging(enable: Bool) {
    }

    func getWave() -> NSData {
    }

    func setWavePath(path: String) -> Bool {
    }
    //deprecated
    //  This API now does nothing

    func autoDetect(autoDetect: Bool) {
    }
    //  Equivalent to '-setAutoConnect: ! prompt'

    func promptForConnection(prompt: Bool) {
    }
    //  Equivalent to '-startUniMag: proceedPowerUp'

    func proceedPoweringUp(proceedPowerUp: Bool) -> UmRet {
    }
    //  Equivalent to '-startUniMag:FALSE'

    func closeConnection() {
    }
    //  Equivalent to '-cancelTask'

    func cancelSwipe() {
    }
    //  It is no longer possible to change command timeout

    func setCmdTimeoutDuration(seconds: Int) -> Bool {
    }
}