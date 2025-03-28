# project root dir
ROOT_DIR = $(abspath .)

# source dir
BOOT_DIR = $(abspath ./boot)

# include dir
INCLUDE_DIR = $(abspath ./include)

# mbr
$(BOOT_DIR)/mbr.bin: $(BOOT_DIR)/mbr.S
	nasm -I $(INCLUDE_DIR) -f bin -o $@ $<
mbr2img: $(BOOT_DIR)/mbr.bin
	dd if=$(BOOT_DIR)/mbr.bin of=$(ROOT_DIR)/hd60M.img bs=512 count=1 conv=notrunc

.PHONY: mbr2img

# loader
$(BOOT_DIR)/loader.bin: $(BOOT_DIR)/loader.S
	nasm -I $(INCLUDE_DIR) -f bin -o $@ $<
loader2img: $(BOOT_DIR)/loader.bin
	dd if=$(BOOT_DIR)/loader.bin of=$(ROOT_DIR)/hd60M.img bs=512 count=1 seek=2 conv=notrunc
	
.PHONY: loader2img
