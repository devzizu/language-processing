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

int ctToJson(COMMENT_T ct, char* nameFile);
char* alterQuoteMark(char* text);
char* takeSpacesOut(char* text);
