//
//  BluePayResponse.h
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#ifndef BluePay_iOS_App_BluePayResponse_h
#define BluePay_iOS_App_BluePayResponse_h
#import <Foundation/Foundation.h>


#endif

@interface BluePayResponse: NSObject

+ (NSMutableDictionary *)ParseResponse:(NSString *)token;
+ (bool)isApproved:(NSMutableDictionary *)response;
+ (bool)isDeclined:(NSMutableDictionary *)response;

@end
