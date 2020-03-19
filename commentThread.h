
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
} *COMMENT_T;



