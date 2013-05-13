//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"
#import "DFClassParser.h"
#import "DFClassModel.h"

@interface DFyUMLBuilder ( /* Private */ )
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) NSArray* classNames;
@property (nonatomic) NSMutableDictionary* classModels;
@end

@implementation DFyUMLBuilder

- (id)initWithFilenames:(NSArray*)fileNames andClassNames:(NSArray*)classNames {
    self  = [super init];
    if (self) {
        _fileNames = fileNames;
        _classNames = classNames;
    }
    return self;
}

- (NSString*)buildyUML {
    self.classModels = [[NSMutableDictionary alloc] init];
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        DFClassParser* parser = [[DFClassParser alloc] initWithFileName:obj];
        parser.delegate = self;
        [parser parseWithCompletion:^(NSError* error){
            
        }];
    }];
    
    return nil;
}

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const name = declaration->entityInfo->name;
    if (name == NULL)
        return;
    
    NSString *declarationName = [NSString stringWithUTF8String:name];
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
        {
            if ([self careAboutClassName:declarationName]) {
                DFClassModel* classModel = [self.classModels objectForKey:declarationName];
                if (!classModel) {
                    classModel = [[DFClassModel alloc] init];
                    [self.classModels setObject:classModel forKey:declarationName];
                    classModel.name = declarationName;
                }
                
                const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
                if (declarationInfo) {
                    const CXIdxBaseClassInfo* superClassInfo = declarationInfo->superInfo;
                    if (superClassInfo) {
                        const char* name = superClassInfo->base->name;
                        if (name) {
                            NSString* superClassName = [NSString stringWithUTF8String:name];
                            if ([self careAboutClassName:superClassName]) {
                                DFClassModel* superClassModel = [[DFClassModel alloc] init];
                                superClassModel.name = superClassName;
                                classModel.superClass = superClassModel;
                            }
                        }
                        name = NULL;
                    }
                }
            }
            break;
        }
            
        default:
        {
            break;
        }
    }    
}

- (BOOL)careAboutClassName:(NSString*)className {
    __block BOOL care = NO;
    [self.classNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:className]) {
            *stop = care = YES;
        }
    }];
    return care;
}

@end
