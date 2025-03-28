; 主引导程序
;--------------------------------------------------
%include "boot.inc"
section mbr vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800  ; 文本模式下，显存内存映射到主存的起始地址
    mov gs, ax  

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
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0       ; 左上角(0, 0)
    mov dx, 184fh  ; 右下角(24, 79)
    int 10h

; 向显存中写入 1 MBR
; 两字节，低字节表示字符本身的编码
; 高字节表示该字符显示时的属性（高 4 位表示背景，低 4 位表示前景）
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0x24 

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0x24 

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0x24 

    mov byte [gs:0x06], 'B'
    mov byte [gs:0x07], 0x24 

    mov byte [gs:0x08], 'R'
    mov byte [gs:0x09], 0x24 

; 加载 bootloader 到内存
    mov eax, LOADER_START_SECTOR    ; 待加载的起始扇区的 LBA 地址
    mov bx, LOADER_BASE_ADDR        ; 写入的地址
    mov cx, 1                       ; 待读入扇区数
    call .rd_disk_m_16               ; 调用 rd_risk_m_16

    jmp LOADER_BASE_ADDR            ; 跳转到 bootloader

;--------------------------------------------------
; 功能：读取硬盘 n 个扇区
;--------------------------------------------------
.rd_disk_m_16:
                                    ; eax   待读取的起始扇区的 LBA 扇区号
                                    ; bx    数据写入的内存地址
                                    ; cx    读取扇区个数  
    mov esi, eax        ; 备份 eax

; 设置要读取的扇区数
    mov dx, 0x1f2 
    mov al, cl
    out dx, al

    mov eax, esi        ; 恢复 eax      

; 存入 LBA 地址
    mov dx, 0x1f3
    out dx, al

    shr eax, 8
    mov dx, 0x1f4
    out dx, al

    shr eax, 8
    mov dx, 0x1f5
    out dx, al

    shr eax, 8
    and al, 0x0F        ; 保留最高 4 位 LBA 地址
    or al, 0xE0         ; 1110 表示读取主设备以及使用 LBA 地址
    mov dx, 0x1f6
    out dx, al

; 写入读取命令 0x20
    mov al, 0x20
    mov dx, 0x1f7
    out dx, al

; 检测读写状态
.not_ready:
    nop
    in al, dx
    and al, 0x88        ; 第三位为 1 表示已准备好 PIO 数据
    cmp al, 0x08
    jnz .not_ready

; 读取数据并写入目标地址
    mov ax, 256         ; 每次读入 16b(2B)，1 个扇区 512B 需要读入 256 次
    mul cx              ; cx 读入扇区数
    mov cx, ax          ; 需要读入次数 

    mov dx, 0x1f0
.go_on_read:
    in ax, dx 
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret
    
    jmp $           ; 使程序悬停在此
                    ; 不该执行到此处

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa

         
