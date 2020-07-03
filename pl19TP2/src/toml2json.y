%{
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "include/generalKey.h"
#include "include/jsonWriter.h"

#include <glib.h>

int yyerror(char* s);
int yylex(); 
void print_hashtable(GHashTable* HT, int* tabs);

/*
 * HashTable that represents the last inserted table. It's required to know when we are 
 * inserting the hashtable with the atributions on the hastable final with the correct table 
 */
GHashTable* lastTable;

/*
 * Hashtable which the writer to Json file receives. This is the main hashtable of the data structure
 */
GHashTable* tableFinal;

/* 
 * Variable that counts the number of depth that one table has. Necessary for the atributions to know 
 * how we can go through the hashtable. In the example "[a.b]", this variable has the value 2 
 */
int length_TermTable = 0;

/* 
 * This variable is identique to the above one, only differentiating in the use of her. This one is used when
 * we have an atribute like "a.b.c = 3". In this case, the length_Term equals to 3
 */
int length_Term = 0;


/*
 * This one works as a boolean, indicating if we are before or after a declaration. 
 * If we are before it has the value 0, otherwise 1
 */
int beforeDeclarations = 0;

%}

%union { char c; char *string; float number; GHashTable* json_struct; VALUE val; GList* glist; } 

%token <string> KEY_NORMAL KEY_STRING STRING BOOL DATE
%token <number> NUM 
%token ERRO 
%type <json_struct> Table TermTable Term
%type <string> Key
%type <val> Value Array
%type <glist> ArrayString ArrayBool ArrayDate ArrayNum Arrays

%%

Toml : Language                                       { ; } 
     ;

Language : Atribuitions Declarations                  { ; }
         | Atribuitions                               { ; }
         ;


Declarations : Definition                             { length_TermTable = 0; }
             | Declarations Definition                { length_TermTable = 0; }
             ;

Definition : Table Atribuitions                       { ; }
           ;

Table : '[' TermTable ']'                             { 
                                                            $$ = $2;

                                                            lastTable = $2;

                                                            int *tabs = (int*) malloc(sizeof(int)); 
                                                            *tabs = 0;

                                                            if (update_table($2, tableFinal)) 
                                                            {
                                                                  printf("\n[Error!] Invalid [table] definition!\n");
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
                                                                              printf("\n[Error!] Invalid atribution definition!\n");
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
                                                                  if (add_lastTable(lastTable, $1, $3, lastTable, length_TermTable, length_Term, tableFinal) == -1)
                                                                  {
                                                                        printf("\n[Error!] Invalid atribution definition!\n");
                                                                        return -1;
                                                                  }

                                                                  *tabs = 0;
                                                                  printf("Tabela final...\n");
                                                                  print_hashtable(tableFinal, tabs);
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

int yyerror(char *s) 
{
	printf("\n[Error!] Got syntax error, <Invalid char sequence:%s>\n", yytext);
	return(0);
}

int main(int argc, char const *argv[]) 
{
      if (argc != 2)
      {
            printf("You need to specify json file... e.g.:\t./toml2json \"FILE_NAME_JSON\"\n");
            return -1;
      }

      lastTable = g_hash_table_new(generalKey_hash, generalKey_equal);
      tableFinal = g_hash_table_new(generalKey_hash, generalKey_equal);

      switch(yyparse())
      {
            case 0:
      
            printf("Writing to Json...\n");
            writeToJson(tableFinal, argv[1]);
            printf("\nProgram finished...\n\tGoodbye :)\n");
            
            break;
      
            default :
                  printf("\n\tOops! Something went wrong :(\n");
      }

      return 0;
}