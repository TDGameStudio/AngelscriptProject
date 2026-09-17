/**
 * @version v1
 * @summary Generated-class Cast<T> upcast, downcast, and invalid cast. After BeginPlay, UpcastSuccess, DowncastSuccess, and InvalidCastFailed are 1. Keep those UPROPERTY names; C++ VerifyByPath reads them.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Generated-class Cast<T> upcast, downcast, and invalid cast. After BeginPlay, UpcastSuccess, DowncastSuccess, and InvalidCastFailed are 1. Keep those UPROPERTY names; C++ VerifyByPath reads them.
 * @topic Baseline
 */
UCLASS()
class ACastBase : AActor
{
	UPROPERTY()
	int BaseValue = 100;
}

UCLASS()
class ACastDerived : ACastBase
{
	UPROPERTY()
	int DerivedValue = 200;
}

UCLASS()
class ACastTester : AActor
{
	UPROPERTY()
	int UpcastSuccess = 0;

	UPROPERTY()
	int DowncastSuccess = 0;

	UPROPERTY()
	int InvalidCastFailed = 0;

	/**
	 * WorldStory: BeginPlay upcasts, downcasts, and records an invalid cast as null.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Cast
	 * @Inputs SpawnActor ACastDerived, implicit upcast, Cast downcast, Cast to ACastTester
	 * @Return UpcastSuccess/DowncastSuccess/InvalidCastFailed set to 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ACastDerived Derived = Cast<ACastDerived>(SpawnActor(ACastDerived::StaticClass()));
		if (Derived != nullptr)
		{
			Derived.DerivedValue = 300;

			ACastBase Base = Derived;
			if (Base != nullptr)
			{
				if (Base.BaseValue == 100)
				{
					UpcastSuccess = 1;
				}
			}

			ACastDerived DownCasted = Cast<ACastDerived>(Base);
			if (DownCasted != nullptr)
			{
				if (DownCasted.DerivedValue == 300)
				{
					DowncastSuccess = 1;
				}
			}

			ACastTester InvalidCast = Cast<ACastTester>(Base);
			if (InvalidCast == nullptr)
			{
				InvalidCastFailed = 1;
			}
		}
	}

	/**
	 * Observe that an unset tester handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Cast
	 * @Inputs an unset ACastTester handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACastTester Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe cast counters before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Cast
	 * @Inputs a freshly constructed tester
	 * @Return UpcastSuccess + DowncastSuccess + InvalidCastFailed
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountersBeforeBeginPlay()
	{
		return UpcastSuccess + DowncastSuccess + InvalidCastFailed;
	}

	/**
	 * Observe that casting nullptr yields a null derived handle.
	 *
	 * @Kind Observe
	 * @Covers UClass.Cast
	 * @Inputs Cast<ACastDerived>(nullptr)
	 * @Return true when the result is null
	 * @Boundary null source
	 */
	UFUNCTION()
	bool CastNullIsNull()
	{
		ACastDerived DownCasted = Cast<ACastDerived>(nullptr);
		return DownCasted == nullptr;
	}
}
/** @end */
