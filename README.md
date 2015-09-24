   Makefile's for building STM32 ARM Library for GCC

1.  My attempt here is to have a set of Makefiles that will build any
STM32 Library set under GCC using Linux.  It's not perfect but it
builds quite a bit of projects.  It includes a tiny printf.

2.  Directions:

A. Get a toolchain from https://launchpad.net/gcc-arm-embedded

  I usually install it in /opt

B. Prepare your box

```
sudo apt-get install build-essential gdb manpages-dev
```

C. Get the library you want, for instance

```
mkdir ~/boards/stm32f030
cd ~/boards/stm32f030
wget <where ever>STM32F0xx_StdPeriph_Lib_V1.5.0.zip
unzip STM32F0xx_StdPeriph_Lib_V1.5.0.zip
cd STM32F0xx_StdPeriph_Lib_V1.5.0
```

D. Get this set of Makefiles:

```
git clone https://github.com/rickbronson/GCC-Makefile-for-Building-STM32-Libraries.git
```

E. Now for the labor intensive part.  You will need to edit the file
config.mk for all of the items explained at the top of config.mk.
There are some canned defines at the end of this file that you can
start with.

F. Decide if you want to tweak the load scripts to remove the sections
.preinit_array .init_array .fini_array that seem to add some amount to
the flash image.  Choose this if you have a 16K flash part and are
using printf or any of the larger projects.

```
make fixuplinker
```

G. Rebuild the world

```
make
```

H. Build just the project you are interested in (for example):

```
cd Projects/STM32F0xx_StdPeriph_Examples/USART/USART_Printf
make
```

I. If you want to use libc's version of printf instead of the tiny
printf, just do (for example)

```
cd ~/boards/stm32f030/STM32F0xx_StdPeriph_Lib_V1.5.0
make notinyprintf
cd Projects/STM32F0xx_StdPeriph_Examples/USART/USART_Printf
make clean; make
```

J. Results

  The following is the result of several builds:
	
```
File: STM32L1xx_StdPeriph_Lib_V1.3.1.zip
Project build pass ratio (main.elf/main.c): 69/84
Build config:
EVAL = 32L152
EVAL2 = 32L1523
TARGET = STM32L1XX_MD
LDFILESUBDIR = STM32L1XX_MD\(STM32L1xxxBxx\)
LDFILE = STM32L152VB_FLASH.ld
STARTUPSUBDIR = Device/ST/STM32L1xx/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32l1xx_md
CORE = cortex-m3
ARCH = armv7-m
MEM_CONT = 

File: STM32F0xx_StdPeriph_Lib_V1.5.0.zip
Project build pass ratio (main.elf/main.c): 58/76
Build config:
EVAL = 320518
EVAL2 = 320518
TARGET = STM32F030
LDFILESUBDIR = STM32F030xC
LDFILE = STM32F030xC_FLASH.ld
STARTUPSUBDIR = Device/ST/STM32F2xx/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f030
CORE = cortex-m0
ARCH = armv6-m
MEM_CONT = 

File: STM32F10x_StdPeriph_Lib_V3.5.0.zip
Project build pass ratio (main.elf/main.c): 75/97
Build config:
EVAL = 3210E
EVAL2 = 3210E
TARGET = STM32F10X_MD
LDFILESUBDIR = STM3210E-EVAL
LDFILE = stm32_flash.ld
STARTUPSUBDIR = CM3/DeviceSupport/ST/STM32F10x/startup/TrueSTUDIO
STARTUP = startup_stm32f10x_md
CORE = cortex-m0
ARCH = armv6-m
MEM_CONT = 

File: STM32F2xx_StdPeriph_Lib_V1.1.0.zip
Project build pass ratio (main.elf/main.c): 80/85
Build config:
EVAL = 322xG
EVAL2 = 322xG
TARGET = STM32F2XX
LDFILESUBDIR = STM322xG_EVAL
LDFILE = stm32_flash.ld
STARTUPSUBDIR = Device/ST/STM32F2xx/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f2xx
CORE = cortex-m0
ARCH = armv6-m
MEM_CONT = 

File: STM32F30x_DSP_StdPeriph_Lib_V1.2.3.zip
Project build pass ratio (main.elf/main.c): 66/83
Build config:
EVAL = 32303C
EVAL2 = 32303C
TARGET = STM32F303xC
LDFILESUBDIR = STM32F303xC
LDFILE = STM32F303VC_FLASH.ld
STARTUPSUBDIR = Device/ST/STM32F30x/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f303xc
CORE = cortex-m0
ARCH = armv6-m
MEM_CONT = 

File: STM32F37x_DSP_StdPeriph_Lib_V1.0.0.zip
Project build pass ratio (main.elf/main.c): 63/74
Build config:
EVAL = 32373C
EVAL2 = 32373C
TARGET = STM32F37X
LDFILESUBDIR = STM32373C-EVAL
LDFILE = STM32_FLASH.ld
STARTUPSUBDIR = Device/ST/STM32F37x/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f37x
CORE = cortex-m4
ARCH = armv7e-m
MEM_CONT = 

File: STM32F4xx_DSP_StdPeriph_Lib_V1.6.0.zip
Project build pass ratio (main.elf/main.c): 82/117
Build config:
EVAL = 324x7I
EVAL2 = 324x7I
TARGET = STM32F427_437xx
LDFILESUBDIR = STM32F427_437xx
LDFILE = STM32F437IIHx_FLASH.ld
STARTUPSUBDIR = Device/ST/STM32F4xx/Source/Templates/TrueSTUDIO
STARTUP = startup_stm32f427_437xx
CORE = cortex-m4
ARCH = armv7e-m
MEM_CONT = stm32f4xx_fmc.c
```
