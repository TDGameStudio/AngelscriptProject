/**
 * @version v1
 * @summary Implicit conversions that must not compile.
 * @topic Language
 * @topic Casting
 *
 * invalid-implicit-struct-to-int
 * invalid-implicit-array-to-int
 * invalid-implicit-int-to-bool
 * invalid-implicit-string-to-int
 */
/**
 * @begin invalid-implicit-struct-to-int
 * @summary A struct cannot convert implicitly to int.
 * @topic Negative
 */
struct FBox
{
	int X;
}

void Test()
{
	FBox Value;
	int X = Value;
}
/** @end */
/**
 * @begin invalid-implicit-array-to-int
 * @summary Compile-rejection form retained from legacy implicit array to int.
 * @topic Negative
 */
void Test()
{
	array<int> Arr;
	int X = Arr;
}
/** @end */
/**
 * @begin invalid-implicit-int-to-bool
 * @summary Compile-rejection form retained from legacy implicit int to bool.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	bool B = X;
}
/** @end */
/**
 * @begin invalid-implicit-string-to-int
 * @summary Compile-rejection form retained from legacy implicit string to int.
 * @topic Negative
 */
void Test()
{
	string S = "5";
	int X = S;
}
/** @end */
