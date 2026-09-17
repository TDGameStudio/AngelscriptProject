/**
 * @version v1
 * @summary A mixin reads and writes UPROPERTY state, first through a null link then a spawned peer. C++ expects after BeginPlay: bSawNullLinkedActor==true, bCopiedLinkedScore==true, Score==43, LinkedScoreAfterMixin==44.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin reads and writes UPROPERTY state, first through a null link then a spawned peer. C++ expects after BeginPlay: bSawNullLinkedActor==true, bCopiedLinkedScore==true, Score==43, LinkedScoreAfterMixin==44.
 * @topic Baseline
 */
/**
 * Mixin that copies LinkedActor.Score plus Bonus, then adds 4 to the linked score.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
 * @Inputs the host actor as Self
 * @Param Self the mixin receiver
 * @Return false when LinkedActor is null; true after the copy
 */
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

/**
 * Mixin that writes Marker.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
 * @Inputs the host actor and a marker name
 * @Param Self the mixin receiver
 * @Param Marker the name to store
 * @Return void; Self.Marker becomes Marker
 */
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

	/**
	 * WorldStory: CopyLinkedScore on a null link, then on a peer with Score 40, then ApplyNameMarker.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs a spawned ACoverageMixinPropertyPeerActor
	 * @Return bSawNullLinkedActor true, bCopiedLinkedScore true, Score 43, LinkedScoreAfterMixin 44, Marker MixinTouchedProperty
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bCopiedLinkedScore = this.CopyLinkedScore();

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

	/**
	 * Observe that an unset host handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs an unset ACoverageMixinPropertyActor handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinPropertyActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that LinkedActor, Marker and Score start unset.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs this actor before BeginPlay
	 * @Return true when LinkedActor is null, Marker is NAME_None and Score is 0
	 * @Boundary default LinkedActor
	 */
	UFUNCTION()
	bool DefaultLinkedNull()
	{
		if (LinkedActor != nullptr)
		{
			return false;
		}
		if (Marker != NAME_None)
		{
			return false;
		}
		return Score == 0;
	}

	/**
	 * Observe the BeginPlay oracle: null-link seen, copy succeeded, scores 43/44, marker set.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs this actor after BeginPlay
	 * @Return true when bSawNullLinkedActor, bCopiedLinkedScore, Score 43, LinkedScoreAfterMixin 44 and Marker MixinTouchedProperty
	 */
	UFUNCTION()
	bool LinkedScoreAfterPlay()
	{
		if (!bSawNullLinkedActor)
		{
			return false;
		}
		if (!bCopiedLinkedScore)
		{
			return false;
		}
		if (Score != 43)
		{
			return false;
		}
		if (LinkedScoreAfterMixin != 44)
		{
			return false;
		}
		return Marker == n"MixinTouchedProperty";
	}

	/**
	 * Observe that ApplyNameMarker can write an empty name.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs ApplyNameMarker(n"")
	 * @Return Marker after the write
	 * @Boundary empty marker
	 */
	UFUNCTION()
	FName EmptyMarkerBoundary()
	{
		ApplyNameMarker(n"");
		return Marker;
	}
}

UCLASS()
class ACoverageMixinPropertyPeerActor : ACoverageMixinPropertyActor
{
	/**
	 * No-op BeginPlay keeps the linked peer from recursively spawning.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinReadsAndWritesUPropertyBoundaries
	 * @Inputs none
	 * @Return void; no recursive spawn
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
}
/** @end */
