// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_SystemUtils.as
 * CanonicalModuleName : Tests.Test_SystemUtils
 * TargetProfile       : GameShipping
 * StableModuleKey     : 26e1442a2b3061a6991aca97425443063f5df46f86eed2ec869f0b8560b7bd7b
 * ProviderId          : d68adf88aff3b35bb80e41f44e00648d55f4fce2b35f700ae9b4bfdc65f87969
 * ArtifactProfile     : 5dc64764efed88608c4266d9449cbdb105571ca28fafba2603c771dc4f50e9aa
 * NativeEnvironment   : a8e1b284849067b4b68e7af94e6d337cd071c3644a8b33d155878b808dea6f2a
 * FunctionCount       : 4
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
 * Declaration       : FPhase2SystemUtilsFixture FPhase2SystemUtilsFixture()
 * Source             : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
 * StableFunctionKey  : 220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2
 * ExecutionHash      : 6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2
 * DebugHash          : 556b13ff6a1abc4c49f5c655995bf25c7942f5f5a8cf71100740c13adc45e1a4
 * EntryAbiHash       : b3e4cf87d21dec1a4a04e3d77cea49f1fa4c9f7d86c1f75d29aef3a5fbef9e26
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2 = "Tests.Test_SystemUtils";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2
#endif

// AS Function : FPhase2SystemUtilsFixture FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : Raw
UObject* ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("FPhase2SystemUtilsFixture FPhase2SystemUtilsFixture()", 0);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[16];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
UObject* v_TEMP_ptr_2 = nullptr;
// JitEntry *
// PSF v2
// ALLOC
{
  asCObjectType* objType = (asCObjectType*)FAngelscriptJITGeneratedReferenceAccess::GetTypeInfo(Execution, 0u);
  asDWORD* mem = (asDWORD*)SCRIPT_ENGINE->AllocScriptObject(objType);
  ScriptObject_Construct(objType, (asCScriptObject*)mem);
  asPWORD* a = (asPWORD*)((&v_TEMP_ptr_2));
  if(a != nullptr) *a = (asPWORD)mem;
value_assign_safe<asQWORD>(&l_stack[0], mem);
// FPhase2SystemUtilsFixture::FPhase2SystemUtilsFixture()
SCRIPT_DEBUG_CALLSTACK_POSITION(0, 0);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c")))}}}}, CallFunction, (void*)(((asQWORD&)l_stack[0])), true);
  CallFunction = CurrentFunctionCall.Get();
  if (CallFunction == nullptr) [[unlikely]]
  {
     SCRIPT_UNBOUND_EXCEPTION();
return {};
  }
  FAngelscriptContext CallContext(CallFunction->GetEngine());
  CallContext->Prepare(CallFunction);
  CallContext->SetObject((void*)((asQWORD&)l_stack[0]));
  {
     FScopeStaticJITNestedExceptionAdoption ExceptionAdoption(*CallContext);
     CallContext->Execute();
  }
  if (Execution.bExceptionThrown || CallContext->m_status != asEXECUTION_FINISHED)
  {
     FStaticJITFunction::AdoptContextException(Execution, *CallContext);
     Execution.bExceptionThrown = true;
return {};
  }
}
}
// JitEntry *
// LOADOBJ v2
l_objectRegister = (void*)v_TEMP_ptr_2;
v_TEMP_ptr_2 = nullptr;
// RET 0
  return (UObject*)l_objectRegister;
}
// AS Function : FPhase2SystemUtilsFixture FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : VM
void ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(UObject**)l_outValue = ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2(Execution);
}
// AS Function : FPhase2SystemUtilsFixture FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : Parms
void ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(UObject**)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_220bbfb94814bb7323283df8fd59557dcff5fcb136737bc8d475856abd3b29f2_6990be897d2fefa5e54ebf57f429d704b26b19fff6ce4942613d67d84208dda2(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : int SystemUtilsFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_SystemUtils.as:9:1
 * StableFunctionKey  : 25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982
 * ExecutionHash      : 0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487
 * DebugHash          : d3f44d9a84ad166337fced429827893e98e85c8b225ff04edfeed842117c9c91
 * EntryAbiHash       : c6f57806578793b4cbc185bcfec86676b31a44de2b69ed24dccfa24921dabc82
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487 = "Tests.Test_SystemUtils";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487
#endif

// AS Function : int SystemUtilsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:9:1
// JIT Entry   : Raw
int32 ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int SystemUtilsFixtureValue()", 11);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[8];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
UObject* v_Fixture = nullptr;
asDWORD v_TEMP_dword_3 = {};
// JitEntry *
// JitEntry *
// JitEntry *
// PshVPtr v2
// CALLINTF
// int FPhase2SystemUtilsFixture::Read()
SCRIPT_DEBUG_CALLSTACK_POSITION(12, 2);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004")))}}}}, CallFunction, (void*)((v_Fixture)), true);
  CallFunction = CurrentFunctionCall.Get();
  if (CallFunction == nullptr) [[unlikely]]
  {
     SCRIPT_UNBOUND_EXCEPTION();
return {};
  }
  FAngelscriptContext CallContext(CallFunction->GetEngine());
  CallContext->Prepare(CallFunction);
  CallContext->SetObject((void*)(v_Fixture));
  {
     FScopeStaticJITNestedExceptionAdoption ExceptionAdoption(*CallContext);
     CallContext->Execute();
  }
  if (Execution.bExceptionThrown || CallContext->m_status != asEXECUTION_FINISHED)
  {
     FStaticJITFunction::AdoptContextException(Execution, *CallContext);
     Execution.bExceptionThrown = true;
return {};
  }
  l_valueRegister = CallContext->m_regs.valueRegister;
}
// JitEntry *
// CpyRtoV4 v3
memcpy((&v_TEMP_dword_3), &l_valueRegister, 4);
// FREE v2, *
{
  void* obj = (void*)v_Fixture;
  if (obj != nullptr)
  {
    asCObjectType* objType = (asCObjectType*)FAngelscriptJITGeneratedReferenceAccess::GetTypeInfo(Execution, 0u);
    if ((objType->flags & asOBJ_NOCOUNT) == 0 && objType->beh.release != 0)
      SCRIPT_ENGINE->CallObjectMethod(obj, objType->beh.release);
  }
}
v_Fixture = nullptr;
// CpyVtoR4 v3
l_dwordRegister = v_TEMP_dword_3;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int SystemUtilsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:9:1
// JIT Entry   : VM
void ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487(Execution);
}
// AS Function : int SystemUtilsFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:9:1
// JIT Entry   : Parms
void ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_25b272c29c722c1b0aa85cb11797c57e405cb305c66120bb49becadbe0b12982_0bf1192af8a1ce5d9dad4aaaf61519d5adb3168e974894dd4bc9d48e3a04c487(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : int Read()
 * Source             : /Angelscript/Game/Tests/Test_SystemUtils.as:3:2
 * StableFunctionKey  : 80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004
 * ExecutionHash      : 440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb
 * DebugHash          : c643b329e8d445cd5380dc0580f15abd816567d76dba8a991f028d2fb5fda117
 * EntryAbiHash       : 7a751028eed26ce1a10a4d8d0cd270b486bec83fde1e19a176cf47ae8eca07b3
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb = "Tests.Test_SystemUtils";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb
#endif

// AS Function : int Read()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:3:2
// JIT Entry   : Raw
int32 ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("int FPhase2SystemUtilsFixture::Read()", 5);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
asDWORD v_TEMP_dword_1 = {};
// JitEntry *
// JitEntry *
// SetV4 v1, 13
v_TEMP_dword_1 = 0xdu;
// CpyVtoR4 v1
l_dwordRegister = v_TEMP_dword_1;
// RET 2
  return (int32)l_dwordRegister;
}
// AS Function : int Read()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:3:2
// JIT Entry   : VM
void ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb(Execution,
		*(UObject**)l_fp);
}
// AS Function : int Read()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:3:2
// JIT Entry   : Parms
void ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_80dc85c6729024bc7fe6b5f26ba41cd266a0f87211d9b10dac36fcd54c5bf004_440f19ec9f5314e99b4fd6ffe36599142ada9985b28c3a7f2cd46fbafd88fcdb(Execution,
		(UObject*)Object);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2SystemUtilsFixture()
 * Source             : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
 * StableFunctionKey  : a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c
 * ExecutionHash      : b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57
 * DebugHash          : 556b13ff6a1abc4c49f5c655995bf25c7942f5f5a8cf71100740c13adc45e1a4
 * EntryAbiHash       : 5a3325e53655a6b08c4fdb23a198d75997dd96990fa8090fe9ea188f17f77c50
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57 = "Tests.Test_SystemUtils";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57
#endif

// AS Function : FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : Raw
void ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("FPhase2SystemUtilsFixture::FPhase2SystemUtilsFixture()", 0);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[8];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
// JitEntry *
// PshVPtr v0
// FinConstruct *
{
  asIScriptObject* Object = (asIScriptObject*)(l_This);
  asITypeInfo* TypeInfo = (asITypeInfo*)FAngelscriptJITGeneratedReferenceAccess::GetTypeInfo(Execution, 0u);
  SCRIPT_FINISH_CONSTRUCT(Object, TypeInfo);
}
// RET 2
  return;
}
// AS Function : FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : VM
void ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57(Execution,
		*(UObject**)l_fp);
}
// AS Function : FPhase2SystemUtilsFixture()
// AS Source   : /Angelscript/Game/Tests/Test_SystemUtils.as:1:0
// JIT Entry   : Parms
void ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_a4cc5a5fe75bf1dd97db6680c5115f1fdb7c3c59332c1a3688bc99ba868b827c_b7ffab0bb94b0a92fcc5783714a0504de32e9354cc1d80c53f41f4b708a56a57(Execution,
		(UObject*)Object);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
