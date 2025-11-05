
!IFNDEF CHARSET
CHARSET = SHIFT_JIS
!ENDIF

!IF "$(CHARSET)" == "UTF_8"
TARGET_CHARSET = UTF-8
!ELSE
TARGET_CHARSET = sjis
!ENDIF

all: char.bin matrix.bin sys.dic unk.dic

char.bin matrix.bin sys.dic unk.dic: naist-jdic.csv matrix.def _left-id.def _pos-id.def _rewrite.def _right-id.def char.def unk.def feature.def
	copy _left-id.def left-id.def
	copy _right-id.def right-id.def
	copy _rewrite.def rewrite.def
	copy _pos-id.def pos-id.def
	..\mecab\src\mecab-dict-index.exe -d . -o . -f UTF-8 -t $(TARGET_CHARSET)

clean:
	del char.bin matrix.bin sys.dic unk.dic
