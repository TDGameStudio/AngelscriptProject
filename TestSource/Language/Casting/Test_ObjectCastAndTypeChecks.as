// Theme: Language.Casting. WorldStory Cast<T>, IsA, IsChildOf, and GetClass on generated actors.
// C++: AngelscriptCoverageTypeConversionTests.cpp::ObjectCastAndTypeChecks
// CSV NegativeDiagnostic is wrong; C++ compiles then VerifyByPath.
// Oracle: bDowncastSuccess, bInvalidCastReturnsNull, bIsABase, bClassIsChild, bExactClassCheck all true.
// Extra: Cast from nullptr is the null vector. Keep UPROPERTY names the C++ path uses.
// FixtureIsolated. Runner owns spawn and World teardown.

UCLASS()
class ACoverageCastBaseActor : AActor
{
}

UCLASS()
class ACoverageCastDerivedActor : ACoverageCastBaseActor
{
	UPROPERTY()
	int DerivedValue = 77;
}

UCLASS()
class ACoverageCastOtherActor : AActor
{
}

UCLASS()
class ACoverageTypeConversionActor : AActor
{
	UPROPERTY()
	bool bDowncastSuccess = false;

	UPROPERTY()
	bool bInvalidCastReturnsNull = false;

	UPROPERTY()
	bool bIsABase = false;

	UPROPERTY()
	bool bClassIsChild = false;

	UPROPERTY()
	bool bExactClassCheck = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ACoverageCastDerivedActor Derived = Cast<ACoverageCastDerivedActor>(SpawnActor(ACoverageCastDerivedActor::StaticClass()));
		// SpawnActor-created secondary instances do not replay this class's inline UPROPERTY
		// initializer; assign the expected value explicitly before downcast assertions.
		if (Derived != nullptr)
		{
			Derived.DerivedValue = 77;
		}
		AActor AsActor = Derived;
		ACoverageCastBaseActor AsBase = Derived;
		ACoverageCastOtherActor Invalid = Cast<ACoverageCastOtherActor>(AsActor);
		ACoverageCastDerivedActor Downcasted = Cast<ACoverageCastDerivedActor>(AsBase);

		bDowncastSuccess = Downcasted != nullptr && Downcasted.DerivedValue == 77;
		bInvalidCastReturnsNull = Invalid == nullptr;
		bIsABase = AsActor.IsA(ACoverageCastBaseActor::StaticClass());
		bClassIsChild = ACoverageCastDerivedActor::StaticClass().IsChildOf(ACoverageCastBaseActor::StaticClass());
		bExactClassCheck = Derived.GetClass() == ACoverageCastDerivedActor::StaticClass();

		if (Derived != nullptr)
		{
			Derived.DestroyActor();
		}
	}
}

bool Observe_Cast_NullDefault()
{
	ACoverageCastDerivedActor Downcasted = Cast<ACoverageCastDerivedActor>(nullptr);
	return Downcasted == nullptr;
}

bool Observe_InvalidCast_OtherTypeBoundary(ACoverageCastBaseActor AsBase)
{
	ACoverageCastOtherActor Invalid = Cast<ACoverageCastOtherActor>(AsBase);
	return Invalid == nullptr;
}
