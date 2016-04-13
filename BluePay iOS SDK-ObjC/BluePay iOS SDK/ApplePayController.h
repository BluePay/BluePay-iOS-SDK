//
//  ViewController.h
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AddressBook/AddressBook.h>
#import "BluePayRequest.h"
#import "BluePayResponse.h"
#import "BluePay.h"

@interface ApplePayController : UIViewController
<PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

