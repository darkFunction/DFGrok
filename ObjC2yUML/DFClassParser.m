//
//  DFClassParser.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFClassParser.h"
#include "clang-c/Index.h"

int abortQuery(CXClientData client_data, void *reserved);
void diagnostic(CXClientData client_data, CXDiagnosticSet diagnostic_set, void *reserved);
CXIdxClientFile enteredMainFile(CXClientData client_data, CXFile mainFile, void *reserved);
CXIdxClientFile ppIncludedFile(CXClientData client_data, const CXIdxIncludedFileInfo *included_file);
CXIdxClientASTFile importedASTFile(CXClientData client_data, const CXIdxImportedASTFileInfo *_imported_ast);
CXIdxClientContainer startedTranslationUnit(CXClientData client_data, void *reserved);
void indexDeclaration(CXClientData client_data, const CXIdxDeclInfo *declaration);
void indexEntityReference(CXClientData client_data, const CXIdxEntityRefInfo *entity_ref);

static IndexerCallbacks indexerCallbacks = {
    .abortQuery = abortQuery,
    .diagnostic = diagnostic,
    .enteredMainFile = enteredMainFile,
    .ppIncludedFile = ppIncludedFile,
    .importedASTFile = importedASTFile,
    .startedTranslationUnit = startedTranslationUnit,
    .indexDeclaration = indexDeclaration,
    .indexEntityReference = indexEntityReference
};

@interface DFClassParser ( /* Private */ )
@property (nonatomic) NSString* fileName;
@end

@implementation DFClassParser

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

- (void)parse {

    CXIndex index = clang_createIndex(1, 1);
    if (!index) {
        NSLog(@"fail: couldn't create translation unit");
        return;
    }
    CXTranslationUnit translationUnit = clang_parseTranslationUnit(index, [self.fileName fileSystemRepresentation], NULL, 0, NULL, 0, CXTranslationUnit_DetailedPreprocessingRecord);
    if (!translationUnit) {
        NSLog(@"fail: couldn't compile %@", self.fileName);
        return;
    }
    CXIndexAction action = clang_IndexAction_create(index);

    // Parsing begin
    
    int indexResult = clang_indexTranslationUnit(action,
                                                 (__bridge CXClientData)self,
                                                 &indexerCallbacks,
                                                 sizeof(indexerCallbacks),
                                                 CXIndexOpt_SuppressWarnings,
                                                 translationUnit);

    // Parsing finished
    
    clang_IndexAction_dispose(action);
    clang_disposeTranslationUnit(translationUnit);
    clang_disposeIndex(index);
    (void) indexResult;
    
}

#pragma mark - Indexer callbacks

int abortQuery(CXClientData client_data, void *reserved) {
    return 0;
}

void diagnostic(CXClientData client_data, CXDiagnosticSet diagnostic_set, void *reserved) {
    
}

CXIdxClientFile enteredMainFile(CXClientData client_data, CXFile mainFile, void *reserved) {
    return NULL;
}

CXIdxClientFile ppIncludedFile(CXClientData client_data, const CXIdxIncludedFileInfo *included_file) {
    return NULL;
}

CXIdxClientASTFile importedASTFile(CXClientData client_data, const CXIdxImportedASTFileInfo *_imported_ast) {
    return NULL;
}

CXIdxClientContainer startedTranslationUnit(CXClientData client_data, void *reserved) {
    return NULL;
}

void indexDeclaration(CXClientData client_data, const CXIdxDeclInfo *declaration) {
    
}

void indexEntityReference(CXClientData client_data, const CXIdxEntityRefInfo *entity_ref) {
    
}

@end
