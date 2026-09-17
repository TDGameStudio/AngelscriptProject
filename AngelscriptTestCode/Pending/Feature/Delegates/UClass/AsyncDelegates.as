/**
 * @version v1
 * @summary Soft-reference async LoadAsync harness. After four Start*Load calls, each callback count is 1; success payloads are non-null and typed; failure payloads are null; LastObjectName is "DefaultTexture". Substitutions.
 * @topic Feature
 */
/**
 * @version root
 * @summary Soft-reference async LoadAsync harness. After four Start*Load calls, each callback count is 1; success payloads are non-null and typed; failure payloads are null; LastObjectName is "DefaultTexture". Substitutions.
 * @topic Baseline
 */
UCLASS()
class USoftReferenceAsyncScriptHarness : UObject
{
	UPROPERTY()
	int ObjectSuccessCallbackCount = 0;

	UPROPERTY()
	int ObjectFailureCallbackCount = 0;

	UPROPERTY()
	int ClassSuccessCallbackCount = 0;

	UPROPERTY()
	int ClassFailureCallbackCount = 0;

	UPROPERTY()
	int bObjectSuccessWasNonNull = 0;

	UPROPERTY()
	int bObjectFailureWasNull = 0;

	UPROPERTY()
	int bClassSuccessWasNonNull = 0;

	UPROPERTY()
	int bClassFailureWasNull = 0;

	UPROPERTY()
	int bObjectPayloadMatchesExpectedType = 0;

	UPROPERTY()
	int bClassPayloadMatchesExpectedType = 0;

	UPROPERTY()
	FString LastObjectName;

	UPROPERTY()
	FString LastClassName;

	/**
	 * Binds HandleObjectSuccess and starts LoadAsync on the success texture path.
	 *
	 * @Covers Delegates.Async
	 * @Inputs $SUCCESS_TEXTURE_PATH$
	 * @Return 1
	 */
	UFUNCTION()
	int StartObjectSuccessLoad()
	{
		FOnSoftObjectLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleObjectSuccess");
		TSoftObjectPtr<UTexture2D>(FSoftObjectPath("$SUCCESS_TEXTURE_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	/**
	 * Binds HandleObjectFailure and starts LoadAsync on the missing object path.
	 *
	 * @Covers Delegates.Async
	 * @Inputs $MISSING_OBJECT_PATH$
	 * @Return 1
	 */
	UFUNCTION()
	int StartObjectFailureLoad()
	{
		FOnSoftObjectLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleObjectFailure");
		TSoftObjectPtr<UTexture2D>(FSoftObjectPath("$MISSING_OBJECT_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	/**
	 * Binds HandleClassSuccess and starts LoadAsync on the success class path.
	 *
	 * @Covers Delegates.Async
	 * @Inputs $SUCCESS_CLASS_PATH$
	 * @Return 1
	 */
	UFUNCTION()
	int StartClassSuccessLoad()
	{
		FOnSoftClassLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleClassSuccess");
		TSoftClassPtr<AActor>(FSoftObjectPath("$SUCCESS_CLASS_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	/**
	 * Binds HandleClassFailure and starts LoadAsync on the missing class path.
	 *
	 * @Covers Delegates.Async
	 * @Inputs $MISSING_CLASS_PATH$
	 * @Return 1
	 */
	UFUNCTION()
	int StartClassFailureLoad()
	{
		FOnSoftClassLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleClassFailure");
		TSoftClassPtr<AActor>(FSoftObjectPath("$MISSING_CLASS_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	/**
	 * Records a successful object load.
	 *
	 * @Covers Delegates.Async
	 * @Param LoadedObject the loaded object
	 * @Inputs LoadedObject
	 * @Return nothing; ObjectSuccessCallbackCount and LastObjectName are written
	 */
	UFUNCTION()
	void HandleObjectSuccess(UObject LoadedObject)
	{
		UTexture2D TypedTexture = Cast<UTexture2D>(LoadedObject);
		ObjectSuccessCallbackCount += 1;
		bObjectSuccessWasNonNull = LoadedObject != null ? 1 : 0;
		bObjectPayloadMatchesExpectedType = TypedTexture != null ? 1 : 0;
		LastObjectName = TypedTexture == null ? FString() : TypedTexture.GetName().ToString();
	}

	/**
	 * Records a failed object load.
	 *
	 * @Covers Delegates.Async
	 * @Param LoadedObject the loaded object, expected null
	 * @Inputs LoadedObject
	 * @Return nothing; ObjectFailureCallbackCount and bObjectFailureWasNull are written
	 */
	UFUNCTION()
	void HandleObjectFailure(UObject LoadedObject)
	{
		ObjectFailureCallbackCount += 1;
		bObjectFailureWasNull = LoadedObject == null ? 1 : 0;
	}

	/**
	 * Records a successful class load.
	 *
	 * @Covers Delegates.Async
	 * @Param LoadedClass the loaded class
	 * @Inputs LoadedClass
	 * @Return nothing; ClassSuccessCallbackCount and LastClassName are written
	 */
	UFUNCTION()
	void HandleClassSuccess(UClass LoadedClass)
	{
		ClassSuccessCallbackCount += 1;
		bClassSuccessWasNonNull = LoadedClass != null ? 1 : 0;
		bClassPayloadMatchesExpectedType = LoadedClass != null && LoadedClass.IsChildOf(AActor::StaticClass()) ? 1 : 0;
		LastClassName = LoadedClass == null ? FString() : LoadedClass.GetName().ToString();
	}

	/**
	 * Records a failed class load.
	 *
	 * @Covers Delegates.Async
	 * @Param LoadedClass the loaded class, expected null
	 * @Inputs LoadedClass
	 * @Return nothing; ClassFailureCallbackCount and bClassFailureWasNull are written
	 */
	UFUNCTION()
	void HandleClassFailure(UClass LoadedClass)
	{
		ClassFailureCallbackCount += 1;
		bClassFailureWasNull = LoadedClass == null ? 1 : 0;
	}

	/**
	 * Observe that all callback counts start at 0 and names are empty.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Async
	 * @Inputs this
	 * @Return true when every count is 0 and both names are empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ObjectSuccessCallbackCount != 0)
		{
			return false;
		}
		if (ObjectFailureCallbackCount != 0)
		{
			return false;
		}
		if (ClassSuccessCallbackCount != 0)
		{
			return false;
		}
		if (ClassFailureCallbackCount != 0)
		{
			return false;
		}
		if (LastObjectName.Len() != 0)
		{
			return false;
		}
		return LastClassName.Len() == 0;
	}

	/**
	 * Observe a null object-failure callback.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Async
	 * @Inputs HandleObjectFailure(null)
	 * @Return bObjectFailureWasNull
	 * @Boundary null object
	 */
	UFUNCTION()
	int NullObjectFailureBoundary()
	{
		HandleObjectFailure(null);
		return bObjectFailureWasNull;
	}

	/**
	 * Observe a null class-failure callback.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Async
	 * @Inputs HandleClassFailure(null)
	 * @Return bClassFailureWasNull
	 * @Boundary null class
	 */
	UFUNCTION()
	int NullClassFailureBoundary()
	{
		HandleClassFailure(null);
		return bClassFailureWasNull;
	}
}
/** @end */
