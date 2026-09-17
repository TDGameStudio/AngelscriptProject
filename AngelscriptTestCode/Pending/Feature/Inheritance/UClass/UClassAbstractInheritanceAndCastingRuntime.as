/**
 * @version v1
 * @summary Abstract UCLASS inheritance plus upcast/downcast at runtime. C++ CompileUClassFixture plus spawn plus VerifyByPath. After BeginPlay CallChain==123, UpcastWorked==1, DowncastWorked==1 and InvalidCastFailed==1.
 * @topic Feature
 */
/**
 * @version root
 * @summary Abstract UCLASS inheritance plus upcast/downcast at runtime. C++ CompileUClassFixture plus spawn plus VerifyByPath. After BeginPlay CallChain==123, UpcastWorked==1, DowncastWorked==1 and InvalidCastFailed==1.
 * @topic Baseline
 */
UCLASS(Abstract, Blueprintable)
class ACoverageUClassRuntimeAbstractBase : AActor
{
	UPROPERTY()
	int CallChain = 0;

	/**
	 * Base ApplyStep that appends digit 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs none
	 * @Return CallChain = CallChain * 10 + 1
	 */
	void ApplyStep()
	{
		CallChain = CallChain * 10 + 1;
	}
}

UCLASS()
class ACoverageUClassRuntimeMid : ACoverageUClassRuntimeAbstractBase
{
	/**
	 * Mid ApplyStep that Super-calls then appends digit 2.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs Super::ApplyStep()
	 * @Return CallChain = CallChain * 10 + 2 after Super
	 */
	void ApplyStep()
	{
		Super::ApplyStep();
		CallChain = CallChain * 10 + 2;
	}
}

UCLASS()
class ACoverageUClassRuntimeLeaf : ACoverageUClassRuntimeMid
{
	UPROPERTY()
	int UpcastWorked = 0;

	UPROPERTY()
	int DowncastWorked = 0;

	UPROPERTY()
	int InvalidCastFailed = 0;

	/**
	 * Leaf ApplyStep that Super-calls then appends digit 3.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs Super::ApplyStep()
	 * @Return CallChain = CallChain * 10 + 3 after Super
	 */
	void ApplyStep()
	{
		Super::ApplyStep();
		CallChain = CallChain * 10 + 3;
	}

	/**
	 * WorldStory: BeginPlay runs ApplyStep then records upcast, downcast and invalid-cast sentinels.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs ApplyStep plus Cast to leaf from a spawned mid
	 * @Return CallChain 123, UpcastWorked 1, DowncastWorked 1, InvalidCastFailed 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ApplyStep();

		ACoverageUClassRuntimeAbstractBase BaseRef = this;
		if (BaseRef != nullptr && BaseRef.CallChain == 123)
		{
			UpcastWorked = 1;
		}

		ACoverageUClassRuntimeLeaf LeafRef = Cast<ACoverageUClassRuntimeLeaf>(BaseRef);
		if (LeafRef != nullptr)
		{
			DowncastWorked = 1;
		}

		ACoverageUClassRuntimeMid SpawnedMid = Cast<ACoverageUClassRuntimeMid>(SpawnActor(ACoverageUClassRuntimeMid::StaticClass()));
		ACoverageUClassRuntimeLeaf InvalidLeaf = Cast<ACoverageUClassRuntimeLeaf>(SpawnedMid);
		if (SpawnedMid != nullptr && InvalidLeaf == nullptr)
		{
			InvalidCastFailed = 1;
		}
	}

	/**
	 * Observe that a locally constructed leaf has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs an actor that has not begun play
	 * @Return the sum of the sentinels, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int CountersBeforeBeginPlay()
	{
		return CallChain + UpcastWorked + DowncastWorked + InvalidCastFailed;
	}

	/**
	 * Observe the abstract inheritance and casting sentinels after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassAbstractInheritanceAndCastingRuntime
	 * @Inputs an actor whose BeginPlay has run
	 * @Return true when CallChain is 123 and all three cast sentinels are 1
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (CallChain != 123)
		{
			return false;
		}
		if (UpcastWorked != 1)
		{
			return false;
		}
		if (DowncastWorked != 1)
		{
			return false;
		}
		return InvalidCastFailed == 1;
	}
}
/** @end */
