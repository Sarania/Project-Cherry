'Chip 8 Emulator in FreeBASIC
'Written by Blyss Sarania and Nobbs66
#Include Once "fbgfx.bi" 'FB graphics library
Using FB 'FB namespace
#Include Once "file.bi" ' file manipulation
#Include Once "string.bi" ' string manipulation
#Include Once "fmod.bi" ' a whole audio library just for boop sounds!

Dim Shared As UByte debug = 0' 1 to show debug, 0 to not show

Type Chip8
	mode As String = "CHIP-8"
	drawflag As UByte 'is set to 1 when screen needs updated
	opcount As ULongInt 'total number of ops. Reset when ops per second is changed
	instruction As String 'current instruction in string form
	opcode As UShort 'current instruction in binary
	opcodePTR As UShort Pointer 'points to the opcode, had to do some weird magic to extract 2 bytes
	memory(0 To 4095) As UByte 'RAM
	V(0 To 15) As UByte 'Registers V0-VF
	stack(0 To 15) As UShort 'The stack
	sp As UShort 'Stack pointer
	Index As UInteger 'Generally holds addresses, it's a register
	PC As UShort 'Program counter
	delayTimer As UByte 'counts to 0 at 60hz
	soundTimer As UByte 'counts to 0 at 60hz, plays a beep when <> 0
	key(0 To 15) As UByte 'Hex keypad
	hp48(0 To 7) As UByte 'SCHIP registers
	xres As UByte = 63 'display X
	yres As UByte = 31'display y
End Type

Type controller
	up As UByte
	down As UByte
	Left As UByte
	Right As ubyte
End Type

Dim Shared As UByte speedunlock = 0 ' for turbo mode
Dim Shared As UByte speedtoggle = 0 ' for turbo mode toggle
Dim Shared As String game
Dim Shared didlogo As UByte = 0
Dim Shared As controller c
Dim Shared As chip8 CPU 'main cpu
Dim Shared display(0 To cpu.xres, 0 To cpu.yres) As UByte 'Monochrome display
Dim Shared dispcolor(1 To cpu.yres+1) As integer
Dim Shared As fb.image Ptr screenbuff 'buffer for screen
Dim Shared As fb.image Ptr debugbox 'debug box
Dim Shared As Double start, chipstart 'start is used for opcode timing, chipstart for chip8 timers
Dim Shared As UInteger VX, VY, KK 'Chip 8 vars
Dim Shared As UInteger screenx, screeny, ops 'screen size, and ops per second
Dim Shared As UInteger foreR, foreG, foreB, backR, backG, backB 'screen colors
Dim Shared As UInteger sfx, sfy 'scale factor for display
Dim Shared As UInteger jumpcount ' counts consecutive jumps
Dim Shared As UInteger msgcount = 0 ' message display time counter
dim shared as string msg ' message passing
Dim Shared As Single version = 1.00 'version
Dim Shared As ULongInt frames
Dim Shared As Double frametime, framestart
Dim Shared As UByte dosave, doload
Dim Shared As UByte hack = 0
Dim Shared As UByte colorlines, aspect
Dim Shared As UByte layout = 0
Dim Shared As UByte booping = 0, mute = 0
Dim Shared As Single soundplaytime ' make sound play at LEAST .1 seconds
Dim Shared As Integer Ptr trackhandle 'SFX pointer
Declare Sub keycheck 'check keys, this must be defined here because the following includes depend on it
Declare Sub CAE 'cleanup and exit
Declare Sub render 'render the display
Declare Sub colorit
Declare Sub playSFX(SFX As String) ' play the boop sound
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

Dim Shared As UByte Sfont(0 To 159) => _ 'SCHIP font set
{&hF0, &hF0, &h90, &h90, &h90, &h90, &h90, &h90, &hF0, &hF0,_ '0
&h20, &h20, &h60, &h60, &h20, &h20, &h20, &h20, &h70, &h70,_ '1
&hF0, &hF0, &h10, &h10, &hF0, &hF0, &h80, &h80, &hF0, &hF0,_ '2
&hF0, &hF0, &h10, &h10, &hF0, &hF0, &h10, &h10, &hF0, &hF0,_ '3
&h90, &h90, &h90, &h90, &hF0, &hF0, &h10, &h10, &h10, &h10,_ '4
&hF0, &hF0, &h80, &h80, &hF0, &hF0, &h10, &h10, &hF0, &hF0,_ '5
&hF0, &hF0, &h80, &h80, &hF0, &hF0, &h90, &h90, &hF0, &hF0,_ '6
&hF0, &hF0, &h10, &h10, &h20, &h20, &h40, &h40, &h40, &h40,_ '7
&hF0, &hF0, &h90, &h90, &hF0, &hF0, &h90, &h90, &hF0, &hF0,_ '8
&hF0, &hF0, &h90, &h90, &hF0, &hF0, &h10, &h10, &hF0, &hF0,_ '9
&hF0, &hF0, &h90, &h90, &hF0, &hF0, &h90, &h90, &h90, &h90,_ 'A
&hE0, &hE0, &h90, &h90, &hE0, &hE0, &h90, &h90, &hE0, &hE0,_ 'B
&hF0, &hF0, &h80, &h80, &h80, &h80, &h80, &h80, &hF0, &hF0,_ 'C
&hE0, &hE0, &h90, &h90, &h90, &h90, &h90, &h90, &hE0, &hE0,_ 'D
&hF0, &hF0, &h80, &h80, &hF0, &hF0, &h80, &h80, &hF0, &hF0,_ 'E
&hF0, &hF0, &h80, &h80, &hF0, &hF0, &h80, &h80, &h80, &h80}  'F


Declare Sub initcpu 'initialize CPU
Declare Sub loadprog(ByVal pn As String = "") 'load ROM to memory
Declare Sub loadini 'load teh ini
Declare Sub about 'project information
Declare Sub extract 'extract VX and VY from cpu.opcode
Declare Sub saveState
Declare Sub loadstate

Sub playSFX (SFX As String)
	If mute=0 Then
		trackHandle = FSOUND_Stream_Open(SFX, FSOUND_LOOP_NORMAL, 0, 0 )
		FSOUND_Stream_Play(1, trackHandle)
		FSOUND_SetVolumeAbsolute(1, 255)
	End If
End Sub

Sub stopSFX
	If FSOUND_IsPlaying(1) Then
		FSOUND_Stream_Stop(trackHandle)
		FSOUND_Stream_Close(trackHandle)
	End If
End Sub

Sub colorit
	ReDim Preserve dispcolor(1 To cpu.yres+1)
	Dim As UByte r, g, b
	For y As Integer = 1 To cpu.yres+1
		recolor:
		r = (Rnd * 255)
		g = (Rnd * 255)
		b = (Rnd * 255)
		If r+g+b < 255 Then GoTo recolor
		dispcolor(y) = RGB(r,g,b)
	Next
End Sub

Sub saveState
	Dim As UByte f = FreeFile
	Open ExePath & "/states/" & game & "_cherry.state" For Output As #f
	Print #f, cpu.drawflag
	Print #f, cpu.opcount
	Print #f, cpu.instruction
	Print #f, cpu.opcode
	Print #f, *cpu.opcodePTR
	For i As Integer = 0 To 15
		Print #f, cpu.v(i)
	Next
	For i As Integer = 0 To 15
		Print #f, cpu.stack(i)
	Next
	Print #f, cpu.sp
	Print #f, cpu.index
	Print #f, cpu.PC
	Print #f, cpu.delayTimer
	Print #f, cpu.soundTimer
	Print #f, cpu.xres
	Print #f, cpu.yres
	Print #f, start
	Print #f, ops
	Print #f, sfx
	Print #f, sfy
	For y As Integer = 0 To cpu.yres
		For x As Integer = 0 To cpu.xres
			Print #f, display(x,y)
		Next
	Next
	Close #f
	f = FreeFile
	Open ExePath & "/states/" & game & "_cherry.ram" For Binary As #f
	Put #f, 1, cpu.memory()
	Close #f
	start = Timer
	cpu.opcount = 0
End Sub

Sub loadstate
	initcpu
	Dim As UByte f = FreeFile
	Open ExePath & "/states/" & game & "_cherry.state" For input As #f
	Input #f, cpu.drawflag
	Input #f, cpu.opcount
	Input #f, cpu.instruction
	Input #f, cpu.opcode
	Input #f, *cpu.opcodePTR
	For i As Integer = 0 To 15
		Input #f, cpu.v(i)
	Next
	For i As Integer = 0 To 15
		Input #f, cpu.stack(i)
	Next
	Input #f, cpu.sp
	Input #f, cpu.Index
	Input #f, cpu.PC
	Input #f, cpu.delayTimer
	Input #f, cpu.soundTimer
	Input #f, cpu.xres
	Input #f, cpu.yres
	Input #f, start
	Input #f, ops
	Input #f, sfx
	Input #f, sfy
	For y As Integer = 0 To cpu.yres
		For x As Integer = 0 To cpu.xres
			input #f, display(x,y)
		Next
	Next
	Close #f
	f = FreeFile
	Open ExePath & "/states/" & game & "_cherry.ram" For Binary As #f
	Get #f, 1, cpu.memory()
	Close #f
	start = Timer
	cpu.opcount = 0
End Sub

Sub extract 'extract VX and VY from cpu.opcode
	Vx = cpu.opcode And &H0F00
	Vx = vx Shr 8
	vy = cpu.opcode And &h00F0
	vy = vy Shr 4
End Sub

Sub about 'Display about section when HOME key is pressed
	Cls
	Dim cherry As fb.image Ptr
	Dim banner As fb.image Ptr
	cherry = ImageCreate(128,148,RGB(0,0,0))
	banner = ImageCreate(400,148,RGB(0,0,0))
	BLoad ("res/cherry.bmp",cherry)
	BLoad ("res/banner.bmp",banner)
	Draw String (0,0), "Project Cherry v" & Format(version, "0.00")
	Draw String (0,10), "_____________________"
	Draw String (0,30), "Project Cherry is a Chip8 emulator written in FreeBASIC."
	Draw String (0,50), "CHIP-8 is an interpreted programming language, developed by Joseph Weisbecker."
	Draw String (0,70), "It was initially used on the COSMAC VIP and Telmac 1800 8-bit microcomputers in"
	Draw String (0,90), "the mid 1970s. CHIP-8 programs are run on a CHIP-8 virtual machine or emulator."
	Draw String (0,150), "Project Cherry was written by:"
	Draw String (0,160), "______________________________"
	Draw String (0,180), "Blyss Sarania"
	Draw String (0,200), "Nobbs66"
	Put (screenx-128,screeny-148), cherry, Trans
	Put (0,screeny-168), banner, Trans
	Draw String (0, screeny-220), "___________________________________________________________________________"
	Draw String (0, screeny-200), "FMOD audio library copyright © Firelight Technologies Pty, Ltd., 1994-2014."
	Draw String (0, screeny-190), "http://www.fmod.org/"
	Draw String (0, screeny-180), "FMOD is free for non-commercial use"
	Draw String (0, screeny-20), "Compiled on: " + Str(__DATE__) + " at " + Str(__TIME__)
	Draw String (0, screeny-10), "Compiled with FreeBASIC version " + Str(__FB_VER_MAJOR__) + "." + Str(__FB_VER_MINOR__) + "." + Str(__FB_VER_PATCH__)
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
		Print #f, 0 '1 for random color lines
		Print #f, 1' 1 for aspect correct scaling
		Print #f, 0 'mute on
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
	Input #f, Colorlines
	input #f, aspect
	Input #f, mute
	Close #f
	If screenx < 640 Then screenx = 640
	If screeny < 480 Then screeny = 480
End Sub



Sub keycheck 'Check for keypresses, and pass to the emulated CPU
	For i As Integer = 0 To 15
		cpu.key(i) = 0
	Next
	If MultiKey(SC_UP) Or MultiKey(SC_W) Then c.up = 1 Else c.up = 0
	If MultiKey(SC_DOWN) Or MultiKey(SC_S) Then c.down = 1 Else c.down = 0
	If MultiKey(SC_LEFT) Or MultiKey(SC_A) Then c.left = 1 Else c.left = 0
	If MultiKey(SC_RIGHT) Or MultiKey(SC_D) Then c.right = 1 Else c.right = 0
	If layout = 0 Then
		If MultiKey(SC_1) Then cpu.key(1) = 1
		If MultiKey(SC_2) Then cpu.key(2) = 1
		If MultiKey(SC_3) Then cpu.key(3) = 1
		If MultiKey(SC_4) Then cpu.key(12) = 1
		If MultiKey(sc_r) Then cpu.key(13) = 1
		If MultiKey(sc_a) Then cpu.key(7) = 1
		If MultiKey(sc_s) Then cpu.key(8) = 1
		If MultiKey(SC_d) Then cpu.key(9) = 1
		If MultiKey(sc_f) Then cpu.key(14) = 1
		If MultiKey(SC_q) Then cpu.key(4) = 1
		If MultiKey(SC_w) Then cpu.key(5) = 1
		If MultiKey(SC_e) Then cpu.key(6) = 1
		If MultiKey(SC_z) Then cpu.key(10) = 1
		If MultiKey(SC_x) Then cpu.key(0) = 1
		If MultiKey(SC_c) Then cpu.key(11) = 1
		If MultiKey(SC_v) Then cpu.key(15) = 1
	End If
	If layout = 1 Then
		If c.left Then cpu.key(7) = 1
		If c.right Then cpu.key(8) = 1
		If c.up Then cpu.key(3) = 1
		If c.down Then cpu.key(6) = 1
	EndIf
	If layout = 2 Then
		If c.left Then cpu.key(5) = 1
		If c.right Then cpu.key(6) = 1
		If c.up Then cpu.key(4) = 1
		If c.down Then cpu.key(7) = 1
	EndIf
	If layout = 3 Then
		If c.left Then cpu.key(4) = 1
		If c.right Then cpu.key(6) = 1
	EndIf
	If layout = 4 Then
		If c.up Or c.left Then cpu.key(1) = 1
		If c.down Or c.right Then cpu.key(4) = 1
	EndIf
	If layout = 5 Then
		If c.left Then cpu.key(4) = 1
		If c.right Then cpu.key(6) = 1
		If c.up Then cpu.key(5) = 1
	EndIf
	If layout = 6 Then
		If c.left then cpu.key(3) = 1
		If c.right then cpu.key(12) = 1
		If c.up then cpu.key(10) = 1
	EndIf
	If MultiKey(SC_ESCAPE) Then 'quit
		CAE
	EndIf
	If MultiKey(SC_HOME) Then 'about
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

	If MultiKey(SC_F3) Then 'savestate
		cpu.soundTimer = 30
		msgcount = 2000
		msg = "State saved sucessfully!"
		dosave = 1
		While MultiKey(SC_F3)
			Sleep 15
		Wend
	EndIf

	If MultiKey(SC_F5) Then 'load state
		If Not FileExists(ExePath & "/states/" & game & "_cherry.state") Or Not FileExists(ExePath & "/states/" & game & "_cherry.ram") Then
			cpu.soundTimer = 30
			msgcount = 2000
			msg = "No save state found!"
		Else
			cpu.soundTimer = 30
			doload = 1
			msgcount = 2000
			msg = "State loaded sucessfully!"
		EndIf
		While MultiKey(SC_F5)
			Sleep 15
		Wend
	End If

	If MultiKey(SC_P) Then ' mute toggle
		If mute = 1 Then mute = 0 Else mute = 1
		cpu.soundtimer = 15
		While MultiKey(SC_P)
			Sleep 15
		Wend
	EndIf

	If MultiKey(sc_tilde) Then 'debug info toggle
		If debug = 1 Then debug = 0 Else debug = 1
		cpu.drawflag = 1
		While MultiKey(SC_TILDE)
			Sleep 15
		Wend
	EndIf

	If MultiKey(SC_TAB) Then 'Engage turbo (while tab is held)
		speedunlock = 1
	EndIf

	If speedunlock = 1 And (Not MultiKey(SC_TAB)) Then 'Disengage turbo
		speedunlock = 0
		start = timer
		cpu.opcount = 0
	EndIf

	If MultiKey(SC_F4) Then 'Toggle turbo
		If speedtoggle = 0 Then
			speedtoggle = 1
		Else
			speedtoggle = 0
			start = Timer
			cpu.opcount = 0
		EndIf
		While MultiKey(SC_F4)
			Sleep 1
		Wend
	EndIf

End Sub
Sub render
	Dim As Single fps = frames / (Timer - framestart)
	If fps > 60 Then Exit Sub
	frames+=1
	Dim As Double renderstart = Timer
	Dim As UInteger offsety = 0
	If aspect = 1 Then offsety = screeny/6
	Dim As integer clr = rgb(ForeR,foreG,ForeB)
	screenbuff = ImageCreate(screenx,screeny,RGB(backR,backG,backB))
	For y As UInteger =  0 To cpu.yres
		If colorlines = 1 Then clr = dispcolor(y)
		For x As UInteger = 0 To cpu.xres
			If display(x,y) = 1 Then Line screenbuff, (x*sfx,(y*sfy)+offsety)-(x*sfx+sfx,(y*sfy+sfy)+offsety), clr, BF
		Next
	Next
	Put (0,0),screenbuff,PSet
	ImageDestroy(screenbuff)
	frametime = Timer-renderstart
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
	For i As Integer = 0 To 159
		cpu.memory(i+80) = Sfont(i)
	Next
End Sub

Sub loadprog(ByVal pn As String = "") 'Load a ROM
	Dim As String progname, shpname, onechr
	If pn <> "" Then progname = pn: GoTo gotname
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
	If UCase(Left(shpname,6)) = "BLINKY" Then layout = 1
	If UCase(Left(shpname,6)) = "TETRIS" Then layout = 2
	If UCase(Left(shpname,8)) = "BREAKOUT" Then layout = 3
	If UCase(Left(shpname,5)) = "BRICK" Then layout = 3
	If UCase(Left(shpname,4)) = "PONG" Then layout = 4
	If UCase(Left(shpname,14)) = "SPACE INVADERS" Then layout = 5
	If UCase(Left(shpname,3)) = "ANT" Then layout = 6

	'Games that need wrapping off:
	If UCase(shpname) = "BOWLING [GOOITZEN VAN DER WAL].CH8" Then hack = 1
	If UCase(shpname) = "BLITZ [DAVID WINTER].CH8" Then hack = 1
	If UCase(shpname) = "SQUASH [DAVID WINTER].CH8" Then hack = 1
	If UCase(shpname) = "WALL [DAVID WINTER].CH8" Then hack = 1
	If UCase(shpname) = "JUMPING X AND O [HARRY KLEINBERG, 1977].CH8" Then hack = 1
	If UCase(shpname) = "MINES! - THE MINEHUNTER [DAVID WINTER, 1997].CH8" Then hack = 1
	If UCase(shpname) = "ROCKET LAUNCH [JONAS LINDSTEDT].CH8" Then hack = 2
	game = Left(shpname, Len(shpname)-4)



	If pn <> CurDir & ("/res/logo.bin") Then WindowTitle "Project Cherry: " & shpname Else WindowTitle "Project Cherry"' set window title
	Dim As Integer f = FreeFile
	Open progname For Binary As #f
	Dim As UInteger maxlen
	If Lof(f) > 4095-512 Then maxlen = 4095-512 Else maxlen = Lof(f)
	For i As Integer = 0 To maxlen
		Get #f, i+1, cpu.memory(i+512), 1 ' file is 1 indexed, array is 0 indexed
	Next
	Close #f
End Sub


Sub CAE 'Cleanup and Exit
	While InKey <> "": wend
	FSOUND_Close
	Cls
	Close
	Draw String ((screenx/2) - 64,screeny/2), "Emulation ended.", RGB(255,0,255)
	Draw String ((screenx/2) - 88,(screeny/2) + 10), "Press any key to exit.", RGB(255,0,255)
	Sleep
	End
End Sub


'Program starts here
'-----------------------------------------------------------------------------------------------------------
Randomize Timer 'Feed the random number generator the timer as a seed
loadini
ScreenRes screenx,screeny,32
If colorlines Then colorit
sfx = screenx/(cpu.xres+1) 'compute the scale factor for X
sfy = iif(aspect = 0, screeny/(cpu.yres+1), sfx) ' and Y
FSOUND_Init(44100, 8, 0)
initcpu
if debug = 1 then: didlogo=1: loadprog: GoTo skiplogo:EndIf
ChDir ExePath
ChDir ".."
loadprog CurDir & ("/res/logo.bin")
skiplogo:
ChDir ExePath
ChDir ".."
Cls
start = Timer
chipstart = Timer
framestart = Timer


'main loop
Do
	cpu.opcount+=1

	While ((cpu.opcount / ops > Timer - start) And speedunlock = 0 And speedtoggle = 0) Or (cpu.opcount / (10000) > Timer - start) 'limit ops per sec. 10kops with turbo on.
		Sleep 1
	Wend
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
			If jumpcount > (ops*3) Then CAE
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

		Case "DISMEGAMODE"
			INS_DISMEGAMODE

		Case "ENMEGAMODE"
			INS_ENMEGAMODE

		Case "LHDI"
			INS_LHDI

		Case "LOADCOLORS"
			INS_LOADCOLORS

		Case "SPRITEWIDTH"
			INS_SPRITEWIDTH

		Case "SPRITEHEIGHT"
			INS_SPRITEHEIGHT

		Case "SETALPHA"
			INS_SETALPHA

		Case "PLAYSOUND"
			INS_PLAYSOUND

		Case "STOPSOUND"
			INS_STOPSOUND

		Case "BLENDMODE"
			INS_BLENDMODE

		Case "SCROLLND"
			INS_SCROLLND

		Case Else
			Cls
			Print "Decoder error!"
			Print "Opcode: " & Hex(cpu.opcode)
			Print "Instruction: " & cpu.instruction
			Print "Opcount: " & cpu.opcount
			Print "PC: " & Hex(cpu.pc)
			print "File address: " & hex(cpu.pc - &h200)
			Sleep
	End Select

	render ' doing it this way with a framelimiter yeilds much lighter requirements than depending on the drawflag

	If Timer-chipstart > 0.01667 Then ' 0.1667 is 1/60 of a second, these count down at 60hz
		If cpu.delaytimer > 0 Then cpu.delaytimer-=1
		If cpu.soundtimer > 0 Then cpu.soundtimer-=1
		chipstart = Timer 'reset the timer
	End If

	If booping = 0 And cpu.soundtimer > 0 Then
		booping = 1
		soundplaytime = timer
		playSFX(ExePath & "/boop.wav")
	EndIf

	If booping = 1 And cpu.soundtimer = 0 And (Timer - soundplaytime) > 0.1 Then
		booping = 0
		stopSFX
	EndIf

	If debug = 1 Then 'print debug infos
		debugbox = ImageCreate(264,104,RGB(128,0,128))
		Line debugbox, (1,1)-(262,102),RGB(128,0,128), BF
		Line debugbox, (1,1)-(262,102),RGB(255,255,255),B
		Draw String debugbox, (2,2), "Instruction: " & cpu.instruction
		Draw String debugbox, (2, 12), "1-2-3-4-q-w-e-r-a-s-d-f-z-x-c-v"
		Draw String debugbox, (2, 22), cpu.key(0) & "_" & cpu.key(1) & "_" & cpu.key(2) & "_" & cpu.key(3) & "_" & cpu.key(4) & "_" & cpu.key(5) & "_" & cpu.key(6) & "_" & cpu.key(7) & "_" & cpu.key(8) & "_" & cpu.key(9) & "_" & cpu.key(10) & "_" & cpu.key(11) & "_" & cpu.key(12) & "_" & cpu.key(13) & "_" & cpu.key(14) & "_" & cpu.key(15)
		Draw String debugbox, (2, 32), "Delay timer: " & cpu.delayTimer
		Draw String debugbox, (2, 42), "Sound timer: " & cpu.soundTimer
		Draw String debugbox, (2, 52), "Speed(OPS) Goal: " & ops
		Draw String debugbox, (2, 62), "Op/s: " & cpu.opcount / (Timer - start)
		Draw String debugbox, (2, 72), "Emulator mode: " & cpu.mode
		Draw String debugbox, (2, 82), "FPS: " & frames / (Timer - framestart)
		Draw String debugbox, (2, 92), "Frame time: " & Format(frametime, "0.00000") & " | " & Format(1/frametime, "0.0000")
		put (0,0),debugBox, pset
		ImageDestroy(debugbox)
	End If


	If dosave = 1 Then saveState: dosave = 0: cpu.drawflag = 1: End if
	If doload = 1 Then loadstate: doload = 0: cpu.drawflag = 1: End If
	If msgcount > 0 Then
		Draw String ((screenx/2) - (Len(msg)*4), screeny/2), msg, RGB(200,0,255)
		msgcount -= 1
		if msgcount = 0 then msg = ""
	EndIf
	If didlogo = 0 And cpu.opcount > 600 Then
		didlogo = 1
		initcpu
		Cls
		loadprog
	EndIf
	If InKey = Chr(255) + "k" Then CAE
Loop
