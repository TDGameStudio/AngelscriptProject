# Maintained Opcode Inventory

Source-only planning inventory, captured 2026-09-06 +08:00. No row is a runtime PASS claim or task completion state. The public enum in Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h supplies the ordinals; the matching as_context.cpp case labels establish only dispatch presence.

There are 213 assigned runtime values 0..212, 38 reserved values 213..250, and five compiler-only records 251..255. MAXBYTECODE=212 is the maximum assigned ordinal, not a count. Final acceptance requires 212 supported runtime semantics plus explicit STR rejection, and separate rejection of reserved/pseudo values.

## Evidence and usage

- Header SHA-256: 4d805c4cc7ab60757a046eb3566654b132824c6d7e93e3629525512718b9c9fd.
- Context SHA-256: b957b6bfeffeae31715babc9ca44afff7193f8c562d9397df420ee167d8ccd53.
- Historical repository provenance and initial coupling anchors are in runtime-dependency-inventory.md.
- Every row also consumes 2.1 codec/operand schemas, 2.2 structural verification and 2.3 symbol/link validation when its operands contain references. The Primary task column assigns the execution/rejection obligation, not all dependencies.
- Historical 4.2/implementation-verification.md records NativeEngine RunIds `6f4ed80cd8fa46369d45f2e6bf6f4049` and `bf8cfb03ed9a4607b347c40a1442660f`. The External Review finds that aggregate/family mapping does not close every row or establish complete source/binary digest provenance. Current final reconciliation belongs to 11.3.
- Runtime services not represented by dedicated opcodes (weak references, cycle GC, shutdown, native ABI preparation) remain mandatory task cases.

## Historical pre-implementation source observations

- STR at as_context.cpp:2568 asserts deprecated rather than functioning.
- CALLBND at :2600 uses old imported-function slots; stable bound slots retain behaviour without source import.
- DestructScript at :4515 has both body and PC advance commented. This Change implements it; it is not a retired instruction.
- CALLSYS at :2574 carries a live pointer and advances by a target-specific width. The symbolic wire format uses typed slots, never this live pointer image.
- JitEntry at :3933 and SaveReturnValue at :4619 are VM marker paths, not proof of a JIT backend.
- Optional resolution/reference-debug hooks at :4553/:4576 require SDK policies and safe absent-hook behaviour.

## Follow-up proof partition

The original columns and primary task assignments remain historical acceptance ownership. The added owner column assigns pending proof only; it is not a PASS claim or second execution state. Each row must map to a complete public test identity, an actual executed path and an independently specified value/state/lifetime/error oracle.

| Owner | Assigned rows | Runtime execution | Assigned rejection | Other rejection |
|---|---|---|---|---|
| 9.1 | 121 | 121 | 0 | 0 |
| 9.2 | 43 | 43 | 0 | 0 |
| 9.3 | 49 | 48 | STR | Every reserved 213..250 and pseudo 251..255 |
| Total | 213 | 212 | 1 | 43 |

9.2 owns every floating/double operation and all conversions involving those types. 9.1 owns the remaining historical 3.1 rows except CALL/RET; it includes integer-only conversions and JMPP. 9.3 owns the other rows plus CALL/RET, preserving the original required independent observation. All 256 ordinal dispositions have exactly one follow-up owner. Shared runs may serve several rows, but shared handlers, named opcodes without executed paths, or a passing sibling do not discharge a row.

## Assigned runtime values

| Value | Opcode | Primary task | Required independent observation | Follow-up proof owner |
|---|---|---|---|---|
| 0 | PopPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 1 | PshGPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 2 | PshC4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 3 | PshV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 4 | PSF | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 5 | SwapPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 6 | NOT | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 7 | PshG4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 8 | LdGRdR4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 9 | CALL | 3.1 | Nested real script call, full arguments/return and frame balance | 9.3 |
| 10 | RET | 3.1 | Nested real script call, full arguments/return and frame balance | 9.3 |
| 11 | JMP | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 12 | JZ | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 13 | JNZ | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 14 | JS | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 15 | JNS | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 16 | JP | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 17 | JNP | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 18 | TZ | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 19 | TNZ | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 20 | TS | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 21 | TNS | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 22 | TP | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 23 | TNP | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 24 | NEGi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 25 | NEGf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 26 | NEGd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 27 | INCi16 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 28 | INCi8 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 29 | DECi16 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 30 | DECi8 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 31 | INCi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 32 | DECi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 33 | INCf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 34 | DECf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 35 | INCd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 36 | DECd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 37 | IncVi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 38 | DecVi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 39 | BNOT | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 40 | BAND | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 41 | BOR | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 42 | BXOR | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 43 | BSLL | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 44 | BSRL | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 45 | BSRA | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 46 | COPY | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 47 | PshC8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 48 | PshVPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 49 | RDSPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 50 | CMPd | 3.1 | Independent comparison flags and downstream branch result | 9.2 |
| 51 | CMPu | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 52 | CMPf | 3.1 | Independent comparison flags and downstream branch result | 9.2 |
| 53 | CMPi | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 54 | CMPIi | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 55 | CMPIf | 3.1 | Independent comparison flags and downstream branch result | 9.2 |
| 56 | CMPIu | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 57 | JMPP | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 58 | PopRPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 59 | PshRPtr | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 60 | STR | 2.2 | Reject retired opcode before publication | 9.3 |
| 61 | CALLSYS | 3.2 | Generic/typed native callback values; target-width live operand | 9.3 |
| 62 | CALLBND | 3.4 | Execute stable script/native/delegate bound slots; no source import | 9.3 |
| 63 | SUSPEND | 3.6 | Suspend/resume/abort with live-frame ownership | 9.3 |
| 64 | ALLOC | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 65 | FREE | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 66 | LOADOBJ | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 67 | STOREOBJ | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 68 | GETOBJ | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 69 | REFCPY | 3.5 | Balanced strong ownership plus GC/root integration | 9.3 |
| 70 | CHKREF | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 71 | GETOBJREF | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 72 | GETREF | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 73 | PshNull | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 74 | ClrVPtr | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 75 | OBJTYPE | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 76 | TYPEID | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 77 | SetV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 78 | SetV8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 79 | ADDSi | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 80 | CpyVtoV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 81 | CpyVtoV8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 82 | CpyVtoR4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 83 | CpyVtoR8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 84 | CpyVtoG4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 85 | CpyRtoV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 86 | CpyRtoV8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 87 | CpyGtoV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 88 | WRTV1 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 89 | WRTV2 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 90 | WRTV4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 91 | WRTV8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 92 | RDR1 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 93 | RDR2 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 94 | RDR4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 95 | RDR8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 96 | LDG | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 97 | LDV | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 98 | PGA | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 99 | CmpPtr | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 100 | VAR | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 101 | iTOf | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 102 | fTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 103 | uTOf | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 104 | fTOu | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 105 | sbTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 106 | swTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 107 | ubTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 108 | uwTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 109 | dTOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 110 | dTOu | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 111 | dTOf | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 112 | iTOd | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 113 | uTOd | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 114 | fTOd | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 115 | ADDi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 116 | SUBi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 117 | MULi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 118 | DIVi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 119 | MODi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 120 | ADDf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 121 | SUBf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 122 | MULf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 123 | DIVf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 124 | MODf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 125 | ADDd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 126 | SUBd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 127 | MULd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 128 | DIVd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 129 | MODd | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 130 | ADDIi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 131 | SUBIi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 132 | MULIi | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 133 | ADDIf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 134 | SUBIf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 135 | MULIf | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.2 |
| 136 | SetG4 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 137 | ChkRefS | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 138 | ChkNullV | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 139 | CALLINTF | 3.4 | Actual dynamic/indirect target, receiver and invalid-target result | 9.3 |
| 140 | iTOb | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 141 | iTOw | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 142 | SetV1 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 143 | SetV2 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 144 | Cast | 3.4 | Actual dynamic/indirect target, receiver and invalid-target result | 9.3 |
| 145 | i64TOi | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 146 | uTOi64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 147 | iTOi64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.1 |
| 148 | fTOi64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 149 | dTOi64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 150 | fTOu64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 151 | dTOu64 | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 152 | i64TOf | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 153 | u64TOf | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 154 | i64TOd | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 155 | u64TOd | 3.1 | Independent conversion value/representation and boundary oracle | 9.2 |
| 156 | NEGi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 157 | INCi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 158 | DECi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 159 | BNOT64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 160 | ADDi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 161 | SUBi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 162 | MULi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 163 | DIVi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 164 | MODi64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 165 | BAND64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 166 | BOR64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 167 | BXOR64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 168 | BSLL64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 169 | BSRL64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 170 | BSRA64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 171 | CMPi64 | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 172 | CMPu64 | 3.1 | Independent comparison flags and downstream branch result | 9.1 |
| 173 | ChkNullS | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 174 | ClrHi | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 175 | JitEntry | 3.6 | VM marker advances; no JIT backend | 9.3 |
| 176 | CallPtr | 3.4 | Actual dynamic/indirect target, receiver and invalid-target result | 9.3 |
| 177 | FuncPtr | 3.4 | Actual dynamic/indirect target, receiver and invalid-target result | 9.3 |
| 178 | LoadThisR | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 179 | PshV8 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 180 | DIVu | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 181 | MODu | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 182 | DIVu64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 183 | MODu64 | 3.1 | Independent numeric/bit result, width and defined failure boundary | 9.1 |
| 184 | LoadRObjR | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 185 | LoadVObjR | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 186 | RefCpyV | 3.5 | Balanced local handle assignment plus GC/root integration | 9.3 |
| 187 | JLowZ | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 188 | JLowNZ | 3.1 | Taken/not-taken or indexed target and terminating loop oracle | 9.1 |
| 189 | AllocMem | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 190 | SetListSize | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 191 | PshListElmnt | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 192 | SetListType | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 193 | POWi | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 194 | POWu | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 195 | POWf | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.2 |
| 196 | POWd | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.2 |
| 197 | POWdi | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.2 |
| 198 | POWi64 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 199 | POWu64 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 200 | Thiscall1 | 3.2 | Supported typed receiver call and correct receiver adjustment | 9.3 |
| 201 | FinConstruct | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 202 | DestructScript | 3.3 | Execute destruction once and advance to following sentinel | 9.3 |
| 203 | CopyScript | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 204 | ResolveObjectPtr | 3.3 | SDK callback or checked absent-hook no-op; never UE fallback | 9.3 |
| 205 | FreeNullV8 | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 206 | TrackRef | 3.6 | Enabled SDK observation and disabled advance | 9.3 |
| 207 | UntrackRef | 3.6 | Enabled balanced SDK observation and disabled advance | 9.3 |
| 208 | ValidateRef | 3.6 | Enabled SDK validation and disabled advance | 9.3 |
| 209 | CpyVtoR1 | 3.1 | Actual stack/register/global/local memory value and sentinels | 9.1 |
| 210 | SaveReturnValue | 3.6 | VM marker advances without changing language result | 9.3 |
| 211 | CmpPtrNull | 3.3 | Actual payload/type/address/lifetime or explicit null failure | 9.3 |
| 212 | ThrowException | 3.6 | Real exception, source observation and balanced unwind | 9.3 |

## Non-runtime values

| Values | Names | Admission |
|---|---|---|
| 213..250 | Reserved dummy values | Reject each value in 2.2; never execute |
| 251 | VarDecl | Reject compiler-only input in 2.2 |
| 252 | Block | Reject compiler-only input in 2.2 |
| 253 | ObjInfo | Reject compiler-only input in 2.2 |
| 254 | LINE | Reject compiler-only input in 2.2 |
| 255 | LABEL | Reject compiler-only input in 2.2 |

Primary assignment counts: 2.2 = 1; 3.1 = 166; 3.2 = 2; 3.3 = 30; 3.4 = 5; 3.5 = 2; 3.6 = 7. Their sum is 213. These are scope counts, not test counts.

## Per-row public test identity

Freeze NativeEngine RunIds `dfb0594750fd4af89e87b62a31435395` and `07b76d4ef99344ec8a9eb346a7841067` re-executed these identities. GETOBJREF and LoadThisR have dedicated emit+Execute oracles; reserved/pseudo reject at author/decode admission.

| Value | Opcode | Public test identity |
|---|---|---|
| 0 | PopPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 1 | PshGPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 2 | PshC4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 3 | PshV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 4 | PSF | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.StackPointerAndVar |
| 5 | SwapPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 6 | NOT | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 7 | PshG4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 8 | LdGRdR4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 9 | CALL | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.NestedCallAndReturn |
| 10 | RET | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.NestedCallAndReturn |
| 11 | JMP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 12 | JZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 13 | JNZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 14 | JS | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 15 | JNS | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 16 | JP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 17 | JNP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 18 | TZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 19 | TNZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 20 | TS | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 21 | TNS | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 22 | TP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 23 | TNP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 24 | NEGi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 25 | NEGf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 26 | NEGd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 27 | INCi16 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 28 | INCi8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 29 | DECi16 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 30 | DECi8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 31 | INCi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 32 | DECi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 33 | INCf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 34 | DECf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 35 | INCd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 36 | DECd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.NegIncDecFloatDouble |
| 37 | IncVi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 38 | DecVi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 39 | BNOT | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 40 | BAND | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 41 | BOR | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 42 | BXOR | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 43 | BSLL | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 44 | BSRL | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 45 | BSRA | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise32 |
| 46 | COPY | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 47 | PshC8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 48 | PshVPtr | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 49 | RDSPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 50 | CMPd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatDoubleComparisons |
| 51 | CMPu | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 52 | CMPf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatDoubleComparisons |
| 53 | CMPi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 54 | CMPIi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 55 | CMPIf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatDoubleComparisons |
| 56 | CMPIu | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 57 | JMPP | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.JumpTableEachArmDefaultAndMalformed |
| 58 | PopRPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 59 | PshRPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 60 | STR | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 61 | CALLSYS | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CallSysReturnsFortyTwo |
| 62 | CALLBND | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CallBndScriptAndNative |
| 63 | SUSPEND | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObserversMarkersSuspendAndThrow |
| 64 | ALLOC | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 65 | FREE | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 66 | LOADOBJ | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CastStoreLoadAndCallIntf |
| 67 | STOREOBJ | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CastStoreLoadAndCallIntf |
| 68 | GETOBJ | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi |
| 69 | REFCPY | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 70 | CHKREF | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi |
| 71 | GETOBJREF | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjRefReplacesStackWithHandleThenReadsSeventeen |
| 72 | GETREF | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi |
| 73 | PshNull | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi |
| 74 | ClrVPtr | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 75 | OBJTYPE | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 76 | TYPEID | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 77 | SetV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 78 | SetV8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 79 | ADDSi | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi |
| 80 | CpyVtoV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 81 | CpyVtoV8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 82 | CpyVtoR4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 83 | CpyVtoR8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 84 | CpyVtoG4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 85 | CpyRtoV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 86 | CpyRtoV8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 87 | CpyGtoV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 88 | WRTV1 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 89 | WRTV2 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 90 | WRTV4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 91 | WRTV8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 92 | RDR1 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 93 | RDR2 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 94 | RDR4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 95 | RDR8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels |
| 96 | LDG | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 97 | LDV | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 98 | PGA | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 99 | CmpPtr | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 100 | VAR | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.StackPointerAndVar |
| 101 | iTOf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 102 | fTOi | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 103 | uTOf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 104 | fTOu | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 105 | sbTOi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 106 | swTOi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 107 | ubTOi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 108 | uwTOi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 109 | dTOi | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 110 | dTOu | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 111 | dTOf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 112 | iTOd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 113 | uTOd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 114 | fTOd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.IntegerFloatConversions |
| 115 | ADDi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 116 | SUBi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 117 | MULi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 118 | DIVi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 119 | MODi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 120 | ADDf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 121 | SUBf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 122 | MULf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 123 | DIVf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 124 | MODf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 125 | ADDd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.DoubleArithmetic |
| 126 | SUBd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.DoubleArithmetic |
| 127 | MULd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.DoubleArithmetic |
| 128 | DIVd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.DoubleArithmetic |
| 129 | MODd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.DoubleArithmetic |
| 130 | ADDIi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 131 | SUBIi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 132 | MULIi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer32Arithmetic |
| 133 | ADDIf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 134 | SUBIf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 135 | MULIf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate |
| 136 | SetG4 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.GlobalMoves |
| 137 | ChkRefS | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.NullChecksThrow |
| 138 | ChkNullV | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.NullChecksThrow |
| 139 | CALLINTF | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CastStoreLoadAndCallIntf |
| 140 | iTOb | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 141 | iTOw | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 142 | SetV1 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 143 | SetV2 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 144 | Cast | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.CastStoreLoadAndCallIntf |
| 145 | i64TOi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 146 | uTOi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 147 | iTOi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.IntegerConversions |
| 148 | fTOi64 | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 149 | dTOi64 | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 150 | fTOu64 | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 151 | dTOu64 | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 152 | i64TOf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 153 | u64TOf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 154 | i64TOd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 155 | u64TOd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.WideFloatConversions |
| 156 | NEGi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 157 | INCi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 158 | DECi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.NegIncDec |
| 159 | BNOT64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 160 | ADDi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer64Arithmetic |
| 161 | SUBi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer64Arithmetic |
| 162 | MULi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer64Arithmetic |
| 163 | DIVi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer64Arithmetic |
| 164 | MODi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Integer64Arithmetic |
| 165 | BAND64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 166 | BOR64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 167 | BXOR64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 168 | BSLL64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 169 | BSRL64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 170 | BSRA64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.Bitwise64 |
| 171 | CMPi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 172 | CMPu64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ComparisonsAndTestFlags |
| 173 | ChkNullS | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.NullChecksThrow |
| 174 | ClrHi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 175 | JitEntry | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObserversMarkersSuspendAndThrow |
| 176 | CallPtr | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.FuncPtrCallPtrAndNull |
| 177 | FuncPtr | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.FuncPtrCallPtrAndNull |
| 178 | LoadThisR | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.LoadThisRReadsReceiverFieldSeventeenAndNullThrows |
| 179 | PshV8 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 180 | DIVu | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.UnsignedDivMod |
| 181 | MODu | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.UnsignedDivMod |
| 182 | DIVu64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.UnsignedDivMod |
| 183 | MODu64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.UnsignedDivMod |
| 184 | LoadRObjR | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 185 | LoadVObjR | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 186 | RefCpyV | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 187 | JLowZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 188 | JLowNZ | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken |
| 189 | AllocMem | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 190 | SetListSize | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 191 | PshListElmnt | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 192 | SetListType | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 193 | POWi | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.PowerIntegerAndOverflow |
| 194 | POWu | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.PowerIntegerAndOverflow |
| 195 | POWf | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.PowerFloatAndDomain |
| 196 | POWd | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.PowerFloatAndDomain |
| 197 | POWdi | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix.PowerFloatAndDomain |
| 198 | POWi64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.PowerIntegerAndOverflow |
| 199 | POWu64 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.PowerIntegerAndOverflow |
| 200 | Thiscall1 | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.Thiscall1AddsSevenToReceiver |
| 201 | FinConstruct | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 202 | DestructScript | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 203 | CopyScript | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef |
| 204 | ResolveObjectPtr | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 205 | FreeNullV8 | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 206 | TrackRef | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 207 | UntrackRef | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 208 | ValidateRef | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 209 | CpyVtoR1 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix.ConstantMovesAndWidths |
| 210 | SaveReturnValue | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObserversMarkersSuspendAndThrow |
| 211 | CmpPtrNull | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks |
| 212 | ThrowException | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.ObserversMarkersSuspendAndThrow |
| 213..250 | Reserved | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 251 | VarDecl | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 252 | Block | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 253 | ObjInfo | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 254 | LINE | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |
| 255 | LABEL | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix.RetiredAndReservedReject |

