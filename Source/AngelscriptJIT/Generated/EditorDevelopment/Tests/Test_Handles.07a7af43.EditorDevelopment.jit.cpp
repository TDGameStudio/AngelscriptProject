// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_Handles.as
 * CanonicalModuleName : Tests.Test_Handles
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 07a7af43d0abfe46c97bf81499c0c86fe0d7d07d42e7283fc3612829ca0b07c1
 * ProviderId          : d68adf88aff3b35bb80e41f44e00648d55f4fce2b35f700ae9b4bfdc65f87969
 * ArtifactProfile     : fc019b75324eb9505dfa8aeaadc5dbbceb8d476837af625df9dfcb6a7d62ef7e
 * NativeEnvironment   : 76d620ec7d0db38aa2028996e595f75523f201e7e560c05d8c9000d60d04cd73
 * FunctionCount       : 1
 */

#if WITH_EDITOR && UE_BUILD_DEVELOPMENT
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
 * Declaration       : int HandlesFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_Handles.as:1:1
 * StableFunctionKey  : beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066
 * ExecutionHash      : 96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283
 * DebugHash          : 8d9c6ec003cd06e5e1d045f0718f76e6b7d6864c5f98fc71e20353ce99ab7295
 * EntryAbiHash       : 281adb83be2827d957dfa7aa7828b0dce06bdfc671eb8c88c8f3f082e084fcd9
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283 = "Tests.Test_Handles";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283
#endif

// AS Function : int HandlesFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Handles.as:1:1
// JIT Entry   : Raw
int32 ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int HandlesFixtureValue()", 3);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
asDWORD v_Value = {};
asDWORD v_TEMP_dword_2 = {};
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v1, 9
v_Value = 0x9u;
// SUSPEND
// JitEntry *
// SetV4 v2, 9
v_TEMP_dword_2 = 0x9u;
// CpyVtoR4 v2
l_dwordRegister = v_TEMP_dword_2;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int HandlesFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Handles.as:1:1
// JIT Entry   : VM
void ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283(Execution);
}
// AS Function : int HandlesFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Handles.as:1:1
// JIT Entry   : Parms
void ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_96dd557d08d1b88608900683384ee1a7f8552c1a5198ce951274da0d4a355283(Execution);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
