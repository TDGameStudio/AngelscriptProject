/**
 * @version v1
 * @summary Compile-fail cases for Interface Implement.
 * @topic Language
 * @topic Interface
 *
 * invalid-missing-interface-method     // A class that lists an interface but omits its method is rejected.
 * invalid-wrong-interface-signature    // A class method that does not match the interface signature is rejected.
 * invalid-multiple-object-bases        // A class may not list two class types as bases.
 */
/**
 * @begin invalid-missing-interface-method
 * @summary A class that lists an interface but omits its method is rejected.
 * @topic Negative
 */
interface INamed
{
	int GetId();
}

class APerson : INamed
{
}
/** @end */
/**
 * @begin invalid-wrong-interface-signature
 * @summary A class method that does not match the interface signature is rejected.
 * @topic Negative
 */
interface INamed
{
	int GetId();
}

class APerson : INamed
{
	int GetId(int Unused)
	{
		return Unused;
	}
}
/** @end */
/**
 * @begin invalid-multiple-object-bases
 * @summary A class may not list two class types as bases.
 * @topic Negative
 */
class ALeft
{
}

class ARight
{
}

class AChild : ALeft, ARight
{
}
/** @end */
