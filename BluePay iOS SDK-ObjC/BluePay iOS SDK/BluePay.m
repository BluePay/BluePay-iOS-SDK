//
//  BluePay_Helper.m
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#import "BluePay.h"

@implementation BluePay

NSMutableDictionary *bluepaySetup;
NSString *accountID = @"Merchant's Account ID Here"; // 12 digit Account ID
NSString *secretKey = @"Merchant's Secret Key Here"; // 32 digit Secret Key
NSString *transMode = @"TEST"; // TEST or LIVE mode
NSString *transType = @"SALE"; // SALE or AUTH; defaults to SALE unless explicitly specified

- (id)initSetup:(NSString*)transactionType
{
    self = [super init];
    bluepaySetup = [[NSMutableDictionary alloc] init];
    [bluepaySetup setObject:accountID forKey:@"AccountID"];
    [bluepaySetup setObject:secretKey forKey:@"SecretKey"];
    [bluepaySetup setObject:transMode forKey:@"TransMode"];
    if (transactionType != nil && ![transactionType  isEqual: @""]) {
        [bluepaySetup setObject:transactionType forKey:@"TransType"];
    } else {
        [bluepaySetup setObject:transType forKey:@"TransType"];
    }
    return self;
}

- (NSMutableDictionary*) getBluePaySetup
{
    return bluepaySetup;
}

+ (NSString *)calcTPS:(NSString *)secretKey accID:(NSString *)accountID transType:(NSString *)transactionType transAmount:(NSString *)amount fullName: (NSString *) name paymentAcct:(NSString *)paymentAccount
{
    // Calculates the TAMPER_PROOF_SEAL needed for each transaction for the bp20post API
    NSMutableString *tps = [NSMutableString string];
    [tps appendString:secretKey];
    [tps appendString:accountID];
    [tps appendString:transactionType];
    [tps appendString:amount];
    [tps appendString:name];
    [tps appendString:paymentAccount];
    NSString *md5 = [tps MD5];
    return md5;
}

+ (NSDictionary *)getCustomerInformation:(PKPayment *) payment
{

    //CFTypeRef addressProperty = ABRecordCopyValue((__bridge ABRecordRef)billingInfo, kABPersonAddressProperty);
    //NSLog(@"%@",CNPostalAddressPostalCodeKey);
    //NSMutableDictionary *customerInformation = (__bridge NSMutableDictionary *)CFArrayGetValueAtIndex((CFArrayRef)ABMultiValueCopyArrayOfAllValues(addressProperty), 0);
    // Grab the first and last name values from the billing address
    //NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue((__bridge ABRecordRef)(billingInfo), kABPersonFirstNameProperty);
    //NSString *firstName = billingInfo.
    //NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue((__bridge ABRecordRef)(billingInfo), kABPersonFirstNameProperty);
    NSString *firstName = payment.billingContact.name.givenName;
    NSString *lastName = payment.billingContact.name.familyName;
    
    // Grab the phone and email values from the shipping address
    //ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(shippingInfo), kABPersonPhoneProperty);
    //NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
    //NSString phone = billingInfo.
    //ABMultiValueRef emails = ABRecordCopyValue((__bridge ABRecordRef)(shippingInfo), kABPersonEmailProperty);
    //NSString *email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emails, 0));
    NSString *phone = payment.shippingContact.phoneNumber.stringValue;
    NSString *email = payment.shippingContact.emailAddress;
    
    // Add customer first name, last name, phone, and email to the customerInformation NSDict
    NSMutableDictionary *customerInformation = [[NSMutableDictionary alloc] init];
    [customerInformation setValue:firstName forKey:@"FirstName"];
    [customerInformation setValue:lastName forKey:@"LastName"];
    [customerInformation setValue:phone forKey:@"Phone"];
    [customerInformation setValue:email forKey:@"Email"];
    return customerInformation;
}

@end

@implementation NSString (BluePayHelper)
- (NSString *)MD5
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}
@end

@implementation NSString (URLEncoding)
- (NSString *)stringByAddingPercentEncodingForRFC3986 {
    NSString *unreserved = @"-._~/";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [self
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}
@end
