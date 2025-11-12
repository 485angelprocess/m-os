# UEFI Specification v2.10, Section 4.11
# https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html?highlight=efi_system_table#efi-image-entry-point

import libc

# UEFI types
type
	EfiStatus = uint
	EfiHandle = pointer
	EfiSystemTable = object # stub
	
const
	EfiSuccess = 0
	
proc NimMain() {.exportc.}

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr: EfiSystemTable): EfiStatus {.exportc.} = 
	NimMain()
	return EfiSuccess