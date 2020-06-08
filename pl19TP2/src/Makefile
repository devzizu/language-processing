
BASE_FILE = toml2json

YACC_FILE = $(BASE_FILE).y
LEX_FILE  = $(BASE_FILE).l

all: yacc flex
	gcc -o $(BASE_FILE) y.tab.c

# -d: generates y.tab.h que contém a tabela 
#     de token names -> token codes
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
