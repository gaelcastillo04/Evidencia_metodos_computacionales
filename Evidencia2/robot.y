%{
#include <stdio.h>
#include <stdlib.h>

FILE *output;
extern FILE *yyin;
void yyerror(const char *s);
int yylex(void);
%}

%union {
    int num;
}

%token ROBOT PLEASE MOVE TURN BLOCKS DEGREES DIRECTION CONNECTOR PUNCT
%token <num> NUMBER DEGREE
%type <num> move_phrase rotate_phrase

%%

structure_sentence:
    requirements sentence
    ;

requirements:
    ROBOT PLEASE
    | PLEASE ROBOT
    ;

sentence:
    complex_verb
    ;

complex_verb:
    verb_phrase
    | verb_phrase optional_comma CONNECTOR sentence
    ;

optional_comma:
    /* nothing */
    | PUNCT
    ;

verb_phrase:
    move_phrase PUNCT
    | move_phrase DIRECTION PUNCT
    | rotate_phrase PUNCT
    ;

move_phrase:
    MOVE NUMBER BLOCKS
    {
        fprintf(output, "MOV,%d\n", $2);
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