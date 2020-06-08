%{
#define _GNU_SOURCE

#include <stdio.h>
#include <string.h>
#include <ctype.h>

int yyerror(char* s);
int yylex(); 

%}

%union { char c; char *string; float number; } 

%token <string> KEY STRING BOOL DATE
%token <number> NUM 

%%

Toml : Language
     ;

Language : 
         | Atrib Statement
         | Declarations
         ;

Statement : 
          | Declarations
          ;

Declarations : Definition
             | Declarations Definition
             ;

Definition : Table Atribuitions
           | '[' Table ']' Atribuitions
           ;

Table : '[' Term ']'
      ;

Term : KEY
     | Term '.' KEY
     ;

Atribuitions : 
             | Atribuitions Atrib
             ;

Atrib : KEY '=' Value
      | STRING '=' Value
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

int yyerror(char *s) 
{
	printf("erro: %s\n",s);
	return(0);
}

int main() 
{
  yyparse();
  return 0;
}