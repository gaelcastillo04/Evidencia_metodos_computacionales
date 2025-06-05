%{
#include <stdio.h>
#include <stdlib.h>

FILE *output;
extern FILE *yyin;
void yyerror(const char *s);
int yylex(void);

int please_counter=0;
%}

%union {
    int num;
}

%token SUBJECT COURTESY_WORD MOVE TURN BLOCKS DEGREES DIRECTION CONNECTOR COMMA DOT BACKWARD
%token <num> NUMBER DEGREE
%type <num> move_phrase rotate_phrase


%%
program:
    sentence_list
    ;

sentence_list:
    structure_sentence DOT
    | structure_sentence DOT sentence_list
    ;

structure_sentence:
    requirements sentence requirements{
        if (please_counter == 0){
            yyerror("Syntax error: You must use at least 'please' at the beginning or end of the sentence.\n");
            YYABORT;
        }
            please_counter=0;
    }
    ;

requirements:
    /* nothing */
    | SUBJECT COURTESY_WORD {please_counter=1;}
    | COURTESY_WORD SUBJECT {please_counter=1;}
    | SUBJECT
    | COURTESY_WORD {please_counter=1;}
    ;

sentence:
    complex_verb
    ;


complex_verb:
    verb_phrase
    | verb_phrase CONNECTOR sentence
    ;

optional_comma:
    /* nothing */
    | COMMA
    ;

verb_phrase:
    move_phrase optional_comma
    | move_phrase DIRECTION optional_comma
    | rotate_phrase optional_comma
    | move_backward_phrase optional_comma 
    ;

move_phrase:
    MOVE NUMBER BLOCKS
    {
        fprintf(output, "MOV,%d\n", $2);
    }
    ;

move_backward_phrase:
    MOVE NUMBER BLOCKS BACKWARD
    {
        fprintf(output, "TURN,180\n");
        fprintf(output, "MOV,%d\n", $2);
        fprintf(output, "TURN,180\n");
    }
    ;

rotate_phrase:
    TURN DEGREE DEGREES
    {
        fprintf(output, "TURN,%d\n", $2);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *in = fopen(argv[1], "r");
    if (!in) {
        perror("Input file error");
        return 1;
    }

    yyin = in;
    output = fopen("instructions.asm", "w");
    if (!output) {
        perror("Output file error");
        return 1;
    }

    yyparse();

    fclose(in);
    fclose(output);

    return 0;
}