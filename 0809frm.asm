.286
.model tiny
.code
locals @@
org 100h

;--BRIEF
;the programm prints frame with constanly updating (on int 08h) registers in videomem in 09h interrupt with saving videomem (three-bufferized mem)
;-------


include         ../macros/vidmem.asm 
include         ../macros/exit.asm 

Start:          cli

                xor bx, bx
                mov es, bx
                mov bx, 4*9             ;9 ячейка таблицы прерываний    
                
                mov ax, es:[bx]         ;-|
                mov Old09ofs, ax        ; |
                mov ax, es:[bx+2]       ; |set latest function addr
                mov Oldo9seg, ax        ;-|
                
                mov es:[bx], offset print_fr_09h
                mov cx, cs 
                mov es:[bx+2], cx

                sub bx, 4               ;8 ячейка таблицы прерываний    
                
                mov ax, es:[bx]         ;-|
                mov Old08ofs, ax        ; |
                mov ax, es:[bx+2]       ; |set latest function addr
                mov Oldo8seg, ax        ;-|
                
                mov es:[bx], offset print_fr_08h
                mov es:[bx+2], cx

                sti 

                mov ax, 3100h       ;ending programm but stays on dos as resident
                mov dx, offset EOP  ;
                shr dx, 4           ;paragraph num for allocating memory for resident in dx
                inc dx              ;
                int 21h

;-----------------------------------
;Function instead defolt interrupt 08h updating frame with registers if it is printed
;-----------------------------------
;Entry: None
;Exit: None
;Destroys: None
;-----------------------------------
print_fr_08h    proc 
 
                push si 

                mov si, offset status   ;-|
                cmp byte ptr cs:[si], 1 ;-|check status of frame printing
                jne @@old_func 


                pop si
                push ax bx cx dx di si bp es 
                
                cli                     ;-|
                call frame_09h          ;-|print frame in case status == 1
                sti 


                mov al, 20h             ;-|
                out 20h, al             ;-|mov 20 in 20h port to end the process of interrupt treating
                
                pop es bp si di dx cx bx ax 

                jmp @@end  

@@old_func:
                pop si
                
@@end:          
                db 0eah                 ; jmp on long addr (addr of latest resident or proc prog)
Old08ofs        dw 0                    ; offset of latest func for long address
Oldo8seg        dw 0                    ; segment addr for long addr

                iret
                endp 
;-----------------------------------

;-----------------------------------
;Function instead defolt interrupt 09h prog for printing or cleaning frame with registers on hot keys
;-----------------------------------
;Entry: None
;Exit: None
;Destroys: None
;-----------------------------------
print_fr_09h    proc 

                push ax 

                in al, 60h              ;-|mov contents of 60h port in al
                cmp al, 3               ;-|
                je @@print_saved        ; |
                cmp al, 131d            ; |print save buffer (vidmem without frame) in case key '2' is pushed
                je @@print_saved        ;-|

                cmp al, 2               ;-|
                jne @@old_func          ;-|call latest resident or standart handler of 09h in case al is 2

                
                pop ax                  ;-|
                push ax bx cx si es dx ds  
                cli
                call frame_09h          ;-|print frame with programm register values
                
                mov si, offset status   ;-|
                mov byte ptr cs:[si], 1 ;-|set status of frame printing
                sti

                pop ds dx 

                jmp @@func_end  
@@print_saved:
                push bx cx si es  

                mov si, offset status   ;-|
                mov byte ptr cs:[si], 0 ;-|set status of no frame printing
                
                mov si, offset save     ;-| 
                call print_saved        ;-|print saved image of vidmem

@@func_end:     in al, 61h              ;-|
                or al, 80h              ; |
                out 61h, al             ; |blinking by 61h port
                and al, not 80h         ; |
                out 61h, al             ;-|
                
                mov al, 20h             ;-|
                out 20h, al             ;-|mov 20 in 20h port to end the process of interrupt treating
                
                pop es si cx bx ax  
                jmp @@end 
@@old_func:
                pop ax 

                db 0eah                 ; jmp on long addr (addr of latest resident or proc prog)
Old09ofs        dw 0                    ; offset of latest func for long address
Oldo9seg        dw 0                    ; segment addr for long addr

@@end:          
                iret
                endp 
;-----------------------------------

include         f_frme.asm 

EOP:        

end         Start