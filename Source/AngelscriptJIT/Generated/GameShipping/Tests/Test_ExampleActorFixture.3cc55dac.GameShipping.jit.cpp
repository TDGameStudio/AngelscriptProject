// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as
 * CanonicalModuleName : Tests.Test_ExampleActorFixture
 * TargetProfile       : GameShipping
 * StableModuleKey     : 3cc55dac535fff7251c45430b2ee1fbba18cd2a924553eb3329f85e8c9b6864f
 * ProviderId          : a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5
 * ArtifactProfile     : 5dc64764efed88608c4266d9449cbdb105571ca28fafba2603c771dc4f50e9aa
 * NativeEnvironment   : cf0f93f6716a0e67b6ba26d9ec2243de153175c1fbc951b949dd7f9b4b8bbc54
 * FunctionCount       : 3
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
 * ExecutionHash      : 2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8
 * DebugHash          : 1579abff946df92517a0eaa9250e9b7fe437c5aee88653c778baa836b1a2806e
 * EntryAbiHash       : 284ee8225c1528677f9aa60ccae2e863dddbeb2568b32c96a11f301e5a07d0ef
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8 = "Tests.Test_ExampleActorFixture";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8
#endif

// AS Function : int ExampleActorFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
// JIT Entry   : Raw
int32 ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8(FScriptExecution& Execution)
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
// JitEntry *
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
void ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8(Execution);
}
// AS Function : int ExampleActorFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:6:1
// JIT Entry   : Parms
void ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_bfc99b6e3c39b342cacec317e04fa4365cc67a7c3ba30f1471b28bcc49fb8a72_2940bb3c245ea8b01443327ab465d8b6a492a3afc417a9f9ebd9337e543fade8(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2ExampleActorFixture()
 * Source             : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
 * StableFunctionKey  : f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4
 * ExecutionHash      : 34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118
 * DebugHash          : ebb330b5dbbe9883014abc4aaa6d080b4a55b081be9082fd3f016b5cb234f382
 * EntryAbiHash       : 740a8cc143fe9d3508c66748bd043504677756c6fa602b7311c5101c9d838cb6
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118 = "Tests.Test_ExampleActorFixture";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118
#endif

// AS Function : FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Raw
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118(FScriptExecution& Execution, UObject* l_This)
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
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118(Execution,
		*(UObject**)l_fp);
}
// AS Function : FPhase2ExampleActorFixture()
// AS Source   : /Angelscript/Game/Tests/Test_ExampleActorFixture.as:1:0
// JIT Entry   : Parms
void ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_f23a1003283e86d8b62122f5bd873f13f840af678fc6becccf89b97d2ee9b4c4_34bd823bbf1c30f77a9246b22f8726f690db52d267aa2001005f1a5dda9c8118(Execution,
		(UObject*)Object);
}
#endif
#endif // !WITH_EDITOR && UE_BUILD_SHIPPING
