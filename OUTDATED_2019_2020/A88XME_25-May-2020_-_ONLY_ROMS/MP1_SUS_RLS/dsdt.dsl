/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200110 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of build/dsdt.aml, Mon May 25 10:03:09 2020
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00001935 (6453)
 *     Revision         0x02
 *     Checksum         0x43
 *     OEM ID           "COREv4"
 *     OEM Table ID     "COREBOOT"
 *     OEM Revision     0x00010001 (65537)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200110 (538968336)
 */
DefinitionBlock ("", "DSDT", 2, "COREv4", "COREBOOT", 0x00010001)
{
    External (_SB_.PCI0.TOM1, UnknownObj)
    External (_SB_.PCI0.TOM2, UnknownObj)
    External (TOM1, IntObj)

    Name (LOMH, Zero)
    Name (PBAD, Zero)
    Name (PBLN, Zero)
    Name (PCBA, 0xF8000000)
    Name (PCLN, 0x04000000)
    Name (HPBA, 0xFED00000)
    Name (OSVR, 0x03)
    Name (OSV, Ones)
    Name (PMOD, One)
    Name (UOM0, Zero)
    Name (UOM1, 0x02)
    Name (UOM2, Zero)
    Name (UOM3, 0x07)
    Name (UOM4, 0x02)
    Name (UOM5, 0x02)
    Name (UOM6, 0x06)
    Name (UOM7, 0x02)
    Name (UOM8, 0x06)
    Name (UOM9, 0x06)
    OperationRegion (PRQM, SystemIO, 0x0C00, 0x02)
    Field (PRQM, ByteAcc, NoLock, Preserve)
    {
        PRQI,   8, 
        PRQD,   8
    }

    IndexField (PRQI, PRQD, ByteAcc, NoLock, Preserve)
    {
        PIRA,   8, 
        PIRB,   8, 
        PIRC,   8, 
        PIRD,   8, 
        PIRE,   8, 
        PIRF,   8, 
        PIRG,   8, 
        PIRH,   8
    }

    OperationRegion (PERC, SystemIO, 0x0C14, One)
    Field (PERC, ByteAcc, NoLock, Preserve)
    {
        SENS,   1, 
        PENS,   1, 
        SENE,   1, 
        PENE,   1
    }

    OperationRegion (CMT, SystemIO, 0x0C50, 0x02)
    Field (CMT, ByteAcc, NoLock, Preserve)
    {
        CMTI,   8, 
        G64E,   1, 
        G64O,   1, 
        G32O,   2, 
            ,   2, 
        GPSL,   2
    }

    OperationRegion (GPT, SystemIO, 0x0C52, One)
    Field (GPT, ByteAcc, NoLock, Preserve)
    {
        GPB0,   1, 
        GPB1,   1, 
        GPB2,   1, 
        GPB3,   1, 
        GPB4,   1, 
        GPB5,   1, 
        GPB6,   1, 
        GPB7,   1
    }

    OperationRegion (FRE, SystemIO, 0x0C6F, One)
    Field (FRE, ByteAcc, NoLock, Preserve)
    {
            ,   6, 
        FLRE,   1
    }

    OperationRegion (PM2R, SystemIO, 0x0CD0, 0x02)
    Field (PM2R, ByteAcc, NoLock, Preserve)
    {
        PM2I,   8, 
        PM2D,   8
    }

    OperationRegion (PIOR, SystemIO, 0x0CD6, 0x02)
    Field (PIOR, ByteAcc, NoLock, Preserve)
    {
        PIOI,   8, 
        PIOD,   8
    }

    IndexField (PIOI, PIOD, ByteAcc, NoLock, Preserve)
    {
        Offset (0xEE), 
        UPWS,   3
    }

    Scope (_SB)
    {
        Device (P000)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
        }

        Device (P001)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
        }

        Device (P002)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
        }

        Device (P003)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
        }

        Device (P004)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
        }

        Device (P005)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
        }

        Device (P006)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
        }

        Device (P007)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
        }
    }

    Name (SSFG, 0x0D)
    If (Zero)
    {
        SSFG = (SSFG & 0xF7)
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    If ((SSFG & One))
    {
        Name (_S1, Package (0x04)  // _S1_: S1 System State
        {
            One, 
            One, 
            Zero, 
            Zero
        })
    }

    If ((SSFG & 0x02))
    {
        Name (_S2, Package (0x04)  // _S2_: S2 System State
        {
            0x02, 
            0x02, 
            Zero, 
            Zero
        })
    }

    If ((SSFG & 0x04))
    {
        Name (_S3, Package (0x04)  // _S3_: S3 System State
        {
            0x03, 
            0x03, 
            Zero, 
            Zero
        })
    }

    If ((SSFG & 0x08))
    {
        Name (_S4, Package (0x04)  // _S4_: S4 System State
        {
            0x04, 
            0x04, 
            Zero, 
            Zero
        })
    }

    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x05, 
        0x05, 
        Zero, 
        Zero
    })
    Name (WKST, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        WKST [Zero] = Zero
        WKST [One] = Zero
        UPWS = 0x07
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        Return (WKST) /* \WKST */
    }

    Scope (_SB)
    {
        Method (MIN, 2, NotSerialized)
        {
            If ((Arg0 < Arg1))
            {
                Return (Arg0)
            }
            Else
            {
                Return (Arg1)
            }
        }

        Method (SLEN, 1, NotSerialized)
        {
            Local0 = Arg0
            Return (SizeOf (Local0))
        }

        Method (S2BF, 1, Serialized)
        {
            Local0 = (SLEN (Arg0) + One)
            Name (BUFF, Buffer (Local0){})
            BUFF = Arg0
            Return (BUFF) /* \_SB_.S2BF.BUFF */
        }

        Method (SCMP, 2, NotSerialized)
        {
            Local0 = S2BF (Arg0)
            Local1 = S2BF (Arg1)
            Local4 = Zero
            Local5 = SLEN (Arg0)
            Local6 = SLEN (Arg1)
            Local7 = MIN (Local5, Local6)
            While ((Local4 < Local7))
            {
                Local2 = DerefOf (Local0 [Local4])
                Local3 = DerefOf (Local1 [Local4])
                If ((Local2 > Local3))
                {
                    Return (One)
                }
                ElseIf ((Local2 < Local3))
                {
                    Return (Ones)
                }

                Local4++
            }

            If ((Local4 < Local5))
            {
                Return (One)
            }
            ElseIf ((Local4 < Local6))
            {
                Return (Ones)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (WCMP, 2, NotSerialized)
        {
            Local0 = S2BF (Arg0)
            Local1 = S2BF (Arg1)
            If ((SLEN (Arg0) < SLEN (Arg1)))
            {
                Return (Zero)
            }

            Local2 = Zero
            Local3 = SLEN (Arg1)
            While ((Local2 < Local3))
            {
                If ((DerefOf (Local0 [Local2]) != DerefOf (Local1 [Local2]
                    )))
                {
                    Return (Zero)
                }

                Local2++
            }

            Return (One)
        }

        Method (I2BM, 1, NotSerialized)
        {
            Local0 = Zero
            If ((Arg0 != Zero))
            {
                Local1 = One
                Local0 = (Local1 << Arg0)
            }

            Return (Local0)
        }

        Name (PR0, Package (0x1F)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                0x03, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0012FFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0012FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0013FFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0013FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0016FFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0016FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0010FFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0010FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0011FFFF, 
                Zero, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                0x03, 
                INTD, 
                Zero
            }
        })
        Name (APR0, Package (0x1F)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0004FFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0012FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0012FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0013FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0013FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0016FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0016FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0010FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0010FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0011FFFF, 
                Zero, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0015FFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PS2, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTC, 
                Zero
            }
        })
        Name (APS2, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x11
            }
        })
        Name (PS4, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTD, 
                Zero
            }
        })
        Name (APS4, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
        Name (PS5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTA, 
                Zero
            }
        })
        Name (APS5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PS6, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTB, 
                Zero
            }
        })
        Name (APS6, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x11
            }
        })
        Name (PS7, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTC, 
                Zero
            }
        })
        Name (APS7, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x12
            }
        })
        Name (PBR0, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTD, 
                Zero
            }
        })
        Name (ABR0, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
        Name (PBR1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                INTB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                INTC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                INTD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                INTA, 
                Zero
            }
        })
        Name (ABR1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PCIB, Package (0x04)
        {
            Package (0x04)
            {
                0x0005FFFF, 
                Zero, 
                Zero, 
                0x14
            }, 

            Package (0x04)
            {
                0x0005FFFF, 
                One, 
                Zero, 
                0x15
            }, 

            Package (0x04)
            {
                0x0005FFFF, 
                0x02, 
                Zero, 
                0x16
            }, 

            Package (0x04)
            {
                0x0005FFFF, 
                0x03, 
                Zero, 
                0x17
            }
        })
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A03") /* PCI Bus */)  // _HID: Hardware ID
            Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
            {
                Return (Zero)
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0B)
            }

            Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
            {
                If (PMOD)
                {
                    Return (APR0) /* \_SB_.APR0 */
                }

                Return (PR0) /* \_SB_.PR0_ */
            }

            Device (AMRT)
            {
                Name (_ADR, Zero)  // _ADR: Address
            }

            Device (PBR2)
            {
                Name (_ADR, 0x00020000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PMOD)
                    {
                        Return (APS2) /* \_SB_.APS2 */
                    }

                    Return (PS2) /* \_SB_.PS2_ */
                }
            }

            Device (PBR4)
            {
                Name (_ADR, 0x00040000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PMOD)
                    {
                        Return (APS4) /* \_SB_.APS4 */
                    }

                    Return (PS4) /* \_SB_.PS4_ */
                }
            }

            Device (PBR5)
            {
                Name (_ADR, 0x00050000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PMOD)
                    {
                        Return (APS5) /* \_SB_.APS5 */
                    }

                    Return (PS5) /* \_SB_.PS5_ */
                }
            }

            Device (PBR6)
            {
                Name (_ADR, 0x00060000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PMOD)
                    {
                        Return (APS6) /* \_SB_.APS6 */
                    }

                    Return (PS6) /* \_SB_.PS6_ */
                }
            }

            Device (PBR7)
            {
                Name (_ADR, 0x00070000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PMOD)
                    {
                        Return (APS7) /* \_SB_.APS7 */
                    }

                    Return (PS7) /* \_SB_.PS7_ */
                }
            }

            Device (K10M)
            {
                Name (_ADR, 0x00180003)  // _ADR: Address
                OperationRegion (TCFG, PCI_Config, 0x64, 0x04)
                Field (TCFG, ByteAcc, NoLock, Preserve)
                {
                    HTCE,   1, 
                    Offset (0x02), 
                    TLMT,   7, 
                    Offset (0x04)
                }

                OperationRegion (TCTL, PCI_Config, 0xA4, 0x04)
                Field (TCTL, ByteAcc, NoLock, Preserve)
                {
                        ,   21, 
                    TNOW,   11
                }

                ThermalZone (TZ00)
                {
                    Name (_STR, Unicode ("AMD CPU Core Thermal Sensor"))  // _STR: Description String
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((HTCE == One))
                        {
                            Return (0x0F)
                        }

                        Return (Zero)
                    }

                    Method (_TMP, 0, NotSerialized)  // _TMP: Temperature
                    {
                        Local0 = (TNOW * 0x0A)
                        Local0 >>= 0x03
                        Return ((Local0 + 0x0AAC))
                    }

                    Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
                    {
                        Local0 = (TLMT * 0x0A)
                        Local0 >>= One
                        Local0 += 0x0208
                        Return ((Local0 + 0x0AAC))
                    }

                    Method (_HOT, 0, NotSerialized)  // _HOT: Hot Temperature
                    {
                        Return ((_PSV () + 0x32))
                    }

                    Method (_CRT, 0, NotSerialized)  // _CRT: Critical Temperature
                    {
                        Return ((_HOT () + 0x32))
                    }
                }
            }

            Method (_OSC, 4, NotSerialized)  // _OSC: Operating System Capabilities
            {
                If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
                {
                    Return (Arg3)
                }
                Else
                {
                    CreateDWordField (Arg3, Zero, CDW1)
                    CDW1 |= 0x04
                    Return (Arg3)
                }
            }

            Device (STCR)
            {
                Name (_ADR, 0x00110000)  // _ADR: Address
            }

            Device (SBUS)
            {
                Name (_ADR, 0x00140000)  // _ADR: Address
            }

            Device (UOH1)
            {
                Name (_ADR, 0x00120000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UOH2)
            {
                Name (_ADR, 0x00120002)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UOH3)
            {
                Name (_ADR, 0x00130000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UOH4)
            {
                Name (_ADR, 0x00130002)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UOH5)
            {
                Name (_ADR, 0x00160000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UOH6)
            {
                Name (_ADR, 0x00160002)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (UEH1)
            {
                Name (_ADR, 0x00140005)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x03
                })
            }

            Device (XHC0)
            {
                Name (_ADR, 0x00100000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x04
                })
            }

            Device (XHC1)
            {
                Name (_ADR, 0x00100001)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x04
                })
            }

            Device (AZHD)
            {
                Name (_ADR, 0x00140002)  // _ADR: Address
                OperationRegion (AZPD, PCI_Config, Zero, 0x0100)
                Field (AZPD, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x42), 
                    NSDI,   1, 
                    NSDO,   1, 
                    NSEN,   1, 
                    Offset (0x44), 
                    IPCR,   4, 
                    Offset (0x54), 
                    PWST,   2, 
                    Offset (0x55), 
                    PMEB,   1, 
                        ,   6, 
                    PMST,   1, 
                    Offset (0x62), 
                    MMCR,   1, 
                    Offset (0x64), 
                    MMLA,   32, 
                    MMHA,   32, 
                    MMDT,   16
                }

                Method (_INI, 0, NotSerialized)  // _INI: Initialize
                {
                    If ((OSVR == 0x03))
                    {
                        NSEN = Zero
                        NSDO = One
                        NSDI = One
                    }
                }
            }

            Device (LIBR)
            {
                Name (_ADR, 0x00140003)  // _ADR: Address
                OperationRegion (CFG, PCI_Config, Zero, 0x0100)
                Field (CFG, DWordAcc, NoLock, Preserve)
                {
                    Offset (0xA0), 
                    BAR,    32
                }

                Device (LDRC)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (CRS, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadWrite,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y00)
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (CRS, \_SB.PCI0.LIBR.LDRC._Y00._BAS, SPIB)  // _BAS: Base Address
                        CreateDWordField (CRS, \_SB.PCI0.LIBR.LDRC._Y00._LEN, SPIL)  // _LEN: Length
                        SPIB = BAR /* \_SB_.PCI0.LIBR.BAR_ */
                        SPIL = 0x1000
                        Return (CRS) /* \_SB_.PCI0.LIBR.LDRC.CRS_ */
                    }
                }

                Device (RTC0)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IRQNoFlags ()
                            {8}
                        IO (Decode16,
                            0x0070,             // Range Minimum
                            0x0070,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IRQNoFlags ()
                            {0}
                        IO (Decode16,
                            0x0040,             // Range Minimum
                            0x0040,             // Range Maximum
                            0x00,               // Alignment
                            0x04,               // Length
                            )
                    })
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0061,             // Range Minimum
                            0x0061,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                    })
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IRQNoFlags ()
                            {2}
                        IO (Decode16,
                            0x0020,             // Range Minimum
                            0x0020,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A0,             // Range Minimum
                            0x00A0,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                    })
                }

                Device (MAD)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        DMA (Compatibility, BusMaster, Transfer8, )
                            {4}
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x10,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0081,             // Range Minimum
                            0x0081,             // Range Maximum
                            0x01,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x0087,             // Range Minimum
                            0x0087,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0089,             // Range Minimum
                            0x0089,             // Range Maximum
                            0x01,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x008F,             // Range Minimum
                            0x008F,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x00C0,             // Range Minimum
                            0x00C0,             // Range Maximum
                            0x10,               // Alignment
                            0x20,               // Length
                            )
                    })
                }

                Device (COPR)
                {
                    Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x00F0,             // Range Minimum
                            0x00F0,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IRQNoFlags ()
                            {13}
                    })
                }
            }

            Device (SDCN)
            {
                Name (_ADR, 0x00140007)  // _ADR: Address
            }

            Device (PIBR)
            {
                Name (_ADR, 0x00140004)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x18, 
                    0x04
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (PCIB) /* \_SB_.PCIB */
                }
            }

            Device (ACMD)
            {
                Name (_ADR, 0x00140006)  // _ADR: Address
            }

            Name (CRES, ResourceTemplate ()
            {
                WordBusNumber (ResourceProducer, MinFixed, MaxFixed, PosDecode,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x00FF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0100,             // Length
                    ,, )
                IO (Decode16,
                    0x0CF8,             // Range Minimum
                    0x0CF8,             // Range Maximum
                    0x01,               // Alignment
                    0x08,               // Length
                    )
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x0CF7,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0CF8,             // Length
                    ,, , TypeStatic, DenseTranslation)
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x03B0,             // Range Minimum
                    0x03DF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0030,             // Length
                    ,, , TypeStatic, DenseTranslation)
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0D00,             // Range Minimum
                    0xFFFF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0xF300,             // Length
                    ,, , TypeStatic, DenseTranslation)
                Memory32Fixed (ReadOnly,
                    0x000A0000,         // Address Base
                    0x00020000,         // Address Length
                    )
                Memory32Fixed (ReadOnly,
                    0x000C0000,         // Address Base
                    0x00020000,         // Address Length
                    )
                Memory32Fixed (ReadOnly,
                    0x00000000,         // Address Base
                    0x00000000,         // Address Length
                    _Y01)
            })
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateDWordField (CRES, \_SB.PCI0._Y01._BAS, MM1B)  // _BAS: Base Address
                CreateDWordField (CRES, \_SB.PCI0._Y01._LEN, MM1L)  // _LEN: Length
                MM1B = TOM1 /* External reference */
                Local0 = 0x0000000100000000
                Local0 -= TOM1 /* External reference */
                MM1L = Local0
                Return (CRES) /* \_SB_.PCI0.CRES */
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                OSFL ()
            }

            Method (OSFL, 0, NotSerialized)
            {
                If ((OSVR != Ones))
                {
                    Return (OSVR) /* \OSVR */
                }

                If (CondRefOf (\_OSI))
                {
                    OSVR = One
                    If (_OSI ("Windows 2006"))
                    {
                        OSVR = 0x02
                    }
                }
                ElseIf (WCMP (_OS, "Linux"))
                {
                    OSVR = 0x03
                }
                Else
                {
                    OSVR = 0x04
                }

                Return (OSVR) /* \OSVR */
            }
        }

        OperationRegion (PCFG, SystemMemory, PCBA, PCLN)
        Field (PCFG, ByteAcc, NoLock, Preserve)
        {
            Offset (0x88024), 
            STB5,   32, 
            Offset (0x98042), 
            PT0D,   1, 
            PT1D,   1, 
            PT2D,   1, 
            PT3D,   1, 
            PT4D,   1, 
            PT5D,   1, 
            PT6D,   1, 
            PT7D,   1, 
            PT8D,   1, 
            PT9D,   1, 
            Offset (0xA0004), 
            SBIE,   1, 
            SBME,   1, 
            Offset (0xA0008), 
            SBRI,   8, 
            Offset (0xA0014), 
            SBB1,   32, 
            Offset (0xA0078), 
                ,   14, 
            P92E,   1
        }

        OperationRegion (SB5, SystemMemory, STB5, 0x1000)
        Field (SB5, AnyAcc, NoLock, Preserve)
        {
            Offset (0x120), 
            P0ER,   1, 
                ,   2, 
            P0DQ,   1, 
                ,   3, 
            P0BY,   1, 
            Offset (0x128), 
            P0DD,   4, 
            Offset (0x129), 
            P0IS,   4, 
            Offset (0x12C), 
            P0DI,   4, 
            Offset (0x130), 
            Offset (0x132), 
            P0PR,   1, 
            Offset (0x1A0), 
            P1ER,   1, 
                ,   2, 
            P1DQ,   1, 
                ,   3, 
            P1BY,   1, 
            Offset (0x1A8), 
            P1DD,   4, 
            Offset (0x1A9), 
            P1IS,   4, 
            Offset (0x1AC), 
            P1DI,   4, 
            Offset (0x1B0), 
            Offset (0x1B2), 
            P1PR,   1, 
            Offset (0x220), 
            P2ER,   1, 
                ,   2, 
            P2DQ,   1, 
                ,   3, 
            P2BY,   1, 
            Offset (0x228), 
            P2DD,   4, 
            Offset (0x229), 
            P2IS,   4, 
            Offset (0x22C), 
            P2DI,   4, 
            Offset (0x230), 
            Offset (0x232), 
            P2PR,   1, 
            Offset (0x2A0), 
            P3ER,   1, 
                ,   2, 
            P3DQ,   1, 
                ,   3, 
            P3BY,   1, 
            Offset (0x2A8), 
            P3DD,   4, 
            Offset (0x2A9), 
            P3IS,   4, 
            Offset (0x2AC), 
            P3DI,   4, 
            Offset (0x2B0), 
            Offset (0x2B2), 
            P3PR,   1
        }

        Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
        {
            If (Arg0)
            {
                CIRQ ()
            }

            PMOD = Arg0
        }

        Method (CIRQ, 0, NotSerialized)
        {
        }

        Name (IRQB, ResourceTemplate ()
        {
            IRQ (Level, ActiveLow, Shared, )
                {15}
        })
        Name (IRQP, ResourceTemplate ()
        {
            IRQ (Level, ActiveLow, Exclusive, )
                {3,4,5,7,10,11,12,15}
        })
        Name (PITF, ResourceTemplate ()
        {
            IRQ (Level, ActiveLow, Exclusive, )
                {9}
        })
        Device (INTA)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRA)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRA) /* \PIRA */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRA = Local0
            }
        }

        Device (INTB)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRB)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRB) /* \PIRB */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRB = Local0
            }
        }

        Device (INTC)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRC)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRC) /* \PIRC */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRC = Local0
            }
        }

        Device (INTD)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRD)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRD) /* \PIRD */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRD = Local0
            }
        }

        Device (INTE)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRE)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRE) /* \PIRE */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRE = Local0
            }
        }

        Device (INTF)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRF)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PITF) /* \_SB_.PITF */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRF) /* \PIRF */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRF = Local0
            }
        }

        Device (INTG)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRG)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRG) /* \PIRG */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRG = Local0
            }
        }

        Device (INTH)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x08)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRH)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (IRQP) /* \_SB_.IRQP */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (IRQB, One, IRQN)
                IRQN = (One << PIRH) /* \PIRH */
                Return (IRQB) /* \_SB_.IRQB */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRQM)
                FindSetRightBit (IRQM, Local0)
                If (Local0)
                {
                    Local0--
                }

                PIRH = Local0
            }
        }
    }

    Scope (_GPE)
    {
        Method (_L03, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
        }

        Method (_L08, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
        }

        Method (_L09, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
        }

        Method (_L0B, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Notify (\_SB.PCI0.UOH1, 0x02) // Device Wake
            Notify (\_SB.PCI0.UOH2, 0x02) // Device Wake
            Notify (\_SB.PCI0.UOH3, 0x02) // Device Wake
            Notify (\_SB.PCI0.UOH4, 0x02) // Device Wake
            Notify (\_SB.PCI0.UOH5, 0x02) // Device Wake
            Notify (\_SB.PCI0.UOH6, 0x02) // Device Wake
            Notify (\_SB.PCI0.UEH1, 0x02) // Device Wake
        }

        Method (_L10, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
        }

        Method (_L11, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
        }

        Method (_L18, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Notify (\_SB.PCI0.PBR4, 0x02) // Device Wake
        }

        Method (_L1B, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Notify (\_SB.PCI0.AZHD, 0x02) // Device Wake
        }
    }
}

