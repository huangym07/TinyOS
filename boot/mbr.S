; 主引导程序
;--------------------------------------------------
section mbr vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

; 利用 0x05 号功能清屏，上卷全部行，则可清屏
;--------------------------------------------------
; int 0x10 功能号:0x06 功能：上卷窗口
;--------------------------------------------------
; 输入：
; AH 功能号 = 0x06
; AL = 上卷的行数(0 表示全部)
; BH = 卷入行的属性
; (CH, CL) = 待卷窗口左上角(row, column)
; (DH, DL) = 待卷窗口右下角(row, column)
; 无返回值
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0       ; 左上角(0, 0)
    mov dx, 0x1008  ; 右下角(16, 8)
    int 0x10

;;;;;;;;;; 获取光标位置 ;;;;;;;;;;
    mov ah, 3       ; 输入：3 号功能获取光标位置
    mov bh, 0       ; bh 存储待获取光标的页号

    int 0x10        ; 输出：(ch, cl) = (光标开始行，光标结束行)
                    ; (dh, dl) = (光标所在行号，光标所在列号)
;;;;;;;;;; 获取光标位置结束 ;;;;;;;;;;

;;;;;;;;;; 打印字符串 ;;;;;;;;;;
; int 0x10 功能号:0x13 功能:打印字符串
    mov ax, message
    mov bp, ax      ; es:bp 为待打印字符串首地址, es 此时同 cs 一致，均为 0x7c00

    mov ax, 0x1301  ; AL=1: 光标跟随字符移动
    mov bx, 0x2     ; BH: page number
                    ; BL: characters' attribute
    mov cx, 18      ; number of characters in string
    int 0x10
;;;;;;;;;; 打印字符串结束 ;;;;;;;;;;

    jmp $           ; 使程序悬停在此

    message db "1 MBR TinyOS's MBR"
    times 510 - ($ - $$) db 0
    db 0x55, 0xaa

         
