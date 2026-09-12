# Move-FrontendPhases.ps1
# Purpose: git-mv reconstructed frontend leaves into Basic/Lexer/Parser/AST/Sema/Compile and rewrite #include "frontend/as_*".
# Dependencies: git, the Plugins/Angelscript checkout. Run once from any cwd; paths are absolute.
$ErrorActionPreference = 'Stop'
$plugin = 'd:\Workspace\AngelscriptProject\Plugins\Angelscript'
$sdkRel = 'Source/AngelscriptRuntime/angelscript'
$feRel = "$sdkRel/frontend"
$sdk = Join-Path $plugin $sdkRel
$fe = Join-Path $plugin $feRel

# From-name -> dest relative to frontend/ (phase/dest-name)
$moves = @{
	'as_source_location.h' = 'Basic/as_source_location.h'
	'as_source_manager.h' = 'Basic/as_source_manager.h'
	'as_frontend_source_manager.cpp' = 'Basic/as_source_manager.cpp'
	'as_source_snapshot.h' = 'Basic/as_source_snapshot.h'
	'as_source_snapshot.cpp' = 'Basic/as_source_snapshot.cpp'
	'as_source_provenance.h' = 'Basic/as_source_provenance.h'
	'as_source_provenance.cpp' = 'Basic/as_source_provenance.cpp'
	'as_diagnostics.h' = 'Basic/as_diagnostics.h'
	'as_diagnostics.cpp' = 'Basic/as_diagnostics.cpp'
	'as_character_stream.h' = 'Basic/as_character_stream.h'
	'as_identifier_table.h' = 'Basic/as_identifier_table.h'
	'as_identifier_table.cpp' = 'Basic/as_identifier_table.cpp'
	'as_language_surface.h' = 'Basic/as_language_surface.h'
	'as_language_surface.cpp' = 'Basic/as_language_surface.cpp'
	'as_function_modifiers.h' = 'Basic/as_function_modifiers.h'
	'as_canonical_encoding.h' = 'Basic/as_canonical_encoding.h'
	'as_canonical_encoding.cpp' = 'Basic/as_canonical_encoding.cpp'
	'as_stable_key.h' = 'Basic/as_stable_key.h'
	'as_stable_key.cpp' = 'Basic/as_stable_key.cpp'
	'as_token.h' = 'Lexer/as_token.h'
	'as_token_kinds.def' = 'Lexer/as_token_kinds.def'
	'as_tokenizer.h' = 'Lexer/as_tokenizer.h'
	'as_frontend_tokenizer.cpp' = 'Lexer/as_tokenizer.cpp'
	'as_preprocessor.h' = 'Lexer/as_preprocessor.h'
	'as_preprocessor.cpp' = 'Lexer/as_preprocessor.cpp'
	'as_preprocess_result.h' = 'Lexer/as_preprocess_result.h'
	'as_preprocess_result.cpp' = 'Lexer/as_preprocess_result.cpp'
	'as_preprocessing_record.h' = 'Lexer/as_preprocessing_record.h'
	'as_preprocessing_record.cpp' = 'Lexer/as_preprocessing_record.cpp'
	'as_directive_tree.h' = 'Lexer/as_directive_tree.h'
	'as_directive_tree.cpp' = 'Lexer/as_directive_tree.cpp'
	'as_directive_kinds.def' = 'Lexer/as_directive_kinds.def'
	'as_frontend_options.h' = 'Lexer/as_frontend_options.h'
	'as_parser.h' = 'Parser/as_parser.h'
	'as_frontend_parser.cpp' = 'Parser/as_parser.cpp'
	'as_frontend_parser_statements.cpp' = 'Parser/as_parser_statements.cpp'
	'as_frontend_parser_access.cpp' = 'Parser/as_parser_access.cpp'
	'as_type_syntax.h' = 'Parser/as_type_syntax.h'
	'as_type_syntax_parser.h' = 'Parser/as_type_syntax_parser.h'
	'as_type_syntax_parser.cpp' = 'Parser/as_type_syntax_parser.cpp'
	'as_ast_fwd.h' = 'AST/as_ast_fwd.h'
	'as_ast_cast.h' = 'AST/as_ast_cast.h'
	'as_ast_context.h' = 'AST/as_ast_context.h'
	'as_frontend_ast_context.cpp' = 'AST/as_ast_context.cpp'
	'as_ast_visitor.h' = 'AST/as_ast_visitor.h'
	'as_ast_verifier.h' = 'AST/as_ast_verifier.h'
	'as_frontend_ast_verifier.cpp' = 'AST/as_ast_verifier.cpp'
	'as_ast_codec.h' = 'AST/as_ast_codec.h'
	'as_ast_codec.cpp' = 'AST/as_ast_codec.cpp'
	'as_ast_projection.h' = 'AST/as_ast_projection.h'
	'as_ast_projection.cpp' = 'AST/as_ast_projection.cpp'
	'as_decl.h' = 'AST/as_decl.h'
	'as_frontend_decl.cpp' = 'AST/as_decl.cpp'
	'as_decl_nodes.def' = 'AST/as_decl_nodes.def'
	'as_stmt.h' = 'AST/as_stmt.h'
	'as_frontend_stmt.cpp' = 'AST/as_stmt.cpp'
	'as_stmt_nodes.def' = 'AST/as_stmt_nodes.def'
	'as_expr.h' = 'AST/as_expr.h'
	'as_frontend_expr.cpp' = 'AST/as_expr.cpp'
	'as_attr.h' = 'AST/as_attr.h'
	'as_attr.cpp' = 'AST/as_attr.cpp'
	'as_attr_nodes.def' = 'AST/as_attr_nodes.def'
	'as_type.h' = 'AST/as_type.h'
	'as_type.cpp' = 'AST/as_type.cpp'
	'as_type_nodes.def' = 'AST/as_type_nodes.def'
	'as_type_loc.h' = 'AST/as_type_loc.h'
	'as_type_loc.cpp' = 'AST/as_type_loc.cpp'
	'as_type_context.h' = 'AST/as_type_context.h'
	'as_type_context.cpp' = 'AST/as_type_context.cpp'
	'as_sema.h' = 'Sema/as_sema.h'
	'as_frontend_sema.cpp' = 'Sema/as_sema.cpp'
	'as_frontend_sema_access.cpp' = 'Sema/as_sema_access.cpp'
	'as_frontend_sema_conversion.cpp' = 'Sema/as_sema_conversion.cpp'
	'as_frontend_sema_initializer.cpp' = 'Sema/as_sema_initializer.cpp'
	'as_frontend_sema_postfix.cpp' = 'Sema/as_sema_postfix.cpp'
	'as_frontend_sema_statements.cpp' = 'Sema/as_sema_statements.cpp'
	'as_constant_evaluator.h' = 'Sema/as_constant_evaluator.h'
	'as_constant_evaluator.cpp' = 'Sema/as_constant_evaluator.cpp'
	'as_body_fragment.h' = 'Sema/as_body_fragment.h'
	'as_body_fragment.cpp' = 'Sema/as_body_fragment.cpp'
	'as_body_lifetime.h' = 'Sema/as_body_lifetime.h'
	'as_body_lifetime.cpp' = 'Sema/as_body_lifetime.cpp'
	'as_declaration_fragment.h' = 'Sema/as_declaration_fragment.h'
	'as_declaration_fragment.cpp' = 'Sema/as_declaration_fragment.cpp'
	'as_list_initializer.h' = 'Sema/as_list_initializer.h'
	'as_external_semantics.h' = 'Sema/as_external_semantics.h'
	'as_type_identity.h' = 'Sema/as_type_identity.h'
	'as_type_identity.cpp' = 'Sema/as_type_identity.cpp'
	'as_compilation_session.h' = 'Compile/as_compilation_session.h'
	'as_compilation_session.cpp' = 'Compile/as_compilation_session.cpp'
	'as_compilation_session_access.cpp' = 'Compile/as_compilation_session_access.cpp'
	'as_compilation_session_constants.cpp' = 'Compile/as_compilation_session_constants.cpp'
	'as_compilation_session_inference.cpp' = 'Compile/as_compilation_session_inference.cpp'
	'as_compilation_session_lists.cpp' = 'Compile/as_compilation_session_lists.cpp'
	'as_compilation_session_records.cpp' = 'Compile/as_compilation_session_records.cpp'
	'as_compilation_session_types.cpp' = 'Compile/as_compilation_session_types.cpp'
	'as_builder_stages.h' = 'Compile/as_builder_stages.h'
	'as_binding_declaration.h' = 'Compile/as_binding_declaration.h'
	'as_binding_declaration.cpp' = 'Compile/as_binding_declaration.cpp'
	'as_definition_consumer.h' = 'Compile/as_definition_consumer.h'
	'as_definition_consumer.cpp' = 'Compile/as_definition_consumer.cpp'
	'as_descriptor_consumer.h' = 'Compile/as_descriptor_consumer.h'
	'as_descriptor_consumer.cpp' = 'Compile/as_descriptor_consumer.cpp'
	'as_dependency_graph.h' = 'Compile/as_dependency_graph.h'
	'as_dependency_graph.cpp' = 'Compile/as_dependency_graph.cpp'
}

$current = @(Get-ChildItem -LiteralPath $fe -File | ForEach-Object Name)
$missing = @($current | Where-Object { -not $moves.ContainsKey($_) })
$extra = @($moves.Keys | Where-Object { $_ -notin $current })
if ($missing.Count -or $extra.Count) {
	throw "Map mismatch. Unmapped: $($missing -join ', '); Missing on disk: $($extra -join ', ')"
}

foreach ($phase in @('Basic', 'Lexer', 'Parser', 'AST', 'Sema', 'Compile')) {
	New-Item -ItemType Directory -Force -Path (Join-Path $fe $phase) | Out-Null
}

foreach ($from in ($moves.Keys | Sort-Object)) {
	$src = "$feRel/$from"
	$dst = "$feRel/$($moves[$from])"
	& git -C $plugin mv -- $src $dst
	if ($LASTEXITCODE -ne 0) { throw "git mv failed: $src -> $dst" }
}

& git -C $plugin mv -- "$sdkRel/as_builder_frontend.cpp" "$sdkRel/as_builder.cpp"
if ($LASTEXITCODE -ne 0) { throw 'git mv as_builder_frontend.cpp failed' }

$includePairs = foreach ($from in $moves.Keys) {
	if ($from -notmatch '\.(h|def)$') { continue }
	[pscustomobject]@{
		Old = "frontend/$from"
		New = "frontend/$($moves[$from])"
	}
}
$includePairs = @($includePairs | Sort-Object { $_.Old.Length } -Descending)

$roots = @(
	(Join-Path $plugin 'Source/AngelscriptRuntime')
	(Join-Path $plugin 'Source/AngelscriptTest')
	(Join-Path $plugin 'Source/AngelscriptEditor')
)
$edited = 0
foreach ($root in $roots) {
	if (-not (Test-Path $root)) { continue }
	Get-ChildItem -LiteralPath $root -Recurse -File -Include *.h, *.cpp, *.inl | ForEach-Object {
		$text = [System.IO.File]::ReadAllText($_.FullName)
		$next = $text
		foreach ($pair in $includePairs) {
			$next = $next.Replace($pair.Old, $pair.New)
		}
		if ($next -cne $text) {
			[System.IO.File]::WriteAllText($_.FullName, $next)
			$edited++
		}
	}
}

Write-Output "Moved $($moves.Count) frontend files + as_builder.cpp; rewrote includes in $edited files."
