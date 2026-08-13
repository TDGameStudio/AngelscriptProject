// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as
 * CanonicalModuleName : Tests.Test_ExampleActorFixture
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 3cc55dac535fff7251c45430b2ee1fbba18cd2a924553eb3329f85e8c9b6864f
 * ProviderId          : a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5
 * ArtifactProfile     : fc019b75324eb9505dfa8aeaadc5dbbceb8d476837af625df9dfcb6a7d62ef7e
 * NativeEnvironment   : c8d9638e7c34100b327617ea9a4769bd7692413e17eb4705818e6b120acc9651
 * FunctionCount       : 3
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
 * Declaration       : FPhase2ExampleActorFixture FPhase2ExampleActorFixture()
 * Source             : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
 * StableFunctionKey  : 6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1
 * ExecutionHash      : 3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211
 * DebugHash          : 7512fb65fd676a622c19923217b5f7c79c7db707ef9bcfe8e4d221af5af66acd
 * EntryAbiHash       : 151729d758bdf52160f5130a578eef6f062a29f69a62bca7f82867212e227793
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211 = "Tests.Test_ExampleActorFixture";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211
#endif

// AS Function : FPhase2ExampleActorFixture FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Raw
UObject* ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("FPhase2ExampleActorFixture FPhase2ExampleActorFixture()", 0);
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
// FPhase2ExampleActorFixture::FPhase2ExampleActorFixture()
SCRIPT_DEBUG_CALLSTACK_LINE(0);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4")))}}}}, CallFunction, (void*)(((asQWORD&)l_stack[0])), true);
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
// AS Function : FPhase2ExampleActorFixture FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : VM
void ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(UObject**)l_outValue = ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211(Execution);
}
// AS Function : FPhase2ExampleActorFixture FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Parms
void ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(UObject**)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_6d9c4dc6976d06a988fd7b2bf7fe7ed78e19583d12cab2e7fde6ecdfc2d604a1_3e4db0c934e102096056116906ac515231a22dccda3306066a14f026a9878211(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : int ExampleActorFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
 * StableFunctionKey  : bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72
 * ExecutionHash      : 076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d
 * DebugHash          : 1da8c6941a1aec307e9e6d2b6394a4997a4a8e64056f817afbda3253a3a3c7db
 * EntryAbiHash       : 284ee8225c1528677f9aa60ccae2e863dddbeb2568b32c96a11f301e5a07d0ef
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d = "Tests.Test_ExampleActorFixture";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d
#endif

// AS Function : int ExampleActorFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
// JIT Entry   : Raw
int32 ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int ExampleActorFixtureValue()", 8);
SCRIPT_ASSUME_NO_EXCEPTION()
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
UObject* v_Fixture = nullptr;
asDWORD v_TEMP_dword_3 = {};
// JitEntry *
// SUSPEND
// JitEntry *
// SUSPEND
// JitEntry *
// LoadRObjR
if (v_Fixture == nullptr) [[unlikely]]
{
SCRIPT_DEBUG_CALLSTACK_LINE(9);
SCRIPT_NULL_POINTER_EXCEPTION();
return {};
}
l_valueRegister = (asQWORD)(v_Fixture) + POFFSET_FPhase2ExampleActorFixture_Value;
// RDR4 v3
v_TEMP_dword_3 = value_read<asDWORD>((void*)l_valueRegister);
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
// AS Function : int ExampleActorFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
// JIT Entry   : VM
void ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d(Execution);
}
// AS Function : int ExampleActorFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
// JIT Entry   : Parms
void ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_076ddfc2027776badd266e31fe581ec6fd6ef639ea9f3dba90ebe3195363494d(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2ExampleActorFixture()
 * Source             : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
 * StableFunctionKey  : f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4
 * ExecutionHash      : 1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52
 * DebugHash          : ebb330b5dbbe9883014abc4aaa6d080b4a55b081be9082fd3f016b5cb234f382
 * EntryAbiHash       : 740a8cc143fe9d3508c66748bd043504677756c6fa602b7311c5101c9d838cb6
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52 = "Tests.Test_ExampleActorFixture";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52
#endif

// AS Function : FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Raw
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("FPhase2ExampleActorFixture::FPhase2ExampleActorFixture()", 3);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[8];
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
// SetV4 v1, 42
v_TEMP_dword_1 = 0x2au;
// LoadThisR +48
l_valueRegister = ((asQWORD)l_This) + POFFSET_FPhase2ExampleActorFixture_Value;
// WRTV4 v1
memcpy((void*)l_valueRegister, (void*)(&v_TEMP_dword_1), 4);
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
// AS Function : FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : VM
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52(Execution,
		*(UObject**)l_fp);
}
// AS Function : FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Parms
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_1884bbd45047bf49c00448b19b3ae2c8df041443245009949ef18178f1de9c52(Execution,
		(UObject*)Object);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
