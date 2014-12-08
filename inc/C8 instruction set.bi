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
Declare Sub INS_HIRES 'F800

Sub INS_HIRES 'F800
	cpu.mode = "CHIP-8 HIRES"
	cpu.xres = 63
	cpu.yres = 63
	ReDim Preserve display(0 To cpu.xres, 0 To cpu.yres)
	sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
	sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
	cpu.pc = &h2c0
	If colorlines Then colorit
End Sub
Sub INS_CLS '00E0
	For y As Integer = 0 To cpu.yres
		For x As Integer = 0 To cpu.xres
			display(x,y) = 0
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
	KK = cpu.opcode And &h00FF
	If cpu.v(vx) = kk Then cpu.pc+=2
End Sub

Sub INS_SKIPNOTEQUAL '4XKK
	KK = cpu.opcode And &h00FF
	If cpu.v(vx) <> kk Then cpu.pc+=2
End Sub

Sub INS_SKIPEQUALREG '5XY0
	vy = cpu.opcode And &h00F0
	vy = vy Shr 4
	If cpu.v(vx) = cpu.v(vy) Then cpu.pc+=2
End Sub

Sub INS_LOADKK '6XKK
	KK = cpu.opcode And &h00FF
	cpu.v(vx) = KK
End Sub


Sub INS_ADDKK '7XKK
	KK = cpu.opcode And &h00FF
	cpu.v(vx)+= kk
End Sub

Sub INS_VXEQVY '8XY0
	cpu.v(vx) = cpu.v(vy)
End Sub

Sub INS_VXORVY '8XY1
	cpu.v(vx) Or = cpu.v(vy)
End Sub

Sub INS_VXANDVY '8XY2
	cpu.v(vx) And = cpu.v(vy)

End Sub

Sub INS_VXXORVY '8XY3
	cpu.v(vx) Xor = cpu.v(vy)
End Sub

Sub INS_ADC '8XY4
	If cpu.v(vx) + cpu.v(vy) > 255 Then cpu.v(&hF) = 1 Else cpu.v(&hF) = 0
	cpu.v(vx) = cpu.v(vx) + cpu.v(vy)
End Sub

Sub INS_SUBTRACT '8XY5
	If cpu.v(vx) >= cpu.v(vy) Then cpu.v(&Hf) = 1 Else cpu.v(&hF) = 0
	cpu.v(vx) -= cpu.v(vy)
End Sub

Sub INS_SHIFTR '8XY6
	If Bit(cpu.v(vx),1) Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
	cpu.v(vx) = cpu.v(vx) Shr 1
End Sub

Sub INS_SUBN '8XY7
	If cpu.v(vy) >= cpu.v(vx) Then cpu.v(&Hf) = 1 Else cpu.v(&hF) = 0
	cpu.v(vx) = cpu.v(vy) - cpu.v(vx)
End Sub

Sub INS_SHIFTL '8XYE
	If Bit(cpu.v(vx),7) Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
	cpu.v(vx) = cpu.v(vx) Shl 1
End Sub

Sub INS_SKIPNOTEQUALREG '9XY0
	If cpu.v(vx) <> cpu.v(vy) Then cpu.pc+=2
End Sub

Sub INS_LOADINDEX 'ANNN
	cpu.index = cpu.opcode And &h0fff
End Sub

Sub INS_JUMPREG 'BNNN
	cpu.pc = (cpu.opcode And &h0FFF) +cpu.v(0)
End Sub

Sub INS_RNDANDKK 'CXKK
	KK = cpu.opcode And &h00FF
	cpu.v(vx) = (CByte(Rnd*255)) And kk
End Sub

Sub INS_DISPLAY 'DXYN
	Dim n As UShort
	Dim p As UShort
	Dim p2 As UShort
	Dim q As UByte = 0
	n = cpu.opcode And &h000F
	cpu.v(&hf) = 0
	If n = 0 Then n = 16
	If n < 16 Or cpu.mode = "CHIP-8" Then ' normal sprite
		For y As Integer = 0 To n-1
			p = cpu.memory(cpu.index+y)
			For x As Integer = 0 To 7
				If (p And (&h80 Shr x)) <> 0 Then
					If display((cpu.v(vx)+x) Mod (cpu.xres+1), (cpu.v(vy)+y) Mod (cpu.yres+1)) = 1 then
						cpu.v(&hf) = 1
					EndIf
					display((cpu.v(vx)+x) Mod (cpu.xres+1),(cpu.v(vy)+y) Mod (cpu.yres+1)) Xor = 1 ' XOR the pixel onto the screen. If a pixel was already on, it gets turned off
				EndIf
			Next
		Next
	End If

	If n = 16 And cpu.mode <> "CHIP-8" Then '16x16 sprite. More complicated. This took forever to figure out!
		For y As Integer = 0 To 15
			p = cpu.memory(cpu.index+q)
			p2 = cpu.memory(cpu.index+q+1)
			For x As Integer = 0 To 15
				If (p Shl 8 + p2 And (&h8000 Shr x)) then
					If display((cpu.v(vx)+x+1) Mod (cpu.xres+1), (cpu.v(vy)+y) Mod (cpu.yres+1)) = 1 then
						cpu.v(&hf) = 1
					EndIf
					display((cpu.v(vx)+x+1) Mod (cpu.xres+1),(cpu.v(vy)+y) Mod (cpu.yres+1)) Xor = 1 ' XOR the pixel onto the screen. If a pixel was already on, it gets turned off
				EndIf
			Next
			q+=2
		Next
	EndIf
	cpu.drawflag=1
End Sub

Sub INS_KEYSKIP 'EX9E
	If cpu.key(cpu.v(vx)) <> 0 Then cpu.pc+=2
End Sub

Sub INS_KEYNOTSKIP 'EXA1
	If cpu.key(cpu.v(vx)) = 0 Then cpu.pc+=2
End Sub

Sub INS_VXDELAY 'FX07
	cpu.V(vx) = cpu.delayTimer
End Sub

Sub INS_KEYWAIT 'FX0A
	Do
		keycheck
		For i As Integer = 0 To 15
			If cpu.key(i) <> 0 Then
				cpu.v(vx) = i
				Exit Do
			EndIf
		Next
		Sleep 15
	Loop
End Sub

Sub INS_DELAYSET 'FX15
	cpu.delaytimer = cpu.v(vx)
End Sub

Sub INS_SOUNDSET 'FX18
	cpu.soundTimer = cpu.V(vx)
End Sub

Sub INS_IPLUSVX 'FX1E
	If cpu.index + cpu.v(vx) > &hFFF Then cpu.v(&hf) = 1 Else cpu.v(&hf) = 0
	cpu.index = cpu.index + cpu.v(vx)
End Sub

Sub INS_ISPRITE 'FX29
	cpu.index = (cpu.v(vx)*5)
	cpu.drawflag=1
End Sub

Sub INS_BCDSTORE 'FX33
	Dim As string hundreds, tens, ones
	Dim As integer temp
	temp = cpu.v(vx)
	If temp > 99 Then hundreds = Left(Str(temp),1)
	ones = right(Str(temp),1)
	If temp > 9 Then tens = Left(Right(Str(temp),2),1)
	cpu.memory(cpu.index) = CInt(hundreds)
	cpu.memory(cpu.index+1) = CInt(tens)
	cpu.memory(cpu.index+2) = CInt(ones)
End Sub

Sub INS_STOREREG 'FX55
	For I As Integer = 0 To vx
		cpu.memory(cpu.index + i) = cpu.v(i)
	Next
	'cpu.index+= vx+1
End Sub

Sub INS_LOADREG 'FX65
	For i As Integer = 0 To vx
		cpu.v(i) = cpu.memory(cpu.index+i)
	Next
	'cpu.index+= vx+1
End Sub
Sub INS_SCROLLN '00CN
	Dim As UByte N
	n = cpu.opcode And &h000F
	For i As Integer = 1 To N
		For y As Integer = cpu.yres To 0 Step -1
			For x As Integer = 0 To cpu.xres
				display(x,y) = display (x,y-1)
			Next
		Next
		cpu.drawflag = 1
	Next
End Sub

Sub INS_RIGHTSCR '00FB

	For y As Integer = 0 To cpu.yres
		For x As Integer = cpu.xres To 4 Step -1
			display(x,y) = display (x-4,y)
		Next
		For x As Integer = 3 to 0 Step -1
			display(x,y) = 0
		Next
	Next
	cpu.drawflag = 1
End Sub

Sub INS_LEFTSCR '00FC
	For y As Integer = 0 To cpu.yres
		For x As Integer = 0 To cpu.xres-4
			display(x,y) = display (x+4,y)
		Next
		For x As Integer = cpu.xres-3 To cpu.xres
			display(x,y) = 0
		Next
	Next
	cpu.drawflag = 1
End Sub

Sub INS_EXCHIP '00FD
	CAE
End Sub
Sub INS_DISEXT '00FE
	cpu.mode = "CHIP-8"
	cpu.xres = 63
	cpu.yres = 31
	ReDim Preserve display(0 To cpu.xres, 0 To cpu.yres)
	sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
	sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
	If colorlines Then colorit
End Sub
Sub INS_ENEXT  '00FF
	cpu.mode = "SCHIP"
	cpu.xres = 127
	cpu.yres = 63
	ReDim Preserve display(0 To cpu.xres, 0 To cpu.yres)
	sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
	sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
	If colorlines Then colorit
	ops*=2
	start = timer
	cpu.opcount = 0
End Sub
Sub INS_TENSPRITE 'FX30
	cpu.index = (cpu.v(vx)*10)+80
	cpu.drawflag=1
End Sub

Sub INS_STORERPL 'FX75
	For i As Integer = 0 To vx
		cpu.hp48(i) = cpu.V(i)
	Next
End Sub
Sub INS_READRPL 'FX85
	For i As Integer = 0 To vx
		cpu.V(i) = cpu.hp48(i)
	next
End Sub
Sub INS_DISMEGAMODE
		cpu.mode = "CHIP-8"
	cpu.xres = 63
	cpu.yres = 31
	ReDim Preserve display(0 To cpu.xres, 0 To cpu.yres)
	sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
	sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
	If colorlines Then colorit
End Sub
Sub INS_ENMEGAMODE
	cpu.xres = 255
	cpu.yres = 192
	ReDim Preserve display(0 To cpu.xres, 0 To cpu.yres)
	sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
	sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
	ops*=2
	start = timer
	cpu.opcount = 0
End Sub
Sub INS_LHDI
	
End Sub
Sub INS_LOADCOLORS
	
End Sub
Sub INS_SPRITEWIDTH
	
End Sub
Sub INS_SPRITEHEIGHT
	
End Sub
Sub INS_SETALPHA
	
End Sub
Sub INS_PLAYSOUND
	
End Sub
Sub INS_STOPSOUND
	
End Sub
Sub INS_BLENDMODE
	
End Sub
Sub INS_SCROLLND
	Dim As UByte N
	n = cpu.opcode And &h000F
	For i As Integer = 1 To N
		For y As Integer = 63 To 0 Step +1
			For x As Integer = 0 To 127
				display(x,y) = display (x,y+1)
			Next
		Next
		cpu.drawflag = 1
		render
	Next
End Sub