{.used.}

type
    const_pointer {.importc: "const void *".} = pointer
    
proc fwrite*(buf: const_pointer, size: csize_t, 
        count: csize_t, stream: File):
    csize_t {.exportc.} =
  return 0.csize_t
  
# fflush: flushes the stream
proc fflush*(stream: File): cint {.exportc.} =
  return 0.cint
  
# stdout and stderr
# global variables with the file struct
var
    stdout* {.exportc.}: File
    stderr* {.exportc.}: File
    
# exit function
proc exit*(status: cint) {.exportc, asmNoStackFrame.} =
    asm """
    .loop:
        cli
        hlt
        jmp .loop
    """