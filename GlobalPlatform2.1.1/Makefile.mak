!IFNDEF DEBUG
!MESSAGE Building release version.
!MESSAGE Use nmake with DEBUG= if you want to build a debug version.
!ENDIF

!MESSAGE
!MESSAGE Possible Targets:
!MESSAGE ALL [DEBUG=] - Build version.
!MESSAGE CLEAN - Delete Debug and Release directories
!MESSAGE DOC - Create documentation.
!MESSAGE PREBUILD - Builds a prebuild zipped version. VERSION= must be set.
!MESSAGE

# replace with your path to the OpenSSL header files
# or specify on command line
OPENSSL_INC=E:\quarantine\openssl-0.9.7e\include

# replace with your path to the OpenSSL library files
# or specify on command line
OPENSSL_LIB=E:\quarantine\openssl-0.9.7e\out32dll

# replace with your path to the zlib header files
# or specify on command line
ZLIB_INC=E:\quarantine\zlib123

# replace with your path to the zlib library files
# or specify on command line
ZLIB_LIB=E:\quarantine\zlib123\projects\visualc6\Win32_DLL_Release

!IF !EXIST($(OPENSSL_INC))
!ERROR Your path to the header files for OpenSSL is wrong. \
Replace it in the Makefile or call nmake with OPENSSL_INC=<PATH_TO_OPENSSL_HEADERS>
!ENDIF

!IF !EXIST($(OPENSSL_LIB))
!ERROR Your path to the library files for OpenSSL is wrong. \
Replace it the Makefile or call nmake with OPENSSL_LIB=<PATH_TO_OPENSSL_LIBS>
!ENDIF

!IF !EXIST($(ZLIB_INC))
!ERROR Your path to the header files for zlib is wrong. \
Replace it in the Makefile or call nmake with ZLIB_INC=<PATH_TO_ZLIB_HEADERS>
!ENDIF

!IF !EXIST($(ZLIB_LIB))
!ERROR Your path to the library files for zlib is wrong. \
Replace it the Makefile or call nmake with ZLIB_LIB=<PATH_TO_ZLIB_LIBS>
!ENDIF

# Directory name may not contain spaces
!IFDEF DEBUG
OUTDIR=Debug
!ELSE
OUTDIR=Release
!ENDIF

OBJS=$(OUTDIR)/stdafx.obj $(OUTDIR)/DLLMain.obj $(OUTDIR)/GlobalPlatform.obj $(OUTDIR)/debug.obj

MINIZIP=$(OUTDIR)/zip.obj $(OUTDIR)/unzip.obj $(OUTDIR)/ioapi.obj

# replace with the location of doxygen
# or specify on command line
DOXYGEN=e:\Programme\doxygen\bin\doxygen.exe

LIB_NAME=GlobalPlatform # the name of the library

CPP=cl

!IFDEF DEBUG
CPPFLAGS=/Od /I $(OPENSSL_INC) /I $(ZLIB_INC) /D "WIN32" /D "_DEBUG" /D "DEBUG" /D "_CONSOLE" /D "OPGP_EXPORTS" /D "_UNICODE" \
/D "_WINDLL" /D "UNICODE" /GZ /MD /Fo$(OUTDIR)/ /W3 /nologo /ZI /TC
!ELSE
CPPFLAGS=/O2 /I "$(OPENSSL_INC)" /I $(ZLIB_INC) /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "OPGP_EXPORTS" /D "_UNICODE" \
/D "_WINDLL" /D "UNICODE" /FD /MD /Fo$(OUTDIR)/ /W3 /nologo /Zi /TC
!ENDIF

LINK=link

!IFDEF DEBUG
LFLAGS=/OUT:$(OUTDIR)/$(LIB_NAME).dll /NOLOGO /LIBPATH:$(OPENSSL_LIB) /LIBPATH:$(ZLIB_LIB) /DLL /DEBUG /PDB:$(OUTDIR)/$(LIB_NAME).pdb \
/SUBSYSTEM:CONSOLE /MACHINE:X86 zlib1.lib ssleay32.lib libeay32.lib winscard.lib kernel32.lib user32.lib gdi32.lib winspool.lib \
comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
!ELSE
LFLAGS=/OUT:$(OUTDIR)/$(LIB_NAME).dll /INCREMENTAL:NO /NOLOGO /LIBPATH:$(OPENSSL_LIB) /LIBPATH:$(ZLIB_LIB) /DLL /SUBSYSTEM:CONSOLE \
/OPT:REF /OPT:ICF /MACHINE:X86 zlib1.lib ssleay32.lib libeay32.lib winscard.lib kernel32.lib user32.lib gdi32.lib \
winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
!ENDIF

all: create_dirs $(OUTDIR)/$(LIB_NAME).dll

create_dirs:
	-@mkdir $(OUTDIR)


# compilation and linking
$(OUTDIR)/$(LIB_NAME).dll: $(OBJS) $(MINIZIP) version.res
	$(LINK) $(LFLAGS) $(OBJS) $(MINIZIP) version.res

$(OBJS): $(@B).c
	$(CPP) $(CPPFLAGS) /c /Fd$(OUTDIR)/%|pfF %|pfF.c

$(MINIZIP): unzip/$(@B).c
	$(CPP) $(CPPFLAGS) /c /Fd$(OUTDIR)/$(@B) %|pfF.c

version.res : version.rc
!IFDEF DEBUG
	rc /dDEBUG version.rc
!ELSE
	rc version.rc
!ENDIF

# run doxygen
doc: do-doc

PREBUILDDIR="GlobalPlatform-$(VERSION)"

prebuild: all
	-@del /S /F /Q $(PREBUILDDIR)
	-@mkdir $(PREBUILDDIR)
	-@mkdir $(PREBUILDDIR)/GlobalPlatform
	cp Debug/GlobalPlatform.dll Debug/GlobalPlatform.lib ChangeLog README COPYING AUTHORS  $(PREBUILDDIR)
	cp GlobalPlatform/GlobalPlatform.h GlobalPlatform/unicode.h $(PREBUILDDIR)/GlobalPlatform
	zip -r $(PREBUILDDIR).zip $(PREBUILDDIR)/*

clean:
	-@rd /S /Q Debug
	-@rd /S /Q Release
	-@rd /S /Q Doc
	-@del version.res

do-doc:
	-@mkdir Doc
!IF !EXIST($(DOXYGEN))
	ERROR Doxygen not found. Change the macro DOXYGEN in this Makefile to point to the \
	correct location or specify it on the command line DOXYGEN=<LOCATION_OF_DOXYGEN_EXECUTABLE>
!ELSE
	$(DOXYGEN) Doxyfile.cfg
!ENDIF