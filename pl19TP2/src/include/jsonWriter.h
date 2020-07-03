#ifndef _JSONWRITER_
#define _JSONWRITER_

#include "generalKey.h"
#include <glib.h>

/*
 * Converts a value to string to add it to json correctly
 */
char* getValueString(GEN_KEY_PTR genKey);

/*
 * Function that creates and writes to the given Json file, the conversion of the TOML file
 */
void writeToJson(GHashTable* tableFinal, const char* fileName);

#endif