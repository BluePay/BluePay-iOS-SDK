//
//  BluePay_Helper.h
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#ifndef BluePay_iOS_App_BluePay_Helper_h
#define BluePay_iOS_App_BluePay_Helper_h
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import <PassKit/PassKit.h>


#endif

@interface BluePay: NSObject

@property (nonatomic, copy) NSMutableDictionary *bluepaySetup;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *transMode;
@property (nonatomic, copy) NSString *transType;

- (id)initSetup:(NSString*)transactionType;
- (NSMutableDictionary*) getBluePaySetup;

+ (NSString *)calcTPS:(NSString *)secretKey accID:(NSString *)accountID transType:(NSString *)transactionType transAmount:(NSString *)amount fullName: (NSString *) name paymentAcct:(NSString *)paymentAccount;
+ (NSDictionary *)getCustomerInformation:(PKPayment *) payment;

@end

@interface NSString (MD5String)
- (NSString *)MD5;
@end

@interface NSString (URLEncoding)
- (NSString *)stringByAddingPercentEncodingForRFC3986;
@end
