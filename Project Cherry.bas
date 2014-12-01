'Chip 8 Emulator in FreeBASIC

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
Index As Short
PC As Short
display(0 To 63,0 To 31) As Byte
delayTimer As Byte
soundTimer As Byte
key(0 To 15) As byte
End Type
