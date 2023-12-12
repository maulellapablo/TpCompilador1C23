include macros2.asm
include number.asm
.MODEL LARGE	; Modelo de Memoria
.386	        ; Tipo de Procesador
.STACK 200h		; Bytes en el Stack

.DATA 

int1                          dd                            ?                             ;Variable int
int2                          dd                            ?                             ;Variable int
resultado                     dd                            ?                             ;Variable int
_1                            dd                            1.00                          ;Cte en formato  int
_2                            dd                            2.00                          ;Cte en formato  int
_El_resultado_es_=_            db                           "El resultado es = "          ,'$', 15 dup (?)
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
FLD int1
FLD int2
FADD 
FSTP @Aux1
FFREE
FLD @Aux1
FSTP resultado
FFREE
displayString _El_resultado_es_=_
displayString resultado



mov ax,4c00h	; Indica que debe finalizar la ejecución
int 21h

End
