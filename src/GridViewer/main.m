//
//  main.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "GVApplicationDelegate.h"

int main(int argc, const char * argv[]) {
    GVApplicationDelegate *del = [[GVApplicationDelegate alloc] init];
    
    [NSApplication sharedApplication];
    [NSApp setDelegate:del];
    /*
    NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
    NSData *inputData = [NSData dataWithData:[input availableData]];
    NSString *inputString = [[NSString alloc]
                             initWithData:inputData encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [inputString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    
    for (NSString *line in lines) {
        NSLog(@"got line: '%@'",line);
    }
    NSLog(@"and still starting app");
    */
    return NSApplicationMain(argc, argv);
}
