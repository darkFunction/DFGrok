//
//  main.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//
#import <getopt.h>
#import <Foundation/Foundation.h>
#import "DFModelBuilder.h"
#import "DFyUMLBuilder.h"

int main(int argc, char * argv[]) {
    
    // Process command line options
    static struct option longopts[] = {
        { "if",         required_argument,  NULL,   'f' },
        { "colours",    optional_argument,  NULL,   'c' },
        { NULL,         0,                  NULL,   0 },
    };
    
    static const char *optstring = "v";
    int ch;
    while ((ch = getopt_long(argc, argv, optstring, longopts, NULL)) != -1) {        
        switch(ch) {
            case 'f':
                printf("File name is: %s", optarg);
                break;
                
            case 'c':
                printf("Colour name is: %s", optarg);
                break;
                
            case ':':
                puts("Missing required argument");
                break;
            
            case '?':
                puts("Unknown option");
                break;
        }
    }
    
    @autoreleasepool {
        
        NSArray* filenames = [NSArray arrayWithObjects:
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoController.m",
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDataModelContainer.m",
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDataModel.m",
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataSource.m",
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataModelOne.m",
                              @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataModelTwo.m",
                              nil];

        DFModelBuilder* modelBuilder = [[DFModelBuilder alloc] initWithFilenames:filenames];
        [modelBuilder buildModelWithCompletion:^(NSError *error) {
            if (!error) {
                
                NSDictionary* colours = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"green", @"UIViewController",
                                             @"orchid", @"UIView",
                                             @"orange", @"BMAModel",
                                             nil];
                
                DFyUMLBuilder* yUMLBuilder = [[DFyUMLBuilder alloc] initWithDefinitions:modelBuilder.definitions
                                                                          keyDefintions:[modelBuilder keyClassDefinitions]
                                                                         andColourPairs:colours];
                
                NSString* yUML = [yUMLBuilder generate_yUML];
                NSLog(@"%@", yUML);
            }
        }];

  
        
    }

    return EXIT_SUCCESS;
}