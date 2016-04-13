//
//  BluePayResponse.m
//  BluePay Apple Pay SDK
//
//  Created by Justin Slingerland on 3/16/15.
//  Copyright (c) 2015 BluePay Processing, Inc. All rights reserved.
//

#import "BluePayResponse.h"

@implementation BluePayResponse

+ (NSMutableDictionary *)ParseResponse:(NSString *)queryString
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}

+ (bool)isApproved:(NSMutableDictionary *)response
{
    if ([[response objectForKey:@"STATUS"] isEqualToString:@"1"] && ![[response objectForKey:@"MESSAGE"]  isEqual: @"DUPLICATE"])
    {
        return true;
    }
    return false;
}

+ (bool)isDeclined:(NSMutableDictionary *)response
{
    if ([[response objectForKey:@"STATUS"]  isEqualToString:@"0"] && ![[response objectForKey:@"MESSAGE"]  isEqual: @"DUPLICATE"])
    {
        return true;
    }
    return false;
}

@end