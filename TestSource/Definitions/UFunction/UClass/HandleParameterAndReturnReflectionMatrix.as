/**
 * TSoftObjectPtr / TSoftClassPtr / TWeakObjectPtr matrix. AcceptHandleMatrix
 * (DefaultTexture, Engine.Actor, this) is 7 and bWeakWasValid true. Empty
 * handles score 0 and leave bWeakWasValid false. ReturnWeakSelf aliases this.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.HandleParameterAndReturnReflectionMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.HandleParameterAndReturnReflectionMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: TSoftObjectPtr / TSoftClassPtr / TWeakObjectPtr matrix.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::HandleParameterAndReturnReflectionMatrix
 * @Provenance Oracle: AcceptHandleMatrix(DefaultTexture, Engine.Actor, this) == 7 and bWeakWasValid true.
 * @Provenance Extra: empty handles score 0 and leave bWeakWasValid false; ReturnWeakSelf aliases this.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionHandleActor : AActor
{
	UPROPERTY()
	TSoftObjectPtr<UObject> LastSoftObject;

	UPROPERTY()
	TSoftClassPtr<AActor> LastSoftClass;

	UPROPERTY()
	TWeakObjectPtr<AActor> LastWeakActor;

	UPROPERTY()
	bool bWeakWasValid = false;

	/**
	 * Score DefaultTexture, Actor class, and a weak this, storing the handles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param SoftObject Soft object path scored for DefaultTexture
	 * @Param SoftClass Soft class path scored for Actor
	 * @Param WeakActor Weak actor scored when it aliases this
	 * @Inputs SoftObject, SoftClass, and WeakActor
	 * @Return 1+2+4 when each handle matches
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	int AcceptHandleMatrix(TSoftObjectPtr<UObject> SoftObject, TSoftClassPtr<AActor> SoftClass, TWeakObjectPtr<AActor> WeakActor)
	{
		LastSoftObject = SoftObject;
		LastSoftClass = SoftClass;
		LastWeakActor = WeakActor;
		bWeakWasValid = WeakActor.IsValid() && WeakActor.Get() == this;

		int Score = 0;
		if (SoftObject.ToString().Contains("DefaultTexture"))
		{
			Score += 1;
		}
		if (SoftClass.ToString().Contains("Actor"))
		{
			Score += 2;
		}
		if (bWeakWasValid)
		{
			Score += 4;
		}
		return Score;
	}

	/**
	 * Return the DefaultTexture soft object.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return DefaultTexture soft object
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TSoftObjectPtr<UObject> ReturnSoftObject()
	{
		return TSoftObjectPtr<UObject>(FSoftObjectPath("/Engine/EngineResources/DefaultTexture.DefaultTexture"));
	}

	/**
	 * Return the Engine.Actor soft class.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return Engine.Actor soft class
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TSoftClassPtr<AActor> ReturnSoftClass()
	{
		return TSoftClassPtr<AActor>(FSoftObjectPath("/Script/Engine.Actor"));
	}

	/**
	 * Return a weak pointer to this actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return this as TWeakObjectPtr<AActor>
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Handles")
	TWeakObjectPtr<AActor> ReturnWeakSelf()
	{
		return this;
	}

	/**
	 * Observe AcceptHandleMatrix with the returned live handles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptHandleMatrix(ReturnSoftObject, ReturnSoftClass, ReturnWeakSelf)
	 * @Return 7
	 */
	UFUNCTION()
	int HandleMatrixNominalSelf()
	{
		return AcceptHandleMatrix(ReturnSoftObject(), ReturnSoftClass(), ReturnWeakSelf());
	}

	/**
	 * Observe AcceptHandleMatrix with empty handles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptHandleMatrix with default-constructed handles
	 * @Return 0
	 * @Boundary empty handles
	 */
	UFUNCTION()
	int HandleMatrixEmptyHandles()
	{
		TSoftObjectPtr<UObject> SoftObject;
		TSoftClassPtr<AActor> SoftClass;
		TWeakObjectPtr<AActor> WeakActor;
		return AcceptHandleMatrix(SoftObject, SoftClass, WeakActor);
	}

	/**
	 * Observe the default bWeakWasValid.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs bWeakWasValid on a freshly constructed actor
	 * @Return true when bWeakWasValid is false
	 * @Boundary default weak flag
	 */
	UFUNCTION()
	bool HandleMatrixDefaultWeakFalse()
	{
		return !bWeakWasValid;
	}

	/**
	 * Observe that ReturnWeakSelf aliases this actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnWeakSelf()
	 * @Return true when the weak pointer is valid and Get() is this
	 */
	UFUNCTION()
	bool HandleMatrixReturnWeakSelf()
	{
		TWeakObjectPtr<AActor> WeakSelf = ReturnWeakSelf();
		if (!WeakSelf.IsValid())
		{
			return false;
		}
		return WeakSelf.Get() == this;
	}
}
