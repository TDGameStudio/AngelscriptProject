// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_ActorLifecycle.as
 * CanonicalModuleName : Tests.Test_ActorLifecycle
 * TargetProfile       : GameShipping
 * StableModuleKey     : 7c60060e0047a87caee5c0fefdc5e76787a9a11051104d045290be587e7a9654
 * ProviderId          : a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5
 * ArtifactProfile     : 5dc64764efed88608c4266d9449cbdb105571ca28fafba2603c771dc4f50e9aa
 * NativeEnvironment   : cf0f93f6716a0e67b6ba26d9ec2243de153175c1fbc951b949dd7f9b4b8bbc54
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
 * Declaration       : FPhase2ActorLifecycleProbe()
 * Source             : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
 * StableFunctionKey  : 3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5
 * ExecutionHash      : ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d
 * DebugHash          : a3e63655e86b552d471e7c5d39e67607d09bc3c2d8329242e14ac66d7fe3006f
 * EntryAbiHash       : df1ef0a4260e999971ecb79ee5b0209ffdb3c9d2ca66407b2b38b3c4b0967369
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d = "Tests.Test_ActorLifecycle";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d
#endif

// AS Function : FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : Raw
void ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("FPhase2ActorLifecycleProbe::FPhase2ActorLifecycleProbe()", 0);
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
// AS Function : FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : VM
void ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d(Execution,
		*(UObject**)l_fp);
}
// AS Function : FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : Parms
void ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5_ca6fabd7775c6c63dddc8ffa38672c08f96e6d4b9937dab80a7395fae9be382d(Execution,
		(UObject*)Object);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2ActorLifecycleProbe FPhase2ActorLifecycleProbe()
 * Source             : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
 * StableFunctionKey  : 36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52
 * ExecutionHash      : bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36
 * DebugHash          : a3e63655e86b552d471e7c5d39e67607d09bc3c2d8329242e14ac66d7fe3006f
 * EntryAbiHash       : d726bec9239ca01301ee679577127b5ec7d2972225504c1123cb5e1c61079ef9
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36 = "Tests.Test_ActorLifecycle";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36
#endif

// AS Function : FPhase2ActorLifecycleProbe FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : Raw
UObject* ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("FPhase2ActorLifecycleProbe FPhase2ActorLifecycleProbe()", 0);
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
// FPhase2ActorLifecycleProbe::FPhase2ActorLifecycleProbe()
SCRIPT_DEBUG_CALLSTACK_LINE(0);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("3665c6f0bd909f8c636a04b1227641f4c3dbf6337673b21655ccd4d0bbcab1a5")))}}}}, CallFunction, (void*)(((asQWORD&)l_stack[0])), true);
  CallFunction = CurrentFunctionCall.Get();
  if (CallFunction == nullptr) [[unlikely]]
  {
     SCRIPT_UNBOUND_EXCEPTION();
return {};
  }
  FAngelscriptContext CallContext(CallFunction->GetEngine());
  CallContext->Prepare(CallFunction);
  CallContext->SetObject((void*)((asQWORD&)l_stack[0]));
  CallContext->Execute();
  if (Execution.bExceptionThrown || CallContext->m_status != asEXECUTION_FINISHED)
  {
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
// AS Function : FPhase2ActorLifecycleProbe FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : VM
void ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(UObject**)l_outValue = ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36(Execution);
}
// AS Function : FPhase2ActorLifecycleProbe FPhase2ActorLifecycleProbe()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:1:0
// JIT Entry   : Parms
void ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(UObject**)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_36cd16feb9e2616fdff166c0af9585e486ed881286b7eeb93c2042c72430cf52_bcd390541d140543482f776efac83cf772dec10cc22732d78df474371a8deb36(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : int ActorLifecycleFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_ActorLifecycle.as:9:1
 * StableFunctionKey  : b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9
 * ExecutionHash      : 407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41
 * DebugHash          : d614f4bcb72a2a9f1fd5f1197c419cf2ab2c7c086f4762c7741e192fe3813f12
 * EntryAbiHash       : d780d090ee77199f30b983082bb625cd3f4c0d372b8042530fa3f2d35e773a8f
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41 = "Tests.Test_ActorLifecycle";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41
#endif

// AS Function : int ActorLifecycleFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:9:1
// JIT Entry   : Raw
int32 ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int ActorLifecycleFixtureValue()", 11);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[8];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
UObject* v_Probe = nullptr;
asDWORD v_TEMP_dword_3 = {};
// JitEntry *
// JitEntry *
// JitEntry *
// PshVPtr v2
// CALLINTF
// int FPhase2ActorLifecycleProbe::Step()
SCRIPT_DEBUG_CALLSTACK_LINE(12);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525")))}}}}, CallFunction, (void*)((v_Probe)), true);
  CallFunction = CurrentFunctionCall.Get();
  if (CallFunction == nullptr) [[unlikely]]
  {
     SCRIPT_UNBOUND_EXCEPTION();
return {};
  }
  FAngelscriptContext CallContext(CallFunction->GetEngine());
  CallContext->Prepare(CallFunction);
  CallContext->SetObject((void*)(v_Probe));
  CallContext->Execute();
  if (Execution.bExceptionThrown || CallContext->m_status != asEXECUTION_FINISHED)
  {
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
  void* obj = (void*)v_Probe;
  if (obj != nullptr)
  {
    asCObjectType* objType = (asCObjectType*)FAngelscriptJITGeneratedReferenceAccess::GetTypeInfo(Execution, 0u);
    if ((objType->flags & asOBJ_NOCOUNT) == 0 && objType->beh.release != 0)
      SCRIPT_ENGINE->CallObjectMethod(obj, objType->beh.release);
  }
}
v_Probe = nullptr;
// CpyVtoR4 v3
l_dwordRegister = v_TEMP_dword_3;
// RET 0
  return (int32)l_dwordRegister;
}
// AS Function : int ActorLifecycleFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:9:1
// JIT Entry   : VM
void ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41(Execution);
}
// AS Function : int ActorLifecycleFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:9:1
// JIT Entry   : Parms
void ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_b93ccfb0585b8376f81e1af50ca1675710cd728589b9304d894892a017e2b0d9_407489dd94e408291cf18e1af30b108152a0e667dbaa43865d56fc69c6402a41(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : int Step()
 * Source             : /Angelscript/Game/Tests/Test_ActorLifecycle.as:3:2
 * StableFunctionKey  : c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525
 * ExecutionHash      : d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8
 * DebugHash          : 1c5aa58d216244b96891b7617a6b9630469c610c789ce5e7f0b4a9f83df1e4bf
 * EntryAbiHash       : a49c93dd3af0ebc4e6443d38f1573603219e705896285dac9f7df16663fb3bfd
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8 = "Tests.Test_ActorLifecycle";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8
#endif

// AS Function : int Step()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:3:2
// JIT Entry   : Raw
int32 ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("int FPhase2ActorLifecycleProbe::Step()", 5);
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
// SetV4 v1, 21
v_TEMP_dword_1 = 0x15u;
// CpyVtoR4 v1
l_dwordRegister = v_TEMP_dword_1;
// RET 2
  return (int32)l_dwordRegister;
}
// AS Function : int Step()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:3:2
// JIT Entry   : VM
void ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8(Execution,
		*(UObject**)l_fp);
}
// AS Function : int Step()
// AS Source   : /Angelscript/Game/Tests/Test_ActorLifecycle.as:3:2
// JIT Entry   : Parms
void ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_c799c0e4d6d9cb1a15fc22f64a878ccaf1c540364b80642e15b54025d5602525_d701668260611469705557c62607db2a7d86093871db4d161e0ba74c23274dd8(Execution,
		(UObject*)Object);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
