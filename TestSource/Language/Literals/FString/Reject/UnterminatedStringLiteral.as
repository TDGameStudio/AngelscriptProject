/**
 * A string literal that opens a quote and never closes it is rejected: the
 * lexer reaches the end of the line without finding the closing quote. This
 * file is the illegal program itself; do not add the missing quote, since the
 * unterminated literal is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.UnterminatedStringLiteral
 * @Harness CompileReject
 * @Tag Language.Literals.UnterminatedStringLiteral
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FString S = "unterminated; with no closing quote
 * @Return does not compile; diagnostic "unterminated string literal"
 */

void Test()
{
	FString S = "unterminated;
}
