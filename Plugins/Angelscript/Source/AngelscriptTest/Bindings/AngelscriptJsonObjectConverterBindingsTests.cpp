#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptJsonObjectConverterRoundTripBindingsTest,
	"Angelscript.TestModule.Bindings.JsonObjectConverterRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptJsonObjectConverterErrorPathBindingsTest,
	"Angelscript.TestModule.Bindings.JsonObjectConverterErrorPaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptJsonObjectConverterBindingsTests_Private
{
	static constexpr ANSICHAR JsonObjectConverterRoundTripModuleName[] = "ASJsonObjectConverterRoundTrip";
	static constexpr ANSICHAR JsonObjectConverterErrorPathModuleName[] = "ASJsonObjectConverterErrorPaths";
}

using namespace AngelscriptTest_Bindings_AngelscriptJsonObjectConverterBindingsTests_Private;

bool FAngelscriptJsonObjectConverterRoundTripBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASJsonObjectConverterRoundTrip"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		JsonObjectConverterRoundTripModuleName,
		TEXT(R"(
int Entry()
{
	const FVector Original = FVector(1.0, 2.0, 3.0);
	FString Json;
	if (!FJsonObjectConverter::UStructToJsonObjectString(Original, Json, 0, 0, 0, false))
		return 10;
	if (Json.IsEmpty())
		return 20;

	FVector Parsed;
	if (!FJsonObjectConverter::JsonObjectStringToUStruct(Json, Parsed, 0, 0))
		return 30;
	if (!Parsed.Equals(Original))
		return 40;

	const FRotator ExtraRotation = FRotator(10.0, 20.0, 30.0);
	if (!FJsonObjectConverter::AppendUStructToJsonObjectString(ExtraRotation, Json, 0, 0, 0, false))
		return 50;
	if (!Json.Contains("\"X\"") || !Json.Contains("\"Y\"") || !Json.Contains("\"Z\""))
		return 60;
	if (!Json.Contains("\"Pitch\"") || !Json.Contains("\"Yaw\"") || !Json.Contains("\"Roll\""))
		return 70;

	FJsonObject Appended = Json::ParseString(Json);
	if (!Appended.IsValid())
		return 80;
	if (Appended.GetNumberField("X") != 1.0 || Appended.GetNumberField("Y") != 2.0 || Appended.GetNumberField("Z") != 3.0)
		return 90;
	if (Appended.GetNumberField("Pitch") != 10.0 || Appended.GetNumberField("Yaw") != 20.0 || Appended.GetNumberField("Roll") != 30.0)
		return 100;

	return 1;
}
)"));
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
		TEXT("Json object converter bindings should round-trip USTRUCT values and append fields into a valid JSON object"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptJsonObjectConverterErrorPathBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASJsonObjectConverterErrorPaths"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		JsonObjectConverterErrorPathModuleName,
		TEXT(R"(
int Entry()
{
	int PlainValue = 7;
	FString Json = "Seed";
	if (FJsonObjectConverter::UStructToJsonObjectString(PlainValue, Json, 0, 0, 0, false))
		return 10;
	if (Json != "Seed")
		return 20;

	FVector Parsed = FVector(9.0, 9.0, 9.0);
	if (FJsonObjectConverter::JsonObjectStringToUStruct("{", Parsed, 0, 0))
		return 30;
	if (!Parsed.Equals(FVector(9.0, 9.0, 9.0)))
		return 40;

	return 1;
}
)"));
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
		TEXT("Json object converter bindings should fail closed for non-USTRUCT inputs and malformed JSON without mutating output sentinels"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
