/**
 * @version v1
 * @summary The public member keyword is rejected on a UCLASS. AngelScript UCLASS members do not use C++ public/private keywords as property introducers.
 * @topic Definitions
 */
/**
 * @version root
 * @summary The public member keyword is rejected on a UCLASS. AngelScript UCLASS members do not use C++ public/private keywords as property introducers.
 * @topic Negative
 */
UCLASS()
class AAccessModifierPublicKeywordBoundary : AActor
{
	public int UnsupportedPublicKeyword = 1;
}
/** @end */
