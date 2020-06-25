extern "C" void kmain () {
  char* vidmem = (char*)0xb8000;
  vidmem[0] = 'B';
  vidmem[1] = 0x07;
}
