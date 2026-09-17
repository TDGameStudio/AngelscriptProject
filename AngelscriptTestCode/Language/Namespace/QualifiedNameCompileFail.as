/**
 * @version v1
 * @summary Compile-fail cases for QualifiedName.
 * @topic Language
 * @topic Namespace
 *
 * invalid-unknown-qualifier            // A qualifier that names no namespace is invalid.
 * invalid-namespace-anonymous          // Compile-rejection form retained from legacy namespace anonymous.
 * invalid-namespace-missing-member     // Compile-rejection form retained from legacy namespace missing member.
 * invalid-namespace-undeclared         // Compile-rejection form retained from legacy namespace undeclared.
 * invalid-namespace-using-directive    // Compile-rejection form retained from legacy namespace using directive.
 * invalid-namespace-using-symbol       // Compile-rejection form retained from legacy namespace using symbol.
 */
/**
 * @begin invalid-unknown-qualifier
 * @summary A qualifier that names no namespace is invalid.
 * @topic Negative
 */
int Test()
{
	return Missing::Offset();
}
/** @end */
/**
 * @begin invalid-namespace-anonymous
 * @summary Compile-rejection form retained from legacy namespace anonymous.
 * @topic Negative
 */
namespace
{
	int X;
}
/** @end */
/**
 * @begin invalid-namespace-missing-member
 * @summary Compile-rejection form retained from legacy namespace missing member.
 * @topic Negative
 */
int X = 1;
/** @end */
/**
 * @begin invalid-namespace-undeclared
 * @summary Compile-rejection form retained from legacy namespace undeclared.
 * @topic Negative
 */
void Test()
{
	int X = FakeNamespace::Value;
}
/** @end */
/**
 * @begin invalid-namespace-using-directive
 * @summary Compile-rejection form retained from legacy namespace using directive.
 * @topic Negative
 */
int Add(int A, int B)
	{
		return A + B;
	}
/** @end */
/**
 * @begin invalid-namespace-using-symbol
 * @summary Compile-rejection form retained from legacy namespace using symbol.
 * @topic Negative
 */
int Add(int A, int B)
	{
		return A + B;
	}
/** @end */
