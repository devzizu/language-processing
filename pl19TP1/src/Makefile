#Makefile that compiles the program 

FF = flex
EXEC = filter
HTMLFILE = ../Files/Publico_extraction.html

CC = gcc -g
CGLAGS = -I
DEPS = $(wildcard CommentThread/*.h)
OBJ = $(patsubst %.c, %.o, $(wildcard *.c))
DIR = CommentThread

# Cleans the files, then executes the flex and, at last, compiles the filter
install:
	@$(MAKE) -s clean 
	@$(MAKE) -s flex
	@$(MAKE) -s filter

# Compiles all .c files to .o
%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

# Compiles the filter that flex had generated
filter: $(OBJ)
	@echo "[..] Compiling filter..."
	$(CC) -o $@ $^ $(CFLAGS)

# Compiles the ER expressions and declarations of filter.l that generates the C program
flex:
	@echo "[..] Compiling with Flex..."
	$(FF) filter.l

# Runs the executable filter
run:
	./$(EXEC) < $(HTMLFILE)

# Cleans the files previus generated to run the filter
clean: 
	@echo "[..] Cleaning trash files..."
	rm -rf filter lex.yy.c ../Files/comments.json *.o 

