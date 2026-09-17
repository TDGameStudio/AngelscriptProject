/**
 * @version v1
 * @summary A default statement inside a struct is rejected. Default statements belong on UCLASS / actor class bodies. This file is the illegal program itself; do not move default onto a UCLASS.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement inside a struct is rejected. Default statements belong on UCLASS / actor class bodies. This file is the illegal program itself; do not move default onto a UCLASS.
 * @topic Negative
 */
struct FAttrStruct
{
	int X = 0;

	default X = 5;
}
/** @end */
