/**
 * @version v1
 * @summary An operator overload declared at global scope is rejected: operators are declared as members of the type they operate on. This file is the illegal program itself; do not move the declaration into a type, since the global.
 * @topic Language
 */
/**
 * @version root
 * @summary An operator overload declared at global scope is rejected: operators are declared as members of the type they operate on. This file is the illegal program itself; do not move the declaration into a type, since the global.
 * @topic Negative
 */
/** */
int opAdd(int A, int B)
{
	return A + B;
}
/** @end */
