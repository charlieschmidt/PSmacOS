//
//  GridViewerApplicationDelegate.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import "GridViewerApplicationDelegate.h"
#import "PSObjectGridViewController.h"

@interface GridViewerApplicationDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end

@implementation GridViewerApplicationDelegate

-(void)createMenu {
    NSMenu *menuBar = [[NSMenu alloc] initWithTitle:@"GridView"];
    [NSApp setMainMenu:menuBar];
    
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [menuBar addItem:appMenuItem];
    
    NSMenu *appMenu = [NSMenu new];
    [appMenuItem setSubmenu:appMenu];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:[@"Quit " stringByAppendingString:@"GridView"]
                                                          action:@selector(terminate:)
                                                   keyEquivalent:@"q"];
    [appMenu addItem:quitMenuItem];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"appdid finish launching");
    //PSObjectGridViewController *controller = [[PSObjectGridViewController alloc] init];
    
    [self createMenu];
    //self.window = [NSWindow windowWithContentViewController:controller];
    //self.window.contentViewController = controller;
    
    [self.window orderFrontRegardless];
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}


@end
