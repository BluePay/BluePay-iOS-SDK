# BluePay-iOS-SDK
BluePay iOS SDK for credit card and Apple Pay payments

## Overview
This repository contains a sample iOS app to be used to accept credit card as well as Apple Pay payments through a BluePay gateway account as well as an SDK to handle said payments.
You will need:
- An Apple Merchant ID
- A BluePay Gateway account

## Usage
After you've set up the appropriate entitlement for Apple Pay in your iOS app, the only thing left to do is to input your BluePay gateway information. In the BluePay.m/BluePay.swift file, you will need to set a few merchant-specific values, namely;
- Your Apple Merchant ID
- Your BluePay gateway Account ID
- Your BluePay gateway Secret Key
- Your transaction mode to process either test or live transactions
- Your transaction type of Auth or Sale.

`@IBAction func buttonTapped(sender: UIButton) {`<br>
<b>`request.merchantIdentifier = "Your Merchant ID Here"`<br></b>
`}`<br>

`class BluePay {`<br>
    `var bluepaySetup = [String: String]()`<br>
    <b>`var AccountID: String = "Merchant's Account ID Here" // 12 digit Account ID`<br></b>
    <b>`var SecretKey: String = "Merchant's Secret Key Here" // 32 digit Secret Key`<br></b>
    <b>`var TransMode: String = "TEST" // TEST or LIVE mode`<br></b>
    <b>`var TransType: String = "SALE" // SALE or AUTH; defaults to SALE unless explicitly specified`<br></b>
    
## Additional App Setup
The sample iOS app requires the shipping and billing information for the customer. To change this, edit the following lines.<br>
`- (IBAction)buttonTapped:(UIButton *)sender {`<br>
`request.requiredShippingAddressFields = PKAddressFieldAll;`<br>
`request.requiredBillingAddressFields = PKAddressFieldAll;`<br>

Also make sure that the currency code, country, and card types that you accept are included as well

`request.countryCode = @"US";`<br>
`request.currencyCode = @"USD";`<br>
`request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];`<br>

Finally, don't forget to add the item(s) that your customer is paying for in the PKPaymentRequest<br>
`request.paymentSummaryItems = @[widget1, widget2, total];`<br>

## After a transaction is processed
You will get a real-time response back from BluePay when an Apple Pay transaction is processed. This result will be either: approved, declined, or errored. If approved, [PKPaymentAuthorizationStatusSuccess](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned. If declined or errored, [PKPaymentAuthorizationStatusFailure](https://developer.apple.com/library/prerelease/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewControllerDelegate_Ref/index.html#//apple_ref/c/tdef/PKPaymentAuthorizationStatus) is returned.
