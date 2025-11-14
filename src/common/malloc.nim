# malloc.nim

{.used.}

import debugcon

const 
  HeapSize = 1024*1024

var
  heap*: array[HeapSize, byte] # 1 MiB heap
  heapBumpPtr*: int = cast[int](addr heap[0])
  heapMaxPtr*: int = cast[int](addr heap[0]) + heap.high

proc malloc*(size: csize_t): pointer {.exportc.} =
  if heapBumpPtr + size.int > heapMaxPtr:
    debugln "Out of memory"
    quit()

  result = cast[pointer](heapBumpPtr)
  inc heapBumpPtr, size.int

proc calloc*(num: csize_t, size: csize_t): pointer {.exportc.} =
  result = malloc(size * num)
  
proc free*(p: pointer) {.exportc.} =
  discard

proc realloc*(p: pointer, new_size: csize_t): pointer {.exportc.} =
  result = malloc(new_size)
  copyMem(result, p, new_size)
  free(p)

