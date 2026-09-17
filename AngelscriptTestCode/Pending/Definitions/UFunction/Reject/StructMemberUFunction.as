/**
 * @version v1
 * @summary A USTRUCT may not declare UFUNCTION members. Structs are value types and do not generate UFunction objects. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT may not declare UFUNCTION members. Structs are value types and do not generate UFunction objects. This file is the illegal program itself.
 * @topic Negative
 */
USTRUCT()
struct FBadFunctionStruct
{
	/**
	 * Illegal UFUNCTION on a USTRUCT member.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() int BadMember()
	 * @Return does not compile
	 */
	UFUNCTION()
	int BadMember()
	{
		return 1;
	}
}
/** @end */
