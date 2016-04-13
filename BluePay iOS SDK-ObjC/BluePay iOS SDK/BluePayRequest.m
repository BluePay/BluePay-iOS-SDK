//
//  BluePayRequest.m
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#import "BluePayRequest.h"

@implementation BluePayRequest

+ (void)Post:(NSData*)token bluepaySetup:(NSDictionary*) bpSetup customer:(NSDictionary*)customerInfo handler:(void(^)(NSString *))completion
{
    if (![bpSetup[@"TransType"]  isEqual: @"SALE"] && ![bpSetup[@"TransType"]  isEqual: @"AUTH"])
        completion(@"Transaction type must be either SALE or AUTH");
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:token
                 options:0
                 error:&error];
    if (error)
    {
        NSLog(@"There was an error in retrieving the Apple Pay token");
        completion(@"There was an error in retrieving the Apple Pay token");
    }
    
    NSDictionary *results = object;

    // Create POST string to send to BluePay
    NSMutableString *post = [NSMutableString string];
        [post appendString:@"ACCOUNT_ID=%@"];
        [post appendString:@"&MODE=%@"];
        [post appendString:@"&TRANS_TYPE=%@"];
        [post appendString:@"&NAME1=%@"];
        [post appendString:@"&NAME2=%@"];
        [post appendString:@"&ADDR1=%@"];
        [post appendString:@"&CITY=%@"];
        [post appendString:@"&STATE=%@"];
        [post appendString:@"&ZIP=%@"];
        [post appendString:@"&COUNTRY=%@"];
        [post appendString:@"&PHONE=%@"];
        [post appendString:@"&EMAIL=%@"];
    
    NSMutableString *postString = [NSMutableString stringWithFormat:post,bpSetup[@"AccountID"],bpSetup[@"TransMode"],bpSetup[@"TransType"],customerInfo[@"FirstName"],customerInfo[@"LastName"],customerInfo[@"Street"],customerInfo[@"City"],customerInfo[@"State"],customerInfo[@"ZIP"],customerInfo[@"Country"],customerInfo[@"Phone"],customerInfo[@"Email"]];
    [post setString:@""];
    if (results[@"header"]) {
        NSString *tps = [BluePay calcTPS:bpSetup[@"SecretKey"] accID:bpSetup[@"AccountID"] transType:bpSetup[@"TransType"] transAmount:@"" fullName:customerInfo[@"FirstName"] paymentAcct:@""];
        [post appendString:@"&TAMPER_PROOF_SEAL=%@"];
        [post appendString:@"&APPLE_EPK=%@"];
        [post appendString:@"&APPLE_DATA=%@"];
        [post appendString:@"&APPLE_SIG=%@"];
        [postString appendString:[NSString stringWithFormat:post,tps,[results[@"header"][@"ephemeralPublicKey"] stringByAddingPercentEncodingForRFC3986],[results[@"data"] stringByAddingPercentEncodingForRFC3986],[results[@"signature"] stringByAddingPercentEncodingForRFC3986]]];
    } else if (results[@"EncryptedTrack1"]) {
        NSString *tps = [BluePay calcTPS:bpSetup[@"SecretKey"] accID:bpSetup[@"AccountID"] transType:bpSetup[@"TransType"] transAmount:results[@"Amount"] fullName:results[@"FirstName"]  paymentAcct:@""];
        [post appendString:@"&TAMPER_PROOF_SEAL=%@"];
        [post appendString:@"&AMOUNT=%@"];
        [post appendString:@"&TRACK1_ENC=%@"];
        [post appendString:@"&TRACK1_EDL=%@"];
        [post appendString:@"&KSN=%@"];
        [postString appendString:[NSString stringWithFormat:post,tps,customerInfo[@"Amount"],results[@"EncryptedTrack1"],results[@"Track1Length"],results[@"KSN"]]];
    } else {
        NSString *tps = [BluePay calcTPS:bpSetup[@"SecretKey"] accID:bpSetup[@"AccountID"] transType:bpSetup[@"TransType"] transAmount:results[@"Amount"] fullName:results[@"FirstName"] paymentAcct:results[@"CardNumber"]];
        [post appendString:@"&TAMPER_PROOF_SEAL=%@"];
        [post appendString:@"&AMOUNT=%@"];
        [post appendString:@"&PAYMENT_ACCOUNT=%@"];
        [post appendString:@"&CARD_EXPIRE=%@"];
        [postString appendString:[NSString stringWithFormat:post,tps,customerInfo[@"Amount"],results[@"CardNumber"],results[@"CardExpirationDate"]]];
    }
    // POST to the bp20post API of the BluePay gateway
    NSString *postURL = @"https://secure.bluepay.com/interfaces/bp20post";
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL]];
    
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [postRequest setValue:@"BluePay iOS SDK" forHTTPHeaderField:@"User-Agent"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Create the POST request and specify its body data
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    //NSData *responseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&err];
    NSURLSessionDataTask *postToBP = [session dataTaskWithRequest:postRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"Response:%@ %@\n", response, error);
        if(error == nil)
        {
            NSString * response = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            //NSLog(@"Data = %@",response);
            completion(response);
            return;
        } else {
            completion([error localizedDescription]);
        }
    }];
        //completion(@"There was an error in retrieving the transaction details from the BluePay gateway.");
    [postToBP resume];
    return;
    //NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // Return the body of the HTTPS POST response from BluePay
    //return responseBody;
}

@end


