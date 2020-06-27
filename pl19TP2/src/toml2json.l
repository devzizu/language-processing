%{

  #include <string.h>

  #include "y.tab.h"

  int IS_RHS = 0;

char* addQuotes(char* string);

%}

%%

[0-9]+-[0-9]+-[0-9]+([T ][0-9]+\:[0-9]+\:[0-9]+(Z|([+-][0-9]+\:[0-9]+))?)?    { yylval.string = strdup(addQuotes(yytext)); IS_RHS = 0; return(DATE); }
[\[\]=,]                                                                      { IS_RHS = 1; return(yytext[0]); }
[.#]                                                                          { IS_RHS = 0; return(yytext[0]); }
[-+]?[0-9]*(\.)?[0-9]+([eE][-+]?[0-9]+)?                                      { yylval.number = atof(yytext); IS_RHS = 0; return(NUM); }
(true|false)                                                                  { yylval.string = strdup(yytext); IS_RHS = 0; return(BOOL); }
[a-zA-Z_0-9-]+                                                                { 
                                                                                //printf("\tKey_normal : %s\n", yytext);
                                                                                yylval.string = strdup(yytext); 
                                                                                IS_RHS = 1;
                                                                                return (KEY_NORMAL);
                                                                              }
["'][^'"=]*["']                                                               { 
                                                                                if (*yytext != *(yytext+strlen(yytext)-1)) return (ERRO);
                                                                                if (IS_RHS) 
                                                                                {
                                                                                  //printf("\tString : %s\n", yytext);
                                                                                  yylval.string = strdup(yytext); 
                                                                                  IS_RHS = 0;
                                                                                  return (STRING);
                                                                                } 
                                                                                else 
                                                                                  {
                                                                                    if (strlen(yytext)==2) return (ERRO);
                                                                                    //printf("\tKey_string : %s\n", yytext);
                                                                                    yylval.string = strdup(yytext); 
                                                                                    IS_RHS = 1;
                                                                                    return (KEY_STRING);
                                                                                  }
                                                                                }                                                                              
#.*\n                 	 	        			               
[\n\t\r ]
.    return ERRO;
%%

char* addQuotes(char* string)
{
  char* result = (char*) malloc(strlen(string) + 2);

  result[0] = '\0';
  strcat(result, "\"");
  strcat(result, string);
  strcat(result, "\"");

  return result;
}

int yywrap()
{
  return(1);
}