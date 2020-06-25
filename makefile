
# sudo apt-get install g++ binutils libc6-dev-i386
# sudo apt-get install VirtualBox grub-legacy xorriso

GCCPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -Wno-write-strings
ASPARAMS = --32
NASMPARAMS = -felf32
LDPARAMS = -melf_i386


objects = loader.o kernel.o

%.o: %.asm
	nasm $(NASMPARAMS) -o $@ $<

%.o: %.c
	gcc $(GCCPARAMS) -c -o $@ $<

%.o: %.cpp
	g++ $(GCCPARAMS) -c -o $@ $<
	
%.o: %.s
	as $(ASPARAMS) -o $@ $<

kernel: link.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

test.iso: kernel
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp kernel iso/boot/kernel
	echo 'set timeout=5'					  > iso/boot/grub/grub.cfg
	echo 'set default=0'					 >> iso/boot/grub/grub.cfg
	echo '' 								 >> iso/boot/grub/grub.cfg
	echo 'menuentry "HydraOS Test ISO" {' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/kernel'	>> iso/boot/grub/grub.cfg
	echo '	boot'							 >> iso/boot/grub/grub.cfg
	echo '}'								 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=test.iso iso
	rm -rf iso

vbox: test.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm 'My Operating System' &

test: test.iso
	(killall qemu-system-i386 && sleep 1) || true
	qemu-system-i386 -cdrom test.iso -m 128M &

qemu: test.iso
	(killall qemu-system-i386 && sleep 1) || true
	qemu-system-i386 -cdrom test.iso -m 128M &

install: kernel
	sudo cp $< /boot/kernel

.PHONY: clean
clean:
	(killall qemu-system-i386 && sleep 1) || true
	(killall VirtualBox && sleep 1) || true
	rm -rf iso
	rm -f $(objects) kernel test.iso
