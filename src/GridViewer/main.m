//
//  main.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GridViewerApplicationDelegate.h"
int main(int argc, const char * argv[]) {
    
    [NSApplication sharedApplication];
    [NSApp setDelegate: [[GridViewerApplicationDelegate alloc] init]];
    
    return NSApplicationMain(argc, argv);
}
