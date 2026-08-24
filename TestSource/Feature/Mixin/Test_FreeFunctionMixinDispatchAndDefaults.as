// Theme: Feature.Mixin. WorldStory free-function mixin dispatch + default arguments.
// C++: AngelscriptCoverageMixinTests.cpp::FreeFunctionMixinDispatchAndDefaults
// Oracle after BeginPlay: bReady==true, Score==12 (5+7), OtherScore==15 (12+3).
// Extra: empty handle null; pre-BeginPlay false/0. FixtureIsolated. Keep bReady/Score/OtherScore.

mixin void MarkReady(ACoverageMixinHostActor Self)
{
	Self.bReady = true;
}

mixin void AddScore(ACoverageMixinHostActor Self, int Amount = 5)
{
	Self.Score += Amount;
}

mixin void CopyScoreTo(ACoverageMixinHostActor Self, ACoverageMixinHostActor Other, int Bonus = 1)
{
	if (Other != nullptr)
	{
		Other.Score = Self.Score + Bonus;
	}
}

UCLASS()
class ACoverageMixinHostActor : AActor
{
	UPROPERTY()
	bool bReady = false;

	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	int OtherScore = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkReady();
		this.AddScore();
		this.AddScore(7);

		// Spawn a no-op peer subclass (not the host class itself) so the
		// spawned receiver does not recursively run host BeginPlay/SpawnActor.
		ACoverageMixinHostActor Other = Cast<ACoverageMixinHostActor>(SpawnActor(ACoverageMixinPeerActor::StaticClass()));
		this.CopyScoreTo(Other, 3);
		if (Other != nullptr)
		{
			OtherScore = Other.Score;
			Other.DestroyActor();
		}
	}
}

UCLASS()
class ACoverageMixinPeerActor : ACoverageMixinHostActor
{
	// No-op BeginPlay keeps the spawned peer from recursively spawning more peers.
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
}

bool Observe_MixinDefaults_EmptyHandleIsNull()
{
	ACoverageMixinHostActor Actor;
	return Actor == nullptr;
}

bool Observe_MixinDefaults_BeforeBeginPlay(ACoverageMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0055 setup: required ACoverageMixinHostActor is null");
	}
	return !Actor.bReady && Actor.Score == 0 && Actor.OtherScore == 0;
}

bool Observe_MixinDefaults_AfterBeginPlay(ACoverageMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0055 setup: required ACoverageMixinHostActor is null");
	}
	return Actor.bReady && Actor.Score == 12 && Actor.OtherScore == 15;
}

int Observe_MixinDefaults_NullCopyScoreBoundary(ACoverageMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0055 setup: required ACoverageMixinHostActor is null");
	}
	Actor.CopyScoreTo(nullptr, 3);
	return Actor.OtherScore;
}
