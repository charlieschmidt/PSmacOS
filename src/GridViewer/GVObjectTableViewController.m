//
//  GVObjectTableViewController.m
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

// line-by-line NSStreamDelegate inspired/copied from https://github.com/AlexMoffat/line-by-line-ios-file-reader

#import "GVObjectTableViewController.h"


@implementation NSDictionary (PSObject)

// a lot of the rest of the code is much easier to deal with if we make the object (stored as a dictionary) have lowercase keys.  we can't ensure that all the powershell objects
// coming in on the pipe will all have their property names in the same string case
// this is an extension method to convert a dictionary to one with lowercase keys
- (NSDictionary *)dictionaryWithLowerCaseKeys {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *key;
    
    for (key in self) {
        id val = [self objectForKey:key];
        
        [result setObject:val forKey:[key lowercaseString]];
    }
    
    return result;
}

@end

@interface GVObjectTableViewController () <NSTableViewDataSource, NSTableViewDelegate, NSStreamDelegate, NSSearchFieldDelegate>

// the objects from the pipeline
@property (strong) IBOutlet NSArrayController *objects;

@property (weak) IBOutlet NSSearchFieldCell *searchField;
@property (weak) IBOutlet NSTableView *tableView;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)okButtonClicked:(id)sender;

// keep track of (and update as more come in over the pipeline) the objc Class being used to store each key/title/column/property
@property (strong, nonatomic) NSMutableDictionary *keyClasses;

// Buffer to hold any unprocessed string data after each loop.
@property (strong, nonatomic) NSString *stringBuffer;

@end







@implementation GVObjectTableViewController

@synthesize stringBuffer;
@synthesize objects;
@synthesize keyClasses;

- (void)controlTextDidChange:(NSNotification *)obj {
    //NSLog(@"in control text did change");
    // the search field has changed
    if (self.keyClasses.allKeys && [self.keyClasses.allKeys count] > 0 && [self.searchField.stringValue isEqualToString:@""] == false) {
        // it has text
        
        //NSLog(@"looking for %@",self.searchField.stringValue);
        
        // build a predicate of () or () or () where each element is a comparison one of the object's properties
        NSMutableArray *subPredicates = [NSMutableArray array];
        
        for (NSString *key in self.keyClasses.allKeys) {
            // foreach key, add a () clause
            NSPredicate *subPredicate = nil;
            //NSLog(@"key = %@",key);
            Class klass = [keyClasses objectForKey:key];
            //NSLog(@"value = %@",klass);
            
            if ([klass isSubclassOfClass:[NSString class]]) {
                // if it's a string, normal comparison
                subPredicate = [NSPredicate predicateWithFormat:@"(%K != nil AND %K CONTAINS[cd] %@)", key, key, self.searchField.stringValue];
            } else if ([klass isSubclassOfClass:[NSNumber class]]) {
                // if it's a number, check if null and then compare to stringvalue
                subPredicate = [NSPredicate predicateWithFormat:@"(%K != nil AND %K.stringValue CONTAINS[cd] %@)", key, key, self.searchField.stringValue];
            } else {
                //NSLog(@"No predicate is appropriate");
            }
            
            if (subPredicate != nil) {
                [subPredicates addObject:subPredicate];
            }
        }
        
        // create master predicate of all subpredicates OR'd together
        NSPredicate *filter = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];
        [self.objects setFilterPredicate:filter];
        
        [self.tableView reloadData];
    } else {
        // clear predicates
        [self.objects setFilterPredicate:nil];
        [self.tableView reloadData];
    }
    //NSLog(@"in control text was changed");
}


- (IBAction)closeButtonClicked:(id)sender {
    [self.view.window close];
}

- (IBAction)okButtonClicked:(id)sender {
    for (id obj in [self.objects.arrangedObjects objectsAtIndexes:[self.tableView selectedRowIndexes]]) {
        NSString *s = [[NSString alloc] initWithFormat:@"%@\n",[obj objectForKey:@"__gridviewer_psobject_index"]];
        [[NSFileHandle fileHandleWithStandardOutput] writeData: [s dataUsingEncoding: NSUTF8StringEncoding]];
    }
    [self.view.window close];
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
    if (streamEvent & NSStreamEventHasBytesAvailable) {
        [self readDataFromStream:stream];
    }
    
    if (streamEvent & NSStreamEventErrorOccurred) {
        //! FIXME - consider probably closing the window or.. bailing out somehow here?
        return;
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
    [super viewDidLoad];
    
    // store the key -> class
    keyClasses = [[NSMutableDictionary alloc] init];

    // read from stdin in the 'background'
    NSStream *stdinStream = [[NSInputStream alloc] initWithFileAtPath:@"/dev/stdin"];
    [stdinStream setDelegate:self];
    [stdinStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stdinStream open];
    
    /*
    [self processLine:@"{\"a\":\"the thing\",\"b\":\"the other\"}"];
    [self processLine:@"{\"a\":\"2the thing\",\"b\":\"2the other\"}"];
    [self processLine:@"{\"a\":\"3the thing\",\"b\":\"3the other\"}"];
    */
}

unsigned int linesRead = 0;

// process an object from the pipeline
- (void)processLine:(NSString*)json {
    if (json != nil && [json isEqualToString:@""] == false) {
        // parse the json
        NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *objectWithTitles = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:0
                                                                  error:&jsonError];
        NSDictionary *objectWithKeys = [objectWithTitles dictionaryWithLowerCaseKeys];
        
        // foreach property/title on the object
        for (NSString *title in objectWithTitles) {
            // make the key - lowercase, because we can't be sure they'll all come in the same string case over the pipeline
            NSString *key = [title lowercaseString];
            
            // find the column we've added alrady
            NSTableColumn *column = [self.tableView tableColumnWithIdentifier:key];
            
            if (column == nil) {
                // if no column, add one
                NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
                column.title = title;
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column.identifier ascending:YES selector:@selector(compare:)];
                [column setSortDescriptorPrototype:sortDescriptor];
                
                
                NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
                [bindingOptions setObject:@""
                                   forKey:NSNullPlaceholderBindingOption];
                
                NSString *keyPath = [NSString stringWithFormat:@"arrangedObjects.%@",key];
                [column bind:NSValueBinding
                    toObject:self.objects
                 withKeyPath:keyPath
                     options:bindingOptions];
                
                [self.tableView addTableColumn:column];
            }
            
            // find the class for this property
            Class klass = [keyClasses objectForKey:key];
            if (klass == nil) {
                // if we havn't seen this key before, let's see if it has a type
                id val = [objectWithKeys objectForKey:key];
                
                if (val != (id)[NSNull null]) {
                    // it does have a type, add that to the cache so we can use it on display later
                    klass = [val class]; // val will have a class, because its not null per above
                    [keyClasses setObject:klass forKey:key];
                }
            }
            
        }
        
        [objectWithKeys setValue:[[NSNumber alloc] initWithInt:linesRead++] forKey:@"__gridviewer_psobject_index"];
        
        // add the object (with lowercase keys) to the controller
        [self.objects addObject:objectWithKeys];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.objects.arrangedObjects count];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)sortDescriptors
{
    [self.objects setSortDescriptors:sortDescriptors];
    [tableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    id originalValue = [[self.objects.arrangedObjects objectAtIndex:row] valueForKey:tableColumn.identifier];
    NSString *newValue;
    
    if (originalValue == (id)[NSNull null] || originalValue == nil) {
        // if the original value is null, return an empty string for display
        newValue = @"";
    } else {
        // find the best way to display the value
        Class klass = [keyClasses objectForKey:tableColumn.identifier];
        
        if ([klass isSubclassOfClass:[NSString class]]) {
            //if a string, display that
            newValue =  originalValue;
        } else if ([klass isSubclassOfClass:[NSNumber class]]) {
            // if a number, format and display that
            NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:originalValue numberStyle:NSNumberFormatterDecimalStyle];
            newValue =  numberStr;
        } else {
            // ?
            newValue =  @"";
        }
    }
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"DefaultCellView" owner:self];
   // [cellView.textField bind:NSValueBinding toObject:]
    cellView.textField.stringValue = newValue;
    
    return cellView;
}


@end


