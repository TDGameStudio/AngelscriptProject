// Theme: Feature.Mixin. WorldStory mixin null-link then linked UPROPERTY read/write.
// C++: AngelscriptCoverageMixinTests.cpp::MixinReadsAndWritesUPropertyBoundaries
// Oracle after BeginPlay: bSawNullLinkedActor==true, bCopiedLinkedScore==true,
// Score==43, LinkedScoreAfterMixin==44, Marker==n"MixinTouchedProperty".
// Extra: empty handle null; default LinkedActor null. FixtureIsolated.

mixin bool CopyLinkedScore(ACoverageMixinPropertyActor Self)
{
	if (Self.LinkedActor == nullptr)
	{
		Self.bSawNullLinkedActor = true;
		return false;
	}

	Self.Score = Self.LinkedActor.Score + Self.Bonus;
	Self.LinkedActor.Score += 4;
	return true;
}

mixin void ApplyNameMarker(ACoverageMixinPropertyActor Self, FName Marker)
{
	Self.Marker = Marker;
}

UCLASS()
class ACoverageMixinPropertyActor : AActor
{
	UPROPERTY()
	ACoverageMixinPropertyActor LinkedActor;

	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	int Bonus = 3;

	UPROPERTY()
	int LinkedScoreAfterMixin = 0;

	UPROPERTY()
	bool bSawNullLinkedActor = false;

	UPROPERTY()
	bool bCopiedLinkedScore = false;

	UPROPERTY()
	FName Marker = NAME_None;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bCopiedLinkedScore = this.CopyLinkedScore();

		// Spawn a no-op peer subclass (not the same class) so the linked actor
		// does not recursively run BeginPlay/SpawnActor.
		LinkedActor = Cast<ACoverageMixinPropertyActor>(SpawnActor(ACoverageMixinPropertyPeerActor::StaticClass()));
		if (LinkedActor != nullptr)
		{
			LinkedActor.Score = 40;
			bCopiedLinkedScore = this.CopyLinkedScore();
			LinkedScoreAfterMixin = LinkedActor.Score;
			LinkedActor.DestroyActor();
		}

		this.ApplyNameMarker(n"MixinTouchedProperty");
	}
}

UCLASS()
class ACoverageMixinPropertyPeerActor : ACoverageMixinPropertyActor
{
	// No-op BeginPlay keeps the linked peer from recursively spawning.
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
}

bool Observe_MixinProperty_EmptyHandleIsNull()
{
	ACoverageMixinPropertyActor Actor;
	return Actor == nullptr;
}

bool Observe_MixinProperty_DefaultLinkedNull(ACoverageMixinPropertyActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0061 setup: required ACoverageMixinPropertyActor is null");
	}
	return Actor.LinkedActor == nullptr && Actor.Marker == NAME_None && Actor.Score == 0;
}

bool Observe_MixinProperty_AfterBeginPlay(ACoverageMixinPropertyActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0061 setup: required ACoverageMixinPropertyActor is null");
	}
	return Actor.bSawNullLinkedActor
		&& Actor.bCopiedLinkedScore
		&& Actor.Score == 43
		&& Actor.LinkedScoreAfterMixin == 44
		&& Actor.Marker == n"MixinTouchedProperty";
}

FName Observe_MixinProperty_EmptyMarkerBoundary(ACoverageMixinPropertyActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0061 setup: required ACoverageMixinPropertyActor is null");
	}
	Actor.ApplyNameMarker(n"");
	return Actor.Marker;
}
