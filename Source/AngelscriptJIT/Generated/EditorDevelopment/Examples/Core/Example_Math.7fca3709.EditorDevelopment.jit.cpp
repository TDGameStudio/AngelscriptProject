// @angelscript-jit-owned revision=2 kind=module-source
/*
 * AngelScript Static JIT Module
 * VirtualSourcePath   : /Angelscript/Game/Examples/Core/Example_Math.as
 * CanonicalModuleName : Examples.Core.Example_Math
 * TargetProfile       : EditorDevelopment
 * StableModuleKey     : 7fca37092c5c2190e0f260bc2042b7bf9b5624688450cfef86d9ebac2c0eb40e
 * ProviderId          : a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5
 * ArtifactProfile     : fc019b75324eb9505dfa8aeaadc5dbbceb8d476837af625df9dfcb6a7d62ef7e
 * NativeEnvironment   : c8d9638e7c34100b327617ea9a4769bd7692413e17eb4705818e6b120acc9651
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
 * Declaration       : void ExecuteExampleMath()
 * Source             : /Angelscript/Game/Examples/Core/Example_Math.as:6:1
 * StableFunctionKey  : 283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112
 * ExecutionHash      : 94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff
 * DebugHash          : 87aa4ce443c4ad49d5974a48874887034825a2f5b2e4578b65f26389ed6d0663
 * EntryAbiHash       : e8c0e341a718465045f8c67751be91ee33b7d19102164052bcd47aa0225b063e
 */
#if AS_JIT_DEBUG_CALLSTACKS
#undef SCRIPT_DEBUG_FILENAME
static const char* MODULENAME_ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff = "Examples.Core.Example_Math";
#define SCRIPT_DEBUG_FILENAME MODULENAME_ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff
#endif

// AS Function : void ExecuteExampleMath()
// AS Source   : /Angelscript/Game/Examples/Core/Example_Math.as:6:1
// JIT Entry   : Raw
void ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff(FScriptExecution& Execution)
{
// == Jit at BC 0 ==
SCRIPT_DEBUG_CALLSTACK_FRAME("void ExecuteExampleMath()", 8);
SCRIPT_ASSUME_NO_EXCEPTION()
alignas(8) asBYTE l_stack[24];
asQWORD l_valueRegister = 0;
asBYTE l_byteRegister = 0;
asDWORD l_dwordRegister = 0;
float l_floatRegister = 0;
double l_doubleRegister = 0;
void* l_objectRegister = nullptr;
double v_AbsoluteValue = {};
double v_MinimumValue = {};
double v_MaximumValue = {};
double v_ClampedValue = {};
double v_WaveValue = {};
double v_RandomValue = {};
asBYTE v_TEMP_byte_7 = {};
double v_TEMP_double_10 = {};
double v_TEMP_double_14 = {};
double v_TEMP_double_20 = {};
double v_TEMP_double_22 = {};
// JitEntry *
// SUSPEND
// JitEntry *
// PshC8 *
// CALLSYS *
// float Math::Abs(float Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 5u).GetFunction();
  auto CastedFuncPtr = (double(*)(double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(8);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0xbff0000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v6
v_AbsoluteValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// SetV8 v4, *
v_MaximumValue = value_as<double>(0x3ff0000000000000ull);
// CMPd v6, v4
  if (v_AbsoluteValue == v_MaximumValue)     l_byteRegister = 0;
  else if (v_AbsoluteValue < v_MaximumValue) l_byteRegister = -1;
  else                l_byteRegister = 1;
// TZ
if(l_byteRegister == 0)
   l_byteRegister = 1;
else
   l_byteRegister = 0;
// CpyRtoV4 v7
v_TEMP_byte_7 = l_byteRegister;
// PshV4 v7
// CALLSYS *
// void check(bool Condition)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 4u).GetFunction();
  auto CastedFuncPtr = (void(*)(bool))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(9);
CastedFuncPtr(value_as<bool>((v_TEMP_byte_7)));
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PshC8 *
// PshC8 *
// CALLSYS *
// float Math::Min(float A, float B)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 3u).GetFunction();
  auto CastedFuncPtr = (double(*)(double,double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(11);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0x3fb999999999999au)),value_as<double>(((asQWORD)0x3ff0000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v12
v_MinimumValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// SetV8 v2, *
v_RandomValue = value_as<double>(0x3fb999999999999aull);
// CMPd v12, v2
  if (v_MinimumValue == v_RandomValue)     l_byteRegister = 0;
  else if (v_MinimumValue < v_RandomValue) l_byteRegister = -1;
  else                l_byteRegister = 1;
// TZ
if(l_byteRegister == 0)
   l_byteRegister = 1;
else
   l_byteRegister = 0;
// CpyRtoV4 v7
v_TEMP_byte_7 = l_byteRegister;
// PshV4 v7
// CALLSYS *
// void check(bool Condition)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 4u).GetFunction();
  auto CastedFuncPtr = (void(*)(bool))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(12);
CastedFuncPtr(value_as<bool>((v_TEMP_byte_7)));
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PshC8 *
// PshC8 *
// CALLSYS *
// float Math::Max(float A, float B)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 2u).GetFunction();
  auto CastedFuncPtr = (double(*)(double,double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(14);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0x3fb999999999999au)),value_as<double>(((asQWORD)0x3ff0000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v4
v_MaximumValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// SetV8 v2, *
v_RandomValue = value_as<double>(0x3ff0000000000000ull);
// CMPd v4, v2
  if (v_MaximumValue == v_RandomValue)     l_byteRegister = 0;
  else if (v_MaximumValue < v_RandomValue) l_byteRegister = -1;
  else                l_byteRegister = 1;
// TZ
if(l_byteRegister == 0)
   l_byteRegister = 1;
else
   l_byteRegister = 0;
// CpyRtoV4 v7
v_TEMP_byte_7 = l_byteRegister;
// PshV4 v7
// CALLSYS *
// void check(bool Condition)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 4u).GetFunction();
  auto CastedFuncPtr = (void(*)(bool))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(15);
CastedFuncPtr(value_as<bool>((v_TEMP_byte_7)));
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PshC8 *
// PshC8 *
// PshC8 *
// CALLSYS *
// float Math::Clamp(float X, float Min, float Max)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 0u).GetFunction();
  auto CastedFuncPtr = (double(*)(double,double,double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(17);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0x4000000000000000u)),value_as<double>(((asQWORD)0x0u)),value_as<double>(((asQWORD)0x3fe0000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v18
v_ClampedValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// SetV8 v2, *
v_RandomValue = value_as<double>(0x3fe0000000000000ull);
// CMPd v18, v2
  if (v_ClampedValue == v_RandomValue)     l_byteRegister = 0;
  else if (v_ClampedValue < v_RandomValue) l_byteRegister = -1;
  else                l_byteRegister = 1;
// TZ
if(l_byteRegister == 0)
   l_byteRegister = 1;
else
   l_byteRegister = 0;
// CpyRtoV4 v7
v_TEMP_byte_7 = l_byteRegister;
// PshV4 v7
// CALLSYS *
// void check(bool Condition)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 4u).GetFunction();
  auto CastedFuncPtr = (void(*)(bool))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(18);
CastedFuncPtr(value_as<bool>((v_TEMP_byte_7)));
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// SUSPEND
// JitEntry *
// PshC8 *
// CALLSYS *
// float Math::Sin(float Value)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 1u).GetFunction();
  auto CastedFuncPtr = (double(*)(double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(21);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0x4000000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v16
v_WaveValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// PshC8 *
// PshC8 *
// CALLSYS *
// float Math::RandRange(float Min, float Max)
{
  asFUNCTION_t RawFuncPtr = FAngelscriptJITGeneratedReferenceAccess::GetSystemFunctionPointer(Execution, 6u).GetFunction();
  auto CastedFuncPtr = (double(*)(double,double))RawFuncPtr;
SCRIPT_DEBUG_CALLSTACK_LINE(24);
double FunctionReturnValue = CastedFuncPtr(value_as<double>(((asQWORD)0x0u)),value_as<double>(((asQWORD)0x4024000000000000u)));
l_doubleRegister = FunctionReturnValue;
if (Execution.bExceptionThrown) [[unlikely]]
{
return;
}
}
// JitEntry *
// CpyRtoV8 v2
v_RandomValue = l_doubleRegister;
// SUSPEND
// JitEntry *
// RET 0
  return;
}
// AS Function : void ExecuteExampleMath()
// AS Source   : /Angelscript/Game/Examples/Core/Example_Math.as:6:1
// JIT Entry   : VM
void ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff_VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue)
{
	ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff(Execution);
}
// AS Function : void ExecuteExampleMath()
// AS Source   : /Angelscript/Game/Examples/Core/Example_Math.as:6:1
// JIT Entry   : Parms
void ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff_ParmsEntry(FScriptExecution& Execution, void* Object, void* Parms)
{
	SIZE_T ParmsOffset = 0;
	ASJIT_283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112_94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff(Execution);
}
#endif
#endif // WITH_EDITOR && UE_BUILD_DEVELOPMENT
