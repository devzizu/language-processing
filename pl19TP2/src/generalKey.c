#include "include/generalKey.h"
#include <glib.h>
#include <stdio.h>
#include <unistd.h>

char* string_GList(GList* List);
char* string_ListArrays(GList* List);

guint generalKey_hash(gconstpointer gen_key) 
{
    return(g_str_hash( (gconstpointer) ((GEN_KEY_PTR) gen_key) -> key));
}

gboolean generalKey_equal(gconstpointer gen_key1, gconstpointer gen_key2)
{
    return(g_str_equal( ((gconstpointer) ((GEN_KEY_PTR) gen_key1) -> key) , ((gconstpointer) ((GEN_KEY_PTR) gen_key2) -> key)));
}


char* strcatarray(char* dest, GList* List, int number) 
{
    char* target = dest;               // where to copy the next elements
    *target = '\0';

    strcat(target, "[");
    target++;

    for (int i = 0; i < number; i++) 
    {
        strcat(target, (char*) ( (VALUE) g_list_nth(List, i) -> data) -> vals);
        target += strlen((char*) ( (VALUE) g_list_nth(List, i) -> data) -> vals);   // move to the end

        if (i != number - 1)
        {
            strcat(target, ",");
            target++;  
        }
    }
        strcat(target, "]");
        target++;

    return dest;
}

void get_me_a_string(GList* floatList, int array_size, char* output_string, int output_string_max_size)
{
    if (!floatList || !output_string)
        return;

    char* aux_string = NULL;

    //Depending on the compiler int is 2-byte or 4 byte.
    //Meaning INT_MAX will be at most 2147483647 (10 characters + 1 '\0').
    aux_string = (char*) malloc(15);
    if (!aux_string)
        return;

    int i;
    int current_array_size = 0;
    
    strcat(output_string, "[");
    current_array_size++;

    for (i = 0; i < array_size; i++)
    {
        if (i == array_size - 1)
        {
            sprintf(aux_string, "%.3f]", (float) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
        }    
        else
        {
            sprintf(aux_string, "%.3f,", (float) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
        } 

        current_array_size += strlen(aux_string);

        if(current_array_size < output_string_max_size)
            strcat(output_string, aux_string);
        else
            break;
    }

    free(aux_string);
}

char* string_GList(GList* List) 
{
    int number = g_list_length(List);
    int sum;

    if (!number)
        return strdup("[]");

    VALUE v = (VALUE) g_list_nth(List, 0) -> data;

    if (v -> type == _FLOAT)
    {
        char* r = (char*) malloc(256);
        
        get_me_a_string(List, number, r, 256);
        
        return r;
    }
    else
    if (v -> type == _BOOL || v -> type == _STRING)
    {
        for (int i = 0; i < number; i++) 
        {   
            sum += strlen( (char*) g_list_nth(List, i) -> data );
        }

              // sum + 1 (strings to add) ; + 2 ("[" and "]") ; + number - 1 (number of ",")
        return strcatarray((char*) malloc(sum + 1 + 2 + (number - 1)), List, number);
    }
    else 
    {
        write(0, "aqui\n", 5);
        return string_ListArrays(List);
    }
}


char* string_ListArrays(GList* List)
{
    int length = g_list_length(List);

    GList* ListStrings = NULL;

    for (int i = 0; i < length; i++)
    {
        VALUE v = (VALUE) malloc(sizeof(struct value));

        v -> vals = string_GList( (GList*) ( (VALUE) g_list_nth(List, i) -> data) -> arrayVal); 

        ListStrings = g_list_append(ListStrings, v); 
    }

    return string_GList(ListStrings);
}



char* getValueString(GEN_KEY_PTR genKey)
{
    char c[50];

    if (genKey -> val == NULL)
        return strdup("Value NULL");

    switch ( (genKey -> val) -> type )
    {   
        case _STRING : 
            return strdup((genKey -> val) -> vals);
        case _FLOAT :
            sprintf(c, "%.3f", (genKey -> val) -> valf);
            return strdup(c);
        case _BOOL :
            return strdup((genKey -> val) -> vals);
        case HASNT_VALUES :
            return strdup("N/A");
        //case _LIST_EMPTY :
        //    return strdup("[]");
        case _LIST_ARRAYS :
            return string_ListArrays((genKey -> val) -> arrayVal);
        default :
            return string_GList((genKey -> val) -> arrayVal);
    }   
}
