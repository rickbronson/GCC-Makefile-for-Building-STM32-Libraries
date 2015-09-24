# 
# Copyright (C) 2015 Rick Bronson (rick AT efn.org)
# Licensed under the GPL
#
# Makefile include that has all defines, etc
# You should only need to change down to the ###### line

# see subdir's in Utilities/STM32_EVAL
# pick one of 320518, 32072B, etc
EVAL = 320518

# see one of the many main.h's (eg. Project*/STM32*_StdPeriph_Examples/*/*/main.h)
# the [] part in USE_STM[320518]_EVAL
EVAL2 = 320518

# pick target chip, eg. STM32F030 STM32F031 STM32F051...
# For choices, see the text just above "Please select first..." 
# in Libraries/CMSIS/Device/ST/STM32*/Include/stm32*.h
TARGET = STM32F030

# pick one of: eg. STM32F030R8 STM32F072VB STM32F091CC...
# Location of the linker scripts, see stuff in Project*/STM32*_StdPeriph_Template*/TrueSTUDIO
LDFILESUBDIR = STM32F030
LDFILE = STM32F030R8_FLASH.ld

# pick startup dir, its the path after Libraries/CMSIS up to the STARTUP file
STARTUPSUBDIR = Device/ST/STM32F2xx/Source/Templates/TrueSTUDIO
# pick startup file, ie. see Libraries/CMSIS/Device/ST/STM32*/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f030

# pick m0 or m3
CORE = cortex-m0
ARCH = armv6-m

# on F4 parts, pick between stm32f4xx_fmc.c or stm32f4xx_fsmc.c
MEM_CONT = 

# pick where your toolchain lives (don't include the "bin" dir)
GCC_BASE = /opt/gcc-arm-none-eabi-4_9-2015q2
#######################  Should only need to change above this line ############################

PATH := ":${GCC_BASE}/bin:${PATH}"
CROSS_COMPILE=arm-none-eabi-
CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
LD=$(CROSS_COMPILE)ld
AR=$(CROSS_COMPILE)ar
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
SIZE=$(CROSS_COMPILE)size
GDB=$(CROSS_COMPILE)gdb

# get dir type substring (ie. F0xx, F10x, F2xx, F30x, F37x, F4xx, L1xx)
STMDIRTYPE=$(shell echo $(TOPDIR) | sed -e "s/.*STM32\(....\).*StdPeriph.*/\1/")
# get file type substring (ie. f0xx, f10x, f2xx, f30x, f37x, f4xx, l1xx)
STMFILETYPE=$(shell echo $(TOPDIR) | sed -e "s/.*STM32\(.\)\(...\).*StdPeriph.*/\l\1\2/")

# sometimes "Project" or "Projects"
PROJDIR=$(shell cd $(TOPDIR); find . -maxdepth 1 -name "Proj*" | sed -e 's|./||')
# sometimes "*StdPeriph_Template" or "*StdPeriph_Templates"
TEMPLATEDIR=$(shell cd $(TOPDIR)/$(PROJDIR); find . -maxdepth 1 -name "*StdPeriph_Template*" | sed -e 's|./||')

LDFILEDIR=$(TOPDIR)/$(PROJDIR)/$(TEMPLATEDIR)/TrueSTUDIO/$(LDFILESUBDIR)

# try to get flash address from linker file
FLASH_ADDR ?= $(shell sed -n -e "s/^FLASH.*ORIGIN =\([^,]*\),.*/\1/p" $(LDFILEDIR)/$(LDFILE))

# Location of the Libraries folder from the STM32* Standard Peripheral Library
STD_PERIPH_LIB=$(TOPDIR)/Libraries

STMLIB=stm32$(STMFILETYPE)
EVAL_DIR=$(TOPDIR)/Utilities/STM32_EVAL
PROJ_INC ?= .

# kinda Draconian I agree, we are including every dir that has a *.h file except for the Example dir's
INC  = -I $(PROJ_INC)
INC += $(shell for dir in `dirname \`find $(TOPDIR) -name "*.h"\` | sort | uniq | grep -v Examples`; do echo -I $$dir; done)
INC += -I $(TOPDIR)/Utilities/STM32_EVAL
INC += -I $(TOPDIR)/$(PROJDIR)/STM32$(STMDIRTYPE)_StdPeriph_Examples/I2C/I2C_TwoBoards

CFLAGS  = -Wall -g -std=gnu99 -Os  
CFLAGS += -mlittle-endian -mcpu=$(CORE)  -march=$(ARCH) -mthumb
CFLAGS += -ffunction-sections -fdata-sections -fno-builtin
CFLAGS += -Wl,--gc-sections -Wl,-Map=$(PROJ_NAME).map
CFLAGS += -D$(TARGET) -DUSE_STM$(EVAL2)_EVAL -DUSE_STDPERIPH_DRIVER
CFLAGS += $(INC)

# location of OpenOCD Board .cfg files (only used with 'make program')
OPENOCD_BOARD_DIR=/usr/local/share/openocd/scripts/board

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=extra/stm32f0-openocd.cfg

vpath %.c src
vpath %.a $(STD_PERIPH_LIB)
