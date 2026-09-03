/**
 * Free-function mixins dispatch onto an actor, including default arguments.
 * C++ expects after BeginPlay: bReady==true, Score==12 (5+7), OtherScore==15
 * (12+3). The observers cover the empty handle, pre-BeginPlay zeros, and a
 * null CopyScoreTo boundary.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.FreeFunctionMixinDispatchAndDefaults
 * @Harness UClass
 * @Tag Feature.Mixin.FreeFunctionMixinDispatchAndDefaults
 * @Provenance Theme: Feature.Mixin. WorldStory free-function mixin dispatch + default arguments.
 * @Provenance C++: AngelscriptCoverageMixinTests.cpp::FreeFunctionMixinDispatchAndDefaults
 * @Provenance Oracle after BeginPlay: bReady==true, Score==12 (5+7), OtherScore==15 (12+3).
 * @Provenance Extra: empty handle null; pre-BeginPlay false/0. FixtureIsolated. Keep bReady/Score/OtherScore.
 */

/**
 * Mixin that marks the host ready.
 *
 * @Kind Mixin
 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
 * @Inputs the host actor as Self
 * @Param Self the mixin receiver
 * @Return void; Self.bReady becomes true
 */
mixin void MarkReady(ACoverageMixinHostActor Self)
{
	Self.bReady = true;
}

/**
 * Mixin that adds to Score, defaulting the amount to 5.
 *
 * @Kind Mixin
 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
 * @Inputs the host actor and an optional amount
 * @Param Self the mixin receiver
 * @Param Amount the score delta, default 5
 * @Return void; Self.Score increases by Amount
 */
mixin void AddScore(ACoverageMixinHostActor Self, int Amount = 5)
{
	Self.Score += Amount;
}

/**
 * Mixin that copies Score onto another host with an optional bonus.
 *
 * @Kind Mixin
 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
 * @Inputs the host, another host, and an optional bonus
 * @Param Self the mixin receiver
 * @Param Other the destination host; ignored when null
 * @Param Bonus added to Self.Score, default 1
 * @Return void; Other.Score becomes Self.Score + Bonus when Other is non-null
 */
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

	/**
	 * WorldStory: MarkReady, AddScore with default then 7, CopyScoreTo a peer with bonus 3.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs a spawned ACoverageMixinPeerActor
	 * @Return bReady true, Score 12, OtherScore 15
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.MarkReady();
		this.AddScore();
		this.AddScore(7);

		ACoverageMixinHostActor Other = Cast<ACoverageMixinHostActor>(SpawnActor(ACoverageMixinPeerActor::StaticClass()));
		this.CopyScoreTo(Other, 3);
		if (Other != nullptr)
		{
			OtherScore = Other.Score;
			Other.DestroyActor();
		}
	}

	/**
	 * Observe that an unset host handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs an unset ACoverageMixinHostActor handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinHostActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the host is not ready and both scores are zero before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs this actor before BeginPlay
	 * @Return true when bReady is false and both scores are 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool DefaultsAreZero()
	{
		if (bReady)
		{
			return false;
		}
		if (Score != 0)
		{
			return false;
		}
		return OtherScore == 0;
	}

	/**
	 * Observe the BeginPlay oracle: ready, Score 12, OtherScore 15.
	 *
	 * @Kind Observe
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs this actor after BeginPlay
	 * @Return true when bReady is true, Score is 12 and OtherScore is 15
	 */
	UFUNCTION()
	bool ReadyScoreAfterPlay()
	{
		if (!bReady)
		{
			return false;
		}
		if (Score != 12)
		{
			return false;
		}
		return OtherScore == 15;
	}

	/**
	 * Observe that CopyScoreTo(nullptr) leaves OtherScore unchanged.
	 *
	 * @Kind Observe
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs this actor and a null destination
	 * @Return OtherScore after CopyScoreTo(nullptr, 3)
	 * @Boundary null destination
	 */
	UFUNCTION()
	int CopyScoreToNullLeavesOtherScore()
	{
		CopyScoreTo(nullptr, 3);
		return OtherScore;
	}
}

UCLASS()
class ACoverageMixinPeerActor : ACoverageMixinHostActor
{
	/**
	 * No-op BeginPlay keeps the spawned peer from recursively spawning more peers.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.FreeFunctionMixinDispatchAndDefaults
	 * @Inputs none
	 * @Return void; no recursive spawn
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
}
