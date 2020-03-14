%{
/* Declaracoes C diversas */
// #include <glib.h>
#include <stdio.h>
#include <time.h>

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
%x CONTADESATIVADA
%x USER
%x TIME
%x DATE


%%
[0-9]+/[ ]+[-'a-zA-ZÀ-ÖØ-öø-ÿ]+<\/h3>\] { 
                                          numberComments = atoi(yytext);
                                          printf("Number of Comments: %d\n", numberComments); 
                                        }

\<ol(.*)class\=\"comments__list\"(.*)\>\< { BEGIN OLIST; }

<OLIST>li(.*)data-comment-id\=\" { BEGIN COMMENT_ID; }  
<OLIST>.|\n

<COMMENT_ID>[A-Za-z0-9-]+/\"> { 
                                 ct->id = strdup(yytext);
                                 test++;
                                 printf("Id: %s\n", ct->id);
                                 BEGIN USER; 
                              }

<USER>\<h5(.*)\>\n\<a(.*)\"> { BEGIN NOMEAUTOR; }
<USER>\<h5(.*)\>\n   { BEGIN CONTADESATIVADA; }
<USER>.|\n  

<NOMEAUTOR>(.*)/\<\/a\>\n\<\/h5\> {
                                    ct->user = strdup(yytext);
                                    printf("\tUser: %s\n", ct->user); 
                                    BEGIN TIME;
                                  }

<CONTADESATIVADA>(.*)/\n[ ]+\<\/h5\> {
                                    ct-> user = strdup(yytext);
                                    printf("\tUser: %s\n", ct->user);
                                    BEGIN TIME;
                                 }      

<TIME>(.*)\<time(.*)\>\n\<a(.*)\"\>    { BEGIN DATE; }
<TIME>.|\n

<DATE>(.*)/\<\/a> {
                     ct->date = strdup(yytext);
                     printf("\tDATE: %s\n", ct->date);

                     // falta o timestamp

                     BEGIN OLIST;
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
   yylex(); 
   printf("\nComentarios: %d\n", test);
   return 0; 
}

