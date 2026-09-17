/**
 * @version v1
 * @summary A namespace declaration must be followed by an opening brace. Omitting it is a syntax error, and the preprocessor emits no processed code even though the chunks it recognised survive. This file is the illegal program.
 * @topic Language
 */
/**
 * @version root
 * @summary A namespace declaration must be followed by an opening brace. Omitting it is a syntax error, and the preprocessor emits no processed code even though the chunks it recognised survive. This file is the illegal program.
 * @topic Negative
 */
namespace Gameplay
UCLASS()
class UBrokenNamespaceCarrier : UObject
{
}

/**
 * A plain entry point outside the malformed namespace. It never runs, since no
 * processed code is emitted at all.
 *
 * @Covers Preprocessor.Namespaces
 * @Inputs none
 * @Return 7, never reached
 */
int Entry()
{
	return 7;
}
/** @end */
