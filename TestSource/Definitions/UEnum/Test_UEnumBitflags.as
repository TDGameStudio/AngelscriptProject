// Theme: Definitions.UEnum. C++ compiles bitwise enum ops (CSV NegativeDiagnostic is wrong).
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumBitflags
// Oracle after BeginPlay: OrResult=3, AndResult=1, XorResult=1, NotResult=-2, CompoundOrResult=5.
// Extra: None=0 empty flags; nullptr actor is the empty handle; Delete=8 is an unused bit boundary.
// FixtureIsolated. Keep OrResult/AndResult/XorResult/NotResult/CompoundOrResult names.

UENUM()
enum EPermissionFlags
{
	None = 0,
	Read = 1,
	Write = 2,
	Execute = 4,
	Delete = 8
}

UCLASS()
class ACoverageUEnumBitflagsActor : AActor
{
	UPROPERTY()
	int OrResult = 0;

	UPROPERTY()
	int AndResult = 0;

	UPROPERTY()
	int XorResult = 0;

	UPROPERTY()
	int NotResult = 0;

	UPROPERTY()
	int CompoundOrResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int Flags1 = int(EPermissionFlags::Read) | int(EPermissionFlags::Write);
		check(Flags1 == 3);
		OrResult = Flags1;

		int Flags2 = Flags1 & int(EPermissionFlags::Read);
		check(Flags2 == 1);
		AndResult = Flags2;

		int Flags3 = Flags1 ^ int(EPermissionFlags::Write);
		check(Flags3 == 1);
		XorResult = Flags3;

		int Flags4 = ~int(EPermissionFlags::Read);
		check(Flags4 == -2);
		NotResult = Flags4;

		int Flags5 = int(EPermissionFlags::Read);
		Flags5 |= int(EPermissionFlags::Execute);
		check(Flags5 == 5);
		CompoundOrResult = Flags5;
	}
}

bool Observe_Permission_BeginPlayOracle(ACoverageUEnumBitflagsActor Actor)
{
	Actor.BeginPlay();
	return Actor.OrResult == 3
		&& Actor.AndResult == 1
		&& Actor.XorResult == 1
		&& Actor.NotResult == -2
		&& Actor.CompoundOrResult == 5;
}

int Observe_Permission_NoneEmpty()
{
	return int(EPermissionFlags::None);
}

bool Observe_Permission_NullDefault()
{
	ACoverageUEnumBitflagsActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Permission_DeleteBoundary()
{
	int WithDelete = int(EPermissionFlags::Read) | int(EPermissionFlags::Delete);
	return WithDelete == 9 && int(EPermissionFlags::Delete) == 8;
}
