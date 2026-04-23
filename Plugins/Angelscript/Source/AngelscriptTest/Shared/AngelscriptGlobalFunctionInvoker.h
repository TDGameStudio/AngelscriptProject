#pragma once

#include "CoreMinimal.h"
#include "AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "UObject/Object.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_context.h"
#include "source/as_scriptengine.h"
#include "source/as_scriptfunction.h"
#include "EndAngelscriptHeaders.h"

/**
 * AngelscriptGlobalFunctionInvoker — small, typed helper for calling AngelScript
 * *global* functions (script-module level, no enclosing UCLASS) from C++ tests.
 *
 * The existing FFunctionInvoker in AngelscriptReflectiveAccess.h targets
 * UFUNCTIONs on spawned UObjects — it goes through UObject::FindFunction and
 * UASFunction::RuntimeCallEvent. Global functions don't participate in UClass
 * reflection, so they must be called directly via asIScriptContext. This file
 * provides the same Get / Set / Call ergonomics, but the parameter bus is the
 * raw AngelScript argument register instead of a UFunction-laid-out packed
 * parameter buffer.
 *
 * Usage:
 *
 *     asIScriptModule* Module = AngelscriptTestSupport::BuildModule(...);
 *     FASGlobalFunctionInvoker Invoker(*this, Engine, *Module, TEXT("int Sum(int, int)"));
 *     Invoker.AddArg(static_cast<int32>(17));
 *     Invoker.AddArg(static_cast<int32>(25));
 *     const int32 Result = Invoker.CallAndReturn<int32>(INDEX_NONE);
 *
 * Convenience overloads ResolveFunctionByDecl / ResolveFunctionByName help
 * locate the target asIScriptFunction on the module.
 */
namespace AngelscriptReflectiveAccess
{
	/**
	 * Resolve an asIScriptFunction by its AS declaration on the given module.
	 *
	 * Mirrors the logic of AngelscriptTestSupport::GetFunctionByDecl: try the
	 * full declaration, then fall back to the bare name, then scan the module
	 * by-index. We materialise a null-terminated FString before the UTF-8
	 * conversion — FStringView::GetData() is not guaranteed null-terminated.
	 */
	inline asIScriptFunction* ResolveFunctionByDecl(
		FAutomationTestBase& Test,
		asIScriptModule& Module,
		FStringView Declaration)
	{
		const FString DeclarationStr(Declaration);
		const FTCHARToUTF8 DeclarationUtf8(*DeclarationStr);
		asIScriptFunction* Function = Module.GetFunctionByDecl(DeclarationUtf8.Get());

		FString FunctionName;
		if (Function == nullptr)
		{
			int32 OpenParenIndex = INDEX_NONE;
			if (DeclarationStr.FindChar(TEXT('('), OpenParenIndex))
			{
				const FString Prefix = DeclarationStr.Left(OpenParenIndex).TrimStartAndEnd();
				int32 NameSeparatorIndex = INDEX_NONE;
				if (Prefix.FindLastChar(TEXT(' '), NameSeparatorIndex))
				{
					FunctionName = Prefix.Mid(NameSeparatorIndex + 1).TrimStartAndEnd();
					if (!FunctionName.IsEmpty())
					{
						const FTCHARToUTF8 FunctionNameUtf8(*FunctionName);
						Function = Module.GetFunctionByName(FunctionNameUtf8.Get());
					}
				}
			}
		}

		if (Function == nullptr && !FunctionName.IsEmpty())
		{
			const asUINT FunctionCount = Module.GetFunctionCount();
			for (asUINT FunctionIndex = 0; FunctionIndex < FunctionCount; ++FunctionIndex)
			{
				asIScriptFunction* CandidateFunction = Module.GetFunctionByIndex(FunctionIndex);
				if (CandidateFunction != nullptr && FunctionName.Equals(UTF8_TO_TCHAR(CandidateFunction->GetName())))
				{
					Function = CandidateFunction;
					break;
				}
			}
		}

		if (Function == nullptr)
		{
			// Dump the module's actual function signatures so the test diagnostic
			// explains the mismatch rather than just "expected not-null".
			FString AvailableFunctions;
			const asUINT FunctionCount = Module.GetFunctionCount();
			for (asUINT FunctionIndex = 0; FunctionIndex < FunctionCount; ++FunctionIndex)
			{
				asIScriptFunction* Candidate = Module.GetFunctionByIndex(FunctionIndex);
				if (Candidate == nullptr)
				{
					continue;
				}
				if (!AvailableFunctions.IsEmpty())
				{
					AvailableFunctions += TEXT(", ");
				}
				AvailableFunctions += UTF8_TO_TCHAR(Candidate->GetDeclaration());
			}

			Test.AddError(FString::Printf(
				TEXT("AS global function '%s' did not resolve by declaration; module exposes {%s}"),
				*DeclarationStr, *AvailableFunctions));
		}

		return Function;
	}

	/** Resolve an asIScriptFunction by its unqualified AS name on the given module. */
	inline asIScriptFunction* ResolveFunctionByName(
		FAutomationTestBase& Test,
		asIScriptModule& Module,
		FStringView Name)
	{
		const FString NameStr(Name);
		const FTCHARToUTF8 NameUtf8(*NameStr);
		asIScriptFunction* Function = Module.GetFunctionByName(NameUtf8.Get());
		Test.TestNotNull(
			*FString::Printf(TEXT("AS global function '%s' should resolve by name"), *NameStr),
			Function);
		return Function;
	}

	/**
	 * Typed builder around asIScriptContext that matches the argument slots of
	 * an AS global function. Each AddArg overload advances the cursor. Call() /
	 * CallAndReturn<R>() execute the context and tear it down.
	 *
	 * Argument mapping:
	 *   AddArg(bool)         -> SetArgByte
	 *   AddArg(uint8)        -> SetArgByte
	 *   AddArg(int16/uint16) -> SetArgWord
	 *   AddArg(int32/uint32) -> SetArgDWord
	 *   AddArg(int64/uint64) -> SetArgQWord
	 *   AddArg(float)        -> SetArgFloat
	 *   AddArg(double)       -> SetArgDouble
	 *   AddArgObject(T*)     -> SetArgObject (for UObject / script class handles)
	 *   AddArgRef<T>(ref)    -> SetArgAddress (for &in / &out / &inout refs)
	 *   AddArgStruct<T>(val) -> SetArgObject on a live temp copy
	 *
	 * Return mapping (CallAndReturn<R>):
	 *   R = bool / integer / enum -> GetReturnByte/Word/DWord/QWord
	 *   R = float / double        -> GetReturnFloat / GetReturnDouble
	 *   R = T*                    -> GetReturnObject
	 *
	 * For AS `float` parameters, the AS runtime applies asEP_FLOAT_IS_FLOAT64=1
	 * so the UFunction-side type is FDoubleProperty — but at the raw AS context
	 * level the parameter is still a `float`. So at this layer callers should
	 * use AddArg(1.0f), NOT AddArg(1.0). (The UFUNCTION path is the
	 * only place where you need `AddParam<double>`.)
	 */
	struct FASGlobalFunctionInvoker
	{
		FASGlobalFunctionInvoker(
			FAutomationTestBase& InTest,
			FAngelscriptEngine& InEngine,
			asIScriptFunction& InFunction)
			: Test(InTest)
			, Engine(InEngine)
			, Function(&InFunction)
		{
			EngineScope = MakeUnique<FAngelscriptEngineScope>(Engine);
			Context = Engine.CreateContext();
			if (!Test.TestNotNull(TEXT("AS global invoker should create an execution context"), Context))
			{
				return;
			}

			const int PrepareResult = Context->Prepare(Function);
			if (!Test.TestEqual(
					*FString::Printf(TEXT("AS global invoker should Prepare '%s' (code %d)"),
						UTF8_TO_TCHAR(Function->GetDeclaration()), PrepareResult),
					PrepareResult,
					static_cast<int32>(asSUCCESS)))
			{
				Context->Release();
				Context = nullptr;
				return;
			}

			bValid = true;
		}

		/** Overload that takes a script module + AS declaration for the common case. */
		FASGlobalFunctionInvoker(
			FAutomationTestBase& InTest,
			FAngelscriptEngine& InEngine,
			asIScriptModule& Module,
			FStringView Declaration)
			: Test(InTest)
			, Engine(InEngine)
			, Function(ResolveFunctionByDecl(InTest, Module, Declaration))
		{
			if (Function == nullptr)
			{
				return;
			}

			EngineScope = MakeUnique<FAngelscriptEngineScope>(Engine);
			Context = Engine.CreateContext();
			if (!Test.TestNotNull(TEXT("AS global invoker should create an execution context"), Context))
			{
				return;
			}

			const int PrepareResult = Context->Prepare(Function);
			if (!Test.TestEqual(
					*FString::Printf(TEXT("AS global invoker should Prepare '%s' (code %d)"),
						*FString(Declaration), PrepareResult),
					PrepareResult,
					static_cast<int32>(asSUCCESS)))
			{
				Context->Release();
				Context = nullptr;
				return;
			}

			bValid = true;
		}

		~FASGlobalFunctionInvoker()
		{
			if (Context != nullptr)
			{
				Context->Release();
				Context = nullptr;
			}
			EngineScope.Reset();
		}

		FASGlobalFunctionInvoker(const FASGlobalFunctionInvoker&) = delete;
		FASGlobalFunctionInvoker& operator=(const FASGlobalFunctionInvoker&) = delete;

		bool IsValid() const { return bValid; }
		asIScriptContext* GetContext() const { return Context; }

		// Typed argument setters — each advances the cursor by one AS slot.
		FASGlobalFunctionInvoker& AddArg(bool    Value)    { return SetArg([&]{ return Context->SetArgByte  (NextArgIndex, Value ? 1 : 0); }); }
		FASGlobalFunctionInvoker& AddArg(uint8   Value)    { return SetArg([&]{ return Context->SetArgByte  (NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArg(int8    Value)    { return SetArg([&]{ return Context->SetArgByte  (NextArgIndex, static_cast<uint8>(Value)); }); }
		FASGlobalFunctionInvoker& AddArg(uint16  Value)    { return SetArg([&]{ return Context->SetArgWord  (NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArg(int16   Value)    { return SetArg([&]{ return Context->SetArgWord  (NextArgIndex, static_cast<uint16>(Value)); }); }
		FASGlobalFunctionInvoker& AddArg(uint32  Value)    { return SetArg([&]{ return Context->SetArgDWord (NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArg(int32   Value)    { return SetArg([&]{ return Context->SetArgDWord (NextArgIndex, static_cast<uint32>(Value)); }); }
		FASGlobalFunctionInvoker& AddArg(uint64  Value)    { return SetArg([&]{ return Context->SetArgQWord (NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArg(int64   Value)    { return SetArg([&]{ return Context->SetArgQWord (NextArgIndex, static_cast<uint64>(Value)); }); }
		FASGlobalFunctionInvoker& AddArg(float   Value)    { return SetArg([&]{ return Context->SetArgFloat (NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArg(double  Value)    { return SetArg([&]{ return Context->SetArgDouble(NextArgIndex, Value); }); }
		FASGlobalFunctionInvoker& AddArgObject(void* Obj)  { return SetArg([&]{ return Context->SetArgObject(NextArgIndex, Obj); }); }
		FASGlobalFunctionInvoker& AddArgAddress(void* Ptr) { return SetArg([&]{ return Context->SetArgAddress(NextArgIndex, Ptr); }); }

		/**
		 * Bind a reference-style argument (AS `&in` / `&out` / `&inout`) to the
		 * supplied live storage. The caller owns the lifetime and can read out
		 * any modifications after Call() returns.
		 */
		template <typename T>
		FASGlobalFunctionInvoker& AddArgRef(T& InOutRef)
		{
			return AddArgAddress(const_cast<std::remove_const_t<T>*>(&InOutRef));
		}

		/**
		 * Bind a value-style struct argument (AS USTRUCT passed by value) by
		 * copying through SetArgObject. The AS engine does NOT destroy the
		 * argument — our live C++ temporary is torn down by the normal scope.
		 */
		template <typename T>
		FASGlobalFunctionInvoker& AddArgStruct(T& LiveValue)
		{
			return AddArgObject(static_cast<void*>(&LiveValue));
		}

		/** Execute the function. Returns true if it ran to completion. */
		bool Call()
		{
			if (!bValid)
			{
				return false;
			}

			if (!Test.TestEqual(
					*FString::Printf(TEXT("AS global '%s' should receive the declared number of arguments"),
						UTF8_TO_TCHAR(Function->GetDeclaration())),
					NextArgIndex,
					static_cast<uint32>(Function->GetParamCount())))
			{
				return false;
			}

			const int ExecuteResult = Context->Execute();
			if (ExecuteResult != asEXECUTION_FINISHED)
			{
				const char* ExceptionText = Context->GetExceptionString();
				Test.AddError(FString::Printf(
					TEXT("AS global '%s' failed to execute (code %d%s%s)"),
					UTF8_TO_TCHAR(Function->GetDeclaration()),
					ExecuteResult,
					ExceptionText != nullptr ? TEXT(": ") : TEXT(""),
					ExceptionText != nullptr ? UTF8_TO_TCHAR(ExceptionText) : TEXT("")));
				return false;
			}

			bHasRun = true;
			return true;
		}

		/** Call the function and return the integer-family / pointer return value. */
		template <typename ReturnType>
		ReturnType CallAndReturn(const ReturnType& Fallback = ReturnType{})
		{
			if (!Call())
			{
				return Fallback;
			}
			return ReadReturn<ReturnType>(Fallback);
		}

		/** Return whether Call() has been invoked. */
		bool HasRun() const { return bHasRun; }

	private:
		template <typename SetArgFn>
		FASGlobalFunctionInvoker& SetArg(SetArgFn&& Fn)
		{
			if (!bValid)
			{
				return *this;
			}

			if (NextArgIndex >= Function->GetParamCount())
			{
				Test.AddError(FString::Printf(
					TEXT("AS global '%s' has %u parameters; AddArg cursor out of range at %u"),
					UTF8_TO_TCHAR(Function->GetDeclaration()),
					static_cast<uint32>(Function->GetParamCount()),
					NextArgIndex));
				bValid = false;
				return *this;
			}

			const int Code = Fn();
			if (Code != asSUCCESS)
			{
				Test.AddError(FString::Printf(
					TEXT("AS global '%s' SetArg index %u failed with code %d"),
					UTF8_TO_TCHAR(Function->GetDeclaration()), NextArgIndex, Code));
				bValid = false;
				return *this;
			}
			++NextArgIndex;
			return *this;
		}

		// Return-value extractors. We specialize via overloads on a dispatch tag
		// struct to keep the template surface simple for callers (`CallAndReturn<int32>()`).
		template <typename R>
		R ReadReturn(const R& Fallback)
		{
			if constexpr (std::is_same_v<R, bool>)
			{
				return Context->GetReturnByte() != 0;
			}
			else if constexpr (std::is_same_v<R, uint8> || std::is_same_v<R, int8>)
			{
				return static_cast<R>(Context->GetReturnByte());
			}
			else if constexpr (std::is_same_v<R, uint16> || std::is_same_v<R, int16>)
			{
				return static_cast<R>(Context->GetReturnWord());
			}
			else if constexpr (std::is_same_v<R, uint32> || std::is_same_v<R, int32>)
			{
				return static_cast<R>(Context->GetReturnDWord());
			}
			else if constexpr (std::is_same_v<R, uint64> || std::is_same_v<R, int64>)
			{
				return static_cast<R>(Context->GetReturnQWord());
			}
			else if constexpr (std::is_same_v<R, float>)
			{
				return Context->GetReturnFloat();
			}
			else if constexpr (std::is_same_v<R, double>)
			{
				return Context->GetReturnDouble();
			}
			else if constexpr (std::is_pointer_v<R>)
			{
				// Object-pointer return (e.g. UObject*, script-class handle).
				return static_cast<R>(Context->GetReturnObject());
			}
			else
			{
				static_assert(sizeof(R) == 0, "Unsupported return type for FASGlobalFunctionInvoker::CallAndReturn — "
					"use ReadReturnStruct<T>() for USTRUCTs or call through a dedicated helper.");
				return Fallback;
			}
		}

	public:
		/**
		 * Read a USTRUCT return value out of the return register. Only valid
		 * after Call() has run. The caller owns the copy.
		 */
		template <typename StructType>
		bool ReadReturnStruct(StructType& OutValue)
		{
			if (!bHasRun)
			{
				Test.AddError(TEXT("ReadReturnStruct called before Call() completed"));
				return false;
			}

			const void* Address = Context->GetAddressOfReturnValue();
			if (!Test.TestNotNull(TEXT("AS global return should provide a value address"), Address))
			{
				return false;
			}
			OutValue = *static_cast<const StructType*>(Address);
			return true;
		}

	private:
		FAutomationTestBase& Test;
		FAngelscriptEngine& Engine;
		asIScriptFunction* Function = nullptr;
		asIScriptContext* Context = nullptr;
		TUniquePtr<FAngelscriptEngineScope> EngineScope;
		asUINT NextArgIndex = 0;
		bool bValid = false;
		bool bHasRun = false;
	};
}
