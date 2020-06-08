%{
#include "y.tab.h"
%}

%%

[0-9]+-[0-9]+-[0-9]+([T ][0-9]+\:[0-9]+\:[0-9]+(Z|([+-][0-9]+\:[0-9]+))?)?    { yylval.string = strdup(yytext); return(DATE); }
[\[\]=,.#]                                                                    { return(yytext[0]); }
[-+]?[0-9]*(\.)?[0-9]+([eE][-+]?[0-9]+)?                                      { yylval.number = atof(yytext); return(NUM); }
\"[^"]+\"                                                                     { yylval.string = strdup(yytext); return(STRING); }
(true|falso)                                                                  { yylval.string = strdup(yytext); return(BOOL); }
[a-zA-Z_0-9-]+                                                                { 
                                                                                yylval.string = strdup(yytext); return(KEY);
                                                                              }

#.*\n                 	 	        			               
[\n\t\r ]

%%

int yywrap(){
  return(1);
}