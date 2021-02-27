
OUT_DIR=./out
SHARED_OUT_DIR=./shared
IDIR=./src

MKDIRS += out
MKDIRS += shared

CFLAGS= -Wall -std=gnu17

ifdef DEBUG
CFLAGS += -g -DDEBUG
else
CFLAGS += -O3
endif

_DEPS = cli.h constants.h diff.h run.h utils.h log.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = judge.o cli.o diff.o run.o utils.o log.o
OBJ = $(patsubst %,$(OUT_DIR)/%,$(_OBJ))

$(OUT_DIR)/%.o: $(IDIR)/%.c $(DEPS) | $(OUT_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

judge: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

S_OBJ = $(patsubst %,$(SHARED_OUT_DIR)/%,$(_OBJ))

$(SHARED_OUT_DIR)/%.o: $(IDIR)/%.c $(DEPS) | $(SHARED_OUT_DIR)
	$(CC) $(CFLAGS) -c -fPIC -o $@ $<

libjudge: $(S_OBJ)
	$(CC) $(CFLAGS) -shared -o $@.so $^

.PHONY: clean
clean:
	rm -f $(OUT_DIR)/*.o $(SHARED_OUT_DIR)/*.o *~ $(IDIR)/*~

C_BASE=./tests/c

c: $(C_BASE)/main.c
	$(CC) $< -o main

testc: c judge
	./judge -l c.log -t 1000 -m 2048 -i $(C_BASE)/1.in -o $(C_BASE)/1.out -u c.tmp.out ./main

NODE_BASE=./tests/node

testnode: judge
	./judge -l node.log -t 1000 -i $(NODE_BASE)/1.in -o $(NODE_BASE)/1.out -u node.tmp.out -- node $(NODE_BASE)/main.js


cleantest:
	rm -f c.log c.tmp.out main node.log node.tmp.out


$(sort $(MKDIRS)):
	mkdir -p $@
