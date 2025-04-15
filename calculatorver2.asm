data segment

make_dot db 0    
x_dot_index db 0
y_dot_index db 0
x_float_count db 0
y_float_count db 0
_TEN     dw 10d
x        dw 0    
y        dw 0
buffer   db 6 dup(0),'$'
lenth    dw 0
operand1 db 0
operand2 db 0
key      db 0 
of       db 0 
ng       db 0
xsighn   db 0
ysighn   db 0
;---------------------------------------------------
 
;print lines
;---------------------------------------------------                           
    l0   db 201,21 dup(205),187,'$'
    l8   db 186,21 dup(' '),186,'$';second line
    
    l1   db 186,'   ',201,13 dup(205),187,'   ',186,'$'
    l2   db 186,'   ',186,13 dup(' '),186,'   ',186,'$'
    l3   db 186,'   ',200,13 dup(205),188,'   ',186,'$'
    
    l4   db 186,' ',218,196,191,' ',218,196,191,' ',218,196,191,' ',218,196,191,' ',218,196,191,' ',186,'$'
    l4_2 db 186,' ',218,196,196,196,196,196,191,' ',218,196,191,' ',218,196,191,' ',179,' ',179,' ',186,'$'
    l5   db 186,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',186,'$'
    l5_2 db 186,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',179,' ',179,' ',186,'$'
    l5_3 db 186,' ',179,' ',' ',' ',' ',' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',179,' ',186,'$'
    l6   db 186,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',186,'$'
    l6_2 db 186,' ',192,196,196,196,196,196,217,' ',192,196,217,' ',192,196,217,' ',192,196,217,' ',186,'$'
    l7   db 200,21 dup(205),188,'$'
;---------------------------------------------------                           
ends

;---------------------------------------------------
gotoxy macro x,y        ;move cursor
       pusha
       mov dl,x
       mov dh,y
       mov bx,0
       mov ah,02h
       int 10h 
       popa
endm
;--------------------------------------------------- 
putstr macro buffer     ;print string
       pusha
       mov ah,09h
       mov dx,offset buffer
       int 21h 
       popa
endm
;---------------------------------------------------
putch  macro char,color ;print character
       pusha
       mov ah,09h
       mov al,char
       mov bh,0
       mov bl,color
       mov cx,1
       int 10h 
       popa
endm
;---------------------------------------------------
clear  macro buf
       lea si,buf
       mov [si],' '
       mov [si+1],' '
       mov [si+2],' '
       mov [si+3],' '
       mov [si+4],' '
       mov [si+5],' '
       gotoxy 15,3
       putstr buf
endm
;---------------------------------------------------


number_in  macro  n,operand,lenth,dot_index,float_count,sign
    local l1,l1_2,l1_2_1,l1_3,l1_3_1
    local l2,l3,l4
    local next_step,next_step1,store_operand
 
    pusha
    mov sign, 0
    mov float_count, 0
    
    mov lenth, 0
    mov make_dot, 0
    mov dot_index, 0
    
    l1:
        mov ah, 08h    ;read keyboard input with echo
        int 21h
        mov key, al
        
    l1_2: 
        cmp lenth, 0    ;first time, clear screen
        jne l1_2_1
        cmp sign, 1
        je l1_2_1
        clear buffer
        putstr buffer
        gotoxy 17,3
    l1_2_1:    
        mov al, key     ;check if it's a number or valid character
        cmp al, '_'
        jne next_step1
        mov xsighn, 1
        mov dl, '-'
        mov ah, 02h
        int 21h
        jmp l1
    next_step1:    
        cmp al, '.'
        jne next_step
         
        cmp make_dot, 0
        jne l2
        inc make_dot
        mov ax, lenth
        inc ax
        mov dot_index, al
        mov ah, 02h
        mov dl, '.'
        int 21h
        jmp l1
        
    next_step:        
        cmp al, 48  
        jb l2                        
        cmp al, 58 
        ja l2                               
                                       
    l1_3:                             
        mov [si], al
        pusha
         
        mov ah, 02h
        mov dx, [si]
        int 21h    
       
        inc si 
        inc lenth
       
        cmp make_dot, 0
        je l1_3_1
        inc float_count
        
    l1_3_1:    
        cmp lenth, 6 ;just receive 5 digits + 1
        jne l1
    ;........................     
    l2:                     ;check for operators or equals
        cmp al, '+'
        je store_operand
        cmp al, '-'
        je store_operand
        cmp al, '*'
        je store_operand
        cmp al, '/'
        je store_operand
        cmp al, '='
        je store_operand
        jmp l1          ;ignore invalid input
    ;........................
    store_operand:
        mov dx, 0
        cmp lenth, 0
        je l4
        mov operand, al ;store operand 
        lea si, buffer
        mov cx, lenth
        mov bx, 10
        l3:         ;make number
            mov ax, dx
            mul bx
            mov dx, ax
            mov ah, 0
            mov al, [si]
            sub al, 48
            add dx, ax
            inc si
            loop l3
        mov n, dx
    l4:
        mov n, dx
        gotoxy 24,3
        popa
endm     
;---------------------------------------------------
putrez macro buffer,x
       local next_digit,pz1,pz2
       local nex1,nex2
     
       pusha
       mov ax,x             ;convert <int> to <str>
       mov cl,x_float_count
       clear buffer
       lea si,buffer               
       mov bx,10             
       mov [si+5],'0'
       mov [si+4],'.'
       mov [si+3],'0'
       
    ;........................                         
       next_digit: 
        cmp cl,0
        jne nex1
        cmp x_float_count,0
        jne nex2
        
        mov [si+5],'0'
        dec si
    nex2:    
        mov dl,'.'
        mov [si+5],dl
        dec si
        dec cl
        dec x_float_count
        jmp next_digit
         
    nex1:
        mov dx,0           ; buffer 
        div bx             
        add dl,48          
        mov [si+5],dl
        dec si
        dec cl
        cmp ax,0
        jne next_digit
         
     
   ;.........................          
       gotoxy 17,3          ;print buffer
       putstr buffer 
        
       cmp of,1             ;print overflow mark
       jne pz1 
       gotoxy 27,3
       putch 'F',15
       jmp pz2              ;print xsighn
   pz1:
       cmp xsighn,1
       jne pz2
       gotoxy 15,3
       putch '-',15
   pz2:
       popa
endm
;---------------------------------------------------
reset macro
       mov x,0
       mov y,0 
       mov xsighn,0
       mov ysighn,0
       mov of,0
       clear buffer
       mov key,0
       mov operand1,0
       mov operand2,0
endm


code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
 
;--------------------------------------------------
;--------------------------------------------------
;---  C A L C U L A T O R E -------- P R O C ------
;--------------------------------------------------
;--------------------------------------------------

call print_screen    
 
begin:
      reset
      calc1:
          ;putrez buffer,x   ;print x
          number_in x,operand1,lenth,x_dot_index,x_float_count,xsighn
          mov al,operand1
          cmp al,'='  
          je calc1           ;if '=' pressed, restart
          ;operand1 should be an operator (+,-,*,/)
      calc2:
          number_in y,operand2,lenth,y_dot_index,y_float_count,ysighn
          mov al,operand2
          cmp al,'='
          jne calc1          ;if not '=', restart (invalid input)
          call calculate     ;x = x (operand1) y
          putrez buffer,x    ;display result
          jmp calc1          ;start again for new calculation
 
;--------------------------------------------------
;--------------------------------------------------
;-------------  F U N C T I O N S -----------------
;--------------------------------------------------
;--------------------------------------------------
 
print_screen proc :
        gotoxy 10,0;...........
        putstr l0
        gotoxy 10,1
        putstr l8
        gotoxy 10,2;........  ;
        putstr l1          ;  ;
        gotoxy 10,3        ;  ;out cadr
        putstr l2          ;  ;
        gotoxy 10,4        ;  ;
        putstr l3          ;  ;
        gotoxy 10,5;...... ;  ;
        putstr l4        ; ;result board + exit key
        gotoxy 10,6      ; ;  ;
        putstr l5        ; ;  ;
        gotoxy 10,7      ; ;  ;
        putstr l6        ; ;  ;
        gotoxy 10,8      ; ;  ;
        putstr l4        ; ;  ;
        gotoxy 10,9      ;key board
        putstr l5        ; ;  ;
        gotoxy 10,10     ; ;  ;
        putstr l6        ; ;  ;
        gotoxy 10,11     ; ;  ;
        putstr l4        ; ;  ;
        gotoxy 10,12     ; ;  ;
        putstr l5        ; ;  ;
        gotoxy 10,13     ; ;  ;
        putstr l5_2      ; ;  ;
        gotoxy 10,14     ; ;  ;
        putstr l4_2      ; ;  ;
        gotoxy 10,15;..... ;  ;
        putstr l5_3      ;  ;
        gotoxy 10,16;.......  ;  
        putstr l6_2      ;
        gotoxy 10,17    
        putstr l7 
        
         
        ;keyboard labels
        
        gotoxy 31,1
        putch 'x',4
        gotoxy 13,6
        putch '7',11
        gotoxy 17,6
        putch '8',11
        gotoxy 21,6
        putch '9',11
        gotoxy 25,6
        putch '/',10
        gotoxy 29,6
        putch 'C',10
        gotoxy 13,9
        putch '4',11
        gotoxy 17,9
        putch '5',11
        gotoxy 21,9
        putch '6',11
        gotoxy 25,9
        putch '*',10
        gotoxy 29,9
        putch 241,10
        gotoxy 13,12
        putch '1',11
        gotoxy 17,12
        putch '2',11
        gotoxy 21,12
        putch '3',11
        gotoxy 25,12
        putch '-',10
        gotoxy 29,13
        putch '=',10
        gotoxy 15,15
        putch '0',11
        gotoxy 21,15
        putch '.',10
        gotoxy 25,15
        putch '+',10       
          
       
print_screen endp
;--------------------------------------------------
 
calculate proc near
    
    cmp operand1,'+'
    je pluss
    cmp operand1,'-'
    je miness
    cmp operand1,'*'
    je mulplus
    cmp operand1,'/'
    je devide
    jmp begin   ;no match found!

            pluss:              
                        mov ax,x
                        add ax,y                        
                            mov x,ax
                            ret                   
                                                                              
            miness:                                
                mov ax,x
                cmp ax,y
                jae mi3
                jb mi4
                
                mi3:            ; neu x >= y 
                    mov ax,x
                    sub ax,y
                    mov x,ax
                    mov xsighn,0
                    ret
                mi4:            ; neu x  < y , cho xsighn = 1 de lam dau - ;
                    mov ax,y
                    sub ax,x
                    mov x,ax
                    mov xsighn,1
                    ret
                    
           mulplus:
                    mov ax, x
                    mov bx, y
                    mul bx       ; nhân x * y, k?t qu? trong AX (n?u không tràn)
                    mov x, ax
                    ret
       
                   
                            
            devide:
                    xor dx, dx
                    mov ax, x
                    mov bx, 10
                    mul bx           
                    mov bx, y
                    xor dx, dx
                    div bx           
                    mov x, ax        ;
                    mov x_float_count, 1  ; 
                    ret                    
calculate endp
;---------------------------------------------------                           
 
exit:
 
    mov ax, 4c00h ; exit 
    int 21h    
ends
 
end start
