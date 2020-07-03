#include "include/generalKey.h"
#include "include/jsonWriter.h"
#include <glib.h>
#include <stdio.h>
#include <unistd.h>

guint generalKey_hash(gconstpointer gen_key) 
{
    return(g_str_hash( (gconstpointer) ((GEN_KEY_PTR) gen_key) -> key));
}

gboolean generalKey_equal(gconstpointer gen_key1, gconstpointer gen_key2)
{
    return(g_str_equal( ((gconstpointer) ((GEN_KEY_PTR) gen_key1) -> key) , ((gconstpointer) ((GEN_KEY_PTR) gen_key2) -> key)));
}

void insert_table(GHashTable* tableIn, GHashTable* tableOut)
{
      if (tableIn == NULL)
            return;
      if (tableOut == NULL)
      {
            tableOut = g_hash_table_new(generalKey_hash, generalKey_equal);
      }
      
      GList* keys = g_hash_table_get_keys(tableIn);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTableIn = (GEN_KEY_PTR) (elementTable -> data);
      
      GHashTable* valueTableIn = (GHashTable*) g_hash_table_lookup(tableIn, keyTableIn);

      g_hash_table_insert(tableOut, keyTableIn, valueTableIn);     
}

int update_table(GHashTable* table, GHashTable* FINAL) 
{
      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);

      if (g_hash_table_contains(FINAL, keyTable))  
      {
            GHashTable* valuesTable = (GHashTable*) g_hash_table_lookup(table, keyTable);
            GHashTable* valuesFinal = (GHashTable*) g_hash_table_lookup(FINAL, keyTable);

            if (valuesFinal == NULL)
            {
                  GList* keysFinal = g_hash_table_get_keys(FINAL);

                  for (GList* iter = keysFinal; iter != NULL; iter = iter -> next) 
                  {                  
                        GEN_KEY_PTR keyIter = (GEN_KEY_PTR) (iter -> data);

                        if (!strcmp(keyIter -> key, keyTable -> key) && (keyIter -> type != ISTABLE))
                        {
                              if (keyIter -> isDefined == DEFINED) 
                                    return -1;  
                        }
                  }

                  if (valuesTable != NULL)
                  {
                        valuesFinal = g_hash_table_new(generalKey_hash, generalKey_equal);
                        g_hash_table_insert(FINAL, keyTable, valuesTable);
                        
                        return 0;
                  }
                        
                  return -1;        
            }
            else
            {
                  if (valuesTable == NULL)
                  {
                        GList* k = g_hash_table_get_keys(FINAL);
                        for (int i = 0; i < g_list_length(k); i++)
                        {
                              GList *eTable = g_list_nth(k, i);
                              GEN_KEY_PTR keyFinal = (GEN_KEY_PTR) (eTable -> data);
                        
                              if (!strcmp(keyFinal -> key, keyTable -> key))
                              {
                                    if (keyFinal -> isDefined == DEFINED) 
                                          return -1;
                                    else
                                    {
                                          keyFinal -> isDefined = DEFINED;
                                          keyFinal -> val = keyTable -> val;
                                          GHashTable* vF = (GHashTable*) g_hash_table_lookup(FINAL, keyFinal);
                                          g_hash_table_insert(FINAL, keyFinal, vF);
                                          
                                          return 0;
                                    }      
                              }
                        }                        
                  }
                  else
                        return update_table(valuesTable, valuesFinal);
            }
      }
      else
      {
            insert_table(table, FINAL); 
            return 0;
      }    
}

int add_lastTable(GHashTable* table, GHashTable* term, VALUE val, GHashTable* beginTable, int l_TTable, int length_Term, GHashTable* tableFinal)
{           
      int *tabs = (int*) malloc(sizeof(int));

      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);

      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);
      GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTable);

      if (l_TTable == 1)
      {            
            GList* listKeysTerm = g_hash_table_get_keys(term);
            GList *elem = g_list_nth(listKeysTerm, 0);
            GEN_KEY_PTR keyTerm = (GEN_KEY_PTR) (elem -> data);

            if (valueTable == NULL)
            {     
                  GHashTable* valuesFinal = (GHashTable*) g_hash_table_lookup(tableFinal, keyTable);
                  
                  if (valuesFinal != NULL && g_hash_table_contains(valuesFinal, keyTerm))
                        return -1;

                  add_value_lastTable(term, val, term, length_Term);
                  g_hash_table_insert(table, keyTable, term);
            }
            else
            {
                  if (g_hash_table_contains(valueTable, keyTerm)) 
                  {
                        GHashTable* valuesByTerm = (GHashTable*) g_hash_table_lookup(valueTable, keyTerm);

                        if (valuesByTerm == NULL || !g_hash_table_size(valuesByTerm))
                              return -1;
                  }

                  add_value_lastTable(term, val, term, length_Term);

                  if (update_table(term, valueTable) == -1) 
                        return -1;

            }
            
            update_table(beginTable, tableFinal);

            return 0;
      }
      else
            return add_lastTable(valueTable, term, val, beginTable, l_TTable - 1, length_Term, tableFinal);
}

void add_value_lastTable(GHashTable* table, VALUE val, GHashTable* beginTable, int l_TTable)
{
      GList* keys = g_hash_table_get_keys(table);
      GList *elementTable = g_list_nth(keys, 0);
      GEN_KEY_PTR keyTable = (GEN_KEY_PTR) (elementTable -> data);
      
      GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTable);

      if (l_TTable == 1)                    
            keyTable -> val = val;
      else
            add_value_lastTable(valueTable, val, beginTable, l_TTable - 1);
}

int insert_termAtrib(GHashTable* term, VALUE val, GHashTable* table, int l_TTable)
{
      GList* keysTerm = g_hash_table_get_keys(term);
      GList *elementTerm = g_list_nth(keysTerm, 0);
      GEN_KEY_PTR keyTerm = (GEN_KEY_PTR) (elementTerm -> data);

      if (g_hash_table_contains(table, keyTerm))
      {
            GHashTable* valueTable = (GHashTable*) g_hash_table_lookup(table, keyTerm);

            if (valueTable == NULL)      
                  return -1;
            else
            {
                  GHashTable* valueTerm = (GHashTable*) g_hash_table_lookup(term, keyTerm);

                  if (valueTerm == NULL)
                        return -1;
                  
                  return insert_termAtrib(valueTerm, val, valueTable, l_TTable - 1);
            }
      }
      else
      {
          add_value_lastTable(term, val, term, l_TTable);
            
            if(update_table(term, table))
                  return -1;
      }

      return 0;
}

void print_hashtable(GHashTable* HT, int* tabs) 
{
    if (HT == NULL) 
      {
            for (int j = 0; j < *tabs; j++)
                  printf("\t");
            printf("(null value)\n");
            return;
      }

      GList* keys = g_hash_table_get_keys(HT);

      for (int j = 0; j < *tabs; j++)
      printf("\t");

      printf("HashTable:\n");

      for (int i = 0; i < g_list_length(keys); i++) 
      {
            for (int j = 0; j < *tabs; j++)
                  printf("\t");

            GList *element = g_list_nth(keys, i);

            char* valueAsString = getValueString( (GEN_KEY_PTR) element -> data);
            printf("> Key: %s (%s), values:\n", ((GEN_KEY_PTR) (element -> data)) -> key, valueAsString);
            //free(valueAsString);

            gpointer value = g_hash_table_lookup(HT, (GEN_KEY_PTR) (element -> data));
            *tabs = *tabs + 1;
            print_hashtable((GHashTable*) value, tabs);
            *tabs = *tabs - 1;
      }

      printf("\n");
}