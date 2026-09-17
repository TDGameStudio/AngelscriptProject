/**
 * @version v1
 * @summary Super:: BeginPlay/Tick/EndPlay order. C++ verifies after BeginPlay: BaseBeginPlayOrder==1, MidBeginPlayOrder==2, DeepBeginPlayOrder==3. Tick and EndPlay stay 0 unless the world dispatches them.
 * @topic Feature
 */
/**
 * @version root
 * @summary Super:: BeginPlay/Tick/EndPlay order. C++ verifies after BeginPlay: BaseBeginPlayOrder==1, MidBeginPlayOrder==2, DeepBeginPlayOrder==3. Tick and EndPlay stay 0 unless the world dispatches them.
 * @topic Baseline
 */
UCLASS()
class ABaseLifecycleActor : AActor
{
	UPROPERTY()
	int BaseBeginPlayOrder = 0;

	UPROPERTY()
	int BaseTickOrder = 0;

	UPROPERTY()
	int BaseEndPlayOrder = 0;

	/**
	 * WorldStory: base BeginPlay records order 1.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs none
	 * @Return BaseBeginPlayOrder == 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseBeginPlayOrder = 1;
	}

	/**
	 * WorldStory: base Tick records order 1.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs the frame delta
	 * @Return BaseTickOrder == 1
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		BaseTickOrder = 1;
	}

	/**
	 * WorldStory: base EndPlay records order 1.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs the end-play reason
	 * @Return BaseEndPlayOrder == 1
	 * @Param EndPlayReason the engine end-play reason
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		BaseEndPlayOrder = 1;
	}
}

UCLASS()
class AMidLifecycleActor : ABaseLifecycleActor
{
	UPROPERTY()
	int MidBeginPlayOrder = 0;

	UPROPERTY()
	int MidTickOrder = 0;

	UPROPERTY()
	int MidEndPlayOrder = 0;

	/**
	 * WorldStory: mid BeginPlay Super-calls then records order 2.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::BeginPlay()
	 * @Return MidBeginPlayOrder == 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		MidBeginPlayOrder = 2;
	}

	/**
	 * WorldStory: mid Tick Super-calls then records order 2.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::Tick(DeltaSeconds)
	 * @Return MidTickOrder == 2
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		MidTickOrder = 2;
	}

	/**
	 * WorldStory: mid EndPlay Super-calls then records order 2.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::EndPlay(EndPlayReason)
	 * @Return MidEndPlayOrder == 2
	 * @Param EndPlayReason the engine end-play reason
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		Super::EndPlay(EndPlayReason);
		MidEndPlayOrder = 2;
	}
}

UCLASS()
class ADeepLifecycleActor : AMidLifecycleActor
{
	UPROPERTY()
	int DeepBeginPlayOrder = 0;

	UPROPERTY()
	int DeepTickOrder = 0;

	UPROPERTY()
	int DeepEndPlayOrder = 0;

	/**
	 * WorldStory: deep BeginPlay Super-calls then records order 3.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::BeginPlay()
	 * @Return DeepBeginPlayOrder == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		DeepBeginPlayOrder = 3;
	}

	/**
	 * WorldStory: deep Tick Super-calls then records order 3.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::Tick(DeltaSeconds)
	 * @Return DeepTickOrder == 3
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		DeepTickOrder = 3;
	}

	/**
	 * WorldStory: deep EndPlay Super-calls then records order 3.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Super::EndPlay(EndPlayReason)
	 * @Return DeepEndPlayOrder == 3
	 * @Param EndPlayReason the engine end-play reason
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		Super::EndPlay(EndPlayReason);
		DeepEndPlayOrder = 3;
	}

	/**
	 * Observe that a locally constructed deep actor has all orders at 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs an actor that has not begun play
	 * @Return true when BeginPlay/Tick/EndPlay orders are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (BaseBeginPlayOrder != 0)
		{
			return false;
		}
		if (MidBeginPlayOrder != 0)
		{
			return false;
		}
		if (DeepBeginPlayOrder != 0)
		{
			return false;
		}
		if (BaseTickOrder != 0)
		{
			return false;
		}
		return DeepEndPlayOrder == 0;
	}

	/**
	 * Observe the BeginPlay Super chain writing 1/2/3.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs BeginPlay()
	 * @Return Base*100 + Mid*10 + Deep, expected to be 123
	 */
	UFUNCTION()
	int BeginPlayChain()
	{
		BeginPlay();
		return BaseBeginPlayOrder * 100 + MidBeginPlayOrder * 10 + DeepBeginPlayOrder;
	}

	/**
	 * Observe the Tick Super chain writing 1/2/3.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs Tick(0.0)
	 * @Return Base*100 + Mid*10 + Deep, expected to be 123
	 */
	UFUNCTION()
	int TickChain()
	{
		Tick(0.0);
		return BaseTickOrder * 100 + MidTickOrder * 10 + DeepTickOrder;
	}

	/**
	 * Observe that BeginPlay on this instance leaves another deep actor at order 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelInheritanceLifecycle
	 * @Inputs this actor plus a second actor
	 * @Return true when this DeepBeginPlayOrder is 3 and the other stays 0
	 * @Param Second the other actor, expected to stay at order 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ADeepLifecycleActor Second)
	{
		if (Second == nullptr)
		{
			throw("MultiLevelInheritanceLifecycle setup: required Second is null");
		}
		BeginPlay();
		if (DeepBeginPlayOrder != 3)
		{
			return false;
		}
		return Second.DeepBeginPlayOrder == 0;
	}
}
/** @end */
