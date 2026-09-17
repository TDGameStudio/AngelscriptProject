/**
 * @version v1
 * @summary A `default` statement whose value does not match the property type is rejected. This file is the illegal program itself; do not change the value's type, since the mismatch is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A `default` statement whose value does not match the property type is rejected. This file is the illegal program itself; do not change the value's type, since the mismatch is the point.
 * @topic Negative
 */
UCLASS()
class UDefaultTypeMismatchCarrier : UObject
{
	UPROPERTY()
	int MyInt;

	default MyInt = "not an int";
}
/** @end */
