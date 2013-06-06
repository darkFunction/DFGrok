//
//  DFClangParser.h
//  DFGrok
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

@protocol DFClangParserDelegate;

@interface DFClangParser : NSObject
@property (nonatomic, weak) id<DFClangParserDelegate>delegate;
@property (nonatomic, readonly) CXTranslationUnit translationUnit;

- (id)initWithFileName:(NSString*)fileName;
- (void)parseWithCompletion:(void(^)(NSError*))completion;
@end

typedef NS_ENUM(NSInteger, DFClangParseError) {
    DFClangParseErrorInit,
    DFClangParseErrorCompilation,
};