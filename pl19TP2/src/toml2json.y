%{
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "include/generalKey.h"

#include <glib.h>

int yyerror(char* s);
int yylex(); 
void print_hashtable(GHashTable* HT, int* tabs);
int update_table(GHashTable* table, GHashTable* FINAL);
void insert_table(GHashTable* tableIn, GHashTable* tableOut);
int add_lastTable(GHashTable* table, GHashTable* term, VALUE val, GHashTable* beginTable, int l_TTable);
void add_value_lastTable(GHashTable* table, VALUE val, GHashTable* beginTable, int l_TTable);
int insert_termAtrib(GHashTable* term, VALUE val, GHashTable* table, int l_TTable);

GHashTable* lastTable;

GHashTable* temp;

GHashTable* tableFinal;

int length_TermTable = 0;
int length_Term = 0;

int beforeDeclarations = 0;

%}

%union { char c; char *string; float number; GHashTable* json_struct; VALUE val; GList* glist; } 

%token <string> KEY_NORMAL KEY_STRING STRING BOOL DATE
%token <number> NUM 
%token ERRO 
%type <json_struct> Language Declarations Definition Table TermTable Term
%type <string> Key
%type <val> Value Array
%type <glist> ArrayString ArrayBool ArrayDate ArrayNum Arrays

%%

Toml : Language                                       { /*
                                                            GList* keys = g_hash_table_get_keys($1);

                                                            int size = g_list_length(keys);

                                                            printf("Tamanho da lista -> %d\n", size);

                                                            for(int i = 0; i < size; i++) 
                                                            { 
                                                                  GList *element = g_list_nth(keys, i);
                                                                  printf("Hashtable key -> %s;\n", ((GEN_KEY_PTR) (element -> data)) -> key);
                                                            }*/
                                                      }
     ;

Language : Atribuitions Declarations                     { $$ = $2; }
         | Atribuitions                                  { ; }
         ;


Declarations : Definition                             {
                                                            /*int exists = g_hash_table_insert(JSON_STRUCT, gk, NULL);

                                                            if (!exists) 
                                                            {
                                                                  printf("Erro!");
                                                                  return(1);
                                                            } */

                                                            length_TermTable = 0;
                                                            $$ = $1;
                                                      }
             | Declarations Definition                { length_TermTable = 0; $$ = $2; }
             ;

Definition : Table Atribuitions                       { 
                                                            $$ = $1;

                                                      }
           | '[' Table ']' Atribuitions               { ; }
           ;

Table : '[' TermTable ']'                             { 
                                                            $$ = $2;

                                                            lastTable = $2;

                                                            int *tabs = (int*) malloc(sizeof(int)); 
                                                            *tabs = 0;

                                                            if (update_table($2, tableFinal)) 
                                                            {
                                                                  printf("[Error!] Invalid [table] definition!\n");
                                                                  return -1;
                                                            }
                                                            else
                                                                  print_hashtable(tableFinal, tabs);
                                                      }               
      ;

TermTable : Key                                       {
                                                            length_TermTable++; 
                                                            GHashTable* TEMPORARY = g_hash_table_new(generalKey_hash, generalKey_equal);

                                                            GEN_KEY_PTR key = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            key -> key = $1;
                                                            key -> type = ISTABLE;
                                                            key -> isDefined = DEFINED;
                                                            
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> type = HASNT_VALUES;
                                                            key -> val = v;

                                                            g_hash_table_insert(TEMPORARY, key, NULL);

                                                            $$ = TEMPORARY;

                                                            beforeDeclarations = 1;
                                                      }                         
          | Key '.' TermTable                         {
                                                            length_TermTable++;
                                                            GHashTable* TEMPORARY = g_hash_table_new(generalKey_hash, generalKey_equal);

                                                            GEN_KEY_PTR key = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            key -> key = $1;
                                                            key -> type = ISTABLE;
                                                            key -> isDefined = NOT_DEFINED;

                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> type = HASNT_VALUES;
                                                            key -> val = v;

                                                            g_hash_table_insert(TEMPORARY, key, $3);

                                                            $$ = TEMPORARY;

                                                            beforeDeclarations = 1;       
                                                      }  
           ; 

Term : Key                                            { 
                                                            length_Term++;

                                                            GHashTable* TEMPORARY = g_hash_table_new(generalKey_hash, generalKey_equal);

                                                            GEN_KEY_PTR key = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            key -> key = $1;
                                                            key -> type = ISATRIB;
                                                            key -> isDefined = DEFINED;

                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> type = HASNT_VALUES;
                                                            key -> val = v;

                                                            g_hash_table_insert(TEMPORARY, key, NULL);

                                                            $$ = TEMPORARY;
                                                      }                         
     | Key '.' Term                                   {
                                                            length_Term++;

                                                            GHashTable* TEMPORARY = g_hash_table_new(generalKey_hash, generalKey_equal);

                                                            GEN_KEY_PTR key = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            key -> key = $1;
                                                            key -> type = ISTABLE;
                                                            key -> isDefined = DEFINED;

                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> type = HASNT_VALUES;
                                                            key -> val = v;

                                                            g_hash_table_insert(TEMPORARY, key, $3);

                                                            $$ = TEMPORARY;
                                                      }           
     ; 


Key : KEY_STRING                                      { $$ = $1; }
    | KEY_NORMAL                                      { $$ = $1; }
    | STRING                                          { $$ = $1; }
    ;

Atribuitions : 
             | Atribuitions Atrib
             ;

Atrib : Term '=' Value                                {                                                                 
                                                            int *tabs = (int*) malloc(sizeof(int));
                                                            
                                                            if (!beforeDeclarations)
                                                            {
                                                                  if (g_hash_table_size(tableFinal) == 0)
                                                                  {
                                                                        add_value_lastTable($1, $3, $1, length_Term);
                                                                        insert_table($1, tableFinal);

                                                                        *tabs = 0;
                                                                        printf("First Insertion\n");
                                                                        print_hashtable(tableFinal, tabs);
                                                                  }
                                                                  else
                                                                  {
                                                                        if(insert_termAtrib($1, $3, tableFinal, length_Term))
                                                                        {
                                                                              printf("[Error!] Invalid atribution definition!\n");
                                                                              return -1;
                                                                        }
                                                                        else
                                                                        {
                                                                              *tabs = 0;
                                                                              printf("More Atributions...\n");
                                                                              print_hashtable(tableFinal, tabs);
                                                                        }
                                                                       
                                                                  }
                                                            }      
                                                            else
                                                            {
                                                                  if (add_lastTable(lastTable, $1, $3, lastTable, length_TermTable) == -1)
                                                                  {
                                                                        printf("[Error!] Invalid atribution definition!\n");
                                                                        return -1;
                                                                  }
                                                            }
                                                

                                                            length_Term = 0;
                                                      }                               
      ;

Value : NUM                                           { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> valf = $1; v -> type = _FLOAT;  

                                                            $$ = v;
                                                      }
      | Array                                         { $$ = $1; }
      | BOOL                                          { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; v -> type = _BOOL; 

                                                            $$ = v;
                                                      }
      | STRING                                        { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; v -> type = _STRING; 

                                                            $$ = v;
                                                      }
      | DATE                                          { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; v -> type = _STRING;

                                                            $$ = v;
                                                      }
      ;

Array : '[' ']'                                       { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = NULL;
                                                            v -> type = _LIST_EMPTY;

                                                            $$ = v;
                                                      } 
      | '[' ArrayString EndArray ']'                  {
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = $2;
                                                            v -> type = _LIST_STRING;

                                                            $$ = v;
                                                      }
      | '[' ArrayNum EndArray ']'                     {
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = $2;
                                                            v -> type = _LIST_FLOAT;

                                                            $$ = v;
                                                      }
      | '[' Arrays EndArray ']'                       {
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = $2;
                                                            v -> type = _LIST_ARRAYS;

                                                            $$ = v;
                                                      }
      | '[' ArrayBool EndArray ']'                    {
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = $2;
                                                            v -> type = _LIST_BOOL;

                                                            $$ = v;
                                                      }
      | '[' ArrayDate EndArray ']'                    {
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> arrayVal = $2;
                                                            v -> type = _LIST_STRING;

                                                            $$ = v;
                                                      }
      ;

ArrayString : STRING                                  { 
                                                            GList* glist = NULL;

                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; 
                                                            v -> type = _STRING;

                                                            glist = g_list_append(glist, v);
                                                            $$ = glist;
                                                      }
            | ArrayString ',' STRING                  { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $3; 
                                                            v -> type = _STRING;

                                                            $$ = g_list_append($1, v);
                                                      }
            ;

ArrayNum : NUM                                        {
                                                            GList* glist = NULL;
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> valf = $1; 
                                                            v -> type = _FLOAT;

                                                            glist = g_list_append(glist, v);
                                                            $$ = glist;
                                                      }
         | ArrayNum ',' NUM                           { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> valf = $3; 
                                                            v -> type = _FLOAT;

                                                            $$ = g_list_append($1, v);
                                                      }
         ;

ArrayBool : BOOL                                      {
                                                            GList* glist = NULL;
                                                            
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; 
                                                            v -> type = _BOOL;

                                                            glist = g_list_append(glist, v);
                                                            $$ = glist;
                                                      }
          | ArrayBool ',' BOOL                        { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $3; 
                                                            v -> type = _BOOL;

                                                            $$ = g_list_append($1, v);
                                                      }
          ;

ArrayDate : DATE                                      {
                                                            GList* glist = NULL;
                                                            
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $1; 
                                                            v -> type = _STRING;

                                                            glist = g_list_append(glist, v);
                                                            $$ = glist;
                                                      }
          | ArrayDate ',' DATE                        { 
                                                            VALUE v = (VALUE) malloc (sizeof(struct value));
                                                            v -> vals = $3; 
                                                            v -> type = _STRING;

                                                            $$ = g_list_append($1, v);
                                                      }
          ;

Arrays : Array                                        {
                                                            GList* glist = NULL;

                                                            glist = g_list_append(glist, $1);
                                                      
                                                            $$ = glist;
                                                      }
       | Arrays ',' Array                             { 
                                                            $$ = g_list_append($1, $3);
                                                      }     
       ;

EndArray : 
         | ','
         ;       

%%

#include "lex.yy.c"

extern char* yytext;

int update_table(GHashTable* table, GHashTable* FINAL) 
{
      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);

      if (g_hash_table_contains(FINAL, keyTable))  
      {
            GHashTable* valuesTable = (GHashTable*) g_hash_table_lookup(table, keyTable);
            GHashTable* valuesFinal = (GHashTable*) g_hash_table_lookup(FINAL, keyTable);

            if (valuesFinal == NULL)
            {
                  if (valuesTable != NULL)
                  {
                        valuesFinal = g_hash_table_new(generalKey_hash, generalKey_equal);
                        g_hash_table_insert(FINAL, keyTable, valuesTable);
                        
                        return 0;
                  }
                        
                  return -1;
                  
            }
            else
            {
                  if (valuesTable == NULL)
                  {
                        GList* k = g_hash_table_get_keys(FINAL);
                        for (int i = 0; i < g_list_length(k); i++)
                        {
                              GList *eTable = g_list_nth(k, i);
                              GEN_KEY_PTR keyFinal = (GEN_KEY_PTR) (eTable -> data);
                        
                              if (!strcmp(keyFinal -> key, keyTable -> key))
                              {
                                    if (keyFinal -> isDefined)
                                          return -1;
                                    else
                                    {
                                          keyFinal -> isDefined = DEFINED;
                                          GHashTable* vF = (GHashTable*) g_hash_table_lookup(FINAL, keyFinal);
                                          g_hash_table_insert(FINAL, keyFinal, vF);
                                          
                                          return 0;
                                    }      
                              }
                        }                        
                  }
                  else
                        return update_table(valuesTable, valuesFinal);
            }
      }
      else
      {
            insert_table(table, FINAL); 
            return 0;
      }      
}


void insert_table(GHashTable* tableIn, GHashTable* tableOut)
{
      if (tableIn == NULL)
            return;
      if (tableOut == NULL)
      {
            tableOut = g_hash_table_new(generalKey_hash, generalKey_equal);
      }
      
      GList* keys = g_hash_table_get_keys(tableIn);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTableIn = (GEN_KEY_PTR) (elementTable -> data);
      
      GHashTable* valueTableIn = (GHashTable*) g_hash_table_lookup(tableIn, keyTableIn);

      g_hash_table_insert(tableOut, keyTableIn, valueTableIn);     
}


int add_lastTable(GHashTable* table, GHashTable* term, VALUE val, GHashTable* beginTable, int l_TTable)
{            
      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);
      
      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);

      GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTable);

      if (l_TTable == 1)
      {            
            GList* k = g_hash_table_get_keys(term);
            GList *e = g_list_nth(k, 0);
            GEN_KEY_PTR kT = (GEN_KEY_PTR) (e -> data);

            if (valueTable == NULL)
            {     
                  GHashTable* valuesFinal = (GHashTable*) g_hash_table_lookup(tableFinal, keyTable);
                  
                  if (valuesFinal != NULL && g_hash_table_contains(valuesFinal, kT))
                        return -1;

                  valueTable = g_hash_table_new(generalKey_hash, generalKey_equal);

                  add_value_lastTable(term, val, term, length_Term);

                  g_hash_table_insert(table, keyTable, term);
            }
            else
            {
                  if (g_hash_table_contains(valueTable, kT))
                        return -1;

                  add_value_lastTable(term, val, term, length_Term);

                  GList* keyTerm = g_hash_table_get_keys(term);
                  GList *eKt = g_list_nth(keyTerm, 0);
                  GEN_KEY_PTR kTerm = (GEN_KEY_PTR) (eKt -> data);

                  GHashTable* valueTermToAdd = (GHashTable*) g_hash_table_lookup(term, kTerm);

                  g_hash_table_insert(valueTable, kTerm, valueTermToAdd);
                  g_hash_table_insert(table, keyTable, valueTable);
            }

            update_table(beginTable, tableFinal);
                  

            int *tabs = (int*) malloc(sizeof(int));
            *tabs = 0;
            printf("Apos insercao\n");
            print_hashtable(tableFinal, tabs);

            return 0;
      }
      else
            return add_lastTable(valueTable, term, val, beginTable, l_TTable - 1);
   
}

void add_value_lastTable(GHashTable* table, VALUE val, GHashTable* beginTable, int l_TTable)
{
      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);
      
      GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTable);

      if (l_TTable == 1)
      {                        
            keyTable -> val = val;
      }
      else
            add_value_lastTable(valueTable, val, beginTable, l_TTable - 1);
}


int insert_termAtrib(GHashTable* term, VALUE val, GHashTable* table, int l_TTable)
{
      GList* keysTerm = g_hash_table_get_keys(term);
      GList *elementTerm = g_list_nth(keysTerm, 0);
      GEN_KEY_PTR keyTerm = (GEN_KEY_PTR) (elementTerm -> data);

      if (g_hash_table_contains(table, keyTerm))
      {
            GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTerm);

            if (valueTable == NULL)      
                  return -1;
            else
            {
                  GHashTable* valueTerm = (GHashTable*) g_hash_table_lookup(term, keyTerm);

                  if (valueTerm == NULL)
                        return -1;
                  
                  return insert_termAtrib(valueTerm, val, valueTable, l_TTable - 1);
            }
      }
      else
      {
          add_value_lastTable(term, val, term, l_TTable);
            
            if(update_table(term, table))
                  return -1;
      }

      return 0;
}

void print_hashtable(GHashTable* HT, int* tabs) {

      if (HT == NULL) {
            for (int j = 0; j < *tabs; j++)
                  printf("\t");
            printf("(null value)\n");
            return;
      }

      GList* keys = g_hash_table_get_keys(HT);

      for (int j = 0; j < *tabs; j++)
      printf("\t");

      printf("HashTable:\n");

      for (int i = 0; i < g_list_length(keys); i++) {

            for (int j = 0; j < *tabs; j++)
                  printf("\t");

            GList *element = g_list_nth(keys, i);
            printf("> Key: %s (%s), values:\n", ((GEN_KEY_PTR) (element -> data)) -> key, getValueString( (GEN_KEY_PTR) element -> data));

            gpointer value = g_hash_table_lookup(HT, (GEN_KEY_PTR) (element -> data));
            *tabs = *tabs + 1;
            print_hashtable((GHashTable*) value, tabs);
            *tabs = *tabs - 1;
      }

      printf("\n");
}

int yyerror(char *s) 
{
	printf("[Error!] Got syntax error, <Invalid char sequence:%s>\n", yytext);
	return(0);
}

int main() 
{
      lastTable = g_hash_table_new(generalKey_hash, generalKey_equal);
      temp = g_hash_table_new(generalKey_hash, generalKey_equal);
      tableFinal = g_hash_table_new(generalKey_hash, generalKey_equal);

      //lastTable = tableFinal;

      yyparse();

      printf("\nProgram finished...\n\tGoodbye :)\n");
      return 0;
}