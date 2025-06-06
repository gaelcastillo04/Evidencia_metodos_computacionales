# 📄 Evidencia

En esta práctica, se busca desarrollar una pequeña interfaz de lenguaje natural controlado para emitir comandos a un robot virtual. Este robot es capaz de realizar acciones simples como moverse, girar y detenerse. Las instrucciones deben seguir una estructura clara, amable y definida, similar a cómo una persona se dirigía educadamente a un asistente robótico.  
El objetivo principal es contruir el analizador léxico (Lex) y un analizador sintáctico (YACC) capaces de procesar y validar un conjunto restringido de isntrucciones escritas en lenguaje natural simple.

---

## 🔍 Analizador léxico (LEX)

El analizador léxico tiene la tarea de leer una entrada que contiene instrucciones destinadas a un robot y desglosarla en unidades léxicas de importancia denominadas *tokens*. Estas unidades facilitarán al compilador la comprensión de los diferentes elementos de las frases, tales como:

- *Sustantivos*: indican entidades o elementos del entorno del robot (ej. "Robot", "blocks", "degrees").  
- *Verbos*: describen las acciones que el robot puede ejecutar (ej. "move", "turn").  
- *Palabras de cortesía*: ayudan a que las instrucciones sean más "humanas" y amables (ej. "please").  
- *Números*: representan cantidades ({1-10}, {90, 180, 270, 360}).  
- *Conectores y preposiciones*: indican orden o dirección (ej. "and", "then", "ahead", "forward", "backwards").  

El analizador léxico debe tener la habilidad de identificar estas categorías, pasar por alto espacios o tabulaciones, y *informar sobre cualquier símbolo no identificado como error*.

---

### 📌 Definición de tokens

- "Robot"               { return SUBJECT; }
- "robot"               { return SUBJECT; }
- "Please"              { return COURTESY_WORD; }
- "please"              { return COURTESY_WORD; }
- "move"                { return MOVE; }
- "turn"                { return TURN; }
- [1-9]+                { yylval.num = atoi(yytext); return NUMBER; }
- 90                    { yylval.num = atoi(yytext); return DEGREE; }
- 180                   { yylval.num = atoi(yytext); return DEGREE; }
- 270                   { yylval.num = atoi(yytext); return DEGREE; }
- 360                   { yylval.num = atoi(yytext); return DEGREE; }
- "blocks"              { return BLOCKS; }
- "block"               { return BLOCKS; }
- "degrees"             { return DEGREES; }
- "ahead"               { return DIRECTION; }
- "forward"             { return DIRECTION; }
- "backwards"           { return BACKWARD; }
- "backward"            { return BACKWARD; }
- "and then"            { return CONNECTOR; }
- "then"                { return CONNECTOR; }
- "next"                { return CONNECTOR; }
- "and finally"         { return CONNECTOR; }
- ","                   { return COMMA; }
- "."                   { return DOT; }
- [ \t\n]+              { /* skip espacios vacios */ }
- .                     { printf("Illegal character: %s\n", yytext); return -1; }


### ✅ Lista de ejemplos aceptados:

- Robot please move 3 blocks ahead, and then turn 90 degrees.  
- Please robot move 3 blocks, and then turn 360 degrees.  
- Robot please move 3 blocks ahead and then turn 90 degrees, then move 2 blocks.  

### ❌ Ejemplos rechazados:

- Robot turn 80 degrees  
- Robot please move 8 blocks now.  
- Robot please turn 78 degrees  

---

## 🧠 Analizador sintáctico (YACC)

El analizador sintáctico necesita emplear los tokens suministrados por Lex para verificar si la secuencia de instrucciones satisface la gramática prevista. El objetivo es establecer una *gramática libre de contexto (CFG) no ambigua*, que facilite la identificación únicamente de aquellas frases que constituyan instrucciones válidas para el robot.

Las frases válidas deben satisfacer las siguientes propiedades:

- Iniciar siempre con la palabra "Robot".  
- Usar formas educadas o directas pero correctas (como "please move", "turn", "stop").  
- Incluir información suficiente sobre la acción: qué hacer, cuántos bloques avanzar, cuántos grados girar, etc. Cabe aclarar que deben de ser los números dentro del rango de lo que se pide.  

En cambio, el sistema debe tener la habilidad de *descartar frases ambiguas, incompletas o incorrectas*, como las que alteren el orden de las palabras, empleen términos no identificados o muestren una sintaxis confusa.

---

### 📐 Definición de CFG

La gramática desarrollada está orientada al análisis sintáctico de instrucciones en lenguaje natural controlado, dirigidas a un robot virtual. Estas instrucciones deben ser educadas, estructuradas y comprensibles para un compilador. El objetivo es traducir frases simples como “Please move 3 blocks forward.” en instrucciones de máquina tipo ensamblador.
La gramática está escrita en YACC y define la estructura válida de las oraciones que puede entender el robot, asegurando:

- Uso de expresiones de cortesía (please) en la instrucción.
- Comandos compuestos como secuencias de movimientos y giros.
- Traducción a instrucciones técnicas (MOV, TURN).
- Validación del orden y número de componentes en cada frase.

### Reglas clave en nuestra gramatica
- Cada oración debe iniciar o finalizar con la palabra "please" (regla de cortesía).
- Las frases pueden contener conectores como "then", "and then", etc.
- Soporta movimientos hacia adelante y hacia atrás, así como giros en grados (permitiendo solo grados como: 90,180,270,360).
- Cada instrucción o oración se finaliza con un punto (.) como delimitador.



### ✅ Lista de ejemplos aceptados:

- please move 3 blocks ahead. Robot please turn 90 degrees and then move 3 blocks. 
- Robot please turn 90 degrees and then move 3 blocks ahead.
- Robot move 4 blocks backward, then turn 90 degrees and finally move 3 blocks ahead please.

### ❌ Ejemplos rechazados:

- please robot move 3 blocks. Robot turn 90 degrees. 
- Robot please move 8 blocks and then turn 270 degrees and finally move backwards
- Robot please turn 78 degrees and then move 3 blocks.

---


```bnf
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
