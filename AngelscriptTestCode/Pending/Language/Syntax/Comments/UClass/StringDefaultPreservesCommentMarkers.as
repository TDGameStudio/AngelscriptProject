/**
 * @version v1
 * @summary Comment markers appearing inside default string literals. The lexer must treat them as data rather than as the start of a comment, so both properties keep their full literal text.
 * @topic Language
 */
/**
 * @version root
 * @summary Comment markers appearing inside default string literals. The lexer must treat them as data rather than as the start of a comment, so both properties keep their full literal text.
 * @topic Baseline
 */
UCLASS()
class UCompilerStringDefaultCarrier : UObject
{
	UPROPERTY()
	FString Message;

	UPROPERTY()
	FString BlockText;

	default Message = "He said \"//not a comment\"";
	default BlockText = "/*literal*/";

	/**
	 * Verifies that both defaults survived the lexer intact.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs the two default string UPROPERTYs
	 * @Return 42 on success, 10 or 20 naming the mismatched property
	 */
	UFUNCTION()
	int VerifyDefaults()
	{
		if (!(Message == "He said \"//not a comment\""))
		{
			return 10;
		}

		if (!(BlockText == "/*literal*/"))
		{
			return 20;
		}

		return 42;
	}

	/**
	 * Observe that both defaults read back unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs VerifyDefaults and the two properties
	 * @Return true when the verification passes and both literals match
	 */
	UFUNCTION()
	bool CommentMarkersSurviveInsideLiterals()
	{
		if (VerifyDefaults() != 42)
		{
			return false;
		}

		if (Message != "He said \"//not a comment\"")
		{
			return false;
		}

		return BlockText == "/*literal*/";
	}

	/**
	 * Observe that an empty string differs from both literals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs a default-constructed FString
	 * @Return true when it is empty and matches neither literal
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool EmptyStringDiffersFromCommentLiterals()
	{
		FString Empty;

		if (Empty.Len() != 0)
		{
			return false;
		}

		if (Empty == "He said \"//not a comment\"")
		{
			return false;
		}

		return Empty != "/*literal*/";
	}
}
/** @end */
