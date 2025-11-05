
CC = cl

!IFNDEF CHARSET
CHARSET = SHIFT_JIS
!ENDIF

CFLAGS = /O2 /Ob2 /Oi /Ot /Oy /GT /GL /TC /I ../njd /D CHARSET_$(CHARSET)
LFLAGS = /LTCG

CORES = njd_set_unvoiced_vowel.obj

all: njd_set_unvoiced_vowel.lib

njd_set_unvoiced_vowel.lib: $(CORES)
	lib $(LFLAGS) /OUT:$@ $(CORES)

.c.obj:
	$(CC) $(CFLAGS) /c $<

clean:
	del *.lib
	del *.obj
