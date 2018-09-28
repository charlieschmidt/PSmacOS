
#ifndef _LIBCLIPBOARD_H_
#define _LIBCLIPBOARD_H_

#ifdef __cplusplus
extern "C" {
#endif

char *get_macos_clipboard();

void free_clipboard(char *clipboard);

#ifdef __cplusplus
}
#endif

#endif