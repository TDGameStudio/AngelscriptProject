/**
 * @version v1
 * @summary Two classes cannot share a name in one module.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary A single named class is valid.
 * @topic Baseline
 */
class ANode
{
	int X;
}

int UseOne()
{
	ANode Object;
	Object.X = 1;
	return Object.X;
}
/** @end */
/**
 * @version invalid-duplicate-class-name
 * @parent root
 * @summary Repeating the same class name is rejected.
 * @topic Negative
 */
class ANode
{
	int X;
}

class ANode
{
	int Y;
}
/** @end */
