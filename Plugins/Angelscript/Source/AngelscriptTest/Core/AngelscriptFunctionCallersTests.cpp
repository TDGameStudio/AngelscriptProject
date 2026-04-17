#include "Core/FunctionCallers.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptFunctionCallersTests_Private
{
	struct FFunctionCallerHarness
	{
		int32 Bias = 0;

		int32 AddToBias(int32 Value, int32& InOut)
		{
			InOut += Bias;
			return Bias + Value + InOut;
		}

		const int32& GetBiasRef() const
		{
			return Bias;
		}
	};

	int32 GlobalAddAndBump(int32 Value, int32& InOut)
	{
		InOut += 6;
		return Value + InOut;
	}

	void CopyFromPtr(const int32* InValue, int32& OutValue)
	{
		OutValue = InValue != nullptr ? *InValue : -1;
	}

	void InvokeCaller(const FFuncEntry& Entry, void** Arguments, void* ReturnValue)
	{
		if (Entry.Caller.type == 1)
		{
			Entry.Caller.FuncPtr(
				reinterpret_cast<ASAutoCaller::TFunctionPtr>(Entry.FuncPtr.ptr.f.func),
				Arguments,
				ReturnValue);
			return;
		}

		if (Entry.Caller.type == 2)
		{
			union FMethodPtrBridge
			{
				FTypeErasedMethodPtr Erased;
				ASAutoCaller::TMethodPtr Auto;
			};

			FMethodPtrBridge MethodPtrBridge;
			FMemory::Memzero(MethodPtrBridge);
			MethodPtrBridge.Erased = Entry.FuncPtr.ptr.m.mthd;
			Entry.Caller.MethodPtr(MethodPtrBridge.Auto, Arguments, ReturnValue);
		}
	}
}

using namespace AngelscriptTest_Core_AngelscriptFunctionCallersTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFunctionCallersRoundTripTest,
	"Angelscript.TestModule.Engine.FunctionCallers.DirectCallersRoundTripValueReferenceAndPointerArguments",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptFunctionCallersRoundTripTest::RunTest(const FString& Parameters)
{
	FFuncEntry GlobalEntry = { ERASE_AUTO_FUNCTION_PTR(GlobalAddAndBump) };
	FFuncEntry MethodEntry = { ERASE_AUTO_METHOD_PTR(FFunctionCallerHarness, AddToBias) };
	FFuncEntry ConstMethodEntry = { ERASE_AUTO_METHOD_PTR(FFunctionCallerHarness, GetBiasRef) };
	FFuncEntry PointerEntry = { ERASE_AUTO_FUNCTION_PTR(CopyFromPtr) };

	if (!TestTrue(TEXT("Function caller round-trip test should bind the global direct-call pointer"), GlobalEntry.FuncPtr.IsBound()) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the global caller thunk"), GlobalEntry.Caller.IsBound()) ||
		!TestEqual(TEXT("Function caller round-trip test should tag the global caller as a function thunk"), GlobalEntry.Caller.type, 1) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the method direct-call pointer"), MethodEntry.FuncPtr.IsBound()) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the method caller thunk"), MethodEntry.Caller.IsBound()) ||
		!TestEqual(TEXT("Function caller round-trip test should tag the method caller as a method thunk"), MethodEntry.Caller.type, 2) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the const method direct-call pointer"), ConstMethodEntry.FuncPtr.IsBound()) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the const method caller thunk"), ConstMethodEntry.Caller.IsBound()) ||
		!TestEqual(TEXT("Function caller round-trip test should keep the const method on the method-thunk path"), ConstMethodEntry.Caller.type, 2) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the pointer-argument direct-call pointer"), PointerEntry.FuncPtr.IsBound()) ||
		!TestTrue(TEXT("Function caller round-trip test should bind the pointer-argument caller thunk"), PointerEntry.Caller.IsBound()) ||
		!TestEqual(TEXT("Function caller round-trip test should keep the pointer-argument function on the function-thunk path"), PointerEntry.Caller.type, 1))
	{
		return false;
	}

	int32 GlobalValue = 9;
	int32 GlobalInOut = 4;
	int32 GlobalReturn = 0;
	void* GlobalArgs[] = { &GlobalValue, &GlobalInOut };
	InvokeCaller(GlobalEntry, GlobalArgs, &GlobalReturn);

	if (!TestEqual(TEXT("Function caller round-trip test should preserve the by-value global input"), GlobalValue, 9) ||
		!TestEqual(TEXT("Function caller round-trip test should write back the by-reference global argument"), GlobalInOut, 10) ||
		!TestEqual(TEXT("Function caller round-trip test should return the expected global result"), GlobalReturn, 19))
	{
		return false;
	}

	FFunctionCallerHarness Harness;
	Harness.Bias = 11;

	int32 MethodValue = 5;
	int32 MethodInOut = 4;
	int32 MethodReturn = 0;
	void* MethodArgs[] = { &Harness, &MethodValue, &MethodInOut };
	InvokeCaller(MethodEntry, MethodArgs, &MethodReturn);

	if (!TestEqual(TEXT("Function caller round-trip test should keep the by-value method input untouched"), MethodValue, 5) ||
		!TestEqual(TEXT("Function caller round-trip test should route the reference method argument back to the caller"), MethodInOut, 15) ||
		!TestEqual(TEXT("Function caller round-trip test should dispatch methods against the object passed in Args[0]"), MethodReturn, 31))
	{
		return false;
	}

	const int32* BiasRef = nullptr;
	void* ConstMethodArgs[] = { &Harness };
	InvokeCaller(ConstMethodEntry, ConstMethodArgs, &BiasRef);

	if (!TestNotNull(TEXT("Function caller round-trip test should materialize the const method return reference as a stable pointer"), BiasRef) ||
		!TestEqual(TEXT("Function caller round-trip test should preserve the const reference value"), BiasRef != nullptr ? *BiasRef : 0, Harness.Bias) ||
		!TestTrue(TEXT("Function caller round-trip test should return a reference to the object field rather than a copied temporary"), BiasRef == &Harness.Bias))
	{
		return false;
	}

	int32 PointerSource = 27;
	const int32* PointerInput = &PointerSource;
	int32 PointerOut = 0;
	void* PointerArgs[] = { const_cast<int32*>(PointerInput), &PointerOut };
	InvokeCaller(PointerEntry, PointerArgs, nullptr);

	return TestEqual(TEXT("Function caller round-trip test should dereference const pointer parameters and write the result to the referenced output"), PointerOut, 27);
}

#endif
