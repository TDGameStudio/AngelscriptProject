/**
 * @version v1
 * @summary Conditional-expression forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary A ternary selecting between two integer arms.
 * @topic Baseline
 */
int Pick(bool Flag)
{
	return Flag ? 1 : 2;
}

int NestedPick(bool First, bool Second)
{
	return First ? (Second ? 1 : 2) : 3;
}
/** @end */
/**
 * @version invalid-ternary-non-bool-condition
 * @parent root
 * @summary The ternary condition must be boolean.
 * @topic Negative
 */
int Test()
{
	return 1 ? 2 : 3;
}
/** @end */
/**
 * @version invalid-ternary-mismatched-arms
 * @parent root
 * @summary Ternary arms must share a common type.
 * @topic Negative
 */
void Test(bool Flag)
{
	int X = Flag ? 1 : true;
}
/** @end */
/**
 * @version invalid-ternary-branch-type-mismatch
 * @parent root
 * @summary Compile-rejection form retained from legacy ternary branch type mismatch.
 * @topic Negative
 */
void Test()
{
	auto X = true ? 1 : "hello";
}
/** @end */
/**
 * @version invalid-ternary-float-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy ternary float condition.
 * @topic Negative
 */
void Test()
{
	int X = 1.0f ? 1 : 0;
}
/** @end */
/**
 * @version invalid-ternary-missing-colon
 * @parent root
 * @summary Compile-rejection form retained from legacy ternary missing colon.
 * @topic Negative
 */
void Test()
{
	int X = true ? 1;
}
/** @end */
/**
 * @version invalid-ternary-missing-true-branch
 * @parent root
 * @summary Compile-rejection form retained from legacy ternary missing true branch.
 * @topic Negative
 */
void Test()
{
	int X = true ? : 0;
}
/** @end */
/**
 * @version invalid-ternary-string-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy ternary string condition.
 * @topic Negative
 */
void Test()
{
	int X = "yes" ? 1 : 0;
}
/** @end */
/**
 * @version valid-nested-ternary
 * @parent root
 * @summary A ternary nested in both arms of an outer ternary.
 * @topic Operators
 */
int Nested(int Value)
{
	return Value > 0 ? (Value > 10 ? 2 : 1) : 0;
}
/** @end */
/**
 * @version valid-ternary-as-return
 * @parent root
 * @summary A function whose body is a single ternary return.
 * @topic Operators
 */
int Sign(int Value)
{
	return Value < 0 ? -1 : Value == 0 ? 0 : 1;
}
/** @end */
