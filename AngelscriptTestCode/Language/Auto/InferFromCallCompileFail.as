/**
 * @version v1
 * @summary Auto inference forms from calls that do not compile.
 * @topic Language
 * @topic Auto
 *
 * auto-void                          // auto Value = NoValue() is rejected because the callee returns void.
 * invalid-auto-void-type             // Void is not a legal auto initializer type name.
 * invalid-constructor-wrong-arity    // Auto cannot construct AHost with an argument the class does not accept.
 * invalid-auto-from-void-method      // auto Value = Object.NoValue() is rejected because the method returns void.
 */
/**
 * @begin auto-void
 * @summary auto Value = NoValue() is rejected because the callee returns void.
 * @topic Negative
 */
void NoValue()
{
}

void Test()
{
	auto Value = NoValue();
}
/** @end */
/**
 * @begin invalid-auto-void-type
 * @summary Void is not a legal auto initializer type name.
 * @topic Negative
 */
void Test()
{
	auto Value = void;
}
/** @end */
/**
 * @begin invalid-constructor-wrong-arity
 * @summary Auto cannot construct AHost with an argument the class does not accept.
 * @topic Negative
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

void Test()
{
	auto Object = AHost(4);
}
/** @end */
/**
 * @begin invalid-auto-from-void-method
 * @summary auto Value = Object.NoValue() is rejected because the method returns void.
 * @topic Negative
 */
class AHost
{
	void NoValue()
	{
	}
}

void Test()
{
	AHost Object;
	auto Value = Object.NoValue();
}
/** @end */
