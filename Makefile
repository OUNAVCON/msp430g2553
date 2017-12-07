PROJ=main

GCC_DIR=/home/isaac/ti/msp430_gcc
SUPPORT_FILE_DIR=$(GCC_DIR)

SOURCES=main.c
INCLUDES=-Iinclude
OUTDIR=build

CC=$(GCC_DIR)/bin/msp430-elf-gcc
LD=$(GCC_DIR)/bin/msp-elf-ld
AR=$(GCC_DIR)/bin/msp-elf-ar
GASP=$(GCC_DIR)/bin/msp-elf-gasp
NM=$(GCC_DIR)/bin/msp-elf-nm
OBJCOPY=$(GCC_DIR)/bin/msp430-elf-objcopy
MAKETXT = srec_cat
UNIX2DOS = unix2dos
RM = rm -f
MKDIR = mkdir -p

MCU=msp430g2553

CFLAGS=-I $(SUPPORT_FILE_DIR)/include/ -Wunused $(INCLUDES)  -Os -g -Wall -mmcu=$(MCU)
LDFLAGS=-g -mmcu=$(MCU) -L $(SUPPORT_FILE_DIR)/include/ -Wa,-Map=$(OUTDIR)/$(PROJ).map
ASFLAGS= -mmcu=$(MCU) -x assembler-with-cpp -Wa, -gstabs


DEPEND = $(SOURCES:.c=.d)

OBJECTS = $(addprefix $(OUTDIR)/,$(notdir $(SOURCES:.c=.o)))



all: $(OUTDIR)/$(PROJ).hex #$(OUTDIR)/$(PROJ).txt

$(OUTDIR)/%.txt: $(OUTDIR)/%.hex
#	$(MAKETXT) -o $@ -TITXT $< -I
#	$(UNIX2DOS) $(OUTDIR)/$(PROJ).txt

$(OUTDIR)/%.hex: $(OUTDIR)/%.elf
	$(OBJCOPY) -O ihex $< $@

$(OUTDIR)/$(PROJ).elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) $(LIBS) -o $@

$(OUTDIR)/%.o: src/%.c | $(OUTDIR)
	$(CC) -c $(CFLAGS) -o $@ $<

%.lst: %.c
	$(CC) -c $(ASFLAGS) -Wa,-anlhd $< > $@

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

clean:
	$(RM)  $(OUTDIR)/*

.PHONY: all clean


flash: all
	mspdebug rf2500 'erase' 'load $(PROJ).elf' 'exit'
