 %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "arbol.h"

#define TS_INT 1
#define TS_FLOAT 2
#define TS_STRING 3
#define TS_ID 4
#define TS_AUX 5

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
int contadorVar = 0;
char* auxTipoDato;
char matrizTipoDato[100][10];
char matrizVariables[100][10];
int contadorId = 0;
int guardarEnTablaSimbolos(int, char*);
int agregarTipoEnTablaSimbolos(char* nombre, int contadorId);
void escribirEnTablaSimbolos();
void generarAssembler(t_arbol *pa, FILE *f, struct struct_tablaSimbolos* ts);
void  printTablaDeSimbolosAsm(FILE *f);
t_arbol* inOrderAssembler(t_arbol *pa, FILE *f);
void removeChar(char *str, char garbage);
int esHoja(t_arbol* pa);
void traduccionAssembler(t_arbol* pa, FILE* f);
void traduccionCond(t_arbol* pa, FILE* f, char* salto);
void traduccionIf(t_arbol* pa,FILE* f, char* salto);
void traduccionElseIf(t_arbol* pa,FILE* f, char* salto);
void traduccionWhile(t_arbol* pa,FILE* f, char* salto);

int contAux = 0;
int contSalto = 1;
int contElse = 0;
int contWhile=0;
int contFinIf = 1;
char str_aux[20];

FILE *f_intermedia;
FILE *f_dot_arbol;
FILE *f_asm;

// Declaracion punteros arbol
t_nodo* ptr_star; //star
t_nodo* ptr_prog; //programa
t_nodo* ptr_zona; //zona_declaracion
t_nodo* ptr_decls; //declaraciones
t_nodo* ptr_decl; //declaracion
t_nodo* ptr_list_dec; //lista_declaracion
t_nodo* ptr_list_var; //lista_var
t_nodo* ptr_list_tip; //lista_tipo
t_nodo* ptr_algo; //algoritmo
t_nodo* ptr_bloq; //bloque
t_nodo* ptr_sub_bloq;
t_nodo* ptr_sent; //sentencia
t_nodo* ptr_cicl; //ciclo
t_nodo* ptr_asig; //asignacion
t_nodo* ptr_sele; //seleccion
t_nodo* ptr_true; //Rama verdadera
t_nodo* ptr_false;//Rama falsa
t_nodo* ptr_cond; //condicion
t_nodo* ptr_cond_aux;
t_nodo* ptr_comp; //comparacion
t_nodo* ptr_comp_aux;
t_nodo* ptr_expr; //expresion
t_nodo* ptr_inmid; //inthe_middle
t_nodo* ptr_list_exp; //lista_expresiones


t_nodo* ptr_term; //termino
t_nodo* ptr_fact; //factor
t_nodo* ptr_entr; //entrada
t_nodo* ptr_sali; //salida

//flags
int and_flag, or_flag;
int _cont = 0;
char *_aux[1000];

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
start: programa {ptr_star = ptr_prog; inOrder(&ptr_star, f_intermedia); generarDOT(&ptr_star, f_dot_arbol); generarAssembler(&ptr_star, f_asm, tablaSimbolos);};

programa: PROGRAM zona_declaracion algoritmo END {ptr_prog = crearNodo("programa", ptr_algo, NULL); printf("\n***** Compilacion exitosa: OK *****\n");};
				  
zona_declaracion:	declaraciones {ptr_zona = ptr_decls;};

declaraciones:	declaracion {ptr_decls = ptr_decl;}
				|declaraciones declaracion {
					ptr_decls = crearNodo("declaraciones", ptr_decls, ptr_decl);};

declaracion:	DECVAR LLAVE_A { printf("***** Inicio declaracion de variables *****\n"); } lista_declaracion LLAVE_C {ptr_decl= ptr_list_dec; printf("*****\n Fin declaracion de variables *****\n");};

lista_declaracion:	lista_var DOS_PUNTOS lista_tipo {ptr_list_dec = crearNodo("dec", ptr_list_var, ptr_list_tip);}
					| lista_declaracion lista_var DOS_PUNTOS lista_tipo {ptr_list_dec = crearNodo("lista_dec_vars", ptr_list_dec, crearNodo("dec", ptr_list_var, ptr_list_tip));};


lista_var:		ID {strcpy(matrizVariables[contadorId],yylval.strid) ;  contadorId++; contadorVar++;ptr_list_var = crearHoja($1);}
				| lista_var COMA ID {strcpy(matrizVariables[contadorId],yylval.strid) ; contadorId++;contadorVar++;
									ptr_list_var = crearNodo("list_var", ptr_list_var, crearHoja($3));
									};

lista_tipo:		TIPO_INT { auxTipoDato="int"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Variable Entera\n");} contadorVar=0; }
				|TIPO_FLOAT {  auxTipoDato="float"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Variable Real\n"); }contadorVar = 0; }
				|TIPO_STRING { auxTipoDato="string"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf("Constante String\n");}contadorVar = 0; };
              
algoritmo:		bloque {ptr_algo = ptr_bloq; printf("\n***** Fin de bloque *****\n");};

bloque:			sentencia {if(ptr_bloq == NULL){ptr_bloq = ptr_sent;}else{ptr_bloq = crearNodo("bloque", ptr_bloq, ptr_sent);}}
				|bloque sentencia {ptr_bloq = crearNodo("bloque", ptr_bloq, ptr_sent);};

sub_bloque:		sentencia {ptr_sub_bloq = ptr_sent;}
				|sub_bloque sentencia {ptr_sub_bloq = crearNodo("sub_bloque", ptr_sub_bloq, ptr_sent);};


sentencia:		asignacion { ptr_sent = ptr_asig; printf(" - asignacion - OK \n"); }
				|seleccion { ptr_sent = ptr_sele; printf(" - seleccion - OK \n"); }
				|ciclo { ptr_sent = ptr_cicl; printf(" - ciclo - OK \n"); }
				|entrada { ptr_sent = crearNodo("entrada", ptr_entr, NULL); printf(" - entrada - OK \n"); }
				|salida { ptr_sent = crearNodo("salida", ptr_sali, NULL); printf(" - salida - OK \n"); };

ciclo:			WHILE PAR_A condicion PAR_C LLAVE_A sub_bloque LLAVE_C {ptr_cicl = crearNodo("ciclo", ptr_cond, ptr_sub_bloq);};
       
asignacion:		ID OPAR_ASIG expresion {ptr_asig = crearNodo(":=", crearHoja($1), ptr_expr);};

                  
seleccion: 		IF  PAR_A condicion PAR_C LLAVE_A sub_bloque LLAVE_C {
																	if(and_flag){
																		ptr_sele = crearNodo("if", ptr_cond,crearNodo("if",ptr_cond_aux,ptr_sub_bloq));
																		and_flag = 0;
																	}else if(or_flag) {
																		ptr_sele = crearNodo("if", ptr_cond,crearNodo("else", ptr_sub_bloq, crearNodo("if",ptr_cond_aux,ptr_sub_bloq)));
																		or_flag = 0;
																	}else{
																		ptr_sele = crearNodo("if", ptr_cond, ptr_sub_bloq);
																	}
																}

				| IF  PAR_A condicion PAR_C LLAVE_A sub_bloque LLAVE_C {ptr_true = ptr_sub_bloq;} ELSE LLAVE_A sub_bloque {ptr_false = ptr_sub_bloq;} LLAVE_C {
																	if(and_flag){
																		ptr_sele = crearNodo("if", ptr_cond, crearNodo("else",crearNodo("if",ptr_cond_aux,crearNodo("else",ptr_true,ptr_false)),ptr_false));
																		and_flag = 0;
																	}else if(or_flag) {
																		ptr_sele = crearNodo("if", ptr_cond, crearNodo("else",ptr_true,crearNodo("if",ptr_cond_aux,crearNodo("else",ptr_true,ptr_false))));
																		or_flag = 0;
																	}else{
																		ptr_sele = crearNodo("if", ptr_cond, crearNodo("else", ptr_true, ptr_false));
																	}
																};
			
condicion:		comparacion              {ptr_cond = ptr_comp; printf("Comparacion - OK\n"); }
				|comparacion OP_LOG_AND  {ptr_cond_aux = ptr_comp; } comparacion { and_flag = 1;ptr_cond = ptr_comp; printf("Condicion OP_LOG_AND- OK\n"); }
				|comparacion OP_LOG_OR   {ptr_cond_aux = ptr_comp; } comparacion { or_flag = 1;ptr_cond = ptr_comp; printf("Condicion OP_LOG_OR- OK\n"); }
				|OP_LOG_NOT comparacion  {ptr_cond = crearNodo("not", ptr_comp, NULL); printf("Condicion OP_LOG_NOT- OK\n"); };

comparacion:	expresion {ptr_comp_aux = ptr_expr;} COMP_IGUAL expresion {ptr_comp = crearNodo("==",ptr_comp_aux,ptr_expr);}  
				|expresion {ptr_comp_aux = ptr_expr;} COMP_MAYOR expresion	{ptr_comp = crearNodo(">",ptr_comp_aux,ptr_expr);}   
				|expresion {ptr_comp_aux = ptr_expr;} COMP_MENOR expresion {ptr_comp = crearNodo("<",ptr_comp_aux,ptr_expr);}  
				|expresion {ptr_comp_aux = ptr_expr;} COMP_MAYOR_IGUAL expresion  {ptr_comp = crearNodo(">=",ptr_comp_aux,ptr_expr);}  
				|expresion {ptr_comp_aux = ptr_expr;} COMP_MENOR_IGUAL expresion {ptr_comp = crearNodo("<=",ptr_comp_aux,ptr_expr);}  
				|expresion {ptr_comp_aux = ptr_expr;} COMP_DISTINTO expresion {ptr_comp = crearNodo("!=",ptr_comp_aux,ptr_expr);} ;

elementinthemiddle: INTHE_MIDDLE PAR_A lista_expresiones PAR_C {
					printf("\nINTHE_MIDDLE! Cant. params: %d\n", _cont);
					printf("\nINTHE_MIDDLE! In the middle: %s\n", _aux[(_cont-1)/2]);
					ptr_inmid = crearHoja(_aux[(_cont-1)/2]);
				};

lista_expresiones: 	factor { _cont = 1;}
					|lista_expresiones COMA factor { _cont++; };

expresion:		expresion { printf(" expresion"); } OP_MAS termino { printf(" termino"); ptr_expr=crearNodo("+",ptr_expr,ptr_term); }
				|expresion { printf(" expresion"); }OP_MENOS termino { printf(" termino"); ptr_expr=crearNodo("-",ptr_expr,ptr_term);}
				|termino { printf(" termino"); ptr_expr=ptr_term; };
									

termino:		termino OP_MULT factor { printf(" factor"); ptr_term=crearNodo("*",ptr_term,ptr_fact);}
				|termino OP_DIV factor { printf(" factor"); ptr_term=crearNodo("/",ptr_term,ptr_fact);}
				|factor { printf(" factor"); ptr_term=ptr_fact; };
                         
factor:			ID {ptr_fact = crearHoja($1); _aux[_cont] = $1;}
				|CTE_ENTERA {ptr_fact = crearHoja($1); _aux[_cont] = $1;}
				|CTE_REAL {ptr_fact = crearHoja($1); _aux[_cont] = $1;}
				|CTE_STRING {ptr_fact = crearHoja($1); _aux[_cont] = $1;}
				|PAR_A expresion PAR_C
				|elementinthemiddle {ptr_fact = ptr_inmid; printf("Condicion ElementInTheMiddle - OK\n"); } ;
 
entrada: 		READ PAR_A ID PAR_C {ptr_entr = crearHoja($3);};

salida:			 WRITE CTE_STRING {ptr_sali = crearHoja($2);}
			    |WRITE PAR_A ID PAR_C {ptr_sali = crearHoja($3);}
				|WRITE PAR_A CTE_STRING PAR_C {ptr_sali = crearHoja($3);};
    
%%
 
int main(int argc,char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nERROR! No se pudo abrir el archivo: %s\n", argv[1]);
		return 1;
	}

	if ((f_intermedia = fopen("intermediate-code.txt", "wt")) == NULL){
		printf("\nERROR! No se pudo abrir el archivo intermedia\n");
		return 1;
	}

	if ((f_dot_arbol = fopen("arbol.dot", "wt")) == NULL){
		printf("\nERROR! No se pudo abrir el archivo .dot para armar el arbol\n");
		return 1;
	}

		if ((f_asm = fopen("Final.asm", "wt")) == NULL){
		printf("\nERROR! No se pudo abrir el archivo Final.asm para armar el programa\n");
		return 1;
	}


	or_flag = and_flag = 0;
	
	yyparse();
	escribirEnTablaSimbolos();
	fclose(yyin);
	fclose(f_intermedia);
	system ("Pause");
	return 0;
}

void removeChar(char *str, char garbage) {

    char *src, *dst;
    for (src = dst = str; *src != '\0'; src++) {
        *dst = *src;
        if (*dst != garbage) dst++;
    }
    *dst = '\0';
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

void generarAssembler(t_arbol *pa, FILE *f_asm, struct struct_tablaSimbolos* ts){
	char Linea[300];

	FILE *f_temp = fopen("Temp.asm", "wt");
    //printf("\n\n Inorder ASSEMBLER");
	//while(inOrderAssembler(pa, f_temp) != pa){}
    inOrderAssembler(pa, f_temp);
 
	fclose(f_temp);

	f_temp = fopen("Temp.asm", "rt");

	fprintf(f_asm, "include macros2.asm\ninclude number.asm\n.MODEL LARGE	; Modelo de Memoria\n.386	        ; Tipo de Procesador\n.STACK 200h		; Bytes en el Stack\n\n.DATA \n\n");

	printTablaDeSimbolosAsm(f_asm);

	fprintf(f_asm, "\n\n.CODE\n\nmov AX,@DATA    ; Inicializa el segmento de datos\nmov DS,AX\nmov es,ax ;\n\n");

	while(fgets(Linea, sizeof(Linea), f_temp))
	{
		fprintf(f_asm, Linea);
	}

	fclose(f_temp);
	remove("Temp.asm");

	fprintf(f_asm, "\n\n\nmov ax,4c00h	; Indica que debe finalizar la ejecución\nint 21h\n\nEnd\n");

	fclose(f_asm);
}

void  printTablaDeSimbolosAsm(FILE* f){
    for(int i = 0; i < puntero_array; i++){
       if((!strncmp(tablaSimbolos[i].nombre, "_", 1)) && (strcmp(tablaSimbolos[i].tipo, "int") == 0)) //Es CTE Entera
        {
            strcat(tablaSimbolos[i].valor, ".00");
            fprintf(f, "%-30s%-30s%-30s%-s %-s\n", tablaSimbolos[i].nombre, "dd", tablaSimbolos[i].valor, ";Cte en formato ", tablaSimbolos[i].tipo);
        }
        else if(!strncmp(tablaSimbolos[i].nombre, "_", 1)) { // Es CTE
            replace_char(tablaSimbolos[i].nombre,' ','_');
            removeChar(tablaSimbolos[i].nombre,'"');
            if(strcmp(tablaSimbolos[i].tipo,"string") == 0)
				fprintf(f, "%-30s %-30s %-30s,'$', %s dup (?) %s\n", tablaSimbolos[i].nombre, "db", tablaSimbolos[i].valor, tablaSimbolos[i].longitud, ";Cte en formato ", tablaSimbolos[i].tipo);
			else
				fprintf(f, "%-30s%-30s%-30s%-s %-s\n", tablaSimbolos[i].nombre, "dd", tablaSimbolos[i].valor, ";Cte en formato ", tablaSimbolos[i].tipo);
		}
        else if(strncmp(tablaSimbolos[i].nombre, "_", 1)) //Es variable
            fprintf(f, "%-30s%-30s%-30s%-s %-s\n", tablaSimbolos[i].nombre, "dd", "?", ";Variable", tablaSimbolos[i].tipo);
    }
}

int esHoja(t_arbol* pa){
    if(!*pa)
        return 0;
 
    return (!(*pa)->izq) && (!(*pa)->der);
}

int guardarEnTablaSimbolos(int tipo, char* nombre){
	
	char longitudConstanteString[10];
	int i;
	int posicion;
	char lexema[50];
	char aux[50];
	char aux_valor[50];

	strcpy(aux_valor, nombre);

	replace_char(nombre,' ','_');
	replace_char(nombre,'.','_');
	removeChar(nombre,'"');

	if(tipo != TS_ID){
		aux[0]='_';
		aux[1]='\0';
		//Se anexa al lexema un guion bajo al inicio
		strcat(aux,nombre);
	}else{
		aux[0]='\0';
		strcat(aux,nombre);
	}

	strcpy(nombre,aux);
	
	//Recorremos la tabla de simbolos y en caso que el lexema ya exista, no se agrega y se retorna su posicion
	for(i = 0; i < puntero_array; i++)
	{
		if(strcmp(tablaSimbolos[i].nombre, nombre) == 0)
		{
			return i;
		}
	}
	
	tablaSimbolos[puntero_array].valor[0]='\0';
	//En caso de ser una CTE, guardamos el Valor en la tabla de simbolos
	if(tipo != TS_ID){
		strcat(tablaSimbolos[puntero_array].valor, aux_valor);
	}
		
	strcpy(tablaSimbolos[puntero_array].nombre, nombre);

	tablaSimbolos[puntero_array].tipo[0]='\0';
	switch(tipo){
		case TS_INT:
			strcat(tablaSimbolos[puntero_array].tipo, "int");
			break;
		case TS_STRING:
			strcat(tablaSimbolos[puntero_array].tipo, "string");
			break;
		case TS_FLOAT:
			strcat(tablaSimbolos[puntero_array].tipo, "float");
			break;
	}

	//En caso de ser una CTE string, se cuentan los caracteres y se guardan en la tabla de simbolos
	if(tablaSimbolos[i].valor[0] == '\"')
	{
		snprintf(longitudConstanteString, sizeof(longitudConstanteString), "%d", strlen(tablaSimbolos[i].valor)-2);
		strcpy(tablaSimbolos[i].longitud,longitudConstanteString);
	}
	else
		tablaSimbolos[puntero_array].longitud[0]='0';
	
	//Se agrega en la tabla de simbolos y se retorna su posicion
	posicion = puntero_array;
	puntero_array++;
	
	return posicion;
}

void agregarTipoSimbolo(char* lexema, int tipo){
	int pos = -1;

	char aux[50];
	strcpy(aux, lexema);
	replace_char(aux,' ','_');
	removeChar(aux,'"');

	for(int i = 0; i < puntero_array; i++) {
		if(strcmp(tablaSimbolos[i].nombre, aux) == 0){
			pos = i;
			break;
		}
	}

	if(pos == -1){
		printf("ERROR! La variable %s no se encuentra definida", aux);
		exit(0);
	}
	tablaSimbolos[pos].tipo[0]='\0';
	switch(tipo){
		case TS_INT:
			strcat(tablaSimbolos[pos].tipo, "int");
			break;
		case TS_STRING:
			strcat(tablaSimbolos[pos].tipo, "string");
			break;
		case TS_FLOAT:
			strcat(tablaSimbolos[pos].tipo, "float");
			break;
	}
}

t_arbol* inOrderAssembler(t_arbol *pa, FILE *f){

    if(!*pa)
        return NULL;
    char aux[50] = "\0";
    if(strcmp((*pa)->data, "ciclo")==0 ){
        contWhile++;
        strcat(aux, str_aux);
        traduccionWhile(pa,f,aux);
        inOrderAssembler(&(*pa)->izq,f);
        contWhile++;
        inOrderAssembler(&(*pa)->der,f);
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        contSalto++;
        aux[0] = '\0';
        strcat(aux, str_aux);
        traduccionWhile(pa,f,aux);
        contWhile = 0;
        return NULL;
    }

    inOrderAssembler(&(*pa)->izq, f);
 
    if(strcmp((*pa)->data, "else")==0 ){
        contElse++;
        inOrderAssembler(&(*pa)->izq,f);
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        contSalto++;
        strcat(aux, str_aux);
        traduccionElseIf(pa,f,aux);
        contElse++;
        inOrderAssembler(&(*pa)->der,f);
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        aux[0] = '\0';
        strcat(aux, str_aux);
        traduccionElseIf(pa,f,aux);
        contElse = 0;
        return NULL;
    }

   
    inOrderAssembler(&(*pa)->der, f);

    if(esHoja(&(*pa)->izq) && ((esHoja(&(*pa)->der)) || (*pa)->der == NULL)){
        if(strcmp((*pa)->data,"bloque") == 0 || strcmp((*pa)->data,"sub_bloque") == 0){
            return NULL;
        }
        // printf("\n\n TRADUCCIR, %d %d\n",esHoja(&(*pa)->izq),esHoja(&(*pa)->der));
        // printf("\nIZQ: %s\n",(*pa)->izq->data);
        traduccionAssembler(pa,f);
        return pa;
    }

    //printf("%s", (*pa)->data);
}

void traduccionAssembler(t_arbol* pa, FILE* f){
    if(!*pa)
        return;
    if((strcmp((*pa)->data,"programa") == 0))
        return;
    char cadena[50]="";
    if(strcmp((*pa)->data, ">")==0 ){
        strcat(cadena,"JNA\0");
            traduccionCond(pa,f,cadena);
        return;
    }else if (strcmp((*pa)->data, "<")==0 ){
        strcat(cadena,"JNB\0");
            traduccionCond(pa,f,cadena);
        return;
    }else if (strcmp((*pa)->data, ">=")==0 ){
        strcat(cadena,"JNAE\0");
            traduccionCond(pa,f,cadena);
        return;
    }else if (strcmp((*pa)->data, "<=")==0 ){
            strcat(cadena,"JNBE\0");
            traduccionCond(pa,f,cadena);
        return;
    }else if (strcmp((*pa)->data, "==")==0 ){
            strcat(cadena,"JNE\0");
            traduccionCond(pa,f,cadena); 
        return;
    }else if (strcmp((*pa)->data, "!=")==0 ){
            strcat(cadena,"JE\0");
            traduccionCond(pa,f,cadena);
        return;
    }

    if (strcmp((*pa)->data, "if")==0 ){
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        contSalto++;
        strcat(cadena, str_aux);
        traduccionIf(pa,f,cadena);
        return;
    } else if (strcmp((*pa)->data, "else")==0 ){
        //contElse++;
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        contSalto++;
        strcat(cadena, str_aux);
        traduccionElseIf(pa,f,cadena);
        return;
    }

    if (strcmp((*pa)->data, "ciclo")==0 ){
        contWhile++;
        sprintf(str_aux, "saltoelse%d\0", contSalto);
        contSalto++;
        strcat(cadena, str_aux);
        traduccionWhile(pa,f,cadena);
        return;
    }

    if (strcmp((*pa)->data, "salida") == 0){
        fprintf(f,"displayString %s\n",(*pa)->izq->data);
        free((*pa)->izq);
        (*pa)->izq = NULL;
        return;
    }
		
    if (strcmp((*pa)->data, "entrada") == 0){
        fprintf(f,"getString %s\n",(*pa)->izq->data);
        free((*pa)->izq);
        (*pa)->izq = NULL;
        return;
    }

    int tam=strlen("bloque");
    strncpy(cadena, (*pa)->data, tam);
    cadena[tam]='\0';
    if(strcmp(cadena, "bloque")!=0 && strcmp(cadena, "sub_bloque")!=0 ){
        //printf("NODO %s\n\t\t%s\n\t\t%s\n", (*pa)->data,(*pa)->izq->data,(*pa)->der->data);
        if(strcmp((*pa)->data,":=")!=0)
            fprintf(f,"FLD %s\n", ((*pa)->izq)->data);
        fprintf(f,"FLD %s\n",((*pa)->der)->data);
        //printf("HOLA2");
        if(strcmp((*pa)->data, "+")==0)
            fprintf(f,"FADD \n");
        else if(strcmp((*pa)->data, "-")==0)
            fprintf(f,"FSUB \n");
        else if(strcmp((*pa)->data, "/")==0)
            fprintf(f,"FDIV \n");
        else if(strcmp((*pa)->data, "*")==0)
            fprintf(f,"FMUL \n");
        
        if(strcmp((*pa)->data,":=")==0){
            fprintf(f,"FSTP %s\n",((*pa)->izq)->data);    
        }else{
            sprintf(cadena,"@Aux%d",++contAux);
            fprintf(f,"FSTP %s\n",cadena);
            strcpy((*pa)->data, cadena);
            guardarEnTablaSimbolos(TS_ID, cadena);
            agregarTipoSimbolo(cadena, TS_FLOAT);
        }
        fprintf(f,"FFREE\n"); 
    }

    free((*pa)->izq);
    (*pa)->izq = NULL;
    free((*pa)->der);
    (*pa)->der = NULL;
}

void traduccionCond(t_arbol* pa, FILE* f, char* salto){
     if(!*pa)
        return;
	
	fprintf(f,"FLD %s\n", ((*pa)->izq)->data);
	fprintf(f,"FCOMP %s\n", ((*pa)->der)->data);
    fprintf(f,"FSTSW ax\n");
    fprintf(f,"SAHF\n");
    sprintf(str_aux, "saltoelse%d", contSalto);
    fprintf(f,"%s %s\n", salto, str_aux);

    free((*pa)->izq);
    free((*pa)->der);

    (*pa)->izq = NULL;
    (*pa)->der = NULL;
}

void traduccionIf(t_arbol* pa,FILE* f, char* salto){
     if(!*pa)
        return;
    if(contElse==0){
        fprintf(f,"%s:\n",salto);
        fprintf(f,"FFREE\n"); 
    }
    contElse=0;
    free((*pa)->izq);
    free((*pa)->der);

    (*pa)->izq = NULL;
    (*pa)->der = NULL;
}

void traduccionElseIf(t_arbol* pa,FILE* f, char* salto){
    if(!*pa)
        return;
    if(contElse==1){
        char salto2[5]="JMP";
        sprintf(str_aux, "fin_if%d", contFinIf);
        fprintf(f,"%s %s\n",salto2, str_aux);
        fprintf(f,"%s:\n",salto);
        return;
    }else if(contElse==2){
        sprintf(str_aux, "fin_if%d", contFinIf);
        fprintf(f,"%s:\n", str_aux);
        contFinIf++;
        free((*pa)->izq);
        free((*pa)->der);

        (*pa)->izq = NULL;
        (*pa)->der = NULL;
    }
}

void traduccionWhile(t_arbol* pa,FILE* f, char* salto){
     if(!*pa)
        return;
     if(contWhile==1){
         fprintf(f,"%s:\n","principiowhile");
         return;
     }else if(contWhile==2){
        fprintf(f,"JMP principiowhile\n");
        fprintf(f,"%s:\n",salto);
        free((*pa)->izq);
        free((*pa)->der);

        (*pa)->izq = NULL;
        (*pa)->der = NULL;
    }
}