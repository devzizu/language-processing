#Makefile para compilar o projeto todo

FF = flex
EXEC = filter
HTMLFILE = ../Files/Publico_extraction.html

CC = gcc -g
CGLAGS = -I
DEPS = $(wildcard CommentThread/*.h)
OBJ = $(patsubst %.c, %.o, $(wildcard *.c))
DIR = CommentThread

install: clean flex filter

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

filter: $(OBJ)
	@echo "[..] Compiling filter..."
	$(CC) -o $@ $^ $(CFLAGS) -lm

flex:
	@echo "[..] Compiling with Flex..."
	$(FF) filter.l

run:
	./$(EXEC) < $(HTMLFILE)

clean: 
	@echo "[..] Cleaning trash files..."
	rm -rf filter lex.yy.c Files/comments.json

