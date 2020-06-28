
# Notes: 
# -> install glib from this libgtk2.0-dev linux: 
#    > sudo apt-get install libgtk2.0-dev

# Yacc and Flex file variables

BASE_FILE = toml2json

YACC_FILE = $(BASE_FILE).y
LEX_FILE  = $(BASE_FILE).l

JSON_FILE_OUTPUT = ../Files/Jsons/jsonResult.json

# Glib linking flags

GLIB = `pkg-config --cflags --libs glib-2.0`
CFLAGS = -Wall -Wextra -g

all: yacc flex compile

compile: generalKey.o jsonWriter.o
	gcc y.tab.c $(GLIB) -o $(BASE_FILE) generalKey.o jsonWriter.o

generalKey.o: generalKey.c
	gcc -c generalKey.c $(GLIB)

jsonWriter.o: jsonWriter.c
	gcc -c jsonWriter.c $(GLIB)

yacc:
	yacc -d $(YACC_FILE)

flex:
	flex $(LEX_FILE)

clean:
	rm -rf lex.yy.c y.tab.* *.o $(BASE_FILE)
	rm -rf $(JSON_FILE_OUTPUT)

run:
	@clear
	@echo "Running yacc/flex parser: $(BASE_FILE).y/l\n"
	./$(BASE_FILE) $(JSON_FILE_OUTPUT)