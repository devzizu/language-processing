#include "include/generalKey.h"
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


