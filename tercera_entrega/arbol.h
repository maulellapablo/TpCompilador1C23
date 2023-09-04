#ifndef ARBOL_H_INCLUDED
#define ARBOL_H_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct nodo{
    struct nodo* izq;
    struct nodo* der;
    char data[45];
}t_nodo;

typedef t_nodo* t_arbol;

t_nodo* crearHoja( char* lexema);
t_nodo* crearNodo( char* lexema, t_nodo* hijoIzq, t_nodo* hijoDer);
void inOrden(t_arbol *pa, FILE *pIntermedia);
char* replace_char(char* str, char find, char replace);

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


// Función de ayuda, replace string
char* replace_char(char* str, char find, char replace){
    char *current_pos = strchr(str,find);
    while (current_pos) {
        *current_pos = replace;
        current_pos = strchr(current_pos,find);
    }
    return str;
}

#endif // ARBOL_H_INCLUDED