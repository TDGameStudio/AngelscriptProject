#include "../Shared/AngelscriptTestMacros.h"
#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Validation_AngelscriptMacroValidationTests_Private
{
	void CollectTerminalReturnBeforeLifecycleEndLocations(TArray<FString>& OutLocations)
	{
		const FString TestRoot = FPaths::ConvertRelativePathToFull(
			FPaths::ProjectDir() / TEXT("Plugins/Angelscript/Source/AngelscriptTest"));

		TArray<FString> SourceFiles;
		IFileManager::Get().FindFilesRecursive(SourceFiles, *TestRoot, TEXT("*.cpp"), true, false);

		for (const FString& SourceFile : SourceFiles)
		{
			TArray<FString> Lines;
			if (!FFileHelper::LoadFileToStringArray(Lines, *SourceFile))
			{
				OutLocations.Add(FString::Printf(TEXT("Failed to read %s"), *SourceFile));
				continue;
			}

			for (int32 LineIndex = 0; LineIndex < Lines.Num(); ++LineIndex)
			{
				const FString TrimmedLine = Lines[LineIndex].TrimStartAndEnd();
				if (!TrimmedLine.StartsWith(TEXT("ASTEST_END_")))
				{
					continue;
				}

				for (int32 PreviousLineIndex = LineIndex - 1; PreviousLineIndex >= 0; --PreviousLineIndex)
				{
					const FString PreviousTrimmedLine = Lines[PreviousLineIndex].TrimStartAndEnd();
					if (PreviousTrimmedLine.IsEmpty())
					{
						continue;
					}

					if (PreviousTrimmedLine.StartsWith(TEXT("return ")) && PreviousTrimmedLine.EndsWith(TEXT(";")))
					{
						OutLocations.Add(FString::Printf(
							TEXT("%s:%d has terminal return before %s"),
							*SourceFile,
							PreviousLineIndex + 1,
							*TrimmedLine));
					}

					break;
				}
			}
		}
	}
}

using namespace AngelscriptTest_Validation_AngelscriptMacroValidationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGlobalBindingsMacroValidationTest,
	"Angelscript.TestModule.Validation.GlobalBindingsMacro",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSharedCleanMacroValidationTest,
	"Angelscript.TestModule.Validation.SharedCleanMacro",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSharedFreshMacroValidationTest,
	"Angelscript.TestModule.Validation.SharedFreshMacro",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptLifecycleEndPlacementValidationTest,
	"Angelscript.TestModule.Validation.LifecycleEndPlacement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGlobalBindingsMacroValidationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(
		Engine,
		"ASGlobalVariableCompatMacro",
		TEXT(R"(
int Entry()
{
	if (CollisionProfile::BlockAllDynamic.Compare(FName("BlockAllDynamic")) != 0)
		return 10;

	FComponentQueryParams FreshParams;
	if (FComponentQueryParams::DefaultComponentQueryParams.ShapeCollisionMask.Bits != FreshParams.ShapeCollisionMask.Bits)
		return 20;

	FGameplayTag EmptyTagCopy = FGameplayTag::EmptyTag;
	if (EmptyTagCopy.IsValid())
		return 30;
	if (!FGameplayTagContainer::EmptyContainer.IsEmpty())
		return 40;
	if (!FGameplayTagQuery::EmptyQuery.IsEmpty())
		return 50;

	return 1;
}
		)"),
		TEXT("int Entry()"),
		Result);

	bPassed = TestEqual(TEXT("Global variable compat operations via macro should preserve bound namespace globals and defaults"), Result, 1);

	ASTEST_END_FULL
	return bPassed;
}

bool FAngelscriptSharedCleanMacroValidationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	int32 Result = 0;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ASTEST_COMPILE_RUN_INT(
		Engine,
		"ASSharedCleanMacroValidation",
		TEXT(R"(
int Entry()
{
	return 17;
}
		)"),
		TEXT("int Entry()"),
		Result);

	bPassed = TestEqual(TEXT("Shared clean lifecycle macro pair should compile and run"), Result, 17);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptSharedFreshMacroValidationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	int32 Result = 0;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ASTEST_COMPILE_RUN_INT(
		Engine,
		"ASSharedFreshMacroValidation",
		TEXT(R"(
int Entry()
{
	return 23;
}
		)"),
		TEXT("int Entry()"),
		Result);

	bPassed = TestEqual(TEXT("Shared fresh lifecycle macro pair should compile and run"), Result, 23);
	ASTEST_END_SHARE_FRESH
	return bPassed;
}

bool FAngelscriptLifecycleEndPlacementValidationTest::RunTest(const FString& Parameters)
{
	TArray<FString> MisplacedLocations;
	CollectTerminalReturnBeforeLifecycleEndLocations(MisplacedLocations);

	constexpr int32 MaxReportedLocations = 20;
	for (int32 Index = 0; Index < MisplacedLocations.Num() && Index < MaxReportedLocations; ++Index)
	{
		AddError(MisplacedLocations[Index]);
	}

	if (MisplacedLocations.Num() > MaxReportedLocations)
	{
		AddError(FString::Printf(
			TEXT("Lifecycle end placement validation found %d total violations; only the first %d are listed."),
			MisplacedLocations.Num(),
			MaxReportedLocations));
	}

	return TestTrue(
		TEXT("Terminal return should come after ASTEST_END_* so lifecycle pairing remains explicit"),
		MisplacedLocations.Num() == 0);
}

#endif
