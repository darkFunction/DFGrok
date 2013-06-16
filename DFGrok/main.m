//
//  main.m
//  DFGrok
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//
#import <getopt.h>
#import <Foundation/Foundation.h>
#import "DFModelBuilder.h"
#import "DFyUMLBuilder.h"

void NSPrint(NSString* str);

int main(int argc, char * argv[]) {

    @autoreleasepool {
        
        // Process command line options
        static const char *optstring = "c:";
        int ch;
        while ((ch = getopt_long(argc, argv, optstring, NULL, NULL)) != -1) {
            switch(ch) {
                case 'c':
                    printf("Colour is: %s", optarg);
                    break;
                    
                case ':':
                    puts("Missing required argument");
                    break;
                
                case '?':
                    puts("Unknown option");
                    break;
            }
        }
        
        NSMutableArray* filenames = [NSMutableArray arrayWithCapacity:(argc - optind)];

        // Test files!
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoController.m",
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDataModelContainer.m",
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDataModel.m",
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataSource.m",
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataModelOne.m",
        //          @"/Users/samtaylor/Projects/ObjC2yUML/UMLTestProject/UMLTestProject/Classes/DFDemoDataModelTwo.m",

        for (int i = optind; i < argc; i++) {
            [filenames addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        
        // Redirect clang errors to the void
        freopen("/dev/null", "w", stderr);
        

        DFModelBuilder* modelBuilder = [[DFModelBuilder alloc] initWithFilenames:filenames];
        [modelBuilder buildModelWithCompletion:^(NSError *error) {
            if (!error) {
                
                NSDictionary* colours = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"green", @"UIViewController",
                                             @"orchid", @"UIView",
                                             @"orange", @"DFDataModel",
                                             @"white", @"NSObject",
                                             nil];
                
                DFyUMLBuilder* yUMLBuilder = [[DFyUMLBuilder alloc] initWithDefinitions:modelBuilder.definitions
                                                                          keyDefintions:[modelBuilder keyClassDefinitions]
                                                                         andColourPairs:colours];
                
                NSString* yUML = [yUMLBuilder generate_yUML];
                
                // print to stdout 
                NSPrint(yUML);
            }
        }];

  
        
    }

    return EXIT_SUCCESS;
}

void NSPrint(NSString* str)
{
    [str writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

