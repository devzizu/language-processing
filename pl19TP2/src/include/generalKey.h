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

// The value has more values or not
#define HAS_VALUES 1
#define HASNT_VALUES 0

/*
 * Struct that represents the values of a key on the hashtable. If the key has a value, it means that it's an 
 * atribute. This atribute can be a string ("vals") or a float ("valf"). To control the value that is inserted on this struct,
 * we added the "type" so it can identify. 
 * The "hasValues" indicates if this struct has any value or not
 * At last, the "arrayVal" works as a list of values and it's used when the value is an array of values, i.e., 
 * a = [1,2], the following value is an "arrayVal" with two elements 
 */
typedef struct value
{
    char* vals;
    float valf;
    short type;
    short hasValues;

    GList* arrayVal;
    
} *VALUE;


/*
 * This struct represents the key of the hashtable used in this program. It's defined by his name in "key" (string),
 * and other parameters. The "type" says if this key is table, atribute or an array of tables (not used).
 * We can know if the key is defined or undefined because the parameter "isDefined".
 * The "VALUE" represents the atributes of this key, if it has any.
 * The "listTables" is not used.
 */
typedef struct general_key 
{
    char*       key;
    short       type;
    short       isDefined;        
    VALUE       val;

    GList* listTables;

} *GEN_KEY_PTR, GEN_KEY;

/*
 * Generates the hash of a general_key with the key
 */
guint generalKey_hash(gconstpointer gen_key);

/*
 * Equal function necessary to most of the hastable functions. Compares two general_keys with their keys
 */
gboolean generalKey_equal(gconstpointer gen_key1, gconstpointer gen_key2);


/*
 * Inserts the key of one hashtable (tableIn) to another one (tableOut)
 */
void insert_table(GHashTable* tableIn, GHashTable* tableOut);

/*
 * Updates the "FINAL" hashtable with another hashTable. Inserts the keys in the "FINAL" in the correct position.
 * Returns -1 if the update went wrong, otherwise returns 0
 */
int update_table(GHashTable* table, GHashTable* FINAL);

/*
 * Function used to insert a key with his value on the tableFinal.
 * It uses the depths of the table and value (l_TTable is the depth of the table and length_Term the length of the value)
 * which we are going to inserted on the "tableFinal" (insert "val" in "table" and then
 * insert the insert the fusion of the two in the "tableFinal").
 * The "beginTable" indicates the root hashtable. In this case it's always the same as "table" but we need a pointer to the 
 * beginning of the "table". 
 * Returns -1 if the update went wrong, otherwise returns 0 
 */
int add_lastTable(GHashTable* table, GHashTable* term, VALUE val, GHashTable* beginTable, int l_TTable, int length_Term, GHashTable* tableFinal);

/*
 * Sets the value in the respected key
 */
void add_value_lastTable(GHashTable* table, VALUE val, GHashTable* beginTable, int l_TTable);

/*
 * Sets the value in a key and then inserts the hashtable with that key in the hashtable "table", normally the "tabelFinal" 
 */
int insert_termAtrib(GHashTable* term, VALUE val, GHashTable* table, int l_TTable);

/*
 * Writes the hashtable format in the terminal
 */
void print_hashtable(GHashTable* HT, int* tabs);

#endif