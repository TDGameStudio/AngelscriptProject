// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Examples/Core/Example_Array.as
 * CanonicalModuleName : Examples.Core.Example_Array
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 8b7574693bdbbc74e1372a47498024f4a66846c953a728b13087d8bf973c062f
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
 * Declaration       : void ExecuteExampleArray()
 * Source             : /Angelscript/Game/Examples/Core/Example_Array.as:6:1
 * StableFunctionKey  : 383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d
 * ExecutionHash      : 4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9
 * DebugHash          : 8dbf648a73f8e1dc82b19ca7b322851eb7607f51697235fcba46b76b88f3542a
 * EntryAbiHash       : b590816c0a82cd49bb6338995e0d944d753752989b2b24c8f742ee8ce347d0b8
 * ExecutionCaps      : 0
 * RuntimeTriggers    : 0
 * CapabilityHash     : 0000000000000000000000000000000000000000000000000000000000000000
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d_4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9 = "Examples.Core.Example_Array";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d_4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9
#endif

// AS Function : void ExecuteExampleArray()
// AS Source   : /Angelscript/Game/Examples/Core/Example_Array.as:6:1
// JIT Entry   : Raw
void ASJIT_383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d_4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("void ExecuteExampleArray()", 9);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[24];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
alignas(8) asBYTE MEM_v_LocalIntArray[sizeof(TArray<int32>)];
TArray<int32>& v_LocalIntArray = (TArray<int32>&)MEM_v_LocalIntArray[0];
alignas(8) asBYTE MEM_v__Iterator[24];
FUnknownValueType& v__Iterator = (FUnknownValueType&)MEM_v__Iterator[0];
asDWORD v_Value = {};
asDWORD v_Count = {};
asDWORD v_Value_1 = {};
asDWORD v_Index = {};
alignas(8) asBYTE MEM_v_TEMP_18[24];
FUnknownValueType& v_TEMP_18 = (FUnknownValueType&)MEM_v_TEMP_18[0];
alignas(8) asBYTE MEM_v_TEMP_24[sizeof(FString)];
FString& v_TEMP_24 = (FString&)MEM_v_TEMP_24[0];
alignas(8) asBYTE MEM_v_TEMP_28[sizeof(FString)];
FString& v_TEMP_28 = (FString&)MEM_v_TEMP_28[0];
asDWORD v_TEMP_dword_5 = {};
asBYTE v_TEMP_byte_19 = {};
// JitEntry *
// SUSPEND
// JitEntry *
// PSF v4
// CALLSYS *
// TArray::TArray()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 4u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(9, 2);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v5, 2
v_TEMP_dword_5 = 0x2u;
// PSF v5
// PSF v4
// CALLSYS *
// void TArray::Add(const int&in Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 21u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(12, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_TEMP_dword_5)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v5, 8
v_TEMP_dword_5 = 0x8u;
// PSF v5
// PSF v4
// CALLSYS *
// void TArray::Add(const int&in Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 21u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(13, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_TEMP_dword_5)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v5, 255
v_TEMP_dword_5 = 0xffu;
// PSF v5
// PSF v4
// CALLSYS *
// void TArray::Add(const int&in Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 21u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(14, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_TEMP_dword_5)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PSF v12
// PSF v4
// CALLSYS *
// TArrayIterator<int> TArray::Iterator()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 5u).GetFunction();
  auto CastedFuncPtr = (FArrayIterator(*)(void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(17, 7);
new((void*)((&v__Iterator))) FArrayIterator(CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// JMP 66
goto LABEL_ExecuteExampleArray_136;
LABEL_ExecuteExampleArray_70:
// SUSPEND
// JitEntry *
// SUSPEND
// JitEntry *
// SUSPEND
// JitEntry *
// PSF v12
// CALLSYS *
// int& TArrayIterator::Proceed()
{
  asMETHOD_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 16u).GetMethod();
  auto CastedFuncPtr = (void*(asCUnknownClass::*)())RawFuncPtr;
  void* Object = (void*)((&v__Iterator));
SCRIPT_DEBUG_CALLSTACK_POSITION(18, 4);
void* FunctionReturnValue = (((asCUnknownClass*)Object)->*CastedFuncPtr)();
l_valueRegister = (asQWORD)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_1;
}
}
// JitEntry *
// RDR4 v5
v_TEMP_dword_5 = value_read<asDWORD>((void*)l_valueRegister);
// CpyVtoV4 v20, v5
v_Value = v_TEMP_dword_5;
// SUSPEND
// JitEntry *
// PGA *
// PSF v24
// CALLSYS *
// FString::FString(const FString&inout Other)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 11u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(19, 3);
CastedFuncPtr(Object,(void**)(FAngelscriptJITGeneratedReferenceAccess::GetGlobalStorage(Execution, 27u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_1;
}
}
// JitEntry *
// PSF v20
// PSF v28
// PSF v24
// CALLSYS *
// FString FString::opAdd(const int&inout Value) const
{
  asCScriptFunction* ScriptFunc = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 14u);
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 14u).GetFunction();
  auto CastedFuncPtr = (FString(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(19, 3);
new((void*)((&v_TEMP_28))) FString(CastedFuncPtr(Object,ScriptFunc,(void**)((&v_Value))));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_2;
}
}
// JitEntry *
// PSF v24
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(19, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_3;
}
}
// JitEntry *
// PSF v28
// CALLSYS *
// void Log(const FString&inout Text)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 6u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_POSITION(19, 3);
CastedFuncPtr((void**)((&v_TEMP_28)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_4;
}
}
// JitEntry *
// PSF v28
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_28));
SCRIPT_DEBUG_CALLSTACK_POSITION(19, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_4;
}
}
// JitEntry *
LABEL_ExecuteExampleArray_136:
// SUSPEND
// JitEntry *
// LoadVObjR
l_valueRegister = (asQWORD)((&v__Iterator)) + (short)16;
// RDR1 v19
v_TEMP_byte_19 = value_read<asBYTE>((void*)l_valueRegister);
// CpyVtoR1 v19
l_byteRegister = v_TEMP_byte_19;
// JLowNZ -77
if(l_byteRegister != 0) {
goto LABEL_ExecuteExampleArray_70;
}
// PSF v12
// CALLSYS *
// TArrayIterator::~TArrayIterator()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 15u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v__Iterator));
SCRIPT_DEBUG_CALLSTACK_POSITION(17, 50);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_1;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v20, 0
v_Value = 0x0u;
// PSF v4
// CALLSYS *
// int TArray::Num() const
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 19u).GetFunction();
  auto CastedFuncPtr = (int32(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(23, 7);
int32 FunctionReturnValue = CastedFuncPtr(Object);
l_dwordRegister = (asDWORD&)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// CpyRtoV4 v30
v_Count = l_dwordRegister;
// JMP 106
goto LABEL_ExecuteExampleArray_276;
LABEL_ExecuteExampleArray_170:
// SUSPEND
// JitEntry *
// SUSPEND
// JitEntry *
// SUSPEND
// JitEntry *
// PshV4 v20
// PSF v4
// Thiscall1 *
// int& TArray::opIndex(int Index)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 0u).GetFunction();
  auto CastedFuncPtr = (void*(*)(void*,void*,int32))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(25, 3);
void* FunctionReturnValue = CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),value_as<int32>((v_Value)));
l_valueRegister = (asQWORD)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// RDR4 v29
v_Index = value_read<asDWORD>((void*)l_valueRegister);
// CpyVtoV4 v31, v29
v_Value_1 = v_Index;
// SUSPEND
// JitEntry *
// PGA *
// PSF v24
// CALLSYS *
// FString::FString(const FString&inout Other)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 11u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr(Object,(void**)(FAngelscriptJITGeneratedReferenceAccess::GetGlobalStorage(Execution, 25u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// PSF v20
// PSF v28
// PSF v24
// CALLSYS *
// FString FString::opAdd(const int&inout Value) const
{
  asCScriptFunction* ScriptFunc = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 14u);
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 14u).GetFunction();
  auto CastedFuncPtr = (FString(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
new((void*)((&v_TEMP_28))) FString(CastedFuncPtr(Object,ScriptFunc,(void**)((&v_Value))));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_5;
}
}
// JitEntry *
// PSF v24
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_6;
}
}
// JitEntry *
// PGA *
// PSF v24
// PSF v28
// CALLSYS *
// FString FString::opAdd(const FString&inout Other) const
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 9u).GetFunction();
  auto CastedFuncPtr = (FString(*)(void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_28));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
new((void*)((&v_TEMP_24))) FString(CastedFuncPtr(Object,(void**)(FAngelscriptJITGeneratedReferenceAccess::GetGlobalStorage(Execution, 24u))));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_7;
}
}
// JitEntry *
// PSF v28
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_28));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_6;
}
}
// JitEntry *
// PSF v31
// PSF v28
// PSF v24
// CALLSYS *
// FString FString::opAdd(const int&inout Value) const
{
  asCScriptFunction* ScriptFunc = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 14u);
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 14u).GetFunction();
  auto CastedFuncPtr = (FString(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
new((void*)((&v_TEMP_28))) FString(CastedFuncPtr(Object,ScriptFunc,(void**)((&v_Value_1))));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_5;
}
}
// JitEntry *
// PSF v24
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_24));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_6;
}
}
// JitEntry *
// PSF v28
// CALLSYS *
// void Log(const FString&inout Text)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 6u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr((void**)((&v_TEMP_28)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_7;
}
}
// JitEntry *
// PSF v28
// CALLSYS *
// FString::~FString()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
  void* Object = (void*)((&v_TEMP_28));
SCRIPT_DEBUG_CALLSTACK_POSITION(26, 3);
CastedFuncPtr(Object);
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_7;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// IncVi v20
v_Value++;
LABEL_ExecuteExampleArray_276:
// SUSPEND
// JitEntry *
// CMPi v20, v30
  if (((int32&)v_Value) == ((int32&)v_Count))     l_byteRegister = 0;
  else if (((int32&)v_Value) < ((int32&)v_Count)) l_byteRegister = -1;
  else                l_byteRegister = 1;
// JS -114
if(((int8&)l_byteRegister) < 0) {
goto LABEL_ExecuteExampleArray_170;
}
// SUSPEND
// JitEntry *
// SetV4 v29, 8
v_Index = 0x8u;
// PSF v29
// PSF v4
// CALLSYS *
// bool TArray::Contains(const int&in Value) const
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 13u).GetFunction();
  auto CastedFuncPtr = (bool(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(30, 2);
bool FunctionReturnValue = CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_Index)));
l_byteRegister = (asBYTE&)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// CpyRtoV4 v19
v_TEMP_byte_19 = l_byteRegister;
// NOT v19
v_TEMP_byte_19 = !v_TEMP_byte_19;
// CpyVtoR1 v19
l_byteRegister = v_TEMP_byte_19;
// JLowZ 13
if(l_byteRegister == 0) {
goto LABEL_ExecuteExampleArray_316;
}
// SUSPEND
// JitEntry *
// PGA *
// CALLSYS *
// void Throw(const FString&inout Text)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 3u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_POSITION(31, 3);
CastedFuncPtr((void**)(FAngelscriptJITGeneratedReferenceAccess::GetGlobalStorage(Execution, 26u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
LABEL_ExecuteExampleArray_316:
// SUSPEND
// JitEntry *
// SetV4 v5, 255
v_TEMP_dword_5 = 0xffu;
// PSF v5
// PSF v4
// CALLSYS *
// int TArray::FindIndex(const int&in Value) const
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 1u).GetFunction();
  auto CastedFuncPtr = (int32(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(34, 2);
int32 FunctionReturnValue = CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_TEMP_dword_5)));
l_dwordRegister = (asDWORD&)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// CpyRtoV4 v29
v_Index = l_dwordRegister;
// SUSPEND
// JitEntry *
// CMPIi v29, 2
  if (((int32&)v_Index) == value_as<int>((asDWORD)0x2u))     l_byteRegister = 0;
  else if (((int32&)v_Index) < value_as<int>((asDWORD)0x2u)) l_byteRegister = -1;
  else                l_byteRegister = 1;
// JZ 13
if(l_byteRegister == 0) {
goto LABEL_ExecuteExampleArray_352;
}
// SUSPEND
// JitEntry *
// PGA *
// CALLSYS *
// void Throw(const FString&inout Text)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 3u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_POSITION(38, 3);
CastedFuncPtr((void**)(FAngelscriptJITGeneratedReferenceAccess::GetGlobalStorage(Execution, 23u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
LABEL_ExecuteExampleArray_352:
// SUSPEND
// JitEntry *
// PshV4 v29
// PSF v4
// CALLSYS *
// void TArray::RemoveAt(int Index)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 7u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*,int32))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(41, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),value_as<int32>((v_Index)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// SetV4 v5, 8
v_TEMP_dword_5 = 0x8u;
// PSF v5
// PSF v4
// CALLSYS *
// int TArray::Remove(const int&in Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 8u).GetFunction();
  auto CastedFuncPtr = (int32(*)(void*,void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(44, 2);
int32 FunctionReturnValue = CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),(void**)((&v_TEMP_dword_5)));
l_dwordRegister = (asDWORD&)FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PshC4 0
// PSF v4
// CALLSYS *
// void TArray::Empty(int ReservedSize = 0)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 17u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*,int32))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(47, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u),value_as<int32>(((asDWORD)0x0u)));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PSF v4
// CALLSYS *
// TArray::~TArray()
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedFuncPtr = (void(*)(void*,void*))RawFuncPtr;
  void* Object = (void*)((&v_LocalIntArray));
SCRIPT_DEBUG_CALLSTACK_POSITION(48, 2);
CastedFuncPtr(Object,FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
if (Execution.bExceptionThrown) [[unlikely]]
{
goto LABEL_ExecuteExampleArray_EXCEPTION_0;
}
}
// JitEntry *
// RET 0
  return;
SCRIPT_ASSUME(false);

LABEL_ExecuteExampleArray_EXCEPTION_0:
// Exception cleanup for variables 4
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_1:
// Exception cleanup for variables 4, 12
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asCScriptFunction* ScriptDestructor = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 15u);
  FScopeInformSystemFunction InformDestructor(Execution, ScriptDestructor);
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 15u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v__Iterator));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_2:
// Exception cleanup for variables 4, 12, 24
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asCScriptFunction* ScriptDestructor = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 15u);
  FScopeInformSystemFunction InformDestructor(Execution, ScriptDestructor);
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 15u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v__Iterator));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_24));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_3:
// Exception cleanup for variables 4, 12, 24, 28
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asCScriptFunction* ScriptDestructor = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 15u);
  FScopeInformSystemFunction InformDestructor(Execution, ScriptDestructor);
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 15u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v__Iterator));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_24));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_28));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_4:
// Exception cleanup for variables 4, 12, 28
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asCScriptFunction* ScriptDestructor = FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction(Execution, 15u);
  FScopeInformSystemFunction InformDestructor(Execution, ScriptDestructor);
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 15u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v__Iterator));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_28));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_5:
// Exception cleanup for variables 4, 24
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_24));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_6:
// Exception cleanup for variables 4, 24, 28
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_24));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_28));
}
return;
LABEL_ExecuteExampleArray_EXCEPTION_7:
// Exception cleanup for variables 4, 28
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 20u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*,void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_LocalIntArray), FAngelscriptJITGeneratedReferenceAccess::GetObjectType(Execution, 12u));
}
{
  asFUNCTION_t RawDestructorPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 18u).GetFunction();
  auto CastedDestructorPtr = (void(*)(void*))RawDestructorPtr;
  CastedDestructorPtr((void*)(&v_TEMP_28));
}
return;
}
// AS Function : void ExecuteExampleArray()
// AS Source   : /Angelscript/Game/Examples/Core/Example_Array.as:6:1
// JIT Entry   : VM
void ASJIT_383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d_4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_383be843824a6ed91adace689b518633aa923b36491c09725a7e192a3b67bd9d_4402de943895277ab2ff76cdcef2d085be898922631853da49197bf6bad82ec9(Execution);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
