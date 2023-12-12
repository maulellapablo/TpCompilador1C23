PATH=C:\TASM;

tasm numbers.asm
tasm Final.asm
tlink Final.obj numbers.obj
Final.exe