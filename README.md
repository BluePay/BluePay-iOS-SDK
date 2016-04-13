# BluePay-iOS-SDK
BluePay iOS SDK for credit card and Apple Pay payments

## Overview
This repository contains a sample iOS app to be used to accept credit card as well as Apple Pay payments through a BluePay gateway account as well as an SDK to handle said payments.
You will need:
- An Apple Merchant ID
- A BluePay Gateway account

## Usage
After you've set up the appropriate entitlement for Apple Pay in your iOS app, the only thing left to do is to input your BluePay gateway information. In the ViewController.m file, you will need to set a few merchant-specific values, namely;
- Your Apple Merchant ID
- Your BluePay gateway Account ID
- Your BluePay gateway Secret Key
- Your transaction mode to process either test or live transactions
- Your transaction type of Auth or Sale.

`- (IBAction)buttonTapped:(UIButton *)sender {`<br>
<b>`request.merchantIdentifier = @"Your Merchant ID here";`<br></b>
`}`<br>

`- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {`<br>
`NSDictionary *bluepaySetup = @{`<br>
        <b>`@"AccountID" : @"Your Account ID here",`<br></b>
        <b>`@"SecretKey" : @"Your Secret Key here",`<br></b>
        <b>`@"TransMode" : @"TEST", // Can be either TEST or LIVE`<br></b>
        <b>`@"TransType" : @"SALE" // Can be either SALE or AUTH`<br></b>
    `};`<br>
`}`<br>
    
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
