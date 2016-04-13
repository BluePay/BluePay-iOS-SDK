//
//  ProcessController.m
//  BluePay iOS SDK
//
//  Created by Justin Slingerland on 3/22/16.
//  Copyright © 2016 BluePay Processing, Inc. All rights reserved.
//

#import "ProcessController.h"

@interface ProcessController ()

@end

@implementation ProcessController
@synthesize datePicker;
@synthesize cardNumber;
@synthesize cvv2;
@synthesize name1;
@synthesize name2;
@synthesize addr1;
@synthesize addr2;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize amount;


- (void)viewDidLoad {
    datePicker._delegate = self;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MMyy"];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)buttonTapped:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Transaction Result"
                                                           message:@""
                                                    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                       }];
    NSString *transAmount = @"";
    NSString *transType = @"";
    // If the amount has been set, use the user-inputted value. Else, set amount to $0.00 and trans type to AUTH
    if (amount != nil && ![amount.text isEqual: @""])
        transAmount = amount.text;
    else {
        transAmount = @"0.00";
        transType = @"AUTH";
    }
    NSDictionary *customerInformation = @{
                                          @"FirstName" : name1.text,
                                          @"LastName" : name2.text,
                                          @"Street" : addr1.text,
                                          @"City" : city.text,
                                          @"State" : state.text,
                                          @"ZIP" : zip.text,
                                          @"Country" : @"US",
                                          @"Phone" : @"",
                                          @"Email" : @"",
                                          @"CardNumber" : cardNumber.text,
                                          @"CardExpirationDate" : [dateFormatter stringFromDate:datePicker.date],
                                          @"Amount" : transAmount
                                          };
    NSError *jsonError;
    NSData *paymentData = [NSJSONSerialization dataWithJSONObject:customerInformation options:0 error:&jsonError];
    if(jsonError) {
        // check the error description
        NSLog(@"json error : %@", [jsonError localizedDescription]);
    } else {
        //NSLog(paymentData);
        // use the jsonDictionaryOrArray
    }
    BluePay *bluepay = [[BluePay alloc] initSetup:transType];
    // Pass transaction data to BluePayRequest, then do POST to the BluePay gateway
    [BluePayRequest Post: paymentData bluepaySetup:[bluepay getBluePaySetup] customer:customerInformation handler:^(NSString *results) {
        
        // Get transaction response from the BluePay gateway
        NSMutableDictionary *response = [BluePayResponse ParseResponse:results];
         if([BluePayResponse isApproved:response]) {
         NSLog(@"The transaction was processed and approved.\nTransaction ID:%@", [response objectForKey:@"TRANS_ID"]);
         
         alertController.message = [NSString stringWithFormat:@"The transaction was processed and approved.\nTransaction ID:%@", [response objectForKey:@"TRANS_ID"]];
         } else if([BluePayResponse isDeclined:response]){
         NSLog(@"The transaction has been declined.");
         alertController.message = @"The transaction has been declined.";
         
         // If an error occurred with the transaction, also return PKPaymentAuthorizationStatusFailure
         } else {
         NSLog(@"There was an error when processing the payment. Reason: %@", [response objectForKey:@"MESSAGE"]);
         alertController.message = [NSString stringWithFormat:@"There was an error when processing the payment. Reason: %@", [response objectForKey:@"MESSAGE"]];
         }
        dispatch_async(dispatch_get_main_queue(), ^{
            //[alertController setModalPresentationStyle:UIModalPresentationPopover];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }];
}

@end

