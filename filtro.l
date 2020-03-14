%{
/* Declaracoes C diversas */
// #include <glib.h>

int numberComments;

typedef struct commentThread 
{
   char*  id;
   char*  user;
   char*  date;
   int	 timestamp;
   char*  commentText;
   int    likes;
   int    hasReplies;
   int    numberReplies;

   //struct commentThread* replies;
} *COMMENT_T;

COMMENT_T ct;

%}

%x COMMENT_ID


%%
[0-9]+/[ ]+[-'a-zA-ZÀ-ÖØ-öø-ÿ]+<\/h3>\] { 
                                          numberComments = atoi(yytext);
                                          printf("Number of Comments: %d\n", numberComments); 
                                        }

\<li.*data-comment-id\=\" { BEGIN COMMENT_ID; }
<COMMENT_ID>[A-Za-z0-9-]+/\"> { 
                                 ct->id = strdup(yytext);
                                 printf("%s\n", ct->id); 
                                 BEGIN INITIAL; 
                              }
                           

.|\n           

%%
int yywrap()
{ 
   return(1); 
}

int main()
{
   ct = (COMMENT_T) malloc(sizeof(struct commentThread));
   yylex(); return 0; 
}

