flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe  lex.yy.c  y.tab.c  -o lyc-compiler.exe
pause
lyc-compiler.exe  test.txt
pause
@echo off
del lyc-compiler.exe
del lex.yy.c
del y.tab.c
del y.tab.h
pause