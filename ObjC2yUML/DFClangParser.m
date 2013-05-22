//
//  DFClangParser.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFClangParser.h"
#import "DFClangParserDelegate.h"

// Supported indexer callback functions
void indexDeclaration(CXClientData client_data, const CXIdxDeclInfo* declaration);
CXIdxClientFile ppIncludedFile(CXClientData client_data, const CXIdxIncludedFileInfo* included_file);

static IndexerCallbacks indexerCallbacks = {
    .indexDeclaration = indexDeclaration,
    .ppIncludedFile = ppIncludedFile,
};

@interface DFClangParser ( /* Private */ )
@property (nonatomic) NSString* fileName;
@end

@implementation DFClangParser

- (id)initWithFileName:(NSString*)fileName {
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.fileName = [fileName copy];
    }
    return self;
}

- (void)parseWithCompletion:(void(^)(NSError*))completion {

    CXIndex index = clang_createIndex(1, 1);
    if (!index) {
        if (completion) {
            completion([[NSError alloc] initWithDomain:@"ClangParseErrorDomain" code:DFClangParseErrorInit userInfo:nil]);
        }
        return;
    }

    // TODO: accept compiler flags from command line, force ARC for now
    const char * command_line_args[2];
    command_line_args[0] = "-fobjc-arc";
    command_line_args[1] = "-F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks";
    
    CXTranslationUnit translationUnit = clang_parseTranslationUnit(index,
                                                                   [self.fileName fileSystemRepresentation],
                                                                   command_line_args, 2,
                                                                   NULL, 0,
                                                                   // CXTranslationUnit_DetailedPreprocessingRecord enables ppIncludedFile callback
                                                                   CXTranslationUnit_SkipFunctionBodies /* | CXTranslationUnit_DetailedPreprocessingRecord */);
    if (!translationUnit) {
        if (completion) {
            completion([[NSError alloc] initWithDomain:@"ClangParseErrorDomain" code:DFClangParseErrorCompilation userInfo:nil]);
        }
        return;
    }
    
    CXIndexAction action = clang_IndexAction_create(index);

    int indexResult = clang_indexTranslationUnit(action,
                                                 (__bridge CXClientData)self,
                                                 &indexerCallbacks,
                                                 sizeof(indexerCallbacks),
                                                 CXIndexOpt_SuppressWarnings,
                                                 translationUnit);
    if (completion) {
        completion(nil);
    }
    
    clang_IndexAction_dispose(action);
    clang_disposeTranslationUnit(translationUnit);
    clang_disposeIndex(index);
    (void) indexResult;
    
}

#pragma mark - Indexer callbacks

void indexDeclaration(CXClientData client_data, const CXIdxDeclInfo* declaration) {
    @autoreleasepool {        
        DFClangParser* parser = (__bridge DFClangParser*)client_data;
        if ([parser.delegate respondsToSelector:@selector(classParser:foundDeclaration:)]) {
            [parser.delegate classParser:parser foundDeclaration:declaration];
        }
    }
}

CXIdxClientFile ppIncludedFile(CXClientData client_data, const CXIdxIncludedFileInfo* included_file) {
    @autoreleasepool {
        DFClangParser* parser = (__bridge DFClangParser*)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:includedFile:)]) {
            return [parser.delegate classParser:parser includedFile:included_file];
        }
        return NULL;
    }
}


@end
