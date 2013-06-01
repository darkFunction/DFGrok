//
//  DFPropertyDefinition.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFPropertyDefinition.h"

@interface DFPropertyDefinition ( /* Private */ )
@property (nonatomic, readwrite, getter = isWeak) BOOL weak;
@property (nonatomic, readwrite) NSMutableArray* protocolNames;
@property (nonatomic, readwrite) NSString* className;
@property (nonatomic) NSMutableArray* tokens;
@end

@implementation DFPropertyDefinition

- (id)initWithDeclaration:(const CXIdxObjCPropertyDeclInfo*)declaration andTranslationUnit:(CXTranslationUnit)translationUnit {
    NSString* name = [NSString stringWithUTF8String:declaration->declInfo->entityInfo->name];
    if (![name length]) {
        return nil;
    }
    
    self = [super initWithName:name];
    if (self) {
        // Setup
        self.protocolNames = [NSMutableArray array];
        self.tokens = [self getStringTokensFromDeclaration:declaration inTranslationUnit:translationUnit];
        
        // Parse
        [self consumeTokens];
    }
    return self;
}

- (NSMutableArray*)getStringTokensFromDeclaration:(const CXIdxObjCPropertyDeclInfo*)declaration inTranslationUnit:(CXTranslationUnit)translationUnit {
    CXSourceRange range = clang_getCursorExtent(declaration->declInfo->cursor);
    CXToken *tokens = 0;
    unsigned int nTokens = 0;
    clang_tokenize(translationUnit, range, &tokens, &nTokens);
    NSMutableArray* stringTokens = [NSMutableArray arrayWithCapacity:nTokens];
    
    for (unsigned int i=0; i<nTokens; ++i) {
        CXString spelling = clang_getTokenSpelling(translationUnit, tokens[i]);
        [stringTokens addObject:[NSString stringWithUTF8String:clang_getCString(spelling)]];
        clang_disposeString(spelling);
    }
    clang_disposeTokens(translationUnit, tokens, nTokens);
    return stringTokens;
}

- (void)consumeTokens {
    [self consumePropertyDeclaration];
    [self consumeAttributes];
    [self consumeProtocols];
    
    // Whatever is left is the classname and the property name. We already have the property name.
    [self.tokens enumerateObjectsUsingBlock:^(NSString* token, NSUInteger idx, BOOL *stop) {
        if ([token isEqualToString:@";"] || [token isEqualToString:@"*"] || [token isEqualToString:self.name]) {
            // Ignore
        } else {
            self.className = token;
            *stop = YES;
        }
    }];
    
    self.tokens = nil;
}

- (void)consumePropertyDeclaration {
    __block NSRange consumeRange;
    consumeRange.location = NSNotFound;
    [self.tokens enumerateObjectsUsingBlock:^(NSString* token, NSUInteger idx, BOOL *stop) {
        if ([token isEqualToString:@"@"]) {
            consumeRange.location = idx;
        } else if ([token isEqualToString:@"property"]) {
            consumeRange.length = (idx+1) - consumeRange.location;
            *stop = YES;
        }
    }];
    if (consumeRange.location != NSNotFound) {
        [self.tokens removeObjectsInRange:consumeRange];
    }
}

- (void)consumeAttributes {
    __block NSRange consumeRange;
    consumeRange.location = NSNotFound;
    
    [self.tokens enumerateObjectsUsingBlock:^(NSString* token, NSUInteger idx, BOOL *stop) {
        if ([token isEqualToString:@"("]) {
            consumeRange.location = idx;
        } else if ([token isEqualToString:@")"]) {
            consumeRange.length = (idx+1) - consumeRange.location;
            *stop = YES;
        } else {
            if (consumeRange.location != NSNotFound) {
                if (![token isEqualToString:@","]) {
                    // OK so we're expecting attributes here, eg, weak, nonatomic, readonly etc.
                    [self attributeFound:token];
                }
            }
        }
    }];
    if (consumeRange.location != NSNotFound) {
        [self.tokens removeObjectsInRange:consumeRange];
    }
}

- (void)attributeFound:(NSString*)name {
    if ([name isEqualToString:@"weak"]) {
        self.weak = YES;
    }
}

- (void)consumeProtocols {
    __block NSRange consumeRange;
    consumeRange.location = NSNotFound;
    
    [self.tokens enumerateObjectsUsingBlock:^(NSString* token, NSUInteger idx, BOOL *stop) {
        if ([token isEqualToString:@"<"]) {
            consumeRange.location = idx;
        } else if ([token isEqualToString:@">"]) {
            consumeRange.length = (idx+1) - consumeRange.location;
            *stop = YES;
        } else if (consumeRange.location != NSNotFound) {
            [self protocolFound:token];
        }
    }];
    if (consumeRange.location != NSNotFound) {
        [self.tokens removeObjectsInRange:consumeRange];
    }
}

- (void)protocolFound:(NSString*)protocolName {
    [self.protocolNames addObject:protocolName];
}

@end
