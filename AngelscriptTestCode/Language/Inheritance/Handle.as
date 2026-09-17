/**
 * @version v1
 * @summary A derived handle can be viewed as its base handle.
 * @topic Language
 * @topic Inheritance
 *
 * derived-handle-as-base    // Assigning a derived handle to a base handle exposes base fields.
 */
/**
 * @begin derived-handle-as-base
 * @summary Assigning a derived handle to a base handle exposes base fields.
 * @topic Inheritance
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Extra;
}

int UseHandle(AChild@ Child)
{
	ABase@ Parent = Child;
	return Parent.Value;
}
/** @end */
