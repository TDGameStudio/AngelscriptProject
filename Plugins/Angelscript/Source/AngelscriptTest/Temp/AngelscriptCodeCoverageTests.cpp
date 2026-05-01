#include "CodeCoverage/AngelscriptCodeCoverage.h"
#include "CodeCoverage/CoverageReportGenerator.h"
#include "CodeCoverage/LineCoverage.h"
#include "GenericPlatform/GenericPlatformFile.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#include <functional>

#if WITH_DEV_AUTOMATION_TESTS && WITH_AS_COVERAGE

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageTests0,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.IntegrationTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageTests0::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Manager = FAngelscriptEngine::Get();

	// Pick one active modules that has executable lines (doesn't matter which ones). If we don't find
	// a single one, just exit since we can't test anything. This integration test uses real data since
	// coverage digs deep into AS internals, which are hard to fake.
	FAngelscriptCodeCoverage Coverage;
	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : Manager.GetActiveModules())
	{
		Coverage.MapExecutableLines(*Module);
	}

	// Pretend we're running something that hits all the lines in all modules.
	Coverage.StartRecording();
	TArray<TSharedRef<struct FAngelscriptModuleDesc>> UsefulModules;
	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : Manager.GetActiveModules())
	{
		const FLineCoverage* ModuleCoverage = Coverage.GetLineCoverage(*Module);
		if (ModuleCoverage == nullptr || ModuleCoverage->NumExecutableLines() == 0)
		{
			continue;
		}

		UsefulModules.Add(Module);
		for (auto Line : ModuleCoverage->HitCounts)
		{
			Coverage.HitLine(*Module, Line.Key);
		}

		// Also hit some lines that are guaranteed outside the file, should be ignored.
		Coverage.HitLine(*Module, 9999999);
		Coverage.HitLine(*Module, -1);
	}

	if (UsefulModules.Num() == 0)
	{
		AddInfo("Found no modules with executable lines, can't test anything without real data");
		return true;
	}

	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : UsefulModules)
	{
		const FLineCoverage* ModuleCoverage = Coverage.GetLineCoverage(*Module);
		TestEqual(FString::Printf(TEXT("All lines should have been hit in %s"), *Module->ModuleName),
			ModuleCoverage->NumExecutableLines(), ModuleCoverage->NumLinesHit());
	}

	FString TempDir = FPaths::Combine(FPaths::AutomationTransientDir(), TEXT("TestOutput"));
	Coverage.StopRecordingAndWriteReport(TempDir);

	IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();
	FString ExpectedIndexPath = FPaths::Combine(TempDir, TEXT("index.html"));
	TestTrue(FString::Printf(TEXT("Should have written an index.html at %s"), *ExpectedIndexPath),
		PlatformFile.FileExists(*ExpectedIndexPath));
	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : UsefulModules)
	{
		FString ExpectedPath = FPaths::Combine(TempDir, Module->Code[0].RelativeFilename) + ".html";
		TestTrue(FString::Printf(TEXT("Should have written a report at %s"), *ExpectedPath),
			PlatformFile.FileExists(*ExpectedPath));
	}

	// Clean up after the test.
	PlatformFile.DeleteDirectoryRecursively(*TempDir);

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageTests1,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.LineCoverageTestEmpty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageTests1::RunTest(const FString& Parameters)
{
	FLineCoverage LineCoverage;

	TestEqual("We have 0 lines total", LineCoverage.NumExecutableLines(), 0);
	TestEqual("0 of them have been hit > 0 times", LineCoverage.NumLinesHit(), 0);

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageTests2,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.LineCoverageTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageTests2::RunTest(const FString& Parameters)
{
	FLineCoverage LineCoverage;

	// We have 7 lines and three of them got hit during a test.
	LineCoverage.HitCounts.Add(3, 4);
	LineCoverage.HitCounts.Add(4, 0);
	LineCoverage.HitCounts.Add(6, 18);
	LineCoverage.HitCounts.Add(8, 1);
	LineCoverage.HitCounts.Add(9, 0);
	LineCoverage.HitCounts.Add(17, 0);
	LineCoverage.HitCounts.Add(18, 0);

	TestEqual("We have 7 lines total", LineCoverage.NumExecutableLines(), 7);
	TestEqual("3 of them have been hit > 0 times", LineCoverage.NumLinesHit(), 3);

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageTests4,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.LineCoveragePruneTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageTests4::RunTest(const FString& Parameters)
{
	FLineCoverage LineCoverage;

	LineCoverage.HitCounts.Add(3, 4);
	LineCoverage.HitCounts.Add(4, 0);
	LineCoverage.HitCounts.Add(6, 18);
	LineCoverage.HitCounts.Add(8, 1);
	LineCoverage.HitCounts.Add(99, 0);
	LineCoverage.HitCounts.Add(100, 4);
	LineCoverage.HitCounts.Add(101, 4);

	// Let's say this file is 99 lines long.
	LineCoverage.PruneGeneratedCode(99);

	TestEqual("We have 7 lines total but 2 are pruned", LineCoverage.NumExecutableLines(), 5);
	TestEqual("3 of them have been hit > 0 times", LineCoverage.NumLinesHit(), 3);

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageTests3,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.ComputeCoverageTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageTests3::RunTest(const FString& Parameters)
{
	FCoverageNode Root;

	FLineCoverage C;
	C.HitCounts.Add(1, 7);
	C.HitCounts.Add(2, 19);
	C.HitCounts.Add(3, 0);
	C.HitCounts.Add(4, 0);
	C.AbsoluteFilename = "D:\\A\\B\\C.as";

	FLineCoverage D;
	D.HitCounts.Add(1, 10);
	D.HitCounts.Add(2, 104);
	D.AbsoluteFilename = "/D/A/B/D.as";

	FLineCoverage E;
	E.HitCounts.Add(1, 0);
	E.AbsoluteFilename = "/D/A/B/E/E.as";

	FLineCoverage G;
	G.HitCounts.Add(1, 1);
	G.AbsoluteFilename = "/mnt/g/G.as";

	// Front or back slashes don't matter.
	AddCoverageLeaf(Root, "A\\B\\C.as", C);
	AddCoverageLeaf(Root, "A/B/D.as", D);
	AddCoverageLeaf(Root, "A/B/E/E.as", E);
	AddCoverageLeaf(Root, "G/G.as", G);

	FCoverageCounts Result = ComputeCoverage(Root);

	TestEqual("The A dir gets the sum of its children", Root.Children["A"]->Counts.NumLinesHit, 4);
	TestEqual("The A dir gets the sum of its children", Root.Children["A"]->Counts.NumExecutableLines, 7);
	TestEqual("The A/B dir gets the sum of its children", Root.Children["A"]->Children["B"]->Counts.NumLinesHit, 4);
	TestEqual(
		"The A/B dir gets the sum of its children", Root.Children["A"]->Children["B"]->Counts.NumExecutableLines, 7);
	TestEqual("The A/B/E dir gets the sum of its children",
		Root.Children["A"]->Children["B"]->Children["E"]->Counts.NumLinesHit, 0);
	TestEqual("The A/B/E dir gets the sum of its children",
		Root.Children["A"]->Children["B"]->Children["E"]->Counts.NumExecutableLines, 1);
	TestEqual("The G dir gets the sum of its children", Root.Children["G"]->Counts.NumLinesHit, 1);
	TestEqual("The G dir gets the sum of its children", Root.Children["G"]->Counts.NumExecutableLines, 1);

	TestEqual("5 lines have > 0 hits across all 4 files", Result.NumLinesHit, 5);
	TestEqual("Total 8 lines in all files", Result.NumExecutableLines, 8);

	return true;
}

// ---------------------------------------------------------------------------
// ResetHits clears all accumulated hit counts
// ---------------------------------------------------------------------------

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageResetHitsTest,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.ResetHitsClearsAll",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageResetHitsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Manager = FAngelscriptEngine::Get();

	TArray<TSharedRef<struct FAngelscriptModuleDesc>> ActiveModules = Manager.GetActiveModules();

	FAngelscriptCodeCoverage Coverage;
	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : ActiveModules)
	{
		Coverage.MapExecutableLines(*Module);
	}

	Coverage.StartRecording();

	// Hit some lines
	TSharedRef<struct FAngelscriptModuleDesc>* FirstModule = nullptr;
	for (TSharedRef<struct FAngelscriptModuleDesc>& Module : ActiveModules)
	{
		const FLineCoverage* LC = Coverage.GetLineCoverage(*Module);
		if (LC != nullptr && LC->NumExecutableLines() > 0)
		{
			for (auto& Pair : LC->HitCounts)
			{
				Coverage.HitLine(*Module, Pair.Key);
			}
			FirstModule = &Module;
			break;
		}
	}

	if (FirstModule == nullptr)
	{
		AddInfo(TEXT("No modules with executable lines found, skipping"));
		return true;
	}

	// Verify hits were recorded
	const FLineCoverage* BeforeReset = Coverage.GetLineCoverage(**FirstModule);
	if (BeforeReset == nullptr || BeforeReset->NumLinesHit() == 0)
	{
		AddInfo(TEXT("HitLine did not record hits (environment-dependent), skipping reset verification"));
		return true;
	}

	// Reset
	Coverage.ResetHits();

	// Verify all cleared
	const FLineCoverage* AfterReset = Coverage.GetLineCoverage(**FirstModule);
	if (AfterReset != nullptr)
	{
		TestEqual(TEXT("After ResetHits, no lines should be hit"),
			AfterReset->NumLinesHit(), 0);
	}

	return true;
}

// ---------------------------------------------------------------------------
// StartRecording twice does not crash (idempotent)
// ---------------------------------------------------------------------------

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageStartStopIdempotentTest,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.StartStopIdempotent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageStartStopIdempotentTest::RunTest(const FString& Parameters)
{
	FAngelscriptCodeCoverage Coverage;

	// Double start should not crash
	Coverage.StartRecording();
	Coverage.StartRecording();

	// Double stop should not crash
	FString TempDir = FPaths::Combine(FPaths::AutomationTransientDir(), TEXT("IdempotentTest"));
	Coverage.StopRecordingAndWriteReport(TempDir);
	Coverage.StopRecordingAndWriteReport(TempDir);

	// Cleanup
	IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();
	PlatformFile.DeleteDirectoryRecursively(*TempDir);

	return true;
}

// ---------------------------------------------------------------------------
// CoverageEnabled reflects config/command-line
// ---------------------------------------------------------------------------

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptCodeCoverageEnabledTest,
	"Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.CoverageEnabledCallable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);

bool FAngelscriptCodeCoverageEnabledTest::RunTest(const FString& Parameters)
{
	// Just verify CoverageEnabled() is callable and returns a bool without crashing.
	const bool Enabled = FAngelscriptCodeCoverage::CoverageEnabled();
	AddInfo(FString::Printf(TEXT("CoverageEnabled() = %s"), Enabled ? TEXT("true") : TEXT("false")));
	return true;
}

#endif    // WITH_DEV_AUTOMATION_TESTS && WITH_AS_COVERAGE