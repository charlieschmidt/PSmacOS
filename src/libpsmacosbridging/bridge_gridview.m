
#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

@interface PSObjectStreamReader: NSObject <NSStreamDelegate> 

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode ;

@property (strong, nonatomic) NSString *buffer;
@property (strong, nonatomic) void (^objectProcessor)(NSString *object, NSError *error);

@end


@implementation PSObjectStreamReader

@synthesize buffer = _buffer;
@synthesize objectProcessor = _objectProcessor;
uint8_t buf[1024];

-(id)initWithBlock:(void (^)(NSString *object, NSError *error))block {
    if ( self = [super init] ) {
        _objectProcessor = block;
    }
    return self;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
    switch (event) {
        case NSStreamEventErrorOccurred:
            self.objectProcessor(nil, [stream streamError]);
            break;
        case NSStreamEventHasBytesAvailable:
            [self readAvailableDataFromStream:stream];
            break;
        case NSStreamEventEndEncountered:
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            if (self.buffer) {
                self.objectProcessor(self.buffer, nil);
                self.buffer = nil;
            }
            
            self.objectProcessor = nil;
            break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventNone:
        case NSStreamEventOpenCompleted:
            break;
    }
}

- (void)readAvailableDataFromStream:(NSStream *)stream
{
    unsigned int len = [(NSInputStream *)stream read:buf maxLength:1024];

    if (len) {
        if (self.buffer) {
            // append
            self.buffer = [self.buffer stringByAppendingString:[[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding]];
        } else {
            self.buffer = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
        }

        NSArray *lines = [self.buffer componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];        
        NSString *lastLine = nil;
        
        for (NSString *currentLine in lines) {
            if (lastLine) {
                self.objectProcessor(lastLine, nil);

                lastLine = @"";
            }
            if (![currentLine isEqualToString:@""]) {
                lastLine = currentLine;
            }
        }
        
        //left over
        self.buffer = lastLine;
    }    
}

@end




void startGridView() {

    NSLog(@"startGridView()");

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

    PSObjectStreamReader *reader = [[PSObjectStreamReader alloc] initWithBlock:^(NSString *object, NSError *error)  {
        if (error) {
     
        } else {
            NSLog(@"new record to add: %@",object);
            [textView insertText:object replacementRange:NSMakeRange(0,0)];
        }
    }];
    [reader autorelease];

    // iStream is NSInputStream instance variable
    NSInputStream *stdin = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
    [stdin setDelegate:reader];
    [stdin scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stdin open];


   // [textView insertText:@"Hello OSX/Cocoa world!" replacementRange:NSMakeRange(0,0)];

    // TODO: Create app delegate to handle system events.
    // TODO: Create menus (especially Quit!)

    // Show window and run event loop.
    [window orderFrontRegardless];

    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];

    NSLog(@"Running NSApp");
    [NSApp run];
    
    NSLog(@"NSApp exitied");
    return;
}
