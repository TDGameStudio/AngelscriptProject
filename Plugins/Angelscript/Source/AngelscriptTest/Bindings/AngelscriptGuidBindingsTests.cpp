#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGuidParseFailureAndIndexCompatBindingsTest,
	"Angelscript.TestModule.Bindings.GuidParseFailureAndIndexCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptGuidBindingsTests_Private
{
	static constexpr ANSICHAR GuidBindingsModuleName[] = "ASGuidParseFailureAndIndexCompat";

	struct FGuidBindingsBaselines
	{
		FGuid ExplicitGuid;
		FGuid SentinelGuid;
		FString DigitsWithHyphens;
		FString Digits;
		FString InvalidInput;
	};

	FGuidBindingsBaselines BuildBaselines()
	{
		FGuidBindingsBaselines Baselines;
		Baselines.ExplicitGuid = FGuid(1, 2, 3, 4);
		Baselines.SentinelGuid = FGuid(91, 92, 93, 94);
		Baselines.DigitsWithHyphens = Baselines.ExplicitGuid.ToString(EGuidFormats::DigitsWithHyphens);
		Baselines.Digits = Baselines.ExplicitGuid.ToString(EGuidFormats::Digits);
		Baselines.InvalidInput = TEXT("not-a-guid");
		return Baselines;
	}

	FString ToScriptUIntLiteral(const uint32 Value)
	{
		return FString::Printf(TEXT("%u"), Value);
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const FString& Replacement)
	{
		ScriptSource.ReplaceInline(Token, *Replacement, ESearchCase::CaseSensitive);
	}

	void ReplaceToken(FString& ScriptSource, const TCHAR* Token, const uint32 Replacement)
	{
		ReplaceToken(ScriptSource, Token, ToScriptUIntLiteral(Replacement));
	}

	void ReplaceGuidTokens(FString& ScriptSource, const TCHAR* Prefix, const FGuid& Value)
	{
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_A__"), Prefix), Value[0]);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_B__"), Prefix), Value[1]);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_C__"), Prefix), Value[2]);
		ReplaceToken(ScriptSource, *FString::Printf(TEXT("__%s_D__"), Prefix), Value[3]);
	}

	FString BuildScriptSource(const FGuidBindingsBaselines& Baselines, const uint32 ExpectedLastSlot)
	{
		FString ScriptSource = TEXT(R"(
int VerifyGuidSlots(FGuid Value, uint ExpectedA, uint ExpectedB, uint ExpectedC, uint ExpectedD, int FailureBase)
{
	if (Value[0] != ExpectedA)
		return FailureBase + 0;
	if (Value[1] != ExpectedB)
		return FailureBase + 1;
	if (Value[2] != ExpectedC)
		return FailureBase + 2;
	if (Value[3] != ExpectedD)
		return FailureBase + 3;

	return 0;
}

int VerifyGuidMatches(FGuid Observed, FGuid Expected, int FailureBase)
{
	if (!(Observed == Expected))
		return FailureBase + 0;
	if (Observed.opCmp(Expected) != 0)
		return FailureBase + 1;

	const int SlotResult = VerifyGuidSlots(Observed, Expected[0], Expected[1], Expected[2], Expected[3], FailureBase + 2);
	if (SlotResult != 0)
		return SlotResult;

	return 0;
}

int Entry()
{
	const FGuid ExplicitGuid(__GUID_A__, __GUID_B__, __GUID_C__, __GUID_D__);
	const FGuid SentinelGuid(__SENTINEL_A__, __SENTINEL_B__, __SENTINEL_C__, __SENTINEL_D__);

	if (!(ExplicitGuid.ToString(EGuidFormats::DigitsWithHyphens) == "__GUID_WITH_HYPHENS__"))
		return 10;
	if (!(ExplicitGuid.ToString(EGuidFormats::Digits) == "__GUID_DIGITS__"))
		return 11;

	int Result = VerifyGuidSlots(ExplicitGuid, __GUID_A__, __GUID_B__, __GUID_C__, __GUID_D_EXPECTED__, 20);
	if (Result != 0)
		return Result;

	FGuid ParsedHyphens = SentinelGuid;
	if (!FGuid::Parse("__GUID_WITH_HYPHENS__", ParsedHyphens))
		return 30;
	Result = VerifyGuidMatches(ParsedHyphens, ExplicitGuid, 31);
	if (Result != 0)
		return Result;

	FGuid ParsedDigits = SentinelGuid;
	if (!FGuid::Parse("__GUID_DIGITS__", ParsedDigits))
		return 40;
	Result = VerifyGuidMatches(ParsedDigits, ExplicitGuid, 41);
	if (Result != 0)
		return Result;

	FGuid ParsedExactHyphens = SentinelGuid;
	if (!FGuid::ParseExact("__GUID_WITH_HYPHENS__", EGuidFormats::DigitsWithHyphens, ParsedExactHyphens))
		return 50;
	Result = VerifyGuidMatches(ParsedExactHyphens, ExplicitGuid, 51);
	if (Result != 0)
		return Result;

	FGuid ParsedExactDigits = SentinelGuid;
	if (!FGuid::ParseExact("__GUID_DIGITS__", EGuidFormats::Digits, ParsedExactDigits))
		return 60;
	Result = VerifyGuidMatches(ParsedExactDigits, ExplicitGuid, 61);
	if (Result != 0)
		return Result;

	FGuid WrongFormat = SentinelGuid;
	if (FGuid::ParseExact("__GUID_WITH_HYPHENS__", EGuidFormats::Digits, WrongFormat))
		return 70;
	Result = VerifyGuidMatches(WrongFormat, SentinelGuid, 71);
	if (Result != 0)
		return Result;

	FGuid InvalidParsed = SentinelGuid;
	if (FGuid::Parse("__INVALID_GUID__", InvalidParsed))
		return 80;
	Result = VerifyGuidMatches(InvalidParsed, SentinelGuid, 81);
	if (Result != 0)
		return Result;

	const FGuid FromHyphenString("__GUID_WITH_HYPHENS__");
	Result = VerifyGuidMatches(FromHyphenString, ExplicitGuid, 90);
	if (Result != 0)
		return Result;

	const FGuid FromDigitsString("__GUID_DIGITS__");
	Result = VerifyGuidMatches(FromDigitsString, ExplicitGuid, 100);
	if (Result != 0)
		return Result;

	return 1;
}
)");

		ReplaceGuidTokens(ScriptSource, TEXT("GUID"), Baselines.ExplicitGuid);
		ReplaceGuidTokens(ScriptSource, TEXT("SENTINEL"), Baselines.SentinelGuid);
		ReplaceToken(ScriptSource, TEXT("__GUID_WITH_HYPHENS__"), Baselines.DigitsWithHyphens.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, TEXT("__GUID_DIGITS__"), Baselines.Digits.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, TEXT("__INVALID_GUID__"), Baselines.InvalidInput.ReplaceCharWithEscapedChar());
		ReplaceToken(ScriptSource, TEXT("__GUID_D_EXPECTED__"), ExpectedLastSlot);
		return ScriptSource;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptGuidBindingsTests_Private;

bool FAngelscriptGuidParseFailureAndIndexCompatBindingsTest::RunTest(const FString& Parameters)
{
	const FGuidBindingsBaselines Baselines = BuildBaselines();
	TestTrue(TEXT("Native hyphenated guid string should not be empty"), !Baselines.DigitsWithHyphens.IsEmpty());
	TestTrue(TEXT("Native digits guid string should not be empty"), !Baselines.Digits.IsEmpty());

	FGuid NativeParsed = Baselines.SentinelGuid;
	TestTrue(TEXT("Native Parse should accept DigitsWithHyphens"), FGuid::Parse(Baselines.DigitsWithHyphens, NativeParsed));
	TestTrue(TEXT("Native Parse should preserve explicit guid value"), NativeParsed == Baselines.ExplicitGuid);

	NativeParsed = Baselines.SentinelGuid;
	TestTrue(TEXT("Native Parse should accept Digits"), FGuid::Parse(Baselines.Digits, NativeParsed));
	TestTrue(TEXT("Native Parse digits should preserve explicit guid value"), NativeParsed == Baselines.ExplicitGuid);

	NativeParsed = Baselines.SentinelGuid;
	TestTrue(TEXT("Native ParseExact should accept DigitsWithHyphens"), FGuid::ParseExact(Baselines.DigitsWithHyphens, EGuidFormats::DigitsWithHyphens, NativeParsed));
	TestTrue(TEXT("Native ParseExact hyphenated should preserve explicit guid value"), NativeParsed == Baselines.ExplicitGuid);

	NativeParsed = Baselines.SentinelGuid;
	TestTrue(TEXT("Native ParseExact should accept Digits"), FGuid::ParseExact(Baselines.Digits, EGuidFormats::Digits, NativeParsed));
	TestTrue(TEXT("Native ParseExact digits should preserve explicit guid value"), NativeParsed == Baselines.ExplicitGuid);

	NativeParsed = Baselines.SentinelGuid;
	TestFalse(TEXT("Native ParseExact should reject wrong format"), FGuid::ParseExact(Baselines.DigitsWithHyphens, EGuidFormats::Digits, NativeParsed));
	TestTrue(TEXT("Native wrong-format ParseExact should preserve sentinel value"), NativeParsed == Baselines.SentinelGuid);

	NativeParsed = Baselines.SentinelGuid;
	TestFalse(TEXT("Native Parse should reject invalid guid text"), FGuid::Parse(Baselines.InvalidInput, NativeParsed));
	TestTrue(TEXT("Native invalid Parse should preserve sentinel value"), NativeParsed == Baselines.SentinelGuid);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bResultMatched = false;
	ASTEST_BEGIN_SHARE_CLEAN

	const FString ScriptSource = BuildScriptSource(Baselines, Baselines.ExplicitGuid[3]);
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		GuidBindingsModuleName,
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

	bResultMatched = TestEqual(TEXT("Guid parse failure and index compat should match native FGuid semantics"), Result, 1);

	ASTEST_END_SHARE_CLEAN
	return bResultMatched;
}

#endif
