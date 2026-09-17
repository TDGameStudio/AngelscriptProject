/**
 * @version v1
 * @summary An FName literal is written with the n"..." prefix and carries a name rather than text. Names compare case-insensitively, so a literal differing only in case denotes the same name. NAME_None is the empty name and is what.
 * @topic Language
 */
/**
 * @version root
 * @summary An FName literal is written with the n"..." prefix and carries a name rather than text. Names compare case-insensitively, so a literal differing only in case denotes the same name. NAME_None is the empty name and is what.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Observe that a name literal builds the same name as the string form.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs n"MyName" compared against FName("MyName")
	 * @Return true when the literal and the constructed name match
	 */
	UFUNCTION()
	bool NameLiteralMatchesConstructedName()
	{
		FName N = n"MyName";
		return N == FName("MyName");
	}

	/**
	 * Observe the None boundary: a named literal is not the empty name.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs n"MyName" compared against NAME_None
	 * @Return true when the literal is not the empty name
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool NamedLiteralIsNotNone()
	{
		FName N = n"MyName";
		return N != NAME_None;
	}

	/**
	 * Observe that names compare case-insensitively: two literals differing
	 * only in case denote the same name.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs n"myname" compared against n"MyName"
	 * @Return true when the two literals denote the same name
	 */
	UFUNCTION()
	bool NameComparisonIgnoresCase()
	{
		return n"myname" == n"MyName";
	}

	/**
	 * Observe the None default: NAME_None equals a default-constructed FName.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs NAME_None compared against an uninitialised FName
	 * @Return true when both are the empty name
	 * @Boundary default name
	 */
	UFUNCTION()
	bool NoneMatchesDefaultConstructedName()
	{
		FName N = NAME_None;
		FName DefaultName;
		if (N != NAME_None)
		{
			return false;
		}
		return N == DefaultName;
	}

	/**
	 * Observe the named boundary of None: the empty name differs from a named
	 * one.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs NAME_None compared against n"MyName"
	 * @Return true when the two differ
	 */
	UFUNCTION()
	bool NoneDiffersFromNamedLiteral()
	{
		return NAME_None != n"MyName";
	}

	/**
	 * Observe copy independence: assigning a name to a copy and then resetting
	 * the original leaves the copy holding the old name.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs Copy a named literal, then set the original to NAME_None
	 * @Return true when the copy keeps the name and the original is empty
	 */
	UFUNCTION()
	bool NameCopyIsIndependent()
	{
		FName N = n"MyName";
		FName Copy = N;
		N = NAME_None;
		if (Copy != n"MyName")
		{
			return false;
		}
		return N == NAME_None;
	}
}
/** @end */
