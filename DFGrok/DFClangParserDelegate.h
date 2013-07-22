//
//  DFClangParserDelegate.h
//  DFGrok
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <clang-c/Index.h>

@class DFClangParser;

@protocol DFClangParserDelegate <NSObject>
@optional
- (void)classParser:(DFClangParser*)parser foundDeclaration:(CXIdxDeclInfo const *)declaration;
- (void)classParser:(DFClangParser*)parser foundEntityReference:(const CXIdxEntityRefInfo *)entityRef;
- (CXIdxClientFile)classParser:(DFClangParser*)parser includedFile:(const CXIdxIncludedFileInfo *)includedFile;
@end