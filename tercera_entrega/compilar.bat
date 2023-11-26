flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc -std=c99 lex.yy.c y.tab.c -o lyc-compiler.exe
pause
lyc-compiler.exe  test.txt
pause
dot -Tpng arbol.dot -o arbol.png
pause
