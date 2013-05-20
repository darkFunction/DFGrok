//
//  DFPropertyDefinition.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFPropertyDefinition.h"

@interface DFPropertyDefinition ( /* Private */ )
@property (nonatomic, readwrite) DFPropertyReferenceType referenceType;
@property (nonatomic, readwrite) NSString* name;
@end

@implementation DFPropertyDefinition

- (id)initWithClangEncoding:(NSString*)encoding {
    self = [super init];
    if (self) {
        [self setupFromEncoding:encoding];
    }
    
    return self;
}

- (void)setupFromEncoding:(NSString*)encoding {
    self.name = [self classNameFromEncoding:encoding];
    
    NSRange range = [encoding rangeOfString:@","];
    if (range.location != NSNotFound) {
        range.location++;
        range.length = encoding.length - range.location;
        NSString* properties = [encoding substringWithRange:range];
        
        if ([properties rangeOfString:@"W"].location != NSNotFound) {
            self.referenceType = DFPropertyReferenceTypeWeak;
        } else {
            self.referenceType = DFPropertyReferenceTypeStrong;
        }
    }
}

- (NSString*)classNameFromEncoding:(NSString*)encoding {
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

- (BOOL)isWeak {
    return self.referenceType == DFPropertyReferenceTypeWeak;
}
@end
