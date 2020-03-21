%{
/* Declarations in C */
#include <stdio.h>
#include <time.h>

#include "commentThread.h" 
 
COMMENT_T ct, p, beginCt;

int year, month, day, hour, minutes;
int replies = 0, isBegin = 1;

int countComments = 0, numberComments;


%}

%x OLIST
%x COMMENT_ID
%x AUTHORNAME
%x ACCOUNTDISABLED
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
                                        }

\<ol(.*)class\=\"comments__list\"(.*)\>\< { 
                                             ct = (COMMENT_T) malloc(sizeof(struct commentThread));
                                             BEGIN OLIST; 
                                          }

<OLIST>li(.*)data-comment-id\=\" {  
                                    ct -> next = (COMMENT_T) malloc(sizeof(struct commentThread));
                                    ct = ct->next;

                                    ct->timestamp = 0;
                                    ct->likes = 0;
                                    ct->hasReplies = 0;
                                    ct->numberReplies = 0;

                                    BEGIN COMMENT_ID;
                                 }
<OLIST>\<ol(.*)\"comments__list\"\>\n*\<  {  
                                             ct->hasReplies = 1;
                                             p = ct;

                                             ct->next = (COMMENT_T) malloc(sizeof(struct commentThread));
                                             ct = ct->next;

                                             ct->timestamp = 0;
                                             ct->likes = 0;
                                             ct->hasReplies = 0;
                                             ct->numberReplies = 0;

                                             replies = 0;

                                             BEGIN COMMENT_ID;
                                          }
<OLIST>\<\/ol\>   { 
                     if(countComments <= 85)
                        p->numberReplies = replies;
                  }
<OLIST>.|\n

<COMMENT_ID>[A-Za-z0-9-]+/\"> {  
                                 replies++;
                                 ct->id = strdup(yytext);

                                 BEGIN USER; 
                              }
<COMMENT_ID>.|\n

<USER>\<h5(.*)\>\n\<a(.*)\"> { BEGIN AUTHORNAME; }
<USER>\<h5(.*)\>\n   { BEGIN ACCOUNTDISABLED; }
<USER>.|\n     

<AUTHORNAME>(.*)/\<\/a\>\n\<\/h5\> {
                                    ct->user = strdup(yytext);
                                    BEGIN TIME;
                                  }

<ACCOUNTDISABLED>(.*)/\n[ ]+\<\/h5\> {
                                       ct->user = strdup(yytext);
                                       BEGIN TIME;
                                     }      

<TIME>\<time(.*)\>\n\<a(.*)\"\>    { BEGIN DATE; }
<TIME>.|\n

<DATE>(.*)/\<\/a> {
                     ct->date = strdup(yytext);

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

                     BEGIN COMMENT_CONTENT;
                  }

<COMMENT_CONTENT>\<p\>[ \n]*  { BEGIN TEXT; }
<COMMENT_CONTENT>.|\n

<TEXT>[^\<]*   {     
                  countComments++;
                  ct->commentText = strdup(takeEnterOut(yytext));

                  BEGIN LIKES;
               }

<LIKES>(.*)\"updatable[ ]+count\"[ ]+\=\"likes\"\>  { BEGIN NUMBERLIKES; }
<LIKES>.|\n { 
               if(isBegin)
               {
                  isBegin = 0;
                  beginCt = ct;
               }
               BEGIN OLIST; 
            }

<NUMBERLIKES>[0-9]*/\<span\>  {
                                 ct->likes = atoi(yytext);
                                 if(isBegin)
                                 {
                                    isBegin = 0;
                                    beginCt = ct;
                                 }

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


// -----------------------------------------------------------------------------------------

   yylex(); 
   
// -----------------------------------------------------------------------------------------
// Beginning to create Json file
// Begins the commentThread structure in Json

   FILE* file = fopen("../Files/comments.json", "w");

   fprintf(file, "{\n");
   fprintf(file, "\"commentThread\":");
   fclose(file);

// -----------------------------------------------------------------------------------------
// Writes in the Json file
   printf("\nWriting to Json...\n");
   ctToJson(beginCt, "../Files/comments.json");
   printf("Ended writing to 'comments.json'\n");

// -----------------------------------------------------------------------------------------

   printf("\nRead %d Comments.\n", countComments);
   printf("Comments in html: %d\n", numberComments);

   printf("\n\tGoodbye...\n");

   return 0; 
}
