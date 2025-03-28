#include "textflag.h"

TEXT ·euclideanAVX2(SB),NOSPLIT,$0
	MOVQ aptr+0(FP), AX
	MOVQ bptr+8(FP), BX
	MOVQ l+16(FP), CX
	MOVQ result+24(FP), DX
	VMOVUPS (DX), Y2

start:
	VMOVUPS (AX), Y0
	VMOVUPS (BX), Y1
	VSUBPS Y0, Y1, Y0
	VMULPS Y0, Y0, Y0
	VADDPS Y2, Y0, Y2

	ADDQ $32, AX
	ADDQ $32, BX
	DECQ CX
	JNZ start

	VMOVUPS Y2, (DX)
	RET
