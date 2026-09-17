/**
 * @version v1
 * @summary Fields inherited through an intermediate class.
 * @topic Language
 * @topic Inheritance
 *
 * nested                     // A grandchild reads fields declared on each ancestor.
 * middle-reads-root-field    // A middle instance can read a field declared on its base.
 */
/**
 * @begin nested
 * @summary A grandchild reads fields declared on each ancestor.
 * @topic Inheritance
 */
class ARoot
{
	int Id;
}

class AMiddle : ARoot
{
	int Extra;
}

class ALeaf : AMiddle
{
	int Leaf;
}

int UseChain()
{
	ALeaf Object;
	Object.Id = 1;
	Object.Extra = 2;
	Object.Leaf = 3;
	return Object.Id + Object.Extra + Object.Leaf;
}
/** @end */
/**
 * @begin middle-reads-root-field
 * @summary A middle instance can read a field declared on its base.
 * @topic Inheritance
 */
class ARoot
{
	int Id;
}

class AMiddle : ARoot
{
	int Extra;
}

int UseMiddle()
{
	AMiddle Object;
	Object.Id = 4;
	return Object.Id;
}
/** @end */
