
#ifndef _LIBCLIPBOARD_H_
#define _LIBCLIPBOARD_H_

#ifdef __cplusplus
extern "C" {
#endif

char *get_clipboard();

void free_clipboard(char *clipboard);

bool set_clipboard(const char *valueString, uint length);

#ifdef __cplusplus
}
#endif

#endif