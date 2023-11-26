#ifndef ARBOL_H_INCLUDED
#define ARBOL_H_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

typedef struct nodo{
    struct nodo* izq;
    struct nodo* der;
    char data[45];
}t_nodo;

typedef t_nodo* t_arbol;

t_nodo* crearHoja( char* lexema);
t_nodo* crearNodo( char* lexema, t_nodo* hijoIzq, t_nodo* hijoDer);
void inOrden(t_arbol *pa, FILE *pIntermedia);
void invertirOperador(t_nodo* n);
void generarAssembler(t_arbol *pa, FILE *f, struct struct_tablaSimbolos* ts);
void  printTablaDeSimbolosAsm(FILE *f);
t_arbol* inOrderAssembler(t_arbol *pa, FILE *f);
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

t_nodo* crearHoja( char* lexema){
    t_nodo* nodo = (t_nodo*) malloc (sizeof(t_nodo));
    if(!nodo){
        printf("No se pudo reservar memoria para el nodo.\n");
        return NULL;
    }
    //Ponemos izq y der en NULL, y almacenamos el lexema dentro del t_nodo
    nodo->izq = NULL;
    nodo->der = NULL;
    strcpy(nodo->data, lexema);
    return nodo;
}

t_nodo* crearNodo(char* lexema, t_nodo* hijoIzq, t_nodo* hijoDer){
    t_nodo* padre = crearHoja(lexema);
    if(!padre){
        return NULL;
    }

    padre->izq = hijoIzq;
    padre->der = hijoDer;

    return padre;
}

void inOrder(t_arbol *pa, FILE *pIntermedia)
{
    if(!(*pa))
        return;
    inOrder(&(*pa)->izq, pIntermedia);
	printf(" %s  ", (*pa)->data);
    fprintf(pIntermedia, " %s  ", (*pa)->data);  
    inOrder(&(*pa)->der, pIntermedia);
}


void grabarNodoDOT(t_nodo *pn, FILE* stream, int* numero)
{
    int thisId = (*numero);
    fprintf(stream, "id%d [label = \"%s\"];\n", thisId, replace_char((*pn).data,'"','\''));

    if ((*pn).izq)
    {
        int izqId = ++(*numero);
        grabarNodoDOT((*pn).izq, stream, numero);
        fprintf(stream, "id%d -> id%d ;\n", thisId , izqId);
    }

    if ((*pn).der)
    {
        int derId = ++(*numero);
        grabarNodoDOT((*pn).der, stream, numero);
        fprintf(stream, "id%d -> id%d ;\n", thisId , derId);
    }
}

void generarDOT(t_arbol* pa, FILE* stream)
{
    fprintf(stream, "digraph BST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if(!(*pa))
        fprintf(stream, "\n");
    else if (!(*pa)->der && !(*pa)->izq)
        fprintf(stream, "    \"%s\";\n", (*pa)->data);
    else{
        int numero = 1;
        grabarNodoDOT((*pa), stream, &numero);
    }

    fprintf(stream, "}\n");
}


void invertirOperador(t_nodo* n){
    if(strcmp(n->data, "==") == 0){
        strcpy(n->data, "!=");
        return;
    }
    if(strcmp(n->data, "!=") == 0){
        strcpy(n->data, "==");
        return;
    }
    if(strcmp(n->data, "<") == 0){
        strcpy(n->data, ">=");
        return;
    }
    if(strcmp(n->data, ">=") == 0){
        strcpy(n->data, "<");
        return;
    }
    if(strcmp(n->data, ">") == 0){
        strcpy(n->data, "<=");
        return;
    }
    if(strcmp(n->data, "<=") == 0){
        strcpy(n->data, ">");
        return;
    }
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

#endif // ARBOL_H_INCLUDED