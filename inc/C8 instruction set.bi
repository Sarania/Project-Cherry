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
	Dim temp As Integer
	temp = CInt(Right(Str(cpu.opcode),3))
	cpu.pc = temp
End Sub

Sub INS_CALL '2NNN
	
End Sub

Sub INS_SKIPEQUAL '3XKK
	
End Sub

Sub INS_SKIPNOTEQUAL '4XKK
	
End Sub

Sub INS_SKIPEQUALREG '5XY0
	
End Sub

Sub INS_LOADKK '6XKK
	
End Sub

Sub INS_ADDKK '7XKK
	
End Sub

Sub INS_VXEQVY '8XY0
	
End Sub

Sub INS_VXORVY '8XY1
	
End Sub

Sub INS_VXANDVY '8XY2
	
End Sub

Sub INS_VXXORVY '8XY3
	
End Sub

Sub INS_ADC '8XY4
	
End Sub

Sub INS_SUBTRACT '8XY5
	
End Sub

Sub INS_SHIFTR '8XY6
	
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
	
End Sub

Sub INS_KEYWAIT 'FX0A
	
End Sub

Sub INS_DELAYSET 'FX15
	
End Sub

Sub INS_SOUNDSET 'FX18
	
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
