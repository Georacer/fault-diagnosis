CC=g++
CFLAGS=-Wall -g 

#CFLAGS=-fno-implicit-templates -Wall
#CFLAGS=-frepo -Wall
objs=
headers=hittingset.h hittingset.tcc

TARGET_OS=$(shell uname -s)

ifeq ($(TARGET_OS),Darwin) # Mac
  MATLAB=/Applications/MATLAB_R2014b.app
  DEVHOME=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs

  MEXCFLAGS=-I../Timer -fexceptions -fno-common -arch x86_64 -mmacosx-version-min=10.9 \
  -isysroot $(DEVHOME)/MacOSX10.9.sdk/ -I$(MATLAB)/extern/include -O3 -DNDEBUG -DMATLAB_MEX_FILE

  MEXLDFLAGS=-Wl,-twolevel_namespace -undefined error -arch x86_64 \
  -mmacosx-version-min=10.9 -Wl,-syslibroot,$(DEVHOME)/MacOSX10.9.sdk -framework Cocoa -bundle \
  -Wl,-exported_symbols_list,$(MATLAB)/extern/lib/maci64/mexFunction.map -L$(MATLAB)/bin/maci64

  MEXEXT=mexmaci64
else # Linux
  MATLAB=/sw/matlab/7.7
  MEXCFLAGS=-I../Timer -I$(MATLAB)/extern/include -I$(MATLAB)/simulink/include \
  -DMATLAB_MEX_FILE -Ansi -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC  \
  -DMX_COMPAT_32 -O3 -DNDEBUG
  MEXLDFLAGS=-pthread -shared -m32 -Wl,--version-script,$(MATLAB)/extern/lib/glnx86/mexFunction.map \
  -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB)/bin/glnx86 -L$(MATLAB)/bin/glnx86
  MEXEXT=mexglx
endif

all: MHScompiled.$(MEXEXT)

MHScompiled.$(MEXEXT): MHScompiled.o
	$(CC) $(MEXLDFLAGS) -o $@ $<  -lmx -lmex -lm -lmat -lstdc++

MHScompiled.o: MHScompiled.cc hittingset.tcc hittingset.h
	$(CC) $(MEXCFLAGS) -c -o $@ $<

.cc.o: $(headers)
	$(CC) $(CFLAGS) -c $< 

clean:
	rm -rf $(objs) *~ MHScompiled.o  

cleanall:
	make clean
	rm -rf MHScompiled.mexmaci MHScompiled.mexmaci64 MHScompiled.mexglx 

.PHONY: all clean cleanall
