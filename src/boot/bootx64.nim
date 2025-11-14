# UEFI Specification v2.10, Section 4.11
# https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html?highlight=efi_system_table#efi-image-entry-point

import common/libc
import common/malloc
import common/uefi

import std/strformat

import debugcon

const
  PageSize = 4096
  KernelPhysicalBase = 0x100000
  KernelStackSize = 128 * 1024'u64
 
proc NimMain() {.importc.}

proc unhandledException*(e: ref Exception) =
  echo "Unhandled exception: " & e.msg & " [" & $e.name & "]"
  if e.trace.len > 0:
    echo "Stack trace:"
    echo getStackTrace(e)
  quit()

proc checkStatus*(status: EfiStatus) =
  ## Debug information for efi status
  if status != EfiSuccess:
    consoleOut &" [failed, status = {status:#x}]"
    quit()
  consoleOut " [success]\r\n"

proc EfiMainInner(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus =
  ## Bootloader main processs
  echo "m os is saying hello to you"

  # Load image protocol
  var loadedImage: ptr EfiLoadedImageProtocol

  consoleOut "boot: getting loaded image protocol"
 
  checkStatus uefi.sysTable.bootServices.handleProtocol(
    imgHandle, EfiLoadedImageProtocolGuid, cast[ptr pointer](addr loadedImage)
  )

  # Load file system protocol
  var fileSystem: ptr EfiSimpleFileSystemProtocol

  consoleOut "boot: Acquiring SimpleFileSystem protocol"
  checkStatus uefi.sysTable.bootServices.handleProtocol(
    loadedImage.deviceHandle, EfiSimpleFileSystemProtocolGuid, cast[ptr pointer](addr fileSystem)
  )

  # Open UEFI file directory
  var rootDir: ptr EfiFileProtocol

  consoleOut "boot: opening root directory"
  checkStatus fileSystem.openVolume(fileSystem, addr rootDir)

  # Open kernel file
  var kernelFile: ptr EfiFileProtocol
  let kernelPath = W"efi\fusion\kernel.bin"

  consoleOut "boot: opening kernel file: "
  consoleOut kernelPath
  checkStatus rootDir.open(rootDir, addr kernelFile, kernelPath, 1, 1)

  # Get kernel file size
  var kernelInfo: EfiFileInfo
  var kernelInfoSize = sizeof(EfiFileInfo).uint

  consoleOut "boot: getting kernel file info"
  checkStatus kernelFile.getInfo(kernelFile, addr EfiFileInfoGuid, addr kernelInfoSize, addr kernelInfo)
  echo &"boot: kernel file size: {kernelInfo.fileSize} bytes"

  # Allocating memory
  consoleOut &"boot: allocating memory for kernel image"
  let kernelImageBase = cast[pointer](KernelPhysicalBase)
  # Round up to nearest page size:
  let kernelImagePages = (kernelInfo.fileSize + 0xFFF).uint div PageSize.uint
  checkStatus uefi.sysTable.bootServices.allocatePages(
    AllocateAddress,
    OsvKernelCode,
    kernelImagePages,
    cast[ptr EfiPhysicalAddress](addr kernelImageBase)
  )

  consoleOut &"boot: allocating memory for kernel stack (16 KiB) "
  var kernelStackBase: uint64
  let kernelStackPages = KernelStackSize div PageSize
  checkStatus uefi.sysTable.bootServices.allocatePages(
    AllocateAnyPages,
    OsvKernelStack,
    kernelStackPages,
    kernelStackBase.addr,
  )

  quit()
  
  EfiSuccess
  
proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} = 
  NimMain()

  uefi.sysTable = sysTable

  try:
    return EfiMainInner(imgHandle, sysTable)
  except Exception as e:
    unhandledException(e)
  
  quit()
  # return EfiSuccess
