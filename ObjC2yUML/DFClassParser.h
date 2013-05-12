//
//  DFClassParser.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

@protocol DFClassParserDelegate;

@interface DFClassParser : NSObject
    @property (nonatomic, weak) id<DFClassParserDelegate>delegate;
    - (id)initWithFileName:(NSString*)fileName;
    - (void)parseWithCompletion:(void(^)(NSError*))completion;
@end

@protocol DFClassParserDelegate <NSObject>
    - (void)classParser:(DFClassParser*)parser foundDeclaration:(CXIdxDeclInfo const *)declaration;
@end

typedef NS_ENUM(NSInteger, DFClangParseError) {
    DFClangParseErrorInit,
    DFClangParseErrorCompilation,
};