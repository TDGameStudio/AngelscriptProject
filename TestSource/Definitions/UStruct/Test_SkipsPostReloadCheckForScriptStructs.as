// Theme: Definitions.UStruct. Positive: struct-only module skips post-reload extra checks.
// C++: AngelscriptAdditionalCompileChecksTests.cpp::SkipsPostReloadCheckForScriptStructs
// Compile succeeds; generated script struct exists; PostReloadCount==0.
// Extra: default Value==19; zero; copy independence.
// DefaultSafe.

USTRUCT()
struct FAdditionalChecksStructOnlyTarget
{
	UPROPERTY()
	int Value = 19;
}

int Observe_StructOnlyTarget_DefaultValue()
{
	FAdditionalChecksStructOnlyTarget Target;
	return Target.Value;
}

int Observe_StructOnlyTarget_ZeroBoundary()
{
	FAdditionalChecksStructOnlyTarget Target;
	Target.Value = 0;
	return Target.Value;
}

bool Observe_StructOnlyTarget_CopyIndependence()
{
	FAdditionalChecksStructOnlyTarget Original;
	FAdditionalChecksStructOnlyTarget Copy = Original;
	Copy.Value = 0;
	return Original.Value == 19 && Copy.Value == 0;
}
