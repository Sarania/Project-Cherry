'decoder for Chip 8
Declare Sub decode(ByVal opc As UShort)

Sub decode(ByVal opc As UShort)
	Dim opctemp As String
	opctemp = UCase(Hex(opc))

	If opctemp = "00E0" Then
		cpu.instruction = "CLS"
		Exit Sub
	End If


	If opctemp = "EE" Then
		cpu.instruction = "RET"
		Exit Sub
	End If
	
	
	If Left(opctemp,1) = "1" Then
		cpu.instruction = "JMP"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "2" Then
		cpu.instruction = "CALL"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "3" Then
		cpu.instruction = "SKIPEQUAL"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "4" Then
		cpu.instruction = "SKIPNOTEQUAL"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "5" Then
		cpu.instruction = "SKIPEQUALREG"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "6" Then
		cpu.instruction = "LOADKK"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "7" Then
		cpu.instruction = "ADDKK"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "8" Then
		If Right(opctemp,1) = "0" Then
			cpu.instruction = "VXEQVY"
			Exit sub
		EndIf
		If Right(opctemp,1) = "1" Then
			cpu.instruction = "VXORVY"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "2" Then
			cpu.instruction = "VXANDVY"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "3" Then
			cpu.instruction = "VXXORVY"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "4" Then
			cpu.instruction = "ADC"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "5" Then
			cpu.instruction = "SUBTRACT"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "6" Then
			cpu.instruction = "SHIFTR"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "7" Then
			cpu.instruction = "SUBN"
			Exit Sub
		EndIf
		If Right(opctemp,1) = "E" Then
			cpu.instruction = "SHIFTL"
			Exit sub
		EndIf
	End If
	
	If Left(opctemp,1) = "9" Then
		cpu.instruction = "SKIPNOTEQUALREG"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "A" Then
		cpu.instruction = "LOADINDEX"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "B" Then
		cpu.instruction = "JUMPREG"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "C" Then
		cpu.instruction = "RNDANDKK"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "D" Then
		cpu.instruction = "DISPLAY"
		Exit Sub
	End If
	
	If Left(opctemp,1) = "E" Then
		If Right(opctemp,2) = "9E" Then
			cpu.instruction = "KEYSKIP"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "A1" Then
			cpu.instruction = "KEYNOTSKIP"
			Exit sub
		EndIf
	End If
	
	If Left(opctemp,1) = "F" Then
		If Right(opctemp,2) = "07" Then
			cpu.instruction = "VXDELAY"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "0A" Then
			cpu.instruction = "KEYWAIT"
			Exit sub
		EndIf
		If Right(opctemp,2) = "15" Then
			cpu.instruction = "DELAYSET"
			Exit sub
		EndIf
		If Right(opctemp,2) = "18" Then
			cpu.instruction = "SOUNDSET"
			Exit sub
		EndIf
		If Right(opctemp,2) = "1E" Then
			cpu.instruction = "IPLUSVX"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "29" Then
			cpu.instruction = "ISPRITE"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "33" Then
			cpu.instruction = "BCDSTORE"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "55" Then
			cpu.instruction = "STOREREG"
			Exit Sub
		EndIf
		If Right(opctemp,2) = "65" Then
			cpu.instruction = "LOADREG"
			Exit sub
		EndIf
	End If
	
	cpu.instruction = "BAD DECODE"
	

End Sub
