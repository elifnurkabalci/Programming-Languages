%{
    #include <stdio.h>
    #include <string.h>
    #include "gpp_interpreter.h"

    //fonksiyon declarations
    int yyerror (char *s);
%}


½struct values{
    char entry[30];
    int input_val;
    int *input_values;
}val;

%start INPUT
%token STRING COMMENT OP_PLUS OP_MINUS OP_DIV OP_MULT OP_OP OP_CP OP_DBLMULT OP_OC OP_CC OP_COMMA KW_AND KW_OR KW_NOT KW_EQUAL KW_LESS
KW_NIL KW_LIST KW_APPEND KW_CONCAT KW_SET KW_DEFFUN KW_FOR KW_IF KW_EXIT
KW_LOAD KW_DISP KW_TRUE KW_FALSE NEWLINE

%token <val.input_val> VALUE 
%token <val->entry> ID

%token <val.input_val> INPUT
%token <val.input_val> EXPINT
%token <val.input_val> EXPBOOL
%token <val.input_val> EXPFLOAT

%token <val->input_values> VALUES
%token <val->input_values> EXPLIST
%token <val->input_values> LISTVALUE

%%

/** program start from input, control the syntax , if it is okey. **/
INPUT:
    EXPINT {printf("SYNTAX OK. \nResult = %d\n", $1);}
    |
    EXPLIST {printf("SYNTAX OK. \nResult = "); print_arr($1);}
    ;

EXPINT:
    ID {$$ = get($1);}
    |
    VALUE {$$ = $1;}
    |
    OP_OP OP_PLUS EXPINT EXPINT OP_CP {$$ = $3 + $4;} /* (+ int int) */
    |
    OP_OP OP_MINUS EXPINT EXPINT OP_CP {$$ = $3 - $4;} /* (- int int) */
    |
    OP_OP OP_MULT EXPINT EXPINT OP_CP {$$ = $3 * $4;} /* (* int int) */
    |
    OP_OP OP_DIV EXPINT EXPINT OP_CP {$$ = $3 - $4;} /* (/ int int) */
    |
    OP_OP OP_DBLMULT EXPINT EXPINT OP_CP {$$ = pow($3, $4);} /* (^ int int) */
    |
    OP_OP KW_IF EXPBOOL EXPINT OP_CP {$$ = (1 == $3) ? $4: 0;} /* (if bool int) */
    |
    OP_OP KW_IF EXPBOOL EXPINT EXPINT OP_CP {$$ = (1 == $3) ? $4: $5;} /* (if bool int int) */
    |
    OP_OP KW_FOR EXPBOOL EXPINT OP_CP {$$ = (1 == $3) ? $4 : 0;} /* (for bool int) */
    |
    OP_OP KW_DISP EXPINT OP_CP {$$ = $3; printf("Print: %d\n", $3);}
    ;

EXPFLOAT:
    ID {$$ = get($1);}
    |
    VALUE {$$ = $1;}
    |
    OP_OP OP_PLUS EXPFLOAT EXPFLOAT OP_CP {$$ = $3 + $4;} /* (+ float float) */
    |
    OP_OP OP_MINUS EXPFLOAT EXPFLOAT OP_CP {$$ = $3 - $4;} /* (- float float) */
    |
    OP_OP OP_MULT EXPFLOAT EXPFLOAT OP_CP {$$ = $3 * $4;} /* (* float float) */
    |
    OP_OP OP_DIV EXPFLOAT EXPFLOAT OP_CP {$$ = $3 - $4;} /* (/ float float) */
    |
    OP_OP OP_DBLMULT EXPFLOAT EXPFLOAT OP_CP {$$ = pow($3, $4);} /* (^ float float) */
    |
    OP_OP KW_IF EXPBOOL EXPFLOAT OP_CP {$$ = (1 == $3) ? $4: 0;} /* (if bool float) */
    |
    OP_OP KW_IF EXPBOOL EXPFLOAT EXPFLOAT OP_CP {$$ = (1 == $3) ? $4: $5;} /* (if bool float float) */
    |
    OP_OP KW_FOR EXPBOOL EXPFLOAT OP_CP {$$ = (1 == $3) ? $4 : 0;} /* (for bool float) */
    |
    OP_OP KW_DISP EXPFLOAT OP_CP {$$ = $3; printf("Print: %f\n", $3);}
    ;
EXPBOOL:
    KW_TRUE {$$ = 1;} /* true EXP */
    |
    KW_FALSE{$$ = 0;} /* false */
    |
    OP_OP KW_NOT EXPBOOL OP_CP {$$ = !($3);} /* (not bool) */
    |
    OP_OP KW_OR EXPBOOL EXPBOOL OP_CP {$$ = $3 || $4;} /* (or bool bool) */
    |
    OP_OP KW_AND EXPBOOL EXPBOOL OP_CP {$$ = $3 && $4;} /* (and bool bool) */
    |
    OP_OP KW_EQUAL EXPBOOL EXPBOOL OP_CP {$$ = ($3 == $4);} /* (equal bool bool) */
    |
    OP_OP KW_EQUAL EXPINT EXPINT OP_CP {$$ = ($3 == $4);} /* (equal int int) */
    |
    OP_OP KW_LESS EXPINT EXPINT OP_CP {$$ = $3 < $4;} /* (less int int) */
    |
    OP_OP KW_DISP EXPBOOL OP_CP {$$ = $3; printf("Print: %s\n", ($3 ? "true":"false"));}
    ;

VALUES:
    VALUES VALUE  {$$ = append_arr($1, $2);}
    |
    VALUE {$$ = NULL; $$ = append_arr($$, $1);}
    ;

EXPLIST:
    LISTVALUE {$$ = $1;}
    |
    OP_OP KW_CONCAT EXPLIST EXPLIST OP_CP {$$ = concat_arr($3, $4);}
    |
    OP_OP KW_LIST VALUES OP_CP {$$ = $3;}
    |
    OP_OP KW_APPEND EXPINT LISTEXP OP_CP {$$ = append_arr($4, $3);}
    |
    OP_OP KW_DISP LISTVALUE OP_CP { $$ = $3; printf("Print: "); ShowArr($3);}
    ;

LISTVALUE:
    KW_NIL { $$ = NULL;} 
    |
    OP_OP OP_CP { $$= NULL; } /* {} */
    |
    OP_OP VALUES OP_CP {$$ = $2;} /* value is exist {values} */
    ;

%%

int yyerror(char *s){
    fprintf(stderr, "SYNTAX ERROR. \n");
    return 0;
}
void print_arr(int *arr){
    printf("( ");
    for(int i=0;arr[i]!=-1; ++i)
        printf("%d ", arr[i]);
    printf(")\n");
}
int pow_func(int a, int pow){
    int i=0, result=1; 
    for(i; i<pow; i++){
        result = result * a; 
    }
    return result;
}
int* append_arr(int *arr, int val){
    if(arr == NULL){ /* if arr is empty, create arr and add val number */
        arr = (int*)malloc(sizeof(int)*2); /* allocate 2 memory part, for data and end of array (-1) */
        arr[0] = val;
        arr[1] = -1; /* end of the array */
    }
    else{ /* expand the old one */
        int size=0, i=0; 
        int *temp=arr; /* for save the initial of array */
        while(*temp != -1){ /* we use like a iterator */
            ++temp;
            ++size;
        }
        temp = arr; /* for using arr in initial point. */ 
        arr = (int*)(malloc(sizeof(int)*(size+2)));
        for(i; i<size; i++){
            arr[i] = temp[i];
        }
        arr[i] = val;
        arr[i+1] = -1;
        free(temp);
    }
    return arr;
}
int* concat_arr(int *arr1, int *arr2){
    int i=0, size2=0,size1=0, j=0;
    int *temp;
    while(arr2[size1]!= -1) size1++;
    while(arr2[size2]!= -1) size2++;
    temp = (int *) malloc(sizeof(int) * (size1 + size2) + 2);
    for(i; i<size1; i++){
        temp[i]=arr1[i];
    }
    for(j; j<size2; j++){
        temp[i+j]=arr2[j];
    }
    temp[i+j]=-1;
    free(arr1);
    free(arr2);
    return temp;
    /*
    ikincil algoritma:
        for(size2)
            append_arr(arr1,arr2[size2])

    */

} 
int main(int argc, char *argv[]){
    ++argv, --argc;
    start_Table();
    while(1){
        yyparse();
    }
    return 0;
}