#include <libkern/OSAtomic.h>
#include <Cocoa/Cocoa.h>

#include <sys/types.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* getClipboard() {
    // get reference to clipboard
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    NSString *clipboardNSString = [pb stringForType:NSPasteboardTypeString];
    if (clipboardNSString == nil) {
        return NULL;
    }

    const char *clipboardString;
    char *ret;
    size_t len;


    clipboardString = [clipboardNSString UTF8String];
    len = strlen(clipboardString);
    ret = malloc(len + 1);
    if (ret != NULL) {
        memcpy(ret, clipboardString, len);
        ret[len] = '\0';
    }

    return ret;
}


bool setClipboard(const char *valueString)
{
    // get reference to clipboard
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    // convert char* to utf'd nsstring
    NSString *valueNSString;
    valueNSString = [[NSString alloc] initWithBytes:valueString length:strlen(valueString) encoding:NSUTF8StringEncoding];

    // prepare clipboard for change
    [pb declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeString,nil] owner:nil];

    // change clipboard
    bool ret = [pb setString:valueNSString forType:NSPasteboardTypeString];

    // free resources
   // [valueNSString release];

    return ret;
}

