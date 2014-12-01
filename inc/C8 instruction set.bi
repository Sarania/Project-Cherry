Declare Sub INS_CLS '00E0
Declare Sub INS_RET '00EE
Declare Sub INS_JMP '1NNN
Declare Sub INS_CALL '2NNN
Declare Sub INS_SKIPEQUAL '3XKK
Declare Sub INS_SKIPNOTEQUAL '4XKK
Declare Sub INS_SKIPEQUALREG '5XY0
Declare Sub INS_LOADKK '6XKK
Declare Sub INS_ADDKK '7XKK
Declare Sub INS_VXEQVY '8XY0
Declare Sub INS_VXORVY '8XY1
Declare Sub INS_VXANDVY '8XY2
Declare Sub INS_VXXORVY '8XY3
Declare Sub INS_ADC '8XY4
Declare Sub INS_SUBTRACT '8XY5
Declare Sub INS_SHIFTR '8XY6
Declare Sub INS_SUBN '8XY7
Declare Sub INS_SHIFTL '8XYE
Declare Sub INS_SKIPNOTEQUALREG '9XY0
Declare Sub INS_LOADINDEX 'ANNN
Declare Sub INS_JUMPREG 'BNNN
Declare Sub INS_RNDANDKK 'CXKK
Declare Sub INS_DISPLAY 'DXYN
Declare Sub INS_KEYSKIP 'EX9E
Declare Sub INS_KEYNOTSKIP 'EXA1
Declare Sub INS_VXDELAY 'FX07
Declare Sub INS_KEYWAIT 'FX0A
Declare Sub INS_DELAYSET 'FX15
Declare Sub INS_SOUNDSET 'FX18
Declare Sub INS_IPLUSVX 'FX1E
Declare Sub INS_ISPRITE 'FX29
Declare Sub INS_BCDSTORE 'FX33
Declare Sub INS_STOREREG 'FX55
Declare Sub INS_LOADREG 'FX65

Sub INS_CLS '00E0
	For y As Integer = 0 To 31
		For x As Integer = 0 To 63
			cpu.display(x,y) = 0
		Next
		Next
End Sub

Sub INS_RET '00EE
	cpu.pc = cpu.stack(cpu.sp)
	cpu.sp-=1
End Sub

Sub INS_JMP '1NNN
	cpu.pc = cpu.opcode And &h0FFF
End Sub

Sub INS_CALL '2NNN
	cpu.sp+=1
	cpu.stack(cpu.sp)=cpu.pc
   cpu.pc = cpu.opcode And &h0FFF
End Sub

Sub INS_SKIPEQUAL '3XKK
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
KK = cpu.opcode And &h00FF
If cpu.v(vx) = kk Then cpu.pc+=2
End Sub

Sub INS_SKIPNOTEQUAL '4XKK
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
KK = cpu.opcode And &h00FF
If cpu.v(vx) <> kk Then cpu.pc+=2
End Sub

Sub INS_SKIPEQUALREG '5XY0
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
If cpu.v(vx) = cpu.v(vy) Then cpu.pc+=2
End Sub

Sub INS_LOADKK '6XKK
	Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
KK = cpu.opcode And &h00FF
cpu.v(vx) = KK
End Sub


Sub INS_ADDKK '7XKK
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
KK = cpu.opcode And &h00FF
cpu.v(vx) = cpu.v(vx)+kk
End Sub

Sub INS_VXEQVY '8XY0
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) = cpu.v(vy)
End Sub

Sub INS_VXORVY '8XY1
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) = cpu.v(vx) Or cpu.v(vy)
End Sub

Sub INS_VXANDVY '8XY2
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) = cpu.v(vx) And cpu.v(vy)
	
End Sub

Sub INS_VXXORVY '8XY3
	Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) = cpu.v(vx) Xor cpu.v(vy)
	
End Sub

Sub INS_ADC '8XY4
	
End Sub

Sub INS_SUBTRACT '8XY5
	
End Sub

Sub INS_SHIFTR '8XY6
	Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If cpu.v(vx) Shl 8 = 1 Then cpu.V(&hF) = 1 Else cpu.V(&hF) = 0
cpu.v(vx) /= 2
End Sub

Sub INS_SUBN '8XY7
	
End Sub

Sub INS_SHIFTL '8XYE
	
End Sub

Sub INS_SKIPNOTEQUALREG '9XY0
	
End Sub

Sub INS_LOADINDEX 'ANNN
	
End Sub

Sub INS_JUMPREG 'BNNN
	Dim btemp As UShort
	btemp = (cpu.opcode And &h0FFF) +cpu.v(0)
	cpu.pc = btemp
End Sub

Sub INS_RNDANDKK 'CXKK
	
End Sub

Sub INS_DISPLAY 'DXYN
	
End Sub

Sub INS_KEYSKIP 'EX9E
	
End Sub

Sub INS_KEYNOTSKIP 'EXA1
	
End Sub

Sub INS_VXDELAY 'FX07
	vx = cpu.opcode And &h0f00
	cpu.V(vx) = cpu.delayTimer
End Sub

Sub INS_KEYWAIT 'FX0A
	
End Sub

Sub INS_DELAYSET 'FX15
	
End Sub

Sub INS_SOUNDSET 'FX18
	vx = cpu.opcode And &h0F00
	cpu.soundTimer = cpu.V(vx)
End Sub

Sub INS_IPLUSVX 'FX1E
	
End Sub

Sub INS_ISPRITE 'FX29
	
End Sub

Sub INS_BCDSTORE 'FX33
	
End Sub

Sub INS_STOREREG 'FX55
	
End Sub

Sub INS_LOADREG 'FX65
	
End Sub
