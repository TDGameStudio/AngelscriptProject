#include "../Shared/AngelscriptTestMacros.h"
#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Validation_AngelscriptMacroValidationTests_Private
{
	bool IsLineCommentOnly(const FString& Line)
	{
		return Line.TrimStartAndEnd().StartsWith(TEXT("//"));
	}

	bool BeginsAngelscriptRawString(const FString& Line)
	{
		return Line.Contains(TEXT("R\"AS("));
	}

	bool EndsAngelscriptRawString(const FString& Line)
	{
		return Line.Contains(TEXT(")AS\""));
	}

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

	void CollectEarlyLifecycleReturnLocations(const FString& RelativeTestRoot, TArray<FString>& OutLocations)
	{
		const FString TestRoot = FPaths::ConvertRelativePathToFull(FPaths::ProjectDir() / RelativeTestRoot);

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

			bool bInsideLifecycleBlock = false;
			bool bInsideAngelscriptRawString = false;
			FString CurrentLifecycleMacro;
			int32 CurrentLifecycleLine = INDEX_NONE;

			for (int32 LineIndex = 0; LineIndex < Lines.Num(); ++LineIndex)
			{
				const FString& Line = Lines[LineIndex];
				const FString TrimmedLine = Line.TrimStartAndEnd();

				if (bInsideAngelscriptRawString)
				{
					if (EndsAngelscriptRawString(Line))
					{
						bInsideAngelscriptRawString = false;
					}
					continue;
				}

				if (BeginsAngelscriptRawString(Line))
				{
					if (!EndsAngelscriptRawString(Line))
					{
						bInsideAngelscriptRawString = true;
					}
					continue;
				}

				if (IsLineCommentOnly(TrimmedLine))
				{
					continue;
				}

				if (TrimmedLine.StartsWith(TEXT("ASTEST_BEGIN_")))
				{
					bInsideLifecycleBlock = true;
					CurrentLifecycleMacro = TrimmedLine;
					CurrentLifecycleLine = LineIndex + 1;
					continue;
				}

				if (!bInsideLifecycleBlock)
				{
					continue;
				}

				if (TrimmedLine.StartsWith(TEXT("ASTEST_END_")))
				{
					bInsideLifecycleBlock = false;
					CurrentLifecycleMacro.Reset();
					CurrentLifecycleLine = INDEX_NONE;
					continue;
				}

				if (TrimmedLine.StartsWith(TEXT("return ")) && TrimmedLine.EndsWith(TEXT(";")))
				{
					OutLocations.Add(FString::Printf(
						TEXT("%s:%d has early lifecycle return inside %s opened at line %d"),
						*SourceFile,
						LineIndex + 1,
						*CurrentLifecycleMacro,
						CurrentLifecycleLine));
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

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptLifecycleEarlyReturnValidationTest,
	"Angelscript.TestModule.Validation.LifecycleEarlyReturn",
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

bool FAngelscriptLifecycleEarlyReturnValidationTest::RunTest(const FString& Parameters)
{
	TArray<FString> MisplacedLocations;
	CollectEarlyLifecycleReturnLocations(
		TEXT("Plugins/Angelscript/Source/AngelscriptTest/Actor"),
		MisplacedLocations);
	CollectEarlyLifecycleReturnLocations(
		TEXT("Plugins/Angelscript/Source/AngelscriptTest/Interface"),
		MisplacedLocations);

	constexpr int32 MaxReportedLocations = 20;
	for (int32 Index = 0; Index < MisplacedLocations.Num() && Index < MaxReportedLocations; ++Index)
	{
		AddError(MisplacedLocations[Index]);
	}

	if (MisplacedLocations.Num() > MaxReportedLocations)
	{
		AddError(FString::Printf(
			TEXT("Lifecycle early-return validation found %d total violations; only the first %d are listed."),
			MisplacedLocations.Num(),
			MaxReportedLocations));
	}

	return TestTrue(
		TEXT("Actor and Interface lifecycle-scoped tests should not return before ASTEST_END_*"),
		MisplacedLocations.Num() == 0);
}

#endif
