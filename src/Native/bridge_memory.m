#include <stdlib.h>
#include <string.h>

void freeString(char *string) {
    if (string != NULL) {
        free(string);
    }
}
