;-------------------- loader and kernel --------------------
LOADER_BASE_ADDR equ 0x900  ; bootloader 加载到内存的位置
LOADER_START_SECTOR equ 0x2 ; bootloader 在硬盘中的扇区号(LAB 编址法)

;-------------------- GDT Descriptor Attributes --------------------
DES_G_4K            equ     100000000000000000000000b

DES_D_32            equ      10000000000000000000000b

DES_L               equ       0000000000000000000000b       ; 64 位标记码，标记为 0

DES_AVL             equ        000000000000000000000b

DES_LIMIT_CODE2     equ         11110000000000000000b
DES_LIMIT_DATA2     equ     DES_LIMIT_CODE2
DES_LIMIT_VIDEO2    equ         00000000000000000000b

DES_P               equ             1000000000000000b

DES_DPL_0           equ              000000000000000b       ; 数字越小，权限越高
DES_DPL_1           equ              010000000000000b
DES_DPL_2           equ              100000000000000b
DES_DPL_3           equ              110000000000000b

DES_S_CODE          equ                1000000000000b
DES_S_DATA          equ                DES_S_CODE
DES_S_SYS           equ                0000000000000b

DES_TYPE_CODE       equ                 100000000000b
                                    ;   xcra    
                                    ;   x = 1 代码段可执行
                                    ;   c = 0 代码段非一致性
                                    ;   r = 0 代码段不可读
                                    ;   a = 0 代码段已访问位清零
DES_TYPE_DATA       equ                 001000000000b
                                    ;   xewa    
                                    ;   x = 0 数据段可执行
                                    ;   e = 0 数据段向上扩展
                                    ;   w = 1 数据段可写
                                    ;   a = 0 数据段已访问位清零

DES_CODE_HIGH4      equ     (0x00 << 24) + DES_G_4K + DES_D_32 + DES_L + DES_AVL + DES_LIMIT_CODE2 + \
DES_P + DES_DPL_0 + DES_S_CODE + DES_TYPE_CODE + \
0x00

DES_DATA_HIGH4      equ     (0x00 << 24) + DES_G_4K + DES_D_32 + DES_L + DES_AVL + DES_LIMIT_DATA2 + \
DES_P + DES_DPL_0 + DES_S_DATA + DES_TYPE_DATA + \
0x00

DES_VIDEO_HIGH4     equ     (0x00 << 24) + DES_G_4K + DES_D_32 + DES_L + DES_AVL + DES_LIMIT_VIDEO2 + \
DES_P + DES_DPL_0 + DES_S_DATA + DES_TYPE_DATA + \
0x0b

;-------------------- Selector Attributes --------------------
RPL0                equ      00b             
RPL1                equ      01b
RPL2                equ      10b
RPL3                equ      11b

TI_GDT              equ     000b
TI_LDT              equ     100b
