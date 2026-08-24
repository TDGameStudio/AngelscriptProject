// Theme: Definitions.UClass. Positive script-only class plus fallback vs explicit DisplayName.
// C++: AngelscriptCoverageUClassTests.cpp::UClassScriptOnlyAndDisplayNameMetadata
// Oracle: plain script class still publishes a UClass with non-empty DisplayName;
// explicit DisplayName="Coverage Explicit Display Object".
// Extra: FCoverageUClassPlainScriptState Value default 5, zero boundary, copy independence. DefaultSafe.

class FCoverageUClassPlainScriptState
{
	int Value = 5;
}

UCLASS()
class UCoverageUClassDefaultDisplayNameObject : UObject
{
}

UCLASS(meta=(DisplayName="Coverage Explicit Display Object"))
class UCoverageUClassExplicitDisplayNameObject : UObject
{
}

int Observe_PlainScriptState_DefaultValue()
{
	FCoverageUClassPlainScriptState State;
	return State.Value;
}

int Observe_PlainScriptState_ZeroBoundary()
{
	FCoverageUClassPlainScriptState State;
	State.Value = 0;
	return State.Value;
}

bool Observe_PlainScriptState_CopyIndependence()
{
	FCoverageUClassPlainScriptState First;
	FCoverageUClassPlainScriptState Second;
	First.Value = 9;
	return First.Value == 9 && Second.Value == 5;
}

bool Observe_DefaultDisplayName_EmptyDefaultIsNull()
{
	UCoverageUClassDefaultDisplayNameObject Obj;
	return Obj == nullptr;
}

bool Observe_ExplicitDisplayName_EmptyDefaultIsNull()
{
	UCoverageUClassExplicitDisplayNameObject Obj;
	return Obj == nullptr;
}
