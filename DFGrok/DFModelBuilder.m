//
//  DFModelBuilder.m
//  DFGrok
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFModelBuilder.h"
#import "DFClangParser.h"
#import <clang-c/Index.h>
// Definitions
#import "DFDefinition.h"
#import "DFClassDefinition.h"
#import "DFProtocolDefinition.h"
#import "DFPropertyDefinition.h"
#import "DFCollectionPropertyDefinition.h"

@interface DFModelBuilder ( /* Private */ )
@property (nonatomic, readwrite) NSMutableDictionary* definitions;
@property (nonatomic) NSMutableArray* implementationNames;
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) DFContainerDefinition* currentContainerDef;
@property (nonatomic, copy) CompletionBlock completion;
@property (nonatomic) DFClangParser* currentParser;
@end

@implementation DFModelBuilder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        
        self.definitions = [NSMutableDictionary dictionary];
        self.implementationNames = [NSMutableArray array];
        self.fileNames = fileNames;
    }
    return self;
}

- (void)buildModelWithCompletion:(CompletionBlock)completion {
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* fileName, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            self.currentParser = [[DFClangParser alloc] initWithFileName:fileName];
            self.currentParser.delegate = self;
            [self.currentParser parseWithCompletion:^(NSError* error){
                if (error && completion) {
                    completion(error);
                    *stop = YES;
                }
            }];
        }
    }];
    
    if (completion) {
        completion(nil);
    }
}

- (NSMutableDictionary*)keyClassDefinitions {
    NSMutableDictionary* keyClasses = [NSMutableDictionary dictionaryWithCapacity:[self.implementationNames count]];
    
    [self.implementationNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        DFClassDefinition* classDef = [self.definitions objectForKey:obj];
        [keyClasses setObject:classDef forKey:obj];
    }];
    
    return keyClasses;
}

#pragma mark - DFClangParserDelegate

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const cName = declaration->entityInfo->name;
    if (cName == NULL)
        return;
    
    //NSLog(@"%d -> %s", declaration->entityInfo->kind, cName);
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
            self.currentContainerDef = [self processClassDeclaration:declaration];
            break;
            
        case CXIdxEntity_ObjCProtocol:
            self.currentContainerDef = [self processProtocolDeclaration:declaration];
            break;
        
        case CXIdxEntity_ObjCProperty:
            [self processPropertyDeclaration:declaration];
            break;
            
        case CXIdxEntity_ObjCCategory:
            self.currentContainerDef = nil; 
            break;
        
        case CXIdxEntity_ObjCInstanceMethod:
            [self processMethodDeclaration:declaration];
            break;
        default:
            break;
    }
}

- (void)classParser:(DFClangParser *)parser foundEntityReference:(const CXIdxEntityRefInfo *)entityRef {
    // Not used...
}

#pragma mark - Declaration processors

- (DFClassDefinition*)processClassDeclaration:(const CXIdxDeclInfo *)declaration {
    NSString* name = [NSString stringWithUTF8String:declaration->entityInfo->name];
    
    DFClassDefinition* classDef = (DFClassDefinition*)[self getDefinitionWithName:name andType:[DFClassDefinition class]];
    
    if (declaration->isContainer) {
        const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
        if (containerInfo) {
            if (containerInfo->kind == CXIdxObjCContainer_Implementation) {
                // Found an implementation
                [self.implementationNames addObject:name];
            } else if (containerInfo->kind == CXIdxObjCContainer_Interface) {
                const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
                if (declarationInfo) {
                    
                    // Find superclass
                    const CXIdxBaseClassInfo* superclassInfo = declarationInfo->superInfo;
                    if (superclassInfo) {
                        const char* cName = superclassInfo->base->name;
                        if (cName) {
                            NSString* superclassName = [NSString stringWithUTF8String:cName];
                            classDef.superclassDef = (DFClassDefinition*)[self getDefinitionWithName:superclassName andType:[DFClassDefinition class]];
                            cName = NULL;
                        }
                    }
                    
                    // Find protocols
                    for (int i=0; i<declarationInfo->protocols->numProtocols; ++i) {
                        const CXIdxObjCProtocolRefInfo* protocolRefInfo = declarationInfo->protocols->protocols[i];
                        NSString* protocolName = [NSString stringWithFormat:@"<%@>", [NSString stringWithUTF8String:protocolRefInfo->protocol->name]];
                        
                        [self setProtocolName:protocolName onContainer:classDef];
                    }
                }
            }
        }
    }
    
    return classDef;
}

- (void)setProtocolName:(NSString*)protocolName onContainer:(DFContainerDefinition*)containerDef {
    DFProtocolDefinition* protocolDef = (DFProtocolDefinition*)[self getDefinitionWithName:protocolName andType:[DFProtocolDefinition class]];
    if (![containerDef.protocols objectForKey:protocolName]) {
        [containerDef.protocols setObject:protocolDef forKey:protocolName];
    }
}

- (DFProtocolDefinition*)processProtocolDeclaration:(const CXIdxDeclInfo *)declaration {
    NSString* name = [NSString stringWithUTF8String:declaration->entityInfo->name];
    name = [NSString stringWithFormat:@"<%@>", name];
    
    DFProtocolDefinition* protoDef = (DFProtocolDefinition*)[self getDefinitionWithName:name andType:[DFProtocolDefinition class]];
    
    // Find super protocols
    const CXIdxObjCProtocolRefListInfo* protocolRefListInfo = clang_index_getObjCProtocolRefListInfo(declaration);
    if (protocolRefListInfo) {
        for (int i=0; i<protocolRefListInfo->numProtocols; ++i) {
            const CXIdxObjCProtocolRefInfo* protocolRefInfo = protocolRefListInfo->protocols[i];
            NSString* protocolName = [NSString stringWithFormat:@"<%@>", [NSString stringWithUTF8String:protocolRefInfo->protocol->name]];
            [self setProtocolName:protocolName onContainer:protoDef];
        }
    }
    
    return protoDef;
}

- (void)processPropertyDeclaration:(const CXIdxDeclInfo *)declaration {
    NSString* name = [NSString stringWithUTF8String:declaration->entityInfo->name];
        
    if (self.currentContainerDef && ![self.currentContainerDef.childDefinitions objectForKey:name]) {
        const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);
        if (propertyDeclaration) {
            NSArray* tokens = [self getStringTokensFromCursor:propertyDeclaration->declInfo->cursor];
            NSString* name = [NSString stringWithUTF8String:propertyDeclaration->declInfo->entityInfo->name];
            
            DFPropertyDefinition* propertyDef = [[DFPropertyDefinition alloc] initWithName:name andTokens:tokens];
            [self.currentContainerDef.childDefinitions setObject:propertyDef forKey:name];
        }
    }
}

// Examine the code to search for multiple property relationships with arrays and dictionaries
- (void)processMethodDeclaration:(const CXIdxDeclInfo *)declaration {
    clang_visitChildrenWithBlock(declaration->cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
        
        if (cursor.kind == CXCursor_ObjCMessageExpr) {
            __block NSString* memberName = nil;
            __block NSString* referencedObjectName = nil;
            
            clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
                if (cursor.kind == CXCursor_MemberRefExpr) {
                    memberName = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(cursor))];
                    referencedObjectName = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(clang_getCursorSemanticParent(clang_getCursorReferenced(cursor))))];
                } else {
                    if (memberName) {
                        __block NSString* passedClassName = nil;
                        __block NSMutableArray* passedProtocolNames = [NSMutableArray array];
                        
                        clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
                            if (cursor.kind == CXCursor_DeclRefExpr) {
                                CXCursor def = clang_getCursorDefinition(cursor);
                                
                                __block int index = 0;
                                clang_visitChildrenWithBlock(def, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
                                    NSString* token = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(cursor))];

                                    // First token is className, remaining are protocols
                                    if (!index) {
                                        passedClassName = token;
                                    } else {
                                        [passedProtocolNames addObject:[NSString stringWithFormat:@"<%@>", token]];
                                    }
                                    index ++;
                                    
                                    return CXChildVisit_Continue;
                                });
                            }
                            
                            return CXChildVisit_Recurse;
                        });
                        
                        DFContainerDefinition* ownerObject = [self.definitions objectForKey:referencedObjectName];
                        
                        DFPropertyDefinition* messagedProperty = [[ownerObject childDefinitions] objectForKey:memberName];
                        if (messagedProperty && passedClassName) {
                            if ([messagedProperty.typeName isEqualToString:@"NSMutableArray"] || [messagedProperty.typeName isEqualToString:@"NSMutableDictionary"]) {
                                
                                // We have discovered that passedClassName<passedProtocolNames> is passed to a mutable array or dictionary property of ownerObject,
                                // so we assume that ownerObject owns multiple passedObjects
                                
                                // Replace the array/dictionary property with a new collection property
                                DFCollectionPropertyDefinition* collectionProperty = [[DFCollectionPropertyDefinition alloc] initWithTypeName:passedClassName protocolNames:passedProtocolNames name:memberName isWeak:messagedProperty.isWeak];

                                [[ownerObject childDefinitions] setObject:collectionProperty forKey:memberName];
                            }
                        } 
                        return CXChildVisit_Break;
                    }
                }
                return CXChildVisit_Continue;
            });
        }
        return CXChildVisit_Recurse;
    });
}

#pragma mark - Utility methods

- (DFDefinition*)getDefinitionWithName:(NSString*)name andType:(Class)classType {
    if (![classType isSubclassOfClass:[DFDefinition class]]) {
        return nil;
    }
    
    DFDefinition* def = [self.definitions objectForKey:name];
    if (!def) {
        def = [[classType alloc] initWithName:name];
        [self.definitions setObject:def forKey:name];
    }
    return def;
}

- (NSMutableArray*)getStringTokensFromCursor:(CXCursor)cursor {
    CXTranslationUnit translationUnit = self.currentParser.translationUnit;
    CXSourceRange range = clang_getCursorExtent(cursor);
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

@end
