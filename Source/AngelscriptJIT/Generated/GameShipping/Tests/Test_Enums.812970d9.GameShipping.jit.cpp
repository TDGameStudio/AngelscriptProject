// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_Enums.as
 * CanonicalModuleName : Tests.Test_Enums
 * TargetProfile       : GameShipping
 * StableModuleKey     : 812970d941c3edf2c6076c1ea72b7ad592c8cd79bb1a9307c13677adb73b7441
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
 * Declaration       : int EnumsFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_Enums.as:1:1
 * StableFunctionKey  : b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093
 * ExecutionHash      : df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402
 * DebugHash          : de8d49e053db74bfebf9dd86c22ed52b3db2d1ad9c7df6ab519425473185f496
 * EntryAbiHash       : 6895e66d7665da189c1e497f564679d7b6c721b022f196db86eed892a88ebc48
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402 = "Tests.Test_Enums";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402
#endif

// AS Function : int EnumsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Enums.as:1:1
// JIT Entry   : Raw
int32 ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int EnumsFixtureValue()", 3);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
asDWORD v_One = {};
asDWORD v_TEMP_dword_2 = {};
// JitEntry *
// JitEntry *
// SetV4 v1, 1
v_One = 0x1u;
// JitEntry *
// SetV4 v2, 1
v_TEMP_dword_2 = 0x1u;
// CpyVtoR4 v2
l_dwordRegister = v_TEMP_dword_2;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int EnumsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Enums.as:1:1
// JIT Entry   : VM
void ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402(Execution);
}
// AS Function : int EnumsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_Enums.as:1:1
// JIT Entry   : Parms
void ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_b9a54f666b9cb90dcbdbdc03855718f9fe18162d358e36f485c2a29c89748093_df6aa93718f17fe0530a220a6169edd7406dcfedc2f8728472ed46fb29797402(Execution);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
