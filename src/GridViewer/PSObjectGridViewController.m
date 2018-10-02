//
//  PSObjectGridViewController.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import "PSObjectGridViewController.h"

@interface PSObjectGridViewController ()

@property (strong) IBOutlet NSArrayController *objects;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong, nonatomic) NSString *buffer;

@end

@implementation PSObjectGridViewController

@synthesize objects;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    

    
    NSLog(@"init view controller");
    // read from stdin for objects
    NSInputStream *stdin = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
    [stdin setDelegate:self];
    [stdin scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stdin open];
    
    /*
    [self addJsonObject:@"{\"a\":\"the thing\",\"b\":\"the other\"}"];
    [self addJsonObject:@"{\"a\":\"2the thing\",\"b\":\"2the other\"}"];
    [self addJsonObject:@"{\"a\":\"3the thing\",\"b\":\"3the other\"}"];
    */
}


BOOL firstRun = YES;

uint8_t buf[1024];

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
            //[self.delegate storeDidChange:self];
            firstRun = NO;
        }
    }
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
                [self addJsonObject:self.buffer];
                _buffer = nil;
                //[self.delegate storeDidChange:self];
            }
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
    NSInteger len = [(NSInputStream *)stream read:buf maxLength:1024];
    
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
                [self addJsonObject:lastLine];
                
                lastLine = @"";
            }
            if (![currentLine isEqualToString:@""]) {
                lastLine = currentLine;
            }
        }
        
        [self.tableView reloadData];
        
        //left over
        self.buffer = lastLine;
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
