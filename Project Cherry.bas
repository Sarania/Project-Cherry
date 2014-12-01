'Chip 8 Emulator in FreeBASIC
#Include Once "fbgfx.bi"
Using FB
ScreenRes 640,480,32


Type Chip8
	opcode As ushort
	memory(0 To 4095) As Byte
	V0 As Byte
	V1 As Byte
	V2 As Byte
	V3 As Byte
	V4 As Byte
	V5 As Byte
	V6 As Byte
	V7 As Byte
	V8 As Byte
	V9 As Byte
	VA As Byte
	VB As Byte
	VC As Byte
	VD As Byte
	VE As Byte
	VF As Byte
	stack(0 To 15) As UShort
	sp As ushort
	Index As UShort
	PC As uShort
	display(0 To 63,0 To 31) As Byte
	delayTimer As Byte
	soundTimer As Byte
	key(0 To 15) As byte
End Type


Dim Shared As chip8 CPU

Dim Shared As UByte font(0 To 79) => _
 {&hF0, &h90, &h90, &h90, &hF0, _ ' 0 
  &h20, &h60, &h20, &h20, &h70, _ ' 1
  &hF0, &h10, &hF0, &h80, &hF0, _ ' 2
  &hF0, &h10, &hF0, &h10, &hF0, _ ' 3
  &h90, &h90, &hF0, &h10, &h10, _ ' 4
  &hF0, &h80, &hF0, &h10, &hF0, _ ' 5
  &hF0, &h80, &hF0, &h90, &hF0, _ ' 6
  &hF0, &h10, &h20, &h40, &h40, _ ' 7
  &hF0, &h90, &hF0, &h90, &hF0, _ ' 8
  &hF0, &h90, &hF0, &h10, &hF0, _ ' 9
  &hF0, &h90, &hF0, &h90, &h90, _ ' A
  &hE0, &h90, &hE0, &h90, &hE0, _ ' B
  &hF0, &h80, &h80, &h80, &hF0, _ ' C
  &hE0, &h90, &h90, &h90, &hE0, _ ' D
  &hF0, &h80, &hF0, &h80, &hF0, _ ' E
  &hF0, &h80, &hF0, &h80, &h80}   ' F
  
Dim Shared As fb.image Ptr screenbuf

Declare Sub initcpu







Sub initcpu
	For i As Integer = 0 To 4095
		cpu.memory(i) = 0
	Next
	For i As Integer = 0 To 15
		CPU.stack(i) = 0
		CPU.key(i) = 0
	Next
	CPU.V1 = 0
	CPU.V2 = 0
	CPU.V3 = 0
	CPU.V4 = 0
	CPU.V5 = 0
	CPU.V6 = 0
	CPU.V7 = 0
	CPU.V8 = 0
	CPU.V9 = 0
	CPU.VA = 0
	CPU.VB = 0
	CPU.VC = 0
	CPU.VD = 0
	CPU.VE = 0
	CPU.VF = 0
	CPU.sp = 0
	CPU.index = 0
	CPU.PC = &h200
	For y As Integer = 0 To 31
		For x As Integer = 0 To 63
			cpu.display(x,y) = 0
		Next
	Next
	CPU.delaytimer = 0
	CPU.soundtimer = 0
End Sub
