#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/DateTime.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDateTimeParseRoundTripCompatBindingsTest,
	"Angelscript.TestModule.Bindings.DateTimeParseRoundTripCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptDateTimeBindingsTests_Private
{
	static constexpr ANSICHAR DateTimeBindingsModuleName[] = "ASDateTimeParseRoundTripCompat";

	struct FDateTimeValueBaseline
	{
		bool bSuccess = false;
		int64 Ticks = 0;
		int32 Year = 0;
		int32 Month = 0;
		int32 Day = 0;
		int32 Hour12 = 0;
		int32 Millisecond = 0;
	};

	struct FDateTimeBindingsBaselines
	{
		FString IsoInput;
		FDateTimeValueBaseline Iso;

		FString HttpInput;
		FDateTimeValueBaseline Http;

		FString GenericInput;
		FDateTimeValueBaseline Generic;

		FString InvalidInput;
		FDateTimeValueBaseline InvalidParse;
		FDateTimeValueBaseline InvalidHttp;
		FDateTimeValueBaseline InvalidIso;

		FString ConstructedHttp;
		FString ConstructedIso;
		FString ConstructedFormatted;
		FDateTimeValueBaseline Constructed;
		FDateTimeValueBaseline ConstructedHttpRoundTrip;
		FDateTimeValueBaseline ConstructedIsoRoundTrip;
		FDateTimeValueBaseline ConstructedFormattedRoundTrip;
	};

	FDateTimeValueBaseline CaptureValueBaseline(const bool bSuccess, const FDateTime& Value)
	{
		int32 Year = INDEX_NONE;
		int32 Month = INDEX_NONE;
		int32 Day = INDEX_NONE;
		Value.GetDate(Year, Month, Day);

		FDateTimeValueBaseline Baseline;
		Baseline.bSuccess = bSuccess;
		Baseline.Ticks = Value.GetTicks();
		Baseline.Year = Year;
		Baseline.Month = Month;
		Baseline.Day = Day;
		Baseline.Hour12 = Value.GetHour12();
		Baseline.Millisecond = Value.GetMillisecond();
		return Baseline;
	}

	FString ToScriptBoolLiteral(const bool bValue)
	{
		return bValue ? TEXT("true") : TEXT("false");
	}

	FString ToScriptInt64Literal(const int64 Value)
	{
		return FString::Printf(TEXT("%lld"), static_cast<long long>(Value));
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

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const bool Replacement)
	{
		ReplaceToken(ScriptSource, Token, ToScriptBoolLiteral(Replacement));
	}

	void ReplaceValueTokens(FString& ScriptSource, const TCHAR* Prefix, const FDateTimeValueBaseline& Value)
	{
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_SUCCESS__"), Prefix), Value.bSuccess);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_TICKS__"), Prefix), Value.Ticks);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_YEAR__"), Prefix), Value.Year);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_MONTH__"), Prefix), Value.Month);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_DAY__"), Prefix), Value.Day);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_HOUR12__"), Prefix), Value.Hour12);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_MILLISECOND__"), Prefix), Value.Millisecond);
	}

	FDateTimeBindingsBaselines BuildBaselines()
	{
		FDateTimeBindingsBaselines Baselines;

		Baselines.IsoInput = TEXT("2024-12-25T14:30:15Z");
		Baselines.HttpInput = TEXT("Wed, 25 Dec 2024 14:30:15 GMT");
		Baselines.GenericInput = TEXT("2024-12-25 14:30:15.123");
		Baselines.InvalidInput = TEXT("not-a-date");

		const FDateTime Sentinel(1999, 1, 2, 3, 4, 5, 6);

		FDateTime IsoValue = Sentinel;
		Baselines.Iso = CaptureValueBaseline(FDateTime::ParseIso8601(*Baselines.IsoInput, IsoValue), IsoValue);

		FDateTime HttpValue = Sentinel;
		Baselines.Http = CaptureValueBaseline(FDateTime::ParseHttpDate(Baselines.HttpInput, HttpValue), HttpValue);

		FDateTime GenericValue = Sentinel;
		Baselines.Generic = CaptureValueBaseline(FDateTime::Parse(Baselines.GenericInput, GenericValue), GenericValue);

		FDateTime InvalidParseValue = Sentinel;
		Baselines.InvalidParse = CaptureValueBaseline(FDateTime::Parse(Baselines.InvalidInput, InvalidParseValue), InvalidParseValue);

		FDateTime InvalidHttpValue = Sentinel;
		Baselines.InvalidHttp = CaptureValueBaseline(FDateTime::ParseHttpDate(Baselines.InvalidInput, InvalidHttpValue), InvalidHttpValue);

		FDateTime InvalidIsoValue = Sentinel;
		Baselines.InvalidIso = CaptureValueBaseline(FDateTime::ParseIso8601(*Baselines.InvalidInput, InvalidIsoValue), InvalidIsoValue);

		const FDateTime ConstructedValue(2024, 12, 25, 14, 30, 15, 123);
		Baselines.Constructed = CaptureValueBaseline(true, ConstructedValue);
		Baselines.ConstructedHttp = ConstructedValue.ToHttpDate();
		Baselines.ConstructedIso = ConstructedValue.ToIso8601();
		Baselines.ConstructedFormatted = ConstructedValue.ToString(TEXT("%Y-%m-%d %H:%M:%S.%s"));

		FDateTime ConstructedHttpRoundTripValue = Sentinel;
		Baselines.ConstructedHttpRoundTrip = CaptureValueBaseline(
			FDateTime::ParseHttpDate(Baselines.ConstructedHttp, ConstructedHttpRoundTripValue),
			ConstructedHttpRoundTripValue);

		FDateTime ConstructedIsoRoundTripValue = Sentinel;
		Baselines.ConstructedIsoRoundTrip = CaptureValueBaseline(
			FDateTime::ParseIso8601(*Baselines.ConstructedIso, ConstructedIsoRoundTripValue),
			ConstructedIsoRoundTripValue);

		FDateTime ConstructedFormattedRoundTripValue = Sentinel;
		Baselines.ConstructedFormattedRoundTrip = CaptureValueBaseline(
			FDateTime::Parse(Baselines.ConstructedFormatted, ConstructedFormattedRoundTripValue),
			ConstructedFormattedRoundTripValue);

		return Baselines;
	}

	FString BuildScriptSource(const FDateTimeBindingsBaselines& Baselines)
	{
		FString ScriptSource = TEXT(R"(
int VerifyDateValue(bool ObservedSuccess, bool ExpectedSuccess, FDateTime Value, int64 ExpectedTicks, int ExpectedYear, int ExpectedMonth, int ExpectedDay, int ExpectedHour12, int ExpectedMillisecond, int FailureBase)
{
	if (ObservedSuccess != ExpectedSuccess)
		return FailureBase + 0;
	if (Value.GetTicks() != ExpectedTicks)
		return FailureBase + 1;

	int Year = -1;
	int Month = -1;
	int Day = -1;
	Value.GetDate(Year, Month, Day);
	if (Year != ExpectedYear || Month != ExpectedMonth || Day != ExpectedDay)
		return FailureBase + 2;
	if (Value.GetHour12() != ExpectedHour12)
		return FailureBase + 3;
	if (Value.GetMillisecond() != ExpectedMillisecond)
		return FailureBase + 4;

	return 0;
}

int Entry()
{
	const FDateTime InvalidSentinel(1999, 1, 2, 3, 4, 5, 6);

	FDateTime IsoParsed = FDateTime::MinValue();
	const bool bIsoParsed = FDateTime::ParseIso8601("__ISO_INPUT__", IsoParsed);
	int Result = VerifyDateValue(bIsoParsed, __ISO_SUCCESS__, IsoParsed, int64(__ISO_TICKS__), __ISO_YEAR__, __ISO_MONTH__, __ISO_DAY__, __ISO_HOUR12__, __ISO_MILLISECOND__, 10);
	if (Result != 0)
		return Result;

	FDateTime HttpParsed = FDateTime::MinValue();
	const bool bHttpParsed = FDateTime::ParseHttpDate("__HTTP_INPUT__", HttpParsed);
	Result = VerifyDateValue(bHttpParsed, __HTTP_SUCCESS__, HttpParsed, int64(__HTTP_TICKS__), __HTTP_YEAR__, __HTTP_MONTH__, __HTTP_DAY__, __HTTP_HOUR12__, __HTTP_MILLISECOND__, 20);
	if (Result != 0)
		return Result;

	FDateTime GenericParsed = FDateTime::MinValue();
	const bool bGenericParsed = FDateTime::Parse("__GENERIC_INPUT__", GenericParsed);
	Result = VerifyDateValue(bGenericParsed, __GENERIC_SUCCESS__, GenericParsed, int64(__GENERIC_TICKS__), __GENERIC_YEAR__, __GENERIC_MONTH__, __GENERIC_DAY__, __GENERIC_HOUR12__, __GENERIC_MILLISECOND__, 30);
	if (Result != 0)
		return Result;

	FDateTime InvalidParsed = InvalidSentinel;
	const bool bInvalidParsed = FDateTime::Parse("__INVALID_INPUT__", InvalidParsed);
	Result = VerifyDateValue(bInvalidParsed, __INVALID_PARSE_SUCCESS__, InvalidParsed, int64(__INVALID_PARSE_TICKS__), __INVALID_PARSE_YEAR__, __INVALID_PARSE_MONTH__, __INVALID_PARSE_DAY__, __INVALID_PARSE_HOUR12__, __INVALID_PARSE_MILLISECOND__, 40);
	if (Result != 0)
		return Result;

	FDateTime InvalidHttp = InvalidSentinel;
	const bool bInvalidHttp = FDateTime::ParseHttpDate("__INVALID_INPUT__", InvalidHttp);
	Result = VerifyDateValue(bInvalidHttp, __INVALID_HTTP_SUCCESS__, InvalidHttp, int64(__INVALID_HTTP_TICKS__), __INVALID_HTTP_YEAR__, __INVALID_HTTP_MONTH__, __INVALID_HTTP_DAY__, __INVALID_HTTP_HOUR12__, __INVALID_HTTP_MILLISECOND__, 50);
	if (Result != 0)
		return Result;

	FDateTime InvalidIso = InvalidSentinel;
	const bool bInvalidIso = FDateTime::ParseIso8601("__INVALID_INPUT__", InvalidIso);
	Result = VerifyDateValue(bInvalidIso, __INVALID_ISO_SUCCESS__, InvalidIso, int64(__INVALID_ISO_TICKS__), __INVALID_ISO_YEAR__, __INVALID_ISO_MONTH__, __INVALID_ISO_DAY__, __INVALID_ISO_HOUR12__, __INVALID_ISO_MILLISECOND__, 60);
	if (Result != 0)
		return Result;

	FDateTime Constructed(2024, 12, 25, 14, 30, 15, 123);
	if (Constructed.ToHttpDate() != "__CONSTRUCTED_HTTP__")
		return 70;
	if (Constructed.ToIso8601() != "__CONSTRUCTED_ISO__")
		return 71;
	const FString Formatted = Constructed.ToString("%Y-%m-%d %H:%M:%S.%s");
	if (Formatted != "__CONSTRUCTED_FORMATTED__")
		return 72;

	Result = VerifyDateValue(true, true, Constructed, int64(__CONSTRUCTED_TICKS__), __CONSTRUCTED_YEAR__, __CONSTRUCTED_MONTH__, __CONSTRUCTED_DAY__, __CONSTRUCTED_HOUR12__, __CONSTRUCTED_MILLISECOND__, 80);
	if (Result != 0)
		return Result;

	FDateTime ConstructedHttpRoundTrip = FDateTime::MinValue();
	const bool bConstructedHttpRoundTrip = FDateTime::ParseHttpDate(Constructed.ToHttpDate(), ConstructedHttpRoundTrip);
	Result = VerifyDateValue(bConstructedHttpRoundTrip, __CONSTRUCTED_HTTP_ROUNDTRIP_SUCCESS__, ConstructedHttpRoundTrip, int64(__CONSTRUCTED_HTTP_ROUNDTRIP_TICKS__), __CONSTRUCTED_HTTP_ROUNDTRIP_YEAR__, __CONSTRUCTED_HTTP_ROUNDTRIP_MONTH__, __CONSTRUCTED_HTTP_ROUNDTRIP_DAY__, __CONSTRUCTED_HTTP_ROUNDTRIP_HOUR12__, __CONSTRUCTED_HTTP_ROUNDTRIP_MILLISECOND__, 90);
	if (Result != 0)
		return Result;

	FDateTime ConstructedIsoRoundTrip = FDateTime::MinValue();
	const bool bConstructedIsoRoundTrip = FDateTime::ParseIso8601(Constructed.ToIso8601(), ConstructedIsoRoundTrip);
	Result = VerifyDateValue(bConstructedIsoRoundTrip, __CONSTRUCTED_ISO_ROUNDTRIP_SUCCESS__, ConstructedIsoRoundTrip, int64(__CONSTRUCTED_ISO_ROUNDTRIP_TICKS__), __CONSTRUCTED_ISO_ROUNDTRIP_YEAR__, __CONSTRUCTED_ISO_ROUNDTRIP_MONTH__, __CONSTRUCTED_ISO_ROUNDTRIP_DAY__, __CONSTRUCTED_ISO_ROUNDTRIP_HOUR12__, __CONSTRUCTED_ISO_ROUNDTRIP_MILLISECOND__, 100);
	if (Result != 0)
		return Result;

	FDateTime ConstructedFormattedRoundTrip = FDateTime::MinValue();
	const bool bConstructedFormattedRoundTrip = FDateTime::Parse(Formatted, ConstructedFormattedRoundTrip);
	Result = VerifyDateValue(bConstructedFormattedRoundTrip, __CONSTRUCTED_FORMATTED_ROUNDTRIP_SUCCESS__, ConstructedFormattedRoundTrip, int64(__CONSTRUCTED_FORMATTED_ROUNDTRIP_TICKS__), __CONSTRUCTED_FORMATTED_ROUNDTRIP_YEAR__, __CONSTRUCTED_FORMATTED_ROUNDTRIP_MONTH__, __CONSTRUCTED_FORMATTED_ROUNDTRIP_DAY__, __CONSTRUCTED_FORMATTED_ROUNDTRIP_HOUR12__, __CONSTRUCTED_FORMATTED_ROUNDTRIP_MILLISECOND__, 110);
	if (Result != 0)
		return Result;

	return 1;
}
)");

		ReplaceToken(ScriptSource, TEXT("__ISO_INPUT__"), Baselines.IsoInput.ReplaceCharWithEscapedChar());
		ReplaceValueTokens(ScriptSource, TEXT("ISO"), Baselines.Iso);

		ReplaceToken(ScriptSource, TEXT("__HTTP_INPUT__"), Baselines.HttpInput.ReplaceCharWithEscapedChar());
		ReplaceValueTokens(ScriptSource, TEXT("HTTP"), Baselines.Http);

		ReplaceToken(ScriptSource, TEXT("__GENERIC_INPUT__"), Baselines.GenericInput.ReplaceCharWithEscapedChar());
		ReplaceValueTokens(ScriptSource, TEXT("GENERIC"), Baselines.Generic);

		ReplaceToken(ScriptSource, TEXT("__INVALID_INPUT__"), Baselines.InvalidInput.ReplaceCharWithEscapedChar());
		ReplaceValueTokens(ScriptSource, TEXT("INVALID_PARSE"), Baselines.InvalidParse);
		ReplaceValueTokens(ScriptSource, TEXT("INVALID_HTTP"), Baselines.InvalidHttp);
		ReplaceValueTokens(ScriptSource, TEXT("INVALID_ISO"), Baselines.InvalidIso);

		ReplaceToken(ScriptSource, TEXT("__CONSTRUCTED_HTTP__"), Baselines.ConstructedHttp.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, TEXT("__CONSTRUCTED_ISO__"), Baselines.ConstructedIso.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, TEXT("__CONSTRUCTED_FORMATTED__"), Baselines.ConstructedFormatted.ReplaceCharWithEscapedChar());
		ReplaceValueTokens(ScriptSource, TEXT("CONSTRUCTED"), Baselines.Constructed);
		ReplaceValueTokens(ScriptSource, TEXT("CONSTRUCTED_HTTP_ROUNDTRIP"), Baselines.ConstructedHttpRoundTrip);
		ReplaceValueTokens(ScriptSource, TEXT("CONSTRUCTED_ISO_ROUNDTRIP"), Baselines.ConstructedIsoRoundTrip);
		ReplaceValueTokens(ScriptSource, TEXT("CONSTRUCTED_FORMATTED_ROUNDTRIP"), Baselines.ConstructedFormattedRoundTrip);

		return ScriptSource;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptDateTimeBindingsTests_Private;

bool FAngelscriptDateTimeParseRoundTripCompatBindingsTest::RunTest(const FString& Parameters)
{
	const FDateTimeBindingsBaselines Baselines = BuildBaselines();
	if (!TestTrue(TEXT("Native ParseIso8601 baseline should succeed for the fixed ISO-8601 sample"), Baselines.Iso.bSuccess) ||
		!TestTrue(TEXT("Native ParseHttpDate baseline should succeed for the fixed HTTP-date sample"), Baselines.Http.bSuccess) ||
		!TestTrue(TEXT("Native Parse baseline should succeed for the fixed generic date sample"), Baselines.Generic.bSuccess) ||
		!TestFalse(TEXT("Native Parse baseline should reject the invalid generic sample"), Baselines.InvalidParse.bSuccess) ||
		!TestFalse(TEXT("Native ParseHttpDate baseline should reject the invalid sample"), Baselines.InvalidHttp.bSuccess) ||
		!TestFalse(TEXT("Native ParseIso8601 baseline should reject the invalid sample"), Baselines.InvalidIso.bSuccess))
	{
		return false;
	}

	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASDateTimeParseRoundTripCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		DateTimeBindingsModuleName,
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
		TEXT("DateTime bindings should match native parse, round-trip, out-parameter, millisecond, hour12 and tick semantics"),
		Result,
		1);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
