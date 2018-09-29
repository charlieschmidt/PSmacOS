
#ifndef _LIBPSMACOSBRIDGING_H_
#define _LIBPSMACOSBRIDGING_H_

#ifdef __cplusplus
extern "C" {
#endif

// bridge_gridview.m
int showGridView();

// bridge_pasteboard.m
char * getClipboard();
bool setClipboard(const char *valueString);

// bridge_messagebox.m
unsigned long showMessageBox(double timeoutSeconds, unsigned long type, const char *title, const char *message, const char *buttonOneLabel, const char *buttonTwoLabel, const char *buttonThreeLabel);

// bridge_memory.m
void freeString(char *string);

#ifdef __cplusplus
}
#endif

#endif