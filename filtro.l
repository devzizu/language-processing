%{
/* Declaracoes C diversas */
#include <stdio.h>
#include <time.h>
//#include <glib.h>

int numberComments;
int test = 0;

typedef struct commentThread 
{
   char*     id;
   char*     user;
   char*     date;
   long int	 timestamp;
   char*     commentText;
   int       likes;
   int       hasReplies;
   int       numberReplies;

   struct commentThread* replies;

   struct commentThread* next;

} *COMMENT_T;

COMMENT_T ct;
int year, month, day, hour, minutes;

int replies = 0;

%}

%x OLIST
%x COMMENT_ID
%x NOMEAUTOR
%x CONTADESATIVADA
%x USER
%x TIME
%x DATE
%x COMMENT_CONTENT
%x TEXT
%x LIKES
%x NUMBERLIKES


%%
[0-9]+/[ ]+[-'a-zA-ZÀ-ÖØ-öø-ÿ]+<\/h3>\] { 
                                          numberComments = atoi(yytext);
                                          printf("Number of Comments: %d\n", numberComments); 
                                        }

\<ol(.*)class\=\"comments__list\"(.*)\>\< { BEGIN OLIST; }

<OLIST>li(.*)data-comment-id\=\" {  
                                    BEGIN COMMENT_ID; 
                                 }
<OLIST>\<ol(.*)\"comments__list\"\>\n*\<  {  
                                             replies = 0;
                                             printf("\t\tREPLIES = TRUE\n");
                                             ct->hasReplies = 1;
                                             ct->replies = (COMMENT_T) malloc(sizeof(struct commentThread));
                                             BEGIN COMMENT_ID;
                                          }
<OLIST>\<\/ol\>   { 
                     ct->numberReplies = replies;
                     printf("Number of Replies: %d\n", replies);
                     replies = 0;
                  }
<OLIST>.|\n

<COMMENT_ID>[A-Za-z0-9-]+/\"> {  
                                 replies++;
                                 ct->id = strdup(yytext);
                                 printf("Id: %s\n", ct->id);
                                 BEGIN USER; 
                              }
<COMMENT_ID>.|\n

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

<TIME>\<time(.*)\>\n\<a(.*)\"\>    { BEGIN DATE; }
<TIME>.|\n

<DATE>(.*)/\<\/a> {
                     ct->date = strdup(yytext);
                     printf("\tDATE: %s\n", ct->date);

                     sscanf(yytext, "%d.%d.%d %d:%d", &day, &month, &year, &hour, &minutes);

                     struct tm t;
                     time_t data;

                     t.tm_year = year;
                     t.tm_mon = month;
                     t.tm_mday = day;
                     t.tm_hour = hour;
                     t.tm_min = minutes;
                     t.tm_sec = 0;
                     t.tm_isdst = -1;
                     data = mktime(&t);

                     ct->timestamp = (long) data;
                     printf("\tTimestamp: %ld\n", data);

                     BEGIN COMMENT_CONTENT;
                  }

<COMMENT_CONTENT>\<p\>[ \n]*  { BEGIN TEXT; }
<COMMENT_CONTENT>.|\n

<TEXT>[^\<]*   {     
                  test++;
                  printf("\tText: %s\n\n", yytext);
                  ct->commentText = strdup(yytext);
                  BEGIN LIKES;
               }

<LIKES>(.*)\"updatable[ ]+count\"[ ]+\=\"likes\"\>  { BEGIN NUMBERLIKES; }
<LIKES>.|\n { 
               ct = ct->next;
               ct = (COMMENT_T) malloc(sizeof(struct commentThread));
               BEGIN OLIST; 
            }

<NUMBERLIKES>[0-9]*/\<span\>  {
                                 ct->likes = atoi(yytext);
                                 ct = ct->next;
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


   printf("ID CT: %s\n",ct->user);

   return 0; 
}
