%{
#include "robot.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%
"Robot"               { return SUBJECT; }
"robot"               { return SUBJECT; }
"Please"              { return COURTESY_WORD; }
"please"              { return COURTESY_WORD; }
"move"                { return MOVE; }
"turn"                { return TURN; }
[1-9]+                { yylval.num = atoi(yytext); return NUMBER; }
90                    { yylval.num = atoi(yytext); return DEGREE; }
180                   { yylval.num = atoi(yytext); return DEGREE; }
270                   { yylval.num = atoi(yytext); return DEGREE; }
360                   { yylval.num = atoi(yytext); return DEGREE; }
"blocks"              { return BLOCKS; }
"block"               { return BLOCKS; }
"degrees"             { return DEGREES; }
"ahead"               { return DIRECTION; }
"forward"             { return DIRECTION; }
"backwards"           { return BACKWARD; }
"backward"            { return BACKWARD; }
"and then"            { return CONNECTOR; }
"then"                { return CONNECTOR; }
"next"                { return CONNECTOR; }
"and finally"         { return CONNECTOR; }
","                   { return COMMA; }
"."                   { return DOT; }
[ \t\n]+              { /* skip espacios vacios */ }
.                     { printf("Illegal character: %s\n", yytext); return -1; }

%%