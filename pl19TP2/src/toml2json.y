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

GHashTable* JSON_STRUCT;

GHashTable* temp;

GHashTable* tableFinal;

GEN_KEY gen_key;

VALUE val;



// GSList* glist = (GSList*) malloc(sizeof(GSList));

%}

%union { char c; char *string; float number; GHashTable* json_struct; } 

%token <string> KEY_NORMAL KEY_STRING STRING BOOL DATE
%token <number> NUM 
%token ERRO 
%type <json_struct> Language Statement Declarations Definition Table TermTable
%type <string> Key Term

%%

Toml : Language                                       { 
                                                            GList* keys = g_hash_table_get_keys($1);

                                                            int size = g_list_length(keys);

                                                            printf("Tamanho da lista -> %d\n", size);

                                                            for(int i = 0; i < size; i++) 
                                                            { 
                                                                  GList *element = g_list_nth(keys, i);
                                                                  printf("Hashtable key -> %s;\n", ((GEN_KEY_PTR) (element -> data)) -> key);
                                                            }
                                                      }
     ;

Language :                                            { ; }
         | Atrib Statement                            { $$ = $2; }
         | Declarations                               { $$ = $1; }
         ;

Statement :                                           { ; }           
          | Declarations                              { $$ = $1; }
          ;

Declarations : Definition                             {
                                                            /*int exists = g_hash_table_insert(JSON_STRUCT, gk, NULL);

                                                            if (!exists) 
                                                            {
                                                                  printf("Erro!");
                                                                  return(1);
                                                            } */
                                                            $$ = $1;
                                                      }
             | Declarations Definition                { $$ = $2; }
             ;

Definition : Table Atribuitions                       { $$ = $1; }
           | '[' Table ']' Atribuitions               { ; }
           ;

Table : '[' TermTable ']'                             { $$ = $2; }               
      ;

TermTable : Key                                       { 
                                                            printf("Key -> %s\n", $1);
                                                            GEN_KEY_PTR gk = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            gk -> key = $1;
                                                            gk -> type = ISTABLE;  // é preciso alterar isto depois (acima)

                                                            int exists = g_hash_table_insert(temp, gk, NULL);

                                                            if (!exists) 
                                                            {
                                                                  printf("Erro!");
                                                                  return(1);
                                                            }

                                                            $$ = temp;
                                                      }                         
          | Key '.' TermTable                         {
                                                            GEN_KEY_PTR gk = (GEN_KEY_PTR) malloc(sizeof(GEN_KEY));
                                                            gk -> key = $1;
                                                            gk -> type = ISTABLE;  // é preciso alterar isto depois (acima)

                                                            int exists = g_hash_table_insert(tableFinal, gk, $3);

                                                            if (!exists) 
                                                            {
                                                                  printf("Erro!");
                                                                  return(1);
                                                            }

                                                            $$ = tableFinal;       
                                                      }           
          ; 

Term : Key                                            { 
                                                            $$ = $1;
                                                      }                         
     | Key '.' Term                                   {
                                                            $$ = strdup($1);
                                                            strcat($$, ".");
                                                            strcat($$, $3);
                                                      }           
     ; 


Key : KEY_STRING                                      { $$ = $1; }
    | KEY_NORMAL                                      { $$ = $1; }
    ;

Atribuitions : 
             | Atribuitions Atrib
             ;

Atrib : Term '=' Value                                
      ;

Value : NUM
      | Array
      | BOOL
      | STRING
      | DATE
      ;

Array : '[' ']'
      | '[' ArrayString EndArray ']'
      | '[' ArrayNum EndArray ']'
      | '[' Arrays EndArray ']'
      | '[' ArrayBool EndArray ']'
      | '[' ArrayDate EndArray ']'
      ;

ArrayString : STRING 
            | ArrayString ',' STRING
            ;

ArrayNum : NUM
         | ArrayNum ',' NUM
         ;

ArrayBool : BOOL 
          | ArrayBool ',' BOOL
          ;

ArrayDate : DATE 
          | ArrayDate ',' DATE
          ;

Arrays : Array 
       | Arrays ',' Array
       ;

EndArray : 
         | ','
         ;

%%

#include "lex.yy.c"

extern char* yytext;

int yyerror(char *s) 
{
	printf("Error: Got syntax error, <Invalid char sequence:%s>\n", yytext);
	return(0);
}

int main() 
{
      JSON_STRUCT = g_hash_table_new(generalKey_hash, generalKey_equal);
      temp = g_hash_table_new(generalKey_hash, generalKey_equal);
      tableFinal = g_hash_table_new(generalKey_hash, generalKey_equal);

      yyparse();
      return 0;
}