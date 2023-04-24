%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"


struct struct_tablaSimbolos{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};
char buffer[30];
FILE *yyin;
int puntero_array = 0;
struct struct_tablaSimbolos tablaSimbolos[1000];

void validarCotaEntero(char*);
void validarCotaReal(char*);
void validarCotaCaracteres(char*);
int guardarEnTablaSimbolos(char*, char*);
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

{CTE_ENTERA}	     { validarCotaEntero(yytext); guardarEnTablaSimbolos("CTE",yytext); yylval.num = strdup(yytext); return CTE_ENTERA;}
{CTE_REAL}		     { validarCotaReal(yytext); guardarEnTablaSimbolos("CTE",yytext); yylval.real = strdup(yytext); return CTE_REAL; }
{CTE_STRING}	     { validarCotaCaracteres(yytext); guardarEnTablaSimbolos("CTE",yytext); yylval.real = strdup(yytext); return CTE_STRING; }
{ID}			     { validarCotaCaracteres(yytext); guardarEnTablaSimbolos("ID",yytext); yylval.strid = strdup(yytext); return ID; }
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

int guardarEnTablaSimbolos(char* tipo, char* nombre){
	
	char longitudConstanteString[10];
	int i;
	int posicion;
	char lexema[50]; 
	lexema[0]='_';
	lexema[1]='\0';
	//Se anexa al lexema un guion bajo al inicio
	strcat(lexema,nombre);
	
	//Recorremos la tabla de simbolos y en caso que el lexema ya exista, no se agrega y se retorna su posicion
	for(i = 0; i < puntero_array; i++)
	{
		if(strcmp(tablaSimbolos[i].nombre, lexema) == 0)
		{
			return i;
		}
	}
	
	//En caso de ser una CTE, guardamos el Valor en la tabla de simbolos
	if(strcmp(tipo,"CTE")==0)
		strcpy(tablaSimbolos[puntero_array].valor, nombre);
	else
		tablaSimbolos[puntero_array].valor[0]='\0';
		
	strcpy(tablaSimbolos[puntero_array].nombre, lexema );
	tablaSimbolos[puntero_array].tipo[0]='\0';
	//En caso de ser una CTE string, se cuentan los caracteres y se guardan en la tabla de simbolos
	if(tablaSimbolos[i].valor[0] == '\"')
	{
		snprintf(longitudConstanteString, sizeof(longitudConstanteString), "%d", strlen(tablaSimbolos[i].valor)-2);
		strcpy(tablaSimbolos[i].longitud,longitudConstanteString);
	}
	else
		tablaSimbolos[puntero_array].longitud[0]='\0';
	
	//Se agrega en la tabla de simbolos y se retorna su posicion
	posicion = puntero_array;
	puntero_array++;
	
	return posicion;
}

void escribirEnTablaSimbolos(){
	FILE *pf; 
	int i;
	pf = fopen("symbol-table.txt","w"); 

	if (pf == NULL)
	{
		printf("ERROR! No se pudo crear correctamente el archivo de la tabla de simbolos\n");
	}

	int ancho_tabla = fprintf(pf, "|%-30s|%-15s|%-32s|%-8s|\n", "Nombre","Tipo","Valor","Longitud");
	for(i = 0; i < ancho_tabla-1; ++i)
			fprintf(pf, "-");
	fprintf(pf, "\n");
	for (i = 0; i < puntero_array; i++)
			fprintf(pf,"|%-30s|%-15s|%-32s|%-8s|\n", tablaSimbolos[i].nombre,tablaSimbolos[i].tipo,tablaSimbolos[i].valor,tablaSimbolos[i].longitud);


	fclose(pf); 
}

int yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno-1, msg);
    exit(1);
}