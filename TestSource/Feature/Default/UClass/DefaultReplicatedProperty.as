/**
 * A default statement on a Replicated bool. The CDO value is true after
 * `default bReplicates = true`, even though the inline initializer is false.
 * Instances stay independent.
 *
 * @Theme Feature.Default
 * @Subject Default.ReplicatedProperty
 * @Harness UClass
 * @Tag Feature.Default.DefaultReplicatedProperty
 * @Provenance Theme: Feature.Default. WorldStory default statement on a Replicated bool.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_AttrReplicated. Oracle: bReplicates==true after default bReplicates = true.
 * @Provenance Extra: empty handle is null; copy independence. Keep bReplicates.
 * @Provenance FixtureIsolated.
 */

class AAttrRepActor : AActor
{
	UPROPERTY(Replicated)
	bool bReplicates = false;

	default bReplicates = true;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrRepActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the default statement sets the replicated flag.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs a freshly constructed actor
	 * @Return true when bReplicates is true
	 */
	UFUNCTION()
	bool DefaultTrue()
	{
		return bReplicates;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds true
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrRepActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultReplicatedProperty setup: required Second is null");
		}
		bReplicates = false;
		return Second.bReplicates;
	}
}
