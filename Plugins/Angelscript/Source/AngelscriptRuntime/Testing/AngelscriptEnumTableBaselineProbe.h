#pragma once

#include "CoreMinimal.h"

// =====================================================================
// FAngelscriptEnumTableBaselineProbe
//
// Phase 0 baseline measurement infrastructure for the proposed
// `Plan_UhtArtifactExpansion.md` P3.2 (UEnum direct-bind table).
//
// Purpose: collect per-bind timing inside CallBinds, internal-segment
// timing for the Bind_Enums lambda (TObjectRange filter / per-enum loop /
// FAngelscriptType::Register / lookup-table register), and per-enum-value
// statistics inside FEnumBind::FEnumElement::operator= (dedupe O(N) scan +
// RegisterEnumValue cost). Decision thresholds are documented in the
// chat-driven plan; this probe only collects evidence, it does not
// influence runtime behavior.
//
// All entry points are no-ops outside WITH_DEV_AUTOMATION_TESTS so the
// probe never reaches shipping builds. The output JSON lands at
//   Saved/Tests/p3-2-baseline/<RunId>/baseline.json
// either via the `as.P3_2.AutoDumpBaseline` cvar (auto-dump after each
// BindScriptTypes pass) or the `as.DumpP3_2Baseline [OutputDir]`
// console command (manual trigger).
// =====================================================================

#if WITH_DEV_AUTOMATION_TESTS

struct ANGELSCRIPTRUNTIME_API FAngelscriptEnumTableBaselineProbe
{
	enum class EBindEnumsSegment : int32
	{
		TObjectRangeFilter = 0,
		PerEnumLoop,
		TypeRegister,
		LookupRegister,
		Count,
	};

	// Phase breakdown for the Bind_Defaults Late+100 lambda
	// (see Plan_BindParallelization Step 1 / Step 2 / Step 3).
	// PrewarmNameArray / Phase2_Prepare / Phase2_Commit accumulate wall-clock seconds.
	// Phase2_PerWorker_Max tracks the longest single ParallelFor task.
	// Phase2_PerWorker_Sum sums all ParallelFor task durations (so we can compute
	// effective parallelism = Sum / Max and validate the speed-up).
	enum class EBindLatePhase : int32
	{
		PrewarmNameArray = 0,
		Phase2_Prepare,
		Phase2_Commit,
		Phase2_PerWorker_Max,
		Phase2_PerWorker_Sum,
		Count,
	};

	static void Reset();

	static void RecordBindTiming(FName BindName, int32 BindOrder, double DurationSeconds);

	static void RecordBindEnumsSegment(EBindEnumsSegment Segment, double DurationSeconds);
	static void RecordBindEnumsEnumProcessed(int32 ValueCount);

	static void RecordEnumValueRegister(
		const ANSICHAR* EnumName,
		double DedupeScanSeconds,
		int32 DedupeScanStrcmpCount,
		double RegisterEnumValueSeconds,
		bool bWasAlreadyRegisteredOrSkipped);

	// Phase2_PerWorker_Max uses a max-reduce; the others accumulate.
	static void RecordLatePhaseSeconds(EBindLatePhase Phase, double DurationSeconds);

	// Auto-dump driven by `as.P3_2.AutoDumpBaseline` cvar (default off).
	// Idempotent within a single capture cycle; Reset() arms the next.
	static void MaybeAutoDump();

	// Returns the absolute path of the written file, or empty string on failure.
	static FString DumpJson(const FString& OptionalOutputDir = FString());
};

// RAII helper for per-bind timing inside CallBinds.
struct ANGELSCRIPTRUNTIME_API FAngelscriptEnumTableBaselineBindScope
{
	FAngelscriptEnumTableBaselineBindScope(FName InBindName, int32 InBindOrder)
		: BindName(InBindName)
		, BindOrder(InBindOrder)
		, StartSeconds(FPlatformTime::Seconds())
	{}

	~FAngelscriptEnumTableBaselineBindScope()
	{
		FAngelscriptEnumTableBaselineProbe::RecordBindTiming(
			BindName,
			BindOrder,
			FPlatformTime::Seconds() - StartSeconds);
	}

	FName BindName;
	int32 BindOrder;
	double StartSeconds;
};

// RAII helper for Bind_Enums internal segments.
struct ANGELSCRIPTRUNTIME_API FAngelscriptEnumTableBaselineSegmentScope
{
	FAngelscriptEnumTableBaselineSegmentScope(FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment InSegment)
		: Segment(InSegment)
		, StartSeconds(FPlatformTime::Seconds())
	{}

	~FAngelscriptEnumTableBaselineSegmentScope()
	{
		FAngelscriptEnumTableBaselineProbe::RecordBindEnumsSegment(
			Segment,
			FPlatformTime::Seconds() - StartSeconds);
	}

	FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment Segment;
	double StartSeconds;
};

// RAII helper for Bind_Defaults Late+100 phase timings.
struct ANGELSCRIPTRUNTIME_API FAngelscriptBindLatePhaseScope
{
	FAngelscriptBindLatePhaseScope(FAngelscriptEnumTableBaselineProbe::EBindLatePhase InPhase)
		: Phase(InPhase)
		, StartSeconds(FPlatformTime::Seconds())
	{}

	~FAngelscriptBindLatePhaseScope()
	{
		FAngelscriptEnumTableBaselineProbe::RecordLatePhaseSeconds(
			Phase,
			FPlatformTime::Seconds() - StartSeconds);
	}

	FAngelscriptEnumTableBaselineProbe::EBindLatePhase Phase;
	double StartSeconds;
};

#define AS_BIND_PHASE_SCOPE(PhaseEnumValue) \
	FAngelscriptBindLatePhaseScope AS_BindPhaseScope_##__LINE__(FAngelscriptEnumTableBaselineProbe::PhaseEnumValue)

#endif // WITH_DEV_AUTOMATION_TESTS

#if !WITH_DEV_AUTOMATION_TESTS
// No-op fallback so production callers can use AS_BIND_PHASE_SCOPE without #if guards.
#define AS_BIND_PHASE_SCOPE(PhaseEnumValue) ((void)0)
#endif
