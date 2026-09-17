/**
 * @version v1
 * @summary A using declaration that names a single symbol is rejected: this fork does not support pulling one symbol out of a namespace. Callers must use the qualified name instead. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A using declaration that names a single symbol is rejected: this fork does not support pulling one symbol out of a namespace. Callers must use the qualified name instead. This file is the illegal program itself.
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
int UseSpecificFunction()
{
	using Math::Add;
	return Add(10, 20);
}
/** @end */
