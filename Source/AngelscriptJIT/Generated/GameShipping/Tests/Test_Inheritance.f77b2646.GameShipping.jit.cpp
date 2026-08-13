// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_Inheritance.as
 * CanonicalModuleName : Tests.Test_Inheritance
 * TargetProfile       : GameShipping
 * StableModuleKey     : f77b2646df95206b9e3c0a6dff95d867c285aae42b2da94e7b6ffee579c5e70c
 * ProviderId          : a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5
 * ArtifactProfile     : 5dc64764efed88608c4266d9449cbdb105571ca28fafba2603c771dc4f50e9aa
 * NativeEnvironment   : cf0f93f6716a0e67b6ba26d9ec2243de153175c1fbc951b949dd7f9b4b8bbc54
 * FunctionCount       : 1
 */

#if !WITH_EDITOR && UE_BUILD_SHIPPING
#include "StaticJIT/StaticJITConfig.h"
#ifndef AS_SKIP_JITTED_CODE


#include "StaticJIT/StaticJITHeader.h"


constexpr SIZE_T POFFSET_FPhase2ExampleActorFixture_Value = Align(sizeof(UObject) + 0, 4);
constexpr SIZE_T PALIGN_FPhase2ExampleActorFixture_Value = AlignmentMax(alignof(UObject), 4);
constexpr SIZE_T TALIGN_FPhase2ExampleActorFixture = PALIGN_FPhase2ExampleActorFixture_Value;
constexpr SIZE_T TSIZE_FPhase2ExampleActorFixture = Align(POFFSET_FPhase2ExampleActorFixture_Value + 4, TALIGN_FPhase2ExampleActorFixture);
constexpr SIZE_T POFFSET_FPhase2MathFixture_Value = Align(sizeof(UObject) + 0, 4);
constexpr SIZE_T PALIGN_FPhase2MathFixture_Value = AlignmentMax(alignof(UObject), 4);
constexpr SIZE_T TALIGN_FPhase2MathFixture = PALIGN_FPhase2MathFixture_Value;
constexpr SIZE_T TSIZE_FPhase2MathFixture = Align(POFFSET_FPhase2MathFixture_Value + 4, TALIGN_FPhase2MathFixture);
/*
 * AngelScript Static JIT Function
 * Declaration       : int InheritanceFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_Inheritance.as:1:1
 * StableFunctionKey  : 1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925
 * ExecutionHash      : 5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db
 * DebugHash          : d7e7aa3652a75ab6691f6db06aa1626e8fa9d07ccf0d69e63531988abe2ea90e
 * EntryAbiHash       : 11fa7e2d5fb132da7c3909fdbecb45d8f91001881304657258e395d881ece21f
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db = "Tests.Test_Inheritance";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db
#endif

// AS Function : int InheritanceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Inheritance.as:1:1
// JIT Entry   : Raw
int32 ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int InheritanceFixtureValue()", 3);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
asDWORD v_BaseValue = {};
asDWORD v_DerivedValue = {};
asDWORD v_TEMP_dword_2 = {};
// JitEntry *
// JitEntry *
// SetV4 v1, 3
v_BaseValue = 0x3u;
// JitEntry *
// SetV4 v3, 7
v_DerivedValue = 0x7u;
// JitEntry *
// SetV4 v2, 7
v_TEMP_dword_2 = 0x7u;
// CpyVtoR4 v2
l_dwordRegister = v_TEMP_dword_2;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int InheritanceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Inheritance.as:1:1
// JIT Entry   : VM
void ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db(Execution);
}
// AS Function : int InheritanceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Inheritance.as:1:1
// JIT Entry   : Parms
void ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_1accffceeaece6046fe2a22dd19c25cdb1849fd02d1b8367cf98d16d285de925_5baa707427dfe0d573be1038edbc3a767d8fbd93a26a3218186e1f9b704427db(Execution);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
