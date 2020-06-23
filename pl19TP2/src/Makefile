
# Notes: 
# -> install glib from this libgtk2.0-dev linux: 
#    > sudo apt-get install libgtk2.0-dev

# Yacc and Flex file variables

BASE_FILE = toml2json

YACC_FILE = $(BASE_FILE).y
LEX_FILE  = $(BASE_FILE).l

# Glib linking flags

GLIB = `pkg-config --cflags --libs glib-2.0`
CFLAGS = -Wall -Wextra -g

all: yacc flex compile

compile: generalKey.o
	gcc y.tab.c $(GLIB) -o $(BASE_FILE) generalKey.o

generalKey.o: generalKey.c
	gcc -c generalKey.c $(GLIB) 

yacc:
	yacc -d $(YACC_FILE)

flex:
	flex $(LEX_FILE)

clean:
	rm -rf lex.yy.c y.tab.* $(BASE_FILE)

run:
	@clear
	@echo "Running yacc file: $(BASE_FILE).y/l\n"
	./$(BASE_FILE)