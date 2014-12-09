'BMP to CHIP-8 converter
'By Blyss Sarania
'BMP rendering code by HAP:
'
'"BMP Viewer, 02-06-05, by hap
'works with monochrome BMPs only, of course. put the BMP data (headerless) at
'offset $30. change offset $0 (200) $00ff to $1202 for Chip-8."

ScreenRes 640,480,32
WindowTitle "BMP to CHIP-8"
#Include Once "fbgfx.bi"
#Include Once "file.bi"
Using fb
Dim As UByte mode = 1
Dim As UShort chipmode = &h0212
Print "Will convert " & Command(1) & " to a chip executable."
Print "Press 1 for CHIP-8 mode(64x32)"
Print "Press 2 for SCHIP mode(128x64)"
Do
	If MultiKey(SC_1) Then mode = 1: Exit Do: End if
	If MultiKey(SC_2) Then mode = 2: Exit Do: End If
	Sleep 15
Loop

Dim As Byte bmploader(0 To 47)
Open ExePath & "/bmploader.bin" For Binary As #1
Get #1, 1, bmploader()
Close #1

Open Command(1) For Binary As #1
Dim As Byte bmp(0 To Lof(1)-(55+8))
Get #1, 55+8, bmp()
Close #1

If fileexists(Left(Command(1), Len(Command(1))-4) & ".ch8") Then Kill(Left(Command(1), Len(Command(1))-4) & ".ch8")
Open Left(Command(1), Len(Command(1))-4) & ".ch8" For Binary As #1
Put #1, 1, bmploader()
Put #1, 49, bmp()
If mode = 1 Then Put #1, 1, chipmode
Close #1