
#include <Cocoa/Cocoa.h>


@interface MyApplicationDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow * window;
}
@end

@implementation MyApplicationDelegate : NSObject
- (id)init {
    if (self = [super init]) {
        NSUInteger windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;

        // Window bounds (x, y, width, height).
        NSRect windowRect = NSMakeRect(100, 100, 400, 400);
        window = [[NSWindow alloc] initWithContentRect:windowRect
                                            styleMask:windowStyle
                                            backing:NSBackingStoreBuffered
                                            defer:NO];
        [window autorelease];

        // Window controller:
        NSWindowController * windowController = [[NSWindowController alloc] initWithWindow:window];
        [windowController autorelease];

        // This will add a simple text view to the window,
        // so we can write a test string on it.
        NSTextView * textView = [[NSTextView alloc] initWithFrame:windowRect];
        [textView autorelease];

        [window setContentView:textView];
        [textView insertText:@"Hello OSX/Cocoa world!" replacementRange:NSMakeRange(0,0)];

        // TODO: Create app delegate to handle system events.
        // TODO: Create menus (especially Quit!)

        // Show window and run event loop.
        [window orderFrontRegardless];
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSLog(@"finished?");
    [window makeKeyAndOrderFront:self];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end

int showGridView() {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

NSLog(@"main nsrunloop: %@",[NSRunLoop mainRunLoop]);
NSLog(@"in showGridView()");
NSLog(@"going async");
    //dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSRunLoop mainRunLoop] performBlock:^{
        NSLog(@"hello world");
    
        [NSAutoreleasePool new];
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        NSUInteger windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;

        // Window bounds (x, y, width, height).
        NSRect windowRect = NSMakeRect(100, 100, 400, 400);
        NSWindow *window = [[NSWindow alloc] initWithContentRect:windowRect
                                            styleMask:windowStyle
                                            backing:NSBackingStoreBuffered
                                            defer:NO];
        [window autorelease];

        // Window controller:
        NSWindowController * windowController = [[NSWindowController alloc] initWithWindow:window];
        [windowController autorelease];

        // This will add a simple text view to the window,
        // so we can write a test string on it.
        NSTextView * textView = [[NSTextView alloc] initWithFrame:windowRect];
        [textView autorelease];

        [window setContentView:textView];
        [textView insertText:@"Hello OSX/Cocoa world!" replacementRange:NSMakeRange(0,0)];

        // TODO: Create app delegate to handle system events.
        // TODO: Create menus (especially Quit!)

        // Show window and run event loop.
        [window orderFrontRegardless];

        [window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        [NSApp run];
        dispatch_semaphore_signal(sema);
    }];

    //dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  //  dispatch_release(sema);
    


    return EXIT_SUCCESS;
}

