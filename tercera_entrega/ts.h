#ifndef TS_H_INCLUDED
#define TS_H_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

int puntero_array = 0;
struct struct_tablaSimbolos tablaSimbolos[1000];

int guardarEnTablaSimbolos(int, char*);
void escribirEnTablaSimbolos();
void validarSimbolo(char*);
void validarTipoSimbolo(char*, int);
char* replace_char(char* str, char find, char replace);
void removeChar(char *str, char garbage);
void agregarTipoSimbolo(char *nombre, int tipo);

// Función de ayuda, replace string
char* replace_char(char* str, char find, char replace){
    char *current_pos = strchr(str,find);
    while (current_pos) {
        *current_pos = replace;
        current_pos = strchr(current_pos,find);
    }
    return str;
}

void removeChar(char *str, char garbage) {

    char *src, *dst;
    for (src = dst = str; *src != '\0'; src++) {
        *dst = *src;
        if (*dst != garbage) dst++;
    }
    *dst = '\0';
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

void escribirEnTablaSimbolos(){
	FILE *pf; 
	int i;
	pf = fopen("ts.txt","w"); 

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

void validarSimbolo(char* lexema){
	char aux[50];
	strcpy(aux, lexema);
	replace_char(aux,' ','_');
	removeChar(aux,'"');
	for(int i = 0; i < puntero_array; i++) {
		if(strcmp(tablaSimbolos[i].nombre, aux) == 0){
			return;
		}
	}

	printf("ERROR! La variable %s no se encuentra definida", aux);
	exit(0);
}

void validarTipoSimbolo(char* lexema, int tipo){
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

	switch(tipo){
		case TS_INT:
		case TS_FLOAT:
			if(strcmp(tablaSimbolos[pos].tipo,"string") == 0){
				printf("ERROR! La variable %s de tipo %s no es entera o flotante!",tablaSimbolos[pos].nombre, tablaSimbolos[pos].tipo);
				exit(0);
			}
			break;
		case TS_STRING:
			if(strcmp(tablaSimbolos[pos].tipo,"string") != 0){
				printf("ERROR! La variable %s de tipo %s no es una string!",tablaSimbolos[pos].nombre, tablaSimbolos[pos].tipo);
				exit(0);
			}
			break;
	}
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

#endif