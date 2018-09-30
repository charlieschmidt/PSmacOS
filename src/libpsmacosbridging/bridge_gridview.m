
#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

@interface PSObjectStore: NSObject <NSStreamDelegate,NSTableViewDataSource>

-(id)initWithBlock:(void (^)())dataAvailableBlock;

@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) void (^dataAvailable)();

/* NSStreamDelegate */
@property (strong, nonatomic) NSString *buffer;

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode ;
/* */


/* NSTableViewDataSource */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
/* */


@end


@implementation PSObjectStore
 
@synthesize buffer = _buffer;
@synthesize objects = _objects;
@synthesize dataAvailable = _dataAvailable;

uint8_t buf[1024];

-(id)initWithBlock:(void (^)())dataAvailableBlock {
    if (self = [super init]) {
        _dataAvailable = dataAvailableBlock;
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
    switch (event) {
        case NSStreamEventHasBytesAvailable:
            [self readAvailableDataFromStream:stream];
            break;
        case NSStreamEventEndEncountered:
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            if (self.buffer) {
                [self.objects addObject:self.buffer];
                self.buffer = nil;
                self.dataAvailable();
            }
            
            self.dataAvailable = nil;
            
            break;
        case NSStreamEventErrorOccurred:
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
                [self.objects addObject:currentLine];

                lastLine = @"";
            }
            if (![currentLine isEqualToString:@""]) {
                lastLine = currentLine;
            }
        }

        self.dataAvailable();
        
        //left over
        self.buffer = lastLine;
    }    
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.objects count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.objects objectAtIndex:row];
}

@end



@interface GridViewerApplicationDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow *window;
    NSTableView *tableView;
    PSObjectStore *objectStore;
}
@end

@implementation GridViewerApplicationDelegate : NSObject
- (id)init {
    if (self = [super init]) {
        NSUInteger windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;

        // Window bounds (x, y, width, height).
        NSRect windowRect = NSMakeRect(100, 100, 400, 400);
        window = [[NSWindow alloc] initWithContentRect:windowRect
                                            styleMask:windowStyle
                                            backing:NSBackingStoreBuffered
                                            defer:NO];
        

        // menu
        NSMenu* menubar = [NSMenu new]; 
        NSMenuItem* appMenuItem = [NSMenuItem new];
        [menubar addItem:appMenuItem];
        [NSApp setMainMenu:menubar];

        NSMenu* appMenu = [NSMenu new];
        NSString* quitTitle = [@"Quit " stringByAppendingString:@"GridViewer"];
        NSMenuItem* quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                        action:@selector(terminate:)
                                                keyEquivalent:@"q"];
        [appMenu addItem:quitMenuItem];
        [appMenuItem setSubmenu:appMenu];


        // window controller
        NSWindowController * windowController = [[NSWindowController alloc] initWithWindow:window];
        


        // tableView
        // create a table view and a scroll view
        NSScrollView *tableContainer = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, 380, 200)];
        tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 364, 200)];
        // create columns for our table
        NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"Col1"];
        NSTableColumn *column2 = [[NSTableColumn alloc] initWithIdentifier:@"Col2"];
        [column1 setWidth:252];
        [column2 setWidth:198];
        // generally you want to add at least one column to the table view.
        [tableView addTableColumn:column1];
        [tableView addTableColumn:column2];
        [tableView setDelegate:self];
        [tableView reloadData];
        // embed the table view in the scroll view, and add the scroll view
        // to our window.
        [tableContainer setDocumentView:tableView];
        [tableContainer setHasVerticalScroller:YES];
        
        [window setContentView:tableContainer];

        // wire up object store & tableview
        __weak NSTableView *weakTableView = tableView;
        objectStore = [[PSObjectStore alloc] initWithBlock:^() {
            [weakTableView reloadData];
        }]; 
        [tableView setDataSource:objectStore];

        //__weak NSTableView *weakTableView = tableView;

        /*WithBlock:^(NSString *object, NSError *error)  {
            if (error) {
        NSLog(@"some error");
            } else {
                NSLog(@"new record to add: %@",object);
                [weakTableView reloadData];
                //[weakTableView insertText:object replacementRange:NSMakeRange(0,0)];
            }
        }];
        */
        
        // read from stdin for objects
        NSInputStream *stdin = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
        [stdin setDelegate:objectStore];
        [stdin scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [stdin open];
    }

    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [window orderFrontRegardless];
    [window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end



void startGridView() {

    NSLog(@"startGridView()");

    NSApplication *application = [NSApplication sharedApplication];

    [application setActivationPolicy:NSApplicationActivationPolicyRegular];
    GridViewerApplicationDelegate *appDelegate = [[GridViewerApplicationDelegate alloc] init];

    [application setDelegate:appDelegate];
    [application activateIgnoringOtherApps:YES];

    NSLog(@"Running NSApp");
    [application run];

    NSLog(@"NSApp exitied");

    return;
}

