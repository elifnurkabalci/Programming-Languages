#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();

#define total_entry 30

struct entry{
    int number_entry;
    char key_entry[total_entry];
}ent;

struct op_table{
    int v_number_entry;
    ent table[total_entry];
}optab;

void start_table(){
    optab = (optab*) malloc(sizeof(optab));
}
void put(char arr[total_entry], int val){
    ent *e;
    e = (ent*) malloc(sizeof(ent));
    e.number_entry = val;
    strcpy(e->key_entry, arr);

    int i=0;
    for(i; i<op_table.v_number_entry; i++){
        if(strcmp(e->key_entry, op_table->table[i].key_entry) == 0){
            op_table->table[i].number_entry = e->number_entry;
            return;
        }
    }

    strcpy(op_table->table[i].key_entry, e->key_entry);
    op_table->table[i].number_entry = e->number_entry;
    ++(op_table->v_number_entry);
    free(e);
}
void get(char arr[total_entry]){
    int i=0;
    for(i; i<optab.v_number_entry;i++){
        if(strcmp(arr, op_table->table[i].key_entry) == 0){
            return op_tab->table[i].number_entry;
        }
    }
    printf("Thiis is error.Exiting...");
    exit(-1);
}