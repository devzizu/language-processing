#ifndef _JSONWRITER_
#define _JSONWRITER_

#include "generalKey.h"
#include <glib.h>

char* getValueString(GEN_KEY_PTR genKey);
void writeToJson(GHashTable* tableFinal, const char* fileName);

#endif