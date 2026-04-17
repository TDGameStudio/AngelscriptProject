#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/ScopeExit.h"
#include "Misc/Timespan.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTimespanAdvancedCompatBindingsTest,
	"Angelscript.TestModule.Bindings.TimespanAdvancedCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptTimespanBindingsTests_Private
{
	static constexpr ANSICHAR TimespanBindingsModuleName[] = "ASTimespanAdvancedCompat";

	struct FTimespanValueBaseline
	{
		int64 Ticks = 0;
		int32 Days = 0;
		int32 Hours = 0;
		int32 Minutes = 0;
		int32 Seconds = 0;
		int32 FractionMicro = 0;
		int32 FractionMilli = 0;
		int32 FractionNano = 0;
		int32 FractionTicks = 0;
		double TotalHours = 0.0;
		double TotalMinutes = 0.0;
		double TotalSeconds = 0.0;
		FString DefaultString;
		FString FormattedString;
	};

	struct FTimespanBindingsBaselines
	{
		FString DetailedFormat;
		FTimespanValueBaseline TicksBased;
		FTimespanValueBaseline Whole;
		FTimespanValueBaseline Detailed;
		FTimespanValueBaseline NegativeDuration;
		FTimespanValueBaseline ModResult;
		FTimespanValueBaseline MutableAfterAdd;
		FTimespanValueBaseline MutableAfterSub;
		FTimespanValueBaseline MutableAfterMul;
		FTimespanValueBaseline MutableAfterDiv;
		FTimespanValueBaseline MutableAfterMod;
		double Ratio = 0.0;
		int32 MaxCmpMin = 0;
	};

	FTimespanValueBaseline CaptureTimespanBaseline(const FTimespan& Value, const TCHAR* Format = nullptr)
	{
		FTimespanValueBaseline Baseline;
		Baseline.Ticks = Value.GetTicks();
		Baseline.Days = Value.GetDays();
		Baseline.Hours = Value.GetHours();
		Baseline.Minutes = Value.GetMinutes();
		Baseline.Seconds = Value.GetSeconds();
		Baseline.FractionMicro = Value.GetFractionMicro();
		Baseline.FractionMilli = Value.GetFractionMilli();
		Baseline.FractionNano = Value.GetFractionNano();
		Baseline.FractionTicks = Value.GetFractionTicks();
		Baseline.TotalHours = Value.GetTotalHours();
		Baseline.TotalMinutes = Value.GetTotalMinutes();
		Baseline.TotalSeconds = Value.GetTotalSeconds();
		Baseline.DefaultString = Value.ToString();
		if (Format != nullptr)
		{
			Baseline.FormattedString = Value.ToString(Format);
		}

		return Baseline;
	}

	int32 CompareTimespans(const FTimespan& Left, const FTimespan& Right)
	{
		if (Left < Right)
		{
			return -1;
		}
		if (Left > Right)
		{
			return 1;
		}

		return 0;
	}

	FString ToScriptInt64Literal(const int64 Value)
	{
		return FString::Printf(TEXT("%lld"), static_cast<long long>(Value));
	}

	FString ToScriptFloat64Literal(const double Value)
	{
		return FString::Printf(TEXT("%.17g"), Value);
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const FString& Replacement)
	{
		ScriptSource.ReplaceInline(Token, *Replacement, ESearchCase::CaseSensitive);
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const int32 Replacement)
	{
		ReplaceToken(ScriptSource, Token, FString::FromInt(Replacement));
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const int64 Replacement)
	{
		ReplaceToken(ScriptSource, Token, ToScriptInt64Literal(Replacement));
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const double Replacement)
	{
		ReplaceToken(ScriptSource, Token, ToScriptFloat64Literal(Replacement));
	}

	void ReplaceTimespanTokens(FString& ScriptSource, const TCHAR* Prefix, const FTimespanValueBaseline& Baseline)
	{
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_TICKS__"), Prefix), Baseline.Ticks);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_DAYS__"), Prefix), Baseline.Days);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_HOURS__"), Prefix), Baseline.Hours);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_MINUTES__"), Prefix), Baseline.Minutes);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_SECONDS__"), Prefix), Baseline.Seconds);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_FRACTION_MICRO__"), Prefix), Baseline.FractionMicro);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_FRACTION_MILLI__"), Prefix), Baseline.FractionMilli);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_FRACTION_NANO__"), Prefix), Baseline.FractionNano);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_FRACTION_TICKS__"), Prefix), Baseline.FractionTicks);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_TOTAL_HOURS__"), Prefix), Baseline.TotalHours);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_TOTAL_MINUTES__"), Prefix), Baseline.TotalMinutes);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_TOTAL_SECONDS__"), Prefix), Baseline.TotalSeconds);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_DEFAULT_STRING__"), Prefix), Baseline.DefaultString.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_FORMATTED_STRING__"), Prefix), Baseline.FormattedString.ReplaceCharWithEscapedChar());
	}

	FTimespanBindingsBaselines BuildBaselines()
	{
		FTimespanBindingsBaselines Baselines;
		Baselines.DetailedFormat = TEXT("%d.%h:%m:%s");

		const FTimespan TicksBased(900000000);
		const FTimespan Whole(1, 2, 3, 4);
		const FTimespan Detailed(1, 2, 3, 4, 500000000);
		const FTimespan Dividend = FTimespan::FromMinutes(95.0);
		const FTimespan Divisor = FTimespan::FromMinutes(30.0);

		Baselines.TicksBased = CaptureTimespanBaseline(TicksBased);
		Baselines.Whole = CaptureTimespanBaseline(Whole);
		Baselines.Detailed = CaptureTimespanBaseline(Detailed, *Baselines.DetailedFormat);
		FTimespan NegativeDividend = -Dividend;
		Baselines.NegativeDuration = CaptureTimespanBaseline(NegativeDividend.GetDuration());
		Baselines.ModResult = CaptureTimespanBaseline(Dividend % Divisor);
		Baselines.Ratio = FTimespan::Ratio(Dividend, Divisor);

		FTimespan Mutable = FTimespan::FromMinutes(10.0);
		Mutable += FTimespan::FromSeconds(45.0);
		Baselines.MutableAfterAdd = CaptureTimespanBaseline(Mutable);

		Mutable -= FTimespan::FromSeconds(15.0);
		Baselines.MutableAfterSub = CaptureTimespanBaseline(Mutable);

		Mutable *= 2.0;
		Baselines.MutableAfterMul = CaptureTimespanBaseline(Mutable);

		Mutable /= 4.0;
		Baselines.MutableAfterDiv = CaptureTimespanBaseline(Mutable);

		Mutable %= FTimespan::FromMinutes(3.0);
		Baselines.MutableAfterMod = CaptureTimespanBaseline(Mutable);

		Baselines.MaxCmpMin = CompareTimespans(FTimespan::MaxValue(), FTimespan::MinValue());
		return Baselines;
	}

	FString BuildScriptSource(const FTimespanBindingsBaselines& Baselines)
	{
		FString ScriptSource = TEXT(R"(
bool NearlyEqual(float64 Observed, float64 Expected, float64 Tolerance)
{
	return Observed >= Expected - Tolerance && Observed <= Expected + Tolerance;
}

int VerifyTimespanValue(FTimespan Value, int64 ExpectedTicks, int ExpectedDays, int ExpectedHours, int ExpectedMinutes, int ExpectedSeconds, int ExpectedFractionMicro, int ExpectedFractionMilli, int ExpectedFractionNano, int ExpectedFractionTicks, float64 ExpectedTotalHours, float64 ExpectedTotalMinutes, float64 ExpectedTotalSeconds, int FailureBase)
{
	if (Value.GetTicks() != ExpectedTicks)
		return FailureBase + 0;
	if (Value.GetDays() != ExpectedDays)
		return FailureBase + 1;
	if (Value.GetHours() != ExpectedHours)
		return FailureBase + 2;
	if (Value.GetMinutes() != ExpectedMinutes)
		return FailureBase + 3;
	if (Value.GetSeconds() != ExpectedSeconds)
		return FailureBase + 4;
	if (Value.GetFractionMicro() != ExpectedFractionMicro)
		return FailureBase + 5;
	if (Value.GetFractionMilli() != ExpectedFractionMilli)
		return FailureBase + 6;
	if (Value.GetFractionNano() != ExpectedFractionNano)
		return FailureBase + 7;
	if (Value.GetFractionTicks() != ExpectedFractionTicks)
		return FailureBase + 8;
	if (!NearlyEqual(Value.GetTotalHours(), ExpectedTotalHours, 0.000000001))
		return FailureBase + 9;
	if (!NearlyEqual(Value.GetTotalMinutes(), ExpectedTotalMinutes, 0.000000001))
		return FailureBase + 10;
	if (!NearlyEqual(Value.GetTotalSeconds(), ExpectedTotalSeconds, 0.000000001))
		return FailureBase + 11;

	return 0;
}

int Entry()
{
	FTimespan TicksBased(int64(__TICKS_BASED_TICKS__));
	int Result = VerifyTimespanValue(TicksBased, int64(__TICKS_BASED_TICKS__), __TICKS_BASED_DAYS__, __TICKS_BASED_HOURS__, __TICKS_BASED_MINUTES__, __TICKS_BASED_SECONDS__, __TICKS_BASED_FRACTION_MICRO__, __TICKS_BASED_FRACTION_MILLI__, __TICKS_BASED_FRACTION_NANO__, __TICKS_BASED_FRACTION_TICKS__, __TICKS_BASED_TOTAL_HOURS__, __TICKS_BASED_TOTAL_MINUTES__, __TICKS_BASED_TOTAL_SECONDS__, 10);
	if (Result != 0)
		return Result;
	if (TicksBased.ToString() != "__TICKS_BASED_DEFAULT_STRING__")
		return 18;

	FTimespan Whole(1, 2, 3, 4);
	Result = VerifyTimespanValue(Whole, int64(__WHOLE_TICKS__), __WHOLE_DAYS__, __WHOLE_HOURS__, __WHOLE_MINUTES__, __WHOLE_SECONDS__, __WHOLE_FRACTION_MICRO__, __WHOLE_FRACTION_MILLI__, __WHOLE_FRACTION_NANO__, __WHOLE_FRACTION_TICKS__, __WHOLE_TOTAL_HOURS__, __WHOLE_TOTAL_MINUTES__, __WHOLE_TOTAL_SECONDS__, 20);
	if (Result != 0)
		return Result;

	FTimespan Detailed(1, 2, 3, 4, 500000000);
	Result = VerifyTimespanValue(Detailed, int64(__DETAILED_TICKS__), __DETAILED_DAYS__, __DETAILED_HOURS__, __DETAILED_MINUTES__, __DETAILED_SECONDS__, __DETAILED_FRACTION_MICRO__, __DETAILED_FRACTION_MILLI__, __DETAILED_FRACTION_NANO__, __DETAILED_FRACTION_TICKS__, __DETAILED_TOTAL_HOURS__, __DETAILED_TOTAL_MINUTES__, __DETAILED_TOTAL_SECONDS__, 30);
	if (Result != 0)
		return Result;
	if (Detailed.ToString() != "__DETAILED_DEFAULT_STRING__")
		return 38;
	if (Detailed.ToString("__DETAILED_FORMAT__") != "__DETAILED_FORMATTED_STRING__")
		return 39;

	const FTimespan Divisor = FTimespan::FromMinutes(30.0);
	const FTimespan Dividend = FTimespan::FromMinutes(95.0);
	FTimespan NegativeDividend = -Dividend;
	Result = VerifyTimespanValue(NegativeDividend.GetDuration(), int64(__NEGATIVE_DURATION_TICKS__), __NEGATIVE_DURATION_DAYS__, __NEGATIVE_DURATION_HOURS__, __NEGATIVE_DURATION_MINUTES__, __NEGATIVE_DURATION_SECONDS__, __NEGATIVE_DURATION_FRACTION_MICRO__, __NEGATIVE_DURATION_FRACTION_MILLI__, __NEGATIVE_DURATION_FRACTION_NANO__, __NEGATIVE_DURATION_FRACTION_TICKS__, __NEGATIVE_DURATION_TOTAL_HOURS__, __NEGATIVE_DURATION_TOTAL_MINUTES__, __NEGATIVE_DURATION_TOTAL_SECONDS__, 40);
	if (Result != 0)
		return Result;
	if (!NearlyEqual(FTimespan::Ratio(Dividend, Divisor), __RATIO__, 0.000000001))
		return 50;

	Result = VerifyTimespanValue(Dividend % Divisor, int64(__MOD_RESULT_TICKS__), __MOD_RESULT_DAYS__, __MOD_RESULT_HOURS__, __MOD_RESULT_MINUTES__, __MOD_RESULT_SECONDS__, __MOD_RESULT_FRACTION_MICRO__, __MOD_RESULT_FRACTION_MILLI__, __MOD_RESULT_FRACTION_NANO__, __MOD_RESULT_FRACTION_TICKS__, __MOD_RESULT_TOTAL_HOURS__, __MOD_RESULT_TOTAL_MINUTES__, __MOD_RESULT_TOTAL_SECONDS__, 60);
	if (Result != 0)
		return Result;

	FTimespan Mutable = FTimespan::FromMinutes(10.0);
	Mutable += FTimespan::FromSeconds(45.0);
	Result = VerifyTimespanValue(Mutable, int64(__MUTABLE_AFTER_ADD_TICKS__), __MUTABLE_AFTER_ADD_DAYS__, __MUTABLE_AFTER_ADD_HOURS__, __MUTABLE_AFTER_ADD_MINUTES__, __MUTABLE_AFTER_ADD_SECONDS__, __MUTABLE_AFTER_ADD_FRACTION_MICRO__, __MUTABLE_AFTER_ADD_FRACTION_MILLI__, __MUTABLE_AFTER_ADD_FRACTION_NANO__, __MUTABLE_AFTER_ADD_FRACTION_TICKS__, __MUTABLE_AFTER_ADD_TOTAL_HOURS__, __MUTABLE_AFTER_ADD_TOTAL_MINUTES__, __MUTABLE_AFTER_ADD_TOTAL_SECONDS__, 70);
	if (Result != 0)
		return Result;

	Mutable -= FTimespan::FromSeconds(15.0);
	Result = VerifyTimespanValue(Mutable, int64(__MUTABLE_AFTER_SUB_TICKS__), __MUTABLE_AFTER_SUB_DAYS__, __MUTABLE_AFTER_SUB_HOURS__, __MUTABLE_AFTER_SUB_MINUTES__, __MUTABLE_AFTER_SUB_SECONDS__, __MUTABLE_AFTER_SUB_FRACTION_MICRO__, __MUTABLE_AFTER_SUB_FRACTION_MILLI__, __MUTABLE_AFTER_SUB_FRACTION_NANO__, __MUTABLE_AFTER_SUB_FRACTION_TICKS__, __MUTABLE_AFTER_SUB_TOTAL_HOURS__, __MUTABLE_AFTER_SUB_TOTAL_MINUTES__, __MUTABLE_AFTER_SUB_TOTAL_SECONDS__, 80);
	if (Result != 0)
		return Result;

	Mutable *= 2.0;
	Result = VerifyTimespanValue(Mutable, int64(__MUTABLE_AFTER_MUL_TICKS__), __MUTABLE_AFTER_MUL_DAYS__, __MUTABLE_AFTER_MUL_HOURS__, __MUTABLE_AFTER_MUL_MINUTES__, __MUTABLE_AFTER_MUL_SECONDS__, __MUTABLE_AFTER_MUL_FRACTION_MICRO__, __MUTABLE_AFTER_MUL_FRACTION_MILLI__, __MUTABLE_AFTER_MUL_FRACTION_NANO__, __MUTABLE_AFTER_MUL_FRACTION_TICKS__, __MUTABLE_AFTER_MUL_TOTAL_HOURS__, __MUTABLE_AFTER_MUL_TOTAL_MINUTES__, __MUTABLE_AFTER_MUL_TOTAL_SECONDS__, 90);
	if (Result != 0)
		return Result;

	Mutable /= 4.0;
	Result = VerifyTimespanValue(Mutable, int64(__MUTABLE_AFTER_DIV_TICKS__), __MUTABLE_AFTER_DIV_DAYS__, __MUTABLE_AFTER_DIV_HOURS__, __MUTABLE_AFTER_DIV_MINUTES__, __MUTABLE_AFTER_DIV_SECONDS__, __MUTABLE_AFTER_DIV_FRACTION_MICRO__, __MUTABLE_AFTER_DIV_FRACTION_MILLI__, __MUTABLE_AFTER_DIV_FRACTION_NANO__, __MUTABLE_AFTER_DIV_FRACTION_TICKS__, __MUTABLE_AFTER_DIV_TOTAL_HOURS__, __MUTABLE_AFTER_DIV_TOTAL_MINUTES__, __MUTABLE_AFTER_DIV_TOTAL_SECONDS__, 100);
	if (Result != 0)
		return Result;

	Mutable %= FTimespan::FromMinutes(3.0);
	Result = VerifyTimespanValue(Mutable, int64(__MUTABLE_AFTER_MOD_TICKS__), __MUTABLE_AFTER_MOD_DAYS__, __MUTABLE_AFTER_MOD_HOURS__, __MUTABLE_AFTER_MOD_MINUTES__, __MUTABLE_AFTER_MOD_SECONDS__, __MUTABLE_AFTER_MOD_FRACTION_MICRO__, __MUTABLE_AFTER_MOD_FRACTION_MILLI__, __MUTABLE_AFTER_MOD_FRACTION_NANO__, __MUTABLE_AFTER_MOD_FRACTION_TICKS__, __MUTABLE_AFTER_MOD_TOTAL_HOURS__, __MUTABLE_AFTER_MOD_TOTAL_MINUTES__, __MUTABLE_AFTER_MOD_TOTAL_SECONDS__, 110);
	if (Result != 0)
		return Result;

	if (FTimespan::MaxValue().opCmp(FTimespan::MinValue()) != __MAX_CMP_MIN__)
		return 120;
	if (FTimespan::MinValue().opCmp(FTimespan::MaxValue()) != -__MAX_CMP_MIN__)
		return 121;

	return 1;
}
)");

		ReplaceToken(ScriptSource, TEXT("__DETAILED_FORMAT__"), Baselines.DetailedFormat.ReplaceCharWithEscapedChar());
		ReplaceTimespanTokens(ScriptSource, TEXT("TICKS_BASED"), Baselines.TicksBased);
		ReplaceTimespanTokens(ScriptSource, TEXT("WHOLE"), Baselines.Whole);
		ReplaceTimespanTokens(ScriptSource, TEXT("DETAILED"), Baselines.Detailed);
		ReplaceTimespanTokens(ScriptSource, TEXT("NEGATIVE_DURATION"), Baselines.NegativeDuration);
		ReplaceTimespanTokens(ScriptSource, TEXT("MOD_RESULT"), Baselines.ModResult);
		ReplaceTimespanTokens(ScriptSource, TEXT("MUTABLE_AFTER_ADD"), Baselines.MutableAfterAdd);
		ReplaceTimespanTokens(ScriptSource, TEXT("MUTABLE_AFTER_SUB"), Baselines.MutableAfterSub);
		ReplaceTimespanTokens(ScriptSource, TEXT("MUTABLE_AFTER_MUL"), Baselines.MutableAfterMul);
		ReplaceTimespanTokens(ScriptSource, TEXT("MUTABLE_AFTER_DIV"), Baselines.MutableAfterDiv);
		ReplaceTimespanTokens(ScriptSource, TEXT("MUTABLE_AFTER_MOD"), Baselines.MutableAfterMod);
		ReplaceToken(ScriptSource, TEXT("__RATIO__"), Baselines.Ratio);
		ReplaceToken(ScriptSource, TEXT("__MAX_CMP_MIN__"), Baselines.MaxCmpMin);

		return ScriptSource;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptTimespanBindingsTests_Private;

bool FAngelscriptTimespanAdvancedCompatBindingsTest::RunTest(const FString& Parameters)
{
	const FTimespanBindingsBaselines Baselines = BuildBaselines();
	if (!TestEqual(TEXT("Native FTimespan max/min ordering baseline should remain positive"), Baselines.MaxCmpMin, 1))
	{
		return false;
	}

	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASTimespanAdvancedCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		TimespanBindingsModuleName,
		BuildScriptSource(Baselines));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("Timespan bindings should match native ctor, fraction, operator, ratio, min/max and formatting semantics"),
		Result,
		1);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
