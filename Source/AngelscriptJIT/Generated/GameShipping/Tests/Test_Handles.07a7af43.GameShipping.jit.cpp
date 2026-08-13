// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_Handles.as
 * CanonicalModuleName : Tests.Test_Handles
 * TargetProfile       : GameShipping
 * StableModuleKey     : 07a7af43d0abfe46c97bf81499c0c86fe0d7d07d42e7283fc3612829ca0b07c1
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
 * Declaration       : int HandlesFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_Handles.as:1:1
 * StableFunctionKey  : beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066
 * ExecutionHash      : dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866
 * DebugHash          : a77b8b859d705675548e6e9da0df7d740daa22a97e3ce62210a4719125e8140e
 * EntryAbiHash       : d6864a82fb6beb24c274bdafeb6b19a0ddac190f3a59c4686115cdebd47090f0
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866 = "Tests.Test_Handles";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866
#endif

// AS Function : int HandlesFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Handles.as:1:1
// JIT Entry   : Raw
int32 ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866(FScriptExecution& Execution)
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
// JitEntry *
// SetV4 v1, 9
v_Value = 0x9u;
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
void ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866(Execution);
}
// AS Function : int HandlesFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Handles.as:1:1
// JIT Entry   : Parms
void ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_beb370979382d9574b5996c6d8b34141260f267800c1ada8e7013b667b4a6066_dcd05aaa4e95df3f804e18200c35f05b31337d4b316d00f4e33f108cff13c866(Execution);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
