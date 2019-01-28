#include <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>

#import <Foundation/NSObject.h>
#import <ApplicationServices/ApplicationServices.h>

#ifndef kASAppleScriptSuite
#define kASAppleScriptSuite 'ascr'
#endif

#ifndef kASSubroutineEvent
#define kASSubroutineEvent 'psbr'
#endif

#ifndef keyASSubroutineName
#define keyASSubroutineName 'snam'
#endif

NSString* executeScript(NSString *script, NSString *functionName, NSArray *scriptArgumentArray)
{
    BOOL executionSucceed = NO;
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];

    if (appleScript == nil)
    {
        return nil;
    }
    else 
    {
        if (functionName && [functionName length])
        {
            /* If we have a functionName (and potentially arguments), we build
             * an NSAppleEvent to execute the script. */

            //Get a descriptor for ourself
            int pid = [[NSProcessInfo processInfo] processIdentifier];
            NSAppleEventDescriptor *thisApplication = [NSAppleEventDescriptor descriptorWithDescriptorType:typeKernelProcessID
                                                                             bytes:&pid
                                                                            length:sizeof(pid)];

            //Create the container event
            NSAppleEventDescriptor *containerEvent = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
                                                                      eventID:kASSubroutineEvent
                                                             targetDescriptor:thisApplication
                                                                     returnID:kAutoGenerateReturnID
                                                                transactionID:kAnyTransactionID];

            //Set the target function
            [containerEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:functionName]
                                    forKeyword:keyASSubroutineName];

            //Pass arguments - arguments is expecting an NSArray with only NSString objects
            if ([scriptArgumentArray count])
            {
                NSAppleEventDescriptor *arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];
                NSString *object;

                for (object in scriptArgumentArray) {
                    [arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:object]
                                        atIndex:([arguments numberOfItems] + 1)]; //This +1 seems wrong... but it's not
                }

                [containerEvent setParamDescriptor:arguments forKeyword:keyDirectObject];
            }

            //Execute the event
            NSDictionary *executionError = nil;
            NSAppleEventDescriptor *result = [appleScript executeAppleEvent:containerEvent error:&executionError];
            if (executionError != nil)
            {
                return nil;
            }
            else 
            {       
                executionSucceed = YES;
                return [result stringValue]; 
            }
        } 
        else 
        {
            NSDictionary *executionError = nil;
            NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&executionError];

            if (executionError != nil)
            {
                return nil;
            }
            else
            {
                executionSucceed = YES;
                return [result stringValue];         
            }
        }
    }
}

char* executeAppleScript(const char *appleScript, const char *functionName, char **arguments, int argumentCount)
{
    NSString *appleScriptNSString = [NSString stringWithCString:appleScript encoding:NSUTF8StringEncoding];
    NSString *functionNameNSString = nil;
    
    if (functionName != nil) {
        functionNameNSString = [NSString stringWithCString:functionName encoding:NSUTF8StringEncoding];
    }

    NSMutableArray *argumentsNSArray = [[NSMutableArray alloc] initWithCapacity: argumentCount];
    for (int i = 0; i < argumentCount; i++)
    {
        [argumentsNSArray addObject: [NSString stringWithCString: arguments[i] encoding:NSUTF8StringEncoding]];
    }

    return [executeScript(appleScriptNSString, functionNameNSString, argumentsNSArray) UTF8String];
}
