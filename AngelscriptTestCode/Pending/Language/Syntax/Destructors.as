/**
 * @version v1
 * @summary Script-declared destructors on classes and structs.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A class with an empty declared destructor.
 * @topic Baseline
 */
class ANode
{
	int Value;

	~ANode()
	{
	}
}

int UseDeclared()
{
	ANode Object;
	Object.Value = 4;
	return Object.Value;
}
/** @end */
/**
 * @version valid-struct-destructor
 * @parent root
 * @summary A struct may declare a destructor.
 * @topic Syntax
 */
struct FPoint
{
	int X;

	~FPoint()
	{
	}
}

int UseStruct()
{
	FPoint Value;
	Value.X = 8;
	return Value.X;
}
/** @end */
/**
 * @version valid-base-and-derived-destructors
 * @parent root
 * @summary Base and derived types may each declare a destructor.
 * @topic Syntax
 */
class ABase
{
	int BaseValue;

	~ABase()
	{
	}
}

class AChild : ABase
{
	int ChildValue;

	~AChild()
	{
	}
}

int UseBoth()
{
	AChild Object;
	Object.BaseValue = 1;
	Object.ChildValue = 2;
	return Object.BaseValue + Object.ChildValue;
}
/** @end */
/**
 * @version invalid-destructor-with-parameter
 * @parent root
 * @summary A destructor cannot take a parameter.
 * @topic Negative
 */
class ANode
{
	~ANode(int Invalid)
	{
	}
}
/** @end */
/**
 * @version invalid-destructor-wrong-name
 * @parent root
 * @summary A destructor name must match its type.
 * @topic Negative
 */
class ANode
{
	~AOther()
	{
	}
}
/** @end */
/**
 * @version invalid-global-destructor
 * @parent root
 * @summary A destructor cannot be declared at global scope.
 * @topic Negative
 */
~ANode()
{
}
/** @end */
