// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_GameplayTags.as
 * CanonicalModuleName : Tests.Test_GameplayTags
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 349ffd2e6836e03e6c2aa6965c6577612ee202c79fb2bb944880d36228b9f3a8
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
 * Declaration       : int GameplayTagsFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_GameplayTags.as:1:1
 * StableFunctionKey  : e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd
 * ExecutionHash      : 28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522
 * DebugHash          : f82d573d8e058d232546f1e31c25d1a32ff9dc9a2a54d45e3be6950618a3631b
 * EntryAbiHash       : db791d9427e1a00928e676f0d1e75821db8c52dc8d6619dff0c48e5a0abd7705
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522 = "Tests.Test_GameplayTags";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522
#endif

// AS Function : int GameplayTagsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_GameplayTags.as:1:1
// JIT Entry   : Raw
int32 ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int GameplayTagsFixtureValue()", 3);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
asDWORD v_TEMP_dword_1 = {};
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v1, 1
v_TEMP_dword_1 = 0x1u;
// CpyVtoR4 v1
l_dwordRegister = v_TEMP_dword_1;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int GameplayTagsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_GameplayTags.as:1:1
// JIT Entry   : VM
void ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522(Execution);
}
// AS Function : int GameplayTagsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_GameplayTags.as:1:1
// JIT Entry   : Parms
void ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_e287d06910fa1a23ac426f4f1292d0dafa2d7bcd7e51ce0106d72c0d4a3cbfbd_28720e2df78b2017054e7e1530800b606d03f4fa1bf59ac305ce28093336a522(Execution);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
