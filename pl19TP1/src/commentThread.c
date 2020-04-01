#include <stdio.h>
#include <string.h>

#include "commentThread.h"


int printCT(COMMENT_T ct, FILE* file, char* ahead)
{
    fprintf(file, "%s{\n", ahead);

    fprintf(file, "%s\t\"id\": \"%s\" ,\n", ahead, ct->id);
    fprintf(file, "%s\t\"user\": \"%s\" ,\n", ahead, ct->user);
    fprintf(file, "%s\t\"date\": \"%s\" ,\n", ahead, ct->date);
    fprintf(file, "%s\t\"timestamp\": %ld ,\n", ahead, ct->timestamp);
    fprintf(file, "%s\t\"commentText\": \"%s\" ,\n", ahead, alterQuoteMark(ct->commentText));
    fprintf(file, "%s\t\"likes\": %d,\n" , ahead, ct->likes);
    fprintf(file, "%s\t\"hasReplies\": \"%s\" ,\n", ahead, ct->hasReplies ? "TRUE" : "FALSE");
    fprintf(file, "%s\t\"numberOfReplies\": %d ,\n", ahead, ct->numberReplies);

    fprintf(file, "%s\t\"replies\":", ahead);
}


int ctToJson(COMMENT_T ct, char* nameFile)
{
    FILE* file = fopen(nameFile, "w");

    fprintf(file, "{\n");
    fprintf(file, "\"commentThread\":");
    
    char* ahead = "\t";

    fprintf(file, "\t[\n");

    while(ct != NULL)
    {
        printCT(ct, file, ahead);

        int nReplies = ct->numberReplies;
        
        if(ct->hasReplies)
        {
            fprintf(file, "\n\t\t[\n");
            
            while(nReplies > 0)
            {
                nReplies--;
                ct = ct->next;

                ahead = "\t\t\t";
                printCT(ct, file, ahead);

                fprintf(file, "\t[ ]\n");
                
                if(nReplies > 0)
                    fprintf(file, "%s},\n", ahead);
                else
                    fprintf(file, "%s}\n", ahead);
            }

            fprintf(file, "\t\t]\n");

            if(ct->next != NULL)
                fprintf(file, "\t},\n");
            else
                fprintf(file, "\t}\n");
        }
        else
        {           
            fprintf(file, "\t[ ]\n");
            
            if(ct->next != NULL)
                fprintf(file, "\t},\n");
            else
                fprintf(file, "\t}\n"); 
        }

        ahead = "\t";

        if(nReplies == 0)
            ct = ct->next;
    }

    fprintf(file, "]\n}\n");
    
    return fclose(file);
}

char* alterQuoteMark(char* text)
{
    char alter = '\"';
    char replace = '\'';
    int i;

    for(i=0; text[i] != '\0'; i++)
    {
        if(text[i] == alter)
            text[i] = replace;
    }

    i--; 

    while(text[i] == ' ')
    {
        i--;
    }
    
    text[i+1] = '\0';

    return text;
}

char* takeEnterOut(char* text)
{
    for(int i=0; text[i] != '\0'; i++)
    {
        if(text[i] == '\n')
            text[i] = ' ';
    }
    return text;
}