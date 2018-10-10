//
//  PSObjectGridViewController.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

// line-by-line NSStreamDelegate inspired/copied from https://github.com/AlexMoffat/line-by-line-ios-file-reader

#import "PSObjectGridViewController.h"

@interface PSObjectGridViewController () <NSTableViewDataSource, NSTableViewDelegate, NSStreamDelegate>

@property (strong) IBOutlet NSArrayController *objects;

@property (weak) IBOutlet NSTableView *tableView;

// Buffer to hold any unprocessed string data after each loop.
@property (strong, nonatomic) NSString *stringBuffer;


@end


@implementation PSObjectGridViewController

@synthesize stringBuffer;
@synthesize objects;



unsigned int const TRY_TO_READ = 1024;
uint8_t _buffer[TRY_TO_READ];
- (void)readDataFromStream:(NSStream *)theStream
{
    NSInteger length = [(NSInputStream *)theStream read:_buffer maxLength:TRY_TO_READ];
    if (length) {
        if (self.stringBuffer) {
            // Some data left from the last time this method was called so
            // append the new data.
            self.stringBuffer = [self.stringBuffer stringByAppendingString:[[NSString alloc] initWithBytes:_buffer length:length encoding:NSUTF8StringEncoding]];
        } else {
            // No data left over from last time.
            self.stringBuffer = [[NSString alloc] initWithBytes:_buffer length:length encoding:NSUTF8StringEncoding];
        }
        // Split on newlines.
        NSArray *lines = [self.stringBuffer componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
        // Lines are processed in arrears, that is each time round the loop we send
        // to the lineProcessor the line read on the previous time round. This is because
        // we might not get a complete last line. However, if the whole stringBuffer ends
        // with the newlines then we get an empty string and so know we read a complete
        // line. Any remaining data is stored in stringBuffer and used on the next loop
        // or sent when the stream is closed.
        NSString *lineToProcess = nil;
        for (NSString *line in lines) {
            if (lineToProcess) {
                [self addJsonObject:lineToProcess];
                // Use an empty string here so that files
                // that end with a newline have a final empty
                // line just like if reading with stringWithContentsOfFile
                // and then splitting.
                lineToProcess = @"";
            }
            if (![line isEqualToString:@""]) {
                lineToProcess = line;
            }
        }
        // Leave any remaining data in the buffer.
        self.stringBuffer = lineToProcess;
    }    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    if (streamEvent & NSStreamEventErrorOccurred) {
        return;
    }
    if (streamEvent & NSStreamEventHasBytesAvailable) {
        [self readDataFromStream:stream];
    }
    if (streamEvent & NSStreamEventEndEncountered) {  
        [stream close];
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        // Treat anything left in stringBuffer as the remaining line.
        if (self.stringBuffer) {
            [self addJsonObject:self.stringBuffer];
            self.stringBuffer = nil;
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"init view controller start");

    NSStream *stdinStream = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
    [iStstdinStreamream setDelegate:self];
    [stdinStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stdinStream open];

    NSLog(@"init view controller done");
    
    /*
    [self addJsonObject:@"{\"a\":\"the thing\",\"b\":\"the other\"}"];
    [self addJsonObject:@"{\"a\":\"2the thing\",\"b\":\"2the other\"}"];
    [self addJsonObject:@"{\"a\":\"3the thing\",\"b\":\"3the other\"}"];
    */
}


BOOL firstRun = YES;
- (void)addJsonObject:(NSString*)json {
    if (json != nil && [json isEqualToString:@""] == false) {
        NSError *jsonError;
        NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&jsonError];
        
        [self.objects addObject:object];
        
        if (firstRun == YES) {
            NSLog(@"firing store has initial object in delegate");
            [self setupColumns:object];
            firstRun = NO;
        }
    }
}

- (void)setupColumns:(NSDictionary *)object
{
    for (NSString *key in object) {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = key;
        NSLog(@"Adding column for %@ to tableview",key);
        
        NSString *keypath = [NSString stringWithFormat:@"arrangedObjects.%@",key];
        [column bind:NSValueBinding toObject:self.objects withKeyPath:keypath options:nil];
        
        [self.tableView addTableColumn:column];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.objects.arrangedObjects count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[self.objects.arrangedObjects objectAtIndex:row] valueForKey:tableColumn.identifier];
}

@end
