%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

; install GDT
    GDT_BASE: 
            dd 0x00000000
            dd 0x00000000
    DES_CODE:
            dd 0x0000FFFF
            dd DES_CODE_HIGH4
    DES_DATA_STACK:   
            dd 0x0000FFFF
            dd DES_DATA_HIGH4
    DES_VIDEO:
            dd 0x80000007   ; (0xbffff - 0xb8000 - 0xfff) >> 12 = 0x0007
            dd DES_VIDEO_HIGH4

    GDT_SIZE equ $ - GDT_BASE
    GDT_LIMIT equ GDT_SIZE - 1
    
    times 60 dq 0           ; 预留 60 个段描述符位置

; selector
    SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0 
    SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0 
    SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0 

; gdt pointer
    gdt_ptr dw GDT_LIMIT
            dd GDT_BASE


; loader
    ; print loader message
    loadermsg db '2 loader in real.'

    loader_start:
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 17
    mov ax, 0x1301
    mov bx, 0x001f
    mov dx, 0x1800
    int 0x10

;-------------------- enter protection mode --------------------
    ;---------- turn on A20 ----------
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    ;---------- load GDT ----------
    lgdt [gdt_ptr]

    ;---------- set cr0 = cr0 or 0x1 ----------
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp dword SELECTOR_CODE:p_mode_start    ; 清空流水线

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'P'

    jmp $
