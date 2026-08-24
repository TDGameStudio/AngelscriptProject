// Theme: Language.Syntax.EdgeCases. WorldStory NewObject RF_Transient and SetTransactional.
// C++: AngelscriptCoverageHandleTests.cpp::UObjectFlagMutationAndTransientState
// sha256=a2434d805e3250404cee96c205cee20f0f510f94258a2864f8c19c63df7a070e; lines 1047-1077.
// Oracle: ScriptTransientMatched=true; TransientObject/TransactionalObject/ClearedTransactionalObject readable.
// Extra: objects null and flag false. FixtureIsolated. NewObject(..., true) sets transient.

UCLASS()
class ACoverageHandleUObjectFlagsActor : AActor
{
	UPROPERTY()
	UObject TransientObject;

	UPROPERTY()
	UObject TransactionalObject;

	UPROPERTY()
	UObject ClearedTransactionalObject;

	UPROPERTY()
	bool ScriptTransientMatched = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TransientObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageHandleTransientObject", true);
		ScriptTransientMatched = TransientObject != nullptr && TransientObject.IsTransient();

		TransactionalObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleTransactionalObject");
		TransactionalObject.SetTransactional(true);

		ClearedTransactionalObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleClearedTransactionalObject");
		ClearedTransactionalObject.SetTransactional(true);
		ClearedTransactionalObject.SetTransactional(false);
	}
}

bool Observe_UObjectFlags_DefaultEmpty(ACoverageHandleUObjectFlagsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UObjectFlagMutationAndTransientState setup: required Actor is null");
	}
	return Actor.TransientObject == nullptr && Actor.TransactionalObject == nullptr && Actor.ClearedTransactionalObject == nullptr && !Actor.ScriptTransientMatched;
}
