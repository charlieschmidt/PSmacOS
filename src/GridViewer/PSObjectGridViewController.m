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

@property (weak) IBOutlet NSSearchFieldCell *searchField;

@property (weak) IBOutlet NSTableView *tableView;

- (IBAction)searchFieldChanged:(id)sender;

// Buffer to hold any unprocessed string data after each loop.
@property (strong, nonatomic) NSString *stringBuffer;

@end



@implementation NSDictionary (PSObject)

- (NSDictionary *)dictionaryFromPSObjectJSON {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *key;
    
    for (key in self) {
        id val = [self objectForKey:key];
        
        if (val == (id)[NSNull null]) {
            //NSLog(@"%@ is null",key);
            Class klass = [val class];
            if ([klass isSubclassOfClass:[NSString class]]) {
              //  NSLog(@"its a string");
                val = @"";
            }
            else if ([klass isSubclassOfClass:[NSNumber class]]) {
                //NSLog(@"its a number");
                val = [[NSNumber alloc] init];
            }
        }
        
        [result setObject:val forKey:[key lowercaseString]];
    }
    
    return result;
}

@end



@implementation PSObjectGridViewController

@synthesize stringBuffer;
@synthesize objects;

- (IBAction)searchFieldChanged:(id)sender {
    NSLog(@"asked for predicate");
    if (allKeys && [allKeys count] > 0 && [self.searchField.stringValue isEqualToString:@""] == false) {
        NSMutableArray *subPredicates = [NSMutableArray array];
        for (NSString *key in allKeys) {
            NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"%K contains %@", key, self.searchField.stringValue];
            [subPredicates addObject:subPredicate];
        }
        NSPredicate *filter = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];
        NSLog(@"predicate is %@",filter);
        [self.objects setFilterPredicate:filter];
        [self.tableView reloadData];
    } else {
        [self.objects setFilterPredicate:nil];
        [self.tableView reloadData];
    }
}

unsigned int const TRY_TO_READ = 1024;
uint8_t _buffer[TRY_TO_READ];

- (void)readDataFromStream:(NSStream *)theStream {
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
                [self processLine:lineToProcess];
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

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
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
            [self processLine:self.stringBuffer];
            self.stringBuffer = nil;
        }
    }
}



- (void)viewDidLoad {
    NSLog(@"viewDidLoad start");
    [super viewDidLoad];
    
    
    NSStream *stdinStream = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
    [stdinStream setDelegate:self];
    [stdinStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stdinStream open];
    
    NSLog(@"viewDidLoad end");
    
    /*
     [self addJsonObject:@"{\"a\":\"the thing\",\"b\":\"the other\"}"];
     [self addJsonObject:@"{\"a\":\"2the thing\",\"b\":\"2the other\"}"];
     [self addJsonObject:@"{\"a\":\"3the thing\",\"b\":\"3the other\"}"];
     */
}

typedef NS_ENUM(NSUInteger, LineType) {
    Titles = 0,
    Types = 1,
    Data = 2
};

LineType currentLineType = Titles;

- (void)processLine:(NSString*)line {
    switch (currentLineType) {
        case Titles:
            [self setupColumns:line];
            currentLineType = Types;
            break;
        case Types:
            //[self setupTypes:line];
            currentLineType = Data;
            break;
        case Data:
            [self addJsonObject:line];
            break;
    }
}

- (void)addJsonObject:(NSString*)json {
    if (json != nil && [json isEqualToString:@""] == false) {
        NSError *jsonError;
        NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:0
                                                                 error:&jsonError];
        
        [self.objects addObject:[object dictionaryFromPSObjectJSON]];
    }
}

NSArray *allKeys;

- (void)setupColumns:(NSString*)titlesCSV {
    NSLog(@"setupColumns start");
    NSArray *titles = [titlesCSV componentsSeparatedByString:@","];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    for (NSString *title in titles) {
        // fix the csv escaping
        NSMutableString *mTitle = [title mutableCopy];
        [mTitle replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:0 range:NSMakeRange(0, [mTitle length])];
        [mTitle deleteCharactersInRange:NSMakeRange(0, 1)];
        [mTitle deleteCharactersInRange:NSMakeRange([mTitle length] - 1, 1)];
        
        NSString *key = [mTitle lowercaseString];
        [keys addObject:key];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = mTitle;
        NSString *keyPath = [NSString stringWithFormat:@"arrangedObjects.%@",key];
        [column bind:NSValueBinding toObject:self.objects withKeyPath:keyPath options:nil];
        
        [self.tableView addTableColumn:column];
    }
    
    allKeys = [keys copy];
    NSLog(@"setupColumns end");
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"numberOfRowsInTableView");
    return [self.objects.arrangedObjects count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[self.objects.arrangedObjects objectAtIndex:row] valueForKey:tableColumn.identifier];
}

/*
-(void)controlTextDidChange:(NSNotification *)notification {
    NSLog(@"interesting");
    NSString *searchString = self.searchField.stringValue;
    NSLog(@"hrm %@",searchString);
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in allKeys) {
        NSLog(@"add search for %@",key);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ containts %@",key,searchString]];
     
        [predicateArray addObject:predicate];
    }
    
    NSPredicate *p = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
    //[self.objects setFilterPredicate:p];
    

    NSString *search1 =  @"name contains $value";
    
    // search all
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"All",@"Search field placeholder"),
                             NSDisplayNameBindingOption, search1,
                             NSPredicateFormatBindingOption, nil];
    [self.searchField bind:NSPredicateBinding
                  toObject:self.objects
               withKeyPath:@"filterPredicate"
                   options: options];

    [self.tableView reloadData];
}
*/



@end


