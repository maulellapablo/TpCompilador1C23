flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe  lex.yy.c  y.tab.c  -o compilador.exe
pause
compilador.exe  test.txt
pause
@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
pause