%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"

char buffer[30];
FILE *yyin;

void validarCotaEntero(char*);
void validarCotaReal(char*);
void validarCotaCaracteres(char*);
int validarCaracter(void);
%}
%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]
ID				{LETRA}({LETRA}|{DIGITO})*
CTE_ENTERA		-?{DIGITO}+
CTE_REAL		-?({DIGITO})*"."({DIGITO})+
COMILLAS		"\""
COM_INI			"*-" 
COM_FIN			"-*"
CARACTERES		({LETRA}|@|\!|\$|\%|\&|\/|\(|\)|\=|\\|\?|.)
ESPACIO			" "
CTE_STRING		{COMILLAS}({CARACTERES}|{DIGITO}|{ESPACIO})+{COMILLAS}
COMENTARIO		{COM_INI}(.)+{COM_FIN}
COMENTARIOS		{COM_INI}(.)+{COM_FIN}



%%
"program"		     { return PROGRAM;}
"end"			     { return END;}
"if"			     { return IF;}
"else"			     { return ELSE;}
"ciclo"			     { return WHILE;}
"read"			     { return READ;}
"write"			     { return WRITE;}
"=="			     { return COMP_IGUAL;}
">"				     { return COMP_MAYOR;}
"<"				     { return COMP_MENOR;}
">="			     { return COMP_MAYOR_IGUAL;} 
"<="			     { return COMP_MENOR_IGUAL;}
"!="			     { return COMP_DISTINTO;}
"="			         { return OPAR_ASIG;}
"Int"			     { return TIPO_INT;} 
"Float"			     { return TIPO_FLOAT;} 
"String"		     { return TIPO_STRING;}
"init"			     { return DECVAR;} 
"&"			         { return OP_LOG_AND;}
"||"			     { return OP_LOG_OR;}
"not"			     { return OP_LOG_NOT;} 
"ElementInTheMiddle" { return INTHE_MIDDLE;} 

{CTE_ENTERA}	     { validarCotaEntero(yytext); yylval.num = strdup(yytext); return CTE_ENTERA;}
{CTE_REAL}		     { validarCotaReal(yytext); yylval.real = strdup(yytext); return CTE_REAL; }
{CTE_STRING}	     { validarCotaCaracteres(yytext); yylval.real = strdup(yytext); return CTE_STRING; }
{ID}			     { validarCotaCaracteres(yytext); yylval.strid = strdup(yytext); return ID; }
{COMENTARIO}	     { printf("\nComentario que sera descartado:  %s\n",yytext); }
     
"+"				     { return OP_MAS;}  
"-"				     { return OP_MENOS;}
"*"				     { return OP_MULT;}
"/"				     { return OP_DIV;}
":"				     { return DOS_PUNTOS;}
";"				     { return PUN_Y_COM;}
","				     { return COMA;}
"("				     { return PAR_A;}
")"				     { return PAR_C;}
"{"				     { return LLAVE_A;}
"}"				     { return LLAVE_C;}
"["				     { return COR_A;}
"]"				     { return COR_C;}	



"\n"      		
"\t"
"\n\t"
"\r\n"
" "
.


%%

int validarCaracter(void)
{
	printf("ERROR! Caracter invalido ingresado\n");
	system("Pause");
	exit(1);
}

void validarCotaEntero(char* str)
{
	int numero = atoi(str);
	if(numero<=-32768|| numero>=32767)
	{
		printf("El valor ingresado para el entero se encuentra fuera del rango valido\n");
		system("Pause");
		exit(1);
	}
}


void validarCotaReal(char* str)
{
	float numero = atof(str);
	if((numero < pow(1.18,-38)) || (numero > pow(3.4,38)))
	{
		printf("ERROR! El valor ingresado para el real se encuentra fuera del rango valido\n");
		system("Pause");
		exit(1);	
	}
}

void validarCotaCaracteres(char* str)
{
	if(strlen(str)>40)
	{
		printf("ERROR! El valor ingresado para la cadena de caracteres se encuentra fuera del rango valido de 40 caracteres\n");
		system("Pause");
		exit(1);
	}
}

int yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno-1, msg);
	system ("Pause");
    exit(1);
}

int mensaje_error(char* mensaje)
{
	printf("Error lexico: %s\nLinea: %d\n", mensaje , yylineno);
	system ("Pause");
	exit (1);
}
