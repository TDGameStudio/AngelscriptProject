/**
 * UObject flag mutation: NewObject's transient flag, SetTransactional turning a
 * flag on, and setting the same flag on and then off again.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UObjectFlagMutationAndTransientState
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.UObjectFlagMutationAndTransientState
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::UObjectFlagMutationAndTransientState
 * @Provenance sha256=a2434d805e3250404cee96c205cee20f0f510f94258a2864f8c19c63df7a070e; lines 1047-1077.
 * @Provenance Oracle: ScriptTransientMatched=true; TransientObject/TransactionalObject/ClearedTransactionalObject readable.
 * @Provenance Extra: objects null and flag false. FixtureIsolated. NewObject(..., true) sets transient.
 */

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

	/**
	 * Creates the three objects with their flag configurations.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handles and flag record the outcome
	 */
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

	/**
	 * Observe that a locally constructed actor holds no objects.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three handles are null and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool UObjectFlagsDefaultEmpty()
	{
		if (TransientObject != nullptr)
		{
			return false;
		}

		if (TransactionalObject != nullptr)
		{
			return false;
		}

		if (ClearedTransactionalObject != nullptr)
		{
			return false;
		}

		return !ScriptTransientMatched;
	}
}
