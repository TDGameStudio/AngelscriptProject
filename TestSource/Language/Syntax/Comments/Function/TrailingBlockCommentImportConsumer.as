/**
 * A block comment trailing an import statement. The comment is stripped rather
 * than folded into the module name, so the import still resolves.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.TrailingBlockCommentImportConsumer
 * @Harness Function
 * @Tag Language.Syntax.Comments.TrailingBlockCommentImportConsumer
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::TrailingBlockCommentDoesNotPolluteModuleName block 2
 * @Provenance sha256=02b3da2c75b71e7a9e8ed9e2b27d5a9f7f76d380896e81101b7bf90d0ac47f5d; lines 246-252.
 * @Provenance Oracle: Entry() == 11; import name is Tests.Preprocessor.ImportTrailingBlockComment.Shared not the comment text.
 * @Provenance Extra: Entry matches SharedValue. DefaultSafe.
 */

import Tests.Preprocessor.ImportTrailingBlockComment.Shared /* shared helpers */;

namespace SyntaxTest
{
	/**
	 * Returns the value imported through the commented statement.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs the imported SharedValue
	 * @Return 11
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the trailing comment did not pollute the module name.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool TrailingCommentDoesNotPolluteImport()
	{
		return Entry() == 11;
	}

	/**
	 * Observe that the consumed value equals the provider's directly.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Entry() and SharedValue()
	 * @Return true when the two agree
	 * @Boundary provider match
	 */
	UFUNCTION()
	bool TrailingCommentImportMatchesProvider()
	{
		return Entry() == SharedValue();
	}
}
