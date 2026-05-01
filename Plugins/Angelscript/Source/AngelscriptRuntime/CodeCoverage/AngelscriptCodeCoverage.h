#pragma once

#include "AngelscriptEngine.h"
#include "LineCoverage.h"

#if WITH_EDITOR
#include "IAutomationControllerModule.h"
#endif

class asIScriptModule;
class asCScriptFunction;

// Manages a map of FLineCoverage entries per AS module and can write out reports in HTML.
// The resulting HTML files are written out to Saved/CodeCoverage/.
struct FAngelscriptCodeCoverage
{
	static ANGELSCRIPTRUNTIME_API bool CoverageEnabled();

	// Starts recording (HitLine calls are ignored unless we're recording).
	ANGELSCRIPTRUNTIME_API void StartRecording();

	// Stops recording and writes coverage to OutputDir.
	ANGELSCRIPTRUNTIME_API void StopRecordingAndWriteReport(const FString& OutputDir);

	// Adds the .as module to our internal coverage map. This must be done before trying
	// to record line hits in it.
	ANGELSCRIPTRUNTIME_API void MapExecutableLines(FAngelscriptModuleDesc& Module);

	// Call when the line in the given file has been executed.
	ANGELSCRIPTRUNTIME_API void HitLine(FAngelscriptModuleDesc& Module, int Line);

	// Retrieves what we got so far on a given module.
	ANGELSCRIPTRUNTIME_API const FLineCoverage* GetLineCoverage(FAngelscriptModuleDesc& Module) const;

	// Hooks up StartRecording and StopRecordingAndWriteReport so we reset coverage
	// between test runs and writes a report at the end. This must be called post
	// engine init since the  automation controller module must be loaded. You don't
	// have to call Start/StopRecording yourself if you use this.
	//
	// A "test run" is considered to be between when the test automation controller says
	// tests have been refreshed and when the tests end.
#if WITH_EDITOR
	void AddTestFrameworkHooks();
#endif

	// Clear all line hits so far.
	ANGELSCRIPTRUNTIME_API void ResetHits();

private:
#if WITH_EDITOR
	// Starts recording when run from the test framework.
	void OnTestsStarting(EAutomationControllerModuleState::Type Type);

	// Writes a report for the case we were run from the tests.
	void OnTestsStopping();
#endif

	// Writes out the coverage results as a directory structure that matches the .as source
	// structure, with one summary .html file per source file.
	bool WriteReportHtml(const FString& OutputDir);

	// Writes summary index.html files for each dir.
	bool WriteCoverageSummaries(const FString& OutputDir) const;

	void MapFunction(asCScriptFunction* F, TMap<int, int>& HitCounts);

	bool IgnoredForCodeCoverage(const FString& AsFilePath) const;

	// Map of relative filename to coverage info.
	TMap<FString, FLineCoverage> FilesToCoverage;

	bool bRecording = false;
};
