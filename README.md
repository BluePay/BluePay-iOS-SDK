# BluePay-iOS-SDK
BluePay iOS SDK for credit card and Apple Pay payments

## Overview
This repository contains a sample iOS app to be used to accept credit card as well as Apple Pay payments through a BluePay gateway account as well as an SDK to handle said payments. Included in this repository are sample projects for both Objective-C and Swift. These projects were built and tested on iOS 9.3.

You will need:
- A BluePay Gateway account
- An Apple Merchant ID (if processing Apple Pay)

## Usage
After you've set up the appropriate entitlement in your iOS app, the only thing left to do is to input your BluePay gateway information. In the BluePay.m/BluePay.swift file, you will need to set a few merchant-specific values, namely:
- Your BluePay gateway Account ID
- Your BluePay gateway Secret Key
- Your transaction mode to process either test or live transactions
- Your transaction type of Auth or Sale.

```swift
class BluePay {
    var bluepaySetup = [String: String]()
    var AccountID: String = "Merchant's Account ID Here" // 12 digit Account ID
    var SecretKey: String = "Merchant's Secret Key Here" // 32 digit Secret Key
    var TransMode: String = "TEST" // TEST or LIVE mode
    var TransType: String = "SALE" // SALE or AUTH; defaults to SALE unless explicitly specified
```
    
Also, if you are planning to process Apple Pay payments, you will need to input your Merchant Identifier in the ApplePayController.m/ApplePayController.swift file:

```swift
@IBAction func buttonTapped(sender: UIButton) {
    ...
    request.merchantIdentifier = "Your Merchant ID Here"
}
```
    
## Additional App Setup For Apple Pay
The sample iOS app requires the shipping and billing information for the customer. To change this, edit the following lines in your ApplePayController.m/ApplePayController.swift file.

```swift
@IBAction func buttonTapped(sender: UIButton) {
    ...
    request.requiredShippingAddressFields = .All
    request.requiredBillingAddressFields = .All
```

Also make sure that the currency code, country, and card types that you accept are included as well

```swift
    request.countryCode = "US"
    request.currencyCode = "USD"
    request.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
```

Finally, don't forget to add the item(s) that your customer is paying for in the PKPaymentRequest

```swift
    request.paymentSummaryItems = [widget1, widget2, total]
}
```

## After a transaction is processed
You will get a real-time response back from BluePay when a transaction is processed. This result will be either: approved, declined, or errored. For Apple Pay: if approved, [PKPaymentAuthorizationStatusSuccess](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned. If declined or errored, [PKPaymentAuthorizationStatusFailure](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned.
