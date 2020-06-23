#ifndef _GENERALKEY_
#define _GENERALKEY_

#include <stdbool.h>
#include <glib.h>

#define ISTABLE 1 
#define ISARRAYTABLES 0
#define ISATRIB -1  

typedef union value
{
    char* vals;
    int   vali;
    float valf;
    GSList* listTables;

    union value* arrayVal;
    
} VALUE;

typedef struct general_key 
{
    char*       key;
    short       type;        
    VALUE       val;

} *GEN_KEY_PTR, GEN_KEY;


guint generalKey_hash(gconstpointer gen_key);
gboolean generalKey_equal(gconstpointer gen_key1, gconstpointer gen_key2);


#endif