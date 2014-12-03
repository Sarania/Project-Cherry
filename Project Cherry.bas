'Chip 8 Emulator in FreeBASIC
'Written by Blyss Sarania and Nobbs66
#Include Once "fbgfx.bi"
Using FB
#Include Once "file.bi"

Dim Shared As UByte debug = 1 ' 1 to show debug, 0 to not show

Type Chip8
	drawflag As UByte 'is set to 1 when screen needs updated
	opcount As ULongInt 'total number of ops. Reset when ops per second is changed
	instruction As String 'current instruction in string form
	opcode As UShort 'current instruction in binary
	opcodePTR As UShort Pointer 'points to the opcode, had to do some weird magic to extract 2 bytes
	memory(0 To 4095) As UByte 'RAM
	V(0 To 15) As UByte 'Registers V0-VF
	stack(0 To 15) As UShort 'The stack
	sp As UShort 'Stack pointer
	Index As UShort 'Generally holds addresses, it's a register
	PC As UShort 'Program counter
	delayTimer As UByte 'counts to 0 at 60hz
	soundTimer As UByte 'counts to 0 at 60hz, plays a beep when it hits 0
	key(0 To 15) As UByte 'Hex keypad
	hp48(0 To 7) As UByte 'SCHIP registers
	xres As UByte = 63 'display X
	yres As UByte = 31'display y
End Type

Dim Shared As chip8 CPU 'main cpu
Dim Shared display(0 To cpu.xres, 0 To cpu.yres) As UByte 'Monochrome display
Dim Shared As fb.image Ptr screenbuff 'buffer for screen
Dim Shared As Double start, chipstart 'start is used for opcode timing, chipstart for chip8 timers
Dim Shared As UInteger VX, VY, KK 'Chip 8 vars
Dim Shared As UInteger screenx, screeny, ops 'screen size, and ops per second
Dim Shared As UInteger foreR, foreG, foreB, backR, backG, backB 'screen colors
Dim Shared As UInteger sfx, sfy 'scale factor for display
Dim Shared As Single version = 0.7 'version
Declare Sub keycheck 'check keys, this must be defined here because the following includes depend on it
#Include Once "inc/c8 instruction set.bi" 'these must go here because depend on cpu type
#Include Once "inc/decoder.bi" 'same


Dim Shared As UByte font(0 To 79) => _ 'Chip 8 font set
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



Declare Sub initcpu 'initialize CPU
Declare Sub loadprog 'load ROM to memory
Declare Sub CAE 'cleanup and exit
Declare Sub render 'render the display
Declare Sub loadini 'load teh ini
Declare Sub about 'project information
Declare Sub extract 'extract VX and VY from cpu.opcode

Sub extract 'extract VX and VY from cpu.opcode
	Vx = cpu.opcode And &H0F00
	Vx = vx Shr 8
	vy = cpu.opcode And &h00F0
	vy = vy Shr 4
End Sub

Sub about 'Display about section when HOME key is pressed
	Dim cherry As fb.image Ptr
	Dim banner As fb.image Ptr
	cherry = ImageCreate(128,148,RGB(0,0,0))
	banner = ImageCreate(400,148,RGB(0,0,0))
	BLoad ("res/cherry.bmp",cherry)
	BLoad ("res/banner.bmp",banner)
	Cls
	Print "Project Cherry v" & version
	Print "_____________________"
	Print
	Print "Project Cherry is a Chip8 emulator written in FreeBASIC."
	Print ""
	Print "CHIP-8 is an interpreted programming language, developed by Joseph Weisbecker."
	Print ""
	Print "It was initially used on the COSMAC VIP and Telmac 1800 8-bit microcomputers in"
	Print ""
	Print "the mid 1970s. CHIP-8 programs are run on a CHIP-8 virtual machine or emulator."
	Print
	Print
	Print
	Print
	Print
	Print "Project Cherry was written by:"
	Print "______________________________"
	Print
	Print "Blyss Sarania"
	Print
	Print "Nobbs66"
	Put (screenx-128,screeny-148), cherry, Trans
	Put (0,screeny-148), banner, Trans
	Locate 49, 1:
	Print "Compiled on: " + Str(__DATE__) + " at " + Str(__TIME__)
	Print "Compiled with FreeBASIC version " + Str(__FB_VER_MAJOR__) + "." + Str(__FB_VER_MINOR__) + "." + Str(__FB_VER_PATCH__)
	ImageDestroy(cherry)
	ImageDestroy(banner)
	Sleep 'wait for keypress
	cpu.drawflag = 1 'reset drawflag since we cleared the screen
End Sub
Sub loadini
	Dim f As Integer = FreeFile
	If Not FileExists(ExePath & "\cherry.ini") Then
		Open ExePath & "\cherry.ini" For Output As #f 'Write a new INI file since it got deleted or something
		Print #f, 640 'screenX
		Print #f, 480 'screenY
		Print #f, 360 'Ops per second goal
		Print #f, 255 'Foreground Red
		Print #f, 255 'Foreground Green
		Print #f, 255 'Foreground Blue
		Print #f, 0 'Background Red
		Print #f, 0 'Background Green
		Print #f, 0 'Background Blue
		Close #f
	EndIf
	Open ExePath & "\cherry.ini" For Input As #f
	Input #f, screenx
	Input #f, screeny
	Input #f, ops
	Input #f, foreR
	Input #f, foreG
	Input #f, foreB
	Input #f, backR
	Input #f, backG
	Input #f, backB
	Close #f
End Sub



Sub keycheck 'Check for keypresses, and pass to the emulated CPU
	If MultiKey(SC_1) Then cpu.key(1) = 1 Else cpu.key(1) = 0
	If MultiKey(SC_2) Then cpu.key(2) = 1 Else cpu.key(2) = 0
	If MultiKey(SC_3) Then cpu.key(3) = 1 Else cpu.key(3) = 0
	If MultiKey(SC_4) Then cpu.key(12) = 1 Else cpu.key(12) = 0
	If MultiKey(sc_r) Then cpu.key(13) = 1 Else cpu.key(13) = 0
	If MultiKey(sc_a) Then cpu.key(7) = 1 Else cpu.key(7) = 0
	If MultiKey(sc_s) Then cpu.key(8) = 1 Else cpu.key(8) = 0
	If MultiKey(SC_d) Then cpu.key(9) = 1 Else cpu.key(9) = 0
	If MultiKey(sc_f) Then cpu.key(14) = 1 Else cpu.key(14) = 0
	If MultiKey(SC_q) Then cpu.key(4) = 1 Else cpu.key(4) = 0
	If MultiKey(SC_w) Then cpu.key(5) = 1 Else cpu.key(5) = 0
	If MultiKey(SC_e) Then cpu.key(6) = 1 Else cpu.key(6) = 0
	If MultiKey(SC_z) Then cpu.key(10) = 1 Else cpu.key(10) = 0
	If MultiKey(SC_x) Then cpu.key(0) = 1 Else cpu.key(0) = 0
	If MultiKey(SC_c) Then cpu.key(11) = 1 Else cpu.key(11) = 0
	If MultiKey(SC_v) Then cpu.key(15) = 1 Else cpu.key(15) = 0
	If MultiKey(SC_ESCAPE) Then
		CAE
	EndIf
	If MultiKey(SC_HOME) Then
		about
		Cls
	EndIf

	If MultiKey(SC_PAGEUP) Then 'increase ops per second
		ops + = 30
		start = Timer
		cpu.opcount = 0
		While MultiKey(SC_PAGEUP)
			Sleep 15
		Wend
	EndIf

	If MultiKey(SC_PAGEDOWN) Then 'decrease ops per second
		ops - = 30
		start = Timer
		cpu.opcount = 0
		While MultiKey(SC_PAGEDOWN)
			Sleep 15
		Wend
	EndIf

End Sub
Sub render
	screenbuff = ImageCreate(screenx,screeny,RGB(backR,backG,backB))
	For y As UInteger = 1 To cpu.yres+1
		For x As UInteger = 1 To cpu.xres+1
			If display(x,y) = 1 Then
				'if y = cpu.yres+1 Then foreR = 0 Else foreR = 255
			For z As Integer = sfy To 1 Step -1
				Line screenbuff, (x*sfx-(sfx/2)+IIf(y=cpu.yres+1,sfx,0), (y*sfy-z))-(x*sfx+(sfx/2)+IIf(y=cpu.yres+1,sfx,0),(y*sfy-z)), RGB(foreR,foreG,foreB)
			Next
			End if
		Next
	Next
	Put (0,0),screenbuff,pset

ImageDestroy(screenbuff)
End Sub


Sub initcpu 'initialize the CPU to power on state
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
	For y As Integer = 0 To cpu.yres
		For x As Integer = 0 To cpu.xres
			display(x,y) = 0
		Next
	Next
	CPU.delaytimer = 0
	CPU.soundtimer = 0

	'Copy the font into memory
	For i As Integer = 0 To 79
		cpu.memory(i) = font(i)
	Next
End Sub

Sub loadprog 'Load a ROM
	Dim As String progname, shpname, onechr
	If Command(1) <> "" Then'See if we got a filename from the command line/drag and drop/double click
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

	'remove path from filename, so we can put it in the Window title
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
	For i As Integer = 0 To Lof(1)
		Get #1, i+1, cpu.memory(i+512), 1 ' file is 1 indexed, array is 0 indexed
	Next
	Close #f
End Sub

Sub CAE 'Cleanup and Exit
	Cls
	Close
	End
End Sub


'Program starts here
'-----------------------------------------------------------------------------------------------------------
Randomize Timer 'Feed the random number generator the timer as a seed
loadini
ScreenRes screenx,screeny,32
sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
sfy = screeny/(cpu.yres+1) ' and Y
initcpu
loadprog
Cls
start = Timer
chipstart = Timer


'main loop
Do
	cpu.opcount+=1

	While cpu.opcount / ops > Timer - start 'limit ops per sec
		Sleep 15
	Wend

	If cpu.drawflag = 1 Then: render: cpu.drawflag = 0: End If
	cpu.opcodePTR = @cpu.memory(cpu.pc) 'Yep, this is weird. But I couldn't concatenate them the normal way
	cpu.opcode = (LoByte(*cpu.opcodePTR) Shl 8 ) + HiByte(*cpu.opcodePTR) 'More of the weirdness mentioned above
	decode(cpu.opcode)
	cpu.pc+=2 'We increment the PC out here, after decoding, but before executing. This ensures it will be right even after jumps
	keycheck 'check for key presses
	extract ' pull VX and VY out of cpu.opcode
	Select Case cpu.instruction
		Case "HIRES"
			INS_HIRES
		
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

		Case "VXANDVY"
			INS_VXANDVY

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

		Case "SCROLLN"
			INS_SCROLLN

		Case "RIGHTSCR"
			INS_RIGHTSCR

		Case "LEFTSCR"
			INS_LEFTSCR

		Case "EXCHIP"
			INS_EXCHIP

		Case "DISEXT"
			INS_DISEXT

		Case "ENEXT"
			INS_ENEXT

		Case "TENSPRITE"
			INS_TENSPRITE

		Case "STORERPL"
			INS_STORERPL

		Case "READRPL"
			INS_READRPL

		Case Else
			Cls
			Print "Decoder error!"
			Print "Opcode: " & Hex(cpu.opcode)
			Print "Instruction: " & cpu.instruction
			Print cpu.opcount
			Sleep
	End Select

	If Timer-chipstart > 0.01667 Then ' 0.1667 is 1/60 of a second, these count down at 60hz
		If cpu.delaytimer > 0 Then cpu.delaytimer-=1
		If cpu.soundtimer > 0 Then cpu.soundtimer-=1
		chipstart = Timer 'reset the timer
	End If

	If debug = 1 Then 'print debug infos
		Locate 1,1: Print cpu.instruction & "          "
		Print "1-2-3-4-q-w-e-r-a-s-d-f-z-x-c-v"
		Print cpu.key(0) & "_" & cpu.key(1) & "_" & cpu.key(2) & "_" & cpu.key(3) & "_" & cpu.key(4) & "_" & cpu.key(5) & "_" & cpu.key(6) & "_" & cpu.key(7) & "_" & cpu.key(8) & "_" & cpu.key(9) & "_" & cpu.key(10) & "_" & cpu.key(11) & "_" & cpu.key(12) & "_" & cpu.key(13) & "_" & cpu.key(14) & "_" & cpu.key(15)
		Print "Delay timer: " & cpu.delayTimer
		Print "Sound timer: " & cpu.soundTimer
		Print "Ops per second: " & ops
	End If

Loop
