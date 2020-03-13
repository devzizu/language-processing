%{
/* Declaracoes C diversas */

int numberComments;

struct commentThread 
{
   char*  id;
   char  user[50];
   char  date[100];
   int	timestamp;
   char	commentText[200];
   int   likes;
   int   hasReplies;
   int   numberReplies;

   struct commentThread* replies;
};

typedef struct commentThread* commentT;

char dest[50];

%}

%%

(?i:data-comment-id=)\"[^\"]*\"   {
                  ct->id = strncpy(dest, yytext + 18, strlen(yytext + 18) - 1);
                  printf("%s\n", ct -> id);
                  }
.|\n           

%%
int yywrap()
{ 
   return(1); 
}


int main()
{ 
   commentT ct = malloc(sizeof(struct commentThread));
   yylex(); return 0; 
}

