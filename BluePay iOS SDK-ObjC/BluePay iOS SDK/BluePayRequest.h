//
//  BluePayRequest.h
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#ifndef BluePay_iOS_App_BluePayRequest_h
#define BluePay_iOS_App_BluePayRequest_h
#import <Foundation/Foundation.h>
#import "BluePay.h"


#endif

@interface BluePayRequest: NSObject

+ (void)Post:(NSData *)token bluepaySetup:(NSDictionary*) bpSetup customer:(NSDictionary*)customerInfo handler:(void(^)(NSString *))completion;

@end
