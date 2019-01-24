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
    
    return NSApplicationMain(argc, argv);
}
