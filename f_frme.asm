;-----------------------------------
;prints frame using three-bufferized mem
;-----------------------------------
;Entry: None
;Exit:None
;Destroys:AX, BX, CX, DX, SI, DI, ES
;-----------------------------------
frame_09h       proc 

                push bp es di si dx cx bx ax 

                mov si, offset draw
                mov bp, offset save 
                
                call save_mem_cmp
                
                push cs
                pop es
                
                mov ax, offset draw 
                
                lea di, framee

                call buff_frameprint        ;-|

                push cs
                pop es 

                mov bx, offset draw         ; |
                add bx, 160d + 4d           ; |
                                            ; |
                call print_regs             ; |
                mov bx, offset draw 
                add bx, 160d + 10d

                mov di, 8d
                
@@next_print:   
                pop bp  
                call Print_h_bp
                add bx, 160d - 8d
                dec di 
                cmp di, 0
                jne @@next_print 

                mov si, offset draw 
                call draw_to_mem

                ret
                endp 
;-----------------------------------
;-----------------------------------
;saves videomem in buffer (save buffer) for time interrupt is processing 
;-----------------------------------
;Entry: SI := attr: start addr of draw in mem buffer
;       BP := attr: start addr of save mem buffer
;Exit:
;Destorys: AX, BX, CX, ES = 0B800h, SI, DI
;-----------------------------------
save_mem_cmp    proc

                LoadVideoES
                
                mov cx, 80d*25d
                xor bx, bx
                
                mov di, offset status 
                cmp byte ptr cs:[di], 0
                je @@copy
                jmp @@cmpre 

@@next:        
                cmp cx, 0
                je @@end 

                dec cx 
                
                add si, 2
                add bx, 2
                add bp, 2

@@cmpre:        mov ax, word ptr cs:[si]
                cmp ax, 0
                je @@cmp_saved
                cmp word ptr es:[bx], ax
                je @@next

                mov ax, word ptr es:[bx]
                mov word ptr cs:[bp], ax 
                jmp @@next

@@cmp_saved:    mov ax, word ptr es:[bx]
                cmp word ptr cs:[bp], ax
                je @@next 
                mov word ptr cs:[bp], ax
                jmp @@next 

@@next_copy:    add bx, 2
                add bp, 2 
@@copy:         mov ax, word ptr es:[bx]
                mov word ptr cs:[bp], ax
                loop @@next_copy
                
@@end:          
                ret 
                endp 
;-----------------------------------

;-----------------------------------
;copies draw buffer to mem
;-----------------------------------
;Entry: SI := attr: start addr of draw buffer
;Exit:
;Destroys: AL, BX, CX, SI += 160d*25d, ES = 0B800h
;-----------------------------------
draw_to_mem     proc 

                mov cx, 160d*25d 

                LoadVideoES
                xor bx, bx

@@next:         mov al, byte ptr cs:[si]
                cmp al, 0
                je @@no_copy
                mov byte ptr es:[bx], al 
@@no_copy:      inc bx
                inc si 
                loop @@next 

                ret
                endp 
;-----------------------------------
;-----------------------------------
;copies draw buffer to mem
;-----------------------------------
;Entry: SI := attr: start addr of save buffer
;Exit:
;Destroys: AL, BX, CX, SI += 160d*25d, ES = 0B800h
;-----------------------------------
print_saved     proc 

                mov cx, 160d*25d 

                LoadVideoES
                xor bx, bx

@@next:         mov al, byte ptr cs:[si]
                mov byte ptr es:[bx], al 
                inc bx
                inc si 
                loop @@next 

                ret
                endp 
;-----------------------------------

include         ../show_ax/f_show.asm
include         buff_fr.asm
include         frme_ax.asm

status:         db 0
framee:         db ' 12 10 7C 1 ', "' '"
draw:           db 25 dup (160 dup(0))
save:           db 25 dup (160 dup(0))