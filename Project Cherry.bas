'Chip 8 Emulator in FreeBASIC
#Include Once "fbgfx.bi"
Using FB
#Include Once "file.bi"

Type Chip8
	opcount As ulongint
	instruction As String
	opcode As UShort
	opcodePTR As UShort Pointer
	memory(0 To 4095) As UByte
	V(0 To 15) As UByte
	stack(0 To 15) As UShort
	sp As UShort
	Index As UShort
	PC As UShort
	display(0 To 63,0 To 31) As UByte
	delayTimer As UByte
	soundTimer As UByte
	key(0 To 15) As UByte
End Type


Dim Shared As chip8 CPU ' main cpu
Dim Shared As fb.image Ptr screenbuff ' buffer for screen
Dim Shared As Integer sfx = 10, sfy = 15' scale factor for display
Dim Shared As Single start
Dim Shared As Integer VX, VY, KK
Dim Shared opctemp As String
Declare Sub keycheck ' check keys
#Include Once "inc/c8 instruction set.bi" ' these must go here because depend on cpu type
#Include Once "inc/decoder.bi" ' same


Dim Shared As UByte font(0 To 79) => _ ' Chip 8 font set
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



Declare Sub initcpu ' initialize CPU
Declare Sub loadprog ' load ROM to memory
Declare Sub CAE ' cleanup and exit
Declare Sub render 'render the display


Sub keycheck
	If MultiKey(SC_1) Then cpu.key(0) = 1 Else cpu.key(0) = 0
	If MultiKey(SC_2) Then cpu.key(1) = 1 Else cpu.key(1) = 0
	If MultiKey(SC_3) Then cpu.key(2) = 1 Else cpu.key(2) = 0
	If MultiKey(SC_4) Then cpu.key(3) = 1 Else cpu.key(3) = 0
	If MultiKey(SC_q) Then cpu.key(4) = 1 Else cpu.key(4) = 0
	If MultiKey(SC_w) Then cpu.key(5) = 1 Else cpu.key(5) = 0
	If MultiKey(SC_e) Then cpu.key(6) = 1 Else cpu.key(6) = 0
	If MultiKey(SC_r) Then cpu.key(7) = 1 Else cpu.key(7) = 0
	If MultiKey(SC_a) Then cpu.key(8) = 1 Else cpu.key(8) = 0
	If MultiKey(SC_s) Then cpu.key(9) = 1 Else cpu.key(9) = 0
	If MultiKey(SC_d) Then cpu.key(10) = 1 Else cpu.key(10) = 0
	If MultiKey(SC_f) Then cpu.key(11) = 1 Else cpu.key(11) = 0
	If MultiKey(SC_z) Then cpu.key(12) = 1 Else cpu.key(12) = 0
	If MultiKey(SC_x) Then cpu.key(13) = 1 Else cpu.key(13) = 0
	If MultiKey(SC_c) Then cpu.key(14) = 1 Else cpu.key(14) = 0
	If MultiKey(SC_v) Then cpu.key(15) = 1 Else cpu.key(15) = 0
	
End Sub
Sub render
	screenbuff = ImageCreate(640,480,RGB(0,0,0))
	For y As Integer = 0 To 31
		For x As Integer = 0 To 63
			For z As Integer = sfy To 1 Step -1
				If cpu.display(x,y) = 1 Then Line screenbuff, (x*sfx-sfx,y*sfy-z)-(x*sfx,y*sfy-z)
			Next
		Next
	Next
	Put (sfx/2,sfy/2),screenbuff,PSet
	ImageDestroy(screenbuff)
End Sub


Sub initcpu
	For i As Integer = 0 To 4095
		cpu.memory(i) = 0
	Next
	For i As Integer = 0 To 15
		CPU.stack(i) = 0
		CPU.key(i) = 0
		cpu.V(i) = 0
	Next
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

	'Font Load
	For i As Integer = 0 To 79
		cpu.memory(i) = font(i)
	Next
End Sub

Sub loadprog
	Dim As String progname, shpname, onechr
	Dim As UInteger romsize
	'See if we got a filename from the command line or drag and drop
	If Command(1) <> "" Then
		progname = Command(1)
		GoTo gotname
	End If
	Print "Note: ROM must be in EXEPATH, else use drag and drop to load it!)"
	Input "Program to run (compiled, no header): ", progname 'Get a filename from user
	progname = ExePath & "\" & progname

	gotname:
	If progname = "" Or Not FileExists(progname) Then 'Break if no such filename
		Cls
		Print "File not found: " & progname
		Sleep 3000
		CAE
	EndIf

	'remove path from filename
	For z As Integer = 1 To Len(progname) Step 1
		onechr = Right(Left(progname,z),1)
		If onechr = "\" Then
			onechr = ""
			shpname = ""
		EndIf
		shpname = shpname & onechr
	Next

	WindowTitle "Project Cherry: " & shpname ' set window title
	Dim As Integer f = FreeFile
	Open progname For Binary As #f
	romsize = Lof(f)
	For i As Integer = 0 To romsize
		Get #1, i+1, cpu.memory(i+512), 1 ' file is 1 indexed, array is 0 indexed
	Next
	Close #f
End Sub

Sub CAE
	Cls
	Close
	End
End Sub


'PROGRAM START
ScreenRes 640,480,32
initcpu
loadprog
'main loop
start = Timer
ins_bcdstore

Do
	cpu.opcount+=1
	
	While cpu.opcount / 60 > Timer - start 'limit to 60 op per sec
		Sleep 15
	Wend

	render
	cpu.opcodePTR = @cpu.memory(cpu.pc)
	cpu.opcode = (LoByte(*cpu.opcodePTR) Shl 8 ) + HiByte(*cpu.opcodePTR)
	decode(cpu.opcode)
	cpu.pc+=2
	Select Case cpu.instruction
		Case "CLS"
			INS_CLS

		Case "RET"
			INS_RET

		Case "JMP"
			INS_JMP

		Case "CALL"
			INS_CALL

		Case "SKIPEQUAL"
			INS_SKIPEQUAL

		Case "SKIPNOTEQUAL"
			INS_SKIPNOTEQUAL

		Case "SKIPEQUALREG"
			INS_SKIPEQUALREG

		Case "LOADKK"
			INS_LOADKK

		Case "ADDKK"
			INS_ADDKK

		Case "VXEQVY"
			INS_VXEQVY

		Case "VXORVY"
			INS_VXORVY

		Case "VXXORVY"
			INS_VXXORVY

		Case "ADC"
			INS_ADC

		Case "SUBTRACT"
			INS_SUBTRACT

		Case "SHIFTR"
			INS_SHIFTR

		Case "SUBN"
			INS_SUBN

		Case "SHIFTL"
			INS_SHIFTL

		Case "SKIPNOTEQUALREG"
			INS_SKIPNOTEQUALREG

		Case "LOADINDEX"
			INS_LOADINDEX

		Case "JUMPREG"
			INS_JUMPREG

		Case "RNDANDKK"
			INS_RNDANDKK

		Case "DISPLAY"
			INS_DISPLAY

		Case "KEYSKIP"
			INS_KEYSKIP

		Case "KEYNOTSKIP"
			INS_KEYNOTSKIP

		Case "VXDELAY"
			INS_VXDELAY

		Case "KEYWAIT"
			INS_KEYWAIT

		Case "DELAYSET"
			INS_DELAYSET

		Case "SOUNDSET"
			INS_SOUNDSET

		Case "IPLUSVX"
			INS_IPLUSVX

		Case "ISPRITE"
			INS_ISPRITE

		Case "BCDSTORE"
			INS_BCDSTORE

		Case "STOREREG"
			INS_STOREREG

		Case "LOADREG"
			INS_LOADREG

		Case Else
			Cls
			Print "Decore error!"
			Print "Opcode: " & Hex(cpu.opcode)
			Print "Instruction: " & cpu.instruction
	End Select
	
	If cpu.delaytimer > 0 Then cpu.delaytimer-=1
	If cpu.soundtimer > 0 Then cpu.soundtimer-=1

Loop While Not MultiKey(SC_ESCAPE)
