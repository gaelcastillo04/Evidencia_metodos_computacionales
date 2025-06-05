# 📄 Evidencia

En esta práctica, se busca desarrollar una pequeña interfaz de lenguaje natural controlado para emitir comandos a un robot virtual. Este robot es capaz de realizar acciones simples como moverse, girar y detenerse. Las instrucciones deben seguir una estructura clara, amable y definida, similar a cómo una persona se dirigía educadamente a un asistente robótico.  
El objetivo principal es contruir el analizador léxico (Lex) y un analizador sintáctico (YACC) capaces de procesar y validar un conjunto restringido de isntrucciones escritas en lenguaje natural simple.

---

## 🔍 Analizador léxico (LEX)

El analizador léxico tiene la tarea de leer una entrada que contiene instrucciones destinadas a un robot y desglosarla en unidades léxicas de importancia denominadas *tokens*. Estas unidades facilitarán al compilador la comprensión de los diferentes elementos de las frases, tales como:

- *Sustantivos*: indican entidades o elementos del entorno del robot (ej. "Robot", "blocks", "degrees").  
- *Verbos*: describen las acciones que el robot puede ejecutar (ej. "move", "turn", "stop").  
- *Palabras de cortesía*: ayudan a que las instrucciones sean más "humanas" y amables (ej. "please", "thank you").  
- *Números*: representan cantidades ({1-10}, {90, 180, 270, 360}).  
- *Conectores y preposiciones*: indican orden o dirección (ej. "and", "then", "ahead", "right").  

El analizador léxico debe tener la habilidad de identificar estas categorías, pasar por alto espacios o tabulaciones, y *informar sobre cualquier símbolo no identificado como error*.

---

### 📌 Definición de tokens

### ✅ Lista de ejemplos aceptados:

- Robot please move 3 blocks ahead, and then turn 90 degrees.  
- Please robot move 3 blocks, and then turn 360 degrees.  
- Robot please move 3 blocks ahead and then turn 90 degrees, then move 2 blocks  

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
