/**
 * @version v1
 * @summary Relational and equality comparison forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * comparison
 * string-equality-operator
 */
/**
 * @begin comparison
 * @summary Equality, inequality, and ordered comparisons on integers and floats.
 */
int EqualInt()
{
	return (1 == 1) ? 1 : 0;
}

int NotEqualInt()
{
	return (1 != 2) ? 1 : 0;
}

int LessInt()
{
	return (1 < 2) ? 1 : 0;
}

int LessEqualInt()
{
	return (2 <= 2) ? 1 : 0;
}

int GreaterInt()
{
	return (3 > 2) ? 1 : 0;
}

int GreaterEqualInt()
{
	return (3 >= 3) ? 1 : 0;
}

int CompareFloat()
{
	return (1.0f < 2.5f) ? 1 : 0;
}
/** @end */
/**
 * @begin string-equality-operator
 * @summary String equality and inequality.
 * @topic Operators
 */
bool Equal()
{
	return "a" == "a";
}

bool Unequal()
{
	return "a" != "b";
}
/** @end */
