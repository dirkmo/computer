; https://www.masswerk.at/6502/assembler.html
lda #$ef  ; font base $e000, screen base $f000
sta $fa10 ; vga base addresses
ldx #0
loop: lda msg,x
sta $f000,x
inx
bne loop

ende: jmp ende

msg:
.ascii "Hello, World from 6502 CPU"
