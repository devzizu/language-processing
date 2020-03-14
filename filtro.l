%{
/* Declaracoes C diversas */
// #include <glib.h>

int numberComments;
int test = 0;

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
%x OLIST
%x NOMEAUTOR
%x USER


%%
[0-9]+/[ ]+[-'a-zA-ZÀ-ÖØ-öø-ÿ]+<\/h3>\] { 
                                          numberComments = atoi(yytext);
                                          printf("Number of Comments: %d\n", numberComments); 
                                        }

\<ol(.*)id\=\"approved-comments\"\> { BEGIN OLIST; }

\<ol[ ]+class\=\"comments__list\"\>   { BEGIN OLIST; }

<OLIST>\<li.*data-comment-id\=\" { BEGIN COMMENT_ID; }  
<OLIST>\<\/ol\>   { BEGIN INITIAL; } 
<OLIST>.|\n

<COMMENT_ID>[A-Za-z0-9-]+/\"> { 
                                 ct->id = strdup(yytext);
                                 test++;
                                 printf("Id: %s\n", ct->id);
                                 BEGIN USER; 
                              }

<USER>\<a(.*)\"\> { BEGIN NOMEAUTOR; }
<NOMEAUTOR>.*/\<  {
                     ct->user = strdup(yytext);
                     printf("User: %s\n", ct->user); 
                     BEGIN OLIST;
                  }
<USER>.|\n        


.|\n           

%%
int yywrap()
{ 
   return(1); 
}

int main()
{
   ct = (COMMENT_T) malloc(sizeof(struct commentThread));
   yylex(); 
   printf("\nComentarios: %d\n", test);
   return 0; 
}

