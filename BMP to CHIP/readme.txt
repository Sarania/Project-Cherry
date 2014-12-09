BMP to CHIP-8 converter
By Blyss Sarania
Feed it a monochrome BMP. Either 128x64(SCHIP) or 64x32(CHIP-8) It will spit out a .ch8 program to render it.
It does not need be headerless for this program(the below text is just a credit to the author of the BMP loading code).

BMP rendering code by HAP:

"BMP Viewer, 02-06-05, by hap
works with monochrome BMPs only, of course. put the BMP data (headerless) at
offset $30. change offset $0 (200) $00ff to $1202 for Chip-8."