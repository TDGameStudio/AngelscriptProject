/**
 * UObject/AActor/UClass/TSubclassOf parameter matrix.
 * AcceptObjectClassMatrix(this, this, self class, self class) is 15.
 * ReturnSelfAsObject aliases this. ReturnSelfClass and ReturnActorSubclass
 * are the generated class. All-null Accept returns 0. LastObject stays null
 * on default construct.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ObjectAndClassParameterReflectionMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.ObjectAndClassParameterReflectionMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: UObject/AActor/UClass/TSubclassOf parameter matrix.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::ObjectAndClassParameterReflectionMatrix
 * @Provenance Oracle: AcceptObjectClassMatrix(this,this,self class,self class) == 15;
 * @Provenance ReturnSelfAsObject aliases this; ReturnSelfClass/ReturnActorSubclass are the generated class.
 * @Provenance Extra: all-null Accept returns 0; LastObject stays null on default construct.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionObjectBaseActor : AActor
{
}

UCLASS()
class ACoverageUFunctionObjectClassActor : ACoverageUFunctionObjectBaseActor
{
	UPROPERTY()
	UObject LastObject;

	UPROPERTY()
	AActor LastActor;

	UPROPERTY()
	UClass LastClass;

	UPROPERTY()
	TSubclassOf<AActor> LastActorClass;

	/**
	 * Score object, actor, class, and subclass identity against this.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param ObjectValue Object received by value
	 * @Param ActorValue Actor received by value
	 * @Param ClassValue Class received by value
	 * @Param ActorClassValue Actor subclass received by value
	 * @Inputs ObjectValue, ActorValue, ClassValue, ActorClassValue
	 * @Return identity score bits 1+2+4+8
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	int AcceptObjectClassMatrix(UObject ObjectValue, AActor ActorValue, UClass ClassValue, TSubclassOf<AActor> ActorClassValue)
	{
		LastObject = ObjectValue;
		LastActor = ActorValue;
		LastClass = ClassValue;
		LastActorClass = ActorClassValue;

		int Score = 0;
		if (LastObject == this)
		{
			Score += 1;
		}
		if (LastActor == this)
		{
			Score += 2;
		}
		if (LastClass == ACoverageUFunctionObjectClassActor::StaticClass())
		{
			Score += 4;
		}
		if (LastActorClass != nullptr && LastActorClass.IsChildOf(ACoverageUFunctionObjectBaseActor::StaticClass()))
		{
			Score += 8;
		}
		return Score;
	}

	/**
	 * Return this as UObject.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return this
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	UObject ReturnSelfAsObject()
	{
		return this;
	}

	/**
	 * Return the generated class.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return ACoverageUFunctionObjectClassActor::StaticClass()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	UClass ReturnSelfClass()
	{
		return ACoverageUFunctionObjectClassActor::StaticClass();
	}

	/**
	 * Return the generated class as TSubclassOf<AActor>.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return ACoverageUFunctionObjectClassActor::StaticClass()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ObjectClass")
	TSubclassOf<AActor> ReturnActorSubclass()
	{
		return ACoverageUFunctionObjectClassActor::StaticClass();
	}

	/**
	 * Observe AcceptObjectClassMatrix of this and the generated class.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs this, this, self class, self class
	 * @Return 15
	 */
	UFUNCTION()
	int AcceptSelf()
	{
		return AcceptObjectClassMatrix(
			this,
			this,
			ACoverageUFunctionObjectClassActor::StaticClass(),
			ACoverageUFunctionObjectClassActor::StaticClass());
	}

	/**
	 * Observe AcceptObjectClassMatrix of all nulls.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs nullptr, nullptr, nullptr, nullptr
	 * @Return 0
	 * @Boundary all-null arguments
	 */
	UFUNCTION()
	int AcceptNulls()
	{
		return AcceptObjectClassMatrix(nullptr, nullptr, nullptr, nullptr);
	}

	/**
	 * Observe ReturnSelfAsObject, ReturnSelfClass, and ReturnActorSubclass.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return true when all three alias this / the generated class
	 */
	UFUNCTION()
	bool ReturnSelfAndClass()
	{
		if (ReturnSelfAsObject() != this)
		{
			return false;
		}
		if (ReturnSelfClass() != ACoverageUFunctionObjectClassActor::StaticClass())
		{
			return false;
		}
		return ReturnActorSubclass() == ACoverageUFunctionObjectClassActor::StaticClass();
	}

	/**
	 * Observe default LastObject, LastActor, and LastClass.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return true when all three last members are null
	 * @Boundary default LastObject
	 */
	UFUNCTION()
	bool DefaultLastObjectNull()
	{
		if (LastObject != nullptr)
		{
			return false;
		}
		if (LastActor != nullptr)
		{
			return false;
		}
		return LastClass == nullptr;
	}
}
