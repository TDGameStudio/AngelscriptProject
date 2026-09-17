/**
 * @version v1
 * @summary Declaring the same operator twice in one type is rejected. This is the coverage suite's counterpart of ../Reject/DuplicateOpAdd, which comes from the syntax suite; both are kept because their C++ sources differ. This.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring the same operator twice in one type is rejected. This is the coverage suite's counterpart of ../Reject/DuplicateOpAdd, which comes from the syntax suite; both are kept because their C++ sources differ. This.
 * @topic Negative
 */
struct FDuplicateOp
{
	/**
	 * The first of two identical opAdd declarations.
	 */
	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}

	/**
	 * The second of two identical opAdd declarations.
	 */
	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}
}
/** @end */
