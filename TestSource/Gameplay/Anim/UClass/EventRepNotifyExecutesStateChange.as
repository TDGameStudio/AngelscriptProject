/**
 * A RepNotify path that applies replicated health and records the notify. C++ verifies
 * TrackedHealth, RepNotifyCount, LastReplicatedHealth and bRepNotifyExecuted by path after
 * ApplyReplicatedHealth(87), so those UPROPERTY names are part of the contract and are
 * kept verbatim. The observers cover the empty defaults and the zero-health boundary.
 *
 * @Theme Gameplay.Anim
 * @Subject Anim.EventRepNotifyExecutesStateChange
 * @Harness UClass
 * @Tag Gameplay.Anim.EventRepNotifyExecutesStateChange
 * @Provenance Theme: Gameplay.Anim. WorldStory RepNotify state-change event path.
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventRepNotifyExecutesStateChange
 * @Provenance Oracle VerifyByPath after ApplyReplicatedHealth(87): TrackedHealth 87,
 * @Provenance RepNotifyCount 1, LastReplicatedHealth 87, bRepNotifyExecuted true.
 * @Provenance Extra: defaults 0/false; ApplyReplicatedHealth(0) is the zero boundary.
 * @Provenance FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageEventRepNotifyActor : AActor
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedHealth)
	int TrackedHealth = 0;

	UPROPERTY()
	int RepNotifyCount = 0;

	UPROPERTY()
	int LastReplicatedHealth = 0;

	UPROPERTY()
	bool bRepNotifyExecuted = false;

	/**
	 * Apply a replicated health value and invoke the RepNotify by hand.
	 *
	 * @Kind Action
	 * @Covers Anim.EventRepNotifyExecutesStateChange
	 * @Inputs the new health
	 * @Return TrackedHealth written and OnRep_TrackedHealth run
	 * @Param NewHealth the replicated health to apply
	 */
	UFUNCTION()
	void ApplyReplicatedHealth(int NewHealth)
	{
		TrackedHealth = NewHealth;
		OnRep_TrackedHealth();
	}

	/**
	 * Record that replicated health changed.
	 *
	 * @Kind Action
	 * @Covers Anim.EventRepNotifyExecutesStateChange
	 * @Inputs none
	 * @Return RepNotifyCount incremented, LastReplicatedHealth updated, bRepNotifyExecuted true
	 */
	UFUNCTION()
	void OnRep_TrackedHealth()
	{
		RepNotifyCount += 1;
		LastReplicatedHealth = TrackedHealth;
		bRepNotifyExecuted = true;
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Anim.EventRepNotifyExecutesStateChange
	 * @Inputs none
	 * @Return true when health, count and flags are 0/false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TrackedHealth != 0)
		{
			return false;
		}
		if (RepNotifyCount != 0)
		{
			return false;
		}
		if (LastReplicatedHealth != 0)
		{
			return false;
		}
		return bRepNotifyExecuted == false;
	}

	/**
	 * Observe that applying 87 records the notify once.
	 *
	 * @Kind Observe
	 * @Covers Anim.EventRepNotifyExecutesStateChange
	 * @Inputs none
	 * @Return true when health is 87, count is 1 and the flag is true
	 */
	UFUNCTION()
	bool Apply87()
	{
		ApplyReplicatedHealth(87);

		if (TrackedHealth != 87)
		{
			return false;
		}
		if (RepNotifyCount != 1)
		{
			return false;
		}
		if (LastReplicatedHealth != 87)
		{
			return false;
		}
		return bRepNotifyExecuted == true;
	}

	/**
	 * Observe that applying 0 is the zero-health boundary and still notifies.
	 *
	 * @Kind Observe
	 * @Covers Anim.EventRepNotifyExecutesStateChange
	 * @Inputs none
	 * @Return true when health is 0, count is 1 and the flag is true
	 * @Boundary zero health
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		ApplyReplicatedHealth(0);

		if (TrackedHealth != 0)
		{
			return false;
		}
		if (RepNotifyCount != 1)
		{
			return false;
		}
		if (LastReplicatedHealth != 0)
		{
			return false;
		}
		return bRepNotifyExecuted == true;
	}
}
