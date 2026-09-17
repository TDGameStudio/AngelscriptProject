/**
 * @version v1
 * @summary Null handle assignment, comparison, and cast forms.
 * @topic Language
 * @topic Casting
 */
/**
 * @version root
 * @summary A reference class handle assigned null and compared with is-null.
 * @topic Baseline
 */
class ANode
{
	int Value;
}

bool NullptrHandleAssignment()
{
	ANode@ Node = null;
	return Node is null;
}

bool NullptrComparison(ANode@ Node)
{
	if (Node is null)
	{
		return true;
	}
	return Node !is null;
}

bool CastNullptrIsNull()
{
	ANode@ Node = null;
	ANode@ Casted = cast<ANode>(Node);
	return Casted is null;
}
/** @end */
/**
 * @version invalid-null-to-value
 * @parent root
 * @summary A value type cannot be assigned null.
 * @topic Negative
 */
void Test()
{
	int X = null;
}
/** @end */
/**
 * @version invalid-nullptr-arithmetic
 * @parent root
 * @summary Compile-rejection form retained from legacy nullptr arithmetic.
 * @topic Negative
 */
void Test()
{
	int X = nullptr + 1;
}
/** @end */
/**
 * @version invalid-nullptr-to-bool
 * @parent root
 * @summary Compile-rejection form retained from legacy nullptr to bool.
 * @topic Negative
 */
void Test()
{
	bool B = nullptr;
}
/** @end */
/**
 * @version invalid-nullptr-to-float
 * @parent root
 * @summary Compile-rejection form retained from legacy nullptr to float.
 * @topic Negative
 */
void Test()
{
	float X = nullptr;
}
/** @end */
/**
 * @version invalid-nullptr-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy nullptr to int.
 * @topic Negative
 */
void Test()
{
	int X = nullptr;
}
/** @end */
/**
 * @version valid-cast-nullptr-is-null
 * @parent root
 * @summary Casting a null handle yields null.
 * @topic Casting
 */
class ANode
{
	int Value;
}

bool CastNull()
{
	ANode@ Node = null;
	return cast<ANode>(Node) is null;
}
/** @end */
/**
 * @version valid-nullptr-comparison
 * @parent root
 * @summary is-null and not-is-null on a handle.
 * @topic Casting
 */
class ANode
{
	int Value;
}

bool Compare(ANode@ Node)
{
	return Node is null || Node !is null;
}
/** @end */
/**
 * @version invalid-nullptr-to-struct
 * @parent root
 * @summary A script struct value cannot be assigned null.
 * @topic Negative
 */
struct FBox
{
	int X;
}

void Test()
{
	FBox Value = null;
}
/** @end */
