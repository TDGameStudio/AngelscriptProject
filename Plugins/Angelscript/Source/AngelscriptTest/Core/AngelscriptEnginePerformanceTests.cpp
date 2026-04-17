#include "AngelscriptEngine.h"

#include "../Shared/AngelscriptPerformanceTestUtils.h"
#include "../Shared/AngelscriptTestUtilities.h"
#include "Testing/AngelscriptBindExecutionObservation.h"

#include "HAL/PlatformFileManager.h"
#include "HAL/PlatformTime.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupPerformanceFullModeTest,
	"Angelscript.TestModule.Core.Performance.Startup.Full",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupPerformanceCloneModeTest,
	"Angelscript.TestModule.Core.Performance.Startup.Clone",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupPerformanceCreateForTestingFallbackTest,
	"Angelscript.TestModule.Core.Performance.Startup.CreateForTestingFallbackFull",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupPerformanceCreateForTestingCloneTest,
	"Angelscript.TestModule.Core.Performance.Startup.CreateForTestingClone",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Core_AngelscriptEnginePerformanceTests_Private
{
	struct FStartupPerformanceSample
	{
		double StartupTotalSeconds = 0.0;
		double BindScriptTypesSeconds = 0.0;
		double CallBindsSeconds = 0.0;
	};

	void ResetPerformanceEngineState()
	{
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
	}

	template<typename MeasureFunc>
	TArray<FStartupPerformanceSample> CollectStartupSamples(MeasureFunc&& Measure)
	{
		constexpr int32 WarmupRuns = 1;
		constexpr int32 MeasurementRuns = 3;
		for (int32 WarmupIndex = 0; WarmupIndex < WarmupRuns; ++WarmupIndex)
		{
			ResetPerformanceEngineState();
			Measure();
			ResetPerformanceEngineState();
		}

		TArray<FStartupPerformanceSample> Samples;
		for (int32 MeasurementIndex = 0; MeasurementIndex < MeasurementRuns; ++MeasurementIndex)
		{
			ResetPerformanceEngineState();
			Samples.Add(Measure());
			ResetPerformanceEngineState();
		}
		return Samples;
	}

	FString ValidateAndWriteStartupMetrics(FAutomationTestBase& Test, const FString& RunId, const FString& TestGroup, const TArray<FStartupPerformanceSample>& Samples, const TArray<FString>& Notes)
	{
		using namespace AngelscriptTestSupport;

		TArray<double> StartupTotals;
		TArray<double> BindTotals;
		TArray<double> CallBindTotals;
		for (const FStartupPerformanceSample& Sample : Samples)
		{
			StartupTotals.Add(Sample.StartupTotalSeconds);
			BindTotals.Add(Sample.BindScriptTypesSeconds);
			CallBindTotals.Add(Sample.CallBindsSeconds);
		}

		LogPerformanceMetric(TEXT("startup.total_seconds"), StartupTotals);
		LogPerformanceMetric(TEXT("startup.bind_script_types_seconds"), BindTotals);
		LogPerformanceMetric(TEXT("startup.call_binds_seconds"), CallBindTotals);

		TArray<FAngelscriptPerformanceMetric> Metrics;
		Metrics.Add({ TEXT("startup.total_seconds"), StartupTotals, ComputeMedian(StartupTotals) });
		Metrics.Add({ TEXT("startup.bind_script_types_seconds"), BindTotals, ComputeMedian(BindTotals) });
		Metrics.Add({ TEXT("startup.call_binds_seconds"), CallBindTotals, ComputeMedian(CallBindTotals) });

		const FString MetricsPath = WritePerformanceMetricsArtifact(RunId, TestGroup, Metrics, Notes);
		Test.TestTrue(TEXT("Startup performance test should write a metrics.json artifact"), FPlatformFileManager::Get().GetPlatformFile().FileExists(*MetricsPath));
		return MetricsPath;
	}

	FStartupPerformanceSample MeasureFullStartup()
	{
		FAngelscriptBindExecutionObservation::Reset();
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		const double StartTime = FPlatformTime::Seconds();
		TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
		const double TotalSeconds = FPlatformTime::Seconds() - StartTime;
		check(Engine.IsValid());
		const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
		return { TotalSeconds, Snapshot.BindScriptTypesDurationSeconds, Snapshot.CallBindsDurationSeconds };
	}

	FStartupPerformanceSample MeasureCloneStartup()
	{
		FAngelscriptBindExecutionObservation::Reset();
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
		check(SourceEngine.IsValid());
		FAngelscriptBindExecutionObservation::Reset();
		const double StartTime = FPlatformTime::Seconds();
		TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
		const double TotalSeconds = FPlatformTime::Seconds() - StartTime;
		check(CloneEngine.IsValid());
		const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
		return { TotalSeconds, Snapshot.BindScriptTypesDurationSeconds, Snapshot.CallBindsDurationSeconds };
	}

	FStartupPerformanceSample MeasureCreateForTestingFallbackStartup()
	{
		FAngelscriptBindExecutionObservation::Reset();
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		const double StartTime = FPlatformTime::Seconds();
		TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
		const double TotalSeconds = FPlatformTime::Seconds() - StartTime;
		check(Engine.IsValid());
		const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
		return { TotalSeconds, Snapshot.BindScriptTypesDurationSeconds, Snapshot.CallBindsDurationSeconds };
	}

	FStartupPerformanceSample MeasureCreateForTestingCloneStartup()
	{
		FAngelscriptBindExecutionObservation::Reset();
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
		check(SourceEngine.IsValid());
		FAngelscriptEngineScope GlobalScope(*SourceEngine);
		FAngelscriptBindExecutionObservation::Reset();
		const double StartTime = FPlatformTime::Seconds();
		TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
		const double TotalSeconds = FPlatformTime::Seconds() - StartTime;
		check(Engine.IsValid());
		const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
		return { TotalSeconds, Snapshot.BindScriptTypesDurationSeconds, Snapshot.CallBindsDurationSeconds };
	}
}

using namespace AngelscriptTest_Core_AngelscriptEnginePerformanceTests_Private;

bool FAngelscriptStartupPerformanceFullModeTest::RunTest(const FString& Parameters)
{
	const TArray<FStartupPerformanceSample> Samples = CollectStartupSamples([]() { return MeasureFullStartup(); });
	ValidateAndWriteStartupMetrics(*this, TEXT("P3_1_StartupPerformance_Full"), TEXT("Angelscript.TestModule.Core.Performance.Startup.Full"), Samples, { TEXT("Measured with fresh full-engine startup samples." )});
	return true;
}

bool FAngelscriptStartupPerformanceCloneModeTest::RunTest(const FString& Parameters)
{
	const TArray<FStartupPerformanceSample> Samples = CollectStartupSamples([]() { return MeasureCloneStartup(); });
	for (const FStartupPerformanceSample& Sample : Samples)
	{
		TestEqual(TEXT("Clone startup performance should not replay BindScriptTypes"), Sample.BindScriptTypesSeconds, 0.0);
		TestEqual(TEXT("Clone startup performance should not replay CallBinds"), Sample.CallBindsSeconds, 0.0);
	}
	ValidateAndWriteStartupMetrics(*this, TEXT("P3_1_StartupPerformance_Clone"), TEXT("Angelscript.TestModule.Core.Performance.Startup.Clone"), Samples, { TEXT("Clone samples measure shared-state adoption without startup bind replay.") });
	return true;
}

bool FAngelscriptStartupPerformanceCreateForTestingFallbackTest::RunTest(const FString& Parameters)
{
	const TArray<FStartupPerformanceSample> Samples = CollectStartupSamples([]() { return MeasureCreateForTestingFallbackStartup(); });
	ValidateAndWriteStartupMetrics(*this, TEXT("P3_1_StartupPerformance_CreateForTestingFallback"), TEXT("Angelscript.TestModule.Core.Performance.Startup.CreateForTestingFallbackFull"), Samples, { TEXT("CreateForTesting falls back to a full engine when no global source engine exists.") });
	return true;
}

bool FAngelscriptStartupPerformanceCreateForTestingCloneTest::RunTest(const FString& Parameters)
{
	const TArray<FStartupPerformanceSample> Samples = CollectStartupSamples([]() { return MeasureCreateForTestingCloneStartup(); });
	for (const FStartupPerformanceSample& Sample : Samples)
	{
		TestEqual(TEXT("CreateForTesting clone performance should not replay BindScriptTypes"), Sample.BindScriptTypesSeconds, 0.0);
		TestEqual(TEXT("CreateForTesting clone performance should not replay CallBinds"), Sample.CallBindsSeconds, 0.0);
	}
	ValidateAndWriteStartupMetrics(*this, TEXT("P3_1_StartupPerformance_CreateForTestingClone"), TEXT("Angelscript.TestModule.Core.Performance.Startup.CreateForTestingClone"), Samples, { TEXT("CreateForTesting clone samples reuse the current global source engine.") });
	return true;
}

#endif
