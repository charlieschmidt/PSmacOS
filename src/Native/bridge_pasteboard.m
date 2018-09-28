
#include <stdlib.h>


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

char* get_macos_clipboard() {
    NSString *clipboardNSString;
    const char *clipboardString;
    char *ret;
    size_t len;

    clipboardNSString = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (clipboardNSString == nil) {
        return NULL;
    }

    clipboardString = [clipboardNSString UTF8String];
    len = strlen(clipboardString);
    ret = malloc(len + 1);
    if (ret != NULL) {
        memcpy(ret, clipboardString, len);
        ret[len] = '\0';
    }

    return ret;
}

void free_clipboard(char *clipboard) {
    if (clipboard != NULL) {
        free(clipboard);
    }
}

bool set_clipboard(const char *valueString, uint length)
{
    // get reference to clipboard
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    // convert char* to utf'd nsstring
    NSString *valueNSString;
    valueNSString = [[NSString alloc] initWithBytes:valueString length:length encoding:NSUTF8StringEncoding];

    // prepare clipboard for change
    [pb declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeString,nil] owner:nil];

    // change clipboard
    bool ret = [pb setString:valueNSString forType:NSPasteboardTypeString];

    // free resources
    [valueNSString release];

    return ret;
}

