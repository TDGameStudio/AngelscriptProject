// Theme: Feature.Delegates. Positive soft-reference async LoadAsync harness.
// C++: AngelscriptSoftReferenceFunctionLibraryTests.cpp::AsyncDelegates
// sha256 from theme-refs TS-FEAT-0231; lines 201-310.
// Substitutions $SUCCESS_TEXTURE_PATH$ / $MISSING_OBJECT_PATH$ / $SUCCESS_CLASS_PATH$ /
// $MISSING_CLASS_PATH$ become runner parameters.
// Oracle after four Start*Load calls: each callback count == 1; success payloads non-null
// and typed; failure payloads null; LastObjectName == "DefaultTexture".
// Extra: local construct keeps all counts 0 and empty names. DefaultSafe.

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

	UFUNCTION()
	int StartObjectSuccessLoad()
	{
		FOnSoftObjectLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleObjectSuccess");
		TSoftObjectPtr<UTexture2D>(FSoftObjectPath("$SUCCESS_TEXTURE_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	UFUNCTION()
	int StartObjectFailureLoad()
	{
		FOnSoftObjectLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleObjectFailure");
		TSoftObjectPtr<UTexture2D>(FSoftObjectPath("$MISSING_OBJECT_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	UFUNCTION()
	int StartClassSuccessLoad()
	{
		FOnSoftClassLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleClassSuccess");
		TSoftClassPtr<AActor>(FSoftObjectPath("$SUCCESS_CLASS_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	UFUNCTION()
	int StartClassFailureLoad()
	{
		FOnSoftClassLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleClassFailure");
		TSoftClassPtr<AActor>(FSoftObjectPath("$MISSING_CLASS_PATH$")).LoadAsync(Delegate);
		return 1;
	}

	UFUNCTION()
	void HandleObjectSuccess(UObject LoadedObject)
	{
		UTexture2D TypedTexture = Cast<UTexture2D>(LoadedObject);
		ObjectSuccessCallbackCount += 1;
		bObjectSuccessWasNonNull = LoadedObject != null ? 1 : 0;
		bObjectPayloadMatchesExpectedType = TypedTexture != null ? 1 : 0;
		LastObjectName = TypedTexture == null ? FString() : TypedTexture.GetName().ToString();
	}

	UFUNCTION()
	void HandleObjectFailure(UObject LoadedObject)
	{
		ObjectFailureCallbackCount += 1;
		bObjectFailureWasNull = LoadedObject == null ? 1 : 0;
	}

	UFUNCTION()
	void HandleClassSuccess(UClass LoadedClass)
	{
		ClassSuccessCallbackCount += 1;
		bClassSuccessWasNonNull = LoadedClass != null ? 1 : 0;
		bClassPayloadMatchesExpectedType = LoadedClass != null && LoadedClass.IsChildOf(AActor::StaticClass()) ? 1 : 0;
		LastClassName = LoadedClass == null ? FString() : LoadedClass.GetName().ToString();
	}

	UFUNCTION()
	void HandleClassFailure(UClass LoadedClass)
	{
		ClassFailureCallbackCount += 1;
		bClassFailureWasNull = LoadedClass == null ? 1 : 0;
	}
}

bool Observe_SoftAsync_DefaultEmpty(USoftReferenceAsyncScriptHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AsyncDelegates setup: required Harness is null");
	}
	return Harness.ObjectSuccessCallbackCount == 0
		&& Harness.ObjectFailureCallbackCount == 0
		&& Harness.ClassSuccessCallbackCount == 0
		&& Harness.ClassFailureCallbackCount == 0
		&& Harness.LastObjectName.Len() == 0
		&& Harness.LastClassName.Len() == 0;
}

int Observe_SoftAsync_NullObjectFailureBoundary(USoftReferenceAsyncScriptHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AsyncDelegates setup: required Harness is null");
	}
	Harness.HandleObjectFailure(null);
	return Harness.bObjectFailureWasNull;
}

int Observe_SoftAsync_NullClassFailureBoundary(USoftReferenceAsyncScriptHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AsyncDelegates setup: required Harness is null");
	}
	Harness.HandleClassFailure(null);
	return Harness.bClassFailureWasNull;
}
