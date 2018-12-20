; Shift left Int 32
shiftl32	.macro
			asl \1
			rol \1 + 1
			rol \1 + 2
			rol \1 + 3
			.endm

zero32		.macro
			pha
			lda #0
			sta \1
			sta \1 + 1
			sta \1 + 2
			sta \1 + 3
			pla
			.endm

add32		.macro
			pha
			clc
			lda \1
			adc \2
			sta \1
			lda \1 + 1
			adc \2 + 1
			sta \1 + 1
			lda \1 + 2
			adc \2 + 2
			sta \1 + 2
			lda \1 + 3
			adc \2 + 3
			sta \1 + 3
			pla
			.endm

; Multiple by 10
multi10		.macro
			pha
			lda \1 + 3
			pha
			lda \1 + 2
			pha
			lda \1 + 1
			pha
			lda \1
			pha
			
			#shiftl32 \1
			#shiftl32 \1
			
			clc
			pla
			adc \1
			sta \1
			pla
			adc \1 + 1
			sta \1 + 1
			pla
			adc \1 + 2
			sta \1 + 2
			pla
			adc \1 + 3
			sta \1 + 3
			
			#shiftl32 \1
			pla
			.endm

; Invert sign of Int 32
invert32	.macro
			pha
			
			lda \1
			eor #$ff
			sta \1
			lda \1 + 1
			eor #$ff
			sta \1 + 1
			lda \1 + 2
			eor #$ff
			sta \1 + 2
			lda \1 + 3
			eor #$ff
			sta \1 + 3
			
			clc
			lda \1
			adc #1
			sta \1
			lda \1 + 1
			adc #0
			sta \1 + 1
			lda \1 + 2
			adc #0
			sta \1 + 2
			lda \1 + 3
			adc #0
			sta \1 + 3
			pla
			.endm