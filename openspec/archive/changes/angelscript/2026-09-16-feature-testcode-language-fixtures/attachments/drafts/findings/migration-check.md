# Creation-time migration check

- The accepted inventory contains 47 distinct FileTags in six directories; the 80-120 estimate and separate Const directory are historical.
- Current `python AngelscriptTestCode/CodeGenTool/codegen.py check` passed before creation. No generate command or fixture mutation ran.
- GeneratedSourcesTests.cpp and AdoptionTests.cpp query production Counter. GeneratedSources also checks exact clean bytes, positional annotations, origin mapping, shared metadata and structured format=v2 activation without runtime source parsing. Replacement must preserve these assertions, not just change the lookup string.
- Python test_source_parser.py reads production Counter at two sites. Existing renderer Counter lacks the production annotations; preserve a dedicated parser fixture before deleting the author file.
- Synthetic Counter strings in ParserTests/BuilderTests/DatabaseTests and tool tests are isolated inputs, not public providers; retain them.
- Existing documentation incorrectly describes the pre-structured projection. Current discovery -> parse_source_file -> render_projection provides parsed metadata/source structures to C++ Builder registration. Update only the affected documentation to current truth.
- ForeachValueReference uses TArray/TMap and DirectiveInString uses FString. Pure-language migration requires adaptation or an explicit lexical SourceOnly boundary, not verbatim copying of those host declarations.
- StructFields anchors exist in Syntax/EdgeCases/Function, not a guessed Syntax/Struct path. The exact inventory lists repository-resolved paths.
- No full semantic review of all legacy programs or execution of AS is claimed by this creation check.
