#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Curves/CurveFloat.h"
#include "Curves/CurveLinearColor.h"
#include "Curves/RichCurve.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptCurveFunctionLibraryTests_Private
{
	static constexpr ANSICHAR RuntimeCurveLinearColorModuleName[] = "ASRuntimeCurveLinearColorAddDefaultKey";
	static constexpr ANSICHAR RuntimeFloatCurveInstanceModuleName[] = "ASRuntimeFloatCurveInstanceSurface";

	bool SetArgAddressChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Address,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind address argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgAddress(ArgumentIndex, Address),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteIntFunctionWithAddressArg(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		void* AddressArg,
		const TCHAR* ContextLabel,
		int32& OutResult)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!SetArgAddressChecked(Test, *Context, 0, AddressArg, ContextLabel))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = static_cast<int32>(Context->GetReturnDWord());
		return true;
	}

	bool ExpectCurveKey(
		FAutomationTestBase& Test,
		const FRichCurve& Curve,
		int32 KeyIndex,
		float ExpectedTime,
		float ExpectedValue,
		const TCHAR* ChannelLabel)
	{
		if (!Test.TestTrue(
			*FString::Printf(TEXT("%s channel should contain key index %d"), ChannelLabel, KeyIndex),
			Curve.Keys.IsValidIndex(KeyIndex)))
		{
			return false;
		}

		const FRichCurveKey& Key = Curve.Keys[KeyIndex];
		const bool bTimeMatches = Test.TestTrue(
			*FString::Printf(TEXT("%s channel key %d should preserve its timestamp"), ChannelLabel, KeyIndex),
			FMath::IsNearlyEqual(Key.Time, ExpectedTime));
		const bool bValueMatches = Test.TestTrue(
			*FString::Printf(TEXT("%s channel key %d should preserve its channel value"), ChannelLabel, KeyIndex),
			FMath::IsNearlyEqual(Key.Value, ExpectedValue));
		return bTimeMatches && bValueMatches;
	}

}

using namespace AngelscriptTest_Bindings_AngelscriptCurveFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeCurveLinearColorAddDefaultKeyTest,
	"Angelscript.TestModule.FunctionLibraries.RuntimeCurveLinearColorAddDefaultKey",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptRuntimeCurveLinearColorAddDefaultKeyTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(ANSI_TO_TCHAR(RuntimeCurveLinearColorModuleName));
	};

	asIScriptModule* Module = nullptr;
	ASTEST_BUILD_MODULE(
		Engine,
		RuntimeCurveLinearColorModuleName,
		TEXT(R"(
int PopulateCurve(FRuntimeCurveLinearColor& Curve)
{
	Curve.AddDefaultKey(0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
	Curve.AddDefaultKey(2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));
	return 1;
}
)"),
		Module);

	FRuntimeCurveLinearColor Curve;
	for (int32 ChannelIndex = 0; ChannelIndex < UE_ARRAY_COUNT(Curve.ColorCurves); ++ChannelIndex)
	{
		bPassed &= TestEqual(
			*FString::Printf(TEXT("Curve channel %d should start empty"), ChannelIndex),
			Curve.ColorCurves[ChannelIndex].Keys.Num(),
			0);
	}

	int32 Result = INDEX_NONE;
	if (!ExecuteIntFunctionWithAddressArg(
		*this,
		Engine,
		*Module,
		TEXT("int PopulateCurve(FRuntimeCurveLinearColor&)"),
		&Curve,
		TEXT("PopulateCurve"),
		Result))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("RuntimeCurveLinearColor AddDefaultKey helper should execute successfully"),
		Result,
		1);

	static const TCHAR* ChannelLabels[] = { TEXT("R"), TEXT("G"), TEXT("B"), TEXT("A") };
	static const float ExpectedValues[4][2] =
	{
		{ 1.0f, 0.125f },
		{ 0.0f, 0.5f },
		{ 0.0f, 0.75f },
		{ 0.25f, 1.0f },
	};
	static const float ExpectedTimes[2] = { 0.0f, 2.5f };

	for (int32 ChannelIndex = 0; ChannelIndex < UE_ARRAY_COUNT(Curve.ColorCurves); ++ChannelIndex)
	{
		const FRichCurve& RichCurve = Curve.ColorCurves[ChannelIndex];
		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s channel should contain two keys after two AddDefaultKey calls"), ChannelLabels[ChannelIndex]),
			RichCurve.Keys.Num(),
			2);
		bPassed &= ExpectCurveKey(*this, RichCurve, 0, ExpectedTimes[0], ExpectedValues[ChannelIndex][0], ChannelLabels[ChannelIndex]);
		bPassed &= ExpectCurveKey(*this, RichCurve, 1, ExpectedTimes[1], ExpectedValues[ChannelIndex][1], ChannelLabels[ChannelIndex]);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeFloatCurveInstanceSurfaceTest,
	"Angelscript.TestModule.FunctionLibraries.RuntimeFloatCurveInstanceSurface",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptRuntimeFloatCurveInstanceSurfaceTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	UCurveFloat* CurveAsset = nullptr;
	bool bModuleCompiled = false;

	ON_SCOPE_EXIT
	{
		if (bModuleCompiled)
		{
			Engine.DiscardModule(ANSI_TO_TCHAR(RuntimeFloatCurveInstanceModuleName));
		}

		if (CurveAsset != nullptr)
		{
			CurveAsset->MarkAsGarbage();
		}
	};

	CurveAsset = NewObject<UCurveFloat>(
		GetTransientPackage(),
		MakeUniqueObjectName(GetTransientPackage(), UCurveFloat::StaticClass(), TEXT("RuntimeFloatCurveInstanceSurface")),
		RF_Transient);
	if (!TestNotNull(TEXT("RuntimeFloatCurve instance surface test should create a transient UCurveFloat"), CurveAsset))
	{
		return false;
	}

	FString Script = TEXT(R"AS(
int PopulateCurve(FRuntimeFloatCurve& RuntimeCurve)
{
	RuntimeCurve.AddDefaultKey(0.5f, 1.25f);
	RuntimeCurve.AddDefaultKey(3.0f, 9.5f);
	if (RuntimeCurve.GetNumKeys() != 2)
		return 10;

	float32 MinTime = -1.0f;
	float32 MaxTime = -1.0f;
	RuntimeCurve.GetTimeRange(MinTime, MaxTime);
	if (MinTime != 0.5f || MaxTime != 3.0f)
		return 20;

	UObject CurveObject = FindObject("__CURVE_PATH__");
	UCurveFloat CurveAsset = Cast<UCurveFloat>(CurveObject);
	if (CurveAsset == null)
		return 30;

	FCurveKeyHandle Handle = CurveAsset.AddAutoCurveKey(1.5f, 7.5f);
	if (CurveAsset.GetFloatValue(1.5f) != 7.5f)
		return 40;
	CurveAsset.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Constant, false);
	return 1;
}
)AS");
	Script.ReplaceInline(TEXT("__CURVE_PATH__"), *CurveAsset->GetPathName().ReplaceCharWithEscapedChar());

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		RuntimeFloatCurveInstanceModuleName,
		Script);
	if (Module == nullptr)
	{
		return false;
	}
	bModuleCompiled = true;

	FRuntimeFloatCurve RuntimeCurve;
	int32 Result = INDEX_NONE;
	if (!ExecuteIntFunctionWithAddressArg(
		*this,
		Engine,
		*Module,
		TEXT("int PopulateCurve(FRuntimeFloatCurve&)"),
		&RuntimeCurve,
		TEXT("PopulateCurve"),
		Result))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("RuntimeFloatCurve and UCurveFloat instance helper surface should compile and execute through instance syntax"),
		Result,
		1);

	const FRichCurve& RuntimeRichCurve = RuntimeCurve.EditorCurveData;
	bPassed &= TestEqual(
		TEXT("FRuntimeFloatCurve.AddDefaultKey instance syntax should add two keys to the runtime curve"),
		RuntimeRichCurve.Keys.Num(),
		2);
	bPassed &= ExpectCurveKey(*this, RuntimeRichCurve, 0, 0.5f, 1.25f, TEXT("RuntimeFloatCurve"));
	bPassed &= ExpectCurveKey(*this, RuntimeRichCurve, 1, 3.0f, 9.5f, TEXT("RuntimeFloatCurve"));

	float MinTime = 0.0f;
	float MaxTime = 0.0f;
	RuntimeCurve.GetRichCurveConst()->GetTimeRange(MinTime, MaxTime);
	bPassed &= TestTrue(
		TEXT("FRuntimeFloatCurve.GetTimeRange instance syntax should preserve the native time range"),
		FMath::IsNearlyEqual(MinTime, 0.5f) && FMath::IsNearlyEqual(MaxTime, 3.0f));

	if (Result == 1)
	{
		const FRichCurve& AssetCurve = CurveAsset->FloatCurve;
		const int32 AssetKeyCount = AssetCurve.Keys.Num();
		bPassed &= TestEqual(
			TEXT("UCurveFloat.AddAutoCurveKey instance syntax should add one key to the asset curve"),
			AssetKeyCount,
			1);
		if (AssetKeyCount > 0)
		{
			bPassed &= ExpectCurveKey(*this, AssetCurve, 0, 1.5f, 7.5f, TEXT("UCurveFloat"));
			bPassed &= TestEqual(
				TEXT("UCurveFloat.SetKeyInterpMode instance syntax should update the native key interpolation mode"),
				AssetCurve.Keys[0].InterpMode,
				ERichCurveInterpMode::RCIM_Constant);
		}
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
