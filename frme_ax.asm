;print register names in frame
;-----------------------------------
;Entry: ES = 0b800h (set on video memory start addr)
;       BX = attr: start addr of printing
;Exit:  None 
;Destroys: BX
;-----------------------------------
print_regs      proc

                mov byte ptr es:[bx], 'A'
                add bx, 2
                mov byte ptr es:[bx], 'X'
                
                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'B'
                add bx, 2
                mov byte ptr es:[bx], 'X'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'C'
                add bx, 2
                mov byte ptr es:[bx], 'X'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'D'
                add bx, 2
                mov byte ptr es:[bx], 'X'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'S'
                add bx, 2
                mov byte ptr es:[bx], 'I'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'D'
                add bx, 2
                mov byte ptr es:[bx], 'I'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'B'
                add bx, 2
                mov byte ptr es:[bx], 'P'

                add bx, 80d*2d - 2d

                mov byte ptr es:[bx], 'E'
                add bx, 2
                mov byte ptr es:[bx], 'S'

                add bx, 80d*2d - 2d

                ret
                endp 
;------------------------

;-----------------------------------
;Printf BP reg in hexodemical 
;-----------------------------------
;Entry: BP
;Exit: None
;Destroys: AX, BX += 8, CX, DX
;-----------------------------------
Print_h_bp      proc

                mov cx, 0004h
                mov dx, H_mask

@@h_next:       push dx        
                
                and dx, bp      ;write cx byte of ax in dx
                cmp cx, 1
                je @@no_shift
                mov ax, cx
                dec cx
@@dx_shift:     
                shr dx, 4
                loop @@dx_shift
                mov cx, ax
 
@@no_shift:
                cmp dx, 0ah 
                jae @@char_hex
                mov byte ptr es:[bx], dl
                add byte ptr es:[bx], '0'
                jmp @@digit_hex
@@char_hex:     sub dx, 10
                mov byte ptr es:[bx], dl
                add byte ptr es:[bx], 'A'
@@digit_hex:    
                pop dx           ;mov h_mask
                shr dx, 4
                add bx, 2
                loop @@h_next      

                ret
                endp
;-----------------------------------

;-----------------------------------
H_mask          equ 0F000h
;-----------------------------------