#ifndef _COMMENTTHREAD_
#define _COMMENTTHREAD_

/*
 * Struct commentThread that implements, in C, the Json structure that we want as result
 * In this struct we have the replies of a comment (if he has any) in the next element of the struct
 * We can identify which ones are the replies by the parameter "hasReplies" and "numberReplies"
 * that indicates us that the next numberReplies are the replies of the main comment (which has "hasReplies" at 1) 
 */
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

   struct commentThread* next;

} *COMMENT_T;

/*
 * Function that writes on the file the structure COMMENT_T
 * It receives an ahead to better format of the file
 */
int printCT(COMMENT_T ct, FILE* file, char* ahead);

/*
 * Receives a COMMENT_T and writes it on the file indicated by 'nameFile'
 */
int ctToJson(COMMENT_T ct, char* nameFile);

/*
 * Replaces the character " on a string by the character '
 * This function is necessary to make the file Json correct
 */
char* alterQuoteMark(char* text);

/*
 * Replaces the enter (\n) in the commentary by a space.
 * Then takes out the spaces from the end of the text
 * It is necessary to make the file Json correct
*/
char* takeEnterOut(char* text);

#endif
