# ======================================================================
# (c) Copyright 1996,1997,1998,1999,2000,2001,2004,2006 Whitehead
# Institute for Biomedical Research, Steve Rozen, and Helen Skaletsky
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#    * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#    * Neither the names of the copyright holders nor contributors may
# be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ======================================================================

# ======================================================================
# CITING PRIMER3
# 
# Steve Rozen and Helen J. Skaletsky (2000) Primer3 on the WWW for
# general users and for biologist programmers. In: Krawetz S, Misener S
# (eds) Bioinformatics Methods and Protocols: Methods in Molecular
# Biology. Humana Press, Totowa, NJ, pp 365-386.  Source code available
# at http://fokker.wi.mit.edu/primer3/.
# ======================================================================

MAX_PRIMER_LENGTH = 36

LDLIBS = -lm
CC      = gcc
O_OPTS  = -O2
CC_OPTS = -g -Wall -D__USE_FIXED_PROTOTYPES__
P_DEFINES = -DDPAL_MAX_ALIGN=$(MAX_PRIMER_LENGTH) -DMAX_PRIMER_LENGTH=$(MAX_PRIMER_LENGTH)

CFLAGS  = $(CC_OPTS) $(O_OPTS)
LDFLAGS = -g

# ======================================================================
# If you have trouble with library skew when moving primer3 executables
# between systems, you might want to set LIBOPTS to -static
LIBOPTS =

PRIMER_EXE      = primer3_core
OLIGOTM_LIB     = liboligotm.a
OLIGOTM_DYN_LIB = liboligotm.so.1.2.0
LIBRARIES       = $(OLIGOTM_LIB)
RANLIB          = ranlib

PRIMER_OBJECTS1=primer3_main.o\
                primer3.o\
                dpal_primer.o\
                format_output.o\
                boulder_input.o\

PRIMER_OBJECTS=$(PRIMER_OBJECTS1) $(OLIGOTM_LIB)
PRIMER_DYN_OBJECTS=$(PRIMER_OBJECTS1) $(OLIGOTM_DYN_LIB)

EXES=$(PRIMER_EXE) ntdpal oligotm long_seq_tm_test

all: $(EXES) $(LIBRARIES)

clean_src:
	-rm *.o $(EXES) *~ $(LIBRARIES)

clean: clean_src
	cd ../test/; make clean

$(OLIGOTM_LIB): oligotm.o
	ar rv $@ oligotm.o
	$(RANLIB) $@

$(OLIGOTM_DYN_LIB): oligotm.o
	gcc -shared -W1,-soname,liboligotm.so.1 -o $(OLIGOTM_DYN_LIB) oligotm.o

$(PRIMER_EXE): $(PRIMER_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(PRIMER_OBJECTS) $(LIBOPTS) $(LDLIBS)

# For use with valgrind, which requires at lease one
# dynamically linked library.  Automatic testing with
# valgrind is not implemented at this point.
$(PRIMER_EXE).dyn: $(PRIMER_DYN_OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(PRIMER_DYN_OBJECTS) $(LIBOPTS) $(LDLIBS)

ntdpal: ntdpal_main.o dpal.o
	$(CC) $(LDFLAGS) -o $@ ntdpal_main.o dpal.o

oligotm: oligotm_main.c oligotm.h $(OLIGOTM_LIB)
	$(CC) $(CFLAGS) -o $@ oligotm_main.c $(OLIGOTM_LIB) $(LIBOPTS) $(LDLIBS)

long_seq_tm_test: long_seq_tm_test_main.c oligotm.o
	$(CC) $(CFLAGS) -o $@ long_seq_tm_test_main.c oligotm.o $(LIBOPTS) $(LDLIBS)

boulder_input.o: boulder_input.c boulder_input.h primer3.h primer3_release.h dpal.h
	$(CC) -c $(CFLAGS) $(P_DEFINES) -o $@ boulder_input.c

dpal.o: dpal.c dpal.h primer3_release.h
	$(CC) -c $(CFLAGS) -o $@ dpal.c

dpal_primer.o: dpal.c dpal.h primer3_release.h
	$(CC) -c $(CFLAGS) $(P_DEFINES) -o $@ dpal.c

format_output.o: format_output.c primer3_release.h format_output.h primer3.h dpal.h
	$(CC) -c $(CFLAGS) $(P_DEFINES) -o $@ format_output.c

ntdpal_main.o: ntdpal_main.c dpal.h
	$(CC) -c $(CC_OPTS) -o $@ ntdpal_main.c
# We use CC_OPTS above rather than CFLAGS because
# gcc 2.7.2 crashes while compiling ntdpal_main.c with -O2

oligotm.o: oligotm.c oligotm.h primer3_release.h

primer3.o: primer3.c primer3.h primer3_release.h
	$(CC) -c $(CFLAGS) $(P_DEFINES) primer3.c

primer3_main.o: primer3_main.c primer3.h primer3_release.h dpal.h oligotm.h format_output.h
	$(CC) -c $(CFLAGS) $(P_DEFINES) primer3_main.c

primer_test: test

test: $(PRIMER_EXE) ntdpal
	cd ../test; make test
