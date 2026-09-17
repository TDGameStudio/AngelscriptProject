/**
 * @version v1
 * @summary A final class can be constructed but cannot be a base.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary A final class is usable as a concrete type.
 * @topic Baseline
 */
class ASealed final
{
	int Value;
}

int UseFinal()
{
	ASealed Object;
	Object.Value = 7;
	return Object.Value;
}
/** @end */
/**
 * @version invalid-inherit-from-final
 * @parent root
 * @summary Deriving from a final class is rejected.
 * @topic Negative
 */
class ASealed final
{
	int Value;
}

class AChild : ASealed
{
	int Extra;
}
/** @end */
