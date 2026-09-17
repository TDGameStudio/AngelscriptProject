/**
 * @version v1
 * @summary Null handle assignment, comparison, and cast forms.
 * @topic Language
 * @topic Casting
 *
 * handle-null-assignment
 * handle-null-comparison
 * cast-null-is-null
 */
/**
 * @begin handle-null-assignment
 * @summary A reference class handle assigned null and compared with is-null.
 * @topic Casting
 */
class ANode
{
	int Value;
}

/**
 * @function NullptrHandleAssignment
 * @summary A reference class handle assigned null and compared with is-null.
 * @covers null assignment
 * @inputs none
 * @return true when the handle is null
 */
bool NullptrHandleAssignment()
{
	ANode@ Node = null;
	return Node is null;
}
/** @end */
/**
 * @begin handle-null-comparison
 * @summary is-null and not-is-null on a handle.
 * @topic Casting
 */
class ANode
{
	int Value;
}

/**
 * @function Compare
 * @summary is-null and not-is-null on a handle.
 * @covers is null
 * @inputs an ANode@ that may be null
 * @return true when the handle is null or not null
 */
bool Compare(ANode@ Node)
{
	if (Node is null)
	{
		return true;
	}
	return Node !is null;
}
/** @end */
/**
 * @begin cast-null-is-null
 * @summary Casting a null handle yields null.
 * @topic Casting
 */
class ANode
{
	int Value;
}

/**
 * @function CastNull
 * @summary Casting a null handle yields null.
 * @covers cast of null
 * @inputs none
 * @return true when the cast result is null
 */
bool CastNull()
{
	ANode@ Node = null;
	return cast<ANode>(Node) is null;
}
/** @end */
