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
NSDictionary* parseColoursFromFile(NSString* fileName);
NSDictionary* defaultColours();
    
int main(int argc, char * argv[]) {

    @autoreleasepool {
        
        // Process command line options
        static const char *optstring = "c:";
        char* configFileArg = optarg;
        
        int ch;
        while ((ch = getopt_long(argc, argv, optstring, NULL, NULL)) != -1) {
            switch(ch) {
                case 'c':
                    configFileArg =  optarg;
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
        
        for (int i=optind; i<argc; ++i) {
            [filenames addObject:[NSString stringWithUTF8String:argv[i]]];
        }

        NSDictionary* colours = nil;
        if (configFileArg) {
            NSString* configFilePath = [NSString stringWithUTF8String:configFileArg];
            colours = parseColoursFromFile(configFilePath);
        } else {
            colours = defaultColours();
        }
        
        // Redirect clang errors to the void
        //freopen("/dev/null", "w", stderr);

        DFModelBuilder* modelBuilder = [[DFModelBuilder alloc] initWithFilenames:filenames];
        [modelBuilder buildModelWithCompletion:^(NSError *error) {
            if (!error) {
                DFyUMLBuilder* yUMLBuilder = [[DFyUMLBuilder alloc] initWithDefinitions:modelBuilder.definitions
                                                                    keyClassDefinitions:[modelBuilder keyClassDefinitions]
                                                                         andColourPairs:colours];
                NSString* yUML = [yUMLBuilder generate_yUML];
                
                // print to stdout 
                NSPrint(yUML);
            }
        }];
    }

    return EXIT_SUCCESS;
}

void NSPrint(NSString* str){
    [str writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

// TODO:
NSDictionary* parseColoursFromFile(NSString* filePath) {
    NSData *data = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        data = [fileManager contentsAtPath:filePath];
        
        NSString* contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", contents);
    }

    return nil;
}

NSDictionary* defaultColours() {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"green", @"UIViewController",
            @"orchid", @"UIView",
            @"orange", @"DFDataModel",
            @"gray", @"NSObject",
            @"pink", @"<NSObject>",
            nil];
}

