// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Tests/Test_MathNamespace.as
 * CanonicalModuleName : Tests.Test_MathNamespace
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 7a4e7104487826a501ef08fa7ba1704bf15f17eb5a69431c669465c0200c5927
 * ProviderId          : d68adf88aff3b35bb80e41f44e00648d55f4fce2b35f700ae9b4bfdc65f87969
 * ArtifactProfile     : fc019b75324eb9505dfa8aeaadc5dbbceb8d476837af625df9dfcb6a7d62ef7e
 * NativeEnvironment   : 76d620ec7d0db38aa2028996e595f75523f201e7e560c05d8c9000d60d04cd73
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
 * Declaration       : int MathNamespaceFixtureValue()
 * Source             : /Angelscript/Game/Tests/Test_MathNamespace.as:6:1
 * StableFunctionKey  : 1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2
 * ExecutionHash      : 9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0
 * DebugHash          : b6640c74fdee25f391085f41d44964fccbd43da0e80d1ceb2d47ab8ad6f51c0d
 * EntryAbiHash       : 9ca04842a8d481866d43a7c491871fb6480e9a848b2f072572f2ecc689a5523f
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0 = "Tests.Test_MathNamespace";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0
#endif

// AS Function : int MathNamespaceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:6:1
// JIT Entry   : Raw
int32 ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("int MathNamespaceFixtureValue()", 8);
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
SCRIPT_DEBUG_CALLSTACK_POSITION(9, 2);
SCRIPT_NULL_POINTER_EXCEPTION();
return {};
}
l_valueRegister = (asQWORD)(v_Fixture) + POFFSET_FPhase2MathFixture_Value;
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
// AS Function : int MathNamespaceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:6:1
// JIT Entry   : VM
void ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(int32*)l_outValue = ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0(Execution);
}
// AS Function : int MathNamespaceFixtureValue()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:6:1
// JIT Entry   : Parms
void ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(int32*)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_1d4d6c1b5a90c438755d3e96844d6c15c88bafe6f88fe2970bc71325447a31d2_9062e1b521991abb69b05ac66baf6cb904c9dd5c25b84ece48c9d7a1499e2aa0(Execution);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2MathFixture()
 * Source             : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
 * StableFunctionKey  : 292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c
 * ExecutionHash      : 69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca
 * DebugHash          : 7b5cf9b724de2c986d1182919a6c00526ea84b8578bd932a7b7ccd34bae897af
 * EntryAbiHash       : 7dd05efd81ba1afb7d1e425513f38c9b25d5027fa6bc63e0b952e2427c8ec1e4
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca = "Tests.Test_MathNamespace";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca
#endif

// AS Function : FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : Raw
void ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca(FScriptExecution& Execution, UObject* l_This)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("FPhase2MathFixture::FPhase2MathFixture()", 3);
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
// SetV4 v1, 10
v_TEMP_dword_1 = 0xau;
// LoadThisR +48
l_valueRegister = ((asQWORD)l_This) + POFFSET_FPhase2MathFixture_Value;
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
// AS Function : FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : VM
void ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca(Execution,
		*(UObject**)l_fp);
}
// AS Function : FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : Parms
void ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c_69a0b637c73db9c8cd4328b5f9fe49c480d6167e9737540aa7b63ec8d14756ca(Execution,
		(UObject*)Object);
}
/*
 * AngelScript Static JIT Function
 * Declaration       : FPhase2MathFixture FPhase2MathFixture()
 * Source             : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
 * StableFunctionKey  : e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2
 * ExecutionHash      : 49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b
 * DebugHash          : 036a118ab1dda21f113368fa21488ef9105049cec36d040dd09c2fa0bde8e3b5
 * EntryAbiHash       : ec26b5d870688a8288407da6bac92673f792df091cbbd7289e00a0f5d85b1e85
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b = "Tests.Test_MathNamespace";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b
#endif

// AS Function : FPhase2MathFixture FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : Raw
UObject* ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("FPhase2MathFixture FPhase2MathFixture()", 0);
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
// FPhase2MathFixture::FPhase2MathFixture()
SCRIPT_DEBUG_CALLSTACK_POSITION(0, 0);
{
  asCScriptFunction* CallFunction = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 1u);
  FStaticJITCurrentFunctionCall CurrentFunctionCall(Execution, FAngelscriptStableFunctionKey{{FAngelscriptHash256{{FBlake3Hash(FWideStringView(TEXT("292e25ac162bcd0a97770292c0b0b8bf980038789180a2ccf7d4c7769ab6823c")))}}}}, CallFunction, (void*)(((asQWORD&)l_stack[0])), true);
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
// AS Function : FPhase2MathFixture FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : VM
void ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	*(UObject**)l_outValue = ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b(Execution);
}
// AS Function : FPhase2MathFixture FPhase2MathFixture()
// AS Source   : /Angelscript/Game/Tests/Test_MathNamespace.as:1:0
// JIT Entry   : Parms
void ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	const SIZE_T ReturnParmOffset = ParmsOffset;
	*(UObject**)(((SIZE_T)Parms) + ReturnParmOffset) = ASJIT_e2a445f5e2b4bc1a570a3cc7a94d4181044901fa64eff454950f6706ae48d7c2_49ea23553df00a305d5a46bfbf4e0097f0f4d7d1ef93afc477cf2e805a0b636b(Execution);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
