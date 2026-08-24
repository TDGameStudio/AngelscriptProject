// Theme: Definitions.UFunction. WorldStory NotBlueprintCallable, AuthorityOnly/Protected/Deprecated, const getter.
// C++: AngelscriptCoverageUFunctionTests.cpp::UFunctionSpecifierFlagEdges
// Oracle: HiddenAction writes StoredValue; AuthorityProtectedAction writes Value+10; ReadStoredValue returns it.
// Extra: StoredValue default 0; nullptr actor is the empty handle; HiddenAction(0) empty write.
// FixtureIsolated. Keep StoredValue name.

UCLASS()
class ACoverageUFunctionFlagEdgeActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION(NotBlueprintCallable)
	void HiddenAction(int Value)
	{
		StoredValue = Value;
	}

	UFUNCTION(BlueprintCallable, BlueprintAuthorityOnly, BlueprintProtected, meta=(DeprecatedFunction, DeprecationMessage="Use ReplacementAction"))
	void AuthorityProtectedAction(int Value)
	{
		StoredValue = Value + 10;
	}

	UFUNCTION(BlueprintCallable)
	int ReadStoredValue() const
	{
		return StoredValue;
	}
}

bool Observe_FlagEdge_EmptyDefault(ACoverageUFunctionFlagEdgeActor Actor)
{
	return Actor.ReadStoredValue() == 0 && Actor.StoredValue == 0;
}

bool Observe_FlagEdge_ZeroHiddenWrite(ACoverageUFunctionFlagEdgeActor Actor)
{
	Actor.HiddenAction(0);
	return Actor.ReadStoredValue() == 0;
}

bool Observe_FlagEdge_NullDefault()
{
	ACoverageUFunctionFlagEdgeActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_FlagEdge_AuthorityBoundary(ACoverageUFunctionFlagEdgeActor Actor)
{
	Actor.HiddenAction(5);
	bool bHidden = Actor.ReadStoredValue() == 5;
	Actor.AuthorityProtectedAction(5);
	return bHidden && Actor.ReadStoredValue() == 15 && Actor.StoredValue == 15;
}
