##  VariantKey
##
##  created from variantkey.h by Nicola Asuni <nicola.asuni@genomicsplc.com>
##  see:  https://github.com/genomicsplc/variantkey
##
##  LICENSE for Variantkey C library
##
{.compile: "hex.c".}
{.compile: "variantkey.c".}

type
  uint8_t* = uint8
  int8_t* = int8
  uint16_t* = uint16
  uint32_t* = uint32
  uint64_t* = uint64
  size_t* = csize

type
  variantkey_t {.bycopy.} = object
    chrom*: uint8_t            ## !< Chromosome encoded number (only the LSB 5 bit are used)
    pos*: uint32_t             ## !< Reference position, with the first base having position 0 (only the LSB 28 bit are used)
    refalt*: uint32_t          ## !< Code for Reference and Alternate allele (only the LSB 31 bits are used)


proc decode_variantkey(code: uint64_t; vk: ptr variantkey_t) {.cdecl, importc:"decode_variantkey".}
proc variantkey(chrom: cstring; sizechrom: csize; pos: uint32_t; `ref`: cstring;
                sizeref: csize; alt: cstring; sizealt: csize): uint64_t {.cdecl, importc:"variantkey".}

proc decode_refalt(code: uint32, reference: cstring, refsize:ptr csize, alt: cstring, altsize: ptr csize) {.cdecl, importc: "decode_refalt".}

proc decode_chrom(code: uint8): string {.inline.} =
  if code < 1'u8 or code > 25'u8:
    return "NA"
  if code < 23'u8:
    return $code
  if code == 23'u8:
    return "X"
  elif code == 24'u8:
    return "Y"
  elif code == 25'u8:
    return "MT"

proc encode*(chrom: string, pos:uint32, ref_allele: string, alt_allele:string): uint64 {.inline.} =
  return variantkey(chrom, chrom.len, pos, ref_allele, ref_allele.len.csize, alt_allele, alt_allele.len.csize)

type Position* = object
    chrom*: string
    position*: uint32
    reference*: string
    alternate*: string


proc cmp_position*(a, b:Position): int =
  ## ordering function for positions to facilitate sorting.
  if a.chrom != b.chrom:
    return cmp(a.chrom, b.chrom)
  if a.position != b.position:
    return system.cmp[uint32](a.position, b.position)
  if a.reference != b.reference:
    return cmp(a.reference, b.reference)
  return cmp(a.alternate, b.alternate)


template exact*(refalt:uint32): bool =
  0'u32 == (refalt and 32'u32)

proc exact*(p:Position): bool {.inline.} =
  return p.reference.len == 0 and p.alternate.len == 0

proc decode*(code:uint64): Position {.inline.} =
    var v : variantkey_t
    decode_variantkey(code, v.addr)
    if v.refalt.exact:
      result.reference.setLen(10)
      result.alternate.setLen(10)
      var refi:csize = 10
      var alti:csize = 10
      decode_refalt(v.refalt, result.reference, refi.addr, result.alternate, alti.addr)
      result.reference.setLen(refi.int)
      result.alternate.setLen(alti.int)

    result.chrom = decode_chrom(v.chrom)
    result.position = v.pos

when isMainModule:
    import random
    import unittest
    import times

    var chroms = @["MT", "X", "Y"]
    for i in 1..22:
        chroms.add($i)

    var t = cpuTime()
    var n = 5_000_000
    when not defined(release):
        n = 100_000

    var refs = ["AA", "TT", "CC", "GG", "GGG", "G", "CCC"]
    var alts = ["T", "C", "GGGGGGG", "AAA", "GGC", "TTCAT"]
    for i in 0..n:
      var c = rand(chroms)
      var p = rand(250_000_000).uint32
      var aref = rand(refs)
      var aalt = rand(alts)
      var e = encode(c, p, aref, aalt)

      var d = e.decode
      doAssert d.chrom == c
      doAssert d.position == p
      doAssert d.reference == aref
      doAssert d.alternate == aalt

    echo int(n.float64 / (cpuTime() - t)), " encode/decodes per second"


    #1       878111  rs1309689674    CAGGGGCCCCCGGGCTCCGGACCCCCCACCCCGTCCCGGGACTCTGCCCGGCGAGCCCCCCGGAA       C
    var e = encode("1", 878111, "CAGGGGCCCCCGGGCTCCGGACCCCCCACCCCGTCCCGGGACTCTGCCCGGCGAGCCCCCCGGAA", "C")
    echo e
    echo e.decode
    doAssert e.decode.reference == ""
    doAssert e.decode.alternate == ""
