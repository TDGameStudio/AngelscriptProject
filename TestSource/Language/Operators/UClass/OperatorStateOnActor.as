/**
 * Operators applied to state held on a script actor, so the results survive
 * across method calls and C++ can read them by path. The actor accumulates a
 * score through compound assignment, guards a threshold with a comparison, and
 * packs a set of capability flags into one int through bitwise operators —
 * the same operator set as the Function files, but exercised against object
 * state rather than against locals.
 * The UPROPERTY names are read by path from C++ and must not be renamed:
 * Score, bAboveThreshold, CapabilityMask, bHasCapability, GrowthCount.
 *
 * @Theme Language.Operators
 * @Subject Operators.OperatorStateOnActor
 * @Harness UClass
 * @Tag Language.Operators.OperatorStateOnActor
 * @Namespace OperatorsTest
 */

UCLASS()
class ACoverageOperatorStateActor : AActor
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	bool bAboveThreshold = false;

	UPROPERTY()
	int CapabilityMask = 0;

	UPROPERTY()
	bool bHasCapability = false;

	UPROPERTY()
	int GrowthCount = 0;

	/**
	 * Add to the score and count how many times it has grown, using compound
	 * assignment against object state.
	 *
	 * @Covers Operators.Assignment
	 * @Param Amount Added onto the score
	 * @Inputs A positive or negative amount
	 * @Return the score after the addition
	 */
	UFUNCTION()
	int AddScore(int Amount)
	{
		Score += Amount;
		GrowthCount += 1;
		return Score;
	}

	/**
	 * Compare the score against a threshold and record the outcome.
	 *
	 * @Covers Operators.Comparison
	 * @Param Threshold Compared against the current score
	 * @Inputs Any threshold
	 * @Return true when the score is at or above the threshold
	 */
	UFUNCTION()
	bool CheckThreshold(int Threshold)
	{
		bAboveThreshold = (Score >= Threshold);
		return bAboveThreshold;
	}

	/**
	 * Grant one capability by or-ing it into the mask.
	 *
	 * @Covers Operators.Bitwise
	 * @Param Capability The bit to grant
	 * @Inputs A single capability bit
	 * @Return true when the capability is held afterwards
	 */
	UFUNCTION()
	bool GrantCapability(int Capability)
	{
		CapabilityMask |= Capability;
		bHasCapability = ((CapabilityMask & Capability) == Capability);
		return bHasCapability;
	}

	/**
	 * Clear one capability by and-ing it out of the mask.
	 *
	 * @Covers Operators.Bitwise
	 * @Param Capability The bit to clear
	 * @Inputs A single capability bit, held or absent
	 * @Return true when the capability is gone afterwards
	 */
	UFUNCTION()
	bool RevokeCapability(int Capability)
	{
		CapabilityMask &= ~Capability;
		bHasCapability = ((CapabilityMask & Capability) == Capability);
		return !bHasCapability;
	}
}

namespace OperatorsTest
{
	const int Cap_Dash  = 0x01;
	const int Cap_Jump  = 0x02;
	const int Cap_Fly   = 0x04;

	/**
	 * Observe compound assignment against object state: repeated additions
	 * accumulate, and the growth counter tracks them.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Assignment
	 * @Inputs Spawn the actor, add three times, then read score and count
	 * @Return true when the score is 60 and the count is 3
	 */
	UFUNCTION()
	bool CompoundAssignmentAccumulatesOnObject()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.AddScore(10);
		Actor.AddScore(20);
		int Final = Actor.AddScore(30);
		if (Final != 60)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.Score != 60)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.GrowthCount == 3);
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe comparison against a threshold, in both directions.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the actor, add 25, then check thresholds of 20 and 30
	 * @Return true when the first passes and the second does not
	 */
	UFUNCTION()
	bool ThresholdComparisonHoldsBothWays()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.AddScore(25);
		bool bPassed = Actor.CheckThreshold(20);
		bool bFailed = Actor.CheckThreshold(30);
		if (!bPassed)
		{
			Actor.DestroyActor();
			return false;
		}
		if (bFailed)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = Actor.bAboveThreshold == false;
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe the bitwise capability protocol against object state: granting
	 * two capabilities leaves both held, and revoking one leaves the other.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Bitwise
	 * @Inputs Spawn the actor, grant dash and fly, then revoke dash
	 * @Return true when fly survives and dash is gone
	 */
	UFUNCTION()
	bool CapabilityMaskSurvivesRevocation()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.GrantCapability(Cap_Dash);
		Actor.GrantCapability(Cap_Fly);
		if (Actor.CapabilityMask != (Cap_Dash | Cap_Fly))
		{
			Actor.DestroyActor();
			return false;
		}

		bool bRevoked = Actor.RevokeCapability(Cap_Dash);
		if (!bRevoked)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.CapabilityMask != Cap_Fly)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.CapabilityMask & Cap_Dash) == 0;
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe the default boundary: a freshly spawned actor starts at zero
	 * score and with no capabilities.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Assignment
	 * @Inputs Spawn the actor and read its initial state
	 * @Return true when the score, count, and mask are all zero
	 * @Boundary freshly spawned defaults
	 */
	UFUNCTION()
	bool SpawnedActorStartsAtZeroState()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		if (Actor.Score != 0)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.GrowthCount != 0)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.CapabilityMask == 0);
		Actor.DestroyActor();
		return bOk;
	}
}
