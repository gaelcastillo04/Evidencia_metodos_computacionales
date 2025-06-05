### Instrucciones de compilación
- bison -d robot.y
- flex robot.l  
- gcc robot.tab.c lexx.yy.c -o robot_compiler / gcc -o robot lex.yy.c robot.tab.c
- cat instruction.asm
- ./robot archivo.txt > instructions.asm
- python3 cpu.py

