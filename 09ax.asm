.286
.model tiny
.code
locals @@
org 100h

;the programm prints ax in videomem in 09h interrupt

include         ../macros/vidmem.asm 
include         ../macros/exit.asm 

Start:      cli

            xor bx, bx
            mov es, bx
            mov bx, 4*9             ;9 ячейка таблицы прерываний    
            
            mov ax, es:[bx]         ;-|
            mov Old09ofs, ax        ; |
            mov ax, es:[bx+2]       ; |set latest function addr
            mov Oldo9seg, ax        ;-|
            
            mov es:[bx], offset Print_ax_09h
            mov ax, cs 
            mov es:[bx+2], ax

            sti 

            mov ax, 3100h       ;ending programm but stays on dos as resident
            mov dx, offset EOP  ;
            shr dx, 4           ;paragraph num for allocating memory for resident in dx
            inc dx              ;
            int 21h

;-----------------------------------
;Function instead defolt interrupt 09h prog for work with key pushing or resetting
;-----------------------------------
;Entry: None
;Exit: None
;Destroys: None
;-----------------------------------
Print_ax_09h    proc 

                push ax bx cx dx si di es bp ax

                in al, 60h              ;mov contents of 60h port in al
                cmp al, 2               ;call latest resident or standart handler of 09h in case al is 2
                jne @@old_func           
                
                LoadVideoES
                mov bx, 160d*5 + 80d+12 ;mov place on screen

                ;mov di, offset framee 
                ;mov al, [di+6]
                ;mov byte ptr es:[bx-2], al
                
                pop ax 
                call Print_h_ax         ;some not understandable problems with hex func!!!!!!!!!!!!!!!!!!!!!1
               
                mov ah, 0FCh
                mov byte ptr es:[bx-7], ah 
                mov byte ptr es:[bx-5], ah 
                mov byte ptr es:[bx-3], ah 
                mov byte ptr es:[bx-1], ah 

                in al, 61h              ;-|
                or al, 80h              ; |
                out 61h, al             ; |blinking by 61h port
                and al, not 80h         ; |
                out 61h, al             ;-|
                

                mov al, 20h             ;-|
                out 20h, al             ;-|mov 20 in 20h port to end the process of interrupt treating

                jmp @@two_func

;framee:         db "0 0 40 20 FC 0 DAC4BFB320B3C0C4D9 'yeah!'"
@@old_func:     pop ax 
@@two_func:     pop bp es di si dx cx bx ax 

                db 0eah     ;jmp on long addr (addr of latest resident or proc prog)
Old09ofs        dw 0        ;offset of latest func for long address
Oldo9seg        dw 0        ;segment addr for long addr

                endp 
;-----------------------------------

include         ../show_ax/f_show.asm

EOP:        

end         Start