// Theme: Language.Syntax.EdgeCases. WorldStory: UDataAsset property registration and CDO defaults.
// C++: AngelscriptTypesScriptDataAssetTests.cpp::CompilesAndRegistersProperties
// sha256=c5859a9b4c6c5a6f62342cd4f08ee1c4c10cd80d109af2835dd8bddd5a6d24e8; lines 32-58.
// Oracle: WeaponName FStr; BaseDamage 10.0; FireRate 0.5; MaxAmmo 30; AllowedAttachments TArray.
// Extra: local construct WeaponName empty, AllowedAttachments Num 0.
// FixtureIsolated. UDataAsset owns CDO defaults; actor holds the config pointer.

UCLASS()
class UFunctionalWeaponData : UDataAsset
{
	UPROPERTY(EditAnywhere)
	FString WeaponName;

	UPROPERTY(EditAnywhere, meta = (ClampMin = "0"))
	float BaseDamage = 10.0;

	UPROPERTY(EditAnywhere)
	float FireRate = 0.5;

	UPROPERTY(EditAnywhere)
	int32 MaxAmmo = 30;

	UPROPERTY(EditAnywhere)
	TArray<FName> AllowedAttachments;
}

UCLASS()
class AFunctionalWeaponActor : AActor
{
	UPROPERTY(EditAnywhere)
	UFunctionalWeaponData WeaponConfig;
}

bool Observe_WeaponData_CDODefaults(UFunctionalWeaponData Data)
{
	if (Data is null)
	{
		throw("Test_CompilesAndRegistersProperties setup: required Data is null");
	}
	return Data.WeaponName.Len() == 0
		&& Data.BaseDamage == 10.0
		&& Data.FireRate == 0.5
		&& Data.MaxAmmo == 30
		&& Data.AllowedAttachments.Num() == 0;
}

bool Observe_WeaponActor_NullConfig(AFunctionalWeaponActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CompilesAndRegistersProperties setup: required Actor is null");
	}
	return Actor.WeaponConfig == nullptr;
}
