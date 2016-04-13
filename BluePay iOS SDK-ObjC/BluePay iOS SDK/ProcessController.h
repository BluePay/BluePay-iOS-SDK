//
//  ProcessController.h
//  BluePay iOS SDK
//
//  Created by Justin Slingerland on 3/22/16.
//  Copyright © 2016 BluePay Processing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AddressBook/AddressBook.h>
#import "BluePayRequest.h"
#import "BluePayResponse.h"
#import "BluePay.h"
#import "UIMonthYearPicker.h"


@interface ProcessController : UIViewController {
    NSDateFormatter *dateFormatter; }

@property (weak, nonatomic) IBOutlet UIMonthYearPicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *name1;
@property (weak, nonatomic) IBOutlet UITextField *name2;
@property (weak, nonatomic) IBOutlet UITextField *addr1;
@property (weak, nonatomic) IBOutlet UITextField *addr2;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextField *cardNumber;
@property (weak, nonatomic) IBOutlet UITextField *cvv2;
-(IBAction)textFieldReturn:(id)sender;

@end
