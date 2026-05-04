#include "Testing/AngelscriptEnumTableBaselineProbe.h"

#if WITH_DEV_AUTOMATION_TESTS

#include "Containers/Map.h"
#include "Dom/JsonObject.h"
#include "Dom/JsonValue.h"
#include "HAL/FileManager.h"
#include "HAL/IConsoleManager.h"
#include "HAL/PlatformTime.h"
#include "Logging/LogMacros.h"
#include "Misc/DateTime.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeLock.h"
#include "Runtime/Launch/Resources/Version.h"
#include "Serialization/JsonSerializer.h"
#include "Serialization/JsonWriter.h"

DEFINE_LOG_CATEGORY_STATIC(LogAngelscriptEnumTableBaseline, Log, All);

namespace AngelscriptEnumTableBaselineProbe_Internal
{
	FCriticalSection GMutex;

	struct FBindTimingEntry
	{
		int32 BindOrder = 0;
		int32 InvocationCount = 0;
		double TotalSeconds = 0.0;
	};
	TMap<FName, FBindTimingEntry> GBindTimings;

	double GBindEnumsSegmentSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::Count] = {};
	int32 GBindEnumsProcessedEnumCount = 0;
	int32 GBindEnumsProcessedValueCount = 0;

	struct FPerEnumStats
	{
		int32 RegisterCallCount = 0;
		int32 SkippedCount = 0;
		int32 TotalDedupeStrcmpCount = 0;
		int32 MaxDedupeScanLength = 0;
		double TotalDedupeScanSeconds = 0.0;
		double TotalRegisterEnumValueSeconds = 0.0;
	};
	TMap<FString, FPerEnumStats> GPerEnumStats;

	int32 GTotalRegisterEnumValueCallCount = 0;
	int32 GTotalSkippedCount = 0;
	int64 GTotalDedupeStrcmpCount = 0;
	double GTotalDedupeScanSeconds = 0.0;
	double GTotalRegisterEnumValueSeconds = 0.0;

	double GBindLatePhaseSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Count] = {};

	bool GAutoDumpFired = false;

	TAutoConsoleVariable<bool> CVarAutoDump(
		TEXT("as.P3_2.AutoDumpBaseline"),
		false,
		TEXT("If true, automatically dump UEnum / bind late-phase baseline JSON after the first BindScriptTypes pass. ")
		TEXT("Output: Saved/Tests/p3-2-baseline/<RunId>/baseline.json. Override via -ExecCmds=\"as.P3_2.AutoDumpBaseline 1\" for measurement runs. Default: 0."),
		ECVF_Default);

	FString FormatSegmentName(FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment Segment)
	{
		switch (Segment)
		{
			case FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::TObjectRangeFilter: return TEXT("TObjectRangeFilter");
			case FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::PerEnumLoop:        return TEXT("PerEnumLoop");
			case FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::TypeRegister:       return TEXT("TypeRegister");
			case FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::LookupRegister:     return TEXT("LookupRegister");
			default: return TEXT("Unknown");
		}
	}

	FString FormatLatePhaseName(FAngelscriptEnumTableBaselineProbe::EBindLatePhase Phase)
	{
		switch (Phase)
		{
			case FAngelscriptEnumTableBaselineProbe::EBindLatePhase::PrewarmNameArray:     return TEXT("prewarmNameArrayMs");
			case FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Phase2_Prepare:       return TEXT("phase2PrepareMs");
			case FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Phase2_Commit:        return TEXT("phase2CommitMs");
			case FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Phase2_PerWorker_Max: return TEXT("phase2PerWorkerMaxMs");
			case FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Phase2_PerWorker_Sum: return TEXT("phase2PerWorkerSumMs");
			default: return TEXT("Unknown");
		}
	}

	FString WriteJsonLocked(const FString& OptionalOutputDir)
	{
		const FString RunId = FDateTime::Now().ToString(TEXT("%Y%m%d_%H%M%S"));
		const FString ResolvedDir = OptionalOutputDir.IsEmpty()
			? FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Tests"), TEXT("p3-2-baseline"), RunId)
			: OptionalOutputDir;

		IFileManager::Get().MakeDirectory(*ResolvedDir, true);
		const FString OutputPath = FPaths::Combine(ResolvedDir, TEXT("baseline.json"));

		TSharedRef<FJsonObject> Root = MakeShared<FJsonObject>();
		Root->SetStringField(TEXT("schemaVersion"), TEXT("1.0.0"));
		Root->SetStringField(TEXT("generatedAt"), FDateTime::UtcNow().ToIso8601());
		Root->SetStringField(TEXT("engineVersion"), FString::Printf(TEXT("%d.%d.%d"), ENGINE_MAJOR_VERSION, ENGINE_MINOR_VERSION, ENGINE_PATCH_VERSION));
		Root->SetStringField(TEXT("captureKind"), TEXT("UhtArtifactExpansion.P3_2.EnumTable"));

		// ---- per-bind timings ----
		{
			TArray<TPair<FName, FBindTimingEntry>> SortedBindEntries;
			SortedBindEntries.Reserve(GBindTimings.Num());
			for (const TPair<FName, FBindTimingEntry>& Pair : GBindTimings)
			{
				SortedBindEntries.Add(Pair);
			}
			SortedBindEntries.Sort([](const TPair<FName, FBindTimingEntry>& Left, const TPair<FName, FBindTimingEntry>& Right)
			{
				return Left.Value.TotalSeconds > Right.Value.TotalSeconds;
			});

			TArray<TSharedPtr<FJsonValue>> PerBindArray;
			PerBindArray.Reserve(SortedBindEntries.Num());
			double TotalCallBindsSeconds = 0.0;
			for (const TPair<FName, FBindTimingEntry>& Pair : SortedBindEntries)
			{
				TotalCallBindsSeconds += Pair.Value.TotalSeconds;
				TSharedRef<FJsonObject> Entry = MakeShared<FJsonObject>();
				Entry->SetStringField(TEXT("bindName"), Pair.Key.ToString());
				Entry->SetNumberField(TEXT("bindOrder"), Pair.Value.BindOrder);
				Entry->SetNumberField(TEXT("invocationCount"), Pair.Value.InvocationCount);
				Entry->SetNumberField(TEXT("totalMs"), Pair.Value.TotalSeconds * 1000.0);
				PerBindArray.Add(MakeShared<FJsonValueObject>(Entry));
			}

			TSharedRef<FJsonObject> CallBinds = MakeShared<FJsonObject>();
			CallBinds->SetNumberField(TEXT("bindCount"), GBindTimings.Num());
			CallBinds->SetNumberField(TEXT("totalMs"), TotalCallBindsSeconds * 1000.0);
			CallBinds->SetArrayField(TEXT("perBindTimings"), PerBindArray);
			Root->SetObjectField(TEXT("callBinds"), CallBinds);
		}

		// ---- Bind_Enums internal segments ----
		{
			TSharedRef<FJsonObject> SegmentObject = MakeShared<FJsonObject>();
			double SegmentTotalSeconds = 0.0;
			for (int32 SegmentIndex = 0; SegmentIndex < (int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::Count; ++SegmentIndex)
			{
				const double Seconds = GBindEnumsSegmentSeconds[SegmentIndex];
				SegmentTotalSeconds += Seconds;
				SegmentObject->SetNumberField(
					FormatSegmentName(static_cast<FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment>(SegmentIndex)),
					Seconds * 1000.0);
			}

			TSharedRef<FJsonObject> BindEnums = MakeShared<FJsonObject>();
			BindEnums->SetNumberField(TEXT("processedEnumCount"), GBindEnumsProcessedEnumCount);
			BindEnums->SetNumberField(TEXT("processedValueCount"), GBindEnumsProcessedValueCount);
			BindEnums->SetNumberField(TEXT("totalSegmentMs"), SegmentTotalSeconds * 1000.0);
			BindEnums->SetObjectField(TEXT("segmentMs"), SegmentObject);
			Root->SetObjectField(TEXT("bindEnums"), BindEnums);
		}

		// ---- per-enum & global RegisterEnumValue stats ----
		{
			TArray<TPair<FString, FPerEnumStats>> SortedPerEnum;
			SortedPerEnum.Reserve(GPerEnumStats.Num());
			for (const TPair<FString, FPerEnumStats>& Pair : GPerEnumStats)
			{
				SortedPerEnum.Add(Pair);
			}
			SortedPerEnum.Sort([](const TPair<FString, FPerEnumStats>& Left, const TPair<FString, FPerEnumStats>& Right)
			{
				const double LeftTotal = Left.Value.TotalDedupeScanSeconds + Left.Value.TotalRegisterEnumValueSeconds;
				const double RightTotal = Right.Value.TotalDedupeScanSeconds + Right.Value.TotalRegisterEnumValueSeconds;
				return LeftTotal > RightTotal;
			});

			constexpr int32 TopNToWrite = 30;
			TArray<TSharedPtr<FJsonValue>> TopArray;
			TopArray.Reserve(FMath::Min(TopNToWrite, SortedPerEnum.Num()));
			for (int32 Index = 0; Index < SortedPerEnum.Num() && Index < TopNToWrite; ++Index)
			{
				const TPair<FString, FPerEnumStats>& Pair = SortedPerEnum[Index];
				TSharedRef<FJsonObject> Entry = MakeShared<FJsonObject>();
				Entry->SetStringField(TEXT("enumName"), Pair.Key);
				Entry->SetNumberField(TEXT("registerCallCount"), Pair.Value.RegisterCallCount);
				Entry->SetNumberField(TEXT("skippedCount"), Pair.Value.SkippedCount);
				Entry->SetNumberField(TEXT("totalDedupeStrcmpCount"), Pair.Value.TotalDedupeStrcmpCount);
				Entry->SetNumberField(TEXT("maxDedupeScanLength"), Pair.Value.MaxDedupeScanLength);
				Entry->SetNumberField(TEXT("totalDedupeScanMs"), Pair.Value.TotalDedupeScanSeconds * 1000.0);
				Entry->SetNumberField(TEXT("totalRegisterEnumValueMs"), Pair.Value.TotalRegisterEnumValueSeconds * 1000.0);
				TopArray.Add(MakeShared<FJsonValueObject>(Entry));
			}

			TSharedRef<FJsonObject> RegisterEnumValue = MakeShared<FJsonObject>();
			RegisterEnumValue->SetNumberField(TEXT("totalCallCount"), GTotalRegisterEnumValueCallCount);
			RegisterEnumValue->SetNumberField(TEXT("totalSkippedCount"), GTotalSkippedCount);
			RegisterEnumValue->SetNumberField(TEXT("totalDedupeStrcmpCount"), (double)GTotalDedupeStrcmpCount);
			RegisterEnumValue->SetNumberField(TEXT("totalDedupeScanMs"), GTotalDedupeScanSeconds * 1000.0);
			RegisterEnumValue->SetNumberField(TEXT("totalRegisterEnumValueMs"), GTotalRegisterEnumValueSeconds * 1000.0);
			RegisterEnumValue->SetNumberField(TEXT("uniqueEnumCount"), GPerEnumStats.Num());
			RegisterEnumValue->SetArrayField(TEXT("topPerEnum"), TopArray);
			Root->SetObjectField(TEXT("registerEnumValue"), RegisterEnumValue);
		}

		// ---- Bind_Defaults Late+100 phase breakdown ----
		{
			TSharedRef<FJsonObject> LatePhaseObject = MakeShared<FJsonObject>();
			for (int32 PhaseIndex = 0; PhaseIndex < (int32)FAngelscriptEnumTableBaselineProbe::EBindLatePhase::Count; ++PhaseIndex)
			{
				LatePhaseObject->SetNumberField(
					FormatLatePhaseName(static_cast<FAngelscriptEnumTableBaselineProbe::EBindLatePhase>(PhaseIndex)),
					GBindLatePhaseSeconds[PhaseIndex] * 1000.0);
			}
			Root->SetObjectField(TEXT("bindLatePhase"), LatePhaseObject);
		}

		// ---- decision verdict (mirrors the chat-driven thresholds) ----
		{
			const double BindEnumsTotalMs = (
				GBindEnumsSegmentSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::TObjectRangeFilter] +
				GBindEnumsSegmentSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::PerEnumLoop] +
				GBindEnumsSegmentSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::TypeRegister] +
				GBindEnumsSegmentSeconds[(int32)FAngelscriptEnumTableBaselineProbe::EBindEnumsSegment::LookupRegister]
			) * 1000.0;

			FString RouteSuggestion;
			if (BindEnumsTotalMs < 50.0)
			{
				RouteSuggestion = TEXT("Minimal");
			}
			else if (BindEnumsTotalMs < 200.0)
			{
				RouteSuggestion = TEXT("Shortcircuit");
			}
			else
			{
				RouteSuggestion = TEXT("Aggressive");
			}

			const bool bDedupeHotspot = GTotalDedupeStrcmpCount > 50000;
			if (bDedupeHotspot && RouteSuggestion != TEXT("Aggressive"))
			{
				RouteSuggestion += TEXT("+DedupeFix");
			}

			TSharedRef<FJsonObject> Verdict = MakeShared<FJsonObject>();
			Verdict->SetNumberField(TEXT("bindEnumsTotalMs"), BindEnumsTotalMs);
			Verdict->SetBoolField(TEXT("dedupeStrcmpHotspot"), bDedupeHotspot);
			Verdict->SetStringField(TEXT("suggestedRoute"), RouteSuggestion);
			Verdict->SetStringField(TEXT("thresholdsRef"),
				TEXT("Plan_UhtArtifactExpansion P3.2 Phase 0 chat-driven: <50ms Minimal, 50-200ms Shortcircuit, >=200ms Aggressive; >50000 strcmp triggers +DedupeFix"));
			Root->SetObjectField(TEXT("verdict"), Verdict);
		}

		FString JsonString;
		TSharedRef<TJsonWriter<TCHAR, TPrettyJsonPrintPolicy<TCHAR>>> JsonWriter = TJsonWriterFactory<TCHAR, TPrettyJsonPrintPolicy<TCHAR>>::Create(&JsonString, 0);
		if (!FJsonSerializer::Serialize(Root, JsonWriter))
		{
			UE_LOG(LogAngelscriptEnumTableBaseline, Error, TEXT("Failed to serialize P3.2 baseline JSON."));
			return FString();
		}

		if (!FFileHelper::SaveStringToFile(JsonString, *OutputPath, FFileHelper::EEncodingOptions::ForceUTF8WithoutBOM))
		{
			UE_LOG(LogAngelscriptEnumTableBaseline, Error, TEXT("Failed to write P3.2 baseline JSON to %s."), *OutputPath);
			return FString();
		}

		return OutputPath;
	}

	void ExecuteDumpConsoleCommand(const TArray<FString>& Args)
	{
		FString OutputDir;
		if (Args.Num() > 0)
		{
			OutputDir = Args[0].TrimQuotes();
		}

		const FString WrittenPath = FAngelscriptEnumTableBaselineProbe::DumpJson(OutputDir);
		if (WrittenPath.IsEmpty())
		{
			UE_LOG(LogAngelscriptEnumTableBaseline, Error, TEXT("as.DumpP3_2Baseline failed to write JSON output."));
			return;
		}
		UE_LOG(LogAngelscriptEnumTableBaseline, Log, TEXT("as.DumpP3_2Baseline wrote: %s"), *WrittenPath);
	}

	FAutoConsoleCommand GDumpCommand(
		TEXT("as.DumpP3_2Baseline"),
		TEXT("Dump UEnum table P3.2 baseline JSON. Optional: as.DumpP3_2Baseline [OutputDir]"),
		FConsoleCommandWithArgsDelegate::CreateStatic(&ExecuteDumpConsoleCommand));
}

void FAngelscriptEnumTableBaselineProbe::Reset()
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	FScopeLock Lock(&GMutex);
	GBindTimings.Reset();
	for (int32 Index = 0; Index < (int32)EBindEnumsSegment::Count; ++Index)
	{
		GBindEnumsSegmentSeconds[Index] = 0.0;
	}
	GBindEnumsProcessedEnumCount = 0;
	GBindEnumsProcessedValueCount = 0;
	GPerEnumStats.Reset();
	GTotalRegisterEnumValueCallCount = 0;
	GTotalSkippedCount = 0;
	GTotalDedupeStrcmpCount = 0;
	GTotalDedupeScanSeconds = 0.0;
	GTotalRegisterEnumValueSeconds = 0.0;
	for (int32 Index = 0; Index < (int32)EBindLatePhase::Count; ++Index)
	{
		GBindLatePhaseSeconds[Index] = 0.0;
	}
	GAutoDumpFired = false;
}

void FAngelscriptEnumTableBaselineProbe::RecordLatePhaseSeconds(EBindLatePhase Phase, double DurationSeconds)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	const int32 Index = (int32)Phase;
	if (Index < 0 || Index >= (int32)EBindLatePhase::Count)
	{
		return;
	}
	FScopeLock Lock(&GMutex);
	if (Phase == EBindLatePhase::Phase2_PerWorker_Max)
	{
		GBindLatePhaseSeconds[Index] = FMath::Max(GBindLatePhaseSeconds[Index], DurationSeconds);
	}
	else
	{
		GBindLatePhaseSeconds[Index] += DurationSeconds;
	}
}

void FAngelscriptEnumTableBaselineProbe::RecordBindTiming(FName BindName, int32 BindOrder, double DurationSeconds)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	FScopeLock Lock(&GMutex);
	FBindTimingEntry& Entry = GBindTimings.FindOrAdd(BindName);
	Entry.BindOrder = BindOrder;
	Entry.InvocationCount++;
	Entry.TotalSeconds += DurationSeconds;
}

void FAngelscriptEnumTableBaselineProbe::RecordBindEnumsSegment(EBindEnumsSegment Segment, double DurationSeconds)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	const int32 Index = (int32)Segment;
	if (Index < 0 || Index >= (int32)EBindEnumsSegment::Count)
	{
		return;
	}
	FScopeLock Lock(&GMutex);
	GBindEnumsSegmentSeconds[Index] += DurationSeconds;
}

void FAngelscriptEnumTableBaselineProbe::RecordBindEnumsEnumProcessed(int32 ValueCount)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	FScopeLock Lock(&GMutex);
	GBindEnumsProcessedEnumCount++;
	GBindEnumsProcessedValueCount += ValueCount;
}

void FAngelscriptEnumTableBaselineProbe::RecordEnumValueRegister(
	const ANSICHAR* EnumName,
	double DedupeScanSeconds,
	int32 DedupeScanStrcmpCount,
	double RegisterEnumValueSeconds,
	bool bWasAlreadyRegisteredOrSkipped)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	const FString Key = EnumName != nullptr ? FString(EnumName) : FString(TEXT("<unknown>"));

	FScopeLock Lock(&GMutex);
	FPerEnumStats& Stats = GPerEnumStats.FindOrAdd(Key);
	Stats.RegisterCallCount++;
	if (bWasAlreadyRegisteredOrSkipped)
	{
		Stats.SkippedCount++;
	}
	Stats.TotalDedupeStrcmpCount += DedupeScanStrcmpCount;
	Stats.MaxDedupeScanLength = FMath::Max(Stats.MaxDedupeScanLength, DedupeScanStrcmpCount);
	Stats.TotalDedupeScanSeconds += DedupeScanSeconds;
	Stats.TotalRegisterEnumValueSeconds += RegisterEnumValueSeconds;

	GTotalRegisterEnumValueCallCount++;
	if (bWasAlreadyRegisteredOrSkipped)
	{
		GTotalSkippedCount++;
	}
	GTotalDedupeStrcmpCount += DedupeScanStrcmpCount;
	GTotalDedupeScanSeconds += DedupeScanSeconds;
	GTotalRegisterEnumValueSeconds += RegisterEnumValueSeconds;
}

void FAngelscriptEnumTableBaselineProbe::MaybeAutoDump()
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	if (!CVarAutoDump.GetValueOnAnyThread())
	{
		return;
	}

	FString WrittenPath;
	{
		FScopeLock Lock(&GMutex);
		if (GAutoDumpFired)
		{
			return;
		}
		GAutoDumpFired = true;
		WrittenPath = WriteJsonLocked(FString());
	}

	if (WrittenPath.IsEmpty())
	{
		UE_LOG(LogAngelscriptEnumTableBaseline, Warning, TEXT("P3.2 baseline auto-dump did not produce a file."));
		return;
	}
	UE_LOG(LogAngelscriptEnumTableBaseline, Log, TEXT("P3.2 baseline auto-dumped to: %s"), *WrittenPath);
}

FString FAngelscriptEnumTableBaselineProbe::DumpJson(const FString& OptionalOutputDir)
{
	using namespace AngelscriptEnumTableBaselineProbe_Internal;
	FScopeLock Lock(&GMutex);
	return WriteJsonLocked(OptionalOutputDir);
}

#endif // WITH_DEV_AUTOMATION_TESTS
