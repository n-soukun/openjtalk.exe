
CC = cl

!IFNDEF CHARSET
CHARSET = SHIFT_JIS
!ENDIF

CFLAGS = /O2 /Ob2 /Oi /Ot /Oy /GT /GL /TC /I ../njd /I ../jpcommon /D CHARSET_$(CHARSET)
LFLAGS = /LTCG

CORES = njd2jpcommon.obj

all: njd2jpcommon.lib

njd2jpcommon.lib: $(CORES)
	lib $(LFLAGS) /OUT:$@ $(CORES)

.c.obj:
	$(CC) $(CFLAGS) /c $<

clean:
	del *.lib
	del *.obj
