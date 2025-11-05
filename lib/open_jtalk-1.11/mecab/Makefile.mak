
!IFNDEF CHARSET
CHARSET = SHIFT_JIS
!ENDIF

all:
	cd src
	nmake /f Makefile.mak CHARSET=$(CHARSET)
	cd ..

clean:
	cd src
	nmake /f Makefile.mak clean
	cd ..
