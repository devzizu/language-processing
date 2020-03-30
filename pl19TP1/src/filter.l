%{
/* Declarations in C */
#include <stdio.h>
#include <time.h>

#include "commentThread.h" 

/*
 * Creates the structs needed to process the comments.
 * ct is the main struct where we put the data in.
 * p is a pointer used to get the correct number of replies and if that comment has replies. By the fact that
 * we put the replies in the next camp of the struct, the pointer p serves as a backpoint to update the valor
 * of "hasReplies" and "numberReplies" that were calculated during the insertion of the replies.
 * beginCt is the same as ct but from the first comment read from the HTML file. It's used to write the struct to
 * the Json file pretended as final result.
 */ 
COMMENT_T ct, p, beginCt;

/*
 * Variables used to store the values of the date of the comment before puted in the struct.
 */
int year, month, day, hour, minutes;

/*
 * Variables used to store the number of replies of a comment and if the 
 * current comment is the first one respectively.  
 */
int replies = 0, isBegin = 1;


/*
 * Stores the actual number of comments read and the number of Comments
 * that the HTML file contains.
 */
int countComments = 0, numberComments;


%}

%x OLIST
%x COMMENT_ID
%x AUTHORNAME ACCOUNTDISABLED USER
%x TIME DATE
%x COMMENT_CONTENT TEXT
%x LIKES NUMBERLIKES

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

// Begins the flex program
   yylex(); 
   
// Writes in into the Json file the Comment Thread from "O Publico"
   printf("\nWriting to Json...\n");
   ctToJson(beginCt, "../Files/comments.json");
   printf("Ended writing to \"comments.json\"\n");

// Number of comments that we are supposed to read
   printf("Comments in HTML: %d\n", numberComments);

// Actual number of comments that the filter has read
   printf("\nRead %d Comments.\n", countComments);

   if(numberComments == countComments)
      printf("[%d out of %d]\tThe filter has read the correct number of comments..\n", countComments, numberComments);
   else
      printf("[%d out of %d]\tThe filter hasn't read the correct number of comments!!\n", countComments, numberComments);


// Ends the program
   printf("\nGoodbye...\n");

   return 0; 
}
