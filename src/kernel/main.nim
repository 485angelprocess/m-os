import debugcon, common/libc, common/malloc

proc KernelMain() {.exportc.} =
  debugln "hi hi :3"
  quit()
