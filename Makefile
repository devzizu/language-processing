#Makefile para compilar o projeto todo

FF = flex
EXEC = filter
HTMLFILE = Publico_extraction.html

CC = gcc -g
CGLAGS = -I
DEPS = $(wildcard *.h)
OBJ = $(patsubst %.c,%.o,$(wildcard *.c))

install: clean flex filter

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

filter: $(OBJ)
	@echo "[..] Compiling filter..."
	$(CC) -o $@ $^ $(CFLAGS) -lm

flex:
	@echo "[..] Compiling with Flex..."
	flex filter.l

run:
	./$(EXEC) < $(HTMLFILE)

clean: 
	@echo "[..] Cleaning trash files..."
	rm -rf filter lex.yy.c Comentarios.json

