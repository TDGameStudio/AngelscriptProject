@{
	SchemaVersion = 1

	AxisSets = @{
		SignedIntegers = @('int8', 'int16', 'int', 'int64')
		UnsignedIntegers = @('uint8', 'uint16', 'uint', 'uint64')
		SignedOrFloatingTypes = @('int8', 'int16', 'int', 'int64', 'float32', 'float64')
		FloatingTypes = @('float32', 'float64')
		IntegralTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64')
		NumericTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64')
		PrimitiveTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool')
		AssignmentLegalPairs = @(
			'assign_int8', 'assign_int16', 'assign_int', 'assign_int64', 'assign_uint8', 'assign_uint16', 'assign_uint', 'assign_uint64', 'assign_float32', 'assign_float64', 'assign_bool',
			'add_assign_int8', 'add_assign_int16', 'add_assign_int', 'add_assign_int64', 'add_assign_uint8', 'add_assign_uint16', 'add_assign_uint', 'add_assign_uint64', 'add_assign_float32', 'add_assign_float64',
			'subtract_assign_int8', 'subtract_assign_int16', 'subtract_assign_int', 'subtract_assign_int64', 'subtract_assign_uint8', 'subtract_assign_uint16', 'subtract_assign_uint', 'subtract_assign_uint64', 'subtract_assign_float32', 'subtract_assign_float64',
			'multiply_assign_int8', 'multiply_assign_int16', 'multiply_assign_int', 'multiply_assign_int64', 'multiply_assign_uint8', 'multiply_assign_uint16', 'multiply_assign_uint', 'multiply_assign_uint64', 'multiply_assign_float32', 'multiply_assign_float64',
			'divide_assign_int8', 'divide_assign_int16', 'divide_assign_int', 'divide_assign_int64', 'divide_assign_uint8', 'divide_assign_uint16', 'divide_assign_uint', 'divide_assign_uint64', 'divide_assign_float32', 'divide_assign_float64',
			'power_assign_int8', 'power_assign_int16', 'power_assign_int', 'power_assign_int64', 'power_assign_uint8', 'power_assign_uint16', 'power_assign_uint', 'power_assign_uint64', 'power_assign_float32', 'power_assign_float64',
			'modulo_assign_int8', 'modulo_assign_int16', 'modulo_assign_int', 'modulo_assign_int64', 'modulo_assign_uint8', 'modulo_assign_uint16', 'modulo_assign_uint', 'modulo_assign_uint64', 'modulo_assign_float32', 'modulo_assign_float64',
			'and_assign_int8', 'and_assign_int16', 'and_assign_int', 'and_assign_int64', 'and_assign_uint8', 'and_assign_uint16', 'and_assign_uint', 'and_assign_uint64',
			'or_assign_int8', 'or_assign_int16', 'or_assign_int', 'or_assign_int64', 'or_assign_uint8', 'or_assign_uint16', 'or_assign_uint', 'or_assign_uint64',
			'xor_assign_int8', 'xor_assign_int16', 'xor_assign_int', 'xor_assign_int64', 'xor_assign_uint8', 'xor_assign_uint16', 'xor_assign_uint', 'xor_assign_uint64',
			'shift_left_assign_int8', 'shift_left_assign_int16', 'shift_left_assign_int', 'shift_left_assign_int64', 'shift_left_assign_uint8', 'shift_left_assign_uint16', 'shift_left_assign_uint', 'shift_left_assign_uint64',
			'shift_right_logical_assign_int8', 'shift_right_logical_assign_int16', 'shift_right_logical_assign_int', 'shift_right_logical_assign_int64', 'shift_right_logical_assign_uint8', 'shift_right_logical_assign_uint16', 'shift_right_logical_assign_uint', 'shift_right_logical_assign_uint64',
			'shift_right_arithmetic_assign_int8', 'shift_right_arithmetic_assign_int16', 'shift_right_arithmetic_assign_int', 'shift_right_arithmetic_assign_int64', 'shift_right_arithmetic_assign_uint8', 'shift_right_arithmetic_assign_uint16', 'shift_right_arithmetic_assign_uint', 'shift_right_arithmetic_assign_uint64'
		)
		AssignmentTypeRejectionPairs = @(
			'add_assign_bool', 'subtract_assign_bool', 'multiply_assign_bool', 'divide_assign_bool', 'modulo_assign_bool', 'power_assign_bool', 'and_assign_bool', 'or_assign_bool', 'xor_assign_bool', 'shift_left_assign_bool', 'shift_right_logical_assign_bool', 'shift_right_arithmetic_assign_bool',
			'and_assign_float32', 'or_assign_float32', 'xor_assign_float32', 'shift_left_assign_float32', 'shift_right_logical_assign_float32', 'shift_right_arithmetic_assign_float32',
			'and_assign_float64', 'or_assign_float64', 'xor_assign_float64', 'shift_left_assign_float64', 'shift_right_logical_assign_float64', 'shift_right_arithmetic_assign_float64'
		)
		CoreValueTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef', 'script_value', 'native_value')
		CoreReferenceTypes = @('script_reference', 'native_reference')
		VariableTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef', 'script_value', 'native_value', 'script_reference', 'native_reference')
		PropertyIndexTypes = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef')
		ParameterDirections = @('value', 'in', 'out', 'inout')
		ParameterPositions = @('first', 'middle', 'last')
		EvidencePaths = @('normal', 'early_return', 'exception')
		OptimizationModes = @('off', 'on')
		Newlines = @('lf', 'crlf')
	}

	Products = @(
		@{
			Id = 'LANG-DECL-FAMILY-SCOPE-ORDER'
			SourceCatalog = 'declarations.md'
			Theme = 'Declarations'
			Element = 'declaration publication and lookup'
			Axes = @{
				Family = @('function', 'method', 'class', 'struct', 'field', 'constructor', 'destructor', 'namespace', 'enum', 'typedef', 'funcdef', 'import', 'virtual_property', 'indexed_property', 'mixin_global')
				Scope = @('global', 'namespace', 'nested_namespace', 'member', 'multiple_sections', 'imported_module')
				Ordering = @('before_use', 'forward_use', 'same_section', 'later_section', 'reversed_sections', 'rebuild')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Runtime', 'Cleanup')
			Expected = 'The legal declaration is published under the exact owner and remains usable for the selected order, or its theme-specific rejection row supplies the exact diagnostic.'
			Owner = 'Language/Declarations/AngelscriptNativeDeclarationPublicationTests.cpp|FDeclarationPublicationTests|DeclarationFamiliesByScopeAndOrder'
		}
		@{
			Id = 'LANG-DECL-COLLISION'
			SourceCatalog = 'declarations.md'
			Theme = 'Declarations'
			Element = 'declaration name collision'
			Axes = @{
				Pair = @('function_overload', 'function_duplicate', 'function_type', 'function_enum', 'type_duplicate', 'type_enum', 'enum_duplicate', 'method_overload', 'method_duplicate', 'method_field', 'method_property', 'field_duplicate', 'field_property', 'property_get_set', 'property_duplicate_get', 'property_duplicate_set')
				NamespaceRelation = @('same', 'different', 'nested')
				InsertionOrder = @('left_then_right', 'right_then_left')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup')
			Expected = 'Legal function/method overloads, complementary property accessors, or namespace separation publish both declarations exactly; illegal same-owner collisions fail atomically in either insertion order with one owning diagnostic and a clean rebuild.'
			Owner = 'Language/Declarations/AngelscriptNativeDeclarationCollisionTests.cpp|FDeclarationCollisionTests|PairsByNamespaceRelationAndInsertionOrder'
		}
		@{
			Id = 'LANG-DECL-FAILURE-RECOVERY'
			SourceCatalog = 'declarations.md'
			Theme = 'Declarations'
			Element = 'malformed declaration rejection and recovery'
			Axes = @{
				Form = @('unbalanced_class', 'bad_parameter_list', 'unclosed_function_body', 'missing_type_name', 'unexpected_handle', 'unknown_base')
				Placement = @('entry_body', 'after_valid_function', 'inside_namespace')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Every malformed declaration form is rejected at each placement and line ending with diagnostics, no partial Entry, module discard, and same-name recovery execution.'
			Owner = 'Language/Declarations/AngelscriptNativeDeclarationFailureRecoveryTests.cpp|FDeclarationFailureRecoveryTests|MalformedDeclarationsRecoverAcrossPlacementAndLineEnding'
		}
		@{
			Id = 'LANG-FN-PARAM-DIRECTION'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'one-parameter transfer and writeback'
			Axes = @{
				Type = 'CoreValueTypes'
				Direction = 'ParameterDirections'
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Exact declaration metadata, input transfer, output writeback, ABI width, and lifecycle counters match the type and direction.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp|FFunctionParameterDirectionTests|ParameterTypesByDirection'
		}
		@{
			Id = 'LANG-FN-PARAM-POSITION'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'three-parameter slot order'
			Axes = @{
				Type = 'CoreValueTypes'
				Position = 'ParameterPositions'
				Direction = 'ParameterDirections'
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Sentinels prove the selected ABI slot and only the designated out or inout argument is written.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionParameterPositionTests.cpp|FFunctionParameterPositionTests|ParameterTypesByPositionAndDirection'
		}
		@{
			Id = 'LANG-FN-SIGNATURE-SHAPE'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'function signature shape and transfer pattern'
			Axes = @{
				Arity = @('one', 'two', 'three', 'four')
				TypePattern = @('homogeneous_int', 'homogeneous_float', 'alternating_int_float', 'alternating_float_int')
				DirectionPattern = @('all_value', 'all_in', 'all_out', 'alternating_inout_out')
				Target = @('global', 'namespace_global', 'instance_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Every arity/type/direction/target combination publishes the exact parameter count, scalar type IDs, direction flags, return value, and caller writeback for out or inout parameters.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionSignatureShapeTests.cpp|FFunctionSignatureShapeTests|SignaturesByArityTypeDirectionAndTarget'
		}
		@{
			Id = 'LANG-FN-ARITY-TARGET'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'parameter-list arity and call target'
			Axes = @{
				Arity = @('zero', 'one', 'two', 'three', 'eight', 'current_boundary', 'boundary_plus_one')
				Target = @('global', 'namespace_global', 'instance_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Legal arity calls preserve slot order and exact declaration identity at the configured 64/65 stress points; an isolated wrong-count call proves deterministic boundary rejection without inventing an unsupported fixed maximum.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionArityTests.cpp|FFunctionArityTests|AritiesByCallTarget'
		}
		@{
			Id = 'LANG-FN-ARITY-TYPE-STRESS'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'parameter-list scale and scalar type arrangement'
			Axes = @{
				Arity = @('zero', 'one', 'two', 'four', 'eight', 'sixteen', 'thirty_two', 'sixty_four')
				TypePattern = @('homogeneous_int', 'homogeneous_bool', 'alternating_int_bool', 'alternating_bool_int')
				Target = @('global', 'namespace_global', 'instance_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Every parameter-list scale from zero through sixty-four publishes the exact slot count, scalar type arrangement, normalized by-value flags, declaration names, target-specific lookup, and stable runtime aggregation across global, namespace, and instance calls.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionArityTypeStressTests.cpp|FFunctionArityTypeStressTests|AritiesByTypePatternAndCallTarget'
		}
		@{
			Id = 'LANG-FN-DEFAULTS'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'default argument omission and selection'
			Axes = @{
				Pattern = @('final_one', 'final_many', 'all_optional', 'explicit_override', 'mixed_omitted_provided', 'non_trailing_invalid', 'type_invalid', 'earlier_parameter_reference_invalid')
				Omission = @('none', 'one', 'many')
				Target = @('global', 'namespace_global', 'instance_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'The exact callable and default expressions are selected, or the invalid declaration/call yields one stable diagnostic.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionDefaultArgumentTests.cpp|FFunctionDefaultArgumentTests|DefaultPatternsByOmissionAndTarget'
		}
		@{
			Id = 'LANG-FN-TYPED-DEFAULTS'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'typed default expressions across arity and call target'
			Axes = @{
				ArityAndOmission = @(
					'one_omit0', 'one_omit1',
					'two_omit0', 'two_omit1', 'two_omit2',
					'three_omit0', 'three_omit1', 'three_omit2', 'three_omit3',
					'four_omit0', 'four_omit1', 'four_omit2', 'four_omit3', 'four_omit4'
				)
				TypePattern = @('homogeneous_int', 'homogeneous_bool', 'alternating_int_bool', 'alternating_bool_int')
				Target = @('global', 'namespace_global', 'instance_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Every typed default declaration preserves its scalar type, parameter order, canonical expression text, and normalized by-value flag while every arity-valid trailing omission count is exercised and the global, namespace, and instance call paths execute the expected mixed int/bool result.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionTypedDefaultArgumentTests.cpp|FFunctionTypedDefaultArgumentTests|TypedDefaultsByArityPatternTargetAndOmission'
		}
		@{
			Id = 'LANG-FN-RETURN'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'return type and control path'
			Axes = @{
				Type = @('void', 'int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef', 'script_value', 'script_reference', 'null_reference')
				Path = @('direct', 'if_else', 'switch', 'early', 'recursive_base', 'exception', 'missing_invalid', 'incompatible_invalid')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'The type-correct context accessor observes the returned value and lifecycle, or the invalid path fails with an exact diagnostic.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionReturnTests.cpp|FFunctionReturnTests|ReturnTypesByControlPath'
		}
		@{
			Id = 'LANG-FN-OVERLOAD'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'overload discrimination'
			Axes = @{
				Discriminator = @('type', 'arity', 'const', 'direction', 'namespace', 'default', 'conversion')
				Outcome = @('exact', 'promotion', 'ambiguous', 'missing')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Function identity and runtime marker prove the selected overload; ambiguous and missing calls report only their owning resolution failure.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionOverloadResolutionTests.cpp|FFunctionOverloadResolutionTests|DiscriminatorsByOutcome'
		}
		@{
			Id = 'LANG-FN-ARG-SOURCE'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'argument source legality'
			Axes = @{
				Source = @('literal', 'local_lvalue', 'const_local', 'global_const', 'field', 'function_return', 'arithmetic_expression', 'conditional_expression', 'null', 'base_view', 'derived_view')
				Direction = 'ParameterDirections'
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Lifecycle')
			Expected = 'Legal sources transfer or write back exactly; illegal temporary, null, or const outputs are rejected at the call site.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionArgumentSourceTests.cpp|FFunctionArgumentSourceTests|ArgumentSourcesByDirection'
		}
		@{
			Id = 'LANG-FN-RECURSION'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'recursive invocation depth'
			Axes = @{
				Depth = @('zero', 'one', 'eight', 'configured_limit')
				Type = @('primitive', 'value_object', 'reference_object')
				Outcome = @('return', 'exception')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'Recursion returns or raises the configured exception with balanced objects, exact stack metadata, and reusable context.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionRecursionTests.cpp|FFunctionRecursionTests|DepthsByTypeAndOutcome'
		}
		@{
			Id = 'LANG-FN-INDIRECT-REGISTERED-FUNCDEF'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'registered funcdef indirect call'
			Axes = @{
				Scenario = @('declaration_metadata', 'compatible_direct', 'compatible_nested', 'null_or_unbound', 'incompatible_signature', 'rebuild_or_rebind')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Registered funcdefs expose exact metadata, compatible invocation, null and incompatible-target behavior, rebuild identity, and cleanup.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp|FFunctionIndirectCallTests|RegisteredFuncdefScenarios'
		}
		@{
			Id = 'LANG-FN-INDIRECT-SCRIPT-FUNCDEF'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'script funcdef current-fork boundary'
			Axes = @{
				Scenario = @('declaration_metadata', 'compatible_direct', 'compatible_nested', 'null_or_unbound', 'incompatible_signature', 'rebuild_or_rebind')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Script funcdef sources preserve the current-fork parser boundary with located diagnostics, no leaked callable state, and same-engine recovery.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp|FFunctionIndirectCallTests|ScriptFuncdefBoundaryScenarios'
		}
		@{
			Id = 'LANG-FN-INDIRECT-MIXIN'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'mixin indirect dispatch'
			Axes = @{
				Scenario = @('declaration_metadata', 'compatible_direct', 'compatible_nested', 'null_or_unbound', 'incompatible_signature', 'rebuild_or_rebind')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Mixin dispatch exposes exact declarations, direct and nested invocation, rejected receiver/signature forms, rebuild behavior, and cleanup.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp|FFunctionIndirectCallTests|MixinScenarios'
		}
		@{
			Id = 'LANG-FN-INDIRECT-IMPORTED'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'imported function bind and rebind'
			Axes = @{
				Scenario = @('declaration_metadata', 'compatible_direct', 'compatible_nested', 'null_or_unbound', 'incompatible_signature', 'rebuild_or_rebind')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Imported functions expose metadata before binding, compatible execution, unbound and mismatch behavior, explicit rebind replacement, and module cleanup.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp|FFunctionIndirectCallTests|ImportedRebindScenarios'
		}
		@{
			Id = 'LANG-FN-VALUE-LIFECYCLE'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'value transfer failure and cleanup'
			Axes = @{
				Failure = @('none', 'argument_evaluation', 'body', 'return_construction')
				Initialized = @('zero', 'one', 'many')
				Transfer = @('value_argument', 'value_return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Diagnostic', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'Constructed values record the exact transfer prefix, every exceptional stage unwinds initialized objects once, and the same context executes a clean follow-up without stale state.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionValueLifecycleTests.cpp|FFunctionValueLifecycleTests|FailuresByInitializedCountAndTransfer'
		}
		@{
			Id = 'LANG-FN-DIRECTION-DEFAULT'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'parameter direction and default argument interaction'
			Axes = @{
				DefaultState = @('none_explicit', 'none_omitted', 'present_explicit', 'present_omitted')
				Direction = 'ParameterDirections'
				Target = @('global', 'namespace_global', 'instance_method')
				Type = 'PrimitiveTypes'
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every primitive type crosses every parameter direction, default declaration/call state, and core call target. Legal cells preserve exact parameter mode/default metadata and transfer or writeback; missing arguments and omitted out/inout calls retain diagnostics and no partial module.'
			Owner = 'Language/Functions/AngelscriptNativeFunctionDirectionDefaultTests.cpp|FFunctionDirectionDefaultTests|DirectionAndDefaultArgumentCells'
		}
		@{
			Id = 'LANG-FN-MIXIN-DIRECT-DISPATCH'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'direct mixin extension-member dispatch by namespace'
			Axes = @{
				Namespace = @('global', 'nested')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Global and nested mixins resolve through extension-style member syntax, mutate only the selected value receiver, publish the exact namespaced entry declaration, and execute in isolated modules.'
			Owner = 'Language/AngelscriptNativeFunctionsTests.cpp|FFunctionsTests|FunctionsMixinNamespace'
		}
		@{
			Id = 'LANG-FN-MIXIN-FREE-CALL-REJECTION'
			SourceCatalog = 'functions.md'
			Theme = 'Functions'
			Element = 'current-fork mixin free-call rejection by namespace'
			Axes = @{
				Namespace = @('global', 'nested')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The current fork does not expose a mixin hidden receiver as an ordinary first free-function argument: global and nested free-call sources fail with the exact AddToCounter signature diagnostic, publish no Entry, and leave a clean isolated module scope.'
			Owner = 'Language/AngelscriptNativeFunctionsTests.cpp|FFunctionsTests|FunctionsMixinNamespace'
		}
		@{
			Id = 'LANG-VAR-INIT-STORAGE'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'variable initialization by storage'
			Axes = @{
				Type = 'CoreValueTypes'
				Storage = @('local', 'const_local', 'auto', 'loop_initializer', 'branch_local', 'const_global', 'field_linkage')
				Initializer = @('default', 'literal', 'expression', 'copy', 'constructor', 'function_return', 'conditional')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Every legal type/storage/initializer cell preserves the declared or inferred type, value, visibility, and lifetime; impossible auto/default, const-global, or field forms are isolated located rejections with no published partial symbol and a clean recovery build.'
			Owner = 'Language/Variables/AngelscriptNativeVariableInitializationTests.cpp|FVariableInitializationTests|TypesByStorageAndInitializer'
		}
		@{
			Id = 'LANG-VAR-SHADOW'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'scope and shadow identity'
			Axes = @{
				Relation = @('none', 'inner_outer', 'parameter_global', 'parameter_member', 'sibling')
				ScopeUsePath = @('function_before_declaration', 'function_after_declaration', 'function_sibling_call', 'nested_block_before', 'nested_block_inside', 'nested_block_after', 'if_branch_before', 'if_branch_inside', 'if_branch_after', 'switch_case_before', 'switch_case_inside', 'switch_case_after', 'for_initializer', 'for_body', 'for_after', 'while_before', 'while_body', 'while_after', 'foreach_before', 'foreach_body', 'foreach_after', 'nested_call_caller_before', 'nested_call_callee', 'nested_call_caller_after', 'after_owner')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Debug')
			Expected = 'Each use resolves to the exact live declaration; inaccessible or duplicate use fails without leaking symbols.'
			Owner = 'Language/Variables/AngelscriptNativeLanguageVariableScopeTests.cpp|FLanguageVariableScopeTests|RelationsByScopeUsePath'
		}
		@{
			Id = 'LANG-VAR-LIFETIME'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'variable lifetime on transfer'
			Axes = @{
				Owner = @('local_value', 'nested_value', 'field', 'reference')
				Exit = @('block_end', 'return', 'break', 'continue', 'exception')
				Nesting = @('one', 'sequential', 'nested_scopes', 'loop', 'nested_call')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup')
			Expected = 'Construction and destruction occur once in exact scope order with no live objects after the exit.'
			Owner = 'Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp|FVariableLifetimeTests|OwnersByExitAndNesting'
		}
		@{
			Id = 'LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'counted reference assignment ownership transition'
			Axes = @{
				Scenario = @(
					'factory_local',
					'overwrite',
					'null_assignment',
					'parameter_return',
					'exception_frame',
					'save_load',
					'parameter_return_save_load'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each factory, overwrite, null, parameter/return, exception, and save/load transition retains exact bytecode/object metadata, return or exception state, construction/AddRef/Release counts, object identity, same-context recovery, and zero live references without compensating fixture releases.'
			Owner = 'Language/Variables/AngelscriptNativeCountedReferenceAssignmentTests.cpp|FCountedReferenceAssignmentTests|CountedReferenceAssignmentsBalanceAcrossOwnershipTransitions'
		}
		@{
			Id = 'LANG-VAR-REFERENCE-INIT'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'automatic-reference variable initialization and inference'
			Axes = @{
				Type = 'CoreReferenceTypes'
				Source = @('constructed_local', 'parameter', 'function_return', 'field', 'null')
				Declaration = @('explicit_type', 'auto', 'const_view')
				Use = @('identity', 'mutation', 'argument', 'return', 'null_compare')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Each legal declaration preserves inferred or explicit reference type, identity, constness, and ownership across the selected use; illegal null or const operations fail at the variable use and leave balanced reference state.'
			Owner = 'Language/Variables/AngelscriptNativeVariableReferenceInitializationTests.cpp|FVariableReferenceInitializationTests|TypesBySourceDeclarationAndUse'
		}
		@{
			Id = 'LANG-VAR-ASSIGN-TARGET'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'variable assignment by target state'
			Axes = @{
				Type = 'VariableTypes'
				Assignment = @('simple', 'copy_source', 'self_assignment', 'compound', 'reference_rebind')
				Target = @('mutable_local', 'const_local', 'mutable_field', 'const_field', 'reference_alias', 'temporary', 'expression_result')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Every meaningful assignment cell records source and target identities, before/result/after values, copy independence, alias visibility, and exact lifecycle effects; unsupported type/operator pairs and non-writable targets own a located diagnostic and recovery.'
			Owner = 'Language/Variables/AngelscriptNativeVariableAssignmentTests.cpp|FVariableAssignmentTests|TypesByAssignmentAndTarget'
		}
		@{
			Id = 'LANG-VAR-LOOP-DECL-LIFETIME'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'loop variable declaration frequency and lifetime'
			Axes = @{
				Type = @('script_value', 'native_value')
				Placement = @('for_initializer', 'for_body', 'while_body', 'do_body', 'nested_body')
				Iterations = @('zero', 'one', 'three', 'eight')
				Exit = @('normal', 'break', 'continue', 'return', 'exception')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'Construction, visible debug scope, body visits, transfer target, and reverse destruction count match the reachable iterations; zero-iteration transfers remain unexecuted and exceptional exits leave a reusable context.'
			Owner = 'Language/Variables/AngelscriptNativeVariableLoopLifetimeTests.cpp|FVariableLoopLifetimeTests|TypesByPlacementIterationsAndExit'
		}
		@{
			Id = 'LANG-VAR-FAILURE-BOUNDARY'
			SourceCatalog = 'variables.md'
			Theme = 'Variables'
			Element = 'variable failure and storage boundary'
			Axes = @{
				Scenario = @('use_before_declaration', 'use_after_scope', 'duplicate_same_scope', 'incompatible_initializer', 'mutable_global', 'reference_global', 'uninitialized_read', 'initializer_exception', 'failed_initializer_atomicity', 'long_identifier', 'many_locals_supported', 'many_locals_boundary', 'stack_frame_pressure', 'module_discard')
				Recovery = @('fresh_module', 'same_module_or_context')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'Each isolated source reaches its named current-fork storage or failure boundary with exact diagnostics or boundary metadata, publishes no partial symbol after failure, balances initialized values, and completes the selected recovery path.'
			Owner = 'Language/Variables/AngelscriptNativeVariableFailureBoundaryTests.cpp|FVariableFailureBoundaryTests|ScenariosByRecovery'
		}
		@{
			Id = 'LANG-PROP-VALUE-OP'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'stored property operation'
			Axes = @{
				Type = 'CoreValueTypes'
				Operation = @('default_read', 'write', 'compound_write', 'copy', 'reference_mutation')
				Receiver = @('mutable', 'const', 'base_view', 'derived_view')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle')
			Expected = 'The field value, receiver identity, copy independence, and legal const behavior match the operation; const writes and unsupported compound operations own a located rejection and clean recovery.'
			Owner = 'Language/Properties/AngelscriptNativeStoredPropertyTests.cpp|FStoredPropertyTests|TypesByOperationAndReceiver'
		}
		@{
			Id = 'LANG-PROP-VISIBILITY'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'stored-property read and write visibility'
			Axes = @{
				Operation = @('read', 'write')
				Visibility = @('default', 'private', 'protected')
				AccessPath = @('owner_method', 'owner_constructor', 'owner_destructor', 'accessor_body', 'direct_derived', 'deep_derived', 'unrelated_type', 'global_same_module', 'base_view_from_derived', 'derived_view_from_global')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Each stored-field read or write names one concrete owner/inheritance relation; legal access observes or mutates the exact field, while illegal access reports the owning visibility diagnostic without publishing a callable probe.'
			Owner = 'Language/Properties/AngelscriptNativePropertyVisibilityTests.cpp|FPropertyVisibilityTests|OperationsByVisibilityAndAccessPath'
		}
		@{
			Id = 'LANG-PROP-ACCESSOR'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'application-registered non-indexed property accessor'
			Axes = @{
				Scenario = @('getter_read_mutable', 'getter_read_const', 'getter_nonconst_read_mutable', 'getter_nonconst_read_const_rejected', 'getter_write_missing', 'getter_compound_missing_set', 'setter_write_mutable', 'setter_write_const_rejected', 'setter_read_missing', 'setter_compound_missing_get', 'both_read_mutable', 'both_write_mutable', 'both_compound_mutable', 'both_compound_const_rejected', 'recursive_getter', 'recursive_setter', 'throwing_getter', 'throwing_setter')
				SourceShape = @('single_line', 'multiline', 'parenthesized', 'helper_call')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'The concrete accessor scenario selects the exact raw-SDK registered declaration with the expected receiver constness and callback trace; missing halves, const writes, recursive callbacks, and thrown callbacks stop at the owning operation, clean up, and permit context reuse in every reviewable source shape.'
			Owner = 'Language/Properties/AngelscriptNativeRegisteredPropertyTests.cpp|FRegisteredPropertyTests|ScenariosBySourceShape'
		}
		@{
			Id = 'LANG-PROP-INDEXED'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'application-registered indexed property overload resolution'
			Axes = @{
				IndexType = 'PropertyIndexTypes'
				CandidateSet = @('same_type', 'adjacent_numeric', 'cross_family', 'competing_primary_first', 'competing_secondary_first', 'unrelated')
				Operation = @('read', 'write', 'compound')
				Receiver = @('mutable', 'const')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Each same-type, adjacent-numeric, cross-family, ordered-competing, or unrelated registered index candidate set records the current fork selected declaration or exact no-viable/multiple-accessor diagnostic for its source type. Ordered competing setters characterize the fork first-lookup behavior in both insertion orders; competing getters, const writes, and every indexed compound form report the owning access site without publishing a misleading result.'
			Owner = 'Language/Properties/AngelscriptNativeIndexedPropertyTests.cpp|FIndexedPropertyTests|IndexTypesByCandidateSetOperationAndReceiver'
		}
		@{
			Id = 'LANG-PROP-INIT-ORDER'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'property initialization source and object-graph order'
			Axes = @{
				Type = 'CoreValueTypes'
				Source = @('default_value', 'declaration_initializer', 'owner_literal_assignment', 'owner_source_assignment', 'derived_reassignment')
				Position = @('base_first', 'base_middle', 'base_last', 'derived_first', 'derived_last')
				Observation = @('base_entry', 'base_exit', 'derived_entry', 'derived_exit')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Every field type records availability and value at the selected base-entry/base-exit/derived-entry/derived-exit checkpoint. Declaration markers and reflected property indexes prove the requested first/middle/last owner position; literal assignment, assignment from a separately constructed source, and derived-body reassignment produce distinct event/lifecycle evidence without treating primitive assignment as copy construction.'
			Owner = 'Language/Properties/AngelscriptNativePropertyInitializationTests.cpp|FPropertyInitializationTests|TypesBySourcePositionAndObservation'
		}
		@{
			Id = 'LANG-PROP-COPY-INDEPENDENCE'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'property copy and assignment independence'
			Axes = @{
				Type = 'VariableTypes'
				Transfer = @('copy_construct', 'assign', 'self_assign')
				Mutation = @('source_after_transfer', 'target_after_transfer', 'nested_member')
				View = @('exact', 'base', 'derived')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Value fields own independent storage after copy or assignment, reference fields preserve intentional identity, self-assignment is stable, and mutations through exact/base/derived views produce the expected one-owner lifecycle trace.'
			Owner = 'Language/Properties/AngelscriptNativePropertyCopyTests.cpp|FPropertyCopyTests|TypesByTransferMutationAndView'
		}
		@{
			Id = 'LANG-PROP-FAILURE'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'property declaration or access failure'
			Axes = @{
				Failure = @('removed_property_decorator', 'removed_virtual_property', 'missing_getter', 'missing_setter', 'registered_mismatched_types', 'registered_duplicate_getter', 'registered_duplicate_setter', 'recursive_getter', 'recursive_setter', 'throwing_getter', 'throwing_setter', 'null_receiver', 'inaccessible_field', 'compound_value_receiver')
				Recovery = @('fresh_module', 'same_module_or_context')
				Probe = @('direct', 'alternate_path')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'Each isolated removal, registration, compile, or runtime failure owns one source location and stopped accessor trace, leaves no partial property publication or live temporary, and completes the selected clean recovery. Direct and alternate probes use a helper/parameter route for source and runtime failures or reverse declaration/registration order for declaration and registration failures, so every variant changes the exercised path.'
			Owner = 'Language/Properties/AngelscriptNativePropertyFailureTests.cpp|FPropertyFailureTests|FailuresByRecoveryAndProbe'
		}
		@{
			Id = 'LANG-PROP-FORK-SEMANTICS'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'current-fork property decorator, automatic-access, and ordinary-method boundary'
			Axes = @{
				Scenario = @(
					'script-decorator-getter',
					'script-decorator-setter',
					'script-decorator-indexed-getter',
					'script-decorator-indexed-setter',
					'native-registration-getter',
					'native-registration-setter',
					'native-registration-indexed-getter',
					'native-registration-indexed-setter',
					'automatic-access-read',
					'automatic-access-write',
					'automatic-access-indexed-read',
					'automatic-access-indexed-write',
					'direct-method-read-write-indexed'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each explicit current-fork boundary scenario proves the exact removed-decorator compile diagnostic, configuration-invalid native registration result, zero-callback automatic-member rejection, or independently representable ordinary-method execution. The direct-method control resolves its exact script entry, returns 88, records two getter and two setter calls, balances carrier lifetime, and leaves no module or engine contamination. It never treats ordinary methods as evidence that property syntax or automatic bracket access is available.'
			Owner = 'Language/Properties/AngelscriptNativePropertyForkSemanticsTests.cpp|FPropertyForkSemanticsTests|DecoratorRegistrationAndAutomaticAccessAreRejected'
		}
		@{
			Id = 'LANG-PROP-REBUILD'
			SourceCatalog = 'properties.md'
			Theme = 'Properties'
			Element = 'property rebuild and bytecode persistence'
			Axes = @{
				Scenario = @('stored_same_source', 'stored_value', 'stored_field_type', 'stored_field_order', 'stored_inheritance', 'registered_same_source', 'registered_read_value', 'registered_getter_presence', 'registered_setter_presence', 'registered_constness', 'registered_indexed_same_source', 'registered_indexed_value', 'registered_indexed_index_type', 'registered_indexed_overload_set', 'registered_indexed_constness')
				Path = @('rebuild', 'save_load')
				Observation = @('metadata', 'runtime', 'old_handle_cleanup')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each form-specific rebuilt or loaded consumer exposes only the current field or registered-accessor identity and value, retains equivalent bytecode for unchanged source, reflects intended changes, and invalidates or releases stale module-owned handles safely.'
			Owner = 'Language/Properties/AngelscriptNativePropertyRebuildTests.cpp|FPropertyRebuildTests|ScenariosByPathAndObservation'
		}
		@{
			Id = 'LANG-CTOR-KIND-CALL'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'constructor selection and call form'
			Axes = @{
				Object = @('script_value', 'script_reference', 'base', 'derived', 'native_value', 'native_reference')
				Kind = @('implicit_default', 'declared_default', 'parameterized', 'overloaded', 'copy', 'conversion')
				Call = @('local', 'temporary', 'field', 'return', 'argument', 'base_call', 'copy_declaration', 'assignment')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'The exact constructor is selected and values plus construction/copy/assignment counters match the call form.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorSelectionTests.cpp|FConstructorSelectionTests|ObjectKindsByConstructorAndCall'
		}
		@{
			Id = 'LANG-CTOR-TRANSFER'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'post-construction value copy and reference alias transfer semantics'
			Axes = @{
				Source = @('script_value_local', 'script_value_temporary', 'script_value_return', 'native_value_local', 'native_value_temporary', 'native_value_return', 'script_reference_local', 'script_reference_temporary', 'script_reference_return', 'native_reference_local', 'native_reference_temporary', 'native_reference_return', 'derived_reference_exact', 'derived_reference_base_view')
				Workflow = @('copy_declaration_local', 'field_constructor_transfer', 'assignment_local', 'field_assignment_after_default', 'argument_transfer', 'return_transfer', 'self_assignment', 'chained_assignment')
				Observation = @('initial_identity_value', 'source_or_temporary_state', 'target_mutation_relation', 'lifecycle_cleanup')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every retained value source produces independent destination storage while every reference source preserves the expected object identity, including derived objects observed through a base view. Local, field, argument, return, self-assignment, and chained workflows record pre-transfer identity/value, post-transfer source or temporary state, reverse-direction target mutation, exact copy/assign/addref/release events, and zero final live storage.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorTransferTests.cpp|FConstructorTransferTests|SourcesByWorkflowAndObservation'
		}
		@{
			Id = 'LANG-CTOR-BOUNDARY'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'constructor declaration, base-call, recursion, and teardown boundaries'
			Axes = @{
				Scenario = @('duplicate_default_signature', 'duplicate_parameter_signature', 'mismatched_constructor_name', 'constructor_value_return', 'super_outside_constructor', 'super_after_statement', 'repeated_super', 'missing_base_argument', 'ambiguous_base_argument', 'inaccessible_base', 'recursive_value_field_direct', 'recursive_value_field_indirect', 'recursive_constructor_direct', 'recursive_constructor_indirect', 'mutable_reference_global', 'module_discard_const_value_global', 'engine_shutdown_const_value_global')
				Observation = @('compile_or_execution_state', 'diagnostic_or_metadata', 'lifecycle_cleanup', 'recovery_or_teardown')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every singular declaration, base-call, recursive construction, raw script-class lifetime, or global teardown boundary has an explicit current-fork outcome. The missing-base source records its Build failure with information-only output rather than inventing an owned error; the mutable script-reference global remains an enabled rejection and public-reference teardown is ApiDeferred. Legal const script value globals use explicit copy/assignment ownership, construct with markers 11,12, and add only the global destructor marker 12 at module discard or engine shutdown. Recursive constructor exceptions unwind partial raw fields, while the normal raw script-class local source retains its base field as a separately recorded current-fork condition.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorBoundaryTests.cpp|FConstructorBoundaryTests|ScenariosByObservation'
		}
		@{
			Id = 'LANG-CTOR-VISIBILITY'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'constructor visibility and resolution'
			Axes = @{
				Visibility = @('default', 'protected', 'private')
				Site = @('owner', 'derived', 'unrelated', 'global')
				Selection = @('exact', 'promotion', 'explicit_cast', 'implicit_rejected', 'ambiguous', 'missing')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Legal sites select one constructor; inaccessible, ambiguous, missing, and implicit-only failures report exact diagnostics.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorVisibilityTests.cpp|FConstructorVisibilityTests|VisibilityBySiteAndSelection'
		}
		@{
			Id = 'LANG-CTOR-PARAM-SELECT'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'constructor parameter family, arity, and candidate selection'
			Axes = @{
				Type = 'CoreValueTypes'
				Arity = @('one', 'two', 'five', 'sixteen')
				Selection = @('exact', 'promotion', 'explicit_conversion', 'ambiguous', 'missing')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'For every value family and nonzero arity, exact and supported conversion candidates publish the selected declaration and marker; unsupported promotion, ambiguous, and missing candidates own a located rejection. Argument evaluation, parameter metadata, value transfer, partial cleanup, and same-name recovery remain explicit for all outcomes.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp|FConstructorParameterTests|ParameterTypesByArityAndSelection'
		}
		@{
			Id = 'LANG-CTOR-SPECIAL-POLICY'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'current-fork implicit and user-declared special-member policy'
			Axes = @{
				Scenario = @('implicit_struct_default', 'declared_struct_default', 'parameter_preserves_generated_default', 'parameter_suppresses_default_option_off', 'implicit_struct_copy', 'declared_struct_copy', 'implicit_struct_assignment', 'declared_struct_assignment', 'user_destructor_copy', 'class_factory_default', 'class_parameter_factory', 'derived_generated_default', 'derived_explicit_super', 'missing_base_default_option_off', 'copy_after_user_constructor', 'assignment_self_stability')
				Observation = @('compile', 'metadata', 'runtime', 'lifecycle')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Each current-fork special-member scenario records whether a default/copy/assignment/factory operation is generated, replaced, or rejected, then proves the published behavior identity, runtime value, lifecycle trace, and cleanup. Parameterized constructors preserve the generated default under the fork runtime configuration; the two option-off scenarios separately prove the exposed raw-SDK configuration boundary. Desired 2.38 generated/deleted-member changes remain in the compiled Disabled product and are not backfilled as active behavior.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorPolicyTests.cpp|FConstructorPolicyTests|ScenariosByObservation'
		}
		@{
			Id = 'LANG-CTOR-ORDER-FAILURE'
			SourceCatalog = 'constructors.md'
			Theme = 'Constructors'
			Element = 'construction order and partial failure'
			Axes = @{
				Failure = @('none', 'base', 'member_first', 'member_middle', 'member_last', 'derived_body', 'copy', 'conversion')
				Depth = @('flat_members', 'nested_members', 'deep_nested_members', 'base_and_derived_members')
				Observation = @('values', 'event_order', 'cleanup', 'context_reuse')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Diagnostic', 'Cleanup')
			Expected = 'Each topology contains a real base, first/middle/last member, and derived body. The current fork initializes member stages 2,3,4 before the explicit base stage 1, then derived stage 5; exception paths publish the exact destructor trace 5,2,3,4,1 and balance all native identities, while normal raw script-class locals retain native fields after unprepare and module discard. The direct native-copy fault retires its already placement-constructed destination before reporting the script exception. Every failure leaves a reusable context with no published partial object.'
			Owner = 'Language/Constructors/AngelscriptNativeConstructorFailureTests.cpp|FConstructorFailureTests|FailurePointsByDepthAndObservation'
		}
		@{
			Id = 'LANG-DTOR-OWNER-EXIT'
			SourceCatalog = 'destructors.md'
			Theme = 'Destructors'
			Element = 'destructor ownership and exit path'
			Axes = @{
				Scenario = @('local_block_end', 'local_return', 'local_early_return', 'local_break', 'local_continue', 'local_switch_exit', 'local_exception', 'local_abort', 'local_unprepare', 'nested_local_block_end', 'nested_local_return', 'nested_local_exception', 'field_block_end', 'field_return', 'field_exception', 'field_abort', 'base_derived_block_end', 'base_derived_return', 'base_derived_exception', 'base_derived_abort', 'temporary_statement_end', 'temporary_early_return', 'temporary_exception', 'returned_value_consume', 'returned_value_discard', 'returned_value_exception', 'argument_copy_return', 'argument_copy_exception', 'argument_copy_abort', 'reference_scope_end', 'reference_alias_scope_end', 'reference_return', 'reference_exception', 'reference_abort', 'reference_unprepare', 'module_discard_global', 'engine_shutdown_global')
				Nesting = @('one', 'sequential', 'nested_scopes', 'nested_calls', 'loop', 'recursion')
				Observation = @('event_order', 'ownership_once', 'terminal_state_recovery')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Each coherent owner/exit scenario materializes a real local, nested local, field, base/derived graph, temporary, returned value, argument copy, reference alias, or module-owned global through the selected nesting shape. The exact constructed event sequence closes once in reverse lifetime order; exception, abort, unprepare, module discard, and engine shutdown own explicit context/global state plus same-context, same-engine, or fresh-engine recovery.'
			Owner = 'Language/Destructors/AngelscriptNativeDestructorExitTests.cpp|FDestructorExitTests|ScenariosByNestingAndObservation'
		}
		@{
			Id = 'LANG-DTOR-PARTIAL'
			SourceCatalog = 'destructors.md'
			Theme = 'Destructors'
			Element = 'partial construction cleanup'
			Axes = @{
				Topology = @('independent', 'nested_member', 'base_derived', 'copy_transfer', 'assignment_transfer', 'self_assignment', 'reference_alias')
				Boundary = @('before_root', 'root_started', 'first_owned', 'middle_owned', 'all_owned', 'complete')
				Exit = @('normal', 'exception', 'abort', 'unprepare')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every topology defines all six named boundaries as real events: construction not started, root storage started, first and middle owned storage, all owned storage, and completed construction/transfer. The selected normal, exception, abort, or unprepare route destroys only the reached owning prefix in reverse order; copy/assignment/self-assignment/reference aliases distinguish storage from non-owning handles and never double destroy.'
			Owner = 'Language/Destructors/AngelscriptNativeDestructorPartialConstructionTests.cpp|FDestructorPartialConstructionTests|TopologiesByBoundaryAndExit'
		}
		@{
			Id = 'LANG-DTOR-DECLARATION'
			SourceCatalog = 'destructors.md'
			Theme = 'Destructors'
			Element = 'implicit, declared, inherited, invalid, and throwing destructor contract'
			Axes = @{
				Scenario = @('implicit_script_value', 'declared_script_value', 'implicit_script_reference', 'declared_script_reference', 'native_value', 'native_reference', 'empty_destructor', 'field_destructor', 'base_derived_destructor', 'private_destructor', 'throwing_destructor', 'throwing_derived_members_base', 'malformed_destructor')
				Observation = @('compile', 'metadata', 'runtime', 'cleanup')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Implicit, user-declared, inherited, native, empty, private, throwing, and malformed destructor scenarios publish the exact current-fork metadata or diagnostic, execute the defined teardown path, destroy each constructed identity at most once, and leave the context/module/engine clean.'
			Owner = 'Language/Destructors/AngelscriptNativeDestructorDeclarationTests.cpp|FDestructorDeclarationTests|ScenariosByObservation'
		}
		@{
			Id = 'LANG-INH-DISPATCH'
			SourceCatalog = 'inheritance.md'
			Theme = 'Inheritance'
			Element = 'inheritance dispatch by view'
			Axes = @{
				Depth = @('base', 'two_levels', 'three_levels', 'deep')
				Member = @('field', 'nonvirtual_method', 'virtual_method', 'override', 'getter_method', 'setter_method')
				View = @('derived_object', 'base_view', 'explicit_base', 'owner', 'derived_impl')
				Invocation = @('direct', 'virtual_route', 'explicit_base')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Direct, virtual-route, and explicit-base invocations expose the exact field/method/getter/setter target permitted by the member form, static view, and inheritance depth. Non-virtual members remain static, virtual members route to the most-derived implementation, and explicit base invocation bypasses overrides with matching metadata.'
			Owner = 'Language/Inheritance/AngelscriptNativeInheritanceDispatchTests.cpp|FInheritanceDispatchTests|DepthsByMemberViewAndDispatch'
		}
		@{
			Id = 'LANG-INH-ACCESS'
			SourceCatalog = 'inheritance.md'
			Theme = 'Inheritance'
			Element = 'inherited member access'
			Axes = @{
				Access = @('default', 'protected', 'private')
				Member = @('field', 'method', 'getter_setter_method', 'constructor')
				Site = @('owner', 'direct_derived', 'deep_derived', 'unrelated', 'global')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Legal inherited access resolves the intended member and illegal access fails at the use site with exact diagnostic ownership.'
			Owner = 'Language/Inheritance/AngelscriptNativeInheritanceAccessTests.cpp|FInheritanceAccessTests|AccessByMemberAndSite'
		}
		@{
			Id = 'LANG-INH-CAST'
			SourceCatalog = 'inheritance.md'
			Theme = 'Inheritance'
			Element = 'object relation and cast'
			Axes = @{
				Relation = @('exact', 'upcast', 'downcast_success', 'downcast_failure', 'sibling', 'null')
				Constness = @('mutable', 'const')
				Use = @('assign', 'argument', 'return', 'identity_compare', 'member_call')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle')
			Expected = 'Cast result, null state, identity, constness, and dispatch agree with the runtime object relation.'
			Owner = 'Language/Inheritance/AngelscriptNativeInheritanceCastTests.cpp|FInheritanceCastTests|RelationsByConstnessAndUse'
		}
		@{
			Id = 'LANG-INH-CLASS-RULE'
			SourceCatalog = 'inheritance.md'
			Theme = 'Inheritance'
			Element = 'raw-core class modifier, method final/override, invalid-base, cycle, and implementation rule'
			Axes = @{
				Scenario = @('abstract_class_keyword_rejected', 'final_class_keyword_rejected', 'concrete_base_inherit', 'concrete_instantiate', 'final_method_override', 'final_method_inherit', 'invalid_base_name', 'invalid_base_kind', 'duplicate_base', 'inheritance_cycle_direct', 'inheritance_cycle_indirect', 'implicit_override_without_keyword', 'exact_override', 'override_without_base', 'return_type_mismatch', 'deep_override')
				Observation = @('compile', 'diagnostic', 'metadata', 'runtime')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'The raw fork rejects class-level abstract/final keywords because their parser/builder paths are disabled, while concrete inheritance and method-level final/override remain active. Every legal implicit/exact/deep override or inherited-final path publishes exact type/method relations and dispatch; class-modifier, final-method override, invalid-base, duplicate-base, cycle, override-without-base, and return-mismatch sources own located diagnostics, publish no callable partial path, and leave the module name recoverable.'
			Owner = 'Language/Inheritance/AngelscriptNativeInheritanceRuleTests.cpp|FInheritanceRuleTests|ScenariosByObservation'
		}
		@{
			Id = 'LANG-INH-OVERRIDE-SIGNATURE'
			SourceCatalog = 'inheritance.md'
			Theme = 'Inheritance'
			Element = 'override signature dimension and view'
			Axes = @{
				Dimension = @('parameter_type', 'parameter_count', 'return_type', 'constness', 'visibility', 'name_hiding')
				Variant = @('exact', 'compatible_overload', 'incompatible')
				View = @('base', 'derived', 'explicit_base')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Each parameter, arity, return, constness, visibility, or name-hiding change is classified as an exact override, a separate compatible overload, or an incompatible override. Base, derived, and explicit-base views prove the selected declaration/dispatch marker, while invalid overrides own a located diagnostic and clean recovery.'
			Owner = 'Language/Inheritance/AngelscriptNativeOverrideSignatureTests.cpp|FOverrideSignatureTests|DimensionsByVariantAndView'
		}
		@{
			Id = 'LANG-REF-SOURCE-OP'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'automatic reference identity and operation'
			Axes = @{
				Source = @('new_local', 'field', 'parameter', 'return', 'base_view', 'derived_view', 'native_object', 'null')
				Operation = @('initialize', 'assign', 'pass', 'return', 'identity', 'null_compare', 'cast', 'member_access', 'alias_mutation')
				Qualifier = @('mutable', 'const_object', 'const_input', 'const_removal_invalid')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle')
			Expected = 'Automatic references preserve identity and legal const behavior; null/member/const failures are exact and cleanup is balanced.'
			Owner = 'Language/References/AngelscriptNativeReferenceIdentityTests.cpp|FReferenceIdentityTests|SourcesByOperationAndQualifier'
		}
		@{
			Id = 'LANG-REF-FORK-DERIVED-INREF'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'derived-to-base input-reference conversion restriction'
			Axes = @{
				Source = @('derived_input_reference')
				Target = @('base_const_input_reference')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup')
			Expected = 'The current fork rejects a derived static view passed to a base const input-reference parameter with its owning diagnostic, leaves no partial module, and recovers with balanced native reference lifetime.'
			Owner = 'Language/References/AngelscriptNativeReferenceDerivedInputRejectionTests.cpp|FReferenceDerivedInputRejectionTests|CurrentForkRejectsDerivedToBaseInputReferenceConversion'
		}
		@{
			Id = 'LANG-REF-DIRECTION'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'reference parameter and alias relation'
			Axes = @{
				Direction = 'ParameterDirections'
				Relation = @('same_two_names', 'distinct', 'self_assignment', 'base_derived_views', 'out_replacement', 'inout_mutation')
				NullState = @('non_null', 'null_input', 'null_output', 'null_return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Parameter direction preserves or replaces identity exactly, with explicit null state and no reference-count imbalance.'
			Owner = 'Language/References/AngelscriptNativeReferenceDirectionTests.cpp|FReferenceDirectionTests|DirectionsByAliasAndNullState'
		}
		@{
			Id = 'LANG-REF-DIRECTION-FORK-GLOBAL'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'mutable script-global reference restriction'
			Axes = @{
				State = @('mutable_global')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup')
			Expected = 'The current fork rejects a mutable script-global reference declaration with its owning diagnostic, publishes no partial module state, and remains recoverable through the same raw engine.'
			Owner = 'Language/References/AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp|FReferenceDirectionMutableGlobalRejectionTests|CurrentForkRejectsMutableScriptGlobals'
		}
		@{
			Id = 'LANG-REF-LIFETIME'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'reference lifetime boundary'
			Axes = @{
				OwnerState = @('owner_live', 'scope_exit', 'returned_alias', 'module_retained', 'module_discarded', 'context_retained', 'context_released', 'gc_cycle')
				ReferenceState = @('none', 'one_alias', 'multiple_aliases', 'cycle', 'weak_flag')
				Observation = @('identity', 'refcount', 'weak_flag', 'destruction', 'gc_stats')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Reference ownership, weak state, destruction, and collector statistics transition exactly at the boundary.'
			Owner = 'Language/References/AngelscriptNativeReferenceLifetimeTests.cpp|FReferenceLifetimeTests|OwnerStatesByReferenceAndObservation'
		}
		@{
			Id = 'LANG-REF-RESOLUTION'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'reference overload candidate selection'
			Axes = @{
				CandidateSet = @('mutable_exact', 'const_pair', 'value_vs_in', 'base_vs_derived', 'return_covariance', 'null_pair', 'numeric_conversion', 'competing_conversions', 'missing_candidate', 'incompatible_candidate')
				Source = @('mutable_lvalue', 'const_lvalue', 'temporary', 'field', 'parameter', 'base_view', 'derived_view', 'null')
				Site = @('direct', 'helper')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Each candidate family resolves or rejects the concrete source at both direct and helper-mediated sites with the exact declaration, const/ref modifier, runtime marker, alias identity, null behavior, located diagnostic, and balanced reference ownership.'
			Owner = 'Language/References/AngelscriptNativeReferenceResolutionTests.cpp|FReferenceResolutionTests|CandidateSetsBySourceAndSite'
		}
		@{
			Id = 'LANG-REF-FAILURE'
			SourceCatalog = 'references.md'
			Theme = 'References'
			Element = 'singular invalid reference and recovery boundary'
			Axes = @{
				Failure = @('explicit_handle', 'const_removal', 'temporary_out', 'expired_local_return', 'unrelated_assignment', 'unrelated_cast', 'null_member_access', 'stale_module_object', 'ambiguous_overload', 'incompatible_inout')
				Recovery = @('fresh_module', 'same_module_or_context')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each explicit-handle, const-removal, temporary-out, expired-return, unrelated assignment/cast, null access, stale-module object, ambiguous overload, or incompatible-inout boundary owns one exact compile/runtime failure, no leaked reference, and a successful fresh or same-state recovery.'
			Owner = 'Language/References/AngelscriptNativeReferenceFailureTests.cpp|FReferenceFailureTests|FailuresByRecovery'
		}
		@{
			Id = 'LANG-CONV-NUMERIC'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'numeric conversion'
			Axes = @{
				SourceType = 'NumericTypes'
				TargetType = 'NumericTypes'
				Form = @('assignment', 'initializer', 'argument', 'return', 'promotion', 'explicit_cast')
				Value = @('zero', 'one', 'negative', 'min', 'max', 'near_boundary', 'fractional')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Each source/target/form cell records whether the current fork accepts the conversion; accepted cells preserve the exact widened, truncated, wrapped, or fractional result and rejected cells own one located diagnostic without publishing a callable.'
			Owner = 'Language/Conversions/AngelscriptNativeNumericConversionTests.cpp|FNumericConversionTests|SourceTargetFormAndValue'
		}
		@{
			Id = 'LANG-CONV-FLOAT-FINITE-SPECIAL'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'finite floating zero, signed-zero, and subnormal conversion'
			Axes = @{
				SourceType = @('float32', 'float64')
				TargetType = 'NumericTypes'
				Form = @('assignment', 'argument', 'return', 'explicit_cast')
				Value = @('positive_zero', 'negative_zero', 'subnormal')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Every finite source reaches its conversion expression and verifies the exact target bit representation for zero sign, subnormal preservation or underflow, target return metadata, and module cleanup.'
			Owner = 'Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp|FNumericBoundaryConversionTests|FiniteValuesBySourceTargetAndForm'
		}
		@{
			Id = 'LANG-CONV-FLOAT64-TO-FLOAT32-RANGE'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'finite float64 to float32 range conversion'
			Axes = @{
				Form = @('assignment', 'argument', 'return', 'explicit_cast')
				BoundaryDirection = @('above_target_max', 'below_target_min')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'The sole representable finite narrowing range path, float64 to float32, reaches each conversion form and verifies positive or negative infinity target bits, return metadata, and module cleanup.'
			Owner = 'Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp|FNumericBoundaryConversionTests|Float64ToFloat32RangeByFormAndDirection'
		}
		@{
			Id = 'LANG-CONV-NONFINITE-PRECONVERSION'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'non-finite source construction before conversion'
			Axes = @{
				SourceType = @('float32', 'float64')
				TargetType = 'NumericTypes'
				Form = @('assignment', 'argument', 'return', 'explicit_cast')
				SourceExpression = @('positive_infinity', 'negative_infinity', 'nan')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Every target conversion form compiles and publishes its return metadata; its source expression then raises the exact raw-SDK divide-by-zero exception before conversion, releases the context, and discards the module without claiming a non-finite conversion result.'
			Owner = 'Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp|FNumericBoundaryConversionTests|NonFiniteConstructionBySourceTargetAndForm'
		}
		@{
			Id = 'LANG-CONV-BOOL-CONTEXT'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'source value in boolean context'
			Axes = @{
				Source = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef')
				Context = @('if', 'while', 'ternary_condition', 'logical_and', 'logical_or', 'logical_xor')
				Value = @('zero', 'one', 'negative')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Every source/context/value cell records the current fork boolean-context rule with an exact branch marker when accepted or one located rejection when implicit truth conversion is unavailable.'
			Owner = 'Language/Conversions/AngelscriptNativeBoolConversionTests.cpp|FBoolConversionTests|SourcesByContextAndValue'
		}
		@{
			Id = 'LANG-CONV-ENUM-ALIAS'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'enum and alias conversion identity'
			Axes = @{
				Source = @('enum', 'alias_int8', 'alias_int', 'alias_int64', 'alias_uint', 'alias_uint64')
				Target = @('enum', 'int8', 'int', 'int64', 'uint', 'uint64', 'float64')
				Form = @('assignment', 'initializer', 'argument', 'return', 'promotion', 'explicit_cast')
				Value = @('zero', 'one', 'negative', 'near_min', 'near_max')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'The conversion distinguishes nominal enum identity from alias transparency, preserves the underlying representation when accepted, and reports the exact illegal implicit or range conversion otherwise.'
			Owner = 'Language/Conversions/AngelscriptNativeEnumAliasConversionTests.cpp|FEnumAliasConversionTests|SourcesByTargetFormAndValue'
		}
		@{
			Id = 'LANG-CONV-OBJECT-CAST'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'object runtime kind and view cast'
			Axes = @{
				RuntimeKind = @('base', 'derived', 'unrelated', 'null')
				SourceView = @('base', 'derived', 'unrelated')
				TargetView = @('base', 'derived', 'unrelated')
				Form = @('assignment', 'initializer', 'argument', 'return', 'explicit_cast')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'The source view is first established or rejected according to the runtime kind, then the target conversion preserves object identity, yields null, or owns one compile/runtime failure with balanced reference counts.'
			Owner = 'Language/Conversions/AngelscriptNativeObjectCastTests.cpp|FObjectCastTests|RuntimeKindsBySourceTargetAndForm'
		}
		@{
			Id = 'LANG-CONV-VALUE-OBJECT'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'value-object constructor and conversion operator'
			Axes = @{
				Availability = @('implicit_constructor', 'explicit_constructor', 'implicit_operator', 'explicit_operator', 'constructor_and_operator', 'none')
				Target = @('same_value', 'other_value', 'int', 'float64', 'bool')
				Form = @('assignment', 'initializer', 'argument', 'return', 'explicit_cast', 'direct_constructor')
				Outcome = @('direct', 'selected', 'ambiguous', 'rejected')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'A fixture configured for the selected outcome proves which constructor or conversion operator ran, whether explicitness is honored at the invocation form, and that every temporary is destroyed exactly once.'
			Owner = 'Language/Conversions/AngelscriptNativeValueObjectConversionTests.cpp|FValueObjectConversionTests|AvailabilityByTargetFormAndOutcome'
		}
		@{
			Id = 'LANG-CONV-OVERLOAD'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'conversion in resolution context'
			Axes = @{
				Context = @('overload', 'operator', 'default_argument', 'property', 'index', 'conditional')
				Conversion = @('identity', 'promotion', 'narrowing', 'constructor', 'operator', 'reference_cast')
				Outcome = @('exact', 'selected_conversion', 'ambiguous', 'rejected')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'The selected declaration and runtime marker prove conversion ranking, or one ambiguity/rejection diagnostic owns the failure.'
			Owner = 'Language/Conversions/AngelscriptNativeConversionResolutionTests.cpp|FConversionResolutionTests|ContextsByConversionAndOutcome'
		}
		@{
			Id = 'LANG-CONV-ABI'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'floating declaration and native ABI conversion'
			Axes = @{
				ScriptDeclaration = @('float', 'double')
				NativeStorage = @('float32', 'float64')
				Direction = @('argument', 'return', 'property')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Each representable script declaration, explicit float32/float64 manual binding, and argument/return/property direction owns a fresh engine; the registered type ID, exact callback count, result marker, and native representation bits agree.'
			Owner = 'Language/Conversions/AngelscriptNativeConversionAbiTests.cpp|FConversionAbiTests|DeclarationsByStorageAndDirection'
		}
		@{
			Id = 'LANG-CONV-ABI-MANUAL-DECLARATION'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'ambiguous floating manual C++ declaration rejection'
			Axes = @{
				Direction = @('argument', 'return', 'property')
			}
			Classification = 'CurrentFork'
			Evidence = @('Diagnostic', 'Metadata', 'Isolation')
			Expected = 'The current fork rejects the ambiguous manual C++ float spelling for function arguments, returns, and global properties before it publishes any global metadata; float32 and float64 are covered only by the representable ABI product.'
			Owner = 'Language/Conversions/AngelscriptNativeConversionAbiTests.cpp|FConversionAbiTests|AmbiguousManualDeclarations'
		}
		@{
			Id = 'LANG-CONV-FAILURE'
			SourceCatalog = 'conversions.md'
			Theme = 'Conversions'
			Element = 'isolated conversion failure and recovery'
			Axes = @{
				Failure = @('implicit_narrowing', 'numeric_to_enum', 'unrelated_reference', 'bad_downcast', 'null_value_target', 'ambiguous_constructor', 'ambiguous_operator', 'explicit_only_implicit_use', 'conversion_exception', 'constructor_exception', 'abi_mismatch', 'conditional_no_common_type')
				Recovery = @('fresh_module', 'same_module_or_context')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each conversion failure has one causal source location and exact compile or runtime owner, publishes no partial callable on build failure, balances constructed values, and completes the selected clean recovery route.'
			Owner = 'Language/Conversions/AngelscriptNativeConversionFailureTests.cpp|FConversionFailureTests|FailuresByRecovery'
		}
		@{
			Id = 'LANG-OP-NUMERIC-BINARY'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'numeric binary operator'
			Axes = @{
				LeftType = 'NumericTypes'
				RightType = 'NumericTypes'
				Operator = @('add', 'subtract', 'multiply', 'divide', 'modulo', 'less', 'less_equal', 'greater', 'greater_equal', 'equal', 'not_equal')
				Value = @('zero', 'one', 'negative', 'near_min', 'near_max')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'The result type and value follow numeric promotion and the selected operator semantics without undefined host-side expectations.'
			Owner = 'Language/Operators/AngelscriptNativeNumericBinaryOperatorTests.cpp|FNumericBinaryOperatorTests|OperandTypesByOperatorAndValue'
		}
		@{
			Id = 'LANG-OP-UNARY'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'built-in unary operator'
			Axes = @{
				OperationType = @(
					'positive_int8', 'positive_int16', 'positive_int', 'positive_int64',
					'positive_uint8', 'positive_uint16', 'positive_uint', 'positive_uint64',
					'positive_float32', 'positive_float64',
					'negative_int8', 'negative_int16', 'negative_int', 'negative_int64',
					'negative_uint8', 'negative_uint16', 'negative_uint', 'negative_uint64',
					'negative_float32', 'negative_float64',
					'bit_not_int8', 'bit_not_int16', 'bit_not_int', 'bit_not_int64',
					'bit_not_uint8', 'bit_not_uint16', 'bit_not_uint', 'bit_not_uint64'
				)
				Category = @('mutable_lvalue', 'const_lvalue', 'temporary', 'field', 'alias')
				Value = @('zero', 'one', 'negative', 'near_min', 'near_max')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Every legal numeric unary operation proves its exact source category, current-fork unsigned-to-signed promotion where applicable, result type, and result bits across five values without mixing in duplicate illegal-value rows.'
			Owner = 'Language/Operators/AngelscriptNativeUnaryOperatorTests.cpp|FUnaryOperatorTests|OperationsByCategoryAndValue'
		}
		@{
			Id = 'LANG-OP-LOGICAL-NOT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'boolean logical negation'
			Axes = @{
				Category = @('mutable_lvalue', 'const_lvalue', 'temporary', 'field', 'alias')
				Value = @('false', 'true')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Logical negation consumes each real boolean value category once and returns the opposite exact boolean without mutating or re-evaluating the operand.'
			Owner = 'Language/Operators/AngelscriptNativeLogicalNotOperatorTests.cpp|FLogicalNotOperatorTests|CategoriesByValue'
		}
		@{
			Id = 'LANG-OP-UNARY-REJECTION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'unsupported primitive unary operator'
			Axes = @{
				Failure = @('positive_bool', 'negative_bool', 'bit_not_bool', 'logical_not_signed', 'logical_not_unsigned', 'logical_not_float', 'bit_not_float32', 'bit_not_float64')
				Category = @('mutable_lvalue', 'const_lvalue', 'temporary', 'field', 'alias')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Isolation')
			Expected = 'Each unsupported type/operator/category source owns one located illegal-operation diagnostic, publishes no entry, and compiles an exact same-name legal recovery without multiplying the same rejection by irrelevant values.'
			Owner = 'Language/Operators/AngelscriptNativeUnaryOperatorFailureTests.cpp|FUnaryOperatorFailureTests|FailuresByCategory'
		}
		@{
			Id = 'LANG-OP-POWER-UNIVERSAL'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'exponentiation with universally representable operands'
			Axes = @{
				BaseType = 'NumericTypes'
				ExponentType = 'NumericTypes'
				SourceShape = @('constant', 'mutable_lvalue', 'const_lvalue', 'function_return')
				Value = @('zero_exponent', 'one_exponent', 'near_limit', 'overflow')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Cleanup')
			Expected = 'Every value is representable by each selected operand type. The source shape proves current-fork constant folding versus integer-runtime rejection or floating execution, exact promotion/result classification, overflow behavior, bytecode route when published, and clean reuse.'
			Owner = 'Language/Operators/AngelscriptNativePowerOperatorTests.cpp|FPowerOperatorTests|UniversalTypesBySourceShapeAndValue'
		}
		@{
			Id = 'LANG-OP-POWER-NEGATIVE-EXPONENT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'exponentiation with a representable negative exponent'
			Axes = @{
				BaseType = 'NumericTypes'
				ExponentType = 'SignedOrFloatingTypes'
				SourceShape = @('constant', 'mutable_lvalue', 'const_lvalue', 'function_return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Cleanup')
			Expected = 'A typed negative exponent reaches the operator rather than an unrelated narrowing conversion. The cell proves the fork constant/runtime and promoted numeric behavior or its one causal integer-runtime rejection.'
			Owner = 'Language/Operators/AngelscriptNativePowerOperatorTests.cpp|FPowerOperatorTests|NegativeExponentTypesBySourceShape'
		}
		@{
			Id = 'LANG-OP-POWER-FRACTIONAL-EXPONENT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'exponentiation with a fractional floating exponent'
			Axes = @{
				BaseType = 'NumericTypes'
				ExponentType = 'FloatingTypes'
				SourceShape = @('constant', 'mutable_lvalue', 'const_lvalue', 'function_return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Cleanup')
			Expected = 'A typed 0.5 exponent reaches float promotion for every selected base type. The cell proves exact float result kind/value, active floating power bytecode, one evaluation per operand, and cleanup.'
			Owner = 'Language/Operators/AngelscriptNativePowerOperatorTests.cpp|FPowerOperatorTests|FractionalExponentTypesBySourceShape'
		}
		@{
			Id = 'LANG-OP-LOGICAL'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'logical operator truth and evaluation'
			Axes = @{
				Source = @('bool_literal', 'bool_lvalue', 'comparison', 'conversion_operator')
				Operator = @('and', 'or', 'xor')
				TruthPair = @('false_false', 'false_true', 'true_false', 'true_true')
				Context = @('assignment', 'return', 'condition', 'argument')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'The result and exact left/right evaluation trace distinguish short-circuit and eager logical operators for every truth pair and consuming context.'
			Owner = 'Language/Operators/AngelscriptNativeLogicalOperatorTests.cpp|FLogicalOperatorTests|SourcesByOperatorTruthAndContext'
		}
		@{
			Id = 'LANG-OP-INTEGRAL-BITWISE'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'integral bitwise and shift operator'
			Axes = @{
				Type = 'IntegralTypes'
				Operator = @('bit_and', 'bit_or', 'bit_xor', 'shift_left', 'shift_right_logical', 'shift_right_arithmetic')
				RightPartition = @('zero', 'one', 'source_width_minus_one', 'source_width', 'negative')
				Category = @('mutable_lvalue', 'const_lvalue', 'temporary', 'field', 'alias')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode')
			Expected = 'Bit pattern, source-width versus promoted execution width, signedness, lvalue category, logical >>, arithmetic >>>, and hardware-masked runtime count behavior match this fork.'
			Owner = 'Language/Operators/AngelscriptNativeBitwiseOperatorTests.cpp|FBitwiseOperatorTests|TypesByOperatorCountAndCategory'
		}
		@{
			Id = 'LANG-OP-ASSIGNMENT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'legal primitive assignment and compound assignment'
			Axes = @{
				OperationType = 'AssignmentLegalPairs'
				Category = @('local', 'field', 'property', 'alias')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Every type-supported assignment form mutates the exact writable lvalue once and exposes expression result, final state, target metadata, and native accessor behavior.'
			Owner = 'Language/Operators/AngelscriptNativeAssignmentOperatorTests.cpp|FAssignmentOperatorTests|TypesByOperatorAndCategory'
		}
		@{
			Id = 'LANG-OP-ASSIGNMENT-TARGET-REJECTION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'non-writable target rejection for otherwise legal assignment form'
			Axes = @{
				OperationType = 'AssignmentLegalPairs'
				Category = @('const_invalid', 'temporary_invalid')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Isolation')
			Expected = 'Every otherwise legal primitive assignment form is rejected at its const or temporary target with one causal diagnostic, zero callback execution, and same-name recovery.'
			Owner = 'Language/Operators/AngelscriptNativeAssignmentTargetRejectionTests.cpp|FAssignmentTargetRejectionTests|WritableTargetRejections'
		}
		@{
			Id = 'LANG-OP-ASSIGNMENT-TYPE-REJECTION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'unsupported primitive operation rejection on writable target'
			Axes = @{
				OperationType = 'AssignmentTypeRejectionPairs'
				Category = @('local', 'field', 'property', 'alias')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Isolation')
			Expected = 'Every unsupported bool or floating primitive operation reaches a real writable target, reports one causal operator diagnostic, executes no native accessor, and permits same-name recovery.'
			Owner = 'Language/Operators/AngelscriptNativeAssignmentTypeRejectionTests.cpp|FAssignmentTypeRejectionTests|TypeRejections'
		}
		@{
			Id = 'LANG-OP-INCREMENT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'legal prefix and postfix increment or decrement observations'
			Axes = @{
				Type = 'NumericTypes'
				Operator = @('pre_increment', 'post_increment', 'pre_decrement', 'post_decrement')
				Category = @('local', 'field', 'property', 'alias')
				Observation = @('before', 'expression_result', 'after')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Before, expression-result, and after observations prove prefix/postfix semantics and one mutation of the exact writable lvalue.'
			Owner = 'Language/Operators/AngelscriptNativeIncrementOperatorTests.cpp|FIncrementOperatorTests|TypesByOperatorCategoryAndObservation'
		}
		@{
			Id = 'LANG-OP-INCREMENT-TARGET-REJECTION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'increment or decrement non-writable target rejection'
			Axes = @{
				Type = 'NumericTypes'
				Operator = @('pre_increment', 'post_increment', 'pre_decrement', 'post_decrement')
				Category = @('const_invalid', 'temporary_invalid')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Isolation')
			Expected = 'A legal numeric increment/decrement token on a const or temporary target produces one located non-writable-target diagnostic, executes no producer, and permits same-name recovery.'
			Owner = 'Language/Operators/AngelscriptNativeIncrementTargetRejectionTests.cpp|FIncrementTargetRejectionTests|WritableTargetRejections'
		}
		@{
			Id = 'LANG-OP-INCREMENT-TYPE-REJECTION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'increment or decrement unsupported bool rejection'
			Axes = @{
				Operator = @('pre_increment', 'post_increment', 'pre_decrement', 'post_decrement')
				Category = @('local', 'field', 'property', 'alias')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Isolation')
			Expected = 'Each writable bool-shaped target reaches the increment/decrement token, produces one located unsupported-type diagnostic, executes no accessor, and permits same-name recovery.'
			Owner = 'Language/Operators/AngelscriptNativeIncrementTypeRejectionTests.cpp|FIncrementTypeRejectionTests|BoolTypeRejections'
		}
		@{
			Id = 'LANG-OP-COMPARISON-FLOAT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'floating comparison and equality special value'
			Axes = @{
				Type = @('float32', 'float64')
				Operator = @('less', 'less_equal', 'greater', 'greater_equal', 'equal', 'not_equal')
				Value = @('negative_zero', 'positive_zero', 'nan', 'positive_infinity', 'negative_infinity', 'minimum', 'maximum', 'equal_pair')
				OperandOrder = @('left_right', 'right_left')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Physical floating width, exact operand bits, unordered NaN rules, signed-zero equality, infinity and finite-boundary ordering, boolean result metadata, and both operand orders agree with independently computed IEEE comparisons.'
			Owner = 'Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp|FComparisonOperatorTests|FloatingTypesByOperatorValueAndOrder'
		}
		@{
			Id = 'LANG-OP-COMPARISON-ENUM-ALIAS'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'enum and alias comparison nominal behavior'
			Axes = @{
				Family = @('enum', 'alias')
				Operator = @('less', 'less_equal', 'greater', 'greater_equal', 'equal', 'not_equal')
				Pair = @('equal_zero', 'equal_named', 'below_adjacent', 'above_adjacent', 'minimum_boundary', 'maximum_boundary')
				OperandOrder = @('left_right', 'right_left')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata')
			Expected = 'Enum nominal identity versus alias representation, legal equality/ordering, exact underlying boundary values, and operand reversal are recorded at the owning comparison.'
			Owner = 'Language/Operators/AngelscriptNativeEnumAliasComparisonOperatorTests.cpp|FEnumAliasComparisonOperatorTests|EnumAndAliasByOperatorPairAndOrder'
		}
		@{
			Id = 'LANG-OP-COMPARISON-REFERENCE'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'reference and null comparison identity'
			Axes = @{
				Operator = @('less', 'less_equal', 'greater', 'greater_equal', 'equal', 'not_equal')
				Relation = @('same_non_null', 'different_non_null', 'left_null', 'right_null', 'both_null', 'derived_base_same', 'sibling_different', 'const_same')
				OperandOrder = @('left_right', 'right_left')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle')
			Expected = 'Equality records automatic-reference identity across same, different, base-view, sibling, const, and null relations; unsupported ordering owns one located rejection and all retained objects balance.'
			Owner = 'Language/Operators/AngelscriptNativeReferenceComparisonOperatorTests.cpp|FReferenceComparisonOperatorTests|ReferencesByOperatorRelationAndOrder'
		}
		@{
			Id = 'LANG-OP-COMPARISON-OVERLOAD'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'overloaded comparison special behavior'
			Axes = @{
				Operator = @('less', 'less_equal', 'greater', 'greater_equal', 'equal', 'not_equal')
				Relation = @('less', 'equal', 'greater', 'unequal')
				OperandOrder = @('left_right', 'right_left')
				Receiver = @('mutable', 'const')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle')
			Expected = 'Exact opCmp or opEquals declaration, receiver constness, operand reversal, marker/order trace, relation result, and value-object lifetime are independently observed for every comparison token.'
			Owner = 'Language/Operators/AngelscriptNativeOverloadedComparisonOperatorTests.cpp|FOverloadedComparisonOperatorTests|OverloadsByOperatorRelationOrderAndReceiver'
		}
		@{
			Id = 'LANG-OP-OVERLOAD-INTEGER-CONSUMER'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'integer-result overloaded operator declarations consumed by language contexts'
			Axes = @{
				Scenario = @('unary_member', 'unary_const_member', 'binary_int_member', 'binary_int_const_member', 'binary_int64_promotion', 'binary_value_parameter', 'index_int_parameter', 'index_int64_promotion', 'call_int_member', 'call_int64_promotion', 'conversion_int_target', 'binary_ambiguous_int8', 'index_ambiguous_int8', 'call_ambiguous_int8', 'conversion_ambiguous_target', 'unary_missing_complement', 'binary_missing_subtract', 'index_missing_second_argument', 'call_missing_second_argument', 'conversion_missing_target')
				Consumer = @('assignment', 'return', 'condition', 'overload_argument', 'chain', 'switch_index')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Each integer-result source declares a legal operator shape and is consumed by every integer-capable context; successful declarations prove marker and metadata, while ambiguous and missing declarations own their marked consumer diagnostic and discard cleanly.'
			Owner = 'Language/Operators/AngelscriptNativeOverloadedOperatorTests.cpp|FOverloadedOperatorTests|IntegerResultsByScenarioAndConsumer'
		}
		@{
			Id = 'LANG-OP-OVERLOAD-BOOLEAN-CONSUMER'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'boolean-result overloaded comparison declarations consumed by language contexts'
			Axes = @{
				Scenario = @('comparison_int_parameter', 'comparison_value_parameter', 'comparison_ambiguous_int8', 'comparison_missing_less')
				Consumer = @('assignment', 'return', 'condition', 'overload_argument', 'chain')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Each boolean-result comparison declaration is consumed only where a boolean result has an independent language observation; successful declarations prove marker and metadata, while ambiguous and missing declarations own their marked consumer diagnostic and discard cleanly.'
			Owner = 'Language/Operators/AngelscriptNativeOverloadedBooleanConsumerTests.cpp|FOverloadedBooleanConsumerTests|BooleanResultsByScenarioAndConsumer'
		}
		@{
			Id = 'LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'value-reference assignment overload declarations consumed by language contexts'
			Axes = @{
				Scenario = @('assignment_int_parameter', 'assignment_value_parameter', 'assignment_ambiguous_int8', 'assignment_missing_add_assign')
				Consumer = @('assignment', 'return', 'condition', 'overload_argument', 'chain', 'switch_index')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Each assignment overload source returns and consumes a real value reference through every reference-capable context; successful declarations prove the selected marker and metadata, while ambiguous and missing declarations own their marked consumer diagnostic and discard cleanly.'
			Owner = 'Language/Operators/AngelscriptNativeOverloadedAssignmentConsumerTests.cpp|FOverloadedAssignmentConsumerTests|AssignmentResultsByScenarioAndConsumer'
		}
		@{
			Id = 'LANG-OP-OVERLOAD-DUPLICATE-DECLARATION'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'duplicate overloaded operator declaration rejection'
			Axes = @{
				Family = @('unary', 'binary', 'comparison', 'index', 'call', 'conversion', 'assignment')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup')
			Expected = 'Each legal operator family declares a duplicate signature whose compilation fails on the marked second declaration before any consumer can be selected, then discards its module cleanly.'
			Owner = 'Language/Operators/AngelscriptNativeOverloadedDuplicateDeclarationTests.cpp|FOverloadedDuplicateDeclarationTests|DuplicateDeclarationsByFamily'
		}
		@{
			Id = 'LANG-OP-RESULT-CONTEXT'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'operator result consumed by another language context'
			Axes = @{
				Family = @('unary', 'arithmetic', 'power', 'bitwise', 'shift', 'comparison', 'logical', 'assignment', 'increment', 'overloaded')
				Context = @('assignment', 'return', 'condition', 'overload_argument', 'chain', 'switch_or_index')
				Outcome = @('exact', 'converted', 'ambiguous', 'rejected')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'The consuming context observes the exact operator result type and value or owns the singular conversion/resolution rejection, with no repeated operand evaluation.'
			Owner = 'Language/Operators/AngelscriptNativeOperatorContextTests.cpp|FOperatorContextTests|FamiliesByContextAndOutcome'
		}
		@{
			Id = 'LANG-OP-FAILURE'
			SourceCatalog = 'operators.md'
			Theme = 'Operators'
			Element = 'isolated operator failure and recovery'
			Axes = @{
				Failure = @('unsupported_operand', 'divide_zero', 'modulo_zero', 'invalid_shift_count', 'signed_overflow', 'power_overflow', 'invalid_lvalue', 'const_mutation', 'missing_overload', 'ambiguous_overload', 'invalid_signature', 'duplicate_operator', 'null_receiver', 'left_operand_exception', 'right_operand_exception', 'assignment_exception')
				Recovery = @('fresh_module', 'same_module_or_context')
				Observation = @('diagnostic_or_exception', 'cleanup', 'recovery_result')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every failure isolates its exact compile/runtime owner and causal source line, stops operand evaluation at the correct point, balances live values, and proves fresh or same-state recovery.'
			Owner = 'Language/Operators/AngelscriptNativeOperatorFailureTests.cpp|FOperatorFailureTests|FailuresByRecoveryAndObservation'
		}
		@{
			Id = 'LANG-EXPR-PRIMARY-CONTEXT'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'primary expression in context'
			Axes = @{
				Primary = @('int_literal', 'bool_literal', 'enum_literal', 'null_literal', 'local_identifier', 'const_identifier', 'reference_identifier', 'scoped_constant', 'scoped_enum', 'parenthesized_scalar', 'parenthesized_lvalue', 'global_function_call', 'method_call', 'value_constructor', 'reference_constructor', 'member_field', 'virtual_property', 'indexed_property', 'explicit_numeric_cast', 'object_cast', 'base_cast', 'derived_cast')
				Context = @('initializer', 'assignment_rhs', 'assignment_lhs', 'argument', 'return', 'condition', 'loop_clause', 'switch_selector', 'index', 'property_accessor')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Each grammar-level primary variant preserves its independently declared type/value category and executes once in every legal context, while type- or lvalue-incompatible contexts reject it at the owning expression node.'
			Owner = 'Language/Expressions/AngelscriptNativePrimaryExpressionTests.cpp|FPrimaryExpressionTests|PrimaryVariantsByContext'
		}
		@{
			Id = 'LANG-EXPR-EVAL-ORDER'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'eager composed-expression evaluation order'
			Axes = @{
				Composition = @('binary', 'assignment', 'compound_assignment', 'call_arguments', 'constructor_arguments', 'index_arguments', 'call_chain', 'member_index_chain', 'nested_cast')
				OperandCount = @('two', 'three', 'eight')
				Outcome = @('complete', 'exception_first', 'exception_middle', 'exception_last')
				SourceShape = @('single_line', 'whitespace', 'comments', 'multiline', 'nested_parentheses')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Lifecycle')
			Expected = 'Ordered markers prove every eager operand executes once in the current fork''s composition-defined order, or stops exactly at the selected first/middle/last execution point with balanced cleanup; function, constructor, index, and chained-call arguments retain their raw SDK right-to-left behavior, while lazy logical and conditional behavior is owned separately.'
			Owner = 'Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp|FEagerExpressionOrderTests|CompositionsByCountOutcomeAndSourceShape'
		}
		@{
			Id = 'LANG-EXPR-VALUE-MUTATION'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'value category under mutation'
			Axes = @{
				Category = @('mutable_lvalue', 'const_lvalue', 'temporary', 'reference_alias', 'field', 'property', 'invalid_non_lvalue')
				Mutation = @('assign', 'compound_assign', 'prefix_increment', 'postfix_increment', 'out_argument')
				Placement = @('local', 'global', 'member', 'indexed')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Each legal target mutates exactly once with the correct expression result and alias visibility; const, temporary, and non-lvalue targets fail at the generated mutation site.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp|FExpressionValueCategoryTests|CategoriesByMutationAndPlacement'
		}
		@{
			Id = 'LANG-EXPR-PRECEDENCE'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'ordered precedence-level pair'
			Axes = @{
				LeftLevel = @('multiplicative', 'additive', 'shift', 'relational', 'equality', 'bitwise_and', 'bitwise_xor', 'bitwise_or', 'logical_and', 'logical_or', 'conditional', 'assignment')
				RightLevel = @('multiplicative', 'additive', 'shift', 'relational', 'equality', 'bitwise_and', 'bitwise_xor', 'bitwise_or', 'logical_and', 'logical_or', 'conditional', 'assignment')
				Grouping = @('unparenthesized', 'left_parenthesized', 'right_parenthesized')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode')
			Expected = 'Every ordered pair of precedence levels has an unparenthesized result and both explicit groupings, with distinct operands proving the parse tree and representative bytecode agreeing with the runtime value.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp|FExpressionPrecedenceTests|LevelsByLevelAndGrouping'
		}
		@{
			Id = 'LANG-EXPR-ASSOCIATIVITY'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'same-level associativity'
			Axes = @{
				Level = @('multiplicative', 'additive', 'shift', 'relational', 'equality', 'bitwise_and', 'bitwise_xor', 'bitwise_or', 'logical_and', 'logical_or', 'conditional', 'assignment')
				Sequence = @('repeated_operator', 'mixed_same_level')
				Grouping = @('unparenthesized', 'left_parenthesized', 'right_parenthesized')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode')
			Expected = 'Repeated and mixed operators at each level expose the current fork associativity, while explicit left and right grouping provide independently computed controls.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp|FExpressionPrecedenceTests|LevelsBySequenceAndGrouping'
		}
		@{
			Id = 'LANG-EXPR-LAZY-EVALUATION'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'logical and conditional lazy evaluation'
			Axes = @{
				Form = @('logical_and', 'logical_or', 'conditional')
				Selector = @('false', 'true')
				OperandOutcome = @('value', 'side_effect', 'exception')
				SourceShape = @('single_line', 'comments', 'multiline', 'parenthesized')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'Counters and exceptions prove exactly which logical operand or conditional branch executes, skipped expressions have no side effects, and exceptional cells clean up and reuse their context.'
			Owner = 'Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp|FLazyExpressionEvaluationTests|LazyFormsBySelectorOutcomeAndShape'
		}
		@{
			Id = 'LANG-EXPR-CHAIN'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'multi-stage expression chain'
			Axes = @{
				Shape = @('call_member', 'member_call', 'index_member', 'member_index', 'cast_member', 'call_index_cast', 'member_call_index', 'cast_call_member_index')
				Depth = @('two', 'three', 'eight', 'deep_boundary')
				State = @('valid', 'null_receiver', 'invalid_intermediate', 'exception_intermediate', 'missing_terminal')
				Context = @('initializer', 'argument', 'return', 'condition', 'assignment')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Debug', 'Cleanup')
			Expected = 'Each generated chain records the visited stages, result type and value, or attributes failure to the injected receiver/intermediate/terminal stage without evaluating later stages.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionChainTests.cpp|FExpressionChainTests|ShapesByDepthStateAndContext'
		}
		@{
			Id = 'LANG-EXPR-RESOLUTION'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'symbol and callable resolution in expression context'
			Axes = @{
				State = @('exact', 'namespace_qualified', 'overload', 'conversion', 'missing', 'ambiguous', 'inaccessible', 'wrong_type')
				Context = @('initializer', 'assignment', 'argument', 'return', 'condition', 'index', 'member_receiver')
				Shape = @('identifier', 'call', 'member', 'scoped_name')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata')
			Expected = 'Successful cells identify the exact declaration and runtime marker; missing, ambiguous, inaccessible, and wrong-type cells emit one located diagnostic owned by the expression node.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionResolutionTests.cpp|FExpressionResolutionTests|StatesByContextAndShape'
		}
		@{
			Id = 'LANG-EXPR-SOURCE-BOUNDARY'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'expression source-shape and depth boundary'
			Axes = @{
				Scenario = @('parentheses_one', 'parentheses_eight', 'parentheses_sixty_four', 'chain_one', 'chain_eight', 'chain_thirty_two', 'arguments_zero', 'arguments_one', 'arguments_many', 'numeric_minimum', 'numeric_maximum', 'whitespace', 'comments', 'multiline')
				Context = @('initializer', 'argument', 'return', 'condition', 'index')
				Build = @('first', 'same_rebuild', 'changed_rebuild')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Cleanup')
			Expected = 'Boundary-shaped expressions compile and execute with stable source locations, then reproduce or intentionally change their result across isolated rebuilds without stale functions.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionBoundaryTests.cpp|FExpressionBoundaryTests|ScenariosByContextAndBuild'
		}
		@{
			Id = 'LANG-EXPR-FAILURE'
			SourceCatalog = 'expressions.md'
			Theme = 'Expressions'
			Element = 'isolated expression failure'
			Axes = @{
				Failure = @('invalid_lvalue', 'missing_delimiter', 'malformed_ternary', 'missing_symbol', 'ambiguous_symbol', 'inaccessible_member', 'missing_member', 'divide_zero', 'index_out_of_range', 'null_access', 'exception_left', 'exception_right')
				Context = @('initializer', 'assignment', 'argument', 'return', 'condition', 'loop_clause', 'switch_selector', 'index')
				Recovery = @('fresh_module', 'rebuild_or_context_reuse')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Debug', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each generated module contains one intended parse, compile, or runtime failure; its exact source location and stopped side-effect trace are observable, followed by a clean rebuild or same-context execution.'
			Owner = 'Language/Expressions/AngelscriptNativeExpressionFailureTests.cpp|FExpressionFailureTests|FailuresByContextAndRecovery'
		}
		@{
			Id = 'LANG-CF-STATEMENT-COUNT-TRANSFER'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'statement execution and transfer'
			Axes = @{
				Statement = @('if', 'if_else', 'else_if', 'while', 'do_while', 'for', 'switch', 'nested_block')
				Count = @('zero', 'one', 'two', 'many')
				Transfer = @('none', 'break_loop', 'break_switch', 'continue', 'early_return', 'nested_return', 'fallthrough', 'exception')
				Nesting = @('none', 'same_kind', 'mixed_loop', 'loop_switch', 'branch_loop', 'three_level')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Lifecycle', 'Bytecode')
			Expected = 'Trace, iteration count, transfer target, lifetime order, and representative control-flow bytecode agree.'
			Owner = 'Language/ControlFlow/AngelscriptNativeStatementTransferTests.cpp|FStatementTransferTests|StatementsByCountTransferAndNesting'
		}
		@{
			Id = 'LANG-CF-CONDITION'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'condition source and branch result'
			Axes = @{
				Statement = @('if', 'while', 'do_while', 'for')
				Condition = @('bool_literal', 'variable', 'comparison', 'logical', 'side_effect_call', 'overloaded_conversion', 'invalid_type')
				Truth = @('false', 'true')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime')
			Expected = 'The condition is evaluated the exact expected number of times and selects one branch; invalid types are rejected.'
			Owner = 'Language/ControlFlow/AngelscriptNativeConditionTests.cpp|FConditionTests|StatementsByConditionAndTruth'
		}
		@{
			Id = 'LANG-CF-SWITCH'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'switch selector and case shape'
			Axes = @{
				Selector = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'enum', 'typedef', 'boundary', 'unsupported')
				Case = @('first', 'middle', 'last', 'default', 'no_match', 'fallthrough', 'grouped', 'duplicate', 'non_constant')
				Exit = @('break', 'fallthrough', 'return', 'exception')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Lifecycle', 'Bytecode')
			Expected = 'The selected case, transfer, and local lifetime are exact; invalid selectors/cases fail without partial execution.'
			Owner = 'Language/ControlFlow/AngelscriptNativeSwitchTests.cpp|FSwitchTests|SelectorsByCaseAndExit'
		}
		@{
			Id = 'LANG-EX-ORIGIN-DEPTH'
			SourceCatalog = 'exceptions.md'
			Theme = 'Exceptions'
			Element = 'exception origin and call depth'
			Axes = @{
				Origin = @('null_access', 'divide_fault', 'bounds_fault', 'native_callback', 'host_set_exception', 'constructor', 'member', 'destructor', 'protocol_callback')
				Depth = @('top', 'one_call', 'three_calls', 'recursion', 'method', 'virtual', 'imported')
				Callback = @('absent', 'installed', 'replaced', 'cleared')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Diagnostic', 'Debug', 'Lifecycle', 'Cleanup')
			Expected = 'Exception text, function, section, location, stack, callback event, and cleanup match the exact origin and depth.'
			Owner = 'Language/Exceptions/AngelscriptNativeExceptionOriginTests.cpp|FExceptionOriginTests|OriginsByDepthAndCallback'
		}
		@{
			Id = 'LANG-EX-CLEANUP-REUSE'
			SourceCatalog = 'exceptions.md'
			Theme = 'Exceptions'
			Element = 'exception cleanup and context reuse'
			Axes = @{
				LiveState = @('none', 'locals', 'nested_scopes', 'arguments', 'partial_construction', 'base_members', 'iterator', 'reference')
				FollowUp = @('unprepare', 'same_function', 'different_arity', 'different_type', 'different_return', 'rebuild', 'release', 'clean_execute')
				NestedState = @('none', 'one', 'two')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'All initialized state unwinds once and the requested follow-up observes no stale arguments, frames, exception, or return storage.'
			Owner = 'Language/Exceptions/AngelscriptNativeExceptionRecoveryTests.cpp|FExceptionRecoveryTests|LiveStatesByFollowUpAndNesting'
		}
		@{
			Id = 'LANG-EX-METADATA-STACK'
			SourceCatalog = 'exceptions.md'
			Theme = 'Exceptions'
			Element = 'exception stack metadata by call depth and source layout'
			Axes = @{
				Depth = @('top', 'one_call', 'three_calls', 'method')
				Layout = @('lf', 'crlf', 'lf_comments')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'Each generated exception source retains the exact exception text, throwing function, source line/column/section, every available callstack frame, and clean unprepare/discard state across call depth and line layout.'
			Owner = 'Language/Exceptions/AngelscriptNativeExceptionMetadataTests.cpp|FExceptionMetadataTests|StackMetadataByDepthAndLayout'
		}
		@{
			Id = 'LANG-EX-HANDLER-REJECTION'
			SourceCatalog = 'exceptions.md'
			Theme = 'Exceptions'
			Element = 'unsupported exception handler syntax rejection and recovery'
			Axes = @{
				Feature = @('try_catch', 'try_without_catch', 'catch_without_try', 'rethrow')
				Placement = @('entry_body', 'nested_function', 'after_valid_declaration')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'The current fork rejects each unsupported try/catch/rethrow spelling at every selected function placement and line ending, publishes no partial Entry, retains a compiler diagnostic, and rebuilds the same module name with an independent valid function.'
			Owner = 'Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp|FExceptionHandlingRejectionTests|UnsupportedHandlersByPlacementAndLineEnding'
		}
		@{
			Id = 'LANG-FE-SIZE-VARIABLE'
			SourceCatalog = 'foreach.md'
			Theme = 'Foreach'
			Element = 'foreach element binding'
			Axes = @{
				Size = @('empty', 'one', 'two', 'many')
				Element = @('primitive', 'value_object', 'reference_object', 'const_element')
				Variable = @('value', 'auto', 'mutable_reference', 'const_reference', 'incompatible')
				Transfer = @('complete', 'break_first', 'break_middle', 'break_last', 'continue_first', 'continue_middle', 'return', 'exception')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Lifecycle', 'Cleanup')
			Expected = 'Iteration values, count, binding identity, transfer, and destruction agree; incompatible variables fail at binding.'
			Owner = 'Language/Foreach/AngelscriptNativeForeachIterationTests.cpp|FForeachIterationTests|SizesByElementVariableAndTransfer'
		}
		@{
			Id = 'LANG-FE-PROTOCOL'
			SourceCatalog = 'foreach.md'
			Theme = 'Foreach'
			Element = 'foreach opFor protocol'
			Axes = @{
				Protocol = @('complete', 'overloaded', 'missing_begin', 'missing_next', 'missing_value', 'missing_end', 'wrong_parameter', 'wrong_return', 'inaccessible', 'throwing')
				Resolution = @('exact', 'conversion', 'const_overload', 'ambiguous', 'missing')
				Nesting = @('single', 'same_iterable', 'distinct_iterable', 'inside_for', 'contains_for')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Lifecycle', 'Cleanup')
			Expected = 'The exact protocol overload and callback order are observed, or the incomplete/ambiguous protocol yields one stable diagnostic and balanced iterators.'
			Owner = 'Language/Foreach/AngelscriptNativeForeachProtocolTests.cpp|FForeachProtocolTests|ProtocolsByResolutionAndNesting'
		}
		@{
			Id = 'LANG-FE-TRANSFER-LIFETIME'
			SourceCatalog = 'foreach.md'
			Theme = 'Foreach'
			Element = 'foreach transfer and element lifetime'
			Axes = @{
				Transfer = @('complete', 'break_first', 'break_middle', 'continue_first', 'continue_middle', 'return', 'exception')
				Nesting = @('single', 'nested_same', 'nested_distinct', 'inside_for')
				Element = @('primitive_value', 'value_object_copy', 'value_object_const_ref')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every transfer path is executed at a selected nesting target. Iterator begin/next/value counts, exact return or exception state, native value copy/destruction, module discard, and context cleanup remain balanced.'
			Owner = 'Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp|FForeachTransferLifetimeTests|TransfersByNestingAndElementLifetime'
		}
		@{
			Id = 'LANG-FE-STRUCTURAL-MUTATION'
			SourceCatalog = 'foreach.md'
			Theme = 'Foreach'
			Element = 'foreach structural mutation'
			Axes = @{
				Size = @('one', 'two', 'many')
				Mutation = @('stable', 'shrink_first', 'shrink_middle', 'clear_after_first')
				Element = @('primitive_value', 'value_object_copy', 'value_object_const_ref')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Changing the live range count during iteration has an explicit current-fork result for each input size and element binding; the observed count, iterator advancement, value lifetime, module discard, and cleanup are exact.'
			Owner = 'Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp|FForeachTransferLifetimeTests|StructuralMutationBySizeAndElement'
		}
		@{
			Id = 'DBG-CALLBACK-STATE-PATH'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'context callback lifecycle'
			Axes = @{
				Family = @('exception', 'instruction', 'line', 'loop_detection', 'stack_pop')
				State = @('absent', 'installed', 'replaced', 'cleared', 'cleared_twice', 'reused')
				Path = @('straight', 'branch_taken', 'branch_not_taken', 'loop_zero', 'loop_one', 'loop_many', 'nested', 'recursion', 'method', 'exception')
				UserData = @('null', 'recorder', 'replacement_recorder')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Cleanup')
			Expected = 'The callback emits the exact ordered events to the active recorder and emits nothing after clear.'
			Owner = 'Runtime/Debug/AngelscriptNativeCallbackLifecycleTests.cpp|FNativeCallbackLifecycleTests|FamiliesByStatePathAndUserData'
		}
		@{
			Id = 'DBG-STACK-FRAME-QUERY'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'call stack frame query'
			Axes = @{
				Depth = @('one', 'two', 'three', 'recursion', 'deep')
				State = @('callback', 'exception', 'finished', 'unprepared')
				Index = @('current', 'middle', 'root', 'out_of_range', 'large_invalid')
				Query = @('size', 'function', 'blueprint_frame', 'line', 'section', 'frame_pointer', 'frame_size')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Metadata')
			Expected = 'Valid frames return exact function/source/pointer-range data and invalid states/indexes return safe documented values. At a real unhandled fault, asCContext::WillExceptionBeCaught returns false before Unprepare and context reuse; the tagged selected-2.38 try/catch owner retains the true disposition until that language path is available.'
			Owner = 'Runtime/Debug/AngelscriptNativeCallstackTests.cpp|FNativeCallstackTests|DepthsByStateIndexAndQuery'
		}
		@{
			Id = 'DBG-STACK-FRAME-BOUNDARIES'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'call stack frame boundary query'
			Axes = @{
				Depth = @('one_frame', 'three_frame', 'recursive_depth')
				Query = @('first', 'last', 'out_of_range')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Metadata', 'Cleanup')
			Expected = 'One-frame, three-frame, and recursive call stacks expose valid first and last frame pointers, lines, and positive sizes; the exact depth boundary returns null function/frame and asINVALID_ARG line results.'
			Owner = 'Runtime/Debug/AngelscriptNativeCallstackTests.cpp|FNativeCallstackTests|DepthsByStateIndexAndQuery'
		}
		@{
			Id = 'DBG-EXCEPTION-CAUGHT-QUERY'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'uncaught exception catchability and context reuse'
			Axes = @{
				Depth = @('one', 'two', 'three', 'five')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'An unhandled exception at every generated nested depth reports false from WillExceptionBeCaught, preserves the fault function and diagnostic text, retains the expected stack depth, and allows the same context to unprepare, execute a recovery function, and cleanly discard its module.'
			Owner = 'Runtime/Debug/AngelscriptNativeExceptionCaughtQueryTests.cpp|FNativeExceptionCaughtQueryTests|WillExceptionBeCaughtByNestedDepthAndContextReuse'
		}
		@{
			Id = 'DBG-LOCAL-TYPE-ROLE-QUERY'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'local variable debug query'
			Axes = @{
				Type = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool', 'enum', 'typedef', 'value_object', 'reference', 'null', 'native_object')
				Role = @('parameter', 'local', 'nested_local', 'loop_local', 'shadowed')
				Query = @('count', 'name', 'declaration', 'declaration_namespace', 'type_id', 'address', 'scope', 'value')
				Optimization = 'OptimizationModes'
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Metadata')
			Expected = 'Name, declaration, type, address, scope, and value identify the exact live variable under the selected optimization mode.'
			Owner = 'Runtime/Debug/AngelscriptNativeLocalVariableTests.cpp|FNativeLocalVariableTests|TypesByRoleQueryAndOptimization'
		}
		@{
			Id = 'DBG-THIS-CALL-FRAME'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'receiver debug query'
			Axes = @{
				Call = @('global', 'member', 'base', 'derived', 'virtual', 'null_object')
				Frame = @('current', 'caller', 'root', 'invalid')
				Query = @('type_id', 'pointer')
				State = @('callback', 'exception', 'finished', 'unprepared', 'nested_outer', 'nested_inner')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Metadata')
			Expected = 'Receiver type and pointer match declared/runtime semantics for valid member frames and are safely absent for global or invalid states.'
			Owner = 'Runtime/Debug/AngelscriptNativeThisPointerTests.cpp|FNativeThisPointerTests|CallsByFrameQueryAndState'
		}
		@{
			Id = 'DBG-NEST-STATE'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'nested context state preservation'
			Axes = @{
				OuterState = @('prepared', 'active_callback', 'exception', 'finished', 'unprepared')
				NestCount = @('zero', 'one', 'two')
				InnerOutcome = @('return', 'exception', 'abort', 'suspend_rejected')
				Observation = @('function', 'arguments', 'return', 'exception', 'frames', 'locals', 'debug_frame_pointer')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Debug', 'Cleanup')
			Expected = 'Push/inner/pop preserves or restores every outer observation exactly; invalid push/pop has the current deterministic result.'
			Owner = 'Runtime/Debug/AngelscriptNativeNestedContextTests.cpp|FNativeNestedContextTests|OuterStatesByNestOutcomeAndObservation'
		}
		@{
			Id = 'DBG-FUNCTION-METADATA'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'script function debug metadata'
			Axes = @{
				Function = @('script', 'system', 'imported', 'noop')
				Query = @('section', 'module', 'name', 'declaration', 'var_count', 'var', 'var_decl', 'next_line', 'bytecode')
				Lifecycle = @('built', 'rebuilt', 'saved_loaded', 'debug_stripped')
				Optimization = 'OptimizationModes'
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Debug', 'Runtime', 'Bytecode')
			Expected = 'Function identity, locals, executable-line search, and bytecode pointer/length match the lifecycle and optimization contract.'
			Owner = 'Runtime/Debug/AngelscriptNativeFunctionDebugMetadataTests.cpp|FNativeFunctionDebugMetadataTests|FunctionsByQueryLifecycleAndOptimization'
		}
		@{
			Id = 'MOD-BYTECODE-STREAM-RESTORE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'raw bytecode stream format, restore, and rejection behavior'
			Axes = @{
				Scenario = @(
					'primitive_round_trip',
					'debug_info_stripped_round_trip',
					'empty_stream_rejected',
					'truncated_stream_rejected',
					'failed_load_leaves_module_clean',
					'legacy_version_one_rejected',
					'copy_script_determinism_and_current_load_restriction'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Current framed streams round-trip the supported primitive forms and preserve the requested debug-info state; empty, truncated, failed, and version-one streams leave no published module state. Identical raw engines save identical non-POD CopyScript streams, while the current loader rejects the nested shared $obj declaration before bytecode translation with its exact diagnostic.'
			Owner = 'Module/AngelscriptNativeRestorePrimitiveTests.cpp|FRestorePrimitiveTests|CopyScriptSaveDeterminismAndCurrentForkLoadRestriction'
		}
		@{
			Id = 'MOD-SCRIPT-CLASS-SAVELOAD-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'raw script-class bytecode save/load and predecessor retention'
			Axes = @{
				Predecessor = @('release-predecessor-before-source-discard', 'retain-predecessor-across-destination-load')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The exact base/derived script-class layout, inherited offsets, debug information, and four runtime values survive bytecode save/load. Releasing or retaining the predecessor entry changes only the explicitly requested predecessor lifetime while destination execution, module discard, engine teardown, and post-teardown allocation remain valid.'
			Owner = 'Module/AngelscriptNativeScriptClassSaveLoadLifecycleTests.cpp|FScriptClassSaveLoadLifecycleTests|PredecessorRetentionBySaveLoadLifecycle'
		}
		@{
			Id = 'ENG-ATOMIC-OPERATIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw asCAtomic operations across initial values and worker modes'
			Axes = @{
				Operation = @('set_get', 'increment', 'decrement', 'balanced_pair')
				InitialValue = @('zero', 'negative_one', 'one', 'positive')
				WorkerMode = @('single', 'concurrent')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Isolation')
			Expected = 'Every operation, initial value, and worker mode directly exercises asCAtomic, retains deterministic final values, and leaves an independently owned control atomic unchanged; the value type has no observable cleanup contract.'
			Owner = 'Engine/AngelscriptNativeAtomicTests.cpp|FAtomicTests|OperationsByInitialValueAndWorkerMode'
		}
		@{
			Id = 'ENG-ATOMIC-DEFAULT-CONSTRUCTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw atomic default construction'
			Axes = @{
				Observation = @('initial_read')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Isolation')
			Expected = 'A fresh asCAtomic publishes zero while a separately mutated control retains its exact value across fresh-object mutation.'
			Owner = 'Engine/AngelscriptNativeAtomicTests.cpp|FAtomicTests|DefaultConstructionStartsAtZero'
		}
		@{
			Id = 'ENG-ATOMIC-RETURN-TRANSITIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw atomic operation return transitions'
			Axes = @{
				Transition = @('increment_zero_to_one', 'increment_one_to_two', 'decrement_two_to_one', 'final_read')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Isolation')
			Expected = 'Increment and decrement return the post-operation value for consecutive transitions, the final read preserves the last transition, and an independent control remains unchanged.'
			Owner = 'Engine/AngelscriptNativeAtomicTests.cpp|FAtomicTests|IncrementAndDecrementReturnExpectedValues'
		}
		@{
			Id = 'ENG-ATOMIC-BATCHED-CONCURRENCY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'balanced raw atomic worker batches'
			Axes = @{
				Observation = @('all_workers_created', 'all_workers_joined', 'final_zero')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Four independently identified workers each complete exactly one owned 4,096-increment/decrement batch, join cleanly, and restore the shared atomic value to zero.'
			Owner = 'Engine/AngelscriptNativeAtomicTests.cpp|FAtomicTests|ConcurrentIncrementAndDecrementRemainBalanced'
		}
		@{
			Id = 'ENG-PRODUCT-VERSION-CONTRACT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'owned Unreal AngelScript product version and upstream lineage contract'
			Axes = @{
				Observation = @(
					'product_identity',
					'upstream_lineage',
					'current_version_creation',
					'legacy_upstream_rejection',
					'newer_header_rejection',
					'major_and_zero_rejection',
					'semantic_compatibility',
					'version_encoding'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Diagnostic', 'Lifecycle')
			Expected = 'The runtime reports Unreal AngelScript 1.0.0 as product version 10000, exposes 2.33/2.38 provenance separately, accepts current and synthetic older same-major requests, and rejects legacy, newer, zero, and cross-major requests.'
			Owner = 'Engine/AngelscriptNativeEngineVersionTests.cpp|FEngineVersionTests|ReportsOwnedProductIdentity'
		}
		@{
			Id = 'ENG-LIFECYCLE-CROSS-ENGINE-MESSAGE-CALLBACK'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw engine creation, callback reuse, and shutdown isolation'
			Axes = @{
				State = @('primary_created', 'primary_callback_installed', 'callback_readback', 'secondary_reuse', 'secondary_message')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Two raw engines are independently created and released; the primary callback metadata can be read back, installed on the secondary engine, and receives the exact secondary message payload and section.'
			Owner = 'Engine/AngelscriptNativeEngineLifecycleTests.cpp|FEngineLifecycleTests|CreatesAndShutsDownRawEngine'
		}
		@{
			Id = 'ENG-LIFECYCLE-MODULE-ENUMERATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw engine module inventory lifecycle'
			Axes = @{
				Observation = @(
					'initial_empty',
					'two_built',
					'first_identity',
					'second_identity',
					'one_past_end',
					'post_discard_name_absence',
					'post_discard_index_retention'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A fresh raw engine reports no modules, publishes both independently built named modules through indexed enumeration, and returns null one past the inventory. Explicit discard removes both names from application lookup, while the current fork retains both discarded entries in GetModuleCount/GetModuleByIndex until shutdown; the enabled negative contract records that cleanup limitation.'
			Owner = 'Engine/AngelscriptNativeEngineLifecycleTests.cpp|FEngineLifecycleTests|ModuleEnumeration'
		}
		@{
			Id = 'ENG-LIFECYCLE-EMPTY-GC-MODES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'empty raw-engine garbage-collection modes'
			Axes = @{
				Scenario = @('fresh_inventory', 'default_full_cycle', 'detecting_full_cycle', 'incremental_step', 'final_inventory', 'destroyed_count', 'detected_count')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Default and detecting full cycles return the finished sentinel, one incremental step returns the current-fork unfinished-cycle sentinel, and no mode publishes, destroys, or detects GC objects on an empty engine.'
			Owner = 'Engine/AngelscriptNativeEngineLifecycleTests.cpp|FEngineLifecycleTests|GarbageCollectCycle'
		}
		@{
			Id = 'ENG-EXACT-DECLARATION-OVERLOAD-REJECTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'exact declaration lookup across overloads'
			Axes = @{
				Observation = @('missing_double_rejected', 'two_named_overloads_visible')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Exact declaration lookup refuses a missing double overload while explicit name enumeration retains both compiled int and float overloads, then explicit discard removes the owning module.'
			Owner = 'Engine/AngelscriptNativeEngineSmokeTests.cpp|FEngineSmokeTests|DeclarationLookupRejectsDifferentOverload'
		}
		@{
			Id = 'ENG-MEMORY-EMPTY-FREE-UNUSED'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'empty raw memory-pool release idempotence'
			Axes = @{
				Invocation = @('first', 'repeated')
				Pool = @('script_node', 'byte_instruction')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'First and repeated FreeUnusedMemory calls remain safe on both empty internal pools and leave their retained allocation counts at zero.'
			Owner = 'Engine/AngelscriptNativeMemoryTests.cpp|FMemoryTests|MemoryFreeUnused'
		}
		@{
			Id = 'ENG-MEMORY-SCRIPT-NODE-LIFO-REUSE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'script-node allocation-pool LIFO reuse'
			Axes = @{
				Observation = @('first_live', 'second_live', 'live_distinct', 'two_retained', 'second_reused_first', 'first_reused_second', 'pool_empty')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Two simultaneous script-node allocations are distinct; freeing them in order retains both and subsequent allocations consume them in reverse order before cleanup.'
			Owner = 'Engine/AngelscriptNativeMemoryTests.cpp|FMemoryTests|MemoryScriptNodeReuse'
		}
		@{
			Id = 'ENG-MEMORY-BYTE-INSTRUCTION-LIFO-REUSE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'byte-instruction allocation-pool LIFO reuse'
			Axes = @{
				Observation = @('first_live', 'second_live', 'live_distinct', 'two_retained', 'second_reused_first', 'first_reused_second', 'pool_empty')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Two simultaneous byte-instruction allocations are distinct; freeing them in order retains both and subsequent allocations consume them in reverse order before cleanup.'
			Owner = 'Engine/AngelscriptNativeMemoryTests.cpp|FMemoryTests|ByteInstructionReuse'
		}
		@{
			Id = 'ENG-MEMORY-POOL-BULK-RELEASE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'populated raw memory-pool bulk release'
			Axes = @{
				Pool = @('script_node', 'byte_instruction')
				State = @('retained', 'released')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Freed script-node and byte-instruction allocations are independently visible in their pools before FreeUnusedMemory and both pools are empty afterward.'
			Owner = 'Engine/AngelscriptNativeMemoryTests.cpp|FMemoryTests|PoolLeakTracking'
		}
		@{
			Id = 'ENG-TLS-MAIN-THREAD-STABILITY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'main-thread raw TLS identity'
			Axes = @{
				Lookup = @('first', 'repeated')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Isolation')
			Expected = 'The first main-thread lookup creates non-null local data, a repeated lookup returns the same identity, and a simultaneously live worker publishes a distinct stable identity.'
			Owner = 'Engine/AngelscriptNativeThreadingTests.cpp|FThreadingTests|PreparedThreadReturnsLocalData'
		}
		@{
			Id = 'ENG-TLS-WORKER-ISOLATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'simultaneous raw TLS worker isolation'
			Axes = @{
				Relation = @('worker_repeat', 'worker_vs_main', 'worker_pairwise')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Three simultaneously live workers each retain stable non-null local data that differs from the main thread and from every other worker, then all workers and synchronization objects are released.'
			Owner = 'Engine/AngelscriptNativeThreadingTests.cpp|FThreadingTests|WorkerThreadsReceiveDistinctLocalData'
		}
		@{
			Id = 'ENG-TLS-MAIN-STABILITY-AFTER-WORKER'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'main-thread raw TLS identity across worker teardown'
			Axes = @{
				State = @('before_worker', 'worker_completed', 'after_worker')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A complete worker TLS lifecycle does not replace or invalidate the main thread local-data identity.'
			Owner = 'Engine/AngelscriptNativeThreadingTests.cpp|FThreadingTests|RepeatedLookupReturnsStableLocalData'
		}
		@{
			Id = 'ENG-LOCKABLE-SHARED-BOOL-CONTENTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'lockable shared-bool mutual exclusion and mutation'
			Axes = @{
				InitialValue = @('initial_false', 'initial_true')
				TargetValue = @('target_false', 'target_true')
				WorkerMode = @('single', 'contended')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every initial value, target value, and worker mode directly exercises Lock and Unlock, completes every protected mutation, prevents overlapping critical sections, publishes the exact final bool, and releases the shared flag only after all workers join.'
			Owner = 'Engine/AngelscriptNativeAtomicTests.cpp|FAtomicTests|LockAndUnlockSerializeWorkerMutation'
		}
		@{
			Id = 'ENG-PROPERTY-ISOLATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'engine property value and independent-engine isolation'
			Axes = @{
				Property = @(
					'allow_unsafe_references',
					'allow_multiline_strings',
					'script_scanner',
					'optimize_bytecode',
					'auto_garbage_collect',
					'alter_syntax_named_args',
					'disallow_value_assign_for_ref_type',
					'allow_implicit_handle_types',
					'require_enum_scope',
					'always_impl_default_construct',
					'always_impl_default_copy',
					'always_impl_default_copy_construct',
					'member_init_mode',
					'allow_double_type'
				)
				AppliedValue = @('zero', 'one')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Each selected native engine property accepts the generated value, is observable on the owning engine, leaves two independent control engines unchanged, and permits a generated probe to compile and execute before explicit discard and null lookup.'
			Owner = 'Engine/AngelscriptNativeEnginePropertyIsolationTests.cpp|FEnginePropertyIsolationTests|PropertyValuesStayIndependentAcrossGeneratedCases'
		}
		@{
			Id = 'ENG-PROPERTY-PROFILE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'bare and fork engine property profile behavior'
			Axes = @{
				Profile = @('bare_sdk', 'fork_configured')
				Property = @(
					'allow_unsafe_references',
					'use_character_literals',
					'allow_multiline_strings',
					'script_scanner',
					'optimize_bytecode',
					'auto_garbage_collect',
					'alter_syntax_named_args',
					'disallow_value_assign_for_ref_type',
					'allow_implicit_handle_types',
					'require_enum_scope',
					'always_impl_default_construct',
					'always_impl_default_copy',
					'always_impl_default_copy_construct',
					'member_init_mode',
					'typecheck_switch_enums',
					'allow_double_type'
				)
				AppliedValue = @('zero', 'one')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Each touched engine property is observed in both the bare SDK and fork-configured profiles. The selected primary engine accepts and exposes the applied value, an independent control engine retains its own baseline, a printed probe compiles and executes on the selected profile, and the property is restored before the next cell.'
			Owner = 'Engine/AngelscriptNativeEnginePropertyProfileTests.cpp|FEnginePropertyProfileTests|ProfilesByPropertyAndAppliedValue'
		}
		@{
			Id = 'ENG-ENGINE-REFCOUNT-LIFETIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'public engine reference-count balance and continued usability'
			Axes = @{
				ReferenceOperation = @('balanced_addref_release')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A direct public AddRef/Release pair changes the reported count by exactly one and leaves the fixture-owned engine usable with its registered inventory intact.'
			Owner = 'Engine/AngelscriptNativeEngineInventoryDepthTests.cpp|FEngineInventoryDepthTests|ReferenceCountRemainsUsableAfterBalancedPair'
		}
		@{
			Id = 'ENG-TYPE-INVENTORY-BY-CATEGORY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'registered object and enum inventory by namespace'
			Axes = @{
				Category = @('object', 'enum')
				Namespace = @('root', 'nested')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Runtime', 'Diagnostic', 'Isolation')
			Expected = 'Root and nested object/enum registrations increase only their own inventory, retain exact name/namespace/type ID identity through indexed lookup, and return null at the one-past-end boundary. An independent engine rejects an uncategorized object registration with the exact asINVALID_ARG diagnostic and preserves both inventory counts.'
			Owner = 'Engine/AngelscriptNativeEngineInventoryDepthTests.cpp|FEngineInventoryDepthTests|RegisteredTypesByCategoryAndNamespace'
		}
		@{
			Id = 'ENG-DEFAULT-NAMESPACE-TRANSITIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'engine default namespace transition and restoration'
			Axes = @{
				NamespaceState = @('root', 'nested', 'restored')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Root, nested, and restored namespace states return success and expose exact public readback without leaving shared registration state in a different namespace.'
			Owner = 'Engine/AngelscriptNativeEngineInventoryDepthTests.cpp|FEngineInventoryDepthTests|DefaultNamespaceTransitionsAndRestores'
		}
		@{
			Id = 'ENG-PRIMITIVE-SIZE-TYPEINFO'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'primitive byte size and non-primitive boundary'
			Axes = @{
				TypeKind = @(
					'bool',
					'int8',
					'uint8',
					'int16',
					'uint16',
					'int32',
					'uint32',
					'int64',
					'uint64',
					'float32',
					'float64',
					'void',
					'object'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every published primitive width returns its exact storage size while void and object IDs return zero without changing engine state. Negative IDs are excluded because this fork indexes primitive metadata without a safe negative guard.'
			Owner = 'Engine/AngelscriptNativeEngineInventoryDepthTests.cpp|FEngineInventoryDepthTests|PrimitiveSizesByPublicTypeId'
		}
		@{
			Id = 'ENG-TYPEINFO-ID-LOOKUP'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'TypeInfo lookup by registered, qualified, primitive, and invalid type ID'
			Axes = @{
				LookupKind = @(
					'root_object',
					'nested_object',
					'root_enum',
					'nested_enum',
					'object_handle',
					'primitive',
					'invalid'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic', 'Isolation')
			Expected = 'Registered object and enum IDs resolve exact TypeInfo identity, handle qualification resolves the same object type, and primitive/invalid IDs return null.'
			Owner = 'Engine/AngelscriptNativeEngineInventoryDepthTests.cpp|FEngineInventoryDepthTests|TypeInfoLookupByIdKindAndFlags'
		}
		@{
			Id = 'MOD-API-RENAME-REINDEX'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'module rename and engine-name index replacement'
			Axes = @{
				RenameState = @('old_to_new')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Renaming a live compiled module removes the old engine lookup, publishes the same module under the new name, retains exact metadata, executes its function, and cleans up by the new name.'
			Owner = 'Module/AngelscriptNativeModuleRenameReindexTests.cpp|FModuleRenameReindexTests|RenameReindexesEngineLookup'
		}
		@{
			Id = 'MOD-API-COMPILE-FUNCTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'single-function compile ownership and invalid arguments'
			Axes = @{
				CompileMode = @('detached', 'attached', 'invalid_flags', 'null_source')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup')
			Expected = 'Detached and attached compilation retain exact ownership, inventory, section, lookup, runtime, and release behavior; invalid flags and null source return asINVALID_ARG and clear the out pointer without changing module inventory.'
			Owner = 'Module/AngelscriptNativeModuleCompileFunctionTests.cpp|FModuleCompileFunctionTests|CompileFunctionDetachedAttachedAndInvalid'
		}
		@{
			Id = 'MOD-API-REMOVE-FUNCTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'owned function removal with external lifetime'
			Axes = @{
				RemovalState = @('foreign_rejected', 'owned_removed', 'external_reference_executes', 'repeat_rejected')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup')
			Expected = 'Foreign removal is rejected; owned removal erases only the target lookup; an explicit external reference remains executable; repeat removal reports asNO_FUNCTION; sibling functions and module cleanup remain intact.'
			Owner = 'Module/AngelscriptNativeModuleRemoveFunctionTests.cpp|FModuleRemoveFunctionTests|RemoveFunctionPreservesExternalOwnership'
		}
		@{
			Id = 'MOD-TYPEDEF-INVENTORY-BOUNDS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'fork-rejected script typedef and empty module inventory boundary'
			Axes = @{
				InventoryState = @('script_typedef_rejected', 'empty_index_zero')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Diagnostic', 'Cleanup')
			Expected = 'The current fork rejects script-level typedef at the parser boundary; the rejected build publishes no module typedef, and a clean empty module reports count zero with null index-zero lookup.'
			Owner = 'Module/AngelscriptNativeModuleTypedefInventoryTests.cpp|FModuleTypedefInventoryTests|TypedefInventoryUsesForkEmptyBoundary'
		}
		@{
			Id = 'MOD-USERDATA-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'keyed module user-data transitions and successful-GC discarded-module cleanup'
			Axes = @{
				UserDataState = @('unset', 'installed', 'replaced', 'cleared', 'discard_deferred', 'engine_shutdown_cleanup_once')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Keyed module user data returns exact prior/current pointers through install, replace, and clear; discard hides and defers destruction, then successful engine GC retires the discarded module with exactly one cleanup callback carrying the exact module and sentinel identities. Independent engine creation does not repeat the callback. Single-threaded evidence does not claim lock correctness.'
			Owner = 'Module/AngelscriptNativeModuleUserDataLifecycleTests.cpp|FModuleUserDataLifecycleTests|UserDataTransitionsAndCleanup'
		}
		@{
			Id = 'MOD-IMPORT-UNBIND-ALL'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'bulk import unbind, failure, and rebind lifecycle'
			Axes = @{
				BindingState = @('bound', 'unbound_exception', 'rebound', 'zero_import')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Two imports execute after BindAll, both fail through an exact unbound-function exception after UnbindAll, both execute again after rebind, and zero-import unbind succeeds without changing local behavior.'
			Owner = 'Module/AngelscriptNativeModuleImportUnbindAllTests.cpp|FModuleImportUnbindAllTests|UnbindAllImportsThenRebinds'
		}
		@{
			Id = 'MOD-PRECLASS-METADATA-APPLICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'pre-class metadata exact-name application and unmatched isolation'
			Axes = @{
				Target = @('exact', 'unmatched_control')
				Observation = @('initial_user_data', 'property_offset', 'type_size')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'An exact pre-class name publishes the supplied initial user-data identity, starts its own property at the supplied base offset, and includes that offset in type size; an unmatched pre-class entry leaves another declaration with null user data, ordinary zero-based property layout, and ordinary size.'
			Owner = 'Module/AngelscriptNativeModulePreClassMetadataTests.cpp|FModulePreClassMetadataTests|PreClassMetadataAppliesOnlyToExactDeclaration'
		}
		@{
			Id = 'MOD-NESTED-IMPORT-VISIBILITY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'direct and flattened module import lookup'
			Axes = @{
				LookupState = @('direct_provider', 'flattened_base', 'repeat_provider', 'repeat_base')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'A consumer resolves exact function identity from its direct provider and the provider flattened base import; repeated and direct duplicate imports preserve stable lookup without foreign or freed modules.'
			Owner = 'Module/AngelscriptNativeModuleNestedImportVisibilityTests.cpp|FModuleNestedImportVisibilityTests|NestedImportModuleVisibilityAndDeduplication'
		}
		@{
			Id = 'MOD-BUILD-FAILURE-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'failed module build publication and same-name recovery'
			Axes = @{
				Phase = @('failed_tables', 'discard', 'recovery_tables', 'recovery_runtime')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A failed build publishes no partial function table, can be discarded, and permits a clean same-name rebuild whose function, global, and object-type tables contain only the recovery source and execute its exact entry.'
			Owner = 'Module/AngelscriptNativeModuleBuildFailureTests.cpp|FModuleBuildFailureTests|FailedBuildDoesNotPublishPartialModuleTablesAndCanRecover'
		}
		@{
			Id = 'MOD-FUNCTION-INVENTORY-RUNTIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'module function inventory, scalar return ABI, and argument round trip'
			Axes = @{
				Scenario = @('enumerate_and_execute', 'scalar_return_types', 'argument_return_round_trip')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Indexed and exact-declaration lookup retain all compiled functions; every supported scalar return ABI and the selected integer, unsigned, floating, and boolean argument/return paths preserve exact values through isolated raw contexts.'
			Owner = 'Module/AngelscriptNativeModuleFunctionTests.cpp|FModuleFunctionTests|EnumerateFunctions'
		}
		@{
			Id = 'MOD-GLOBAL-STATE-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'module global inventory, reset, and removal'
			Axes = @{
				Operation = @('enumerate_metadata_storage', 'reset_preserves_inventory', 'remove_reindexes_inventory')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Module globals preserve declaration order, names, constness, type metadata, and initialized storage; reset preserves declarations and deliberately leaves directly mutated pure-constant storage unchanged in this fork; removal erases only the selected slot and leaves the remaining inventory valid before discard.'
			Owner = 'Module/AngelscriptNativeModuleGlobalTests.cpp|FModuleGlobalTests|ModuleGlobalEnumerate'
		}
		@{
			Id = 'MOD-IMPORT-BINDING-CONTRACT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'import metadata, manual binding, rejection, rebinding, and automatic binding'
			Axes = @{
				Scenario = @(
					'unbound_metadata',
					'manual_bind_execute',
					'signature_mismatch_rejected',
					'invalid_index_rejected',
					'unbind_rebind_execute',
					'bind_all_missing_rejected',
					'bind_all_execute'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Unbound imports retain exact declaration/source metadata; compatible providers execute through manual and automatic binding; signature and index mismatches return exact errors; unbind permits a different compatible provider to be rebound without stale execution state.'
			Owner = 'Module/AngelscriptNativeModuleImportTests.cpp|FModuleImportTests|ImportMetadataBeforeBinding'
		}
		@{
			Id = 'MOD-LIFECYCLE-REBUILD-ISOLATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'module creation, discard, isolation, and replacement identity'
			Axes = @{
				Scenario = @(
					'create_build_execute',
					'discard_existing',
					'discard_missing',
					'parallel_name_isolation',
					'always_create_replacement',
					'discard_recompile',
					'discard_rebuild_function_and_type_identity'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Creation/build/execution publishes exact state; existing and missing discard return distinct results; independent names do not alias; replacement and discard/rebuild paths publish new module, function, and type identities while executing only the latest body.'
			Owner = 'Module/AngelscriptNativeModuleLifecycleTests.cpp|FModuleLifecycleTests|ModuleLifecycleCreate'
		}
		@{
			Id = 'MOD-NAMESPACE-LOOKUP-CONTRACT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'module default and explicit namespace lookup behavior'
			Axes = @{
				Scenario = @('default_does_not_rehome', 'explicit_namespace_qualified_lookup', 'invalid_default_preserves_previous')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The module default namespace affects lookup without rehoming unqualified declarations; explicit source namespaces require qualified lookup; malformed namespace text is rejected without changing the previous valid default.'
			Owner = 'Module/AngelscriptNativeModuleNamespaceTests.cpp|FModuleNamespaceTests|DefaultNamespaceDoesNotRehomeDeclarations'
		}
		@{
			Id = 'MOD-SAVELOAD-FUNCTION-RESTORE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'public module bytecode save/load for function declarations and execution'
			Axes = @{
				Scenario = @('declaration_round_trip', 'stripped_debug_flag', 'truncated_then_complete_retry', 'multi_function_restore_execute')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Public SaveByteCode/LoadByteCode preserve exact function declarations and execution, report the selected debug-info state, reject a truncated stream without poisoning a complete retry, and restore all functions in a multi-function module.'
			Owner = 'Module/AngelscriptNativeModuleSaveLoadTests.cpp|FModuleSaveLoadTests|RoundTripPreservesFunctionDeclarations'
		}
		@{
			Id = 'MOD-SECTION-BUILD-DIAGNOSTIC'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'script section diagnostics, ownership, and cross-section resolution'
			Axes = @{
				Scenario = @(
					'diagnostic_section_offset',
					'declaring_section_metadata',
					'single_section_pipeline',
					'multi_section_call',
					'cross_section_symbol'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Failed sections retain exact name and line offset; successful functions retain their declaring section; single and multiple sections build and execute with sibling symbol resolution and no cross-module publication.'
			Owner = 'Module/AngelscriptNativeModuleSectionTests.cpp|FModuleSectionTests|SyntaxErrorReportsSectionAndOffset'
		}
		@{
			Id = 'MOD-STATE-TABLE-REBUILD'
			SourceCatalog = 'native-domains.md'
			Theme = 'Module'
			Element = 'top-level module tables before and after same-name rebuild'
			Axes = @{
				Scenario = @('rich_tables_execute', 'rebuild_clears_previous_tables')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A rich namespaced source publishes exact function, global, object, and enum tables and executes its entry; rebuilding the same name removes every obsolete table row and publishes only the replacement declarations.'
			Owner = 'Module/AngelscriptNativeModuleStateTableTests.cpp|FModuleStateTableTests|RichModuleStoresTopLevelTablesAndExecutesEntry'
		}
		@{
			Id = 'FRONTEND-TOKEN-TAXONOMY-ACTIVE-KEYWORDS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'fork token-table keyword spelling and identifier boundary'
			Axes = @{
				Keyword = @(
					'access', 'and', 'auto', 'bool', 'break', 'case', 'cast', 'class', 'const', 'continue', 'default', 'do', 'double', 'else', 'enum', 'false', 'fallthrough', 'float', 'float32', 'float64', 'for', 'foreach', 'funcdef', 'if', 'import', 'in', 'inout', 'interface', 'int', 'int8', 'int16', 'int32', 'int64', 'is', 'local', 'mixin', 'namespace', 'not', 'not_is', 'null', 'nullptr', 'or', 'out', 'private', 'protected', 'return', 'struct', 'switch', 'true', 'typedef', 'uint', 'uint8', 'uint16', 'uint32', 'uint64', 'unresolved_object', 'void', 'while', 'xor'
				)
				Boundary = @('bare', 'identifier_suffix')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every selected fork token-table spelling has its exact current kind and byte length across bare and suffixed input. Ordinary identifier-like spellings retain one identifier boundary; current rejected or split spellings remain explicit, including !is_suffix as ttNot followed by identifier is_suffix rather than one operator token.'
			Owner = 'Frontend/AngelscriptNativeTokenizerKeywordIdentifierDepthTests.cpp|FTokenizerKeywordIdentifierDepthTests|TokenTaxonomyCoversActiveKeywordFamilies'
		}
		@{
			Id = 'FRONTEND-TOKEN-LONGEST-MATCH-OPERATORS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'operator prefix, longest spelling, and trailing boundary'
			Axes = @{
				OperatorInput = @('slash', 'divide_assign', 'percent', 'modulo_assign', 'plus', 'add_assign', 'increment', 'minus', 'subtract_assign', 'decrement', 'multiply', 'multiply_assign', 'power', 'power_assign', 'bitwise_or', 'or_assign', 'logical_or', 'bitwise_and', 'and_assign', 'logical_and', 'bitwise_xor', 'xor_assign', 'logical_xor', 'less_than', 'less_equal', 'left_shift', 'left_shift_assign', 'greater_than', 'greater_equal', 'right_shift', 'right_shift_assign', 'arithmetic_right_shift', 'arithmetic_right_shift_assign', 'assignment', 'equality', 'logical_not', 'not_equal', 'handle_rejected', 'bitwise_not', 'dot', 'scope', 'statement_terminator', 'list_separator', 'statement_block_start', 'statement_block_end', 'parenthesis_open', 'parenthesis_close', 'bracket_open', 'bracket_close', 'question', 'colon', 'arithmetic_right_shift_assignment_tail', 'arithmetic_right_shift_name_tail', 'left_shift_name_tail', 'power_name_tail')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every active operator and punctuation spelling, plus the fork-rejected handle sigil, consumes the exact token length; overlapping forms win over shorter prefixes and trailing identifier/assignment tails remain separate.'
			Owner = 'Frontend/AngelscriptNativeTokenizerOperatorDepthTests.cpp|FTokenizerOperatorDepthTests|LongestMatchCoversOperatorPrefixAndSuffixBoundaries'
		}
		@{
			Id = 'FRONTEND-TOKEN-NUMERIC-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'numeric radix, exponent, suffix, and malformed tail'
			Axes = @{
				LiteralInput = @('decimal_zero', 'decimal_leading_zero', 'decimal_large', 'binary_zero', 'binary_value', 'octal_zero', 'octal_value', 'explicit_decimal', 'hex_zero', 'hex_value', 'float_leading_zero', 'float_leading_dot', 'float_trailing_dot', 'float32_lower_suffix', 'float32_upper_suffix', 'exponent_positive', 'exponent_signed_positive', 'exponent_signed_negative', 'float32_exponent', 'float64_exponent', 'binary_invalid_tail', 'octal_invalid_tail', 'hex_missing_digit', 'incomplete_exponent', 'sign_only_exponent', 'float_suffix_identifier_tail')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'The tokenizer identifies radix and floating forms with exact consumed lengths, preserving the current fork spelling and stopping at malformed or identifier tails.'
			Owner = 'Frontend/AngelscriptNativeTokenizerNumericDepthTests.cpp|FTokenizerNumericDepthTests|NumericLiteralFormsCoverRadixExponentAndSuffixBoundaries'
		}
		@{
			Id = 'FRONTEND-TOKEN-OPERATOR-OPERAND-SPACING'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'operator, adjacent operand, and whitespace context'
			Axes = @{
				Operator = @('slash', 'slash_assign', 'percent', 'percent_assign', 'plus', 'plus_assign', 'increment', 'minus', 'minus_assign', 'decrement', 'multiply', 'multiply_assign', 'power', 'power_assign', 'bitwise_or', 'or_assign', 'logical_or', 'bitwise_and', 'and_assign', 'logical_and', 'bitwise_xor', 'xor_assign', 'logical_xor', 'less', 'less_equal', 'left_shift', 'left_shift_assign', 'greater', 'greater_equal', 'right_shift', 'right_shift_assign', 'arithmetic_right_shift', 'arithmetic_right_shift_assign', 'assignment', 'equality', 'logical_not', 'not_equal', 'bitwise_not', 'dot', 'scope')
				LeftOperand = @('identifier', 'integer', 'close_parenthesis', 'comma')
				RightOperand = @('identifier', 'integer', 'open_parenthesis', 'statement_end')
				Spacing = @('none', 'left', 'right', 'both')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every operator × left operand × right operand × spacing cell retains exact token kinds and byte lengths; dot-plus-number lexical merging is asserted as a float-literal path, while all other contexts preserve the operator and following operand.'
			Owner = 'Frontend/AngelscriptNativeTokenizerOperatorDepthTests.cpp|FTokenizerOperatorDepthTests|OperatorOperandSpacingCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-OPERATOR-MALFORMED-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'malformed operator prefix and recovery token'
			Axes = @{
				MalformedPrefix = @('at', 'hash', 'dollar', 'backtick', 'backslash')
				RecoveryTail = @('identifier', 'integer', 'plus', 'statement_end')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every unknown operator-like prefix consumes exactly one byte and leaves the selected identifier, numeric, operator, or punctuation recovery token observable with its exact kind and length.'
			Owner = 'Frontend/AngelscriptNativeTokenizerOperatorDepthTests.cpp|FTokenizerOperatorDepthTests|OperatorMalformedRecoveryCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-CONTEXTUAL-IDENTIFIER-WORDS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'contextual parser word identifier boundary'
			Axes = @{
				Word = @('this', 'from', 'super')
				Boundary = @('bare', 'identifier_suffix')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Words reserved by parser context rather than the raw token table remain identifier tokens and consume their bare or suffixed spelling as one token.'
			Owner = 'Frontend/AngelscriptNativeTokenizerKeywordIdentifierDepthTests.cpp|FTokenizerKeywordIdentifierDepthTests|ContextualWordsRemainIdentifierTokens'
		}
		@{
			Id = 'FRONTEND-TOKEN-NUMERIC-SIGN-TERMINATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'signed numeric token and termination recovery'
			Axes = @{
				Sign = @('positive', 'negative')
				Literal = @('decimal_zero', 'decimal_value', 'signed_32_max', 'signed_32_rollover', 'signed_64_max', 'signed_64_rollover', 'binary_zero', 'binary_value', 'octal_zero', 'octal_value', 'explicit_decimal', 'hex_zero', 'hex_value', 'float64_decimal', 'float64_leading_dot', 'float64_trailing_dot', 'exponent_positive', 'exponent_negative', 'float32_exponent', 'float32_upper_exponent')
			Termination = @('statement_terminator', 'identifier_after_whitespace', 'newline', 'closing_parenthesis')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every sign × numeric spelling × termination cell tokenizes the sign separately, preserves the exact numeric token kind and consumed length, and leaves the selected whitespace or punctuation terminator available for the next scan.'
			Owner = 'Frontend/AngelscriptNativeTokenizerNumericDepthTests.cpp|FTokenizerNumericDepthTests|NumericSignAndTerminationCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-NUMERIC-MALFORMED-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'malformed numeric prefix and recovery token'
			Axes = @{
				Sign = @('positive', 'negative')
				MalformedInput = @('binary_invalid_tail', 'octal_invalid_tail', 'hex_missing_digit', 'incomplete_exponent', 'sign_only_exponent', 'float_suffix_identifier_tail')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every sign × malformed numeric input consumes only the valid numeric prefix and exposes the exact recovery token when one remains; end-of-input malformed exponent cases are explicitly distinguished from recoverable suffix tails.'
			Owner = 'Frontend/AngelscriptNativeTokenizerNumericDepthTests.cpp|FTokenizerNumericDepthTests|NumericMalformedRecoveryCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-TEXT-COMMENT-WHITESPACE-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'string, character, comment, whitespace, and BOM token boundary'
			Axes = @{
				TextInput = @('grouped_whitespace', 'crlf_whitespace', 'line_comment_newline', 'line_comment_crlf', 'line_comment_eof', 'closed_block_comment', 'empty_block_comment', 'nested_marker_first_close', 'unterminated_block_comment', 'empty_string', 'escaped_quote', 'newline_escape', 'hex_escape', 'escaped_character', 'multiline_string_crlf', 'multiline_string', 'heredoc_string', 'heredoc_escape_text', 'escaped_backslash', 'utf8_string', 'character_literal', 'unterminated_string', 'utf8_bom')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Text and comment forms retain their distinct token kinds and exact byte ranges, including unterminated input and UTF-8 BOM handling.'
			Owner = 'Frontend/AngelscriptNativeTokenizerTextCommentWhitespaceDepthTests.cpp|FTokenizerTextCommentWhitespaceDepthTests|StringCommentAndWhitespaceBoundariesRemainDistinct'
		}
		@{
			Id = 'FRONTEND-TOKEN-TEXT-ESCAPE-LINE-ENDINGS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'delimited text escape and line-ending boundary'
			Axes = @{
				Family = @('quoted_string', 'character_literal', 'heredoc_string')
				PayloadVariant = @('short_text', 'escaped_delimiter', 'escaped_newline', 'hex_escape', 'escaped_backslash')
				Boundary = @('eof', 'lf', 'crlf', 'identifier_suffix')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Quoted, character, and heredoc literals retain exact token classes and byte spans across escape payloads and EOF/LF/CRLF/identifier boundaries; the next token remains independently observable.'
			Owner = 'Frontend/AngelscriptNativeTokenizerTextCommentWhitespaceDepthTests.cpp|FTokenizerTextCommentWhitespaceDepthTests|TextLiteralEscapeAndLineEndingCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-COMMENT-WHITESPACE-EOF'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'comment, whitespace, BOM, and EOF boundary'
			Axes = @{
				Family = @('line_comment', 'block_comment', 'whitespace')
				PayloadVariant = @('minimal', 'ascii', 'utf8', 'bom_or_space')
				Boundary = @('eof', 'lf', 'crlf', 'identifier_suffix')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Line comments consume LF/CRLF and stop at EOF or an identifier tail according to the fork; block comments stop at their closing marker; whitespace groups BOM, tabs, spaces, LF, and CRLF while exposing the following token.'
			Owner = 'Frontend/AngelscriptNativeTokenizerTextCommentWhitespaceDepthTests.cpp|FTokenizerTextCommentWhitespaceDepthTests|CommentWhitespaceAndEofCartesianProduct'
		}
		@{
			Id = 'FRONTEND-TOKEN-DEFINITIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'published token definition lookup'
			Axes = @{
				TokenKind = @('identifier', 'int_constant', 'float32_constant', 'float64_constant', 'string_constant', 'multiline_string', 'heredoc_string', 'unterminated_string', 'bits_constant', 'plus', 'scope', 'shift_right_arithmetic_assign', 'statement_block_start', 'close_bracket', 'question', 'colon', 'class', 'float64', 'return', 'unresolved_object')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic')
			Expected = 'Every selected public token kind has a non-empty diagnostic spelling through the raw tokenizer definition API.'
			Owner = 'Frontend/AngelscriptNativeTokenizerDefinitionDepthTests.cpp|FTokenizerDefinitionDepthTests|TokenDefinitionsRemainAvailableForPublishedKinds'
		}
		@{
			Id = 'FRONTEND-PARSER-DECLARATION-FAMILIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'declaration family and AST publication'
			Axes = @{
				DeclarationFamily = @('default_parameter', 'reference_directions', 'inheritance', 'namespace', 'enum', 'class_member_function', 'const_global')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Each declaration family is emitted as readable source, parsed by one class-owned raw SDK engine, and checked for its exact root node family, count, and parent/sibling links.'
			Owner = 'Frontend/AngelscriptNativeParserCartesianDepthTests.cpp|FParserCartesianDepthTests|DeclarationFamiliesRetainNodeKinds'
		}
		@{
			Id = 'FRONTEND-PARSER-EXPRESSION-STATEMENT-FAMILIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'expression and statement parser roots'
			Axes = @{
				SnippetFamily = @('arithmetic_precedence', 'nested_ternary', 'member_chain', 'if_branch', 'for_loop', 'while_loop')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Expression and statement snippets retain the expected root node and at least one expected child node across precedence, member access, branch, and loop forms.'
			Owner = 'Frontend/AngelscriptNativeParserCartesianDepthTests.cpp|FParserExpressionStatementDepthTests|ExpressionAndStatementFamiliesRetainRoots'
		}
		@{
			Id = 'FRONTEND-PARSER-FUNCTION-PARAMETER-BODY-LINE-ENDINGS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'function parameter, body, and line-ending parser publication'
			Axes = @{
				ParameterShape = @('scalar', 'default', 'reference_directions', 'multiple_default')
				BodyShape = @('literal', 'parameter_use', 'branch_return')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Every parameter-shape × body-shape × LF/CRLF cell publishes one function node and preserves parser parent/sibling links after complete generated-source logging.'
			Owner = 'Frontend/AngelscriptNativeParserCartesianDepthTests.cpp|FParserFunctionCartesianDepthTests|FunctionParameterBodyAndLineEndingCartesianProduct'
		}
		@{
			Id = 'FRONTEND-PARSER-EXPRESSION-OPERATOR-GROUPING'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'expression operator precedence and grouping parser publication'
			Axes = @{
				ExpressionShape = @('additive', 'multiplicative', 'shift_additive', 'comparison_equality', 'logical', 'bitwise', 'power', 'member_chain')
				Grouping = @('bare', 'parenthesized', 'chained')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Every expression-shape × grouping cell publishes an expression root with the expected operator-node depth, including current-fork power, bitwise, comparison, logical, and member-chain forms.'
			Owner = 'Frontend/AngelscriptNativeParserCartesianDepthTests.cpp|FParserExpressionGroupingDepthTests|ExpressionOperatorGroupingCartesianProduct'
		}
		@{
			Id = 'FRONTEND-PARSER-SEMANTIC-EXPRESSION-PLACEMENT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'semantic expression node and legal placement publication'
			Axes = @{
				ExpressionShape = @('cast', 'index', 'named_argument', 'initializer_list', 'anonymous_function')
				Placement = @('bare', 'parenthesized', 'call_argument')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every semantic expression-shape × legal-placement cell publishes an expression root, retains the shape-specific owning AST node, preserves the outer function-call node when nested as an argument, and keeps parent/sibling links valid after complete source logging.'
			Owner = 'Frontend/AngelscriptNativeParserCartesianDepthTests.cpp|FParserSemanticExpressionDepthTests|SemanticExpressionShapesByPlacement'
		}
		@{
			Id = 'FRONTEND-NODE-DEEP-NESTING-COPY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'deep script-node nesting and copy ownership'
			Axes = @{
				NodeShape = @('if', 'while', 'namespace')
				Depth = @('1', '2', '4', '8')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Every node-shape × depth cell publishes the exact nested node count, retains deep source structure, and preserves links, histogram, and maximum depth through asCScriptNode::CreateCopy.'
			Owner = 'Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp|FParserNodeNestingDepthTests|NodeDeepNestingAndCopyCartesianProduct'
		}
		@{
			Id = 'FRONTEND-SCRIPT-CODE-ROW-COLUMN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'script-code line and column conversion'
			Axes = @{
				LineEnding = @('lf', 'crlf')
				Position = @('line1_start', 'line1_end', 'line2_start', 'line2_middle', 'line3_end', 'eof')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata')
			Expected = 'Every LF/CRLF × start/middle/end/EOF position maps to the exact current-fork one-based row and column, including the EOF row sentinel.'
			Owner = 'Frontend/AngelscriptNativeScriptCodePositionTests.cpp|FParserScriptCodePositionTests|ScriptCodeRowColumnCartesianProduct'
		}
		@{
			Id = 'FRONTEND-NODE-TRAVERSAL-COPY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'AST traversal links and deep copy structure'
			Axes = @{
				SourceShape = @('globals', 'control_flow', 'class_member', 'enum_namespace')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup')
			Expected = 'Each source shape preserves parent, previous/next, top-level sibling, histogram, and maximum-depth invariants through asCScriptNode::CreateCopy.'
			Owner = 'Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp|FParserNodeTraversalDepthTests|NodeTraversalAndCopyPreserveStructure'
		}
		@{
			Id = 'FRONTEND-SOURCE-POSITIONS-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'line-sensitive source ranges and parser recovery'
			Axes = @{
				Path = @('crlf_multiline_comment', 'invalid_then_reset')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Diagnostic', 'Cleanup')
			Expected = 'CRLF, comment, multiline, and parser-reset inputs preserve row/column/range evidence, and an invalid script does not poison a valid script parsed after Reset.'
			Owner = 'Frontend/AngelscriptNativeParserSourceRecoveryTests.cpp|FParserSourceRecoveryDepthTests|SourcePositionsAndParserRecoveryRemainStable'
		}
		@{
			Id = 'COMPILER-BUILDER-SHAPE-FAILURE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder source shape, stage, and failure publication'
			Axes = @{
				Shape = @('basic_function', 'namespace_call', 'const_global', 'class_property_method')
				Failure = @('none', 'malformed_signature', 'unknown_type', 'unclosed_shape_scope')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Runtime', 'Cleanup')
			Expected = 'Each builder shape traverses parse, type, function, class, global, function-layout, and code stages. Every failure source embeds the selected basic-function, namespace-call, const-global, or class-property/method shape rather than repeating one generic invalid source. Valid shapes publish Entry and run; the class shape additionally proves layout metadata because local reference-class value construction is a recorded fork limitation. Invalid shapes fail at their exact owning stage, retain the exact section/row/symbol diagnostic, publish no executable bytecode, discard the exact module, leave name lookup empty, and preserve independent native storage.'
			Owner = 'Compiler/AngelscriptNativeCompilerCartesianDepthTests.cpp|FCompilerBuilderCartesianDepthTests|BuilderStagesPublishOrRejectAcrossShapeAndFailureInputs'
		}
		@{
			Id = 'COMPILER-BUILDER-REBUILD-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder invalid publication and same/fresh-engine recovery'
			Axes = @{
				Shape = @('literal', 'namespace')
				Failure = @('syntax', 'missing_type', 'missing_brace')
				RecoveryRoute = @('same_engine', 'fresh_engine')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Every invalid builder shape/failure route fails at its exact owning stage, retains the exact section/row/symbol diagnostic, publishes no executable bytecode, and is explicitly discarded with null name lookup before the same module name is rebuilt through either the same engine or a fresh engine; the valid recovery publishes Entry, returns 42, and is independently discarded.'
			Owner = 'Compiler/AngelscriptNativeCompilerCartesianDepthTests.cpp|FCompilerBuilderRecoveryDepthTests|InvalidBuildsRecoverAcrossShapeAndEngineRoute'
		}
		@{
			Id = 'COMPILER-BYTECODE-SHAPE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'compiled bytecode control shapes and class-layout publication'
			Axes = @{
				Shape = @('arithmetic_call', 'conditional_branch', 'loop', 'object_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Cleanup')
			Expected = 'Arithmetic-call, conditional-branch, and loop shapes publish exact bytecode, emit their representative opcode family, and return independently expected runtime values. The object-method source publishes class/method layout metadata while a separate constant Entry supplies safe runtime and non-empty bytecode evidence; local reference-class value construction and method invocation remain an explicit current-fork limitation rather than being claimed by this product. Every shape explicitly discards its exact module and leaves name lookup empty before the next cell.'
			Owner = 'Compiler/AngelscriptNativeCompilerBytecodeShapeDepthTests.cpp|FCompilerBytecodeShapeDepthTests|ControlFlowArithmeticAndClassLayoutShapesKeepRuntimeAndOpcodeEvidence'
		}
		@{
			Id = 'COMPILER-BYTECODE-MUTATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'instruction sequence mutation and serialized invariants'
			Axes = @{
				InitialInstructionCount = @('zero', 'one', 'two', 'three')
				Mutation = @('plain', 'jump_resolve', 'remove_last', 'optimize')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Bytecode', 'Metadata', 'Cleanup')
			Expected = 'Insertion, jump resolution, removal, and optimization preserve linked traversal, head/tail ownership, and serialized size invariants for every selected initial sequence length.'
			Owner = 'Compiler/AngelscriptNativeCompilerBytecodeMutationDepthTests.cpp|FCompilerBytecodeMutationDepthTests|InstructionInsertionRemovalAndJumpResolutionPreserveLinks'
		}
		@{
			Id = 'COMPILER-BYTECODE-OPTIMIZATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'optimization mode and debug metadata parity'
			Axes = @{
				Optimization = @('off', 'on')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Bytecode', 'Debug', 'Cleanup')
			Expected = 'Optimization off and on both publish executable bytecode, preserve section/debug metadata, retain the branch opcode family, return the same value, explicitly discard their exact module with null name lookup, and restore the engine optimization property.'
			Owner = 'Compiler/AngelscriptNativeCompilerOptimizationDepthTests.cpp|FCompilerOptimizationDepthTests|OptimizationModesPreserveRuntimeSectionAndLocals'
		}
		@{
			Id = 'COMPILER-BYTECODE-REFERENCE-COPY-EXACT-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'compiled counted-reference copy and null-release optimizer forms'
			Axes = @{
				Shape = @('reference_copy', 'null_free')
				Optimization = @('off', 'on')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'For both optimization modes, generated counted-reference scripts print before compilation, execute with exact values and balanced native ownership, and expose their actual Entry bytecode. Raw reference assignment retains PSF plus typed REFCPY, optimized assignment retains typed RefCpyV, and optimized null assignment consumes its copy window into typed FREE; every observed typed opcode carries the registered FNativeCaseReference TypeInfo pointer and its exact destination offset. Hand-built linked-bytecode fixtures prove only the local structural rewrite and are never substituted for compiled production evidence.'
			Owner = 'Compiler/AngelscriptNativeBytecodeOptimizationTests.cpp|FBytecodeOptimizationTests|ReferenceCopyCollapsesToTypedVariableCopyWithEqualStackEffect'
		}
		@{
			Id = 'COMPILER-BYTECODE-OPCODE-DESCRIPTORS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'published opcode descriptor table'
			Axes = @{
				OpcodeTable = @('published')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Bytecode', 'Diagnostic', 'Isolation')
			Expected = 'Every opcode from zero through asBC_MAXBYTECODE has an index-matching descriptor, a non-empty name, a concrete encoding, and a positive serialized DWORD size; the review source prints index, name, encoding, size, and stack delta for the complete table.'
			Owner = 'Compiler/AngelscriptNativeBytecodeOpcodeTests.cpp|FBytecodeOpcodeTests|PublishedOpcodesExposeCompleteDescriptors'
		}
		@{
			Id = 'RT-CTX-ARGUMENT-SCALAR-SLOTS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context scalar argument slots and state transitions'
			Axes = @{
				Slot = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'bool')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every scalar slot uses the exact width accessor, exposes a non-null address, and contributes its independent value to the complete sum before cleanup. The current fork performs no argument-index bounds check, so unsafe out-of-range SetArg/GetAddress calls are recorded as an API limitation rather than executed.'
			Owner = 'Runtime/AngelscriptNativeContextAccessorDepthTests.cpp|FNativeContextAccessorDepthTests|ScalarArgumentSlotsAndExactOverloads'
		}
		@{
			Id = 'RT-CTX-STATE-TRANSITIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context externally observable state transitions'
			Axes = @{
				StatePoint = @('uninitialized_before_prepare', 'prepared', 'finished', 'uninitialized_after_unprepare')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The same context exposes the exact public state before prepare, after prepare, after execution, and after unprepare. Executing is not claimed because this owner does not query state from inside an active callback.'
			Owner = 'Runtime/AngelscriptNativeContextAccessorDepthTests.cpp|FNativeContextAccessorDepthTests|ScalarArgumentSlotsAndExactOverloads'
		}
		@{
			Id = 'RT-CTX-OVERLOAD-EXACT-INVOCATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context exact overload and float ABI invocation'
			Axes = @{
				Invocation = @('integer_overload', 'configured_floating_overload', 'configured_floating_return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'Exact declarations select the intended integer and configured floating functions, and floating argument/return accessors follow the one ABI selected by the current engine property. The inactive ABI is not claimed as an executed cell.'
			Owner = 'Runtime/AngelscriptNativeContextAccessorDepthTests.cpp|FNativeContextAccessorDepthTests|ScalarArgumentSlotsAndExactOverloads'
		}
		@{
			Id = 'RT-CTX-POOL-FALLBACK-LIFETIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context fallback request return and public reference lifetime'
			Axes = @{
				Operation = @(
					'request'
					'addref'
					'balanced_release'
					'final_return_cleanup'
					'null_return'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Without callbacks, RequestContext creates an uninitialized context owned by the exact engine; AddRef and Release expose a balanced second reference; ReturnContext consumes the final reference and invokes cleanup exactly once; a null return is ignored safely without another cleanup.'
			Owner = 'Runtime/AngelscriptNativeContextPublicApiDepthTests.cpp|FNativeContextPublicApiDepthTests|FallbackRequestReturnAndBalancedReferenceLifetime'
		}
		@{
			Id = 'RT-CTX-POOL-CALLBACK-ROUTING'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context request return callback pairing routing and clear'
			Axes = @{
				CallbackState = @(
					'paired_install'
					'request_only_rejected_preserves_pair'
					'return_only_rejected_preserves_pair'
					'cleared_fallback'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A paired callback configuration routes exact engine, parameter, and context identities; request-only and return-only updates return asINVALID_ARG without replacing the pair; clearing both callbacks restores fallback creation and release before fixture teardown.'
			Owner = 'Runtime/AngelscriptNativeContextPublicApiDepthTests.cpp|FNativeContextPublicApiDepthTests|CallbackPairValidationRoutingAndClear'
		}
		@{
			Id = 'RT-CTX-METHOD-OBJECT-REFERENCE-RETURN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'prepared method receiver and reference return address'
			Axes = @{
				Observation = @(
					'receiver_constructor'
					'receiver_set_for_reference'
					'pre_execute_null'
					'post_execute_reference_identity'
					'reference_mutation_visible'
					'primitive_return_null'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A constructed script receiver is installed only after preparing exact instance methods; GetReturnAddress is null before execution, equals the referenced property after the reference-returning method finishes, exposes a mutation visible to a second invocation, and remains null for a primitive return. Context, object, and module ownership are released in order.'
			Owner = 'Runtime/AngelscriptNativeContextPublicApiDepthTests.cpp|FNativeContextPublicApiDepthTests|PreparedMethodReceiverAndReferenceReturnAddress'
		}
		@{
			Id = 'RT-CTX-VARTYPE-ARGUMENT-METADATA'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'variable-type context argument metadata and state validation'
			Axes = @{
				Scenario = @(
					'unprepared_rejection'
					'one_past_index_rejection'
					'ordinary_parameter_rejection'
					'int32'
					'float64'
					'bool'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'SetArgVarType returns exact unprepared, invalid-index, and invalid-parameter results with their exact context states; int32, double-backed float64, and bool wildcard calls expose exact type IDs and pointer identities to one generic callback, return type-specific values, recover through Unprepare, and retain case isolation.'
			Owner = 'Runtime/AngelscriptNativeContextPublicApiDepthTests.cpp|FNativeContextPublicApiDepthTests|VariableTypeMetadataByTypeAndInvalidState'
		}
		@{
			Id = 'RT-CTX-CONTROL-FLOW-EXECUTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context execution across loop boundary inputs'
			Axes = @{
				Input = @('zero', 'one', 'ten')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'A case-owned context executes the exact Compute declaration for the zero-iteration, one-iteration, and ten-iteration loop boundaries; every result participates in the entry oracle before module and engine cleanup.'
			Owner = 'Runtime/AngelscriptNativeContextControlTests.cpp|FContextControlTests|ContextControlContext'
		}
		@{
			Id = 'RT-CTX-ARITHMETIC-EXCEPTION-DETAILS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'arithmetic exception operation and call placement'
			Axes = @{
				Operation = @('divide', 'modulo')
				Placement = @('direct', 'nested')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Division and modulo by zero each raise asEXECUTION_EXCEPTION from direct and nested placements, retain the exact current-fork exception text, publish a positive line, and identify Entry or Fault as the exact failing frame.'
			Owner = 'Runtime/AngelscriptNativeContextControlTests.cpp|FContextControlTests|ExceptionDetails'
		}
		@{
			Id = 'RT-CTX-SUSPEND-FORK-REJECTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'current-fork active-context suspension rejection'
			Axes = @{
				Observation = @('callback_result', 'execution_state', 'return_value')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The active native callback receives the exact asERROR suspension rejection, execution continues to asEXECUTION_FINISHED, and the scripted return remains 42 without leaking the context or registration.'
			Owner = 'Runtime/AngelscriptNativeContextControlTests.cpp|FContextControlTests|SuspendAndResumePreserveContextState'
		}
		@{
			Id = 'RT-CTX-EXCEPTION-RECOVERY-SIGNATURE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'same-context exception recovery and successor signature'
			Axes = @{
				Scenario = @('shallow_same_arity', 'deep_one_argument', 'zero_to_one_argument')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'One context recovers after shallow and deep exceptions, accepts the selected same-arity or changed-arity successor, clears the failed execution through Prepare, executes every successor, and returns the exact post-recovery value.'
			Owner = 'Runtime/AngelscriptNativeContextControlTests.cpp|FContextControlTests|ContextReuseAfterException'
		}
		@{
			Id = 'RT-CTX-STACK-OVERFLOW-METADATA'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'stack-overflow exception metadata'
			Axes = @{
				Observation = @('reason', 'function', 'line')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Bounded-stack recursion raises asEXECUTION_EXCEPTION and exposes the exact Stack overflow reason, recursive function identity, and a positive source location before context and engine cleanup.'
			Owner = 'Runtime/AngelscriptNativeContextExceptionTests.cpp|FContextExceptionTests|ExceptionLocation'
		}
		@{
			Id = 'RT-CTX-INVOCATION-ARITY-RETURN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context invocation parameter count and return shape'
			Axes = @{
				Arity = @('zero', 'one', 'two', 'three')
				ReturnShape = @('void', 'int')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every zero-through-three-argument void and integer function publishes the exact normalized parameter count, accepts every selected argument slot, executes to completion, records the full argument sum, returns it for integer signatures, and unprepares cleanly.'
			Owner = 'Runtime/AngelscriptNativeContextInvocationTests.cpp|FContextInvocationTests|InvocationByArityAndReturnShape'
		}
		@{
			Id = 'RT-CTX-RETURN-ABI-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context configured floating and signed integer return ABI'
			Axes = @{
				Shape = @('configured_float', 'signed_integer')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The active float ABI uses its matching declaration and return accessor to preserve 42.5, while signed DWORD argument and return slots preserve -42 without unsigned reinterpretation in the oracle.'
			Owner = 'Runtime/AngelscriptNativeContextReturnValueTests.cpp|FContextReturnValueTests|ContextReturnValueFloatReturn'
		}
		@{
			Id = 'RT-CTX-RETURN-CONTROL-PATHS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'context return control-flow path'
			Axes = @{
				Path = @('positive', 'fallback')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Independent contexts prepare the same exact declaration, execute both the positive early-return and fallback paths, and expose their distinct 40 and 2 return values before cleanup.'
			Owner = 'Runtime/AngelscriptNativeContextReturnValueTests.cpp|FContextReturnValueTests|MultipleReturnPaths'
		}
		@{
			Id = 'RT-GC-EMPTY-SERVICE-CONTRACTS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'empty garbage-collector service contract'
			Axes = @{
				Operation = @('statistics', 'full_collect', 'invalid_lookup', 'undestroyed_report')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'A fresh collector reports all counters as zero, completes an empty full cycle, rejects an out-of-range lookup while zeroing every output, and reports zero undestroyed objects under case-owned engine cleanup.'
			Owner = 'Runtime/AngelscriptNativeGarbageCollectorTests.cpp|FGarbageCollectorTests|GarbageCollectorStatistics'
		}
		@{
			Id = 'RT-GC-CYCLE-TOPOLOGY-PHASES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'garbage-collector cycle topology and collection phase'
			Axes = @{
				Topology = @('self', 'two_node')
				Phase = @('detect', 'destroy')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Self and two-node reference cycles are notified to the raw SDK collector, remain tracked through detect-only collection, increase detected statistics, then release every object during full collection with exact live-count and tracking deltas.'
			Owner = 'Runtime/AngelscriptNativeGarbageCollectorTests.cpp|FGarbageCollectorTests|ManualCycleCollection'
		}
		@{
			Id = 'DBG-NEST-STATE-DEPTH'
			SourceCatalog = 'native-debug.md'
			Theme = 'Runtime.Debug'
			Element = 'nested context state depth signature and action'
			Axes = @{
				Depth = @('one', 'two', 'three', 'five')
				Signature = @('same_signature', 'different_signature')
				Action = @('success', 'exception', 'suspend_request', 'abort_request')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Debug', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'PushState, PopState, and IsNested preserve the active caller, exact saved-state count, selected same/different signature, inner exception consumption, and current-fork rejected suspend/abort requests across nested depths.'
			Owner = 'Runtime/Debug/AngelscriptNativeNestedContextDepthTests.cpp|FNativeNestedContextDepthTests|NestedStateByDepthSignatureAndAction'
		}
		@{
			Id = 'RT-OBJ-CONSTRUCT-COPY-ASSIGN-PROPERTY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'script object construction copy assignment and property ownership'
			Axes = @{
				Operation = @('default_construct', 'copy_construct', 'uninitialized_assign', 'copy_from', 'property_query')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Raw script-object construction, copy construction, assignment, CopyFrom, and property queries retain the exact observed values and release every owned object.'
			Owner = 'Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp|FNativeScriptObjectLifecycleDepthTests|ConstructCopyAssignPropertyAndReferenceOwnership'
		}
		@{
			Id = 'RT-OBJ-REFCOUNT-WEAKFLAG-FORK'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'script object reference count and weak-reference fork boundary'
			Axes = @{
				Contract = @('balanced_addref_release_pair', 'null_weak_flag_fork_boundary')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup')
			Expected = 'Explicit add/ref release remains balanced, and the current fork reports no registered weak-reference flag for script objects as a visible boundary.'
			Owner = 'Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp|FNativeScriptObjectLifecycleDepthTests|ConstructCopyAssignPropertyAndReferenceOwnership'
		}
		@{
			Id = 'DBG-INSTRUCTION-PHASE-FAMILY'
			SourceCatalog = 'native-debug.md'
			Theme = 'Runtime.Debug'
			Element = 'instruction callback phase, opcode, callstack, and clear lifecycle'
			Axes = @{
				Scenario = @('loop_branch_and_phase_pairing', 'nested_call_and_phase_pairing', 'callback_clear_lifecycle')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Debug', 'Bytecode', 'Cleanup')
			Expected = 'The loop owner and nested callee each expose independently paired before/after instruction callbacks with non-negative offsets and opcode text; the separate clear lifecycle proves that a later invocation emits no events. Observation fields are assertions within each scenario, not additional Cartesian axes.'
			Owner = 'Runtime/Debug/AngelscriptNativeInstructionPhaseDepthTests.cpp|FNativeInstructionPhaseDepthTests|InstructionPhaseOpcodeAndCallbackClear'
		}
		@{
			Id = 'DBG-LINE-CALLBACK-SOURCE-PATH'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'line callback source-path and lifecycle depth'
			Axes = @{
				Layout = @('lf', 'crlf')
				Path = @('straight', 'branch_true', 'branch_false', 'loop_zero', 'loop_two')
				State = @('absent', 'installed', 'replaced', 'cleared')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'Each LF/CRLF source path returns its independent result and, when the line callback is active, records the selected executable marker line while excluding the untaken branch or zero-iteration body. Callback absence, replacement, and clear-before-execution retain safe no-event behavior with exact source section/function/line/column evidence and reusable context cleanup.'
			Owner = 'Runtime/Debug/AngelscriptNativeLineCallbackSourceTests.cpp|FNativeLineCallbackSourceTests|PathsByLayoutAndCallbackState'
		}
		@{
			Id = 'DBG-STACK-POP-EXIT'
			SourceCatalog = 'native-debug.md'
			Theme = 'NativeDebug'
			Element = 'stack-pop callback exit and depth lifecycle'
			Axes = @{
				Depth = @('one', 'nested', 'recursive')
				Exit = @('normal', 'early_return', 'exception', 'recovery')
				State = @('installed', 'cleared')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Debug', 'Cleanup', 'Isolation')
			Expected = 'Installed stack-pop callbacks expose non-empty old-frame ranges across normal, early-return, exception, and same-context recovery paths at every selected depth; cleared callbacks emit no events. Exception paths retain the expected execution result and context unprepare/reuse, and every cell cleans callback, user data, context, and module state.'
			Owner = 'Runtime/Debug/AngelscriptNativeStackPopCallbackDepthTests.cpp|FNativeStackPopCallbackDepthTests|ExitsByDepthAndCallbackState'
		}
		@{
			Id = 'TYPE-DATATYPE-QUALIFIER-CARTESIAN'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'primitive data type qualifier semantics'
			Axes = @{
				Type = @('int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64', 'bool')
				Qualifier = @('mutable', 'const', 'reference', 'const_reference')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every primitive type and qualifier combination retains token/category flags, const/reference state, canonical format, independent size/alignment, equality relations, execution, and module cleanup.'
			Owner = 'TypeSystem/AngelscriptNativeDataTypeQualifierCartesianTests.cpp|FDataTypeQualifierCartesianTests|PrimitiveTypesByQualifier'
		}
		@{
			Id = 'X-SEMANTIC-CHAIN'
			SourceCatalog = 'cross-theme-interactions.md'
			Theme = 'CrossTheme'
			Element = 'multi-theme semantic chain'
			Axes = @{
				Chain = @('fn_conv', 'fn_ref', 'fn_ctor', 'ctor_prop', 'ctor_exception', 'inheritance_dispatch', 'operator_conversion', 'operator_control', 'variable_control', 'foreach_exception', 'namespace_module', 'metadata_bytecode', 'exception_debug', 'nested_debug', 'optimization_debug', 'gc_module')
				Path = @('normal', 'boundary', 'negative', 'exception')
				Lifecycle = @('initial', 'rebuild', 'save_load', 'discard_cleanup')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Debug', 'Cleanup')
			Expected = 'The chain records intermediate and final observations at every owner boundary and preserves cleanup under normal and failing paths.'
			Owner = 'Language/Interactions/AngelscriptNativeSemanticInteractionTests.cpp|FSemanticInteractionTests|ChainsByPathAndLifecycle'
		}
		@{
			Id = 'CONF-RECURSION-DATA-STACK-LIMIT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Conformance'
			Element = 'configured recursion data-stack limit and context recovery'
			Axes = @{
				Observation = @('property_install', 'property_readback', 'overflow_result', 'overflow_text', 'exception_function', 'callstack', 'same_context_recovery')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A raw recursive function under equal initial and maximum data-stack limits reports the exact Stack overflow exception with function/callstack metadata, then the same context unprepares and executes a non-recursive recovery call.'
			Owner = 'Conformance/AngelscriptNativeGlobalSemanticsTests.cpp|FGlobalSemanticsTests|GlobalSemanticsDataLimit'
		}
		@{
			Id = 'CONF-CALL-LIMIT-PROPERTIES-STORAGE-ONLY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Conformance'
			Element = 'current-fork call-limit property storage without enforcement'
			Axes = @{
				Scenario = @('initial_call_stack_set', 'maximum_call_stack_set', 'maximum_nested_calls_set', 'initial_readback', 'maximum_readback', 'nested_readback', 'depth_four_finishes')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The three call-limit properties accept and return value one, while depth-four ordinary script recursion still finishes because the current fork stores but does not consume these properties in the context execution path.'
			Owner = 'Conformance/AngelscriptNativeGlobalSemanticsTests.cpp|FGlobalSemanticsTests|GlobalSemanticsCallLimit'
		}
		@{
			Id = 'CONF-APPLICATION-INTERFACE-REGISTRATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Conformance'
			Element = 'raw application interface registration metadata and engine isolation'
			Axes = @{
				Observation = @('type_id', 'declaration', 'typeinfo_identity', 'flags', 'zero_size', 'method_count', 'method_declaration', 'method_id', 'function_kind', 'method_owner', 'control_engine_absence')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'A registered application interface and method publish exact type/function IDs, declaration, flags, zero instantiable size, interface function kind, owning TypeInfo, and remain absent from an independent raw engine. This fork exposes no per-interface unregister or safe post-engine-release receiver, so the product does not claim an independently observable lifecycle or cleanup layer.'
			Owner = 'Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp|FInterfaceSemanticsTests|InterfaceSemanticsInterfaceBridge'
		}
		@{
			Id = 'V238-DESIRED-BEHAVIOR'
			SourceCatalog = 'coverage-contract.md'
			Theme = 'Future238'
			Element = 'selected 2.38 desired behavior'
			Axes = @{
				Feature = @('using_namespace', 'member_initialization', 'default_special_members', 'bool_context', 'lambda', 'variadic_function', 'function_template', 'try_catch_rethrow', 'script_property_accessors', 'indexed_setter_ambiguity', 'abstract_class_modifier', 'final_class_modifier', 'null_handle_syntax')
				Layer = @('parse', 'compile', 'metadata', 'runtime', 'cleanup')
			}
			Classification = 'Future238Disabled'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Cleanup')
			Expected = 'The compiled Disabled case contains the desired 2.38 assertion and #as-v238-backport tag without changing current-fork active semantics.'
			Owner = 'Conformance/AngelscriptNativeSelected238DesiredBehaviorTests.cpp|FSelected238DesiredBehaviorTests|FeaturesByEvidenceLayer'
		}
		@{
			Id = 'LANG-CF-LOOP-DEPTH'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'loop kind iteration and transfer counters'
			Axes = @{
				LoopKind = @('while', 'do_while', 'for')
				Count = @('zero', 'one', 'two', 'many')
				Transfer = @('none', 'break', 'continue', 'return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode', 'Cleanup')
			Expected = 'Every loop kind and iteration count preserves exact condition/body/increment counts for no transfer, break, continue, and early return; each generated function publishes executable bytecode and its module is discarded cleanly.'
			Owner = 'Language/ControlFlow/AngelscriptNativeLoopDepthTests.cpp|FLoopDepthTests|LoopsByKindCountAndTransfer'
		}
		@{
			Id = 'LANG-CF-LOOP-COND-TRANSFER-DEPTH'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'loop condition shape and transfer depth'
			Axes = @{
				LoopKind = @('while', 'do_while', 'for')
				Condition = @('variable', 'comparison', 'logical', 'negated', 'side_effect')
				Count = @('zero', 'one', 'two')
				Transfer = @('none', 'break', 'continue', 'return')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Every loop form crosses variable/comparison/logical/negated/side-effect condition shapes, zero/one/two iterations, and none/break/continue/return transfers. Generated sources retain independent body and condition-call results, legal early exits, explicit context release, module absence, and detached per-cell native counter state. All cells are valid programs, so this product does not claim a diagnostic layer.'
			Owner = 'Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp|FLoopConditionTransferDepthTests|LoopsByConditionCountAndTransfer'
		}
		@{
			Id = 'LANG-CF-BRANCH-CONDITION-DEPTH'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'branch condition and selection depth'
			Axes = @{
				BranchKind = @('if', 'if_else', 'else_if_chain')
				Condition = @('variable', 'comparison', 'logical', 'negated', 'side_effect')
				Selection = @('first', 'second', 'none')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every if/if-else/else-if branch form crosses variable, comparison, logical, negated, and side-effect conditions with first/second/no-match selections and LF/CRLF source layouts. Exact branch markers and independent native condition-call counts prove eager selection behavior, skipped arms, source-line preservation, context cleanup, and module isolation.'
			Owner = 'Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp|FBranchConditionDepthTests|BranchesByConditionSelectionAndLineEnding'
		}
		@{
			Id = 'LANG-CF-LIVE-LOCAL-CLEANUP'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'live local cleanup across nested control exits'
			Axes = @{
				ScopeShape = @('loop', 'branch_loop', 'nested_loop', 'switch_loop')
				Exit = @('normal', 'break', 'continue', 'return', 'exception')
				Depth = @('one', 'two', 'three')
				LocalCount = @('one', 'two')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every generated scope constructs the requested local count at each nesting depth and proves exact once-only destruction, reverse lifetime order, zero live objects, transfer behavior, exception cleanup, same-context recovery, and module isolation across both source layouts.'
			Owner = 'Language/ControlFlow/AngelscriptNativeControlFlowLifetimeDepthTests.cpp|FControlFlowLifetimeDepthTests|LocalsByScopeExitDepthAndLayout'
		}
		@{
			Id = 'LANG-CF-FOR-CLAUSES'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'for clause presence and bounded iteration'
			Axes = @{
				Init = @('present', 'omitted')
				Condition = @('present', 'omitted')
				Increment = @('present', 'omitted')
				Count = @('zero', 'one', 'many')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode', 'Cleanup')
			Expected = 'Every legal initialization/condition/increment presence combination runs bounded zero/one/many limits; omitted conditions use an explicit source-level break and the result records initialization, condition, and increment event counts.'
			Owner = 'Language/ControlFlow/AngelscriptNativeForClauseTests.cpp|FForClauseTests|ClausesByPresenceAndCount'
		}
		@{
			Id = 'LANG-CF-NESTED-TARGETS'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'nested transfer target level'
			Axes = @{
				Nesting = @('nested_loop', 'branch_loop', 'three_level')
				Transfer = @('break', 'continue', 'return')
				Target = @('inner', 'outer')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Bytecode', 'Cleanup')
			Expected = 'Nested loop, branch-wrapped loop, and three-level loop sources distinguish break/continue/return at the inner or outer target level with exact trace and module cleanup.'
			Owner = 'Language/ControlFlow/AngelscriptNativeNestedTargetTests.cpp|FNestedTargetTests|TransfersByNestingAndTarget'
		}
		@{
			Id = 'LANG-CF-TRANSFER-VALIDITY'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'transfer owning placement legality'
			Axes = @{
				Placement = @('function', 'branch', 'switch', 'loop')
				Transfer = @('break', 'continue')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Cleanup')
			Expected = 'Break and continue are rejected outside an owning construct, break is accepted by switch, and both transfers execute with the expected loop target when emitted inside a loop; every source retains diagnostics or runtime and module-cleanup evidence.'
			Owner = 'Language/ControlFlow/AngelscriptNativeTransferValidityTests.cpp|FTransferValidityTests|TransfersByOwningPlacementAndKind'
		}
		@{
			Id = 'LANG-CF-SWITCH-PLACEMENT'
			SourceCatalog = 'control-flow.md'
			Theme = 'ControlFlow'
			Element = 'switch case/default placement and ordering legality'
			Axes = @{
				Placement = @('function', 'branch', 'loop', 'after_switch')
				Form = @('case_outside', 'default_outside', 'duplicate_default', 'case_after_default')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup')
			Expected = 'Every owning placement emits case/default labels outside a switch, duplicate default labels, or a case after default; each of the sixteen current-fork-invalid sources retains a diagnostic, publishes no executable entry, and cleans up its module.'
			Owner = 'Language/ControlFlow/AngelscriptNativeSwitchPlacementTests.cpp|FSwitchPlacementTests|InvalidCaseAndDefaultFormsByOwningPlacement'
		}
		@{
			Id = 'ENG-MESSAGE-CALLBACK-CARTESIAN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw engine message callback severity, source coordinates, and payload forms'
			Axes = @{
				Severity = @('information', 'warning', 'error')
				Location = @('zero_offset', 'first_line', 'middle_line', 'large_offset')
				Payload = @('plain', 'empty', 'punctuation')
			}
			Classification = 'CurrentFork'
			Evidence = @('Diagnostic', 'Metadata', 'Lifecycle')
			Expected = 'Every severity, coordinate/section, and payload combination preserves the exact raw WriteMessage return, callback count, section, row, column, type, and text in the installed native collector.'
			Owner = 'Engine/AngelscriptNativeEngineMessageCallbackTests.cpp|FEngineMessageCallbackTests|MessagesBySeverityLocationAndPayloadCartesianProduct'
		}
		@{
			Id = 'ENG-MESSAGE-CALLBACK-FAMILIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw engine message callback severity and source coordinates'
			Axes = @{
				Severity = @('information', 'warning', 'error')
				Location = @('one-based', 'offset')
				Payload = @('section', 'row', 'column', 'text')
			}
			Classification = 'CurrentFork'
			Evidence = @('Diagnostic', 'Metadata', 'Lifecycle')
			Expected = 'Every raw WriteMessage severity preserves the exact section, row, column, and message text in the installed native callback collector.'
			Owner = 'Engine/AngelscriptNativeEngineMessageCallbackTests.cpp|FEngineMessageCallbackTests|MessagesBySeverityLocationAndText'
		}
		@{
			Id = 'ENG-MESSAGE-CALLBACK-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'raw engine message callback replacement clear and restore lifecycle'
			Axes = @{
				State = @('installed', 'replaced', 'cleared', 'restored')
				Receiver = @('native_collector', 'buffered_stream')
				Observation = @('get_callback', 'write', 'no_delivery_after_clear', 'write_after_restore')
			}
			Classification = 'CurrentFork'
			Evidence = @('Diagnostic', 'Metadata', 'Lifecycle', 'Isolation')
			Expected = 'The callback can be read, replaced, cleared, and restored; each receiver observes only the messages delivered during its owned state and WriteMessage remains safe after clear.'
			Owner = 'Engine/AngelscriptNativeEngineMessageCallbackTests.cpp|FEngineMessageCallbackTests|CallbackReplacementClearAndRestore'
		}
		@{
			Id = 'FRONTEND-TOKENIZER-INTERNAL-HELPERS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'tokenizer protected helper dispatch'
			Axes = @{
				Helper = @('whitespace', 'line_comment', 'integer_constant', 'identifier', 'keyword', 'dispatch')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'Each tokenizer helper family directly classifies its input, token kind, token class, and consumed span through the raw asCTokenizer implementation.'
			Owner = 'Frontend/AngelscriptNativeTokenizerInternalTests.cpp|FTokenizerInternalTests|ProtectedHelpersByInputFamily'
		}
		@{
			Id = 'FRONTEND-TOKENIZER-RADIX-HELPER'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'tokenizer radix digit helper'
			Axes = @{
				Character = @('zero', 'seven', 'eight', 'nine', 'upper_a', 'upper_f', 'lower_a', 'lower_f', 'upper_g', 'lower_g', 'minus', 'space')
				Radix = @('2', '8', '10', '16')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'Every character/radix pair agrees with the independent numeric-value oracle, including upper/lower hexadecimal forms and invalid separators.'
			Owner = 'Frontend/AngelscriptNativeTokenizerInternalTests.cpp|FTokenizerInternalTests|RadixDigitHelperByCharacterAndRadix'
		}
		@{
			Id = 'FRONTEND-PARSER-INTERNAL-PREDICATES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'parser protected token predicates'
			Axes = @{
				Predicate = @('real_type', 'data_type', 'constant', 'operator', 'pre_operator', 'post_operator', 'assign_operator')
				TokenKind = @('void', 'int', 'float64', 'identifier', 'int_constant', 'string_constant', 'plus', 'minus', 'inc', 'dec', 'assign', 'add_assign', 'statement_end', 'open_parenthesis')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'Every parser predicate/token pair matches an independent token-family oracle, directly exercising protected asCParser classification helpers rather than inferring them from builder output.'
			Owner = 'Frontend/AngelscriptNativeParserInternalTests.cpp|FParserInternalTests|TokenPredicatesByPredicateAndToken'
		}
		@{
			Id = 'FRONTEND-PARSER-INTERNAL-IDENTIFIER'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'parser identifier spelling predicate'
			Axes = @{
				Candidate = @('exact_identifier', 'suffixed_identifier', 'keyword_token')
				Probe = @('same', 'different')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Isolation')
			Expected = 'IdentifierIs honors exact source spelling and rejects keyword tokens or different suffix boundaries for every candidate/probe pair.'
			Owner = 'Frontend/AngelscriptNativeParserInternalTests.cpp|FParserInternalTests|IdentifierPredicateByCandidateAndProbe'
		}
		@{
			Id = 'FRONTEND-STRING-CORE-OPERATIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'asCString core operation and storage state'
			Axes = @{
				Operation = @('length', 'append', 'substring', 'prefix_suffix', 'format', 'clear')
				SourceState = @('empty', 'short_local', 'long_dynamic', 'explicit_length')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every asCString operation/source-state pair retains explicit length, null termination, mutation, substring, formatting, prefix/suffix, and clear behavior.'
			Owner = 'Frontend/AngelscriptNativeStringInternalTests.cpp|FStringInternalTests|CoreOperationsBySourceState'
		}
		@{
			Id = 'FRONTEND-STRING-COMPARISON-POINTER'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'asCString comparison mutation distance and pointer views'
			Axes = @{
				Operation = @('mutation', 'comparison', 'distance', 'pointer_view')
				Observation = @('exact')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Cleanup', 'Isolation')
			Expected = 'Direct asCString/asCStringPointer observations retain assignment, bounded mutation, comparisons, edit distance, external ranges, and object-backed pointer views.'
			Owner = 'Frontend/AngelscriptNativeStringInternalTests.cpp|FStringInternalTests|MutationComparisonDistanceAndPointerViews'
		}
		@{
			Id = 'FRONTEND-STRING-OWNERSHIP-DEPTH'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'asCString owned storage and asCStringPointer alias lifetime'
			Axes = @{
				SourceState = @('empty', 'short', 'long', 'embedded_null')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every explicit-length source state preserves bytes and termination through copy construction, copy assignment, the current fork rvalue-to-copy fallback, and self-assignment; owned copies remain independent while object-backed and external-range pointer views retain their distinct mutation and length semantics.'
			Owner = 'Frontend/AngelscriptNativeStringOwnershipDepthTests.cpp|FStringOwnershipDepthTests|CopyMoveAndAliasOwnershipBySourceState'
		}
		@{
			Id = 'FRONTEND-STRING-SCAN-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'floating scanner malformed and partial-prefix boundaries'
			Axes = @{
				InputShape = @('empty', 'negative_sign', 'positive_sign', 'sign_only', 'leading_dot', 'trailing_token', 'malformed_exponent', 'malformed_exponent_plus', 'malformed_exponent_minus', 'valid_exponent', 'missing_mantissa', 'fraction_trailing')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Diagnostic', 'Isolation')
			Expected = 'Every empty, sign, fraction, trailing-token, and exponent boundary produces the current fork double/float value; the host prefix oracle records the consumed-prefix limitation because the exported scanner signatures do not expose an end pointer.'
			Owner = 'Frontend/AngelscriptNativeStringOwnershipDepthTests.cpp|FStringOwnershipDepthTests|NumericScanningBoundariesAndHostPrefixOracle'
		}
		@{
			Id = 'FRONTEND-PARSER-DIAGNOSTIC-LINE-ENDINGS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'malformed declaration diagnostic and line-ending preservation'
			Axes = @{
				MalformedShape = @('unfinished_class', 'capital_const_parameter', 'unclosed_namespace', 'bad_parameter_list', 'multiple_malformed')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Every malformed declaration shape fails full compilation under LF and CRLF, emits at least the shape-specific minimum error count, retains a useful stable diagnostic fragment where the fork publishes one, and prints the complete rejected source before compilation.'
			Owner = 'Frontend/AngelscriptNativeParserDiagnosticTests.cpp|FParserDiagnosticTests|MalformedDeclarationsByShapeAndLineEnding'
		}
		@{
			Id = 'FRONTEND-PARSER-MALFORMED-STAGE-CLASSIFICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'raw parser-stage malformed-source classification'
			Axes = @{
				MalformedShape = @('missing_semicolon', 'unbalanced_braces', 'unclosed_string', 'bad_operator_sequence', 'bad_parameter_list', 'multiple_malformed')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Each malformed source shape retains its exact current-fork parser-stage acceptance or rejection result. Missing-semicolon and bad-operator semantic defects are deliberately distinguished from shapes rejected during syntax-tree construction, and every source is printed.'
			Owner = 'Frontend/AngelscriptNativeParserErrorsTests.cpp|FParserErrorsTests|ParseStageClassificationByMalformedShape'
		}
		@{
			Id = 'FRONTEND-PARSER-RESET-RECOVERY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'parser failure recovery across parser lifetime'
			Axes = @{
				MalformedShape = @('unbalanced_braces', 'unclosed_string', 'bad_parameter_list', 'multiple_malformed')
				RecoveryMode = @('same_parser_reset', 'fresh_parser')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every parser-rejected source is followed by a valid source through both explicit reuse after Reset and an independently constructed parser. The invalid pass remains rejected, the recovery pass publishes a valid script tree, and source/module ownership stays isolated.'
			Owner = 'Frontend/AngelscriptNativeParserErrorsTests.cpp|FParserErrorsTests|ResetRecoveryByMalformedShapeAndParserLifetime'
		}
		@{
			Id = 'FRONTEND-NODE-SOURCE-RANGE-LINE-ENDINGS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'script-node source range across source shape and line ending'
			Axes = @{
				SourceShape = @('leading_lines_function', 'indented_class_member', 'multiline_declaration', 'comment_then_declaration', 'utf8_bom_declaration')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every source-shape and LF/CRLF cell publishes the selected node with exact one-based start row/column, a non-empty token span, and an end position reaching the expected line. Comment, indentation, multiline, and UTF-8 BOM byte offsets remain distinct.'
			Owner = 'Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp|FScriptNodeSourceRangeTests|SourceRangesByShapeAndLineEnding'
		}
		@{
			Id = 'FRONTEND-NODE-SOURCE-RANGE-CONTAINMENT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'nested script-node range containment'
			Axes = @{
				SourceShape = @('function', 'class', 'control', 'expression')
				LineEnding = @('lf', 'crlf')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every function, class, control-flow, and expression source under LF and CRLF publishes in-bounds node spans, keeps each ranged child inside its parent, exposes genuinely nested semantic spans, and retains non-trivial node count and depth.'
			Owner = 'Frontend/AngelscriptNativeScriptNodeOwnershipDepthTests.cpp|FScriptNodeOwnershipDepthTests|NestedSourceRangesRemainStrictlyContained'
		}
		@{
			Id = 'FRONTEND-NODE-COPY-OWNERSHIP-INDEPENDENCE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'deep script-node copy storage independence'
			Axes = @{
				SourceShape = @('deep_source')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The deep class/function/control/expression tree produces an independent CreateCopy allocation with identical token and link fingerprints; mutation and parser-scope release of the original leave the copied node count, links, histogram, and maximum depth unchanged.'
			Owner = 'Frontend/AngelscriptNativeScriptNodeOwnershipDepthTests.cpp|FScriptNodeOwnershipDepthTests|DeepCopyOwnsIndependentTreeAfterOriginalRelease'
		}
		@{
			Id = 'FRONTEND-STRING-UTILITY-COMPARISON-RANGES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'bounded raw string comparison'
			Axes = @{
				LeftRange = @('empty', 'alpha', 'alphabet', 'beta', 'embedded_null')
				RightRange = @('empty', 'alpha', 'alphabet', 'beta', 'embedded_null')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'Every left/right byte-range pair preserves the current SDK bounded-comparison sign convention, including empty, prefix, distinct-first-byte, and embedded-null ranges without falling back to null-terminated comparison.'
			Owner = 'Frontend/AngelscriptNativeStringUtilityTests.cpp|FStringUtilityTests|ComparisonsByLeftAndRightRange'
		}
		@{
			Id = 'FRONTEND-STRING-UTILITY-UNSIGNED-SCAN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'unsigned integer string scanning'
			Axes = @{
				Radix = @('binary', 'octal', 'decimal', 'hexadecimal')
				Magnitude = @('zero', 'value', 'maximum', 'overflow', 'invalid_tail')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic', 'Isolation')
			Expected = 'Every radix and magnitude cell preserves the exact wrapped value, consumed byte count, and overflow flag for zero, representative value, uint64 maximum, first overflow, and invalid trailing digit.'
			Owner = 'Frontend/AngelscriptNativeStringUtilityTests.cpp|FStringUtilityTests|UnsignedScanningByRadixAndMagnitude'
		}
		@{
			Id = 'FRONTEND-STRING-UTILITY-FLOAT-SCAN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'floating string scanning by precision and spelling'
			Axes = @{
				Precision = @('float32', 'float64')
				Spelling = @('signed_fraction', 'positive_exponent', 'negative_exponent', 'leading_dot')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Isolation')
			Expected = 'Every float32/float64 and spelling cell preserves signed fractional, positive/negative exponent, and leading-dot numeric values through the raw SDK scanner entry point.'
			Owner = 'Frontend/AngelscriptNativeStringUtilityTests.cpp|FStringUtilityTests|FloatingScanningByPrecisionAndSpelling'
		}
		@{
			Id = 'FRONTEND-STRING-UTILITY-UNICODE-ENCODING'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'Unicode code-point encoding boundary'
			Axes = @{
				CodePoint = @('ascii_boundary', 'two_byte_boundary', 'three_byte_value', 'supplementary_value', 'surrogate_current_fork', 'out_of_range')
				Encoding = @('utf8', 'utf16')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic', 'Isolation')
			Expected = 'Every code-point class and UTF-8/UTF-16 cell preserves the current-fork validity and encoded length. Valid UTF-8 values round-trip with the exact consumed length; the fork rejects UTF-8 surrogates and out-of-range values, while its raw UTF-16 encoder retains the existing two-byte surrogate and four-byte out-of-range behavior despite the public implementation comment.'
			Owner = 'Frontend/AngelscriptNativeStringUtilityTests.cpp|FStringUtilityTests|UnicodeEncodingByCodePointAndEncoding'
		}
		@{
			Id = 'FRONTEND-TOKEN-LONG-IDENTIFIER-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Frontend'
			Element = 'long identifier length and trailing token boundary'
			Axes = @{
				IdentifierLength = @('1', '63', '255', '400', '1024', '4096')
				TrailingToken = @('eof', 'space_identifier', 'assignment_integer', 'newline_keyword')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic', 'Isolation')
			Expected = 'Every identifier length and trailing-token cell emits one identifier with the complete byte span and leaves EOF, whitespace/identifier, assignment/integer, or newline/keyword boundaries independently observable.'
			Owner = 'Frontend/AngelscriptNativeTokenizerBoundaryTests.cpp|FTokenizerBoundaryTests|LongIdentifiersByLengthAndTrailingToken'
		}
		@{
			Id = 'COMPILER-BUILDER-FUNCTION-DECLARATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder function-declaration parsing and metadata'
			Axes = @{
				ReturnType = @('int', 'bool', 'float64')
				ParameterShape = @('none', 'single', 'default', 'directions')
				Trait = @('plain', 'no_discard')
				Namespace = @('global', 'named')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every return-type, parameter-shape, trait, and namespace combination parses through asCBuilder::ParseFunctionDeclaration and preserves exact return type, parameter count and defaults, no_discard state, and namespace metadata. Every cell owns independent case/control engines with same-name modules, preserves control identity, and explicitly discards both modules with null lookup.'
			Owner = 'Compiler/AngelscriptNativeBuilderApplicationTests.cpp|FBuilderApplicationTests|FunctionDeclarationsByReturnParameterTraitAndNamespace'
		}
		@{
			Id = 'COMPILER-BUILDER-SCALAR-DECLARATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder scalar data-type and variable-declaration parsing'
			Axes = @{
				ScalarType = @('int', 'bool', 'float64')
				Qualifier = @('mutable', 'const')
				Namespace = @('global', 'named')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every scalar type, qualifier, and namespace combination preserves type id, readonly state, variable name, and namespace identity through both ParseDataType and ParseVariableDeclaration. Every cell owns independent case/control engines with same-name modules, preserves control identity, and explicitly discards both modules with null lookup.'
			Owner = 'Compiler/AngelscriptNativeBuilderScalarApplicationTests.cpp|FBuilderScalarApplicationTests|ScalarTypesByQualifierAndDeclarationApi'
		}
		@{
			Id = 'COMPILER-BUILDER-TEMPLATE-DECLARATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder template declaration token splitting'
			Axes = @{
				Arity = @('one', 'two', 'three')
				IdentifierStyle = @('plain', 'numbered')
				Whitespace = @('tight', 'spaced')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every subtype arity, identifier style, and whitespace combination preserves the template name, exact subtype count, ordering, and spelling through ParseTemplateDecl. Every cell owns independent case/control engines with same-name modules, preserves control identity, and explicitly discards both modules with null lookup.'
			Owner = 'Compiler/AngelscriptNativeBuilderTemplateApplicationTests.cpp|FBuilderTemplateApplicationTests|TemplateDeclarationsByArityIdentifierAndWhitespace'
		}
		@{
			Id = 'COMPILER-BUILDER-PROPERTY-VERIFICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder native-property verification'
			Axes = @{
				ScalarType = @('int', 'bool', 'float64')
				Qualifier = @('mutable', 'const')
				ConflictState = @('new', 'existing')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every scalar type, qualifier, and new/existing property-name combination preserves success or asNAME_TAKEN, parsed metadata for accepted declarations, and the exact name-conflict diagnostic for rejected declarations. Independent case/control engines use same-name modules, the control carrier/property identity and count remain unchanged, and both modules are explicitly discarded with null lookup.'
			Owner = 'Compiler/AngelscriptNativeBuilderPropertyApplicationTests.cpp|FBuilderPropertyApplicationTests|PropertiesByScalarQualifierAndConflictState'
		}
		@{
			Id = 'EMBED-JIT-INSTALL-COMPILE-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'raw JIT compiler installation and compile routing'
			Axes = @{
				State = @('absent', 'primary_installed', 'replacement_installed', 'cleared')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The raw engine reports the exact installed compiler, routes subsequently built script functions only to the active compiler, supports replacement and clear, and retains interpreted module compilation after clear.'
			Owner = 'Embedding/AngelscriptNativeJitCompilerTests.cpp|FNativeJitCompilerTests|InstallCompileReplaceAndClear'
		}
		@{
			Id = 'EMBED-JIT-FAILURE-RELEASE-BOUNDARY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'raw JIT compile failure and release boundary'
			Axes = @{
				Scenario = @('compile_rejection_interpreted_fallback', 'module_discard_missing_release', 'explicit_release_interface')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A negative CompileFunction result leaves the module available for interpretation with a null JIT function; the current fork visibly does not call ReleaseJITFunction during module discard, while direct interface dispatch preserves the exact explicitly released function pointer.'
			Owner = 'Embedding/AngelscriptNativeJitCompilerTests.cpp|FNativeJitCompilerTests|CompileFailureAndReleaseBoundary'
		}
		@{
			Id = 'EMBED-GENERIC-METADATA-CALLBACK'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'generic callback metadata by receiver, arity, and auxiliary registration'
			Axes = @{
				Target = @('global', 'object_method')
				Arity = @('zero', 'one', 'two')
				Auxiliary = @('absent', 'provided')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every global/object target, zero/one/two-argument signature, and absent/provided auxiliary registration invokes exactly one generic callback, exposes the owning engine/function, the registered object receiver type or the current-fork raw minus-one sentinel for a global callback (distinct from public asINVALID_TYPE), exact argument count, int return metadata, deterministic result, and the current-fork null-auxiliary contract.'
			Owner = 'Embedding/AngelscriptNativeGenericInterfaceDepthTests.cpp|FGenericInterfaceDepthTests|MetadataByTargetArityAndAuxiliaryRegistration'
		}
		@{
			Id = 'EMBED-GENERIC-OBJECT-RETURN'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'generic value-object return and auxiliary registration boundary'
			Axes = @{
				Auxiliary = @('absent', 'provided')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Both auxiliary registration states invoke SetReturnObject for the exact registered POD value type, copy the complete object payload into script return storage, expose the exact return type, retain the current fork null-auxiliary observation, and explicitly remove each generated module before the next independent cell. Object construction/destruction lifecycle is owned separately by non-POD registration products.'
			Owner = 'Embedding/AngelscriptNativeGenericInterfaceDepthTests.cpp|FGenericInterfaceDepthTests|ObjectReturnsByAuxiliaryRegistration'
		}
		@{
			Id = 'EMBED-NATIVE-CALL-ABI-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'native global-function argument and return ABI shapes'
			Axes = @{
				Shape = @('four_int_args', 'double_args_return', 'void_side_effect', 'nested_call', 'six_int_args', 'wide_return', 'mixed_int_double', 'bool_return', 'out_params')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'The exact owner plus eight scenario-specific product parts cover every registered CDecl signature and script entry: four/six integer arguments, double arguments/return, void side effects, nested calls, int64 return, mixed int/double arguments, bool return, and out parameters. The owner asserts exact function ID/arity/return metadata, explicit module removal, and absence from an independent engine; each part executes its distinct ABI shape in a case-owned engine.'
			Owner = 'Embedding/AngelscriptNativeCallFunctionTests.cpp|FCallFunctionTests|CallFunctionMultipleArgs'
		}
		@{
			Id = 'EMBED-CALLING-CONVENTION-DISPATCH'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'native calling convention dispatch'
			Axes = @{
				Convention = @('cdecl', 'generic', 'thiscall', 'cdecl_object_last')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The owner and three scenario-specific product parts resolve the returned function or behaviour IDs, assert exact declaration/parameter/return-or-owner metadata, and execute CDecl, generic, thiscall, and CDecl object-last dispatch. Object-last preserves the constructor argument before thiscall dispatch; every printed module is explicitly discarded and confirmed absent, and each registration surface remains absent from an independent engine.'
			Owner = 'Embedding/AngelscriptNativeCallingConventionTests.cpp|FCallingConventionTests|CallingConventionCDecl'
		}
		@{
			Id = 'EMBED-GLOBAL-CALLBACK-ARGUMENT-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'global native callback argument shapes'
			Axes = @{
				Shape = @('zero', 'one_int', 'two_int', 'mixed_width', 'floating')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The owner and four scenario-specific product parts register zero-, one-, two-, mixed-width-, and float-property-aware callbacks and assert each returned ID, exact normalized declaration, parameter count, and void return metadata before executing a complete printed module. Direct one-argument context dispatch preserves the argument, context release supplies the exact user-data pointer to cleanup, every module is explicitly discarded and confirmed absent, and an independent engine contains no callback registrations.'
			Owner = 'Embedding/AngelscriptNativeGlobalCallbackTests.cpp|FGlobalCallbackTests|GlobalCallbackBasicInvocation'
		}
		@{
			Id = 'EMBED-GLOBAL-REGISTRATION-SURFACES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'global function and property registration surfaces'
			Axes = @{
				Surface = @('function', 'property')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The function owner asserts its returned ID, normalized declaration, parameter count, return type, printed-script result, and the current-fork declaration-lookup mismatch. The property product part asserts indexed root-namespace name, type, mutability, and exact native address before proving script mutation. Both explicitly discard and confirm removal of their modules and prove their registration surface absent from an independent engine.'
			Owner = 'Embedding/AngelscriptNativeGlobalRegistrationTests.cpp|FGlobalRegistrationTests|GlobalRegistrationGlobalFunction'
		}
		@{
			Id = 'EMBED-OBJECT-REGISTRATION-CONTRACTS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Embedding'
			Element = 'native value-object registration and caller contracts'
			Axes = @{
				Scenario = @('simple_value', 'double_value', 'missing_caller')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The owner and two scenario-specific product parts publish exact native size, property name/type/offset, and method declaration/parameter/return metadata for the POD integer and double-backed value types. Printed scripts preserve constructor/property state and double method arguments/results; a non-generic method without an automatic caller raises the exact current-fork exception with a throwing function before native invocation. Every module is explicitly discarded and confirmed absent, and every registered type remains absent from an independent engine.'
			Owner = 'Embedding/AngelscriptNativeObjectRegistrationTests.cpp|FObjectRegistrationTests|ObjectRegistrationSimpleValueType'
		}
		@{
			Id = 'TYPE-TYPEINFO-IDENTITY-OWNERSHIP'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'public TypeInfo engine/module/config/access/reference ownership by type kind'
			Axes = @{
				Kind = @('native_object', 'script_class', 'typedef', 'funcdef')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every native-object, module-owned script-class, registered typedef, and registered funcdef TypeInfo exposes the exact engine and module ownership, the current-fork null config-group lookup, all-bits access mask, and a balanced external AddRef/Release transition while the engine/module remains live.'
			Owner = 'TypeSystem/AngelscriptNativeTypeInfoFunctionMetadataDepthTests.cpp|FTypeInfoFunctionMetadataDepthTests|TypeIdentityOwnershipByKind'
		}
		@{
			Id = 'TYPE-TYPEINFO-OBJECT-STRUCTURE'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'public object TypeInfo property, factory, subtype, interface, and child-funcdef structure'
			Axes = @{
				Target = @('base', 'derived')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Base and derived script-class inputs expose exact property declarations, canonical factory index/declaration identity and invalid boundaries, zero non-template subtype state, zero accepted interface state with exact Implements behavior, and empty child-funcdef state; a registered native owner independently proves positive child/parent funcdef identity while unsafe zero-count GetInterface indexing remains explicitly deferred.'
			Owner = 'TypeSystem/AngelscriptNativeTypeInfoFunctionMetadataDepthTests.cpp|FTypeInfoFunctionMetadataDepthTests|ObjectStructureFactoriesAndBoundaries'
		}
		@{
			Id = 'TYPE-TYPEINFO-TYPEDEF-USERDATA'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'public typedef alias and plain TypeInfo user-data lifecycle'
			Axes = @{
				Alias = @('int64')
				Mutation = @('install_replace_clear')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The registered int64 typedef reports the underlying primitive type ID, starts with null plain user data, returns exact prior pointers across install and replacement, and returns to null after explicit cleanup before engine teardown.'
			Owner = 'TypeSystem/AngelscriptNativeTypeInfoFunctionMetadataDepthTests.cpp|FTypeInfoFunctionMetadataDepthTests|TypedefAndPlainUserDataLifecycle'
		}
		@{
			Id = 'TYPE-SCRIPTFUNCTION-METADATA-KINDS'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'public ScriptFunction metadata by implementation kind'
			Axes = @{
				Kind = @('native_system', 'registered_funcdef', 'script_noop', 'script_effect')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Bytecode', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Native system, registered funcdef signature, empty script, and effectful script functions expose the exact engine, current-fork null config-group and auxiliary pointers, kind-specific IsNoOp and IsShared results, and the stable matching registered function-pointer type ID.'
			Owner = 'TypeSystem/AngelscriptNativeTypeInfoFunctionMetadataDepthTests.cpp|FTypeInfoFunctionMetadataDepthTests|FunctionMetadataByImplementationKind'
		}
		@{
			Id = 'RT-OBJ-TYPE-ENGINE-IDENTITY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'live script-object TypeInfo type-ID and engine identity by creation origin'
			Axes = @{
				Origin = @('constructed', 'copy', 'uninitialized')
				Query = @('object_type', 'type_id', 'engine')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Constructed, copied, and uninitialized live raw script objects each expose the exact owning TypeInfo, its public type ID with engine round-trip, and the exact raw engine before and after a balanced object AddRef/Release pair; all objects are released before module discard.'
			Owner = 'Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp|FNativeScriptObjectLifecycleDepthTests|TypeObjectAndEngineIdentityByCreationOrigin'
		}
		@{
			Id = 'RT-OBJ-USERDATA-FORK-STUB'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'script-object user-data storage stub by slot and transition'
			Axes = @{
				Slot = @('default', 'custom')
				State = @('initial', 'install', 'replace', 'clear')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Default and custom script-object user-data slots return null initially and across install, replacement, readback, and clear because the current fork accessors are explicit storage stubs; the enabled negative owner does not claim keyed storage or cleanup callback support.'
			Owner = 'Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp|FNativeScriptObjectLifecycleDepthTests|UserDataSlotsRetainCurrentForkStubBehavior'
		}
		@{
			Id = 'RT-OBJ-ENGINE-TEARDOWN-REGISTRY-ISOLATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'outstanding raw script-object registry retirement and successor-engine isolation'
			Axes = @{
				EngineGeneration = @('outstanding_owner', 'independent_successor')
				Observation = @('registry_identity', 'teardown_removal', 'successor_identity', 'final_release')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'An application-held raw object has an exact registry entry before its engine retires, that engine removes only its registry entry without claiming allocation destruction, and an independently compiled successor owns and releases a distinct object without inheriting stale TypeInfo state.'
			Owner = 'Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp|FNativeScriptObjectLifecycleDepthTests|OutstandingRegistrationIsRemovedBeforeIndependentEngine'
		}
		@{
			Id = 'TYPE-TYPEINFO-SHADOW-SYSTEM-TYPE'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'TypeInfo shadow-system assignment replacement traversal and clearing'
			Axes = @{
				Operation = @(
					'initial'
					'copy_base'
					'copy_child'
					'transitive_method'
					'replace'
					'replace_transitive'
					'clear_grandchild'
					'clear_child'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Valid same-engine object TypeInfo inputs establish direct and transitive ShadowsFrom relations and exact method identity, replacement removes the old chain and publishes the new chain, and ordered null clearing removes all inherited relations and methods without creating cycles or dangling owners.'
			Owner = 'TypeSystem/AngelscriptNativeTypeInfoShadowSystemTypeTests.cpp|FTypeInfoShadowSystemTypeTests|CopyReplaceTraverseAndClearShadowType'
		}
		@{
			Id = 'ENG-REGISTRATION-STRING-FACTORY-INTERFACE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'test-owned string-factory constant ownership and raw-data interface'
			Axes = @{
				Scenario = @('alpha_reuse', 'null_raw_data_reject', 'stale_release_reject')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'The test-owned raw string factory interns equal byte sequences to one identity with balanced references, publishes exact raw length and bytes, releases the final identity exactly once, and rejects null raw-data and stale-release inputs without an addon.'
			Owner = 'Engine/AngelscriptNativeEngineRegistrationServiceTests.cpp|FEngineRegistrationServiceTests|StringFactoryReferenceAndRawDataLifecycle'
		}
		@{
			Id = 'ENG-REGISTRATION-STRING-FACTORY-SERVICE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'engine string-factory registration literal compilation and bytecode lifecycle'
			Axes = @{
				State = @('fresh_query', 'register_value_type', 'repeat_same', 'literal_alpha')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Bytecode', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A fresh engine reports no factory without overwriting caller flags; a test-owned value type and factory publish exact type identity and fork flags, repeated identical registration preserves identity, a printed literal compiles and serializes without an addon, and engine teardown balances every acquired constant.'
			Owner = 'Engine/AngelscriptNativeEngineRegistrationServiceTests.cpp|FEngineRegistrationServiceTests|StringFactoryRegistrationLiteralAndBytecodeLifecycle'
		}
		@{
			Id = 'ENG-REGISTRATION-STRING-FACTORY-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'string-factory invalid registration isolation'
			Axes = @{
				Input = @('null_factory', 'unknown_type', 'handle_type')
			}
			Classification = 'CurrentFork'
			Evidence = @('Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Null factory, unknown type, and handle-type inputs are rejected in independent raw engines with exact result codes and diagnostics, and no rejected input publishes a string-factory type.'
			Owner = 'Engine/AngelscriptNativeEngineRegistrationServiceTests.cpp|FEngineRegistrationServiceTests|StringFactoryRegistrationRejectsInvalidInputsInIsolation'
		}
		@{
			Id = 'ENG-REGISTRATION-DEFAULT-ARRAY-TYPE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'default array type registration and failure isolation'
			Axes = @{
				State = @('fresh', 'primitive_reject', 'non_template_reject', 'template_accept', 'post_install_invalid')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Diagnostic', 'Lifecycle', 'Isolation')
			Expected = 'A fresh engine has no default array type; primitive and non-template inputs are rejected; a test-owned raw template is accepted with exact type identity, name, and flags; and a later invalid input preserves the installed identity. Cleanup is not claimed: repeating a successful registration remains excluded because the current fork leaks the prior internal reference.'
			Owner = 'Engine/AngelscriptNativeEngineRegistrationServiceTests.cpp|FEngineRegistrationServiceTests|DefaultArrayTypeRegistrationAndFailureIsolation'
		}
		@{
			Id = 'ENG-OBJECT-SERVICE-DELEGATE-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'delegate creation rejection and unsafe positive-path boundary'
			Axes = @{
				Scenario = @('null_function', 'null_object', 'non_method')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Null function, null object, and non-method inputs return null without retaining the receiver. The valid path is printed but not executed because retained focused runs prove independent current-fork crashes in parameter assignment, top-level delegate execution, and shutdown GC reporting.'
			Owner = 'Engine/AngelscriptNativeEngineObjectServiceTests.cpp|FNativeEngineObjectServiceTests|DelegateCreationRejectsInvalidInputsAndRecordsUnsafePositivePath'
		}
		@{
			Id = 'ENG-OBJECT-SERVICE-REFCAST-CONTRACT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'reference cast guards conversion routing and result ownership'
			Axes = @{
				Scenario = @(
					'null_output'
					'null_from'
					'null_to'
					'null_object'
					'identity'
					'no_conversion'
					'implicit'
					'explicit_suppressed'
					'explicit'
					'unsafe_mismatch_deferred'
					'cross_engine_type_deferred'
				)
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Safe null, identity, absent-conversion, implicit, and explicit routes preserve exact return codes, pointer identity, callback routing, and balanced result ownership. Runtime-type mismatch and cross-engine TypeInfo inputs remain printed but unexecuted current-fork limitations because RefCastObject does not validate those invariants before dispatch.'
			Owner = 'Engine/AngelscriptNativeEngineObjectServiceTests.cpp|FNativeEngineObjectServiceTests|ReferenceCastGuardsConversionsAndOwnership'
		}
		@{
			Id = 'ENG-GC-FORWARD-VALUE-BEHAVIOURS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'value-GC enum and release reference forwarding'
			Axes = @{
				Scenario = @('value_gc_enum', 'value_gc_release', 'plain_value_enum_noop', 'plain_value_release_noop')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Isolation')
			Expected = 'Value types carrying the GC flag dispatch the exact enum or release behaviour once without cross-dispatch, while a plain value type leaves both counters unchanged in each forwarding direction.'
			Owner = 'Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp|FNativeEngineGcCleanupServiceTests|ForwardsOnlyValueGcReferenceBehaviours'
		}
		@{
			Id = 'ENG-CLEANUP-ENGINE-USERDATA'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'engine user-data cleanup callback replacement and slot isolation'
			Axes = @{
				Scenario = @('default_slot_replace', 'custom_slot_isolation', 'null_slot_suppression')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Default and custom engine user-data slots return exact prior pointers, callback replacement retires the prior callback, populated slots dispatch only their final callback exactly once at destruction with exact engine/data identity, and an empty slot does not dispatch.'
			Owner = 'Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp|FNativeEngineGcCleanupServiceTests|CleansEngineUserDataBySlotAtDestruction'
		}
		@{
			Id = 'ENG-CLEANUP-TYPEINFO-USERDATA'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'TypeInfo user-data cleanup callback replacement and type-slot isolation'
			Axes = @{
				Scenario = @('default_slot_replace', 'custom_slot_type_isolation', 'null_slot_suppression')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Two TypeInfo owners and default/custom/empty slots preserve exact replacement pointers, callback replacement, cross-type and cross-slot isolation, destruction-time exactly-once dispatch for every populated type-slot pair, final data visibility, and empty-slot suppression.'
			Owner = 'Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp|FNativeEngineGcCleanupServiceTests|CleansTypeInfoUserDataBySlotAtDestruction'
		}
		@{
			Id = 'ENG-APP-EXCEPTION-TRANSLATE-REJECT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Engine'
			Element = 'application exception translation rejection without native exception support'
			Axes = @{
				Configuration = @('as_no_exceptions')
			}
			Classification = 'RejectByFork'
			Evidence = @('Runtime', 'Diagnostic')
			Expected = 'A non-null correctly declared CDECL application-exception translator is rejected with asNOT_SUPPORTED because the current fork compiles the raw SDK with AS_NO_EXCEPTIONS; the enabled test records the limitation rather than hiding the API or requiring an unsupported 2.38 path.'
			Owner = 'Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp|FNativeEngineGcCleanupServiceTests|RejectsApplicationExceptionTranslationWithoutExceptionSupport'
		}
		@{
			Id = 'TYPE-CONFIG-GROUP-STORAGE-ONLY'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'configuration-group storage-only lifecycle and function persistence'
			Axes = @{
				Operation = @('begin', 'register', 'end', 'nested', 'remove', 'persistence')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Runtime', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Every group operation reports success, nested begin/end remains accepted, registered functions expose null config-group metadata, removal is a no-op, and the exact function remains compilable and executable afterward; the product records the current fork stub rather than claiming real group ownership.'
			Owner = 'TypeSystem/AngelscriptNativeConfigGroupTests.cpp|FConfigGroupTests|ConfigGroupBeginEnd'
		}
		@{
			Id = 'TYPE-DATATYPE-HANDLE-CONTRACT'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'internal data-type object-handle identity qualifiers and storage'
			Axes = @{
				Shape = @('object_value', 'mutable_handle', 'const_handle', 'const_reference_handle', 'null_handle')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata')
			Expected = 'A registered zero-size reference-object value and its mutable, const, const-reference, and null handle value descriptors preserve exact TypeInfo identity, kind predicates, comparison semantics, instantiation policy, and the current distinction between zero metadata size and native-pointer variable size/alignment. Object-type ownership and cleanup are independently owned by the dedicated destruction/function/property release products.'
			Owner = 'TypeSystem/AngelscriptNativeDataTypeTests.cpp|FDataTypeTests|HandleQualifiersPreserveConstAndReferenceFlags'
		}
		@{
			Id = 'TYPE-DEFAULT-TRAIT-METADATA-RUNTIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'defaults-only and unsafe-construction function trait publication'
			Axes = @{
				Modifier = @('defaults', 'unsafe_during_construction')
				Observation = @('metadata', 'direct_context')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Each modifier publishes only its exact internal function-trait bit, keeps the opposite bit clear, retains its canonical declaration, and remains directly executable with the expected return value. An ordinary Entry control publishes neither trait, executes independently, and the module is explicitly discarded before the next owner.'
			Owner = 'TypeSystem/AngelscriptNativeDefaultTraitTests.cpp|FDefaultTraitTests|DefaultTraitModifiers'
		}
		@{
			Id = 'TYPE-ENUM-REGISTRATION-RUNTIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'native and script enum registration metadata and runtime behavior'
			Axes = @{
				Origin = @('native_global', 'native_namespace', 'script_local')
				Observation = @('metadata', 'runtime')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Global native, namespace-local native, and module-local script enums retain exact type flags, distinct namespace/module ownership, value count, value names and underlying values, while the script-local enum executes equality through its exact entry declaration. Module discard proves script-local cleanup. Three distinct native-enum TypeInfo userdata sentinels expose the current-fork cleanup defect: engine destruction clears registeredEnums without invoking their cleanup callbacks, so the enabled negative contract requires zero callbacks and no observed sentinel.'
			Owner = 'TypeSystem/AngelscriptNativeEnumTypeTests.cpp|FEnumTypeTests|EnumTypeEnum'
		}
		@{
			Id = 'TYPE-GLOBAL-PROPERTY-ACCESS-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'registered native global-property access by type and direction'
			Axes = @{
				Type = @('int', 'double', 'bool')
				Access = @('read', 'write', 'read_modify_write')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Every int, double, and bool property independently compiles and executes read, write, and read-modify-write access against native storage, publishes the exact integer observation entry ABI, and cleans its isolated generated module.'
			Owner = 'TypeSystem/AngelscriptNativeGlobalPropertyTests.cpp|FGlobalPropertyTests|GlobalPropertiesByTypeAndAccess'
		}
		@{
			Id = 'TYPE-TYPEDEF-BYTECODE-RUNTIME'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'registered typedef declaration bytecode persistence and loaded execution'
			Axes = @{
				Phase = @('save_registration', 'save_bytecode', 'load_bytecode', 'loaded_runtime')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Bytecode', 'Metadata', 'Runtime', 'SaveLoad', 'Cleanup', 'Isolation')
			Expected = 'Independently registered int8 and int64 aliases compile one alias-backed function, normalize its public declaration to the canonical underlying types while preserving exact registered type IDs, save and load bytecode across separately configured engines, and execute the loaded widening round trip. Both modules are absent, the stream returns to an explicit empty baseline, and distinct engine-user-data sentinels prove ordered load/save engine cleanup.'
			Owner = 'TypeSystem/AngelscriptNativeTypedefTypeTests.cpp|FTypedefTypeTests|TypedefTypeTypedefBytecode'
		}
		@{
			Id = 'TYPE-VARIABLE-SCOPE-BOUNDARIES'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'block construct variable visibility and escape rejection'
			Axes = @{
				Construct = @('block', 'for', 'while', 'if')
				Outcome = @('inside_valid', 'outside_rejected')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Block, for, while, and if locals compile and execute while referenced inside their owner, reject an otherwise identical escaped reference after the owner, name the escaped identifier in diagnostics, and discard every isolated module.'
			Owner = 'TypeSystem/AngelscriptNativeVariableScopeTests.cpp|FVariableScopeTests|ScopesByConstructAndOutcome'
		}
		@{
			Id = 'COMPILER-BYTECODE-CONTAINER-OPERATIONS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'bytecode linked container mutation and serialization'
			Axes = @{
				SeedCount = @('empty', 'one', 'two', 'four')
				Mutation = @('append', 'prepend', 'remove', 'clear_reappend', 'jump_resolve')
				Payload = @('zero', 'positive', 'maximum')
			}
			Classification = 'CurrentFork'
			Evidence = @('Bytecode', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every seed-count, mutation, and payload combination preserves linked instruction count including the zero-size LABEL pseudo-instruction, head/tail state, serialized GetSize parity excluding zero-size labels, exact payload retention, empty removal rejection, and resolved forward-jump offsets.'
			Owner = 'Compiler/AngelscriptNativeByteInstructionTests.cpp|FByteInstructionTests|InstructionContainersBySeedMutationAndPayload'
		}
		@{
			Id = 'COMPILER-BUILDER-MODULE-DEPENDENCY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder module dependency target flag repeat and global-initializer outcome'
			Axes = @{
				Scenario = @('direct_module', 'structural_type', 'hard_function', 'global_initializer_rejection')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Direct module, structural type, and hard function dependencies preserve exact owner identity, zero-node location, deduplication, and mutually accurate flags; an unavailable cross-module global-initializer dependency is rejected without an executable leak.'
			Owner = 'Compiler/AngelscriptNativeBuilderDependencyTests.cpp|FBuilderDependencyTests|ModuleDependenciesPreserveTargetsFlagsAndFailureIsolation'
		}
		@{
			Id = 'COMPILER-BUILDER-CROSS-SECTION-PUBLICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'cross-section provider consumer type helper and entry publication'
			Axes = @{
				Shape = @('provider_consumer', 'type_helper_entry')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Bytecode', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'Both provider/consumer and type/helper/entry section shapes traverse every builder stage, retain exact declaring-section ownership and class layout, publish executable bytecode, and execute the cross-section result without insertion-order leakage.'
			Owner = 'Compiler/AngelscriptNativeBuilderCrossSectionPublicationTests.cpp|FBuilderCrossSectionPublicationTests|CrossSectionPublicationPreservesOwnersAndExecution'
		}
		@{
			Id = 'COMPILER-BUILDER-EDITOR-ONLY-CLASSIFICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'editor-only line block whole-module and section classification'
			Axes = @{
				Mode = @('line_block', 'whole_module')
				DeclarationKind = @('class', 'function')
				SectionRelation = @('owning', 'other')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Isolation')
			Expected = 'Line-block and whole-module modes classify class/function nodes exactly, while matching row ranges from another retained script section remain isolated from the owning section.'
			Owner = 'Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp|FBuilderEditorOnlyTests|EditorOnlyModesClassifyDeclarationsAndIsolateSections'
		}
		@{
			Id = 'COMPILER-DIAGNOSTIC-WARNING-POLICY'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'default and warnings-as-errors severity publication'
			Axes = @{
				Policy = @('default')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Bytecode', 'Cleanup', 'Isolation')
			Expected = 'Default warning policy preserves exact section, row, severity, and overload diagnostic, increments warnings without errors, succeeds compilation, publishes executable Entry bytecode, explicitly removes its module, and leaves the engine warning property unchanged.'
			Owner = 'Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp|FBuilderDiagnosticTests|WarningReportsSectionRowAndDoesNotFailByDefault'
		}
		@{
			Id = 'COMPILER-BUILDER-COMPILE-FUNCTION-SUCCESS'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'CompileFunction successful section publication'
			Axes = @{
				Outcome = @('success')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Bytecode', 'Cleanup', 'Isolation')
			Expected = 'CompileFunction success returns the exact function, publishes it once in the module, retains the supplied script section, and leaves executable bytecode. The product module is removed before an independent control module proves no function or diagnostic leakage and is itself removed.'
			Owner = 'Compiler/AngelscriptNativeBuilderFunctionTests.cpp|FBuilderFunctionTests|CompileFunctionUsesProvidedSectionName'
		}
		@{
			Id = 'COMPILER-BYTECODE-JUMP-RESOLUTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'bytecode jump direction topology composition and recovery'
			Axes = @{
				Topology = @('forward', 'backward', 'multiple', 'missing_repair', 'appended_sequence')
			}
			Classification = 'CurrentFork'
			Evidence = @('Bytecode', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Forward and backward jumps retain signed relative direction; independent labels retain distinct rewritten targets; a missing label fails without losing instructions and resolves after repair; and a target appended from another sequence retains payload order, exact offset direction, serialized-size parity, and isolated fixture cleanup.'
			Owner = 'Compiler/AngelscriptNativeBytecodeJumpTests.cpp|FBytecodeJumpTests|JumpTopologiesResolveOrRejectWithExactOffsets'
		}
		@{
			Id = 'COMPILER-DIAGNOSTIC-WARNING-PROMOTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'warnings-as-errors promotion diagnostic and cleanup'
			Axes = @{
				Policy = @('warnings_as_errors')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Warnings-as-errors preserves the original located warning, adds the promotion error, rejects the final compile stage after bytecode publication, increments both counters, removes the exact module, restores the previous engine property, and does not change an independent engine warning policy.'
			Owner = 'Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp|FBuilderDiagnosticTests|WarningsAsErrorsFailBuildAndPreserveWarningDiagnostic'
		}
		@{
			Id = 'COMPILER-BUILDER-COMPILE-FUNCTION-FAILURE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'CompileFunction failure atomicity'
			Axes = @{
				Outcome = @('invalid_signature')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'CompileFunction rejects an invalid signature, returns no function, and leaves module function/global/type and builder-description tables empty without leaking partial state. After exact module cleanup, an independent control module compiles the same Entry name, publishes bytecode without inherited diagnostics, and is removed.'
			Owner = 'Compiler/AngelscriptNativeBuilderFunctionTests.cpp|FBuilderFunctionTests|CompileFunctionFailureDoesNotLeakFunction'
		}
		@{
			Id = 'COMPILER-BUILDER-COMPILE-FUNCTION-WARNING-OFFSET'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'CompileFunction warning section and line-offset propagation'
			Axes = @{
				LineOffset = @('twenty')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'CompileFunction succeeds with its exact returned function, retains the provided section, applies the requested source-line offset to the warning row, and publishes warning severity without an error. After exact module cleanup, an independent clean control compiles without inheriting diagnostics and is removed.'
			Owner = 'Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp|FBuilderDiagnosticTests|CompileFunctionWarningUsesLineOffset'
		}
		@{
			Id = 'COMPILER-BYTECODE-CALL-CONTROL-SHAPES'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'compiled overload transfer recursion short-circuit default-call and enum-switch shapes'
			Axes = @{
				Shape = @('namespace_overload', 'break_continue', 'recursion', 'short_circuit', 'default_arguments', 'enum_switch')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Bytecode', 'Runtime', 'Metadata', 'Diagnostic', 'Cleanup', 'Isolation')
			Expected = 'Every generated shape prints complete source, publishes its exact declarations, retains a representative call or branch opcode, executes its independent overload/transfer/recursion/skip/default/switch oracle, and leaves no module or context residue.'
			Owner = 'Compiler/AngelscriptNativeBuilderBytecodeTests.cpp|FBuilderBytecodeTests|CallAndControlShapesPreserveBytecodeAndRuntime'
		}
		@{
			Id = 'COMPILER-BUILDER-DECLARATION-PUBLICATION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'staged declaration-family scope and overload publication'
			Axes = @{
				Stage = @('parse', 'type', 'function', 'layout', 'code')
				Family = @('class', 'enum', 'function', 'import', 'const_global')
				Scope = @('global', 'namespace')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Bytecode', 'Runtime', 'Cleanup', 'Isolation')
			Expected = 'At each builder stage every declaration family is either absent or published in its exact global/namespaced owner, overloads retain distinct descriptions and type IDs, imports/globals remain stage-correct, and final code executes without partial early publication. Transient builder/parser state is released before exact module discard and null lookup; an independent engine proves no declaration publication.'
			Owner = 'Compiler/AngelscriptNativeBuilderDeclarationTests.cpp|FBuilderDeclarationTests|StagesPublishDeclarationFamiliesWithoutEarlyLeak'
		}
		@{
			Id = 'COMPILER-BUILDER-CONST-GLOBAL-STATE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'const-global descriptor module address folding and runtime state'
			Axes = @{
				Type = @('int', 'int64', 'double', 'bool')
				Scope = @('global', 'namespace')
				Initializer = @('literal', 'folded_expression')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Bytecode', 'Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Every type/scope/initializer cell preserves builder descriptor flags and folded value, module declaration/index/type/const metadata, exact storage address value, reader bytecode/runtime, and isolated cleanup before and after initialization. Transient builder/parser state is released before exact module discard; a registered native storage control retains address/value identity and an independent engine remains empty.'
			Owner = 'Compiler/AngelscriptNativeBuilderGlobalTests.cpp|FBuilderGlobalTests|ConstGlobalsPreserveDescriptorAddressAndRuntimeState'
		}
		@{
			Id = 'COMPILER-BUILDER-FORK-DECLARATION-REJECTION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'current-fork declaration rejection stage publication atomicity and recovery'
			Axes = @{
				Feature = @('mutable_global', 'script_interface')
				Recovery = @('same_engine', 'fresh_module')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Mutable globals and script interfaces fail at their exact current-fork stage with located diagnostics and no executable partial tables; same-engine and fresh-module recovery publish and execute an allowed replacement without residue.'
			Owner = 'Compiler/AngelscriptNativeBuilderTypeTests.cpp|FBuilderTypeTests|ForkDeclarationRejectionsRemainAtomicAndRecover'
		}
		@{
			Id = 'COMPILER-BUILDER-CLASS-LAYOUT'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'class inheritance property-initializer method-overload and stage layout'
			Axes = @{
				Shape = @('inheritance', 'property_initializer', 'method_overload')
				Stage = @('layout', 'code')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Bytecode', 'Runtime', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Inheritance, property-initializer, and method-overload shapes retain exact base/type/property/method/default-init metadata at layout and code stages, publish executable bytecode, and run only behavior actually exercised by the generated source. Raw observations and transient builder state are released before staged/runtime module cleanup; a native reference-type identity control and an independent engine prove isolation.'
			Owner = 'Compiler/AngelscriptNativeBuilderLayoutTests.cpp|FBuilderLayoutTests|ClassLayoutsPreserveInheritanceInitializersAndOverloads'
		}
		@{
			Id = 'COMPILER-BUILDER-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'module-owned builder success failure reset teardown and rebuild lifecycle'
			Axes = @{
				Operation = @('module_success', 'module_failure', 'standalone_reset')
				Phase = @('before', 'after', 'rebuild')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Diagnostic', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Successful and failed Module::Build paths release their transient builder at the correct phase; standalone Reset clears transient flags/counters without corrupting owned parsers; and same-name rebuild publishes clean executable state.'
			Owner = 'Compiler/AngelscriptNativeBuilderLifecycleTests.cpp|FBuilderLifecycleTests|BuilderLifecycleClearsTransientStateAndRebuilds'
		}
		@{
			Id = 'COMPILER-INTERNAL-COMPILER-LIFECYCLE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'asCCompiler construction reset and destruction ownership'
			Axes = @{
				Scenario = @('construction_defaults', 'reset_transient_state', 'destructor_owned_resources')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Construction initializes the documented compiler pointers, flags, and bytecode container; Reset replaces the active builder/script/function owners and clears diagnostic, label, bytecode, lambda, and external-this transient state; destruction walks nested variable scopes and releases every compiler-owned string constant exactly once.'
			Owner = 'Compiler/AngelscriptNativeCompilerInternalLifecycleTests.cpp|FCompilerInternalLifecycleTests|ConstructionResetAndDestructionOwnTransientState'
		}
		@{
			Id = 'COMPILER-INTERNAL-TEMPLATE-COVARIANCE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'template subtype covariance success and failure classification'
			Axes = @{
				Relation = @('unflagged', 'same_instance', 'different_template_base', 'exact_subtype', 'derived_reference', 'unrelated_reference', 'primitive_mismatch', 'nested_covariant')
				Oracle = @('all_covariant', 'failed_covariance')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Runtime', 'Isolation')
			Expected = 'The two internal covariance classifiers agree on flag and template-base guards, accept exact, derived-reference, and recursively nested compatible subtypes, and distinguish unrelated-reference or primitive subtype failures without treating same-instance or unrelated-template inputs as failed covariance.'
			Owner = 'Compiler/AngelscriptNativeCompilerTemplateCovarianceTests.cpp|FCompilerTemplateCovarianceTests|TemplateSubtypeRelationsReportSuccessAndFailurePrecisely'
		}
		@{
			Id = 'COMPILER-BUILDER-PARSE-STAGE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'multi-section parser-root family and downstream-publication barrier'
			Axes = @{
				SectionCount = @('one', 'two')
				Family = @('namespace', 'class', 'enum', 'function', 'global')
			}
			Classification = 'CurrentFork'
			Evidence = @('Compile', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Each retained section produces its own parser/root and expected AST families, while parse completion alone leaves every type/function/global/module publication table empty until its owning later stage. Every root and transient builder/parser tree is released before exact module discard and null lookup; an independent engine remains free of parsed declarations.'
			Owner = 'Compiler/AngelscriptNativeBuilderParsingTests.cpp|FBuilderParsingTests|ParseStageRetainsRootsAndBlocksDownstreamPublication'
		}
		@{
			Id = 'COMPILER-BUILDER-DECLARATION-COLLISION'
			SourceCatalog = 'native-domains.md'
			Theme = 'Compiler'
			Element = 'builder declaration collision stage atomicity and recovery'
			Axes = @{
				Pair = @('class_class', 'function_function', 'global_global')
				Recovery = @('same_name_replacement')
			}
			Classification = 'RejectByFork'
			Evidence = @('Compile', 'Diagnostic', 'Metadata', 'Cleanup', 'Isolation')
			Expected = 'Every duplicate pair reaches its exact collision stage, reports the owning section/symbol, publishes no downstream partial table, and permits a corrected same-name replacement to build and execute in isolation.'
			Owner = 'Compiler/AngelscriptNativeBuilderTypeTests.cpp|FBuilderTypeTests|DeclarationCollisionsFailAtomicallyAndRecover'
		}
		@{
			Id = 'TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'script-engine primitive type ID reconstruction'
			Axes = @{
				Type = @('void', 'bool', 'int8', 'int16', 'int', 'int64', 'uint8', 'uint16', 'uint', 'uint64', 'float32', 'float64')
			}
			Classification = 'CurrentFork'
			Evidence = @('Runtime', 'Metadata', 'Isolation')
			Expected = 'Every built-in primitive type ID reconstructs the same valid primitive asCDataType in two independent engines with the independent token, canonical current-fork declaration, and exact byte size. Primitive data types are value descriptors and declare no artificial cleanup contract.'
			Owner = 'TypeSystem/AngelscriptNativePrimitiveTypeIdRoundTripTests.cpp|FPrimitiveTypeIdRoundTripTests|PrimitiveIdsPreserveTokenDeclarationAndSize'
		}
		@{
			Id = 'TYPE-OBJECTTYPE-DESTRUCTION-OWNERSHIP'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'object-type internal destruction ownership'
			Axes = @{
				Shape = @('empty', 'list_pattern', 'owned_graph')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Empty and list-pattern object types take their exact detach path, while an owned graph clears its base, subtype, property, and behavior state and releases every retained sentinel exactly once.'
			Owner = 'TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp|FObjectTypeReleaseTests|DestroyInternalClearsEmptyListAndOwnedState'
		}
		@{
			Id = 'TYPE-OBJECTTYPE-FUNCTION-RELEASE'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'object-type function-slot release'
			Axes = @{
				Slot = @('factory', 'constructor', 'method', 'virtual', 'gc')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Each selected factory, constructor, method, virtual, or garbage-collection slot releases exactly its owned function reference, clears its index state, and leaves unrelated engine functions unchanged.'
			Owner = 'TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp|FObjectTypeReleaseTests|ReleaseAllFunctionsClearsEveryOwnedSlotFamily'
		}
		@{
			Id = 'TYPE-OBJECTTYPE-PROPERTY-RELEASE'
			SourceCatalog = 'native-domains.md'
			Theme = 'TypeSystem'
			Element = 'object-type property ownership release'
			Axes = @{
				OwnerKind = @('application', 'script')
				PropertyKind = @('primitive', 'object')
			}
			Classification = 'CurrentFork'
			Evidence = @('Metadata', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'Application and script object types clear primitive and object properties, balance object-type ownership exactly once, and erase all property views and name lookup state.'
			Owner = 'TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp|FObjectTypeReleaseTests|ReleaseAllPropertiesBalancesOwnerAndPropertyKinds'
		}
		@{
			Id = 'RT-SCRIPTFUNCTION-REFERENCE-RELEASE'
			SourceCatalog = 'native-domains.md'
			Theme = 'Runtime'
			Element = 'script-function signature and local type reference release'
			Axes = @{
				ReferenceCategory = @('return', 'parameter', 'template', 'local')
			}
			Classification = 'CurrentFork'
			Evidence = @('Bytecode', 'Lifecycle', 'Cleanup', 'Isolation')
			Expected = 'A bytecode-owning script function releases exactly the reference added for its return, parameter, template subtype, or local object type and restores the independent sentinel baseline.'
			Owner = 'Runtime/AngelscriptNativeScriptFunctionReferenceTests.cpp|FScriptFunctionReferenceTests|SignatureAndLocalReferencesReleaseExactlyOnce'
		}
	)
}
