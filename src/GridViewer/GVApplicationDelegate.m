//
//  GVApplicationDelegate.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import "GVApplicationDelegate.h"
#import "GVObjectTableViewController.h"
#import "GVWindowController.h"

@interface GVApplicationDelegate ()

@end

@implementation GVApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
    
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    NSLog(@"args: %@",args);
    NSLog(@"arg count: %lu",(unsigned long)args.count);
    NSLog(@"arg: '%@'",[args objectAtIndex:1]);
    
    if (args.count == 2) {
        [mainWindow setTitle:[args objectAtIndex:1]];
    } else {
        [mainWindow setTitle:@"GridView"];
    }
    
    [mainWindow orderFrontRegardless];
    [mainWindow makeKeyAndOrderFront:nil];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
