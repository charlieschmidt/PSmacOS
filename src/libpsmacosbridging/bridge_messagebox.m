 #import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AppKit/Appkit.h>

unsigned long showMessageBox(double timeoutSeconds, unsigned long type, const char *title, const char *message, const char *buttonOneLabel, const char *buttonTwoLabel, const char *buttonThreeLabel)
{
    CFStringRef messageStringRef = CFStringCreateWithCString(NULL, message, strlen(message));
    CFStringRef titleStringRef = CFStringCreateWithCString(NULL, title, strlen(title));

    CFStringRef buttonOneLabelStringRef = CFStringCreateWithCString(NULL, buttonOneLabel, strlen(buttonOneLabel));
    
    CFStringRef buttonTwoLabelStringRef = NULL;
    if (buttonTwoLabel != NULL) {
        buttonTwoLabelStringRef = CFStringCreateWithCString(NULL, buttonTwoLabel, strlen(buttonTwoLabel));
    }
    
    CFStringRef buttonThreeLabelStringRef = NULL;
    if (buttonThreeLabel != NULL) {
        buttonThreeLabelStringRef = CFStringCreateWithCString(NULL, buttonThreeLabel, strlen(buttonThreeLabel));
    }
    
    CFOptionFlags responseFlags;
    CFUserNotificationDisplayAlert(timeoutSeconds, type, NULL, NULL, NULL, titleStringRef, messageStringRef, buttonOneLabelStringRef, buttonTwoLabelStringRef, buttonThreeLabelStringRef, &responseFlags);
    return responseFlags;
}
