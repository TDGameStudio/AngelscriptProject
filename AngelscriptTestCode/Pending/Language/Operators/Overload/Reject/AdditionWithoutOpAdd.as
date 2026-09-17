/**
 * @version v1
 * @summary Using + on a type that declares no opAdd is rejected: there is no operator to dispatch to. This file is the illegal program itself; do not add opAdd or anything else that would make it compile, since the missing operator.
 * @topic Language
 */
/**
 * @version root
 * @summary Using + on a type that declares no opAdd is rejected: there is no operator to dispatch to. This file is the illegal program itself; do not add opAdd or anything else that would make it compile, since the missing operator.
 * @topic Negative
 */
struct FMyType
{
	int X = 0;
}

/** */
void Test()
{
	FMyType A;
	FMyType B;
	FMyType C = A + B;
}
/** @end */
