; LogHoloEnRpgPersonalityQuiz.ahk
; 
; This script generates the Choices and Results columns of the CombinationsList
; tab of this spreadsheet (holoEN RPG Personality Quiz Data):  
; https://docs.google.com/spreadsheets/d/1uCNcwZgxWc0I8WEW3X80SNoRGYCGAj2tdIIb2Xf3wbo/pubhtml
; 
; A quiz choice is represented by a digit ranging from 1 to 4.
; A combination of choices is a string of 5 choices.
; 
; llamatar
; 2024-08-23

#SingleInstance, Force
#Persistent

QuizUrl := "https://hololive-rpg-personalityquiz.belugacpn.jp/"
OutputFile := "LogHoloEnRpgPersonalityQuizCombinations.csv"


; Click tray icon or menu options to activate this script.
Menu, Tray, Add
Menu, Tray, Add, Open Quiz Page, OpenQuizPage

Menu, Tray, Add, Get Quiz Result, LogHoloEnRpgPersonalityQuizMain
Menu, Tray, Default, Get Quiz Result
Menu, Tray, Click, 1

Menu, Tray, Add, Log All Results, LogAllResults


OpenQuizPage() {
	; Opens the quiz webpage in the browser.
	global QuizUrl

	; Hardcoded: Brave browser
	Run, brave.exe %QuizUrl%
	Sleep, 3000
}


LogHoloEnRpgPersonalityQuizMain() {
	; Toggle this flag to log result from user input.
	LogFlag := false
	
	GetResultFromUserInput(LogFlag)
}


LogAllResults() {
	; Logs all results from 11111 to 44444 (takes about 2 hours).
	
	; Populate this with one large string of comment-separated choices to skip them.
	AlreadyLoggedList := "00000,00000,00000"
	
	LogResults(1,1,1,1,1,AlreadyLoggedList)
}


GetResultFromUserInput(LogFlag := false) {
	; Prompts user for choices and gets the quiz result.
	Choices := "11314"
	InputBox, Choices, , , , 100, 100, , , , , %Choices%
	If (ErrorLevel)
		Return
	
	Q1 := SubStr(Choices, 1, 1)
	Q2 := SubStr(Choices, 2, 1)
	Q3 := SubStr(Choices, 3, 1)
	Q4 := SubStr(Choices, 4, 1)
	Q5 := SubStr(Choices, 5, 1)
	
	OpenQuizPage()
	
	Result := GetResult(Q1, Q2, Q3, Q4, Q5, LogFlag)
	
	MsgBox, Result of %Choices%: %Result%
}


GetResult(Q1, Q2, Q3, Q4, Q5, LogFlag := false) {
	; Returns the quiz result for the given choices.
	; Logs the result if LogFlag is true.
	global OutputFile
	
	; Hardcoded: wait time for webpage to load after each choice selection
	SleepTime := 1000

	; Enter quiz choices
	Send, {Tab}{Enter}
	Sleep, %SleepTime%
	Send, {Tab %Q1%}{Enter}
	Sleep, %SleepTime%
	Send, {Tab %Q2%}{Enter}
	Sleep, %SleepTime%
	Send, {Tab %Q3%}{Enter}
	Sleep, %SleepTime%
	Send, {Tab %Q4%}{Enter}
	Sleep, %SleepTime%
	Send, {Tab %Q5%}{Enter}
	Sleep, %SleepTime%
	
	; Try to copy result to clipboard
	Loop, 3 {
		; Hardcoded: mouse positions for my screen
		MouseClickDrag, Left, 692, 692, 692, 732
		Clipboard := ""
		Send, ^c
		ClipWait, 1
		If (not ErrorLevel)
			Break
	}
	
	; Clean clipboard
	Clipboard := Trim(Clipboard)
	StringReplace, Clipboard, Clipboard, `n, , All
	StringReplace, Clipboard, Clipboard, `r, , All
	
	If (LogFlag) {
		Line := Q1 Q2 Q3 Q4 Q5 "," Clipboard
		FileAppend, %Line%`n, %OutputFile%
	}
	
	Return Clipboard
}


LogResults(Q1, Q2, Q3, Q4, Q5, AlreadyLoggedList:="") {
	; Gets each quiz result starting from the given choices up to 44444, skipping the ones in AlreadyLoggedList, and logs them in the output file.
	LogCount := 0
	
	OpenQuizPage()
	
	Loop {
		Choices := Q1 Q2 Q3 Q4 Q5
		
		; This line must be formatted this way because "in" operator cannot be used in expression.
		if Choices not in %AlreadyLoggedList%
		{
			GetResult(Q1, Q2, Q3, Q4, Q5, true)
			LogCount++
			
			Send, {Tab 3}{Enter}
			Sleep, 1000
		}
		
		; Increment quiz choices to produce all possible combinations
		If (++Q5 <= 4)
			Continue
		Q5 := 1
		
		If (++Q4 <= 4)
			Continue
		Q4 := 1
		
		If (++Q3 <= 4)
			Continue
		Q3 := 1
		
		If (++Q2 <= 4)
			Continue
		Q2 := 1
		
		If (++Q1 <= 4)
			Continue
		Break
	}
	
	MsgBox, LogResults completed.`n%LogCount% results logged.
}