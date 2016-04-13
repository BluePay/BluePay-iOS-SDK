# BluePay-iOS-SDK
BluePay iOS SDK for credit card and Apple Pay payments

## Overview
This repository contains a sample iOS app to be used to accept credit card as well as Apple Pay payments through a BluePay gateway account as well as an SDK to handle said payments.
You will need:
- A BluePay Gateway account
- An Apple Merchant ID (if processing Apple Pay)

## Usage
After you've set up the appropriate entitlement in your iOS app, the only thing left to do is to input your BluePay gateway information. In the BluePay.m/BluePay.swift file, you will need to set a few merchant-specific values, namely:
- Your BluePay gateway Account ID
- Your BluePay gateway Secret Key
- Your transaction mode to process either test or live transactions
- Your transaction type of Auth or Sale.

`class BluePay {`<br>
`   var bluepaySetup = [String: String]()`<br>
    <b>`var AccountID: String = "Merchant's Account ID Here" // 12 digit Account ID`<br></b>
    <b>`var SecretKey: String = "Merchant's Secret Key Here" // 32 digit Secret Key`<br></b>
    <b>`var TransMode: String = "TEST" // TEST or LIVE mode`<br></b>
    <b>`var TransType: String = "SALE" // SALE or AUTH; defaults to SALE unless explicitly specified`<br></b>
    
Also, if you are planning to process Apple Pay payments, you will need to input your Merchant Identifier in the ApplePayController.m/ApplePayController.swift file:

`@IBAction func buttonTapped(sender: UIButton) {`<br>
`...`<br>
<b>`request.merchantIdentifier = "Your Merchant ID Here"`<br></b>
`}`<br>
    
## Additional App Setup For Apple Pay
The sample iOS app requires the shipping and billing information for the customer. To change this, edit the following lines in your ApplePayController.m/ApplePayController.swift file.<br>
`@IBAction func buttonTapped(sender: UIButton) {`<br>
`...`<br>
<b>`request.requiredShippingAddressFields = .All`<br></b>
<b>`request.requiredBillingAddressFields = .All`<br></b>

Also make sure that the currency code, country, and card types that you accept are included as well

<b>`request.countryCode = "US"`<br></b>
<b>`request.currencyCode = "USD"`<br></b>
<b>`request.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]`<br></b>

Finally, don't forget to add the item(s) that your customer is paying for in the PKPaymentRequest<br>
<b>`request.paymentSummaryItems = [widget1, widget2, total]`<br></b>

## After a transaction is processed
You will get a real-time response back from BluePay when a transaction is processed. This result will be either: approved, declined, or errored. For Apple Pay: if approved, [PKPaymentAuthorizationStatusSuccess](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned. If declined or errored, [PKPaymentAuthorizationStatusFailure](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned.
