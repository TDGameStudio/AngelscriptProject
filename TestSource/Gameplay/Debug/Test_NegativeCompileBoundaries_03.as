// Theme: Gameplay.Debug. Isolated compile-fail: nested containers as error payload.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
// Expected diagnostic: Containers cannot be nested in other containers.
// DiagnosticOnly. Do not flatten Details.

class FCoverageErrorPayload
{
	TArray<TMap<int, FString>> Details;
}
