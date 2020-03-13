%{
/* Declaracoes C diversas */

int numberComments;

typedef struct commentThread 
{
   char*  id;
   char* user;
   char*  date;
   int	timestamp;
   char	*commentText;
   int   likes;
   int   hasReplies;
   int   numberReplies;

   // struct commentThread* replies;
} COMMENT_T;

%}

%%

([0-9]+)/[ ]comentários {
                           numberComments = atoi(yytext);
                           printf("Number of Comments: %d\n", numberComments);
                        }
.|\n           

%%
int yywrap()
{ 
   return(1); 
}


int main()
{
   
  yylex(); return 0; 
}

