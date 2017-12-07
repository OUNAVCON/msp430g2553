PROJ=blink

GCC_DIR=/home/isaac/ti/msp430_gcc
SUPPORT_FILE_DIR=$(GCC_DIR)

CC=$(GCC_DIR)/bin/msp430-elf-gcc
MCU=msp430g2553
CFLAGS=-I $(SUPPORT_FILE_DIR)/include/  -Os -g -Wall -mmcu=$(MCU)
LDFLAGS=-g -mmcu=$(MCU) -L $(SUPPORT_FILE_DIR)/include/

OBJS=main.o

all:$(OBJS)
	@echo linking: $(PROJ).elf
	$(CC) $(LDFLAGS) -o $(PROJ).elf $(OBJS)
	@echo "--== Size of firmware ==--"
	msp430-size $(PROJ).elf

&.o:%.c %.h
	@echo compiling file: $<
	$(CC) $(CFLAGS) -c $<

clean:
	@echo cleaning $<
	rm -fr $(PROJ).elf $(OBJS)

flash: all
	mspdebug rf2500 'erase' 'load $(PROJ).elf' 'exit'
