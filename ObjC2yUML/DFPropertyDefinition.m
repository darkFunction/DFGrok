//
//  DFPropertyDefinition.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFPropertyDefinition.h"

@interface DFPropertyDefinition ( /* Private */ )

@end

@implementation DFPropertyDefinition

+ (NSString*)classNameFromEncoding:(NSString*)encoding {
    NSRange range = [encoding rangeOfString:@"\".*?\"" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        // Remove quotes
        range.length -= 2;
        range.location++;
        
        NSString* name = [encoding substringWithRange:range];
        
        // Remove <> from protocol name
        if ([name rangeOfString:@"<"].location == 0 && [name rangeOfString:@">"].location == name.length-1) {
            range.length = [name length] - 2;
            range.location = 1;
            name = [name substringWithRange:range];
        }
        return name;
    }
    return nil;
}

+ (DFPropertyReferenceType)referenceTypeFromEncoding:(NSString*)encoding {
    NSRange range = [encoding rangeOfString:@","];
    if (range.location != NSNotFound) {
        range.location++;
        range.length = encoding.length - range.location;
        NSString* properties = [encoding substringWithRange:range];
        
        if ([properties rangeOfString:@"W"].location != NSNotFound) {
            return DFPropertyReferenceTypeWeak;
        } else {
            return DFPropertyReferenceTypeStrong;
        }
    }
    return DFPropertyReferenceTypeUnknown;
}

- (BOOL)isWeak {
    return self.referenceType == DFPropertyReferenceTypeWeak;
}

@end
