/**
 * @version v1
 * @summary A UFUNCTION annotation must close its parenthesis list. UFUNCTION( without a matching ) is illegal and the method that follows cannot be parsed. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION annotation must close its parenthesis list. UFUNCTION( without a matching ) is illegal and the method that follows cannot be parsed. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncMisParenActor : AActor
{
	UFUNCTION( void Foo() { }
}
/** @end */
