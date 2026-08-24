// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so an AActor handle
// UPROPERTY currently compiles (script object references are handles, not raw pointers).
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
// UPropTN_RawPointer; lines 497-503;
// sha256=dad58ce9af3f86de94ee038d0e2d7cc5907a205403257bc5846daea7546183be.
// Oracle: Ptr default is null. Extra: null empty/default; this-assignment is the live boundary.
// FixtureIsolated.

class AUPropRawPtrActor : AActor
{
	UPROPERTY()
	AActor Ptr = nullptr;
}

bool Observe_Ptr_Nominal(AUPropRawPtrActor Actor)
{
	return Actor.Ptr == nullptr;
}

bool Observe_Ptr_EmptyDefault(AUPropRawPtrActor Actor)
{
	return Actor.Ptr == nullptr;
}

bool Observe_Ptr_AssignBoundary(AUPropRawPtrActor Actor)
{
	AActor Saved = Actor.Ptr;
	Actor.Ptr = Actor;
	bool bAssigned = Actor.Ptr != nullptr;
	Actor.Ptr = Saved;
	return bAssigned && Saved == nullptr;
}
