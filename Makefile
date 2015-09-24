# 
# Copyright (C) 2015 Rick Bronson (rick AT efn.org)
# Licensed under the GPL
#
# Top level Makefile for STM32 library under gcc, get things initialized and build all

# search up in directory tree for  'config.mk'
TOPDIR ?= $(shell TOPD=$$PWD ; until [ -f config.mk -o "$$TOPD" = "/" ] ; do cd .. ; TOPD=$$PWD ; done ; echo $$TOPD)

all: .INITD .BUILDLIB buildall

.INITD:
	sed -i -e "s/#include <stm32.*/#include <stm32$(STMFILETYPE).h>/" tiny_printf.c
	cp -f Makefile.lib Libraries/Makefile
	cp -f tiny_printf.c Libraries/STM32$(STMDIRTYPE)_StdPeriph_Driver/src
	for dir in `dirname $$(find . -name "main.c")`; do \
	 	cp -f Makefile.proj $$dir/Makefile; \
	done;
	for dir in `dirname $$(find . -name "*eval.c")`; do \
	 	cp -f Makefile.eval $$dir/Makefile; \
	done;
# Some include files are included as STM32*.h but the files are really stm32*.h, fix this
	for file in `find . -name "*.[ch]"`; do if grep "^#include \"STM32" $$file; then sed -i -e "s/^\(#include .*\)STM32\([^/]*.h\)/\1stm32\2/g" $$file; fi; done
	for file in `find . -name "*.[ch]"`; do if grep "^#include \"stm32373C_eval_lcd" $$file; then sed -i -e "s/#include \"stm32373C_eval_lcd/#include \"stm32373c_eval_lcd/g" $$file; fi; done
# Some dir's are the wrong case, fix this
	for file in `find . -name "*.[ch]"`; do if grep "#include \"stm32.*_eval/" $$file; then sed -i -e "s|#include \"stm32\([^/ ]*\)_eval/|#include \"STM32\U\1_EVAL/|g" $$file; fi; done
	@touch $@

buildlib : .BUILDLIB
.BUILDLIB:
	make -C Libraries
	@touch $@

# include common definitions (cross toolchain etc.)
include config.mk

buildall:
	for dir in `dirname $$(find . -name "main.c")`; do \
	  make -C $$dir; \
	  make -C Libraries clean; \
	  make -C Utilities/STM32_EVAL/STM$(EVAL)_EVAL clean; \
	done;

#get rid of some items in linker scripts that add memory
fixuplinker:
	for file in `find . -name "*.ld"`; do sed -i -e '/.preinit_array/,/FLASH/d; /.init_array/,/FLASH/d; /.fini_array/,/FLASH/d' $$file; done

notinyprintf:
	rm -f Libraries/STM32$(STMDIRTYPE)_StdPeriph_Driver/src/tiny_printf.*

clean:
	rm -f .INITD .BUILDLIB Libraries/Makefile
	for dir in `dirname $$(find . -name "main.c" -or -name "*eval.c")`; do \
	  rm -f $$dir/Makefile; \
	done;
	rm -f Libraries/STM32$(STMDIRTYPE)_StdPeriph_Driver/src/tiny_printf.c
	rm -f `find . -name "*.[ao]" -or -name "main.elf" -or -name "main.elf" -or -name "main.hex" -or -name "main.bin" -or -name "main.lst"`
