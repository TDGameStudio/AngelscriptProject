/**
 * @version v1
 * @summary A using directive that opens a whole namespace is rejected: this fork does not support importing every symbol from a namespace. Callers must use qualified names instead. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A using directive that opens a whole namespace is rejected: this fork does not support importing every symbol from a namespace. Callers must use qualified names instead. This file is the illegal program itself.
 * @topic Negative
 */
namespace Math
{
/** */
	int Add(int A, int B)
	{
		return A + B;
	}
}

/** */
int UseNamespace()
{
	using namespace Math;
	return Add(10, 20);
}
/** @end */
