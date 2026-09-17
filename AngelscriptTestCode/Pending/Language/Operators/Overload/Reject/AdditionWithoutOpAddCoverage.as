/**
 * @version v1
 * @summary Using + on a type that declares no opAdd is rejected. This is the coverage suite's counterpart of ../Reject/AdditionWithoutOpAdd, which comes from the syntax suite; both are kept because their C++ sources differ. This.
 * @topic Language
 */
/**
 * @version root
 * @summary Using + on a type that declares no opAdd is rejected. This is the coverage suite's counterpart of ../Reject/AdditionWithoutOpAdd, which comes from the syntax suite; both are kept because their C++ sources differ. This.
 * @topic Negative
 */
struct FNoPlus
{
	int Value = 0;
}

/** */
void Test()
{
	FNoPlus A;
	FNoPlus B;
	FNoPlus C = A + B;
}
/** @end */
