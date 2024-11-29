TITLE Enhanced Digital Watch (Test.asm)
INCLUDE Irvine32.inc
.data
    hours   BYTE ?
    minutes BYTE ?
    seconds BYTE ?
    sysTime SYSTEMTIME <>
    lastSecond BYTE ?    ; To track second changes
    inputMinMsg   BYTE "Enter minutes (0-59): ", 0
    inputSecMsg   BYTE "Enter seconds (0-59): ", 0
    invalidMsg    BYTE "Invalid input! Seconds must be between 0-59.", 0dh, 0ah, 0
    timeMsg    BYTE "Time remaining: ", 0

    ; End message ASCII art
endMsg1 BYTE "  _______ _____ __  __ ______     _____ _______ ____  _____   ____ ", 0dh, 0ah
BYTE " |__   __|_   _|  \/  |  ____|   / ____|__   __/ __ \|  __ \ / ____|", 0dh, 0ah
BYTE "    | |    | | | \  / | |__     | (___    | | | |  | | |__) | (___  ", 0dh, 0ah
BYTE "    | |    | | | |\/| |  __|     \___ \   | | | |  | |  ___/ \___ \ ", 0dh, 0ah
BYTE "    | |   _| |_| |  | | |____    ____) |  | | | |__| | |     ____) |", 0dh, 0ah
BYTE "    |_|  |_____|_|  |_|______|  |_____/   |_|  \____/|_|    |_____/ ", 0dh, 0ah, 0

    ; Menu strings
    menuStr     BYTE "Digital Watch Menu", 0dh, 0ah
                BYTE "----------------", 0dh, 0ah
                BYTE "1. Clock", 0dh, 0ah
                BYTE "2. Stopwatch", 0dh, 0ah
                BYTE "3. Timer", 0dh, 0ah
                BYTE "4. Exit", 0dh, 0ah, 0dh, 0ah
                BYTE "Choose option (1-4): ", 0

    stopwatchPrompt BYTE "Stopwatch Controls:", 0dh, 0ah
                   BYTE "----------------", 0dh, 0ah
                   BYTE "SPACE - Start/Pause", 0dh, 0ah
                   BYTE "R - Reset", 0dh, 0ah
                   BYTE "ESC - Back to menu", 0dh, 0ah, 0

    ; Stopwatch variables
    swMinutes   DWORD 0
    swSeconds   DWORD 0
    swMilli    DWORD 0
    isRunning   BYTE 0    ; 0 = stopped, 1 = running

    ; Month names array
    monthNames BYTE "January  ", 0
              BYTE "February ", 0
              BYTE "March    ", 0
              BYTE "April    ", 0
              BYTE "May      ", 0
              BYTE "June     ", 0
              BYTE "July     ", 0
              BYTE "August   ", 0
              BYTE "September", 0
              BYTE "October  ", 0
              BYTE "November ", 0
              BYTE "December ", 0
   
    dateStr   BYTE " , ", 0
    yearStr   BYTE ", ", 0

    ; Digital display patterns
    digit0 BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    digit1 BYTE "   ?   ", 0
           BYTE "  ??   ", 0
           BYTE "   ?   ", 0
           BYTE "   ?   ", 0
           BYTE "   ?   ", 0
           BYTE "   ?   ", 0
           BYTE "  ???  ", 0

    digit2 BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE "    ?  ", 0
           BYTE "   ?   ", 0
           BYTE "  ?    ", 0
           BYTE " ?     ", 0
           BYTE " ????? ", 0

    digit3 BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE "     ? ", 0
           BYTE "   ??  ", 0
           BYTE "     ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    digit4 BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE " ????? ", 0
           BYTE "     ? ", 0
           BYTE "     ? ", 0
           BYTE "     ? ", 0

    digit5 BYTE " ????? ", 0
           BYTE " ?     ", 0
           BYTE " ?     ", 0
           BYTE " ????  ", 0
           BYTE "     ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    digit6 BYTE "  ???  ", 0
           BYTE " ?     ", 0
           BYTE " ?     ", 0
           BYTE " ????  ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    digit7 BYTE " ????? ", 0
           BYTE "     ? ", 0
           BYTE "     ? ", 0
           BYTE "    ?  ", 0
           BYTE "   ?   ", 0
           BYTE "  ?    ", 0
           BYTE " ?     ", 0

    digit8 BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    digit9 BYTE "  ???  ", 0
           BYTE " ?   ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???? ", 0
           BYTE "     ? ", 0
           BYTE " ?   ? ", 0
           BYTE "  ???  ", 0

    colon  BYTE "   ", 0
           BYTE " ? ", 0
           BYTE " ? ", 0
           BYTE "   ", 0
           BYTE " ? ", 0
           BYTE " ? ", 0
           BYTE "   ", 0

    digitHeight = 7
    digitWidth = 8
    numberPtr DWORD digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9

.code
main PROC
    call Clrscr

menuLoop:
    ; Clear screen and set color
    call Clrscr
    mov eax, white + (black * 16)
    call SetTextColor

    ; Display menu
    mov dh, 5
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuStr
    call WriteString
   
    ; Get user input
    call ReadChar
   
    ; Process menu choice
    cmp al, '1'
    je clockMode
    cmp al, '2'
    je stopwatchMode
    cmp al, '3'
    je getInput
    cmp al, '4'
    je exitProgram
    jmp menuLoop

clockMode:
    call Clrscr
    call RunClock
    jmp menuLoop

stopwatchMode:
    call Clrscr
    call RunStopwatch
    jmp menuLoop

getInput :
call Clrscr
; Get input minutes
mov edx, OFFSET inputMinMsg
call WriteString
call ReadDec
mov minutes, al

; Get input seconds
mov edx, OFFSET inputSecMsg
call WriteString
call ReadDec

; Validate seconds input(0 - 59)
cmp al, 59
ja invalidInput
mov seconds, al
jmp startTimer

invalidInput :
mov edx, OFFSET invalidMsg
call WriteString
jmp getInput

startTimer :
; Start timer loop
timerLoop :
call Clrscr


mov dh, 8; Row
mov dl, 25; Column
call Gotoxy


movzx eax, minutes
mov bl, 10
div bl
movzx ebx, al; First digit
push ax
call DisplayDigit

pop ax
movzx ebx, ah; Second digit
call DisplayDigit

; Display colon
call DisplayColon

; Display seconds
movzx eax, seconds
mov bl, 10
div bl
movzx ebx, al; First digit
push ax
call DisplayDigit

pop ax
movzx ebx, ah; Second digit
call DisplayDigit

; Check if timer is done
cmp minutes, 0
jne continueTimer
cmp seconds, 0
je timerDone

continueTimer :
mov eax, 500
call Delay

; Update timer
cmp seconds, 0
jne decrementSeconds
dec minutes
mov seconds, 59
jmp timerLoop

decrementSeconds :
dec seconds
jmp timerLoop

timerDone :
call Clrscr

; Set color to bright red for end message
mov eax, lightRed + (black * 16)
call SetTextColor

mov dh, 8; Row
mov dl, 5; Column
call Gotoxy
mov edx, OFFSET endMsg1
call WriteString

; Wait for any key before exit
call ReadChar
jmp menuLoop
main ENDP

RunClock PROC
    mov lastSecond, 0FFh    ; Initialize

clockLoop:
    ; Get system time
    INVOKE GetLocalTime, ADDR sysTime
   
    ; Check the last second
    mov al, byte ptr sysTime.wSecond
    cmp al, lastSecond
    je checkClockEscape
    mov lastSecond, al

    ; Clear screen and set color
    call Clrscr
    mov eax, lightCyan + (black * 16)
    call SetTextColor

    ; Center Position for clock
    mov dh, 8    
    mov dl, 25  
    call Gotoxy

    ; Display hours
    movzx eax, sysTime.wHour
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax        
    call DisplayDigit
   
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display colon
    call DisplayColon

    ; Display minutes
    movzx eax, sysTime.wMinute
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax
    call DisplayDigit
   
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display colon
    call DisplayColon

    ; Display seconds
    movzx eax, sysTime.wSecond
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax
    call DisplayDigit
   
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display date
    mov dh, 16    
    mov dl, 25    
    call Gotoxy

    ; Display month name
    movzx eax, sysTime.wMonth
    dec eax  
    mov ebx, 10  
    mul ebx
    lea edx, monthNames
    add edx, eax
    call WriteString

    ; Date separator
    mov edx, OFFSET dateStr
    call WriteString

    ; Display day
    movzx eax, sysTime.wDay
    call WriteDec

    ; Year separator
    mov edx, OFFSET yearStr
    call WriteString

    ; Display year
    movzx eax, sysTime.wYear
    call WriteDec

checkClockEscape:
    ; Check for ESC key
    mov eax, 50
    call Delay
   
    call ReadKey
    jz clockLoop    ; No key pressed
   
    cmp al, 27    ; ESC key
    jne clockLoop
   
    ret
RunClock ENDP

RunStopwatch PROC
    LOCAL startTime:DWORD
   
    ; Display controls
    call Clrscr
    mov dh, 2
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET stopwatchPrompt
    call WriteString
   
    ; Initialize stopwatch
    mov swMinutes, 0
    mov swSeconds, 0
    mov swMilli, 0
    mov isRunning, 0
   
stopwatchLoop:
    ; Set position and color for stopwatch display
    mov dh, 8
    mov dl, 25
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
   
    ; Display minutes
    mov eax, swMinutes
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax        
    call DisplayDigit
   
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display colon
    call DisplayColon
   
    ; Display seconds
    mov eax, swSeconds
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax        
    call DisplayDigit
   
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display point and milliseconds
    mov dh, 16
    mov dl, 25
    call Gotoxy
    mov al, '.'
    call WriteChar
   
    mov eax, swMilli
    .IF eax < 100
        mov al, '0'
        call WriteChar
    .ENDIF
    .IF eax < 10
        mov al, '0'
        call WriteChar
    .ENDIF
    call WriteDec
   
    ; Check for key press
    mov eax, 0    ; Small delay
    ;call Delay
    call ReadKey
    jz updateStopwatch
   
    ; Process key
    .IF al == 27    ; ESC
        ret
    .ELSEIF al == ' '    ; Space
        xor BYTE PTR isRunning, 1
    .ELSEIF al == 'r' || al == 'R'    ; Reset
        mov swMinutes, 0
        mov swSeconds, 0
        mov swMilli, 0
        mov isRunning, 0
    .ENDIF
   
updateStopwatch:
    cmp isRunning, 0
    je stopwatchLoop
   
    ; Update milliseconds
    add swMilli, 2
    cmp swMilli, 1000
    jb stopwatchLoop
   
    ; Reset milliseconds and increment seconds
    mov swMilli, 0
    inc swSeconds
    cmp swSeconds, 60
    jb stopwatchLoop
   
    ; Reset seconds and increment minutes
    mov swSeconds, 0
    inc swMinutes
   
    jmp stopwatchLoop
RunStopwatch ENDP

DisplayDigit PROC
    push eax
    push ecx
    push edx
    push esi

    mov esi, DWORD PTR numberPtr[ebx * 4]
    mov ecx, digitHeight    ; Number of rows

displayLoop:
    push ecx
    push dx
   
    ; Display current row
    mov edx, esi
    call WriteString
   
    ; Move pointer to next row
    pop dx
    inc dh
    call Gotoxy
   
    ; Move to next row in pattern
    add esi, digitWidth
   
    pop ecx
    loop displayLoop

    ; Move cursor for next digit
    pop esi
    pop edx
    add dl, digitWidth
    call Gotoxy
   
    pop ecx
    pop eax
    ret
DisplayDigit ENDP

DisplayColon PROC
    push eax
    push ecx
    push edx
    push esi

    lea esi, colon
    mov ecx, digitHeight

colonLoop:
    push ecx
    push dx
   
    mov edx, esi
    call WriteString
   
    pop dx
    inc dh
    call Gotoxy
   
    add esi, 4    ; Width of colon pattern + null terminator
   
    pop ecx
    loop colonLoop

    pop esi
    pop edx
    add dl, 4    ; Move cursor past colon
    call Gotoxy
   
    pop ecx
    pop eax
    ret
DisplayColon ENDP
exitProgram:
exit

END main
