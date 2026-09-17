/**
 * @version v1
 * @summary UObject flag mutation: NewObject's transient flag, SetTransactional turning a flag on, and setting the same flag on and then off again.
 * @topic Language
 */
/**
 * @version root
 * @summary UObject flag mutation: NewObject's transient flag, SetTransactional turning a flag on, and setting the same flag on and then off again.
 * @topic Baseline
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
/** @end */
