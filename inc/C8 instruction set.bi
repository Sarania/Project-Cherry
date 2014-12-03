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
Declare Sub INS_SCROLLN '00CN
Sub INS_CLS '00E0
	For y As Integer = 0 To 31
		For x As Integer = 0 To 63
			cpu.display(x,y) = 0
		Next
	Next
	cpu.drawflag=1
End Sub

Sub INS_RET '00EE
	
	cpu.pc = cpu.stack(cpu.sp)
	cpu.stack(cpu.sp) = 0
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
cpu.v(vx) Or = cpu.v(vy)
End Sub

Sub INS_VXANDVY '8XY2
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) And = cpu.v(vy)
	
End Sub

Sub INS_VXXORVY '8XY3
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
cpu.v(vx) Xor = cpu.v(vy)
End Sub

Sub INS_ADC '8XY4
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
If cpu.v(vx) + cpu.v(vy) > 255 Then cpu.v(&hF) = 1 Else cpu.v(&hF) = 0
'If cpu.v(vy) > (&hff - cpu.v(vx)) Then cpu.v(&hf) = 1 Else cpu.v(&hf)=0
cpu.v(vx) = cpu.v(vx) + cpu.v(vy)
End Sub

Sub INS_SUBTRACT '8XY5
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
If cpu.v(vx) >= cpu.v(vy) Then cpu.v(&Hf) = 1 Else cpu.v(&hF) = 0
cpu.v(vx) -= cpu.v(vy)
End Sub

Sub INS_SHIFTR '8XY6
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If Bit(cpu.v(vx),1) Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
cpu.v(vx) = cpu.v(vx) Shr 1
End Sub

Sub INS_SUBN '8XY7
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
If cpu.v(vy) >= cpu.v(vx) Then cpu.v(&Hf) = 1 Else cpu.v(&hF) = 0
cpu.v(vx) = cpu.v(vy) - cpu.v(vx)
End Sub

Sub INS_SHIFTL '8XYE
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If Bit(cpu.v(vx),7) Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
cpu.v(vx) = cpu.v(vx) Shl 1
End Sub

Sub INS_SKIPNOTEQUALREG '9XY0
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
If cpu.v(vx) <> cpu.v(vy) Then cpu.pc+=2
	
End Sub

Sub INS_LOADINDEX 'ANNN
	cpu.index = cpu.opcode And &h0fff
End Sub

Sub INS_JUMPREG 'BNNN
	cpu.pc = (cpu.opcode And &h0FFF) +cpu.v(0)
End Sub

Sub INS_RNDANDKK 'CXKK
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
KK = cpu.opcode And &h00FF
cpu.v(vx) = (CByte(Rnd*255)) And kk
End Sub

Sub INS_DISPLAY 'DXYN
Dim n As UShort
Dim p As ushort
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
vy = cpu.opcode And &h00F0
vy = vy Shr 4
n = cpu.opcode And &h000F
cpu.v(&hf) = 0

For y As Integer = 0 To n-1
	p = cpu.memory(cpu.index+y)
	For x As Integer = 0 To 7
		If (p And (&h80 Shr x)) <> 0 Then
			If cpu.display(cpu.v(vx)+x, cpu.v(vy)+y) = 1 then
				cpu.v(&hf) = 1
			EndIf
			cpu.display(cpu.v(vx)+x,cpu.v(vy)+y) Xor = 1
		EndIf	
	Next
Next
	cpu.drawflag=1
End Sub

Sub INS_KEYSKIP 'EX9E
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If cpu.key(cpu.v(vx)) <> 0 Then cpu.pc+=2
End Sub

Sub INS_KEYNOTSKIP 'EXA1
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If cpu.key(cpu.v(vx)) = 0 Then cpu.pc+=2
End Sub

Sub INS_VXDELAY 'FX07
	vx = cpu.opcode And &h0f00
	vx = vx Shr 8
	cpu.V(vx) = cpu.delayTimer
End Sub

Sub INS_KEYWAIT 'FX0A
	Do
		keycheck
		For i As Integer = 0 To 15
			If cpu.key(i) <> 0 Then Exit do
		Next
		Sleep 15
	Loop
End Sub

Sub INS_DELAYSET 'FX15
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
cpu.delaytimer = cpu.v(vx)
End Sub

Sub INS_SOUNDSET 'FX18
	vx = cpu.opcode And &h0F00
	cpu.soundTimer = cpu.V(vx)
End Sub

Sub INS_IPLUSVX 'FX1E
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
If cpu.index + cpu.v(vx) > &hFFF Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
cpu.index = cpu.index + cpu.v(vx)
End Sub

Sub INS_ISPRITE 'FX29
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
cpu.index = (cpu.v(vx)*5)
cpu.drawflag=1
End Sub

Sub INS_BCDSTORE 'FX33
Dim As string hundreds, tens, ones
Dim As integer temp
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
temp = cpu.v(vx)
If temp > 99 Then hundreds = Left(Str(temp),1)
ones = right(Str(temp),1)
If temp > 9 Then tens = Left(Right(Str(temp),2),1)
cpu.memory(cpu.index) = CInt(hundreds)
cpu.memory(cpu.index+1) = CInt(tens)
cpu.memory(cpu.index+2) = CInt(ones)
End Sub

Sub INS_STOREREG 'FX55
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
	For I As Integer = 0 To vx
		cpu.memory(cpu.index + i) = cpu.v(i)
	Next
	cpu.index+= vx+1
End Sub

Sub INS_LOADREG 'FX65
Vx = cpu.opcode and &H0F00
Vx = vx Shr 8
	For i As Integer = 0 To vx
		cpu.v(i) = cpu.memory(cpu.index+i)
	Next
	cpu.index+= vx+1
End Sub
Sub INS_SCROLLN '00CN
	
End Sub

Sub INS_RIGHTSCR '00FB
	
End Sub

Sub INS_LEFTSCR '00FC
	
End Sub

Sub INS_EXCHIP '00FD
	
End Sub
Sub INS_DISEXT '00FE
	
End Sub
Sub INS_ENEXT  '00FF
	
End Sub
Sub INS_TENSPRITE 'FX30
	
End Sub
Sub INS_STORERPL 'FX75
	
End Sub
Sub INS_READRPL 'FX85
	
End Sub
