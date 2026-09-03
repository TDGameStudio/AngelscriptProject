/**
 * A default statement calling inherited SetReplicates(true) on a pawn. The
 * pawn reports GetIsReplicated() true. Two spawned handles remain distinct.
 *
 * @Theme Feature.Default
 * @Subject Default.InheritedSetReplicates
 * @Harness UClass
 * @Tag Feature.Default.DefaultInheritedSetReplicates
 * @Provenance Theme: Feature.Default. Positive default statement calling inherited SetReplicates.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_AttrInherited. Oracle: GetIsReplicated() is true.
 * @Provenance Extra: empty handle is null; two spawned pawns remain distinct.
 * @Provenance DefaultSafe.
 */

class AMyPawn : APawn
{
	/**
	 * Marks the pawn replicated on the CDO.
	 *
	 * @Covers Default.InheritedSetReplicates
	 * @Inputs none
	 * @Return nothing; GetIsReplicated() becomes true
	 */
	default SetReplicates(true);

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.InheritedSetReplicates
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AMyPawn Pawn;
		return Pawn == nullptr;
	}

	/**
	 * Observe that the inherited default call marked the pawn replicated.
	 *
	 * @Kind Observe
	 * @Covers Default.InheritedSetReplicates
	 * @Inputs a freshly constructed pawn
	 * @Return true when GetIsReplicated() is true
	 */
	UFUNCTION()
	bool SetReplicatesTrue()
	{
		return GetIsReplicated();
	}

	/**
	 * Observe that two spawned handles remain distinct.
	 *
	 * @Kind Observe
	 * @Covers Default.InheritedSetReplicates
	 * @Inputs this pawn compared against a second pawn
	 * @Return true when the handles are not the same
	 * @Param Second the other pawn
	 * @Boundary two handles
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(AMyPawn Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultInheritedSetReplicates setup: required Second is null");
		}
		return this != Second;
	}
}
