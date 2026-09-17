/**
 * @version v1
 * @summary Assigning a string literal to an FString stores the literal's text. The assignment copies by value, so a default FString is empty and mutating the source afterwards leaves the copy at the original literal.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning a string literal to an FString stores the literal's text. The assignment copies by value, so a default FString is empty and mutating the source afterwards leaves the copy at the original literal.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Observe that a literal assignment reads back the literal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString S = "Hello World"
	 * @Return true when S equals "Hello World"
	 */
	UFUNCTION()
	bool LiteralAssignmentNominal()
	{
		FString S = "Hello World";
		return S == "Hello World";
	}

	/**
	 * Observe the default empty boundary of an unassigned FString.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A default-constructed FString
	 * @Return true when its length is 0
	 * @Boundary default empty string
	 */
	UFUNCTION()
	bool LiteralEmptyDefault()
	{
		FString Empty;
		return Empty.Len() == 0;
	}

	/**
	 * Observe that assignment copies by value rather than by alias.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of a literal, then the source changed
	 * @Return true when the copy keeps the original literal
	 */
	UFUNCTION()
	bool LiteralCopyIndependence()
	{
		FString S = "Hello World";
		FString Copy = S;
		S = "changed";
		return Copy == "Hello World";
	}
}
/** @end */
