#include "include/generalKey.h"
#include <glib.h>
#include <stdio.h>
#include <unistd.h>

char* string_GList(GList* List);
char* string_ListArrays(GList* List);
char* alterQuoteMark(char* text);

char floatResultString[256];
char stringRArr[624];

char* strcatarray(char* dest, GList* List, int number) 
{
    char* target = dest;               
    *target = '\0';

    strcat(target, "[");
    target++;

    for (int i = 0; i < number; i++) 
    {
        strcat(target, (char*) ( (VALUE) g_list_nth(List, i) -> data) -> vals);
        target += strlen((char*) ( (VALUE) g_list_nth(List, i) -> data) -> vals);   

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

void string_NumArray(GList* floatList, int array_size, char* output_string, int output_string_max_size)
{
    if (!floatList || !output_string)
        return;

    char* aux_string = NULL;

    aux_string = (char*) malloc(15);
    
    if (!aux_string)
        return;

    int i;
    int current_array_size = 0;
    
    strcat(output_string, "[");
    current_array_size++;

    for (i = 0; i < array_size; i++)
    {
        if ( ((float) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf) == ((int) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf) )
        {
            if (i == array_size - 1) 
            {
                sprintf(aux_string, "%d]", (int) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
            }    
            else
            {
                sprintf(aux_string, "%d,", (int) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
            }
        }
        else
        {
            if (i == array_size - 1) 
            {
                sprintf(aux_string, "%.3f]", (float) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
            }    
            else
            {
                sprintf(aux_string, "%.3f,", (float) ( (VALUE) g_list_nth(floatList, i) -> data) -> valf);
            } 
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

    switch(v -> type) 
    {
        case _FLOAT: 
            floatResultString[0] = '\0';
            string_NumArray(List, number, &floatResultString[0], 256);
            return strdup(floatResultString);
        case _BOOL:
        case _STRING:
        {
                for (int i = 0; i < number; i++)   
                    sum += strlen( (char*) g_list_nth(List, i) -> data );

                // sum + 1 (strings to add) ; + 2 ("[" and "]") ; + number - 1 (number of ",")
                return strdup(strcatarray(stringRArr, List, number));
        }
        default: 

            return string_ListArrays(List);
    }

    return strdup("ERROR_|string_GList");
}

char* string_ListArrays(GList* List)
{
    GList* ListStringsToConcat = NULL;

    for (int i = 0; i < g_list_length(List); i++)
    {
        VALUE singleVal = (VALUE) malloc(sizeof(struct value));
        singleVal -> type = _STRING;
        singleVal -> vals = string_GList( (GList*) ((VALUE) g_list_nth(List, i) -> data) -> arrayVal ); 

        ListStringsToConcat = g_list_append(ListStringsToConcat, singleVal); 
    }

    char* resultString = string_GList(ListStringsToConcat);

    //for (int i = 0; i < g_list_length(ListStringsToConcat); i++)
    //    free(g_list_nth(ListStringsToConcat, i) -> data);

    return resultString;
}

char* getValueString(GEN_KEY_PTR genKey)
{
    char c[50];

    if (genKey -> val == NULL)
        return strdup("Value NULL");

    switch ( (genKey -> val) -> type )
    {   
        case _STRING : 
            return alterQuoteMark(strdup((genKey -> val) -> vals));
        case _FLOAT :
            if ( (float) ((VALUE) genKey -> val) -> valf == ((int) ( (VALUE) genKey -> val) -> valf ))
            {
                sprintf(c, "%d", (int) ( (VALUE) genKey -> val) -> valf);
            }
            else
            {
                sprintf(c, "%.3f", (float) ( (VALUE) genKey -> val) -> valf); 
            }
            return strdup(c); 
        case _BOOL :
            return strdup((genKey -> val) -> vals);
        case HASNT_VALUES :
            return strdup("N/A");        
        case _LIST_ARRAYS :
            return string_ListArrays((genKey -> val) -> arrayVal);
        default:
            return string_GList((genKey -> val) -> arrayVal);
    }   
}


char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1); 

    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

char* alterQuoteMark(char* text)
{
    char replace = '\"';
    char alter = '\'';
    int i;

    for(i = 0; text[i] != '\0'; i++)
    {
        if(text[i] == alter)
            text[i] = replace;
    }

    i--; 

    while(text[i] == ' ')
    {
        i--;
    }
    
    text[i+1] = '\0';

    return text;
}

int hasQuote(char* text)
{
    for (int i = 0; text[i] != '\0'; i++)
    {
        if (text[i] == '\"' || text[i] == '\'')
            return 1;
    }
    return 0;
}

void tableToJson(GHashTable* tableFinal, FILE* file, char* ahead)
{
    if (tableFinal == NULL)
        return;
    
    for (int i = 0; i < g_hash_table_size(tableFinal); i++)
    {
        GList* keys = g_hash_table_get_keys(tableFinal);
        GList *elementTable = g_list_nth(keys, i);
        GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);

        if (keyTable -> type == ISTABLE)
        {
            if (hasQuote(keyTable -> key))
                fprintf(file, "%s%s:\n%s{\n", ahead, alterQuoteMark(keyTable -> key), ahead);
            else
                fprintf(file, "%s\"%s\":\n%s{\n", ahead, alterQuoteMark(keyTable -> key), ahead);

            GHashTable* values = (GHashTable*) g_hash_table_lookup(tableFinal, keyTable);

            tableToJson(values, file, concat(ahead, "\t"));

            if (i == g_hash_table_size(tableFinal) - 1)
                fprintf(file, "%s}\n", ahead);
            else   
                fprintf(file, "%s},\n", ahead);
        }
        else
        {
            if (hasQuote(keyTable -> key))
                fprintf(file, "%s%s:", ahead, keyTable -> key);
            else
                fprintf(file, "%s\"%s\":", ahead, keyTable -> key);

            if (i == g_hash_table_size(tableFinal) - 1)
                    fprintf(file, " %s\n", alterQuoteMark(getValueString(keyTable)));
            else 
                fprintf(file, " %s,\n", alterQuoteMark(getValueString(keyTable)));
        }
    }

}

void writeToJson(GHashTable* tableFinal, const char* fileName)
{    
    FILE* file = fopen(fileName, "w");

    fprintf(file, "{\n");

    fclose(file);

    char* ahead = strdup("\t");

    file = fopen(fileName, "a");

    tableToJson(tableFinal, file, ahead);

    fprintf(file, "}\n");

    fclose(file);
}