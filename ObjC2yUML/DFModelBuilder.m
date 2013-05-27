//
//  DFModelBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFModelBuilder.h"
#import "DFDefinition.h"
#import "DFClangParser.h"
// Definitions
#import "DFClassDefinition.h"
#import "DFProtocolDefinition.h"
#import "DFPropertyDefinition.h"

@interface DFModelBuilder ( /* Private */ )
@property (nonatomic) NSMutableDictionary* definitions;
@property (nonatomic) NSMutableArray* implementationNames;
@property (nonatomic) DFContainerDefinition* currentContainer;
@end

@implementation DFModelBuilder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        
        self.definitions = [NSMutableDictionary dictionary];
        self.implementationNames = [NSMutableArray array];
        
        [self buildModel:fileNames];
    }
    return self;
}

- (void)buildModel:(NSArray*)fileNames {
    [fileNames enumerateObjectsUsingBlock:^(NSString* fileName, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            DFClangParser* parser = [[DFClangParser alloc] initWithFileName:fileName];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                
            }];
        }
    }];
}

#pragma mark DFClangParserDelegate

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const cName = declaration->entityInfo->name;
    if (cName == NULL)
        return;
    
    NSString *declarationName = [NSString stringWithUTF8String:cName];
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
        {
            DFClassDefinition* classDef = (DFClassDefinition*)[self getDefinitionWithName:declarationName andType:[DFClassDefinition class]];
            self.currentContainer = classDef;
            
            const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
            if (declarationInfo) {
                const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
                
                if (containerInfo) {
                    if (containerInfo->kind == CXIdxObjCContainer_Implementation) {
                        // Found an implementation
                        [self.implementationNames addObject:declarationName];
                    } else if (containerInfo->kind == CXIdxObjCContainer_Interface) {
                        
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
                            NSString* protocolName = [NSString stringWithUTF8String:protocolRefInfo->protocol->name];
                            
                            DFProtocolDefinition* protocolDef = (DFProtocolDefinition*)[self getDefinitionWithName:protocolName andType:[DFProtocolDefinition class]];
                            if (![classDef.protocols objectForKey:protocolName]) {
                                [classDef.protocols setObject:protocolDef forKey:protocolName];
                            }
                        }
                    }
                }
            }        
            break;
        }
        case CXIdxEntity_ObjCCategory:
        {
            // Just extend the original class, discard the fact that we are in a category
            DFClassDefinition* classDef = (DFClassDefinition*)[self getDefinitionWithName:declarationName andType:[DFClassDefinition class]];
            self.currentContainer = classDef;
            
            NSLog(@"%@", declarationName);
            break;
        }
        case CXIdxEntity_ObjCProtocol:
        {
            DFProtocolDefinition* protocolDef = (DFProtocolDefinition*)[self getDefinitionWithName:declarationName andType:[DFProtocolDefinition class]];
            self.currentContainer = protocolDef;
            break;
        }
        case CXIdxEntity_ObjCProperty:
        {
            const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);
            if (propertyDeclaration) {
                // Parse property info from type encoding
                NSString* typeEncoding = [NSString stringWithUTF8String:clang_getCString(clang_getDeclObjCTypeEncoding(propertyDeclaration->declInfo->cursor))];
                NSString* propertyClassDefName = [DFPropertyDefinition classNameFromEncoding:typeEncoding];
                // TODO
                //NSArray* propertyProtocolDefNames = [DFPropertyDefinition protocolNamesFromEncoding:typeEncoding];
                DFPropertyReferenceType propertyRefType = [DFPropertyDefinition referenceTypeFromEncoding:typeEncoding];
                
                if ([propertyClassDefName length]) {
                    DFPropertyDefinition* propertyDef = [[DFPropertyDefinition alloc] initWithName:declarationName];
                    propertyDef.referenceType = propertyRefType;
                    propertyDef.classDefinition = (DFClassDefinition*)[self getDefinitionWithName:propertyClassDefName andType:[DFClassDefinition class]];
                    [self.currentContainer.childDefinitions setObject:propertyDef forKey:declarationName];
                }
            }

            break;
        }
        default:
            break;
    }
}

#pragma mark - Utility methods

- (DFDefinition*)getDefinitionWithName:(NSString*)name andType:(Class)classType {
    if (![classType isKindOfClass:[DFDefinition class]]) {
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
