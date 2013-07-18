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
        {
            clang_visitChildrenWithBlock(declaration->cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
         
                if (cursor.kind == CXCursor_ObjCMessageExpr) {
                    __block NSString* memberName = nil;
                    __block NSString* methodName = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(cursor))];

                    clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
                        if (cursor.kind == CXCursor_MemberRefExpr) {
                            memberName = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(cursor))];
                            
                            return CXChildVisit_Continue;
                        }
                        
                        if (memberName) {
                            NSLog(@"Messaging %@ using method name: %@ with parameter: %s", memberName, methodName, clang_getCString(clang_getCursorSpelling(cursor)));
                        }
                        return CXChildVisit_Break;
                    });
                }
                
                

                if (cursor.kind == CXCursor_MemberRefExpr) {
                    if (parent.kind == CXCursor_ObjCMessageExpr) {
                        // Sending a message to a member variable
                        NSString* memberName = [NSString stringWithUTF8String:clang_getCString(clang_getCursorDisplayName(parent))];
                        //NSLog(@"%s -> %@", clang_getCString(clang_getCursorDisplayName(cursor)), memberName);

                        
//                        // need to grab the class def for the type we are messaging.. in this case self but for others too
//                        CXCursor test = clang_getCursorSemanticParent(clang_getCursorSemanticParent(cursor));
//                        CXCursor def = clang_getCursorDefinition(test);
//                        CXType type = clang_getCursorType(cursor);
                        
                        // if self...
                        DFPropertyDefinition* messagedProperty = [[self.currentContainerDef childDefinitions] objectForKey:memberName];
                        if (messagedProperty) {
                            if ([messagedProperty.className isEqualToString:@"NSMutableArray"] || [messagedProperty.className isEqualToString:@"NSMutableDictionary"]) {
                                // what did we pass in?
                            }
                        }
                        
                        
                    }
                }
                return CXChildVisit_Recurse;
            });
            break;
        }
        default:
            break;
    }
}

- (void)classParser:(DFClangParser *)parser foundEntityReference:(const CXIdxEntityRefInfo *)entityRef {
//    if (entityRef->parentEntity)
//    NSLog(@"%@ -> %d -> %s -> %s", self.currentContainerDef.name, entityRef->parentEntity->kind, entityRef->parentEntity->name, entityRef->referencedEntity->name);
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
            DFPropertyDefinition* propertyDef = [[DFPropertyDefinition alloc] initWithDeclaration:propertyDeclaration andTranslationUnit:self.currentParser.translationUnit];
            [self.currentContainerDef.childDefinitions setObject:propertyDef forKey:name];
        }
    }
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

@end
