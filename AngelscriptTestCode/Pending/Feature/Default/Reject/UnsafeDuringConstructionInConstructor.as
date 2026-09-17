/**
 * @version v1
 * @summary Calling a method marked `unsafe_during_construction` from a constructor is rejected. This file is the illegal program itself; do not call UnsafeValue from Entry instead of the constructor.
 * @topic Feature
 */
/**
 * @version root
 * @summary Calling a method marked `unsafe_during_construction` from a constructor is rejected. This file is the illegal program itself; do not call UnsafeValue from Entry instead of the constructor.
 * @topic Negative
 */
class UnsafeConstructorCarrier
{
	int Value = 0;

	/**
	 * A method that is unsafe to call while the object is being constructed.
	 *
	 * @Kind CompileReject
	 * @Covers Default.UnsafeDuringConstruction
	 * @Inputs none
	 * @Return 7
	 */
	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	/**
	 * Constructor that illegally calls the unsafe method.
	 *
	 * @Kind CompileReject
	 * @Covers Default.UnsafeDuringConstruction
	 * @Inputs none
	 * @Return does not compile
	 */
	UnsafeConstructorCarrier()
	{
		Value = UnsafeValue();
	}
}

/**
 * Constructs the carrier so the illegal constructor is reached.
 *
 * @Kind CompileReject
 * @Covers Default.UnsafeDuringConstruction
 * @Inputs none
 * @Return does not compile
 */
int Entry()
{
	UnsafeConstructorCarrier@ Carrier = UnsafeConstructorCarrier();
	return Carrier.Value;
}
/** @end */
