/**
 * @version v1
 * @summary Null handle assignment, comparison, and cast forms.
 * @topic Language
 * @topic Casting
 *
 * handle-null-assignment             // A reference class handle assigned nullptr and compared with nullptr.
 * handle-null-comparison             // Equality and inequality against nullptr on a handle.
 * cast-null-is-null                  // Casting a nullptr handle yields nullptr.
 * handle-null-then-is-null           // Assign nullptr to a handle, then compare with nullptr.
 * handle-assign-null-after-object    // Replace a constructed handle with nullptr.
 */
/**
 * @begin handle-null-assignment
 * @summary A reference class handle assigned nullptr and compared with nullptr.
 */
class ANode
{
	int Value;
}

bool Assigned()
{
	ANode@ Node = nullptr;
	return Node == nullptr;
}
/** @end */
/**
 * @begin handle-null-comparison
 * @summary Equality and inequality against nullptr on a handle.
 */
class ANode
{
	int Value;
}

bool Compare(ANode@ Node)
{
	if (Node == nullptr)
	{
		return true;
	}
	return Node != nullptr;
}
/** @end */
/**
 * @begin cast-null-is-null
 * @summary Casting a nullptr handle yields nullptr.
 */
class ANode
{
	int Value;
}

bool CastNull()
{
	ANode@ Node = nullptr;
	return Cast<ANode>(Node) == nullptr;
}
/** @end */
/**
 * @begin handle-null-then-is-null
 * @summary Assign nullptr to a handle, then compare with nullptr.
 */
class ANode
{
	int Value;
}

bool AssignedThenCompared()
{
	ANode@ Node;
	Node = nullptr;
	return Node == nullptr;
}
/** @end */
/**
 * @begin handle-assign-null-after-object
 * @summary Replace a constructed handle with nullptr.
 */
class ANode
{
	int Value;
}

bool ClearedAfterObject()
{
	ANode@ Node = ANode();
	Node = nullptr;
	return Node == nullptr;
}
/** @end */
