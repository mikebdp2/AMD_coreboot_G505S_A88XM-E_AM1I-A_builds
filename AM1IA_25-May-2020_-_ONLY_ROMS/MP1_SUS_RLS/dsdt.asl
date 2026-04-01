DefinitionBlock (
 "DSDT.AML",
 "DSDT",
 0x02,
 "COREv4",
 "COREBOOT",
 0x00010001
 )
{
Name(LOMH, 0x0)
Name(PBAD, 0x0)
Name(PBLN, 0x0)
Name(PCBA, 0xF8000000)
Name(PCLN, Multiply(0x100000, 64))
Name(HPBA, 0xFED00000)
Name(OSVR, 3)
Name(OSV, Ones)
Name(PMOD, One)
OperationRegion(GP0B, SystemMemory, 0xfed80814, 0x04)
 Field(GP0B, ByteAcc, NoLock, Preserve) {
 , 11,
 USBS, 1,
}
 OperationRegion(PRQM, SystemIO, 0x00000C00, 0x00000002)
  Field(PRQM, ByteAcc, NoLock, Preserve) {
  PRQI, 0x00000008,
  PRQD, 0x00000008,
 }
 IndexField(PRQI, PRQD, ByteAcc, NoLock, Preserve) {
  PIRA, 0x00000008,
  PIRB, 0x00000008,
  PIRC, 0x00000008,
  PIRD, 0x00000008,
  PIRE, 0x00000008,
  PIRF, 0x00000008,
  PIRG, 0x00000008,
  PIRH, 0x00000008,
 }
 OperationRegion(PERC, SystemIO, 0x00000C14, 0x00000001)
  Field(PERC, ByteAcc, NoLock, Preserve) {
  SENS, 0x00000001,
  PENS, 0x00000001,
  SENE, 0x00000001,
  PENE, 0x00000001,
 }
 OperationRegion(CMT, SystemIO, 0x00000C50, 0x00000002)
  Field(CMT, ByteAcc, NoLock, Preserve) {
  CMTI, 8,
  G64E, 1,
  G64O, 1,
  G32O, 2,
  , 2,
  GPSL, 2,
 }
 OperationRegion(GPT, SystemIO, 0x00000C52, 0x00000001)
  Field(GPT, ByteAcc, NoLock, Preserve) {
  GPB0,1,
  GPB1,1,
  GPB2,1,
  GPB3,1,
  GPB4,1,
  GPB5,1,
  GPB6,1,
  GPB7,1,
 }
 OperationRegion(FRE, SystemIO, 0x00000C6F, 0x00000001)
  Field(FRE, ByteAcc, NoLock, Preserve) {
  , 0x00000006,
  FLRE, 0x00000001,
 }
 OperationRegion(PM2R, SystemIO, 0x00000CD0, 0x00000002)
  Field(PM2R, ByteAcc, NoLock, Preserve) {
  PM2I, 0x00000008,
  PM2D, 0x00000008,
 }
 OperationRegion(PIOR, SystemIO, 0x00000CD6, 0x00000002)
  Field(PIOR, ByteAcc, NoLock, Preserve) {
  PIOI, 0x00000008,
  PIOD, 0x00000008,
 }
 IndexField (PIOI, PIOD, ByteAcc, NoLock, Preserve) {
  Offset(0xEE),
  UPWS, 3,
 }
Scope (\_SB) {
 Device (P000) {
 Name(_HID, "ACPI0007")
 Name(_UID, 0)
 }
 Device (P001) {
 Name(_HID, "ACPI0007")
 Name(_UID, 1)
 }
 Device (P002) {
 Name(_HID, "ACPI0007")
 Name(_UID, 2)
 }
 Device (P003) {
 Name(_HID, "ACPI0007")
 Name(_UID, 3)
 }
 Device (P004) {
 Name(_HID, "ACPI0007")
 Name(_UID, 4)
 }
 Device (P005) {
 Name(_HID, "ACPI0007")
 Name(_UID, 5)
 }
 Device (P006) {
 Name(_HID, "ACPI0007")
 Name(_UID, 6)
 }
 Device (P007) {
 Name(_HID, "ACPI0007")
 Name(_UID, 7)
 }
}
Name (SSFG, 0x0D)
If (0) {
 Store(And(SSFG, 0xF7), SSFG)
}
Name(\_S0, Package () {0x00, 0x00, 0x00, 0x00} )
If (And(SSFG, 0x01)) {
 Name(\_S1, Package () {0x01, 0x01, 0x00, 0x00} )
}
If (And(SSFG, 0x02)) {
 Name(\_S2, Package () {0x02, 0x02, 0x00, 0x00} )
}
If (And(SSFG, 0x04)) {
 Name(\_S3, Package () {0x03, 0x03, 0x00, 0x00} )
}
If (And(SSFG, 0x08)) {
 Name(\_S4, Package () {0x04, 0x04, 0x00, 0x00} )
}
Name(\_S5, Package () {0x05, 0x05, 0x00, 0x00} )
Name(WKST,Package(){Zero, Zero})
External(\_SB.APTS, MethodObj)
External(\_SB.AWAK, MethodObj)
Method(_PTS, 1) {
 Store(0, Index(WKST,0))
 Store(0, Index(WKST,1))
 Store(7, UPWS)
 \_SB.APTS(Arg0)
}
Method(\_BFS, 1) {
}
Method(\_WAK, 1) {
 Store(1,USBS)
 \_SB.AWAK(Arg0)
 Return(WKST)
}
 Scope(\_SB) {
Method(MIN, 2)
{
 if (LLess(Arg0, Arg1)) {
  Return(Arg0)
 } else {
  Return(Arg1)
 }
}
Method(SLEN, 1)
{
 Store(Arg0, Local0)
 Return(Sizeof(Local0))
}
Method(S2BF, 1, Serialized)
{
 Add(SLEN(Arg0), One, Local0)
 Name(BUFF, Buffer(Local0) {})
 Store(Arg0, BUFF)
 Return(BUFF)
}
Method(SCMP, 2)
{
 Store(S2BF(Arg0), Local0)
 Store(S2BF(Arg1), Local1)
 Store(Zero, Local4)
 Store(SLEN(Arg0), Local5)
 Store(SLEN(Arg1), Local6)
 Store(MIN(Local5, Local6), Local7)
 While(LLess(Local4, Local7)) {
  Store(Derefof(Index(Local0, Local4)), Local2)
  Store(Derefof(Index(Local1, Local4)), Local3)
  if (LGreater(Local2, Local3)) {
   Return(One)
  } else {
   if (LLess(Local2, Local3)) {
    Return(Ones)
   }
  }
  Increment(Local4)
 }
 if (LLess(Local4, Local5)) {
  Return(One)
 } else {
  if (LLess(Local4, Local6)) {
   Return(Ones)
  } else {
   Return(Zero)
  }
 }
}
Method(WCMP, 2)
{
 Store(S2BF(Arg0), Local0)
 Store(S2BF(Arg1), Local1)
 if (LLess(SLEN(Arg0), SLEN(Arg1))) {
  Return(0)
 }
 Store(Zero, Local2)
 Store(SLEN(Arg1), Local3)
 While(LLess(Local2, Local3)) {
  if (LNotEqual(Derefof(Index(Local0, Local2)),
   Derefof(Index(Local1, Local2)))) {
   Return(0)
  }
  Increment(Local2)
 }
 Return(One)
}
Method(I2BM, 1)
{
 Store(0, Local0)
 if (LNotEqual(ARG0, 0)) {
  Store(1, Local1)
  ShiftLeft(Local1, ARG0, Local0)
 }
 Return(Local0)
}
Name(PR0, Package(){
 Package(){0x0001FFFF, 0, INTA, 0 },
 Package(){0x0001FFFF, 1, INTB, 0 },
 Package(){0x0002FFFF, 0, INTA, 0 },
 Package(){0x0002FFFF, 1, INTB, 0 },
 Package(){0x0002FFFF, 2, INTC, 0 },
 Package(){0x0002FFFF, 3, INTD, 0 },
 Package(){0x0014FFFF, 0, INTA, 0 },
 Package(){0x0014FFFF, 1, INTB, 0 },
 Package(){0x0014FFFF, 2, INTC, 0 },
 Package(){0x0014FFFF, 3, INTD, 0 },
 Package(){0x0012FFFF, 0, INTC, 0 },
 Package(){0x0012FFFF, 1, INTB, 0 },
 Package(){0x0013FFFF, 0, INTC, 0 },
 Package(){0x0013FFFF, 1, INTB, 0 },
 Package(){0x0016FFFF, 0, INTC, 0 },
 Package(){0x0016FFFF, 1, INTB, 0 },
 Package(){0x0010FFFF, 0, INTC, 0 },
 Package(){0x0010FFFF, 1, INTB, 0 },
 Package(){0x0011FFFF, 0, INTD, 0 },
})
Name(APR0, Package(){
 Package(){0x0001FFFF, 0, 0, 44 },
 Package(){0x0001FFFF, 1, 0, 45 },
 Package(){0x0002FFFF, 0, 0, 24 },
 Package(){0x0002FFFF, 1, 0, 25 },
 Package(){0x0002FFFF, 2, 0, 26 },
 Package(){0x0002FFFF, 3, 0, 27 },
 Package(){0x0014FFFF, 0, 0, 16 },
 Package(){0x0014FFFF, 1, 0, 17 },
 Package(){0x0014FFFF, 2, 0, 18 },
 Package(){0x0014FFFF, 3, 0, 19 },
 Package(){0x0012FFFF, 0, 0, 18 },
 Package(){0x0012FFFF, 1, 0, 17 },
 Package(){0x0013FFFF, 0, 0, 18 },
 Package(){0x0013FFFF, 1, 0, 17 },
 Package(){0x0016FFFF, 0, 0, 18 },
 Package(){0x0016FFFF, 1, 0, 17 },
 Package(){0x0010FFFF, 0, 0, 18 },
 Package(){0x0010FFFF, 1, 0, 17 },
 Package(){0x0011FFFF, 0, 0, 19 },
})
Name(PS4, Package(){
 Package(){0x0000FFFF, 0, INTA, 0 },
 Package(){0x0000FFFF, 1, INTB, 0 },
 Package(){0x0000FFFF, 2, INTC, 0 },
 Package(){0x0000FFFF, 3, INTD, 0 },
})
Name(APS4, Package(){
 Package(){0x0000FFFF, 0, 0, 24 },
 Package(){0x0000FFFF, 1, 0, 25 },
 Package(){0x0000FFFF, 2, 0, 26 },
 Package(){0x0000FFFF, 3, 0, 27 },
})
Name(PS5, Package(){
 Package(){0x0000FFFF, 0, INTB, 0 },
 Package(){0x0000FFFF, 1, INTC, 0 },
 Package(){0x0000FFFF, 2, INTD, 0 },
 Package(){0x0000FFFF, 3, INTA, 0 },
})
Name(APS5, Package(){
 Package(){0x0000FFFF, 0, 0, 28 },
 Package(){0x0000FFFF, 1, 0, 29 },
 Package(){0x0000FFFF, 2, 0, 30 },
 Package(){0x0000FFFF, 3, 0, 31 },
})
Name(PS6, Package(){
 Package(){0x0000FFFF, 0, INTC, 0 },
 Package(){0x0000FFFF, 1, INTD, 0 },
 Package(){0x0000FFFF, 2, INTA, 0 },
 Package(){0x0000FFFF, 3, INTB, 0 },
})
Name(APS6, Package(){
 Package(){0x0000FFFF, 0, 0, 32 },
 Package(){0x0000FFFF, 1, 0, 33 },
 Package(){0x0000FFFF, 2, 0, 34 },
 Package(){0x0000FFFF, 3, 0, 35 },
})
Name(PS7, Package(){
 Package(){0x0000FFFF, 0, INTD, 0 },
 Package(){0x0000FFFF, 1, INTA, 0 },
 Package(){0x0000FFFF, 2, INTB, 0 },
 Package(){0x0000FFFF, 3, INTC, 0 },
})
Name(APS7, Package(){
 Package(){0x0000FFFF, 0, 0, 36 },
 Package(){0x0000FFFF, 1, 0, 37 },
 Package(){0x0000FFFF, 2, 0, 38 },
 Package(){0x0000FFFF, 3, 0, 39 },
})
Name(PS8, Package(){
 Package(){0x0000FFFF, 0, INTB, 0 },
 Package(){0x0000FFFF, 1, INTC, 0 },
 Package(){0x0000FFFF, 2, INTD, 0 },
 Package(){0x0000FFFF, 3, INTA, 0 },
})
Name(APS8, Package(){
 Package(){0x0000FFFF, 0, 0, 40 },
 Package(){0x0000FFFF, 1, 0, 41 },
 Package(){0x0000FFFF, 2, 0, 42 },
 Package(){0x0000FFFF, 3, 0, 43 },
})
  Device(PWRB) {
   Name(_HID, EISAID("PNP0C0C"))
   Name(_UID, 0xAA)
   Name(_PRW, Package () {3, 0x04})
   Name(_STA, 0x0B)
  }
  Device(PCI0) {
External (TOM1)
External (TOM2)
Name(_HID, EISAID("PNP0A08"))
Name(_CID, EISAID("PNP0A03"))
Method(_BBN, 0, NotSerialized)
{
 Return(Zero)
}
Method(_STA, 0, NotSerialized)
{
 Return(0x0B)
}
Method(_PRT,0, NotSerialized)
{
 If(PMOD)
 {
  Return(APR0)
 }
 Return (PR0)
}
Device(AMRT) {
 Name(_ADR, 0x00000000)
}
Device(PBR4) {
 Name(_ADR, 0x00020001)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS4) }
  Return (PS4)
 }
}
Device(PBR5) {
 Name(_ADR, 0x00020002)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS5) }
  Return (PS5)
 }
}
Device(PBR6) {
 Name(_ADR, 0x00020003)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS6) }
  Return (PS6)
 }
}
Device(PBR7) {
 Name(_ADR, 0x00020004)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS7) }
  Return (PS7)
 }
}
Device(PBR8) {
 Name(_ADR, 0x00020005)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS8) }
  Return (PS8)
 }
}
Device(K10M) {
 Name (_ADR, 0x00180003)
OperationRegion (TCFG, PCI_Config, 0x64, 0x4)
Field (TCFG, ByteAcc, NoLock, Preserve) {
 HTCE, 1,
 , 15,
 TLMT, 7,
 , 9,
}
OperationRegion (TCTL, PCI_Config, 0xa4, 0x4)
Field (TCTL, ByteAcc, NoLock, Preserve) {
 , 21,
 TNOW, 11,
}
ThermalZone (TZ00) {
 Name (_STR, Unicode ("AMD CPU Core Thermal Sensor"))
 Method (_STA) {
  If (LEqual (HTCE, One)) {
   Return (0x0F)
  }
  Return (Zero)
 }
 Method (_TMP) {
  Multiply (TNOW, 10, Local0)
  ShiftRight (Local0, 3, Local0)
  Return (Add (Local0, 2732))
 }
 Method (_PSV) {
  Multiply (TLMT, 10, Local0)
  ShiftRight (Local0, 1, Local0)
  Add (Local0, 520, Local0)
  Return (Add (Local0, 2732))
 }
 Method (_HOT) {
  Return (Add (_PSV, 50))
 }
 Method (_CRT) {
  Return (Add (_HOT, 50))
 }
}
}
Method(_OSC,4)
{
 If(LEqual(Arg0,ToUUID("33DB4D5B-1FF7-401C-9657-7441C03DD766")))
 {
  Return (Arg3)
 } Else {
  CreateDWordField(Arg3,0,CDW1)
  Or(CDW1,4,CDW1)
  Return(Arg3)
 }
}
Device(STCR) {
 Name(_ADR, 0x00110000)
Name(STTM, Buffer(20) {
 0x78, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00,
 0x78, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00,
 0x1f, 0x00, 0x00, 0x00
})
Method(_INI) {
 \_GPE._L1F()
}
Device(PMRY)
{
 Name(_ADR, 0)
 Method(_GTM, 0x0, NotSerialized) {
  Return(STTM)
 }
 Method(_STM, 0x3, NotSerialized) {}
 Device(PMST) {
  Name(_ADR, 0)
  Method(_STA,0) {
   if (LGreater(P0IS,0)) {
    return (0x0F)
   }
   else {
    return (0x00)
   }
  }
 }
 Device(PSLA)
 {
  Name(_ADR, 1)
  Method(_STA,0) {
   if (LGreater(P1IS,0)) {
    return (0x0F)
   }
   else {
    return (0x00)
   }
  }
 }
}
Device(SEDY)
{
 Name(_ADR, 1)
 Method(_GTM, 0x0, NotSerialized) {
  Return(STTM)
 }
 Method(_STM, 0x3, NotSerialized) {}
 Device(SMST)
 {
  Name(_ADR, 0)
  Method(_STA,0) {
   if (LGreater(P2IS,0)) {
    return (0x0F)
   }
   else {
    return (0x00)
   }
  }
 }
 Device(SSLA)
 {
  Name(_ADR, 1)
  Method(_STA,0) {
   if (LGreater(P3IS,0)) {
    return (0x0F)
   }
   else {
    return (0x00)
   }
  }
 }
}
Scope(\_GPE) {
 Method(_L1F,0x0,NotSerialized) {
  if (\_SB.P0PR) {
   if (LGreater(\_SB.P0IS,0)) {
    sleep(32)
   }
   Notify(\_SB.PCI0.STCR.PMRY.PMST, 0x01)
   store(one, \_SB.P0PR)
  }
  if (\_SB.P1PR) {
   if (LGreater(\_SB.P1IS,0)) {
    sleep(32)
   }
   Notify(\_SB.PCI0.STCR.PMRY.PSLA, 0x01)
   store(one, \_SB.P1PR)
  }
  if (\_SB.P2PR) {
   if (LGreater(\_SB.P2IS,0)) {
    sleep(32)
   }
   Notify(\_SB.PCI0.STCR.SEDY.SMST, 0x01)
   store(one, \_SB.P2PR)
  }
  if (\_SB.P3PR) {
   if (LGreater(\_SB.P3IS,0)) {
    sleep(32)
   }
   Notify(\_SB.PCI0.STCR.SEDY.SSLA, 0x01)
   store(one, \_SB.P3PR)
  }
 }
}
}
Device(SBUS) {
 Name(_ADR, 0x00140000)
}
Device(UOH1) {
 Name(_ADR, 0x00120000)
 Name(_PRW, Package() {0x0B, 3})
}
Device(UOH2) {
 Name(_ADR, 0x00120002)
 Name(_PRW, Package() {0x0B, 3})
}
Device(UOH3) {
 Name(_ADR, 0x00130000)
 Name(_PRW, Package() {0x0B, 3})
}
Device(UOH4) {
 Name(_ADR, 0x00130002)
 Name(_PRW, Package() {0x0B, 3})
}
Device(UOH5) {
 Name(_ADR, 0x00160000)
 Name(_PRW, Package() {0x0B, 3})
}
Device(UOH6) {
 Name(_ADR, 0x00160002)
 Name(_PRW, Package() {0x0B, 3})
}
Device(XHC0) {
 Name(_ADR, 0x00100000)
 Name(_PRW, Package() {0x0B, 4})
}
Device(AZHD) {
 Name(_ADR, 0x00140002)
 OperationRegion(AZPD, PCI_Config, 0x00, 0x100)
  Field(AZPD, AnyAcc, NoLock, Preserve) {
  offset (0x42),
  NSDI, 1,
  NSDO, 1,
  NSEN, 1,
  offset (0x44),
  IPCR, 4,
  offset (0x54),
  PWST, 2,
  , 6,
  PMEB, 1,
  , 6,
  PMST, 1,
  offset (0x62),
  MMCR, 1,
  offset (0x64),
  MMLA, 32,
  offset (0x68),
  MMHA, 32,
  offset (0x6C),
  MMDT, 16,
 }
 Method (_INI, 0, NotSerialized)
 {
  If (LEqual (OSVR, 0x03))
  {
   Store (Zero, NSEN)
   Store (One, NSDO)
   Store (One, NSDI)
  }
 }
}
Device(LIBR) {
 Name(_ADR, 0x00140003)
 OperationRegion(CFG,PCI_Config,0x0,0x100)
 Field(CFG,DWordAcc,NoLock,Preserve){
  Offset(0xA0),
  BAR,32}
 Device(LDRC)
 {
  Name (_HID, EISAID("PNP0C02"))
  Name (CRS, ResourceTemplate ()
  {
   Memory32Fixed(ReadWrite,
   0x00000000,
   0x00000000,
   BAR0
   )
  })
  Method(_CRS,0,NotSerialized)
  {
   CreateDwordField(^CRS,^BAR0._BAS,SPIB)
   CreateDwordField(^CRS,^BAR0._LEN,SPIL)
   Store(BAR,SPIB)
   Store(0x1000,SPIL)
   Return(CRS)
  }
 }
 Device(RTC0) {
  Name(_HID, EISAID("PNP0B00"))
  Name(_CRS, ResourceTemplate() {
   IRQNoFlags(){8}
   IO(Decode16,0x0070, 0x0070, 0, 2)
  })
 }
 Device(TMR) {
  Name(_HID,EISAID("PNP0100"))
  Name(_CRS, ResourceTemplate() {
   IRQNoFlags(){0}
   IO(Decode16, 0x0040, 0x0040, 0, 4)
  })
 }
 Device(SPKR) {
  Name(_HID,EISAID("PNP0800"))
  Name(_CRS, ResourceTemplate() {
   IO(Decode16, 0x0061, 0x0061, 0, 1)
  })
 }
 Device(PIC) {
  Name(_HID,EISAID("PNP0000"))
  Name(_CRS, ResourceTemplate() {
   IRQNoFlags(){2}
   IO(Decode16,0x0020, 0x0020, 0, 2)
   IO(Decode16,0x00A0, 0x00A0, 0, 2)
  })
 }
 Device(MAD) {
  Name(_HID,EISAID("PNP0200"))
  Name(_CRS, ResourceTemplate() {
   DMA(Compatibility,BusMaster,Transfer8){4}
   IO(Decode16, 0x0000, 0x0000, 0x10, 0x10)
   IO(Decode16, 0x0081, 0x0081, 0x01, 0x03)
   IO(Decode16, 0x0087, 0x0087, 0x01, 0x01)
   IO(Decode16, 0x0089, 0x0089, 0x01, 0x03)
   IO(Decode16, 0x008F, 0x008F, 0x01, 0x01)
   IO(Decode16, 0x00C0, 0x00C0, 0x10, 0x20)
  })
 }
 Device(COPR) {
  Name(_HID,EISAID("PNP0C04"))
  Name(_CRS, ResourceTemplate() {
   IO(Decode16, 0x00F0, 0x00F0, 0, 0x10)
   IRQNoFlags(){13}
  })
 }
Device (PS2M) {
 Name (_HID, EisaId ("PNP0F13"))
 Name (_CRS, ResourceTemplate () {
  IRQNoFlags () {12}
 })
}
Device (PS2K) {
 Name (_HID, EisaId ("PNP0303"))
 Name (_CRS, ResourceTemplate () {
  IO (Decode16, 0x0060, 0x0060, 0x00, 0x01)
  IO (Decode16, 0x0064, 0x0064, 0x00, 0x01)
  IRQNoFlags () {1}
 })
}
Device (COM1) {
 Name (_HID, EISAID ("PNP0501"))
 Name (_UID, 1)
 Name (_CRS, ResourceTemplate ()
 {
  IO (Decode16, 0x03F8, 0x03F8, 0x08, 0x08)
  IRQNoFlags () {4}
 })
 Name (_PRS, ResourceTemplate ()
 {
  IO (Decode16, 0x03F8, 0x03F8, 0x08, 0x08)
  IRQNoFlags () {4}
 })
}
Device (COM2) {
 Name (_HID, EISAID ("PNP0501"))
 Name (_UID, 2)
 Name (_CRS, ResourceTemplate ()
 {
  IO (Decode16, 0x02F8, 0x02F8, 0x08, 0x08)
  IRQNoFlags () {3}
 })
 Name (_PRS, ResourceTemplate ()
 {
  IO (Decode16, 0x02F8, 0x02F8, 0x08, 0x08)
  IRQNoFlags () {3}
 })
}
Device (LPT1) {
 Name (_HID, EISAID ("PNP0401"))
 Name (_UID, 1)
 Name (_CRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0378, 0x0378, 0x04, 0x08)
  IO (Decode16, 0x0778, 0x0778, 0x04, 0x08)
  IRQNoFlags () {5}
 })
 Name (_PRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0378, 0x0378, 0x04, 0x08)
  IO (Decode16, 0x0778, 0x0778, 0x04, 0x08)
  IRQNoFlags () {5}
 })
}
Device (ENVC) {
 Name (_HID, EISAID ("PNP0C02"))
 Name (_UID, 1)
 Name (_CRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0230, 0x0230, 0x04, 0x10)
  IO (Decode16, 0x0290, 0x0290, 0x04, 0x10)
 })
 Name (_PRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0230, 0x0230, 0x04, 0x10)
  IO (Decode16, 0x0290, 0x0290, 0x04, 0x10)
 })
}
Device (GPIC) {
 Name (_HID, EISAID ("PNP0C02"))
 Name (_UID, 2)
 Name (_CRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0300, 0x0300, 0x04, 0x20)
 })
 Name (_PRS, ResourceTemplate ()
 {
  IO (Decode16, 0x0300, 0x0300, 0x04, 0x20)
 })
}
}
Device(SDCN) {
 Name(_ADR, 0x00140007)
}
Name(CRES, ResourceTemplate() {
 WordBusNumber (ResourceProducer, MinFixed, MaxFixed, PosDecode,
  0x0000,
  0x0000,
  0x00FF,
  0x0000,
  0x0100,
  ,, PSB0)
 IO(Decode16, 0x0CF8, 0x0CF8, 1, 8)
 WORDIO(ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
  0x0000,
  0x0000,
  0x0CF7,
  0x0000,
  0x0CF8
 )
 WORDIO(ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
  0x0000,
  0x03B0,
  0x03DF,
  0x0000,
  0x0030
 )
 WORDIO(ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
  0x0000,
  0x0D00,
  0xFFFF,
  0x0000,
  0xF300
 )
 Memory32Fixed(READONLY, 0x000A0000, 0x00020000, VGAM)
 Memory32Fixed(READONLY, 0x000C0000, 0x00020000, EMM1)
 Memory32Fixed(ReadOnly, 0x00000000, 0x00000000, MMIO)
})
Method(_CRS, 0) {
 CreateDWordField(CRES, ^MMIO._BAS, MM1B)
 CreateDWordField(CRES, ^MMIO._LEN, MM1L)
 Store(TOM1, MM1B)
 ShiftLeft(0x10000000, 4, Local0)
 Subtract(Local0, TOM1, Local0)
 Store(Local0, MM1L)
 Return(CRES)
}
Method(_INI, 0) {
 OSFL()
}
Method(OSFL, 0){
 if (LNotEqual(OSVR, Ones)) {Return(OSVR)}
 if (CondRefOf(\_OSI))
 {
  Store(1, OSVR)
  if (\_OSI("Windows 2006"))
  {
   Store(2, OSVR)
  }
 } else {
  If(WCMP(\_OS,"Linux")) {
   Store(3, OSVR)
  } Else {
   Store(4, OSVR)
  }
 }
 Return(OSVR)
}
  }
 OperationRegion(PCFG, SystemMemory, PCBA, PCLN)
  Field(PCFG, ByteAcc, NoLock, Preserve) {
  Offset(0x00088024),
  STB5, 32,
  Offset(0x00098042),
  PT0D, 1,
  PT1D, 1,
  PT2D, 1,
  PT3D, 1,
  PT4D, 1,
  PT5D, 1,
  PT6D, 1,
  PT7D, 1,
  PT8D, 1,
  PT9D, 1,
  Offset(0x000A0004),
  SBIE, 1,
  SBME, 1,
  Offset(0x000A0008),
  SBRI, 8,
  Offset(0x000A0014),
  SBB1, 32,
  Offset(0x000A0078),
  ,14,
  P92E, 1,
 }
 OperationRegion(SB5, SystemMemory, STB5, 0x1000)
  Field(SB5, AnyAcc, NoLock, Preserve){
  Offset(0x120),
  P0ER, 1,
  , 2,
  P0DQ, 1,
  , 3,
  P0BY, 1,
  Offset(0x128),
  P0DD, 4,
  , 4,
  P0IS, 4,
  Offset(0x12C),
  P0DI, 4,
  Offset(0x130),
  , 16,
  P0PR, 1,
  offset(0x1A0),
  P1ER, 1,
  , 2,
  P1DQ, 1,
  , 3,
  P1BY, 1,
  Offset(0x1A8),
  P1DD, 4,
  , 4,
  P1IS, 4,
  Offset(0x1AC),
  P1DI, 4,
  Offset(0x1B0),
  , 16,
  P1PR, 1,
  Offset(0x220),
  P2ER, 1,
  , 2,
  P2DQ, 1,
  , 3,
  P2BY, 1,
  Offset(0x228),
  P2DD, 4,
  , 4,
  P2IS, 4,
  Offset(0x22C),
  P2DI, 4,
  Offset(0x230),
  , 16,
  P2PR, 1,
  Offset(0x2A0),
  P3ER, 1,
  , 2,
  P3DQ, 1,
  , 3,
  P3BY, 1,
  Offset(0x2A8),
  P3DD, 4,
  , 4,
  P3IS, 4,
  Offset(0x2AC),
  P3DI, 4,
  Offset(0x2B0),
  , 16,
  P3PR, 1,
 }
 Method(_PIC, 0x01, NotSerialized)
 {
  If (Arg0)
  {
   \_SB.CIRQ()
  }
  Store(Arg0, PMOD)
 }
 Method(CIRQ, 0x00, NotSerialized){
 }
 Name(IRQB, ResourceTemplate(){
  IRQ(Level,ActiveLow,Shared){15}
 })
 Name(IRQP, ResourceTemplate(){
  IRQ(Level,ActiveLow,Exclusive){3, 4, 5, 7, 10, 11, 12, 15}
 })
 Name(PITF, ResourceTemplate(){
  IRQ(Level,ActiveLow,Exclusive){9}
 })
 Device(INTA) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 1)
  Method(_STA, 0) {
   if (PIRA) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRA, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRA)
  }
 }
 Device(INTB) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 2)
  Method(_STA, 0) {
   if (PIRB) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRB, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRB)
  }
 }
 Device(INTC) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 3)
  Method(_STA, 0) {
   if (PIRC) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRC, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRC)
  }
 }
 Device(INTD) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 4)
  Method(_STA, 0) {
   if (PIRD) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRD, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRD)
  }
 }
 Device(INTE) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 5)
  Method(_STA, 0) {
   if (PIRE) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRE, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRE)
  }
 }
 Device(INTF) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 6)
  Method(_STA, 0) {
   if (PIRF) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(PITF)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRF, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRF)
  }
 }
 Device(INTG) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 7)
  Method(_STA, 0) {
   if (PIRG) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRG, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRG)
  }
 }
 Device(INTH) {
  Name(_HID, EISAID("PNP0C0F"))
  Name(_UID, 8)
  Method(_STA, 0) {
   if (PIRH) {
    Return(0x0B)
   } else {
    Return(0x09)
   }
  }
  Method(_DIS ,0) {
  }
  Method(_PRS ,0) {
   Return(IRQP)
  }
  Method(_CRS ,0) {
   CreateWordField(IRQB, 0x1, IRQN)
   ShiftLeft(1, PIRH, IRQN)
   Return(IRQB)
  }
  Method(_SRS, 1) {
   CreateWordField(ARG0, 1, IRQM)
   FindSetRightBit(IRQM, Local0)
   if (Local0) {
    Decrement(Local0)
   }
   Store(Local0, PIRH)
  }
 }
 }
Scope(\_SI) {
 Method(_SST, 1) {
 }
}
}
