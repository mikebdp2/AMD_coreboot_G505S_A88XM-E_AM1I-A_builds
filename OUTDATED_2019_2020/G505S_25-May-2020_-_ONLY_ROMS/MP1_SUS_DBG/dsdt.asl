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
 Name(PWRS, Zero)
 OperationRegion(GP0B, SystemMemory, 0xfed80814, 0x04)
  Field(GP0B, ByteAcc, NoLock, Preserve) {
  , 11,
  USBS, 1,
 }
 OperationRegion (GPIO, SystemMemory, 0xfed80100, 0x100)
 Field (GPIO, ByteAcc, NoLock, Preserve) {
  Offset (0x39),
  , 6,
  GP57, 1,
  Offset (0x76),
  , 7,
  GE22, 1,
 }
 OperationRegion (SMIX, SystemMemory, 0xfed80200, 0x100)
 Field (SMIX, AnyAcc, NoLock, Preserve) {
  Offset (0x08),
  , 22,
  LPOL, 1,
 }
 Method (PNOT)
 {
  Store("Received PNOT call (probably from EC)", Debug)
 }
Scope (\_SB) {
 Device (LID)
 {
  Name(_HID, EisaId("PNP0C0D"))
  Name(_PRW, Package () {22, 0x04})
  Method(_LID, 0)
  {
   Return (GE22)
  }
  Method (_INI, 0)
  {
   Not(GE22, LPOL)
  }
 }
 Device(PWRB) {
  Name(_HID, EisaId("PNP0C0C"))
  Name(_UID, 0xAA)
  Name(_STA, 0x0B)
 }
 Device (MB) {
  Name(_HID, EisaId("PNP0C01"))
  Method (LIDO) { }
  Method (LIDC) { }
  Method (BRTU) { }
  Method (BRTD) { }
  Method (DSPS) { }
  Method (WLTG)
  {
   Store( Not(GP57), GP57 )
  }
  Method (LIDS)
  {
   Return(GE22)
  }
 }
}
Name(UOM0, 0)
Name(UOM1, 2)
Name(UOM2, 0)
Name(UOM3, 7)
Name(UOM4, 2)
Name(UOM5, 2)
Name(UOM6, 6)
Name(UOM7, 2)
Name(UOM8, 6)
Name(UOM9, 6)
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
Method(\_PTS, 1) {
 Store(0, Index(WKST,0))
 Store(0, Index(WKST,1))
 Store (0x07, UPWS)
}
Method(\_BFS, 1) {
}
Method(\_WAK, 1) {
 Store(1,USBS)
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
  Package(){0x0000FFFF, 0, INTA, 0 },
  Package(){0x0000FFFF, 1, INTB, 0 },
  Package(){0x0000FFFF, 2, INTC, 0 },
  Package(){0x0000FFFF, 3, INTD, 0 },
  Package(){0x0001FFFF, 0, INTB, 0 },
  Package(){0x0001FFFF, 1, INTC, 0 },
  Package(){0x0002FFFF, 0, INTC, 0 },
  Package(){0x0002FFFF, 1, INTD, 0 },
  Package(){0x0002FFFF, 2, INTA, 0 },
  Package(){0x0002FFFF, 3, INTB, 0 },
  Package(){0x0003FFFF, 0, INTD, 0 },
  Package(){0x0003FFFF, 1, INTA, 0 },
  Package(){0x0003FFFF, 2, INTB, 0 },
  Package(){0x0003FFFF, 3, INTC, 0 },
  Package(){0x0004FFFF, 0, INTA, 0 },
  Package(){0x0004FFFF, 1, INTB, 0 },
  Package(){0x0004FFFF, 2, INTC, 0 },
  Package(){0x0004FFFF, 3, INTD, 0 },
  Package(){0x0005FFFF, 0, INTB, 0 },
  Package(){0x0005FFFF, 1, INTC, 0 },
  Package(){0x0005FFFF, 2, INTD, 0 },
  Package(){0x0005FFFF, 3, INTA, 0 },
  Package(){0x0006FFFF, 0, INTC, 0 },
  Package(){0x0006FFFF, 1, INTD, 0 },
  Package(){0x0006FFFF, 2, INTA, 0 },
  Package(){0x0006FFFF, 3, INTB, 0 },
  Package(){0x0007FFFF, 0, INTD, 0 },
  Package(){0x0007FFFF, 1, INTA, 0 },
  Package(){0x0007FFFF, 2, INTB, 0 },
  Package(){0x0007FFFF, 3, INTC, 0 },
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
  Package(){0x0015FFFF, 0, INTA, 0 },
  Package(){0x0015FFFF, 1, INTB, 0 },
  Package(){0x0015FFFF, 2, INTC, 0 },
  Package(){0x0015FFFF, 3, INTD, 0 },
 })
 Name(APR0, Package(){
  Package(){0x0001FFFF, 0, 0, 17 },
  Package(){0x0001FFFF, 1, 0, 18 },
  Package(){0x0002FFFF, 0, 0, 18 },
  Package(){0x0002FFFF, 1, 0, 19 },
  Package(){0x0002FFFF, 2, 0, 16 },
  Package(){0x0002FFFF, 3, 0, 17 },
  Package(){0x0003FFFF, 0, 0, 19 },
  Package(){0x0003FFFF, 1, 0, 16 },
  Package(){0x0003FFFF, 2, 0, 17 },
  Package(){0x0003FFFF, 3, 0, 18 },
  Package(){0x0004FFFF, 0, 0, 16 },
  Package(){0x0004FFFF, 1, 0, 17 },
  Package(){0x0004FFFF, 2, 0, 18 },
  Package(){0x0004FFFF, 3, 0, 19 },
  Package(){0x0005FFFF, 0, 0, 17 },
  Package(){0x0005FFFF, 1, 0, 18 },
  Package(){0x0005FFFF, 2, 0, 19 },
  Package(){0x0005FFFF, 3, 0, 16 },
  Package(){0x0006FFFF, 0, 0, 18 },
  Package(){0x0006FFFF, 1, 0, 19 },
  Package(){0x0006FFFF, 2, 0, 16 },
  Package(){0x0006FFFF, 3, 0, 17 },
  Package(){0x0007FFFF, 0, 0, 19 },
  Package(){0x0007FFFF, 1, 0, 16 },
  Package(){0x0007FFFF, 2, 0, 17 },
  Package(){0x0007FFFF, 3, 0, 18 },
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
  Package(){0x0010FFFF, 0, 0, 0x12},
  Package(){0x0010FFFF, 1, 0, 0x11},
  Package(){0x0011FFFF, 0, 0, 19 },
  Package(){0x0015FFFF, 0, 0, 16 },
  Package(){0x0015FFFF, 1, 0, 17 },
  Package(){0x0015FFFF, 2, 0, 18 },
  Package(){0x0015FFFF, 3, 0, 19 },
 })
 Name(PS2, Package(){
  Package(){0x0000FFFF, 0, INTC, 0 },
  Package(){0x0000FFFF, 1, INTD, 0 },
  Package(){0x0000FFFF, 2, INTA, 0 },
  Package(){0x0000FFFF, 3, INTB, 0 },
 })
 Name(APS2, Package(){
  Package(){0x0000FFFF, 0, 0, 18 },
  Package(){0x0000FFFF, 1, 0, 19 },
  Package(){0x0000FFFF, 2, 0, 16 },
  Package(){0x0000FFFF, 3, 0, 17 },
 })
 Name(PS4, Package(){
  Package(){0x0000FFFF, 0, INTA, 0 },
  Package(){0x0000FFFF, 1, INTB, 0 },
  Package(){0x0000FFFF, 2, INTC, 0 },
  Package(){0x0000FFFF, 3, INTD, 0 },
 })
 Name(APS4, Package(){
  Package(){0x0000FFFF, 0, 0, 16 },
  Package(){0x0000FFFF, 1, 0, 17 },
  Package(){0x0000FFFF, 2, 0, 18 },
  Package(){0x0000FFFF, 3, 0, 19 },
 })
 Name(PS5, Package(){
  Package(){0x0000FFFF, 0, INTB, 0 },
  Package(){0x0000FFFF, 1, INTC, 0 },
  Package(){0x0000FFFF, 2, INTD, 0 },
  Package(){0x0000FFFF, 3, INTA, 0 },
 })
 Name(APS5, Package(){
  Package(){0x0000FFFF, 0, 0, 17 },
  Package(){0x0000FFFF, 1, 0, 18 },
  Package(){0x0000FFFF, 2, 0, 19 },
  Package(){0x0000FFFF, 3, 0, 16 },
 })
 Name(PS6, Package(){
  Package(){0x0000FFFF, 0, INTC, 0 },
  Package(){0x0000FFFF, 1, INTD, 0 },
  Package(){0x0000FFFF, 2, INTA, 0 },
  Package(){0x0000FFFF, 3, INTB, 0 },
 })
 Name(APS6, Package(){
  Package(){0x0000FFFF, 0, 0, 18 },
  Package(){0x0000FFFF, 1, 0, 19 },
  Package(){0x0000FFFF, 2, 0, 16 },
  Package(){0x0000FFFF, 3, 0, 17 },
 })
 Name(PS7, Package(){
  Package(){0x0000FFFF, 0, INTD, 0 },
  Package(){0x0000FFFF, 1, INTA, 0 },
  Package(){0x0000FFFF, 2, INTB, 0 },
  Package(){0x0000FFFF, 3, INTC, 0 },
 })
 Name(APS7, Package(){
  Package(){0x0000FFFF, 0, 0, 19 },
  Package(){0x0000FFFF, 1, 0, 16 },
  Package(){0x0000FFFF, 2, 0, 17 },
  Package(){0x0000FFFF, 3, 0, 18 },
 })
 Name(PE0, Package(){
  Package(){0x0000FFFF, 0, INTA, 0 },
  Package(){0x0000FFFF, 1, INTB, 0 },
  Package(){0x0000FFFF, 2, INTC, 0 },
  Package(){0x0000FFFF, 3, INTD, 0 },
 })
 Name(APE0, Package(){
  Package(){0x0000FFFF, 0, 0, 16 },
  Package(){0x0000FFFF, 1, 0, 17 },
  Package(){0x0000FFFF, 2, 0, 18 },
  Package(){0x0000FFFF, 3, 0, 19 },
 })
 Name(PE1, Package(){
  Package(){0x0000FFFF, 0, INTB, 0 },
  Package(){0x0000FFFF, 1, INTC, 0 },
  Package(){0x0000FFFF, 2, INTD, 0 },
  Package(){0x0000FFFF, 3, INTA, 0 },
 })
 Name(APE1, Package(){
  Package(){0x0000FFFF, 0, 0, 17 },
  Package(){0x0000FFFF, 1, 0, 18 },
  Package(){0x0000FFFF, 2, 0, 19 },
  Package(){0x0000FFFF, 3, 0, 16 },
 })
 Name(PE2, Package(){
  Package(){0x0000FFFF, 0, INTC, 0 },
  Package(){0x0000FFFF, 1, INTD, 0 },
  Package(){0x0000FFFF, 2, INTA, 0 },
  Package(){0x0000FFFF, 3, INTB, 0 },
 })
 Name(APE2, Package(){
  Package(){0x0000FFFF, 0, 0, 18 },
  Package(){0x0000FFFF, 1, 0, 19 },
  Package(){0x0000FFFF, 2, 0, 16 },
  Package(){0x0000FFFF, 3, 0, 17 },
 })
 Name(PE3, Package(){
  Package(){0x0000FFFF, 0, INTD, 0 },
  Package(){0x0000FFFF, 1, INTA, 0 },
  Package(){0x0000FFFF, 2, INTB, 0 },
  Package(){0x0000FFFF, 3, INTC, 0 },
 })
 Name(APE3, Package(){
  Package(){0x0000FFFF, 0, 0, 19 },
  Package(){0x0000FFFF, 1, 0, 16 },
  Package(){0x0000FFFF, 2, 0, 17 },
  Package(){0x0000FFFF, 3, 0, 18 },
 })
 Name(PCIB, Package(){
  Package(){0x0005FFFF, 0, 0, 0x14 },
  Package(){0x0005FFFF, 1, 0, 0x15 },
  Package(){0x0005FFFF, 2, 0, 0x16 },
  Package(){0x0005FFFF, 3, 0, 0x17 },
  Package(){0x0006FFFF, 0, 0, 0x15 },
  Package(){0x0006FFFF, 1, 0, 0x16 },
  Package(){0x0006FFFF, 2, 0, 0x17 },
  Package(){0x0006FFFF, 3, 0, 0x14 },
 })
  Device(PCI0) {
External (TOM1)
External (TOM2)
Name(_HID, EISAID("PNP0A03"))
Method (_BBN, 0, NotSerialized)
{
 Return (Zero)
}
Method (_STA, 0, NotSerialized)
{
 Return (0x0B)
}
Method (_PRT, 0, NotSerialized)
{
 If (PMOD)
 {
  Return (APR0)
 }
 Return (PR0)
}
Device(AMRT) {
 Name(_ADR, 0x00000000)
}
Device(PBR2) {
 Name(_ADR, 0x00020000)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS2) }
  Return (PS2)
 }
}
Device(PBR4) {
 Name(_ADR, 0x00040000)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS4) }
  Return (PS4)
 }
}
Device(PBR5) {
 Name(_ADR, 0x00050000)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS5) }
  Return (PS5)
 }
}
Device(PBR6) {
 Name(_ADR, 0x00060000)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS6) }
  Return (PS6)
 }
}
Device(PBR7) {
 Name(_ADR, 0x00070000)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT,0) {
  If(PMOD) { Return(APS7) }
  Return (PS7)
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
Device(UEH1) {
 Name(_ADR, 0x00140005)
 Name(_PRW, Package() {0x0B, 3})
}
Device(XHC0) {
 Name(_ADR, 0x00100000)
 Name(_PRW, Package() {0x0B, 4})
}
Device(XHC1) {
 Name(_ADR, 0x00100001)
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
Device (SIO) {
 Name (_HID, EisaId("PNP0A05"))
 Name (_UID, 0)
 Device (PS2K)
 {
  Name(_HID, EISAID("PNP0303"))
  Name(_CID, EISAID("PNP030B"))
  Name(_CRS, ResourceTemplate()
  {
   IO (Decode16, 0x60, 0x60, 0x01, 0x01)
   IO (Decode16, 0x64, 0x64, 0x01, 0x01)
   IRQ (Edge, ActiveHigh, Exclusive) { 0x01 }
  })
  Method (_STA, 0)
  {
   Return (0xf)
  }
 }
 Device (PS2M)
 {
  Name(_HID, EISAID("PNP0F13"))
  Name(_CID, EISAID("PNP0F13"))
  Name(_CRS, ResourceTemplate()
  {
   IRQ (Edge, ActiveHigh, Exclusive) { 0x0c }
  })
  Method(_STA, 0)
  {
   Return (0xf)
  }
 }
}
}
Device(SDCN) {
 Name(_ADR, 0x00140007)
}
Device(PIBR) {
 Name(_ADR, 0x00140004)
 Name(_PRW, Package() {0x18, 4})
 Method(_PRT, 0) {
  Return (PCIB)
 }
}
Device(ACMD) {
 Name(_ADR, 0x00140006)
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
 Scope(\_SB.PCI0.LIBR) {
Device (EC0)
{
 Name (_HID, EISAID ("PNP0C09"))
 Name (_UID, 1)
 Name (_GPE, 3)
 OperationRegion (ERAM, EmbeddedControl, 0x00, 0xff)
 Field (ERAM, ByteAcc, Lock, Preserve)
 {
  Offset(0x00),
  , 1,
  LCDS, 1,
  , 6,
  HTBN, 8,
  HTBT, 8,
  LMEN, 1,
  , 7,
  ADAP, 2,
  , 6,
  Offset(0x08),
  Offset(0x2D),
  DSPM, 1,
  Offset(0x2E),
  EFP1, 4,
  Offset(0x40),
  Offset(0x5D),
  ENIB, 16,
  ENDD, 8,
  Offset(0x60),
  SMPR, 8,
  SMST, 8,
  SMAD, 8,
  SMCM, 8,
  SMD0, 0x100,
  BCNT, 8,
  SMAA, 24,
  Offset(0x90),
  BMFN, 72,
  BATD, 56,
  Offset(0xA1),
  , 1,
  VIDO, 1,
  TOUP, 1,
  Offset(0xA2),
  ODTS, 8,
  Offset(0xA3),
  OSTY, 3,
  , 4,
  ADPT, 1,
  Offset(0xA4),
  PWAK, 1,
  MWAK, 1,
  LWAK, 1,
  RWAK, 1,
  WWAK, 1,
  UWAK, 1,
  KWAK, 1,
  TWAK, 1,
  Offset(0xA5),
  CCAC, 1,
  AOAC, 1,
  BLAC, 1,
  PSRC, 1,
  BOAC, 1,
  LCAC, 1,
  AAAC, 1,
  ACAC, 1,
  Offset(0xA6),
  S3ST, 1,
  S3RM, 1,
  S4ST, 1,
  S4RM, 1,
  S5ST, 1,
  S5RM, 1,
  , 2,
  Offset(0xA7),
  OSTT, 8,
  OSST, 8,
  THLT, 8,
  TCNL, 8,
  MODE, 1,
  , 2,
  INIT, 1,
  FAN1, 1,
  FAN2, 1,
  FANT, 1,
  SKNM, 1,
  SDTM, 8,
  FSSN, 4,
  FANU, 4,
  PCVL, 4,
  , 2,
  SWTO, 1,
  TTHR, 1,
  TTHM, 1,
  THTL, 1,
  , 2,
  NPST, 4,
  CTMP, 8,
  CTML, 8,
  SKTA, 8,
  SKTB, 8,
  SKTC, 8,
  , 8,
  NTMP, 8,
  Offset(0xB7),
  , 1,
  SKEY, 1,
  DIGM, 1,
  CDLE, 1,
  , 4,
  , 1,
  LIDF, 1,
  PMEE, 1,
  PWBE, 1,
  RNGE, 1,
  BTWE, 1,
  , 2,
  Offset(0xB9),
  BRTS, 8,
  S35M, 1,
  S35S, 1,
  , 2,
  FFEN, 1,
  FFST, 1,
  , 2,
  WLAT, 1,
  BTAT, 1,
  WLEX, 1,
  BTEX, 1,
  KLSW, 1,
  WLOK, 1,
  AT3G, 1,
  EX3G, 1,
  PJID, 8,
  CPUJ, 3,
  CPNM, 3,
  GATY, 2,
  Offset(0xBE),
  BOL0, 1,
  BOL1, 1,
  , 2,
  BCC0, 1,
  BCC1, 1,
  , 2,
  BPU0, 1,
  BPU1, 1,
  , 2,
  BOS0, 1,
  BOS1, 1,
  , 2,
  Offset(0xC0),
  BTY0, 1,
  BAM0, 1,
  BAL0, 1,
  , 1,
  BMF0, 3,
  , 1,
  BST0, 8,
  BRC0, 16,
  BSN0, 16,
  BPV0, 16,
  BDV0, 16,
  BDC0, 16,
  BFC0, 16,
  GAU0, 8,
  CYC0, 8,
  BPC0, 16,
  BAC0, 16,
  BTW0, 8,
  BVL0, 8,
  BTM0, 8,
  BAT0, 8,
  BCG0, 16,
  BCT0, 8,
  BCI0, 8,
  BCM0, 8,
  BOT0, 8,
  BSSB, 16,
  BOV0, 8,
  BCF0, 8,
  BAD0, 8,
  BCV1, 16,
  BCV2, 16,
  BCV3, 16,
  BCV4, 16,
  Offset(0xF4),
  BMD0, 16,
  BACV, 16,
  BDN0, 8,
  , 8
 }
 Method (_CRS, 0, NotSerialized)
 {
  Name (ECMD, ResourceTemplate()
  {
   IO (Decode16, 0x62, 0x62, 0, 1)
   IO (Decode16, 0x66, 0x66, 0, 1)
  })
  Return (ECMD)
 }
 Method (_REG, 2, NotSerialized)
 {
  Store (ADPT, \PWRS)
  Store (CTML, Local0)
  Increment (Local0)
 }
 Method (_Q11, 0, NotSerialized)
 {
  \_SB.MB.BRTD()
 }
 Method (_Q12, 0, NotSerialized)
 {
  \_SB.MB.BRTU()
 }
 Method (_Q15, 0, NotSerialized)
 {
  \_SB.MB.LIDO()
 }
 Method (_Q16, 0, NotSerialized)
 {
  \_SB.MB.LIDC()
 }
 Method (_Q1C, 0, NotSerialized)
 {
  \_SB.MB.DSPS()
 }
 Method (_Q37, 0, NotSerialized)
 {
  Store (One, \PWRS)
  Notify (AC, 0x80)
  Notify (BATX, 0x80)
  \PNOT ()
 }
 Method (_Q38, 0, NotSerialized)
 {
  Store (Zero, \PWRS)
  Notify (AC, 0x80)
  Notify (BATX, 0x80)
  \PNOT ()
 }
 Method (_Q40, 0, NotSerialized)
 {
  \_SB.MB.WLTG()
 }
 Method (_Q22, 0, NotSerialized)
 {
  Notify (BATX, 0x80)
 }
 Method(_Q25, 0, NotSerialized)
 {
  Notify(BATX, 0x81)
  Notify(BATX, 0x80)
 }
 Method(_Q60, 0, NotSerialized)
 {
  IF(WLEX)
  {
  }
 }
Device (AC)
{
 Name (_HID, "ACPI0003")
 Name (_PCL, Package () { \_SB })
 Method (_PSR)
 {
  Store(ADPT, Local0)
  Return(Local0)
 }
 Method (_STA)
 {
  Return (0x0F)
 }
}
Device (BATX)
{
 Name (_HID, EISAID ("PNP0C0A"))
 Name (_UID, 1)
 Name (_PCL, Package () { \_SB })
 Name (PBIF, Package () {
  0x00000001,
  0xFFFFFFFF,
  0xFFFFFFFF,
  0x00000001,
  0xFFFFFFFF,
  0x00000003,
  0xFFFFFFFF,
  0x00000001,
  0x00000001,
  "",
  "",
  "LION",
  ""
 })
 Name (PBST, Package () {
  0x00000000,
  0xFFFFFFFF,
  0xFFFFFFFF,
  0xFFFFFFFF,
 })
 Name (BTNM, Zero)
 Name (BFWK, One)
 Method (BFWE)
 {
  Store (One, BFWK)
 }
 Method (BFWD)
 {
  Store (Zero, BFWK)
 }
 Method (_STA, 0, Serialized)
 {
  If (BOL0) {
   Return (0x1F)
  } Else {
   Return (0x0F)
  }
 }
 Method (_BIF, 0, Serialized)
 {
  Store (BAM0, Index (PBIF, 0))
  Store (BDC0, Index (PBIF, 1))
  Store (BFC0, Index (PBIF, 2))
  Store (BDV0, Index (PBIF, 4))
  Divide(BFC0, 0x64, , Local1)
  Multiply(Local1, 0x0A, Local1)
  Store(Local1, Index(PBIF, 5))
  Divide(BFC0, 0x64, , Local1)
  Multiply(Local1, 0x03, Local1)
  Store (Local1, Index (PBIF, 6))
  Store (ToString(Concatenate(BATD, 0x00)), Index (PBIF, 9))
  Store (ToHexString(BSN0), Index (PBIF, 10))
  Store (ToString(BMFN), Index (PBIF, 12))
  Store(BDN0, BTNM)
  Return (PBIF)
 }
 Method (_BST, 0, Serialized)
 {
  Store (BST0, Local0)
  Store (Local0, Index (PBST, 0))
  Store (BAC0, Local1)
  Subtract(0xFFFF, Local1, Local1)
  Store (Local1, Index (PBST, 1))
  Multiply(BFC0, GAU0, Local1)
  Divide(Local1, 0x64, Local2, Local1)
  If (LAnd (BFWK, LAnd (ADPT, LNot (Local0)))) {
   Store (GAU0, Local2)
   ShiftRight (Local2, 5, Local3)
   If (LAnd (LGreater (Local1, Subtract (Local2, Local3)),
             LLess (Local1, Add (Local2, Local3))))
   {
    Store (Local2, Local1)
   }
  }
  Store (Local1, Index (PBST, 2))
  Store (BPV0, Index (PBST, 3))
  If(LNotEqual(BDN0, BTNM)) {
   Notify(BATX, 0x81)
  }
  Return (PBST)
 }
}
}
 }
Scope(\_GPE) {
 Method(_L08) {
 }
 Method(_L09) {
 }
 Method(_L0B) {
  Store("USB PME", Debug)
  Notify(\_SB.PCI0.UOH1, 0x02)
  Notify(\_SB.PCI0.UOH2, 0x02)
  Notify(\_SB.PCI0.UOH3, 0x02)
  Notify(\_SB.PCI0.UOH4, 0x02)
  Notify(\_SB.PCI0.XHC0, 0x02)
  Notify(\_SB.PCI0.UEH1, 0x02)
  Notify(\_SB.PWRB, 0x02)
 }
 Method(_L10) {
 }
 Method(_L11) {
 }
 Method(_L16) {
  Store("Lid status changed", Debug)
  Not(LPOL, LPOL)
  Notify(\_SB.LID, 0x80)
 }
 Method(_L18) {
  Store("PCI bridge wake event", Debug)
  Notify(\_SB.PCI0.PBR4, 0x02)
  Notify(\_SB.PCI0.PBR5, 0x02)
 }
 Method(_L1B) {
  Notify(\_SB.PCI0.AZHD, 0x02)
  Notify(\_SB.PWRB, 0x02)
 }
}
 Scope(\_SI) {
  Method(_SST, 1) {
  }
 }
}
