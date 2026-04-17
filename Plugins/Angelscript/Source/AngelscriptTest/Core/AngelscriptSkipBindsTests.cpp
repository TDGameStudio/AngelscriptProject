#include "AngelscriptBinds.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptSkipBindsTests_Private
{
	struct FSkipEntryExpectation
	{
		const TCHAR* ClassName;
		const TCHAR* FunctionName;
		bool bExpectedSkipped;
	};

	struct FSkipClassExpectation
	{
		const TCHAR* ClassName;
		bool bExpectedSkipped;
	};
}

using namespace AngelscriptTest_Core_AngelscriptSkipBindsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultSkipListRegistrationTest,
	"Angelscript.TestModule.Engine.BindConfig.SkipBinds.DefaultSkipListIsRegistered",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultSkipListRegistrationTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	const FSkipEntryExpectation EntryCases[] =
	{
		{ TEXT("StaticMesh"), TEXT("GetMinLODForQualityLevels"), true },
		{ TEXT("StaticMesh"), TEXT("SetMinLODForQualityLevels"), true },
		{ TEXT("SkeletalMesh"), TEXT("GetMinLODForQualityLevels"), true },
		{ TEXT("SkeletalMesh"), TEXT("SetMinLODForQualityLevels"), true },
		{ TEXT("SourceEffectEQPreset"), TEXT("SetSettings"), true },
		{ TEXT("StaticMesh"), TEXT("BuildNanite"), false },
	};

	const FSkipClassExpectation ClassCases[] =
	{
		{ TEXT("ClothingSimulationInteractorNv"), true },
		{ TEXT("NiagaraPreviewGrid"), true },
		{ TEXT("GameplayCamerasSubsystem"), true },
		{ TEXT("AsyncAction_PerformTargeting"), true },
		{ TEXT("Actor"), false },
	};

	for (const FSkipEntryExpectation& EntryCase : EntryCases)
	{
		const bool bFirstRead = FAngelscriptBinds::CheckForSkipEntry(EntryCase.ClassName, EntryCase.FunctionName);
		const bool bSecondRead = FAngelscriptBinds::CheckForSkipEntry(EntryCase.ClassName, EntryCase.FunctionName);
		const FString EntryLabel = FString::Printf(TEXT("%s.%s"), EntryCase.ClassName, EntryCase.FunctionName);

		bPassed &= TestEqual(
			*FString::Printf(TEXT("SkipBinds default list should return the expected registration state for %s"), *EntryLabel),
			bFirstRead,
			EntryCase.bExpectedSkipped);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("SkipBinds repeated reads should keep the same result for %s"), *EntryLabel),
			bSecondRead,
			bFirstRead);
	}

	for (const FSkipClassExpectation& ClassCase : ClassCases)
	{
		const bool bFirstRead = FAngelscriptBinds::CheckForSkipClass(ClassCase.ClassName);
		const bool bSecondRead = FAngelscriptBinds::CheckForSkipClass(ClassCase.ClassName);

		bPassed &= TestEqual(
			*FString::Printf(TEXT("SkipBinds default list should return the expected registration state for class %s"), ClassCase.ClassName),
			bFirstRead,
			ClassCase.bExpectedSkipped);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("SkipBinds repeated reads should keep the same result for class %s"), ClassCase.ClassName),
			bSecondRead,
			bFirstRead);
	}

	ASTEST_END_FULL
	return bPassed;
}

#endif
