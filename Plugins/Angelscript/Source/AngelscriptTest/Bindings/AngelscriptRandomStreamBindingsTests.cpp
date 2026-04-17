#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptRandomStreamBindingsTests_Private
{
	struct FRandomStreamExpectations
	{
		int32 IntInitialSeed = 0;
		int32 IntInitialCurrentSeed = 0;
		uint32 IntUnsignedValue = 0;
		int32 IntRangeValue = 0;
		double IntFractionValue = 0.0;
		double IntDoubleRangeValue = 0.0;
		int32 IntPostSequenceSeed = 0;
		int32 IntCopyNextValue = 0;
		int32 IntStreamNextValue = 0;
		int32 IntResetValue = 0;
		int32 UintInitialSeed = 0;
		int32 UintInitialCurrentSeed = 0;
		uint32 UintUnsignedValue = 0;
		int32 UintResetValue = 0;
		int32 NameCurrentSeed = 0;
		int32 NameFirstRangeValue = 0;
	};

	FString ToScriptFloatLiteral(double Value)
	{
		FString Literal = FString::Printf(TEXT("%.17g"), Value);
		if (!Literal.Contains(TEXT(".")) && !Literal.Contains(TEXT("e")) && !Literal.Contains(TEXT("E")))
		{
			Literal += TEXT(".0");
		}

		return Literal;
	}

	FRandomStreamExpectations BuildRandomStreamExpectations()
	{
		FRandomStreamExpectations Expectations;

		FRandomStream NativeIntSeed(123);
		Expectations.IntInitialSeed = NativeIntSeed.GetInitialSeed();
		Expectations.IntInitialCurrentSeed = NativeIntSeed.GetCurrentSeed();
		Expectations.IntUnsignedValue = NativeIntSeed.GetUnsignedInt();
		Expectations.IntRangeValue = NativeIntSeed.RandRange(1, 1000);
		Expectations.IntFractionValue = NativeIntSeed.GetFraction();
		Expectations.IntDoubleRangeValue = NativeIntSeed.FRandRange(0.0, 10.0);
		Expectations.IntPostSequenceSeed = NativeIntSeed.GetCurrentSeed();

		FRandomStream NativeIntCopy = NativeIntSeed;
		Expectations.IntCopyNextValue = NativeIntCopy.RandRange(1, 1000);
		Expectations.IntStreamNextValue = NativeIntSeed.RandRange(1, 1000);
		NativeIntSeed.Reset();
		Expectations.IntResetValue = NativeIntSeed.RandRange(1, 1000);

		FRandomStream NativeUintSeed(uint32(123));
		Expectations.UintInitialSeed = NativeUintSeed.GetInitialSeed();
		Expectations.UintInitialCurrentSeed = NativeUintSeed.GetCurrentSeed();
		Expectations.UintUnsignedValue = NativeUintSeed.GetUnsignedInt();
		NativeUintSeed.Reset();
		Expectations.UintResetValue = NativeUintSeed.RandRange(1, 1000);

		FRandomStream NativeNameSeed;
		NativeNameSeed.Initialize(FName(TEXT("RandomSeedName")));
		Expectations.NameCurrentSeed = NativeNameSeed.GetCurrentSeed();
		Expectations.NameFirstRangeValue = NativeNameSeed.RandRange(1, 1000);

		return Expectations;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptRandomStreamBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRandomStreamSequenceParityTest,
	"Angelscript.TestModule.Bindings.RandomStreamSequenceParity",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptRandomStreamSequenceParityTest::RunTest(const FString& Parameters)
{
	FRandomStreamExpectations Expectations = BuildRandomStreamExpectations();

	FString ScriptSource = TEXT(R"(
bool NearlyEqual(float64 A, float64 B)
{
	return Math::Abs(A - B) <= 0.000001;
}

int Entry()
{
	FRandomStream IntStream(123);
	if (IntStream.GetInitialSeed() != __INT_INITIAL_SEED__)
		return 10;
	if (IntStream.GetCurrentSeed() != __INT_INITIAL_CURRENT_SEED__)
		return 11;
	if (IntStream.GetUnsignedInt() != __INT_UNSIGNED_VALUE__)
		return 12;
	if (IntStream.RandRange(1, 1000) != __INT_RANGE_VALUE__)
		return 13;
	if (!NearlyEqual(IntStream.GetFraction(), __INT_FRACTION_VALUE__))
		return 14;
	if (!NearlyEqual(IntStream.RandRange(0.0, 10.0), __INT_DOUBLE_RANGE_VALUE__))
		return 15;
	if (IntStream.GetCurrentSeed() != __INT_POST_SEQUENCE_SEED__)
		return 16;

	FRandomStream IntCopy = IntStream;
	int CopyNext = IntCopy.RandRange(1, 1000);
	int StreamNext = IntStream.RandRange(1, 1000);
	if (CopyNext != __INT_COPY_NEXT_VALUE__)
		return 17;
	if (StreamNext != __INT_STREAM_NEXT_VALUE__)
		return 18;
	if (CopyNext != StreamNext)
		return 19;

	IntStream.Reset();
	if (IntStream.RandRange(1, 1000) != __INT_RESET_VALUE__)
		return 20;

	FRandomStream UintStream(uint32(123));
	if (UintStream.GetInitialSeed() != __UINT_INITIAL_SEED__)
		return 30;
	if (UintStream.GetCurrentSeed() != __UINT_INITIAL_CURRENT_SEED__)
		return 31;
	if (UintStream.GetUnsignedInt() != __UINT_UNSIGNED_VALUE__)
		return 32;
	UintStream.Reset();
	if (UintStream.RandRange(1, 1000) != __UINT_RESET_VALUE__)
		return 33;

	FRandomStream NameStream;
	NameStream.Initialize(n"RandomSeedName");
	if (NameStream.GetCurrentSeed() != __NAME_CURRENT_SEED__)
		return 40;
	if (NameStream.RandRange(1, 1000) != __NAME_FIRST_RANGE_VALUE__)
		return 41;

	return 1;
}
)");

	ScriptSource.ReplaceInline(TEXT("__INT_INITIAL_SEED__"), *LexToString(Expectations.IntInitialSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_INITIAL_CURRENT_SEED__"), *LexToString(Expectations.IntInitialCurrentSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_UNSIGNED_VALUE__"), *LexToString(Expectations.IntUnsignedValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_RANGE_VALUE__"), *LexToString(Expectations.IntRangeValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_FRACTION_VALUE__"), *ToScriptFloatLiteral(Expectations.IntFractionValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_DOUBLE_RANGE_VALUE__"), *ToScriptFloatLiteral(Expectations.IntDoubleRangeValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_POST_SEQUENCE_SEED__"), *LexToString(Expectations.IntPostSequenceSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_COPY_NEXT_VALUE__"), *LexToString(Expectations.IntCopyNextValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_STREAM_NEXT_VALUE__"), *LexToString(Expectations.IntStreamNextValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__INT_RESET_VALUE__"), *LexToString(Expectations.IntResetValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__UINT_INITIAL_SEED__"), *LexToString(Expectations.UintInitialSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__UINT_INITIAL_CURRENT_SEED__"), *LexToString(Expectations.UintInitialCurrentSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__UINT_UNSIGNED_VALUE__"), *LexToString(Expectations.UintUnsignedValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__UINT_RESET_VALUE__"), *LexToString(Expectations.UintResetValue), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__NAME_CURRENT_SEED__"), *LexToString(Expectations.NameCurrentSeed), ESearchCase::CaseSensitive);
	ScriptSource.ReplaceInline(TEXT("__NAME_FIRST_RANGE_VALUE__"), *LexToString(Expectations.NameFirstRangeValue), ESearchCase::CaseSensitive);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASRandomStreamSequenceParity",
		ScriptSource);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("FRandomStream bindings should preserve native sequence parity for int32/uint32/name seeds"), Result, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
