/**
 * The compound plus-assign operator appends to an FString in place. Unlike the
 * binary plus, it mutates the destination, so the observers check the
 * destination after the append rather than a separate result.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringConcatenationPlusAssign
 * @Harness Function
 * @Tag Language.Literals.StringConcatenationPlusAssign
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 4 AssertCompiles.
 * @Provenance sha256=579289c89456a762869e55c4a2a32a6177a8dc6a943c0be72f96f09455e5784f; lines 81-83.
 * @Provenance Oracle: "Hello" += " World" yields "Hello World".
 * @Provenance Extra: empty += " World"; += "" leaves "Hello" unchanged.
 * @Provenance DefaultSafe. += mutates the destination.
 */

namespace LiteralsTest
{
	/**
	 * Observe that plus-assign appends in place.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "Hello" with " World" appended
	 * @Return true when the destination is "Hello World"
	 */
	UFUNCTION()
	bool ConcatPlusAssignNominal()
	{
		FString S = "Hello";
		S += " World";
		return S == "Hello World";
	}

	/**
	 * Observe the empty-destination boundary of plus-assign.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" with " World" appended
	 * @Return true when the destination is " World"
	 * @Boundary empty destination
	 */
	UFUNCTION()
	bool ConcatPlusAssignEmptyDestination()
	{
		FString S = "";
		S += " World";
		return S == " World";
	}

	/**
	 * Observe that appending an empty string is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "Hello" with "" appended
	 * @Return true when the destination is unchanged
	 * @Boundary empty append
	 */
	UFUNCTION()
	bool ConcatPlusAssignEmptyAppendBoundary()
	{
		FString S = "Hello";
		S += "";
		return S == "Hello";
	}
}
