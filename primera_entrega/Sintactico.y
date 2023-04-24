 %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"


struct struct_tablaSimbolos
{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};

int yystopparser=0;
FILE  *yyin;
extern int yylineno;
extern char *yytext;

int yylex();
int yyerror(char *);
extern struct struct_tablaSimbolos tablaSimbolos[1000]; 
extern int puntero_array;
int contadorTipos = 0;
char* auxTipoDato;
char matrizTipoDato[100][10];
char matrizVariables[100][10];
int contadorId = 0;
int agregarTipoEnTablaSimbolos(char* nombre, int contadorId);
void escribirEnTablaSimbolos();

%}
%token PROGRAM
%token END
%token IF
%token ELSE
%token WHILE
%token WRITE
%token READ
%token DECVAR
%token COMP_IGUAL
%token COMP_MAYOR
%token COMP_MENOR
%token COMP_MAYOR_IGUAL
%token COMP_MENOR_IGUAL
%token COMP_DISTINTO
%token OPAR_ASIG
%token TIPO_INT
%token TIPO_FLOAT
%token TIPO_STRING
%token <num>CTE_ENTERA
%token <real>CTE_REAL
%token <str>CTE_STRING
%token OP_MAS 
%token OP_MENOS
%token OP_MULT
%token OP_DIV
%token OP_LOG_AND
%token OP_LOG_OR
%token OP_LOG_NOT
%token DOS_PUNTOS
%token PUN_Y_COM
%token COMA
%token <strid>ID
%token PAR_A
%token PAR_C
%token LLAVE_A
%token LLAVE_C
%token COR_A
%token COR_C
%token INTHE_MIDDLE

%union{
char * strid;
char * num;
char * real; 
char * str;
}

%%
programa: PROGRAM { printf("***** Inicio de Programa *****\n"); } zona_declaracion algoritmo END { printf("\n***** Compilacion exitosa: OK *****\n");};
				  
zona_declaracion:	declaraciones;

declaraciones:	declaracion
				|declaraciones declaracion;

declaracion:	DECVAR LLAVE_A { printf("***** Inicio declaracion de variables *****\n"); } lista_declaracion LLAVE_C {printf("***** Fin declaracion de variables *****\n");};

lista_declaracion:	lista_var DOS_PUNTOS lista_tipo
					| lista_declaracion lista_var DOS_PUNTOS lista_tipo


lista_var:		ID {strcpy(matrizVariables[contadorId],yylval.strid) ;  contadorId++; }
				| lista_var COMA ID {strcpy(matrizVariables[contadorId],yylval.strid) ; contadorId++;};

 
lista_tipo:		 TIPO_INT    { auxTipoDato="int"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Variable Entera\n"); }
				|TIPO_FLOAT  {  auxTipoDato="float"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Variable Real\n"); }
				|TIPO_STRING { auxTipoDato="string"; strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Constante String\n"); };
              

algoritmo:		bloque {printf("\n***** Fin de bloque *****\n");};

bloque:			sentencia
				|bloque sentencia;

sentencia:		asignacion { printf(" - asignacion - OK \n"); }
				|seleccion { printf(" - seleccion - OK \n"); }
				|ciclo     { printf(" - ciclo - OK \n"); }
				|entrada   { printf(" - entrada - OK \n"); }
				|salida    { printf(" - salida - OK \n"); };

ciclo:			WHILE PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C;
       
asignacion:		ID OPAR_ASIG expresion
                  
seleccion: 		IF  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C { printf("seleccion - OK\n"); } 
				| IF  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C ELSE LLAVE_A bloque LLAVE_C;

condicion:		comparacion                         { printf("Comparacion - OK\n"); }
				|comparacion OP_LOG_AND comparacion { printf("Condicion OP_LOG_AND- OK\n"); }
				|comparacion OP_LOG_OR comparacion	{ printf("Condicion OP_LOG_OR- OK\n"); }
				|OP_LOG_NOT comparacion             { printf("Condicion OP_LOG_NOT- OK\n"); };

comparacion:	expresion COMP_IGUAL expresion
				|expresion COMP_MAYOR  expresion        {printf(" - Comparacion Mayor\n");}	
				|expresion COMP_MENOR expresion         {printf(" - Comparacion Menor\n");}
				|expresion COMP_MAYOR_IGUAL expresion   {printf(" - Comparacion Mayor Igual\n");}
				|expresion COMP_MENOR_IGUAL expresion   {printf(" - Comparacion Menor Igual\n");}
				|expresion COMP_DISTINTO expresion;

elementinthemiddle: INTHE_MIDDLE PAR_A lista_expresiones PAR_C; 

lista_expresiones: 	factor
					|lista_expresiones COMA factor;

expresion:		expresion  { printf(" expresion"); } OP_MAS termino { printf(" termino"); }
				|expresion { printf(" expresion"); }OP_MENOS termino { printf(" termino"); }
				|termino   { printf(" termino"); };
									

termino:		termino OP_MULT factor { printf(" factor"); }
				|termino OP_DIV factor { printf(" factor"); }
				|factor { printf(" factor"); };
                         
factor:			ID 
				|CTE_ENTERA 
				|CTE_REAL 
				|CTE_STRING 
				|PAR_A expresion PAR_C
				|elementinthemiddle { printf("Condicion ElementInTheMiddle - OK\n"); } ;
 
entrada: 		READ PAR_A ID PAR_C;

salida:			 WRITE CTE_STRING 
			    |WRITE PAR_A ID PAR_C 
				|WRITE PAR_A CTE_STRING PAR_C;
    
%%
 
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nERROR! No se pudo abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
	escribirEnTablaSimbolos();
  }
  fclose(yyin);
  system ("Pause");
  return 0;
}

int agregarTipoEnTablaSimbolos(char* nombre, int contadorTipos)
{     
		int i;          
        char lexema[50]; 
		lexema[0]='_';
		lexema[1]='\0';
		strcat(lexema,nombre);
                 
		for(i = 0; i < puntero_array; i++)
		{
			if(strcmp(tablaSimbolos[i].nombre, lexema) == 0)
			{
				if(tablaSimbolos[i].tipo[0] == '\0')
				strcpy(tablaSimbolos[i].tipo,matrizTipoDato[contadorTipos]);
		  
				return 1; 
			}
		}
	
	return 0;	
}
