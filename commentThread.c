#include <stdio.h>
#include <string.h>

#include "commentThread.h"


int printCT(COMMENT_T ct, FILE* file)
{
    fprintf(file, "\t{\n");

    fprintf(file, "\t\t\"id\": \"%s\" ,\n", ct->id);
    fprintf(file, "\t\t\"user\": \"%s\" ,\n", ct->user);
    fprintf(file, "\t\t\"date\": \"%s\" ,\n", ct->date);
    fprintf(file, "\t\t\"timestamp\": %ld ,\n", ct->timestamp);
    fprintf(file, "\t\t\"commentText\": \"%s\" ,\n", alterQuoteMark(ct->commentText));
    fprintf(file, "\t\t\"likes\": %d,\n" , ct->likes);
    fprintf(file, "\t\t\"hasReplies\": \"%s\" ,\n", ct->hasReplies ? "TRUE" : "FALSE");
    fprintf(file, "\t\t\"numberOfReplies\": %d ,\n", ct->numberReplies);

    fprintf(file, "\t\t\"replies\":\n");
}



int ctToJson(COMMENT_T ct, char* nameFile)
{
    FILE* file = fopen(nameFile, "a");

    fprintf(file, "\t[\n");

    while(ct != NULL)
    {

        printCT(ct, file);

        int nReplies = ct->numberReplies;

        if(ct->hasReplies)
        {
            fprintf(file, "\t\t[\n");

            while(nReplies > 0)
            {
                nReplies--;
                ct = ct->next;

                printCT(ct, file);
            }
            fprintf(file, "\t\t]\n");
        }
        else
        {
            if(ct->next != NULL)
                fprintf(file, "\t},\n");
            else
                fprintf(file, "\t}\n"); 
        }

        if(nReplies == 0)
            ct = ct->next;
    }

    fprintf(file, "]\n");
    
    return fclose(file);;
}

char* alterQuoteMark(char* text)
{
    char alter = '\"';
    char replace = '\'';

    for(int i=0; text[i] != '\0'; i++)
    {
        if(text[i] == alter)
            text[i] = replace;
    }

    return text;
}

char* takeSpacesOut(char* text)
{
    for(int i=0; text[i] != '\0'; i++)
    {
        if(text[i] == '\n')
            text[i] = ' ';
    }
    return text;
}