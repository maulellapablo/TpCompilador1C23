include macros2.asm
include number.asm
.MODEL LARGE	; Modelo de Memoria
.386	        ; Tipo de Procesador
.STACK 200h		; Bytes en el Stack

.DATA 

int1                          dd                            ?                             ;Variable int
int2                          dd                            ?                             ;Variable int
a1                            dd                            ?                             ;Variable float
b1                            dd                            ?                             ;Variable float
p1                            dd                            ?                             ;Variable string
p2                            dd                            ?                             ;Variable string
p3                            dd                            ?                             ;Variable string
_1                            dd                            1.00                          ;Cte en formato  int
_2                            dd                            2.00                          ;Cte en formato  int
_int1                          db                             "int1"                        ,'$', 4 dup (?) ;Cte en formato 
_int1_no_es_mas_grande_que_int2 db                             "int1 no es mas grande que int2",'$', 30 dup (?) ;Cte en formato 
_int1_es_mas_grande_que_int2   db                             "int1 es mas grande que int2" ,'$', 27 dup (?) ;Cte en formato 
@Aux1                         dd                            ?                             ;Variable float


.CODE

mov AX,@DATA    ; Inicializa el segmento de datos
mov DS,AX
mov es,ax ;

FLD _1
FSTP int1
FFREE
FLD _2
FSTP int2
FFREE
displayString _int1
getString int2
FLD int1
FCOMP int2
FSTSW ax
SAHF
JNA saltoelse1
displayString _int1_no_es_mas_grande_que_int2
JMP fin_if1
saltoelse1:
displayString _int1_no_es_mas_grande_que_int2
fin_if1:
saltoelse2:
FFREE
principiowhile:
FLD int1
FCOMP int2
FSTSW ax
SAHF
JNA saltoelse3
displayString _int1_es_mas_grande_que_int2
FLD int1
FLD int2
FADD 
FSTP @Aux1
FFREE
FLD @Aux1
FSTP int1
FFREE
JMP principiowhile
saltoelse3:



mov ax,4c00h	; Indica que debe finalizar la ejecución
int 21h

End
