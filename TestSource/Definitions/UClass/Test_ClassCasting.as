// Theme: Definitions.UClass. WorldStory generated-class Cast<T> upcast/downcast/invalid.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::ClassCasting compiles then VerifyByPath.
// CSV NegativeDiagnostic is wrong. Oracle after BeginPlay: UpcastSuccess=1, DowncastSuccess=1, InvalidCastFailed=1.
// Extra: Cast from nullptr is null; pre-BeginPlay counters stay 0. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create derived instance
		ACastDerived Derived = Cast<ACastDerived>(SpawnActor(ACastDerived::StaticClass()));
		if (Derived != nullptr)
		{
			Derived.DerivedValue = 300;

			// Upcast (implicit)
			ACastBase Base = Derived;
			if (Base != nullptr && Base.BaseValue == 100)
			{
				UpcastSuccess = 1;
			}

			// Downcast (explicit)
			ACastDerived DownCasted = Cast<ACastDerived>(Base);
			if (DownCasted != nullptr && DownCasted.DerivedValue == 300)
			{
				DowncastSuccess = 1;
			}

			// Invalid cast should fail
			ACastTester InvalidCast = Cast<ACastTester>(Base);
			if (InvalidCast == nullptr)
			{
				InvalidCastFailed = 1;
			}
		}
	}
}

bool Observe_CastTester_EmptyDefaultIsNull()
{
	ACastTester Actor;
	return Actor == nullptr;
}

int Observe_CastTester_CountersBeforeBeginPlay(ACastTester Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0038 setup: required ACastTester is null");
	}
	return Actor.UpcastSuccess + Actor.DowncastSuccess + Actor.InvalidCastFailed;
}

bool Observe_CastDerived_NullDefault()
{
	ACastDerived DownCasted = Cast<ACastDerived>(nullptr);
	return DownCasted == nullptr;
}
