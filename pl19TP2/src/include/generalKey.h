#ifndef _GENERALKEY_
#define _GENERALKEY_

#include <stdbool.h>
#include <glib.h>
#include <stdio.h>

// Type of GEN_KEY
#define ISTABLE 1 
#define ISARRAYTABLES 0
#define ISATRIB -1 

// Is key defined?
#define DEFINED 1
#define NOT_DEFINED 0

// Type of value
#define _BOOL 2
#define _STRING 1
#define _FLOAT -2
#define _LIST_STRING -3
#define _LIST_FLOAT -4
#define _LIST_BOOL -5
#define _LIST_ARRAYS -1    
#define _LIST_EMPTY -6


// Has more values or not
#define HAS_VALUES 1
#define HASNT_VALUES 0

typedef struct value
{
    char* vals;
    float valf;
    short type;
    short hasValues;

    GList* arrayVal;
    
} *VALUE;

typedef struct general_key 
{
    char*       key;
    short       type;
    short       isDefined;        
    VALUE       val;

    GList* listTables;

} *GEN_KEY_PTR, GEN_KEY;


guint generalKey_hash(gconstpointer gen_key);
gboolean generalKey_equal(gconstpointer gen_key1, gconstpointer gen_key2);

void insert_table(GHashTable* tableIn, GHashTable* tableOut);
int update_table(GHashTable* table, GHashTable* FINAL);
int add_lastTable(GHashTable* table, GHashTable* term, VALUE val, GHashTable* beginTable, int l_TTable, int length_Term, GHashTable* tableFinal);
void add_value_lastTable(GHashTable* table, VALUE val, GHashTable* beginTable, int l_TTable);
int insert_termAtrib(GHashTable* term, VALUE val, GHashTable* table, int l_TTable);
void print_hashtable(GHashTable* HT, int* tabs);

#endif