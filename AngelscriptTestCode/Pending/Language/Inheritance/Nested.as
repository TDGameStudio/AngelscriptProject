/**
 * @version v1
 * @summary Fields inherited through an intermediate class.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary A grandchild reads fields declared on each ancestor.
 * @topic Baseline
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
 * @version valid-middle-reads-root-field
 * @parent root
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
/**
 * @version invalid-unknown-ancestor-field
 * @parent root
 * @summary A name not declared on any ancestor cannot be read.
 * @topic Negative
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

int Test()
{
	ALeaf Object;
	return Object.Missing;
}
/** @end */
