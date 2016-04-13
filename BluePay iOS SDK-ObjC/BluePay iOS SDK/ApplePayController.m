//
//  ViewController.m
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#import "ApplePayController.h"

@interface ApplePayController ()

@end

@implementation ApplePayController
UILabel *errorLabel;

UIAlertController *alertController;
UIAlertAction *okAction;

- (void)viewDidLoad {
    alertController = [UIAlertController alertControllerWithTitle:@"Transaction Result"
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    okAction = [UIAlertAction actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
                                      }];
    [alertController addAction:okAction];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonTapped:(UIButton *)sender {
    // Verify that the user's device can accept Apple Pay transactions
    if([PKPaymentAuthorizationViewController canMakePayments]) {
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        // Set up sample app test items
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 1" amount:[NSDecimalNumber decimalNumberWithString:@"4.99"]];
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 2" amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
        NSNumber *sum = [NSNumber numberWithFloat:([widget1.amount floatValue] + [widget2.amount floatValue])];
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total" amount:[NSDecimalNumber decimalNumberWithDecimal:[sum decimalValue]]];
        
        // Request setup portion
        request.countryCode = @"US";
        request.currencyCode = @"USD";
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
        request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
        request.merchantIdentifier = @"Your Merchant ID Here";
        request.paymentSummaryItems = @[widget1, widget2, total];
        // Payment will include *all* shipping and billing fields
        request.requiredShippingAddressFields = PKAddressFieldAll;
        request.requiredBillingAddressFields = PKAddressFieldAll;
        PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        if (!paymentPane) {
            [alertController setModalPresentationStyle:UIModalPresentationPopover];
            alertController.message = @"An error occurred when populating the Apple Pay Payment Pane.";
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"An error occurred when populating the Apple Pay Payment Pane.");
        }
        paymentPane.delegate = self;
        [self presentViewController:paymentPane animated:TRUE completion:nil];
    } else {
        // User's device cannot accept Apple Pay transactions. Display a payment form here for them to enter their payment info into.
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.message = @"Device cannot make Apple Pay payments.";
        NSLog(@"Device cannot make Apple Pay payments.");
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                    completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    // Grab the customer's name, billing address, phone #, and email address
    NSDictionary *customerInformation = [BluePay getCustomerInformation:payment];
    // Pass Merchant's BluePay gateway account information to helper class
    BluePay *bluepay = [[BluePay alloc] initSetup:nil];
    // Pass Apple Pay transaction data to BluePayRequest, then do POST to the BluePay gateway
    [BluePayRequest Post: payment.token.paymentData bluepaySetup:[bluepay getBluePaySetup] customer:customerInformation handler:^(NSString *results) {
        
        // Get transaction response from the BluePay gateway
        NSMutableDictionary *response = [BluePayResponse ParseResponse:results];
        
        // If transaction was approved, return PKPaymentAuthorizationStatusSuccess
        if([BluePayResponse isApproved:response]) {
            completion(PKPaymentAuthorizationStatusSuccess);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"The transaction was processed and approved. \nTransaction ID: %@", [response objectForKey:@"TRANS_ID"]);
                alertController.message = [NSString stringWithFormat:@"The transaction was processed and approved. \nTransaction ID: %@", [response objectForKey:@"TRANS_ID"]];
            });
            // If transaction was declined, return PKPaymentAuthorizationStatusFailure
        } else if([BluePayResponse isDeclined:response]){
            completion(PKPaymentAuthorizationStatusFailure);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"The transaction has been declined.");
                alertController.message = @"The transaction has been declined.";
            });
            
            // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
        } else {
            completion(PKPaymentAuthorizationStatusFailure);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"There was an error when processing the payment. Reason: %@", [response objectForKey:@"MESSAGE"]);
                alertController.message = [NSString stringWithFormat:@"There was an error when processing the payment. Reason: %@", [response objectForKey:@"MESSAGE"]];
            });
        }
        
    }];
}

@end

