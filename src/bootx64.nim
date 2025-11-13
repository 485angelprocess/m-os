# UEFI Specification v2.10, Section 4.11
# https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html?highlight=efi_system_table#efi-image-entry-point

import libc
import malloc
import uefi
 
proc NimMain() {.importc.}

proc unhandledException*(e: ref Exception) =
  echo "Unhandled exception: " & e.msg & " [" & $e.name & "]"
  if e.trace.len > 0:
    echo "Stack trace:"
    echo getStackTrace(e)
  quit()

proc EfiMainInner(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus =
  consoleClear()

  # forced index exception
  let a = [1, 2, 3]
  let n = 5
  discard a[5]

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} = 
  NimMain()

  uefi.sysTable = sysTable
  consoleClear()

  echo "Hi welcome\n"

  try:
    return EfiMainInner(imgHandle, sysTable)
  except Exception as e:
    unhandledException(e)
  
  quit()
  # return EfiSuccess
