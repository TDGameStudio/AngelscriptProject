// Theme: Language.Syntax.EdgeCases. C++ compiles these getters then executes valid and null receivers.
// CSV SourceShape NegativeDiagnostic is the null-pointer runtime path, not a compile-fail.
// C++: AngelscriptWorldFunctionLibraryTests.cpp::WorldStreamingNullGuards
// sha256=1e836cee0419309910079bfe580ae734f38fce6b0e5609a2dc9821c4f9004e7c; lines 69-79.
// Oracle: GetStreamingLevelCount(valid world) matches native Num; GetLevelVisibleInEditor matches native;
// null World/Level throw "Null pointer access".
// Extra: comments name the null boundary; do not call null from Observe (runtime exception).
// DiagnosticOnly for the null path; functions themselves compile. Source does not own the world.

int GetStreamingLevelCount(UWorld World)
{
	return World.GetStreamingLevels().Num();
}

bool GetLevelVisibleInEditor(ULevelStreaming Level)
{
	return Level.GetShouldBeVisibleInEditor();
}

int Observe_GetStreamingLevelCount_Valid(UWorld World)
{
	return GetStreamingLevelCount(World);
}

bool Observe_GetLevelVisibleInEditor_Valid(ULevelStreaming Level)
{
	return GetLevelVisibleInEditor(Level);
}
