[CmdletBinding()]
param([string]$RepoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'GenerationInventoryCommon.psm1') -Force
$ChangeRoot = Resolve-GenerationPlanRoot -ScriptRoot $PSScriptRoot
$RepositoryRoot = Resolve-RepositoryRoot -ChangeRoot $ChangeRoot -RepoRoot $RepoRoot

$ManualCatalogPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-manual-bind-source-coverage/inventory/planned-test-sources.csv'
$SdkRegistryPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-native-sdk-comprehensive-coverage/catalogs/generated-source-registry.csv'
$SdkCardinalityPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/product-cardinalities.csv'
$CoveragePath = Join-Path $ChangeRoot 'catalogs/coverage-generation-disposition.csv'
$InlinePath = Join-Path $ChangeRoot 'catalogs/inline-as-generation-disposition.csv'

foreach ($RequiredPath in @($ManualCatalogPath, $SdkRegistryPath, $SdkCardinalityPath, $CoveragePath, $InlinePath))
{
	if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf))
	{
		throw "Required planning input not found: $RequiredPath"
	}
}

function Get-NativeRecipeFamily
{
	param([Parameter(Mandatory = $true)][string]$ProductId, [Parameter(Mandatory = $true)][string]$Theme)

	if ($ProductId -match '(?i)(FAIL|REJECT|INVALID|DIAGNOSTIC|ERROR)') { return 'compile-fail-mutation' }
	if ($ProductId -match '(?i)(DECL|NAMESPACE|ENUM|TYPEDEF|INTERFACE|CLASS|MIXIN)') { return 'declaration-product' }
	if ($ProductId -match '(?i)(FN|FUNCTION|CALL|PARAM|RETURN)') { return 'function-signature-product' }
	if ($ProductId -match '(?i)(OP|EXPR|CONVERSION|CAST|LITERAL|ASSIGN)') { return 'expression-product' }
	if ($ProductId -match '(?i)(TOKEN|LEX|PARSE|FRONTEND|PREPROCESS)') { return 'frontend-token-product' }
	if ($ProductId -match '(?i)(ARRAY|MAP|SET|CONTAINER|DICTIONARY)') { return 'container-element-product' }
	if ($ProductId -match '(?i)(GC|REFCOUNT|OWNERSHIP|RELEASE|DESTRUCT)') { return 'gc-ownership-product' }
	if ($ProductId -match '(?i)(DEBUG|TRACE|LINE|STACK)') { return 'debug-trace-product' }
	if ($ProductId -match '(?i)(SAVE|LOAD|SERIAL|BYTECODE)') { return 'serialization-product' }
	if ($Theme -match '(?i)Compiler') { return 'compiler-stage-product' }
	if ($Theme -match '(?i)Runtime') { return 'runtime-lifecycle-product' }
	if ($Theme -match '(?i)Module') { return 'module-lifecycle-product' }
	if ($Theme -match '(?i)Type') { return 'type-system-product' }
	if ($Theme -match '(?i)(API|Embedding)') { return 'embedding-api-product' }
	return 'statement-control-product'
}

function Get-NativeOracleScope
{
	param(
		[Parameter(Mandatory = $true)][string]$ProductId,
		[Parameter(Mandatory = $true)][string]$Theme,
		[Parameter(Mandatory = $true)][string]$Classification
	)

	$Kinds = [System.Collections.Generic.List[string]]::new()
	$Kinds.Add('compile-status')
	if ($Theme -match '(?i)Declarations') { $Kinds.AddRange([string[]]@('metadata-publication', 'lookup-owner', 'runtime-use', 'cleanup')) }
	elseif ($Theme -match '(?i)Functions') { $Kinds.AddRange([string[]]@('typed-return', 'argument-transfer', 'out-writeback', 'metadata', 'lifecycle')) }
	elseif ($Theme -match '(?i)(Operators|Expressions|Language)') { $Kinds.AddRange([string[]]@('typed-value', 'evaluation-order', 'side-effect-count', 'boundary-result')) }
	elseif ($Theme -match '(?i)Frontend') { $Kinds.AddRange([string[]]@('token-or-ast-shape', 'source-position', 'diagnostic')) }
	elseif ($Theme -match '(?i)Compiler') { $Kinds.AddRange([string[]]@('metadata', 'bytecode-shape', 'runtime-value', 'cleanup', 'isolation')) }
	elseif ($Theme -match '(?i)Runtime') { $Kinds.AddRange([string[]]@('typed-value', 'exception-state', 'lifecycle', 'cleanup')) }
	elseif ($Theme -match '(?i)Module') { $Kinds.AddRange([string[]]@('module-state', 'import-or-binding-state', 'save-load', 'cleanup', 'isolation')) }
	elseif ($Theme -match '(?i)Type') { $Kinds.AddRange([string[]]@('type-id', 'declaration', 'size-or-layout', 'ownership', 'isolation')) }
	else { $Kinds.AddRange([string[]]@('typed-value', 'metadata', 'side-effects', 'cleanup')) }

	if ($Classification -ne 'CurrentFork' -or $ProductId -match '(?i)(FAIL|REJECT|INVALID|DIAGNOSTIC|ERROR)')
	{
		$Kinds.AddRange([string[]]@('exact-diagnostic-anchor', 'atomic-failure', 'same-name-recovery'))
	}
	return (($Kinds | Select-Object -Unique) -join ';')
}

function Get-RandomSlots
{
	param([Parameter(Mandatory = $true)][string]$RecipeFamily)

	switch ($RecipeFamily)
	{
		'expression-product' { 'legal literal choice;boundary representative;identifier spelling;parenthesization;independent declaration order' }
		'function-signature-product' { 'legal literal choice;identifier spelling;independent declaration order;optional legal grouping' }
		'declaration-product' { 'identifier spelling;independent declaration order;optional legal member grouping' }
		'container-element-product' { 'legal element/key/value samples;boundary index/key;identifier spelling;independent setup order' }
		'frontend-token-product' { 'payload identifier/literal only when spelling, spacing, and line-ending are not explicit axes' }
		'compile-fail-mutation' { 'valid-baseline identifiers/literals only;the invalid mutation identity is frozen' }
		default { 'legal literals;identifier spelling;independent declaration order;optional legal grouping where the recipe declares the slot' }
	}
}

function Get-ReleaseShard
{
	param([string]$Origin, [string]$Key)
	$Parts = $Key -split '/'
	$Bucket = if ($Parts.Count -gt 1) { ConvertTo-PlanSlug -Value $Parts[1] } else { 'General' }
	return "Plugins/Angelscript/Source/AngelscriptTest/Generated/TestCode/${Origin}_${Bucket}.gen.cpp"
}

$ManualRows = @(Import-Csv -LiteralPath $ManualCatalogPath)
$AuthoredRows = [System.Collections.Generic.List[object]]::new()
foreach ($Row in $ManualRows)
{
	$RelativeNoExt = ($Row.TargetPath -replace '^TestSource/', '') -replace '\.as$', ''
	$CaseKey = "TestSource/$RelativeNoExt"
	$Symbol = "TS_$((ConvertTo-PlanSlug -Value $Row.TaskId).ToUpperInvariant())"
	$Exists = Test-Path -LiteralPath (Join-Path $RepositoryRoot $Row.TargetPath) -PathType Leaf
	$AuthoredRows.Add([pscustomobject][ordered]@{
		TaskId = "GEN-$($Row.TaskId)"
		CaseKey = $CaseKey
		SourcePath = $Row.TargetPath
		ManualBindTaskId = $Row.TaskId
		BindIds = $Row.BindIds
		SurfaceIds = $Row.SurfaceIds
		ReferenceIds = $Row.ReferenceIds
		SourceShape = $Row.SourceShape
		PlannedSymbols = $Row.PlannedSymbols
		GeneratedCppSymbol = $Symbol
		TestScope = $Row.CoverageScope
		Inputs = $Row.Inputs
		ExpectedObservations = $Row.ExpectedObservations
		ExpectedComments = $Row.CommentFocus
		Harness = $Row.FutureRunner
		Dependencies = $Row.Dependencies
		Status = if ($Exists) { 'AuthoredSourceAvailable' } else { 'WaitingForManualSource' }
	})
}

$SdkRegistry = @(Import-Csv -LiteralPath $SdkRegistryPath)
$SdkCardinalities = @(Import-Csv -LiteralPath $SdkCardinalityPath)
$CardinalityById = @{}
foreach ($Cardinality in $SdkCardinalities) { $CardinalityById[$Cardinality.ProductId] = $Cardinality }

$SdkRows = [System.Collections.Generic.List[object]]::new()
foreach ($Registry in $SdkRegistry)
{
	if (-not $CardinalityById.ContainsKey($Registry.ProductId))
	{
		throw "SDK generated product missing cardinality: $($Registry.ProductId)"
	}
	$Cardinality = $CardinalityById[$Registry.ProductId]
	$Recipe = Get-NativeRecipeFamily -ProductId $Registry.ProductId -Theme $Cardinality.Theme
	$IsNegative = $Cardinality.Classification -ne 'CurrentFork' -or $Registry.ProductId -match '(?i)(FAIL|REJECT|INVALID|DIAGNOSTIC|ERROR)'
	$SdkRows.Add([pscustomobject][ordered]@{
		TaskId = "GEN-SDK-$($Registry.ProductId)"
		ProductId = $Registry.ProductId
		LegacyFile = "Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/$($Registry.File)"
		LegacyClass = $Registry.Class
		LegacyMethod = $Registry.Method
		LegacyGenerator = $Registry.Generator
		Theme = $Cardinality.Theme
		Axes = $Cardinality.Axes
		ExpandedCells = [int]$Cardinality.ExpandedCells
		Classification = $Cardinality.Classification
		Evidence = "Owner=$($Cardinality.Owner); Formatting=$($Registry.FormattingContract); Catalog=$($Cardinality.SourceCatalog)"
		RecipeFamily = $Recipe
		GeneratedCppSymbol = "NS_$((ConvertTo-PlanSlug -Value $Registry.ProductId).ToUpperInvariant())"
		GeneratedAsScope = "Re-express $($Registry.Generator) as a declarative $Recipe rule for $($Registry.Method). $($Registry.Reason)"
		OracleScope = Get-NativeOracleScope -ProductId $Registry.ProductId -Theme $Cardinality.Theme -Classification $Cardinality.Classification
		FixedInputs = "Enumerate all explicit product axes exactly: $($Cardinality.Axes)"
		RandomSlots = Get-RandomSlots -RecipeFamily $Recipe
		Constraints = "All $($Cardinality.ExpandedCells) explicit cells remain mandatory; seed variation may change only declared legal slots and never cell membership or oracle meaning. Preserve $($Registry.FormattingContract)."
		NegativeMutation = if ($IsNegative) { 'Start from one valid baseline and apply exactly one named invalid mutation per negative cell; keep the diagnostic anchor frozen.' } else { 'None; this product is not converted into a negative test by random choice.' }
		RecoverySource = if ($IsNegative) { 'Emit a separately named corrected source when the current product observes cleanup, atomicity, isolation, or same-name recovery.' } else { 'Emit only when the existing product explicitly observes rebuild, reset, cleanup, or isolation.' }
		CommentKnowledge = "Explain the $($Cardinality.Theme) feature, the selected axis cell, concrete input values, and the exact typed/diagnostic/lifecycle observations. Wording remains case-specific."
		References = "$($Registry.File)|$($Registry.Class)|$($Registry.Method); openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/product-cardinalities.csv; openspec/changes/test-as-native-sdk-comprehensive-coverage/catalogs/generated-source-registry.csv"
		RuleStatus = 'PlannedNoReplacement'
	})
}

$RecipeRows = @(
	[pscustomobject][ordered]@{ RecipeId='authored-source-export'; Owner='TestSource/Generation/Rules/Authored'; InputSchema='CaseKey + authored .as path + comment/observation metadata'; ExplicitAxes='one authored fixture per CaseKey'; RandomSlots='none by default'; Emits='source + canonical manifest + typed oracle metadata'; OracleKinds='authored exact observations'; NegativePolicy='preserve authored negative and recovery units'; CommentPolicy='knowledge comments explain feature, inputs, expectations, and important boundary'; PrimaryReferences='planned-test-sources.csv'; InitialConsumers='614 manual-bind TestSource fixtures' },
	[pscustomobject][ordered]@{ RecipeId='declaration-product'; Owner='TestSource/Generation/Rules/NativeSDK'; InputSchema='declaration kind/scope/order/member/specifier matrix'; ExplicitAxes='all declared declaration cells'; RandomSlots='identifier + independent declaration order + legal grouping'; Emits='declaration source units + manifest'; OracleKinds='compile + metadata + lookup + runtime + diagnostic + cleanup'; NegativePolicy='single invalid declaration mutation'; CommentPolicy='explain publication owner and legal/illegal contract'; PrimaryReferences='Native SDK generated registry and cardinalities'; InitialConsumers='SDK declaration products and Coverage definition candidates' },
	[pscustomobject][ordered]@{ RecipeId='function-signature-product'; Owner='TestSource/Generation/Rules/NativeSDK'; InputSchema='return/parameter/direction/position/arity/call form'; ExplicitAxes='all signature and transfer cells'; RandomSlots='legal literals + identifiers + independent declaration order'; Emits='functions/calls + manifest + typed writeback oracle'; OracleKinds='compile + typed return + transfer + writeback + metadata + lifecycle'; NegativePolicy='one illegal signature or call mutation'; CommentPolicy='explain slot sentinels and expected transfer'; PrimaryReferences='Native SDK function products'; InitialConsumers='SDK function and Coverage function-mode products' },
	[pscustomobject][ordered]@{ RecipeId='expression-product'; Owner='TestSource/Generation/Rules/Expressions'; InputSchema='type/operator/operand/boundary/evaluation form'; ExplicitAxes='all operator/type/shape cells'; RandomSlots='legal literals + boundary representative + identifiers + parentheses'; Emits='expression functions + typed oracle'; OracleKinds='typed value + evaluation order + side-effect count + boundary result'; NegativePolicy='one unsupported operator/type mutation'; CommentPolicy='explain operands, operation, exact result, and side effects'; PrimaryReferences='Coverage expression/function files and SDK expression products'; InitialConsumers='Coverage and Native SDK expression cases' },
	[pscustomobject][ordered]@{ RecipeId='statement-control-product'; Owner='TestSource/Generation/Rules/Language'; InputSchema='statement/control-flow shape + values + exit path'; ExplicitAxes='declared statement and transfer cells'; RandomSlots='legal literals + identifiers + independent blocks'; Emits='function bodies + trace oracle'; OracleKinds='typed value + trace + cleanup + control transfer'; NegativePolicy='single invalid statement mutation when specified'; CommentPolicy='explain path, input state, expected trace and result'; PrimaryReferences='Native SDK language products'; InitialConsumers='unclassified language product rules' },
	[pscustomobject][ordered]@{ RecipeId='ue-definition-product'; Owner='TestSource/Generation/Rules/Definitions'; InputSchema='UCLASS/USTRUCT/UENUM/UINTERFACE kind + specifiers + members + order'; ExplicitAxes='all supported definition cells'; RandomSlots='legal names + independent member order + legal default values'; Emits='UE annotated AS definitions + metadata oracle'; OracleKinds='compile + generated UType metadata + defaults + invocation'; NegativePolicy='single invalid specifier/member mutation'; CommentPolicy='explain generated UE surface and expected reflected shape'; PrimaryReferences='Coverage definition tests'; InitialConsumers='Coverage definition candidates' },
	[pscustomobject][ordered]@{ RecipeId='uclass-property-family'; Owner='TestSource/Generation/Rules/Definitions'; InputSchema='property type/declaration/default/read-write/metadata'; ExplicitAxes='all property family cells'; RandomSlots='legal default + identifier + independent member order'; Emits='UCLASS source + property oracle'; OracleKinds='compile + metadata + default + read/write + return value'; NegativePolicy='one illegal property declaration mutation'; CommentPolicy='explain property contract and exact state transitions'; PrimaryReferences='Coverage property tests'; InitialConsumers='Coverage property candidates' },
	[pscustomobject][ordered]@{ RecipeId='ufunction-signature-product'; Owner='TestSource/Generation/Rules/Definitions'; InputSchema='return/parameter/direction/position/arity/specifier/call form'; ExplicitAxes='all reflected signature cells'; RandomSlots='legal literals + identifiers + independent declaration order'; Emits='UFUNCTION source + metadata/call oracle'; OracleKinds='compile + metadata + invocation + return + writeback'; NegativePolicy='one unsupported signature mutation'; CommentPolicy='explain reflected signature and exact call observations'; PrimaryReferences='Coverage UFunction tests'; InitialConsumers='Coverage UFunction candidates' },
	[pscustomobject][ordered]@{ RecipeId='container-element-product'; Owner='TestSource/Generation/Rules/Containers'; InputSchema='container/type/operation/state/boundary'; ExplicitAxes='all container element/key/value cells'; RandomSlots='legal values + boundary index/key + identifiers'; Emits='container program + typed collection oracle'; OracleKinds='return + size + ordering + element/key/value + mutation state'; NegativePolicy='one invalid element/key/value operation'; CommentPolicy='explain starting collection, operation, and exact final state'; PrimaryReferences='Coverage and SDK container cases'; InitialConsumers='container product candidates' },
	[pscustomobject][ordered]@{ RecipeId='compile-fail-mutation'; Owner='TestSource/Generation/Rules/Negative'; InputSchema='valid baseline + named mutation + diagnostic anchor + optional recovery'; ExplicitAxes='all named invalid forms'; RandomSlots='baseline identifiers/literals only'; Emits='invalid source + diagnostic oracle + corrected source'; OracleKinds='compile failure + diagnostic + atomicity + cleanup + recovery'; NegativePolicy='exactly one mutation from a valid baseline'; CommentPolicy='explain why the one mutation is invalid and expected recovery'; PrimaryReferences='SDK rejection products and existing negative tests'; InitialConsumers='negative candidates' },
	[pscustomobject][ordered]@{ RecipeId='frontend-token-product'; Owner='TestSource/Generation/Rules/Frontend'; InputSchema='token/spelling/spacing/line-ending/source-position'; ExplicitAxes='all lexical/parser cells'; RandomSlots='payload only outside explicit lexical axes'; Emits='source sections + token/AST/diagnostic oracle'; OracleKinds='token + AST + source position + diagnostic'; NegativePolicy='one malformed lexical/parser mutation'; CommentPolicy='explain exact spelling and expected frontend observation'; PrimaryReferences='Native SDK Frontend products'; InitialConsumers='frontend products' },
	[pscustomobject][ordered]@{ RecipeId='compiler-stage-product'; Owner='TestSource/Generation/Rules/Compiler'; InputSchema='source shape/stage/mode/publication state'; ExplicitAxes='all compiler stage cells'; RandomSlots='legal names/literals and independent declarations'; Emits='source + compiler metadata/bytecode oracle'; OracleKinds='compile + metadata + bytecode + runtime + cleanup + isolation'; NegativePolicy='one stage-owned invalid mutation with recovery'; CommentPolicy='explain stage boundary and exact published/non-published state'; PrimaryReferences='Native SDK Compiler products'; InitialConsumers='compiler products' },
	[pscustomobject][ordered]@{ RecipeId='runtime-lifecycle-product'; Owner='TestSource/Generation/Rules/Runtime'; InputSchema='runtime operation/path/value/lifecycle state'; ExplicitAxes='all runtime path cells'; RandomSlots='legal values + identifiers + independent setup'; Emits='runtime source + typed/lifecycle oracle'; OracleKinds='return + exception + lifecycle + cleanup + isolation'; NegativePolicy='one runtime failure trigger when explicitly modeled'; CommentPolicy='explain state before/after and exact cleanup'; PrimaryReferences='Native SDK Runtime products'; InitialConsumers='runtime products' },
	[pscustomobject][ordered]@{ RecipeId='module-lifecycle-product'; Owner='TestSource/Generation/Rules/Module'; InputSchema='module operation/order/import/save-load/rebuild'; ExplicitAxes='all module state cells'; RandomSlots='module/symbol names + independent section order'; Emits='multi-section source + module-state oracle'; OracleKinds='module state + import/bind + save-load + cleanup + isolation'; NegativePolicy='one invalid bind/build/load mutation with clean recovery'; CommentPolicy='explain ownership, phase, and post-operation state'; PrimaryReferences='Native SDK Module products'; InitialConsumers='module products' },
	[pscustomobject][ordered]@{ RecipeId='type-system-product'; Owner='TestSource/Generation/Rules/TypeSystem'; InputSchema='type/category/qualifier/storage/relationship'; ExplicitAxes='all type system cells'; RandomSlots='legal type/symbol names + independent declarations'; Emits='type declarations/uses + type oracle'; OracleKinds='type id + declaration + size/layout + ownership + isolation'; NegativePolicy='one incompatible type relation'; CommentPolicy='explain type relation and exact metadata/runtime observation'; PrimaryReferences='Native SDK TypeSystem products'; InitialConsumers='type products' },
	[pscustomobject][ordered]@{ RecipeId='embedding-api-product'; Owner='TestSource/Generation/Rules/Embedding'; InputSchema='API operation/object state/input/result path'; ExplicitAxes='all embedding API cells'; RandomSlots='legal names/values when not API identity'; Emits='support source + API oracle metadata'; OracleKinds='status + returned object/value + side effects + cleanup'; NegativePolicy='one invalid API state/argument'; CommentPolicy='explain API precondition and exact result'; PrimaryReferences='Native SDK Embedding/API products'; InitialConsumers='embedding products' },
	[pscustomobject][ordered]@{ RecipeId='debug-trace-product'; Owner='TestSource/Generation/Rules/Debugging'; InputSchema='source shape/frame/line/event/path'; ExplicitAxes='all debug/trace cells'; RandomSlots='identifiers and inert literals only'; Emits='source + line/frame/trace oracle'; OracleKinds='line + frame + scope + event order + cleanup'; NegativePolicy='only explicit debug failure products'; CommentPolicy='explain expected event sequence and source positions'; PrimaryReferences='Native SDK debug products'; InitialConsumers='debug products' },
	[pscustomobject][ordered]@{ RecipeId='serialization-product'; Owner='TestSource/Generation/Rules/Serialization'; InputSchema='source shape/save-load mode/version/state'; ExplicitAxes='all serialization cells'; RandomSlots='legal names/literals captured in manifest'; Emits='source + serialization/reload oracle'; OracleKinds='byte identity + load result + runtime value + cleanup'; NegativePolicy='one corrupted/incompatible input when explicitly modeled'; CommentPolicy='explain persisted state and post-load expectation'; PrimaryReferences='Native SDK save/load products'; InitialConsumers='serialization products' },
	[pscustomobject][ordered]@{ RecipeId='gc-ownership-product'; Owner='TestSource/Generation/Rules/Runtime'; InputSchema='reference category/owner/path/cleanup phase'; ExplicitAxes='all ownership/lifecycle cells'; RandomSlots='identifiers and independent allocation order'; Emits='ownership source + counter/cleanup oracle'; OracleKinds='reference count + lifecycle + cleanup + isolation'; NegativePolicy='one ownership violation only when current product expects it'; CommentPolicy='explain owner, retained edge, and exact release count'; PrimaryReferences='Native SDK GC/ownership products'; InitialConsumers='ownership products' },
	[pscustomobject][ordered]@{ RecipeId='namespace-publication-product'; Owner='TestSource/Generation/Rules/Language'; InputSchema='namespace relation/order/symbol family/lookup'; ExplicitAxes='all namespace publication cells'; RandomSlots='legal namespace/symbol names + independent order'; Emits='namespace source + publication oracle'; OracleKinds='compile + owner + lookup + collision + runtime'; NegativePolicy='one same-owner collision mutation'; CommentPolicy='explain namespace relation and lookup result'; PrimaryReferences='Native SDK namespace products'; InitialConsumers='namespace products' },
	[pscustomobject][ordered]@{ RecipeId='preprocessor-product'; Owner='TestSource/Generation/Rules/Preprocessor'; InputSchema='directive/include/define/branch/path/source-position'; ExplicitAxes='all preprocessor cells'; RandomSlots='macro/payload identifiers outside explicit axes'; Emits='multi-file source bundle + preprocessing oracle'; OracleKinds='expanded source + diagnostic + source mapping + compile'; NegativePolicy='one invalid directive/include mutation'; CommentPolicy='explain input files/directives and exact expansion'; PrimaryReferences='existing Preprocessor inline AS'; InitialConsumers='future promoted preprocessor products' },
	[pscustomobject][ordered]@{ RecipeId='authored-host-scenario'; Owner='existing C++ test fixture'; InputSchema='authored source + UE fixture contract'; ExplicitAxes='none inferred'; RandomSlots='none'; Emits='no generated source until explicit promotion'; OracleKinds='existing host-specific observations'; NegativePolicy='preserve authored source'; CommentPolicy='knowledge comments remain scenario-specific'; PrimaryReferences='inline-as-generation-disposition.csv'; InitialConsumers='specialized scenarios only' }
)

$CoverageRows = @(Import-Csv -LiteralPath $CoveragePath)
$InlineRows = @(Import-Csv -LiteralPath $InlinePath)

Write-PlanCsv -Rows $AuthoredRows.ToArray() -Path (Join-Path $ChangeRoot 'catalogs/authored-testsource-static-functions.csv')
Write-PlanCsv -Rows $SdkRows.ToArray() -Path (Join-Path $ChangeRoot 'catalogs/sdk-generated-product-rules.csv')
Write-PlanCsv -Rows $RecipeRows -Path (Join-Path $ChangeRoot 'catalogs/recipe-family-registry.csv')

$StaticRows = [System.Collections.Generic.List[object]]::new()
foreach ($Row in $AuthoredRows)
{
	$StaticRows.Add([pscustomobject][ordered]@{
		CaseKey=$Row.CaseKey; CppSymbol=$Row.GeneratedCppSymbol; Origin='Authored'; RecipeId='authored-source-export'; SourcePath=$Row.SourcePath; ProductId='<none>'; RequestAxes='authored fixture'; DefaultSeed='0'; ReturnType='FAngelscriptGeneratedCase'; ReleaseShard=(Get-ReleaseShard -Origin 'Authored' -Key $Row.CaseKey); References="$($Row.ManualBindTaskId);$($Row.ReferenceIds)"
	})
}
foreach ($Row in $SdkRows)
{
	$CaseKey = "NativeSDK/$($Row.ProductId)"
	$StaticRows.Add([pscustomobject][ordered]@{
		CaseKey=$CaseKey; CppSymbol=$Row.GeneratedCppSymbol; Origin='NativeSDK'; RecipeId=$Row.RecipeFamily; SourcePath='<generated in memory>'; ProductId=$Row.ProductId; RequestAxes=$Row.Axes; DefaultSeed='0'; ReturnType='FAngelscriptGeneratedCase'; ReleaseShard=(Get-ReleaseShard -Origin 'NativeSDK' -Key "NativeSDK/$($Row.Theme)"); References=$Row.References
	})
}
foreach ($Row in ($CoverageRows | Where-Object Disposition -eq 'GeneratedRecipe'))
{
	$Symbol = "CV_$((ConvertTo-PlanSlug -Value $Row.DispositionId).ToUpperInvariant())_$((ConvertTo-PlanSlug -Value $Row.Method).ToUpperInvariant())"
	$StaticRows.Add([pscustomobject][ordered]@{
		CaseKey=$Row.FutureCaseKey; CppSymbol=$Symbol; Origin='Coverage'; RecipeId=$Row.CandidateRecipe; SourcePath='<generated in memory>'; ProductId=$Row.DispositionId; RequestAxes=$Row.ProductAxes; DefaultSeed='0'; ReturnType='FAngelscriptGeneratedCase'; ReleaseShard=(Get-ReleaseShard -Origin 'Coverage' -Key "Coverage/$($Row.Domain)"); References="$($Row.File):$($Row.Line)"
	})
}
foreach ($Row in ($InlineRows | Where-Object { $_.Disposition -eq 'GeneratedRecipe' -and $_.File -notmatch '/Coverage/' }))
{
	$StaticRows.Add([pscustomobject][ordered]@{
		CaseKey=$Row.FutureCaseKey; CppSymbol="IN_$($Row.InlineId.Replace('-', '_'))"; Origin='InlineCandidate'; RecipeId=$Row.RecipeFamily; SourcePath='<generated in memory>'; ProductId=$Row.InlineId; RequestAxes='axes must be confirmed by the disposition-review task'; DefaultSeed='0'; ReturnType='FAngelscriptGeneratedCase'; ReleaseShard=(Get-ReleaseShard -Origin 'Inline' -Key $Row.FutureCaseKey); References=$Row.References
	})
}
Write-PlanCsv -Rows $StaticRows.ToArray() -Path (Join-Path $ChangeRoot 'catalogs/static-function-registry.csv')

$TaskText = [System.Text.StringBuilder]::new()
[void]$TaskText.AppendLine('# Implementation Tasks')
[void]$TaskText.AppendLine()
[void]$TaskText.AppendLine('This is an execution-ready plan. Every task is future work; this OpenSpec creation pass does not modify `TestSource`, `Tools/AngelscriptCodeGen`, existing tests, or plugin release code. A task may be checked only after its listed tests and verification command pass. Legacy builders remain authoritative throughout this change.')
[void]$TaskText.AppendLine()

function Add-Task
{
	param(
		[string]$Id, [string]$Title, [string]$Files, [string]$Reference, [string]$AsScope,
		[string]$Axes, [string]$Oracle, [string]$RandomFrozen, [string]$Impact,
		[string]$Tests, [string]$Verify, [string]$Requirement, [string]$Dependencies
	)
	[void]$TaskText.AppendLine("- [ ] $Id $Title")
	[void]$TaskText.AppendLine("  - Files: $Files")
	[void]$TaskText.AppendLine("  - Reference: $Reference")
	[void]$TaskText.AppendLine("  - AS Scope: $AsScope")
	[void]$TaskText.AppendLine("  - Axes: $Axes")
	[void]$TaskText.AppendLine("  - Oracle: $Oracle")
	[void]$TaskText.AppendLine("  - Random/Frozen: $RandomFrozen")
	[void]$TaskText.AppendLine("  - Impact: $Impact")
	[void]$TaskText.AppendLine("  - Tests: $Tests")
	[void]$TaskText.AppendLine("  - Verify: $Verify")
	[void]$TaskText.AppendLine("  - Requirement: $Requirement")
	[void]$TaskText.AppendLine("  - Dependencies: $Dependencies")
	[void]$TaskText.AppendLine()
}

[void]$TaskText.AppendLine('## 1. Shared contract, deterministic engine, and release boundary')
[void]$TaskText.AppendLine()
$FoundationTasks = @(
	@('1.1','Write failing schema tests for generation requests and results','Tools/AngelscriptCodeGen/tests/test_generation_schema.py; Tools/AngelscriptCodeGen/cpp/tests/GenerationSchemaTests.cpp','design.md; specs/as-test-source-generation-rules/spec.md','Validate CaseKey, recipe, explicit axes, seed, source bundle, canonical manifest, typed oracle, comments, and references.','schema versions and every required field','invalid inputs fail with the same stable error code in Python and C++','all values frozen','adds tests only','Yes; Python and portable C++ negative/positive schema tests','python -m pytest Tools/AngelscriptCodeGen/tests/test_generation_schema.py -q','Shared language-neutral generation contract','none'),
	@('1.2','Implement the versioned language-neutral generation schema','TestSource/Generation/schema/generation-request-v1.json; TestSource/Generation/schema/generation-result-v1.json; Tools/AngelscriptCodeGen/src/angelscript_codegen/model/generation_schema.py; Tools/AngelscriptCodeGen/cpp/include/AngelscriptCodeGen/GenerationSchema.h','task 1.1; design.md','Represent complete generated cases without UE types in the shared rule layer.','schema fields; oracle variants; source bundle entries','round-trip every typed oracle and reject unknown required versions','no random behavior in schema parsing','adds shared schema and independent Python/C++ readers; no plugin change','Yes; make task 1.1 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_generation_schema.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter GenerationSchema','Shared language-neutral generation contract','1.1'),
	@('1.3','Write failing canonical source and manifest serialization tests','Tools/AngelscriptCodeGen/tests/test_canonical_serialization.py; Tools/AngelscriptCodeGen/cpp/tests/CanonicalSerializationTests.cpp','design.md Canonical output','Exercise UTF-8 source bundles and canonical JSON manifests.','LF/CRLF input; BOM/no BOM; key ordering; escaping; terminal newline','byte-identical source and manifest bytes','fixtures frozen','tests only','Yes; cross-language byte fixtures','python -m pytest Tools/AngelscriptCodeGen/tests/test_canonical_serialization.py -q','Canonical output and parity','1.2'),
	@('1.4','Implement canonical source and manifest serialization independently in Python and C++','Tools/AngelscriptCodeGen/src/angelscript_codegen/output/canonical.py; Tools/AngelscriptCodeGen/cpp/src/CanonicalOutput.cpp','task 1.3','Emit UTF-8 without BOM, LF line endings, and exactly one trailing newline; emit fixed-order compact canonical JSON.','all serialization axes from task 1.3','Python bytes equal C++ bytes and checked-in goldens','serialization is frozen and seed-independent','adds two independent implementations','Yes; make task 1.3 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_canonical_serialization.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter CanonicalSerialization','Canonical output and parity','1.3'),
	@('1.5','Write failing CaseKey and symbol derivation tests','Tools/AngelscriptCodeGen/tests/test_case_keys.py; Tools/AngelscriptCodeGen/cpp/tests/CaseKeyTests.cpp','catalogs/static-function-registry.csv','Cover authored paths, SDK product IDs, Coverage methods, punctuation, Unicode input, and collision cases.','origin; logical path; product ID; method ordinal','stable CaseKey, UTF-8 FNV-1a hash, collision rejection, valid C++ symbol','all vectors frozen','tests only','Yes; shared golden vectors','python -m pytest Tools/AngelscriptCodeGen/tests/test_case_keys.py -q','Stable identity and release symbols','1.2'),
	@('1.6','Implement CaseKey validation, UTF-8 FNV-1a hashing, and C++ symbol derivation','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/case_key.py; Tools/AngelscriptCodeGen/cpp/src/CaseKey.cpp','task 1.5','Create stable logical identities without using absolute paths, platform separators, or process hash functions.','all identity axes from task 1.5','same key/hash/symbol in both implementations','identity is frozen and seed-independent','adds independent implementations','Yes; make task 1.5 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_case_keys.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter CaseKey','Stable identity and release symbols','1.5'),
	@('1.7','Write failing portable random algorithm vectors','Tools/AngelscriptCodeGen/tests/test_splitmix64.py; Tools/AngelscriptCodeGen/cpp/tests/SplitMix64Tests.cpp; TestSource/Generation/goldens/splitmix64-v1.json','design.md Controlled randomness','Cover state transitions, bounded draws, rejection sampling, deterministic Fisher-Yates, and slot substreams.','zero/max seeds; power-of-two/non-power bounds; empty/single/many shuffles','exact unsigned 64-bit vectors and no modulo bias','algorithm/version/vectors frozen','tests only','Yes; Python and C++ consume the same vectors','python -m pytest Tools/AngelscriptCodeGen/tests/test_splitmix64.py -q','Controlled deterministic randomness','1.2'),
	@('1.8','Implement SplitMix64-v1, rejection sampling, Fisher-Yates, and named substreams in Python','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/splitmix64.py','task 1.7','Provide deterministic random slots without random.Random.','all task 1.7 vectors','Python vectors exact','seed varies only declared slots; matrix membership frozen','replaces observable RNG only after parity coverage exists','Yes; Python vectors','python -m pytest Tools/AngelscriptCodeGen/tests/test_splitmix64.py -q','Controlled deterministic randomness','1.7'),
	@('1.9','Implement SplitMix64-v1, rejection sampling, Fisher-Yates, and named substreams in portable C++','Tools/AngelscriptCodeGen/cpp/include/AngelscriptCodeGen/SplitMix64.h; Tools/AngelscriptCodeGen/cpp/src/SplitMix64.cpp','tasks 1.7-1.8','Mirror the specified algorithm without std::random or UE random facilities.','all task 1.7 vectors','C++ vectors and Python parity exact','seed varies only declared slots; matrix membership frozen','adds independent portable implementation','Yes; C++ vectors and parity','powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter SplitMix64','Controlled deterministic randomness','1.7,1.8'),
	@('1.10','Write failing typed-oracle and negative-mutation contract tests','Tools/AngelscriptCodeGen/tests/test_oracles.py; Tools/AngelscriptCodeGen/tests/test_negative_mutations.py; Tools/AngelscriptCodeGen/cpp/tests/OracleAndMutationTests.cpp','design.md Oracle model and Negative generation','Cover integer widths, unsigned values, float bits/tolerance, strings/names/text, math values, object identity, writeback, metadata, bytecode, trace, lifecycle, exception, cleanup, isolation, save-load, diagnostic, and recovery.','oracle kind; comparison mode; negative baseline/mutation/recovery','lossless round-trip and exactly one named invalid mutation','oracle meaning and mutation identity frozen','tests only','Yes; schema/parity/one-mutation tests','python -m pytest Tools/AngelscriptCodeGen/tests/test_oracles.py Tools/AngelscriptCodeGen/tests/test_negative_mutations.py -q','Deep typed observations and valid-baseline negative generation','1.2,1.4'),
	@('1.11','Implement typed-oracle serialization and valid-baseline negative mutation contracts','Tools/AngelscriptCodeGen/src/angelscript_codegen/model/oracle.py; Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/mutations.py; Tools/AngelscriptCodeGen/cpp/include/AngelscriptCodeGen/Oracle.h; Tools/AngelscriptCodeGen/cpp/src/Oracle.cpp','task 1.10','Carry complete expected observations instead of assuming int returns; keep negative generation structural.','all oracle/mutation axes','byte parity and one mutation per invalid case','only legal baseline decorations vary; mutation and diagnostic anchor frozen','adds independent model implementations','Yes; make task 1.10 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_oracles.py Tools/AngelscriptCodeGen/tests/test_negative_mutations.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter Oracle','Deep typed observations and valid-baseline negative generation','1.10'),
	@('1.12','Write failing recipe-schema and exhaustive-matrix tests','Tools/AngelscriptCodeGen/tests/test_recipe_schema.py; Tools/AngelscriptCodeGen/cpp/tests/RecipeSchemaTests.cpp','catalogs/recipe-family-registry.csv','Validate recipe IDs, explicit axes, constraints, random slots, emitters, oracle kinds, negative policy, comments, and references.','all recipe-family registry rows','every explicit Cartesian cell emitted exactly once for every seed','axis membership frozen; only declared slots random','tests only','Yes; registry completeness and matrix cardinality','python -m pytest Tools/AngelscriptCodeGen/tests/test_recipe_schema.py -q','Declarative recipe families and exhaustive axes','1.2,1.7,1.10'),
	@('1.13','Implement recipe schema loading and exhaustive matrix enumeration independently','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/recipes.py; Tools/AngelscriptCodeGen/cpp/include/AngelscriptCodeGen/Recipe.h; Tools/AngelscriptCodeGen/cpp/src/Recipe.cpp; TestSource/Generation/schema/recipe-v1.json','task 1.12','Load reviewed rule data and enumerate all explicit cells before applying per-cell random slots.','registry recipes and matrix axes','cardinality, CaseKey, manifest, and order parity','explicit matrix frozen; random slots isolated per CaseKey/cell/slot','adds independent engines over shared data','Yes; make task 1.12 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_recipe_schema.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter RecipeSchema','Declarative recipe families and exhaustive axes','1.12'),
	@('1.14','Write failing knowledge-comment contract tests','Tools/AngelscriptCodeGen/tests/test_knowledge_comments.py; Tools/AngelscriptCodeGen/cpp/tests/KnowledgeCommentTests.cpp','design.md Knowledge comments; user requirement','Check that emitted source explains feature, concrete inputs, exact observations, and an important boundary when applicable without enforcing prose wording.','positive/negative/recovery; definition/function/expression/container recipes','semantic fields present and comments attached to the correct source unit/function','facts frozen; wording may vary only from reviewed fragments','tests only','Yes; semantic presence tests, no rigid sentence snapshots','python -m pytest Tools/AngelscriptCodeGen/tests/test_knowledge_comments.py -q','Knowledge-like AS comments without rigid prose templates','1.13'),
	@('1.15','Implement structured comment facts and recipe-specific comment rendering','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/comments.py; Tools/AngelscriptCodeGen/cpp/src/Comments.cpp; TestSource/Generation/schema/comment-facts-v1.json','task 1.14','Render sufficient AS comments from structured facts while permitting recipe-specific organization.','feature; inputs; expectations; boundaries; reference','comments remain truthful for every cell and negative/recovery unit','facts frozen; optional phrasing/order may be a declared random slot','adds independent renderers','Yes; make task 1.14 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_knowledge_comments.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter KnowledgeComments','Knowledge-like AS comments without rigid prose templates','1.14'),
	@('1.16','Write failing generic definition and executable-body generator tests','Tools/AngelscriptCodeGen/tests/test_definition_generation.py; Tools/AngelscriptCodeGen/tests/test_executable_generation.py; Tools/AngelscriptCodeGen/cpp/tests/DefinitionAndExecutableGenerationTests.cpp','research/coverage-generation.md; catalogs/recipe-family-registry.csv','Cover UCLASS/USTRUCT/UENUM/UINTERFACE, properties, UFUNCTION signatures, functions, expressions, statements, containers, negatives, recovery, and comments.','definition/signature/expression/statement/container axes','complete source plus typed/metadata/diagnostic oracle; return values explicitly consumed','matrix frozen; legal literals/names/order/grouping random','tests only','Yes; small golden representatives for every family','python -m pytest Tools/AngelscriptCodeGen/tests/test_definition_generation.py Tools/AngelscriptCodeGen/tests/test_executable_generation.py -q','Generation beyond shallow definitions and int returns','1.13,1.15'),
	@('1.17','Implement Python emitters for all initial recipe families','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/definitions.py; Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/functions.py; Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/expressions.py; Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/statements.py; Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/containers.py','task 1.16','Generate complete reviewed AS source units and complete oracle manifests.','all initial recipe families','Python goldens exact and all return/writeback/metadata observations populated','only declared legal slots random','extends current tool behind versioned rule entry points','Yes; Python family tests','python -m pytest Tools/AngelscriptCodeGen/tests/test_definition_generation.py Tools/AngelscriptCodeGen/tests/test_executable_generation.py -q','Generation beyond shallow definitions and int returns','1.16'),
	@('1.18','Implement portable C++ emitters for all initial recipe families independently','Tools/AngelscriptCodeGen/cpp/src/Definitions.cpp; Tools/AngelscriptCodeGen/cpp/src/Functions.cpp; Tools/AngelscriptCodeGen/cpp/src/Expressions.cpp; Tools/AngelscriptCodeGen/cpp/src/Statements.cpp; Tools/AngelscriptCodeGen/cpp/src/Containers.cpp','tasks 1.16-1.17','Implement the same specification without invoking Python or sharing implementation code.','all initial recipe families','C++ source/manifest bytes equal Python for goldens and seed sweep','only declared legal slots random','adds portable C++ implementation','Yes; C++ family tests and parity','powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter InitialRecipes','Generation beyond shallow definitions and int returns','1.16,1.17'),
	@('1.19','Write failing cross-language parity, determinism, and seed-sweep tests','Tools/AngelscriptCodeGen/tests/test_cpp_parity.py; Tools/AngelscriptCodeGen/cpp/tests/ParityDriver.cpp; TestSource/Generation/goldens/representative-cases.json','design.md Python and portable C++ parity','Compare every recipe family, boundary seed, multiple ordinary seeds, invalid case, recovery, source bytes, manifest bytes, CaseKeys, and enumeration order.','recipe;cell;seed;output kind','byte-identical Python/C++ outputs and repeated-run determinism','seed explicit; goldens frozen','tests only','Yes; cross-process parity and determinism','python -m pytest Tools/AngelscriptCodeGen/tests/test_cpp_parity.py -q','Independent implementations with byte parity','1.4,1.9,1.11,1.13,1.15,1.17,1.18'),
	@('1.20','Implement the portable C++ build and parity runner','Tools/AngelscriptCodeGen/CMakeLists.txt; Tools/AngelscriptCodeGen/cpp/CMakeLists.txt; Tools/AngelscriptCodeGen/RunParityTests.ps1; Tools/AngelscriptCodeGen/src/angelscript_codegen/parity.py','task 1.19','Build a standard-C++ generator/driver and compare canonical outputs without Unreal Engine.','all parity axes','one command proves schema/vector/golden/seed parity','requested seed frozen per invocation','adds tool build/validation entry points','Yes; make task 1.19 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_cpp_parity.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1','Independent implementations with byte parity','1.19'),
	@('1.21','Write failing in-memory/default-output and explicit-write tests','Tools/AngelscriptCodeGen/tests/test_output_policy.py; Tools/AngelscriptCodeGen/cpp/tests/OutputPolicyTests.cpp','design.md Output ownership','Prove generation returns memory objects by default and writes only through explicit Saved/temp/golden/release modes.','memory;Saved;temp;golden;release;invalid repository path','no accidental generated AS files in TestSource or plugin','paths and modes frozen; content seed explicit','tests only','Yes; filesystem boundary tests','python -m pytest Tools/AngelscriptCodeGen/tests/test_output_policy.py -q','In-memory default and explicit output ownership','1.4,1.20'),
	@('1.22','Implement explicit output policies for Python and C++','Tools/AngelscriptCodeGen/src/angelscript_codegen/output/policy.py; Tools/AngelscriptCodeGen/cpp/src/OutputPolicy.cpp','task 1.21','Keep generated source in memory by default; allow explicit Saved/temp, reviewed goldens, and release emit destinations.','all output modes','written bytes equal in-memory canonical bytes and path guards hold','output destination frozen and seed explicit','adds guarded writers; no generated output committed by this task itself','Yes; make task 1.21 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_output_policy.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter OutputPolicy','In-memory default and explicit output ownership','1.21'),
	@('1.23','Write failing plugin release API and static-function contract tests','Plugins/Angelscript/Source/AngelscriptTest/Tests/Generated/AngelscriptTestCodeReleaseTests.cpp','design.md FAngelscriptTestCode; catalogs/static-function-registry.csv','Validate one static function per product/fixture returns the complete case and generic dispatch can enumerate and look up CaseKeys.','origin;CaseKey;axes;seed;oracle;source bundle','complete FAngelscriptGeneratedCase; unique symbols; no registrar/ForceLink','default seed and catalog order frozen','tests only; no current tests replaced','Yes; UE compile-level/data contract tests','Tools/RunTests.ps1 -Test Angelscript.TestModule.Generated.TestCodeRelease','Generated C++ release mirror and static API','1.20,1.22'),
	@('1.24','Implement plugin-facing generated case value types and FAngelscriptTestCode declaration','Plugins/Angelscript/Source/AngelscriptTest/Public/Generated/AngelscriptTestCode.h','task 1.23; legacy TestCode research','Declare EAngelscriptTestCodeOrigin, axis/cell/oracle/source/result values, per-case static functions, TryGenerateByCaseKey, EnumerateCaseKeys, and EnumerateCells.','all registry entries and typed oracle variants','complete immutable value returned without hidden registrar state','catalog/default seed frozen; request seed explicit','plugin receives release API only','Yes; compile and data contract tests','Tools/RunBuild.ps1 -Target AngelscriptProjectEditor','Generated C++ release mirror and static API','1.23'),
	@('1.25','Write failing static release emitter, sharding, and stale-output tests','Tools/AngelscriptCodeGen/tests/test_static_release.py; Tools/AngelscriptCodeGen/cpp/tests/StaticReleaseTests.cpp','catalogs/static-function-registry.csv; design.md Release generation','Cover symbol declaration/definition, shard selection, escaping, dispatch sort order, stale file removal manifest, and no registrar/ForceLink.','authored;SDK;Coverage;inline candidate;empty/nonempty shard','byte-identical .h/.cpp output and exact registry coverage','registry/order frozen; generated content uses explicit seed','tests only','Yes; Python/C++ emitter parity','python -m pytest Tools/AngelscriptCodeGen/tests/test_static_release.py -q','Generated C++ release mirror and static API','1.24'),
	@('1.26','Implement independent Python and C++ static release emitters','Tools/AngelscriptCodeGen/src/angelscript_codegen/output/static_cpp.py; Tools/AngelscriptCodeGen/cpp/src/StaticCpp.cpp','task 1.25','Emit plugin-owned generated C++ with one static function per CaseKey and a generated sorted dispatch table.','all static-function registry rows','declarations, definitions, source, canonical manifest, oracle, axes, seed, references all complete','registry/default seed frozen; source variation uses request seed','writes only generated plugin release artifacts in explicit release mode','Yes; make task 1.25 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_static_release.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter StaticRelease','Generated C++ release mirror and static API','1.25'),
	@('1.27','Write failing authored-source export parity tests','Tools/AngelscriptCodeGen/tests/test_authored_source_export.py; Tools/AngelscriptCodeGen/cpp/tests/AuthoredSourceExportTests.cpp','catalogs/authored-testsource-static-functions.csv','Read reviewed TestSource .as bytes and export them into the same complete generated-case contract without regenerating their semantics.','614 authored CaseKeys; LF/BOM/trailing newline inputs','exported source canonicalizes predictably and retains observation/comment/reference manifest fields','authored semantics and CaseKey frozen; seed ignored','tests only','Yes; representative and full-catalog export checks','python -m pytest Tools/AngelscriptCodeGen/tests/test_authored_source_export.py -q','Unified authored and generated static API','1.4,1.24'),
	@('1.28','Implement authored TestSource export adapters in Python and C++','Tools/AngelscriptCodeGen/src/angelscript_codegen/generation/authored.py; Tools/AngelscriptCodeGen/cpp/src/AuthoredSource.cpp; TestSource/Generation/Rules/Authored/index.json','task 1.27','Export existing reviewed .as source as complete FAngelscriptGeneratedCase inputs; do not synthesize or alter test intent.','all authored registry entries','source/comment/reference/oracle metadata complete','source and manifest frozen; no random source changes','adds export path only; manual AS remains source of truth','Yes; make task 1.27 pass','python -m pytest Tools/AngelscriptCodeGen/tests/test_authored_source_export.py -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Filter AuthoredSource','Unified authored and generated static API','1.27')
)

foreach ($Task in $FoundationTasks)
{
	Add-Task -Id $Task[0] -Title $Task[1] -Files $Task[2] -Reference $Task[3] -AsScope $Task[4] -Axes $Task[5] -Oracle $Task[6] -RandomFrozen $Task[7] -Impact $Task[8] -Tests $Task[9] -Verify $Task[10] -Requirement $Task[11] -Dependencies $Task[12]
}

[void]$TaskText.AppendLine('## 2. Authored TestSource fixture exports (614 exact entries)')
[void]$TaskText.AppendLine()
$TaskIndex = 1
foreach ($Row in $AuthoredRows)
{
	$TestFile = "Tools/AngelscriptCodeGen/tests/rules/authored/test_$($Row.ManualBindTaskId.ToLowerInvariant().Replace('-', '_')).py"
	$RuleFile = "TestSource/Generation/Rules/Authored/$($Row.ManualBindTaskId).json"
	$Static = $StaticRows | Where-Object CaseKey -eq $Row.CaseKey | Select-Object -First 1
	Add-Task -Id "2.$TaskIndex" -Title "Write failing authored export test for $($Row.CaseKey)" -Files "$TestFile; Tools/AngelscriptCodeGen/cpp/tests/Authored/$($Row.ManualBindTaskId)Tests.cpp" -Reference "$($Row.SourcePath); $($Row.ManualBindTaskId); Bind=$($Row.BindIds); Surface=$($Row.SurfaceIds); Refs=$($Row.ReferenceIds)" -AsScope "$($Row.TestScope); symbols=$($Row.PlannedSymbols); inputs=$($Row.Inputs)" -Axes "one authored fixture CaseKey; source shape=$($Row.SourceShape); harness=$($Row.Harness)" -Oracle $Row.ExpectedObservations -RandomFrozen 'authored source, expectations, and comments frozen; seed ignored' -Impact 'adds export tests only; does not compile, replace, or relocate the AS source' -Tests 'Yes; Python canonical export and portable C++ parity for this exact CaseKey' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.CaseKey)'" -Requirement 'Every reviewed authored TestSource file has one complete static export' -Dependencies "1.28; $($Row.ManualBindTaskId); $($Row.Dependencies)"
	++$TaskIndex
	Add-Task -Id "2.$TaskIndex" -Title "Add authored rule and generated static release entry for $($Row.CaseKey)" -Files "$RuleFile; $($Static.ReleaseShard)" -Reference "$($Row.SourcePath); comment focus=$($Row.ExpectedComments)" -AsScope "Export the exact reviewed AS file and its planned symbols through $($Row.GeneratedCppSymbol); no semantic source generation." -Axes "CaseKey=$($Row.CaseKey); source shape=$($Row.SourceShape); fixture status=$($Row.Status)" -Oracle $Row.ExpectedObservations -RandomFrozen 'all authored bytes/facts frozen after canonicalization; seed ignored' -Impact 'adds one rule record and one generated release function; current C++/AS runners remain unchanged' -Tests 'Yes; make the immediately preceding authored export test pass' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.CaseKey)'" -Requirement 'Every reviewed authored TestSource file has one complete static export' -Dependencies "2.$($TaskIndex - 1); manual source status=$($Row.Status)"
	++$TaskIndex
}

[void]$TaskText.AppendLine('## 3. Native AngelScript SDK generated product rules (271 products / 45,760 mandatory cells)')
[void]$TaskText.AppendLine()
$TaskIndex = 1
foreach ($Row in $SdkRows)
{
	$Slug = $Row.ProductId.ToLowerInvariant().Replace('-', '_')
	$TestFile = "Tools/AngelscriptCodeGen/tests/rules/native_sdk/test_$Slug.py"
	$RuleFile = "TestSource/Generation/Rules/NativeSDK/$($Row.Theme)/$($Row.ProductId).json"
	$CaseKey = "NativeSDK/$($Row.ProductId)"
	$Static = $StaticRows | Where-Object CaseKey -eq $CaseKey | Select-Object -First 1
	Add-Task -Id "3.$TaskIndex" -Title "Write failing exhaustive rule/parity test for $($Row.ProductId)" -Files "$TestFile; Tools/AngelscriptCodeGen/cpp/tests/NativeSDK/$($Row.Theme)/$($Row.ProductId)Tests.cpp" -Reference "$($Row.LegacyFile)|$($Row.LegacyClass)|$($Row.LegacyMethod)|$($Row.LegacyGenerator); $($Row.References)" -AsScope $Row.GeneratedAsScope -Axes "$($Row.Axes); mandatory cells=$($Row.ExpandedCells); classification=$($Row.Classification)" -Oracle $Row.OracleScope -RandomFrozen "random slots=$($Row.RandomSlots); frozen=$($Row.Constraints)" -Impact 'adds rule tests only; does not replace or modify the legacy builder/test' -Tests 'Yes; cardinality, seed sweep, Python/C++ byte parity, oracle completeness, comments, negative/recovery when applicable' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$CaseKey'" -Requirement 'Every current SDK source builder is represented by one deep declarative product rule' -Dependencies '1.20;1.26'
	++$TaskIndex
	Add-Task -Id "3.$TaskIndex" -Title "Implement rule and static release entry for $($Row.ProductId)" -Files "$RuleFile; $($Static.ReleaseShard)" -Reference "$($Row.LegacyFile)|$($Row.LegacyClass)|$($Row.LegacyMethod)|$($Row.LegacyGenerator); evidence=$($Row.Evidence)" -AsScope "$($Row.GeneratedAsScope); comments=$($Row.CommentKnowledge)" -Axes "$($Row.FixedInputs); mandatory cells=$($Row.ExpandedCells)" -Oracle "$($Row.OracleScope); negative=$($Row.NegativeMutation); recovery=$($Row.RecoverySource)" -RandomFrozen "only $($Row.RandomSlots) vary; explicit cells, oracle meaning, mutation identity, and formatting contract remain frozen" -Impact "adds $($Row.GeneratedCppSymbol) and rule data; preserves legacy test unchanged; status=$($Row.RuleStatus)" -Tests 'Yes; make the immediately preceding product test pass and prove both implementations emit identical bytes' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$CaseKey'" -Requirement 'Every current SDK source builder is represented by one deep declarative product rule' -Dependencies "3.$($TaskIndex - 1)"
	++$TaskIndex
}

[void]$TaskText.AppendLine('## 4. Coverage generation candidates (one rule per current TEST_METHOD candidate)')
[void]$TaskText.AppendLine()
$TaskIndex = 1
foreach ($Row in ($CoverageRows | Where-Object Disposition -eq 'GeneratedRecipe'))
{
	$TestFile = "Tools/AngelscriptCodeGen/tests/rules/coverage/test_$($Row.DispositionId.ToLowerInvariant().Replace('-', '_')).py"
	$RuleFile = "TestSource/Generation/Rules/Coverage/$($Row.Domain)/$($Row.DispositionId).json"
	$Static = $StaticRows | Where-Object CaseKey -eq $Row.FutureCaseKey | Select-Object -First 1
	Add-Task -Id "4.$TaskIndex" -Title "Write failing candidate-rule test for $($Row.DispositionId) $($Row.Class).$($Row.Method)" -Files "$TestFile; Tools/AngelscriptCodeGen/cpp/tests/Coverage/$($Row.DispositionId)Tests.cpp" -Reference "$($Row.File):$($Row.Line); recipe=$($Row.CandidateRecipe); $($Row.Rationale)" -AsScope $Row.GeneratedAsScope -Axes $Row.ProductAxes -Oracle $Row.ExistingOracle -RandomFrozen 'seed may vary only legal literals, names, independent order, and grouping declared by the recipe; current method behavior and all explicit cells frozen' -Impact 'adds candidate tests only; current Coverage method and host harness remain unchanged' -Tests 'Yes; Python/C++ parity, source shape, typed oracle, comments, and representative seed sweep' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.FutureCaseKey)'" -Requirement 'Coverage repetition is promoted only through reviewed finite products' -Dependencies '1.20;1.26; disposition review in section 6 for the owning file'
	++$TaskIndex
	Add-Task -Id "4.$TaskIndex" -Title "Implement candidate rule and static entry for $($Row.DispositionId)" -Files "$RuleFile; $($Static.ReleaseShard)" -Reference "$($Row.File):$($Row.Line); CaseKey=$($Row.FutureCaseKey); host=$($Row.HostRequirements)" -AsScope $Row.GeneratedAsScope -Axes $Row.ProductAxes -Oracle $Row.ExistingOracle -RandomFrozen 'explicit product and host oracle frozen; only recipe-declared legal slots random' -Impact 'adds a no-adoption rule/static result beside the unchanged Coverage method' -Tests 'Yes; make the immediately preceding candidate test pass; do not change the existing UE test' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.FutureCaseKey)'" -Requirement 'Coverage repetition is promoted only through reviewed finite products' -Dependencies "4.$($TaskIndex - 1)"
	++$TaskIndex
}

[void]$TaskText.AppendLine('## 5. Non-Coverage inline generation candidates')
[void]$TaskText.AppendLine()
$TaskIndex = 1
foreach ($Row in ($InlineRows | Where-Object { $_.Disposition -eq 'GeneratedRecipe' -and $_.File -notmatch '/Coverage/' }))
{
	$TestFile = "Tools/AngelscriptCodeGen/tests/rules/inline/test_$($Row.InlineId.ToLowerInvariant().Replace('-', '_')).py"
	$RuleFile = "TestSource/Generation/Rules/Inline/$($Row.InlineId).json"
	$Static = $StaticRows | Where-Object CaseKey -eq $Row.FutureCaseKey | Select-Object -First 1
	Add-Task -Id "5.$TaskIndex" -Title "Write failing reviewed-rule test for $($Row.InlineId) $($Row.Class).$($Row.Method)" -Files "$TestFile; Tools/AngelscriptCodeGen/cpp/tests/Inline/$($Row.InlineId)Tests.cpp" -Reference "$($Row.References); extraction=$($Row.ExtractionForm); $($Row.Rationale)" -AsScope "$($Row.GeneratedAsScope); shape=$($Row.ApproxShape); return types=$($Row.ReturnTypes)" -Axes "derive and freeze a finite $($Row.RecipeFamily) matrix during disposition review; one current source unit is the baseline" -Oracle "$($Row.ExistingExecutionKind); $($Row.ExistingOracle)" -RandomFrozen 'no random slot enabled until the owning-file disposition review names its legal domain; explicit baseline frozen' -Impact 'adds tests only; no current inline literal or test is changed' -Tests 'Yes; exact baseline, rule schema, seed invariants, Python/C++ parity' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.FutureCaseKey)'" -Requirement 'Inline AS is inventoried before any rule promotion' -Dependencies "1.20; section 6 disposition review for $($Row.File)"
	++$TaskIndex
	Add-Task -Id "5.$TaskIndex" -Title "Implement reviewed inline rule and static entry for $($Row.InlineId)" -Files "$RuleFile; $($Static.ReleaseShard)" -Reference "$($Row.References); CaseKey=$($Row.FutureCaseKey)" -AsScope "$($Row.GeneratedAsScope); recipe=$($Row.RecipeFamily)" -Axes 'use only the finite axes approved by the preceding disposition review' -Oracle "$($Row.ExistingExecutionKind); $($Row.ExistingOracle); return types=$($Row.ReturnTypes)" -RandomFrozen 'only reviewed legal slots random; baseline, explicit cells, oracle, negative mutation, and recovery frozen' -Impact 'adds a no-adoption rule/static result beside the unchanged inline test' -Tests 'Yes; make the immediately preceding rule test pass' -Verify "python -m pytest $TestFile -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -CaseKey '$($Row.FutureCaseKey)'" -Requirement 'Inline AS is inventoried before any rule promotion' -Dependencies "5.$($TaskIndex - 1)"
	++$TaskIndex
}

[void]$TaskText.AppendLine('## 6. File-level review of every inline AS disposition')
[void]$TaskText.AppendLine()
$TaskIndex = 1
foreach ($FileGroup in ($InlineRows | Group-Object File | Sort-Object Name))
{
	$Ids = ($FileGroup.Group.InlineId -join ';')
	$Lines = ($FileGroup.Group.Line -join ';')
	$Dispositions = (($FileGroup.Group | Group-Object Disposition | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ';')
	$Recipes = (($FileGroup.Group.RecipeFamily | Sort-Object -Unique) -join ';')
	Add-Task -Id "6.$TaskIndex" -Title "Review inline AS dispositions in $($FileGroup.Name)" -Files 'openspec/changes/test-as-source-generation-rules/catalogs/inline-as-generation-disposition.csv' -Reference "$($FileGroup.Name); InlineIds=$Ids; Lines=$Lines" -AsScope "Review all $($FileGroup.Count) extracted source units; confirm source boundaries, return types, execution kind, oracle, and authored/generated/specialized classification." -Axes "candidate recipes=$Recipes" -Oracle (($FileGroup.Group.ExistingOracle | Sort-Object -Unique) -join ';') -RandomFrozen 'do not authorize randomness unless a finite legal slot and frozen matrix/oracle are recorded' -Impact "planning catalog only; disposition counts=$Dispositions; no source replacement" -Tests 'Yes; rerun inventory and validator; manually compare catalog rows with every referenced literal' -Verify "powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ExportCurrentInlineAsInventory.ps1; powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ValidateGenerationRulePlan.ps1" -Requirement 'Complete current inline AS inventory with explicit disposition' -Dependencies 'inventory baseline; no generator implementation dependency'
	++$TaskIndex
}

[void]$TaskText.AppendLine('## 7. Final no-adoption release verification')
[void]$TaskText.AppendLine()
Add-Task -Id '7.1' -Title 'Prove all 614 authored fixture entries are exported or explicitly waiting on their manual source task' -Files 'catalogs/authored-testsource-static-functions.csv; generated release artifacts' -Reference 'test-as-manual-bind-source-coverage/inventory/planned-test-sources.csv' -AsScope 'Check every exact TestSource path, symbol, scope, inputs, observations, comments, harness, and dependency.' -Axes '614 exact CaseKeys' -Oracle 'catalog completeness and per-entry export parity' -RandomFrozen 'authored source frozen; seed ignored' -Impact 'verification only' -Tests 'Yes; full authored catalog suite' -Verify 'python -m pytest Tools/AngelscriptCodeGen/tests/test_authored_source_export.py -q' -Requirement 'Unified authored and generated static API' -Dependencies 'all section 2 tasks'
Add-Task -Id '7.2' -Title 'Prove all 271 SDK products and 45,760 mandatory cells are represented without replacement' -Files 'catalogs/sdk-generated-product-rules.csv; generated release artifacts' -Reference 'generated-source-registry.csv; product-cardinalities.csv' -AsScope 'Check every legacy owner/generator, source scope, comments, negative/recovery rule, and generated product result.' -Axes '271 products; 45,760 explicit cells' -Oracle 'per-product typed/diagnostic/metadata/lifecycle oracle completeness' -RandomFrozen 'seed sweep preserves every explicit cell and oracle' -Impact 'verification only; legacy builders remain byte-for-byte unchanged' -Tests 'Yes; full SDK rule/parity suite' -Verify 'python -m pytest Tools/AngelscriptCodeGen/tests/rules/native_sdk -q; powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Suite NativeSDK' -Requirement 'Every current SDK source builder is represented by one deep declarative product rule' -Dependencies 'all section 3 tasks'
Add-Task -Id '7.3' -Title 'Prove Coverage and inline candidate registries retain explicit no-adoption status' -Files 'catalogs/coverage-generation-disposition.csv; catalogs/inline-as-generation-disposition.csv; catalogs/static-function-registry.csv' -Reference '90 Coverage files / 1022 methods; current AngelscriptTest inline source scan' -AsScope 'Check every candidate source rule is additive and every authored/specialized case remains dispositioned.' -Axes 'all inventory rows and candidate recipes' -Oracle 'inventory identity, rule parity, and absence of current-test rewrites' -RandomFrozen 'unreviewed candidates have no enabled random slots' -Impact 'verification only' -Tests 'Yes; inventory and repository diff guards' -Verify 'powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ValidateGenerationRulePlan.ps1' -Requirement 'No test adoption or replacement in this change' -Dependencies 'sections 4-6'
Add-Task -Id '7.4' -Title 'Generate the plugin release mirror from both implementations and compare bytes' -Files 'Plugins/Angelscript/Source/AngelscriptTest/Generated/TestCode/**; release manifest' -Reference 'catalogs/static-function-registry.csv' -AsScope 'Emit only reviewed source/manifests/oracles/static functions and sorted generic dispatch.' -Axes 'all registry CaseKeys and default seed' -Oracle 'Python output bytes equal portable C++ output bytes; every entry complete' -RandomFrozen 'release seed and ordering frozen' -Impact 'updates generated C++ release artifacts only; plugin receives no Python/JSON/TestSource assets' -Tests 'Yes; stale-output, parity, compile, and data contract tests' -Verify 'powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1 -Suite Release; Tools/RunBuild.ps1 -Target AngelscriptProjectEditor' -Requirement 'Generated C++ release mirror and static API' -Dependencies '1.26; all section 2-5 implementation tasks'
Add-Task -Id '7.5' -Title 'Run final scope, determinism, catalog, and no-replacement audit' -Files 'openspec/changes/test-as-source-generation-rules/verification.md; generated validation reports' -Reference 'all three delta specs and every catalog in this change' -AsScope 'Record exact counts, commands, hashes, seed sweep, output ownership, plugin release contents, and unchanged legacy-test proof.' -Axes 'all recipe families; boundary/ordinary seeds; all registry origins' -Oracle 'zero missing/duplicate rows, zero parity drift, zero unauthorized writes, zero legacy replacements' -RandomFrozen 'all seeds explicit in the report' -Impact 'verification record only' -Tests 'Yes; full portable and targeted UE suites listed in verification.md' -Verify 'powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ValidateGenerationRulePlan.ps1; openspec validate test-as-source-generation-rules --strict --no-interactive' -Requirement 'Auditable completion without hidden adoption' -Dependencies '7.1-7.4'

$TasksPath = Join-Path $ChangeRoot 'tasks.md'
[System.IO.File]::WriteAllText($TasksPath, $TaskText.ToString().Replace("`r`n", "`n"), [System.Text.UTF8Encoding]::new($false))

$SdkCellCount = ($SdkRows | Measure-Object -Property ExpandedCells -Sum).Sum
Write-Host "Authored catalog: $($AuthoredRows.Count) rows"
Write-Host "SDK rule catalog: $($SdkRows.Count) rows / $SdkCellCount cells"
Write-Host "Static registry: $($StaticRows.Count) rows"
Write-Host "Tasks: $([regex]::Matches($TaskText.ToString(), '(?m)^- \[ \] ').Count) checkboxes -> $TasksPath"
