/**
 * UUserWidget lifecycle and animation BlueprintOverride reflection. C++ compiles
 * and looks up the sentinel properties and UFunctions. Defaults are false/0/null
 * until Construct, Tick or animation callbacks fire.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.WidgetLifecycleAndAnimationOverrideReflection
 * @Harness UClass
 * @Tag Feature.Inheritance.WidgetLifecycleAndAnimationOverrideReflection
 * @Provenance Theme: Feature.Inheritance. Positive UUserWidget lifecycle/animation BlueprintOverride reflection.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::WidgetLifecycleAndAnimationOverrideReflection
 * @Provenance Compile + property/UFunction reflection. Oracle sentinels: bInitialized/bConstructed/bDestructed,
 * @Provenance TickCount, LastStartedAnimation, LastFinishedAnimation.
 * @Provenance Extra: default false/0/null; TickCount stays 0 until Tick. DefaultSafe.
 * @Provenance Keep bInitialized/bConstructed/bDestructed/TickCount/LastStartedAnimation/LastFinishedAnimation.
 */

UCLASS()
class UCoverageLifecycleAnimationWidget : UUserWidget
{
	UPROPERTY()
	bool bInitialized = false;

	UPROPERTY()
	bool bConstructed = false;

	UPROPERTY()
	bool bDestructed = false;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	UWidgetAnimation LastStartedAnimation;

	UPROPERTY()
	UWidgetAnimation LastFinishedAnimation;

	/**
	 * WorldStory: OnInitialized records that the widget was initialized.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs none
	 * @Return bInitialized == true
	 */
	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
		bInitialized = true;
	}

	/**
	 * WorldStory: Construct records that the widget was built.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs none
	 * @Return bConstructed == true
	 */
	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		bConstructed = true;
	}

	/**
	 * WorldStory: Destruct records that the widget was torn down.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs none
	 * @Return bDestructed == true
	 */
	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		bDestructed = true;
	}

	/**
	 * WorldStory: Tick increments TickCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs the widget geometry and the frame delta
	 * @Return TickCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float DeltaTime)
	{
		TickCount++;
	}

	/**
	 * WorldStory: OnAnimationStarted records initialization as the original sentinel.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs the started animation
	 * @Return bInitialized == true
	 * @Param Animation the started widget animation
	 */
	UFUNCTION(BlueprintOverride)
	void OnAnimationStarted(const UWidgetAnimation Animation)
	{
		bInitialized = true;
	}

	/**
	 * WorldStory: OnAnimationFinished records construction as the original sentinel.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs the finished animation
	 * @Return bConstructed == true
	 * @Param Animation the finished widget animation
	 */
	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		bConstructed = true;
	}

	/**
	 * Observe that a locally constructed widget has all sentinels at their defaults.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs a widget that has not been constructed
	 * @Return true when flags are false, TickCount is 0 and both animation handles are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultSentinels()
	{
		if (bInitialized)
		{
			return false;
		}
		if (bConstructed)
		{
			return false;
		}
		if (bDestructed)
		{
			return false;
		}
		if (TickCount != 0)
		{
			return false;
		}
		if (LastStartedAnimation != nullptr)
		{
			return false;
		}
		return LastFinishedAnimation == nullptr;
	}

	/**
	 * Observe OnInitialized writing bInitialized.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.WidgetLifecycleAndAnimationOverrideReflection
	 * @Inputs OnInitialized()
	 * @Return 1 when bInitialized is true, otherwise 0
	 * @Boundary OnInitialized
	 */
	UFUNCTION()
	int OnInitializedBoundary()
	{
		OnInitialized();
		return bInitialized ? 1 : 0;
	}
}
