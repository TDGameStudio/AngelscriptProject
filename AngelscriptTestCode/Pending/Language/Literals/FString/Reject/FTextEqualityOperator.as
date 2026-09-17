/**
 * @version v1
 * @summary Comparing two FTexts with the equality operator is rejected: this fork exposes no equality operator for text. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Language
 */
/**
 * @version root
 * @summary Comparing two FTexts with the equality operator is rejected: this fork exposes no equality operator for text. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Negative
 */
/** */
bool TryTextEqualsOperator()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("A");
	return Left == Right;
}
/** @end */
