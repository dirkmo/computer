; https://www.masswerk.at/6502/assembler.html
ldx #0
loop: lda msg,x
sta $f000,x
inx
bne loop

ende: jmp ende

msg:
.ascii "Hello, World from CPU"
