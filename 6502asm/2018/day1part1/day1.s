CHKIN = $FFC6
CHRIN = $FFCF
CHROUT = $FFD2
CLOSE = $FFC3
CLRCH = $FFCC
OPEN = $FFC0
SETNAM = $FFBD
SETLFS = $FFBA

CR = $0d
DEVICE = 8
CHANNEL = 3

.include "macros.s"

current = $2000
value = current + 4
count = value + 4
fnamelen = count + 4
fname = fnamelen + 1


; BASIC COMMAND - SYS 4096
*=$0801
.byte $0c, $08, $0a, $00, $9e, $20
.byte $34, $30, $39, $36, $00, $00
.byte $00

* = $1000
main
.block
	jsr readfname
	jsr readfile
	lda #CR
	jsr CHROUT
	jsr printdec
	rts
.bend

;
sprint   stx sprint01+1        ;save string pointer LSB
         sty sprint01+2        ;save string pointer MSB
         ldy #0                ;starting string index
;
sprint01 lda $1000,y           ;get a character
         beq sprint02          ;end of string
;
         jsr CHROUT            ;print character
         iny                   ;next
         bne sprint01
;
sprint02 rts                   ;exit

readfname
.block
		; Print message
		ldx #<fnamemsg
		ldy #>fnamemsg
		jsr sprint
	
		; Read filename
		ldy #$00
RD 		jsr CHRIN
		sta fname,Y
		iny
		cmp #CR
		bne RD
		dey
		lda #0
		sta fname,Y
		sty fnamelen
		rts
.bend

readint32
.block
		; Clear the current value
		#zero32 current
	
loop	jsr CHRIN			; Call Kernal routine CHRIN
		cmp #CR				; Check if carriage return
		beq end
		cmp 0
		beq end
	
		; Multiple the current value by 10
		#multi10 current				
	
		; Convert from ASCII to int byte
		sec
		sbc #$30
		
		; Add to the current value
		clc
		adc current
		sta current
		lda current + 1
		adc #$00
		sta current + 1
		lda current + 2
		adc #$00
		sta current + 2
		lda current + 3
		adc #$00
		sta current + 3
		
		jmp loop
		
end		rts
.bend

readline
.block
	jsr CHRIN			; Call Kernal routine CHRIN
	cmp #$2d			; Check if minus char
	beq neg
	cmp #$2b
	beq pos
	lda #$ff
	rts	
pos
	jsr readint32
	lda #0
	rts
neg
	jsr readint32
	#invert32 current
	lda #0
	rts
.bend

readfile
.block
		#zero32 value
		#zero32 count

		; Open file
		lda fnamelen
		ldx #<fname
		ldy #>fname
		jsr SETNAM
		lda #CHANNEL
		ldx #DEVICE
		ldy #CHANNEL
		jsr SETLFS
		jsr OPEN
		ldx #CHANNEL
		jsr CHKIN
		
loop	jsr readline
		cmp #0
		bne end
		#add32 count, one32
		#add32 value, current
		jmp loop
end

		lda #CHANNEL
		jsr CLOSE
		jsr CLRCH
		rts
.bend

; prints a 32 bit value to the screen
printdec
.block
		lda value + 3
		asl a
		bcc pos
		lda #$2d
		jsr CHROUT
		#invert32 value
pos     jsr hex2dec

        ldx #9
l1      lda result,x
        bne l2
        dex             ; skip leading zeros
        bne l1

l2      lda result,x
        ora #$30
        jsr CHROUT
        dex
        bpl l2
        rts
.bend

        ; converts 10 digits (32 bit values have max. 10 decimal digits)
hex2dec
.block
        ldx #0
l3      jsr div10
        sta result,x
        inx
        cpx #10
        bne l3
        rts

        ; divides a 32 bit value by 10
        ; remainder is returned in akku
div10
        ldy #32         ; 32 bits
        lda #0
        clc
l4      rol
        cmp #10
        bcc skip
        sbc #10
skip    rol value
        rol value+1
        rol value+2
        rol value+3
        dey
        bpl l4
        rts
.bend

result  .byte 0,0,0,0,0,0,0,0,0,0

one32	.byte $01, $00, $00, $00
fnamemsg .null "enter input filename: -"
resultmsg .null "{cr}result: "
