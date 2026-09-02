[CmdletBinding()]
param(
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Drift = New-Object System.Collections.Generic.List[string]
$ChangeRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $ChangeRoot '..\..\..')).Path
$InventoryRoot = Join-Path $ChangeRoot 'inventory'
$MatricesRoot = Join-Path $ChangeRoot 'matrices'
$TasksPath = Join-Path $ChangeRoot 'tasks.md'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-RelativePath([string]$Path) {
    $Full = [System.IO.Path]::GetFullPath($Path)
    if (-not $Full.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside repository: $Path"
    }
    return $Full.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
}

function Normalize-Text([string]$Text) {
    if ($null -eq $Text) { return '' }
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}

function Write-GeneratedFile([string]$Path, [string]$Content) {
    $Expected = Normalize-Text $Content
    if (-not $Expected.EndsWith("`n")) { $Expected += "`n" }

    if ($Check) {
        if (-not (Test-Path -LiteralPath $Path)) {
            $script:Drift.Add("missing: $(Get-RelativePath $Path)")
            return
        }
        $Actual = Normalize-Text ([System.IO.File]::ReadAllText($Path))
        if ($Actual -ne $Expected) {
            $script:Drift.Add("drift: $(Get-RelativePath $Path)")
        }
        return
    }

    $Parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Expected, $Utf8NoBom)
}

function Write-GeneratedJsonFile([string]$Path, [object]$Value) {
    if ($Check) {
        if (-not (Test-Path -LiteralPath $Path)) {
            $script:Drift.Add("missing: $(Get-RelativePath $Path)")
            return
        }

        try {
            # PowerShell 5.1 and PowerShell 7 use different pretty-print
            # whitespace for the same JSON value. Compare compact parsed data
            # so -Check is stable across both supported hosts.
            $ActualValue = [System.IO.File]::ReadAllText($Path) | ConvertFrom-Json
            $ExpectedCanonical = $Value | ConvertTo-Json -Depth 10 -Compress
            $ActualCanonical = $ActualValue | ConvertTo-Json -Depth 10 -Compress
            if ($ActualCanonical -cne $ExpectedCanonical) {
                $script:Drift.Add("drift: $(Get-RelativePath $Path)")
            }
        }
        catch {
            $script:Drift.Add("invalid-json: $(Get-RelativePath $Path)")
        }
        return
    }

    Write-GeneratedFile $Path ($Value | ConvertTo-Json -Depth 5)
}

function Convert-RowsToCsv([object[]]$Rows) {
    if ($Rows.Count -eq 0) { return '' }
    return (($Rows | ConvertTo-Csv -NoTypeInformation) -join "`n")
}

function Get-Sha256([string]$Text) {
    $Sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes((Normalize-Text $Text).Trim())
        return ([System.BitConverter]::ToString($Sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $Sha.Dispose()
    }
}

function Get-LineNumber([string]$Content, [int]$Index) {
    if ($Index -le 0) { return 1 }
    return ([regex]::Matches($Content.Substring(0, $Index), "`n")).Count + 1
}

function Collapse-Text([string]$Text, [int]$Limit = 900) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    $Collapsed = ($Text -replace '\s+', ' ').Trim()
    if ($Collapsed.Length -gt $Limit) { return $Collapsed.Substring(0, $Limit) + '...' }
    return $Collapsed
}

function Get-FirstMeaningfulLine([string]$Body) {
    foreach ($Line in (Normalize-Text $Body).Split("`n")) {
        $Trimmed = $Line.Trim()
        if ($Trimmed -and $Trimmed -notmatch '^(//|/\*|\*|#if\s+0|#endif|[{}]+$)') {
            return Collapse-Text $Trimmed 240
        }
    }
    return ''
}

function Get-DeclaredSymbols([string]$Body) {
    $Names = New-Object System.Collections.Generic.List[string]
    $Pattern = '(?m)^\s*(?:UCLASS\([^\r\n]*\)\s*)?(?:class|struct|enum|interface)\s+([A-Za-z_]\w*)|^\s*(?:[A-Za-z_]\w*(?:<[^>]+>)?[&@]?\s+)+([A-Za-z_]\w*)\s*\('
    foreach ($Match in [regex]::Matches($Body, $Pattern)) {
        $Name = if ($Match.Groups[1].Success) { $Match.Groups[1].Value } else { $Match.Groups[2].Value }
        if ($Name -and -not $Names.Contains($Name)) { $Names.Add($Name) }
        if ($Names.Count -ge 16) { break }
    }
    return ($Names -join ';')
}

function Get-OracleHints([string]$MethodText) {
    $Hints = New-Object System.Collections.Generic.List[string]
    foreach ($Line in (Normalize-Text $MethodText).Split("`n")) {
        $Trimmed = $Line.Trim()
        if ($Trimmed -match '(ASSERT_|EXPECT_|TestTrue|TestFalse|TestEqual|TestNotEqual|ExpectCompile|ExpectRuntime|Expect.*Error|Verify|CHECK\s*\()') {
            $Hints.Add((Collapse-Text $Trimmed 260))
        }
        if ($Hints.Count -ge 8) { break }
    }
    return ($Hints -join ' | ')
}

function Get-SafeName([string]$Value) {
    $Name = $Value -replace '[^A-Za-z0-9_]+', '_'
    $Name = $Name.Trim('_')
    if (-not $Name) { return 'Unnamed' }
    return $Name
}

function Test-ProbablyAngelScript([string]$Body, [string]$Prefix, [string]$CppTheme) {
    if ($Prefix -match 'ASTEST_AS\s*\(\s*$') { return $true }
    if ($Body -match '(?im)^\s*(?:UCLASS|USTRUCT|UENUM|UINTERFACE|UFUNCTION|UPROPERTY|mixin\s+|namespace\s+|class\s+|struct\s+|enum\s+|interface\s+|asset\s+|default\s+|access\s+)') { return $true }
    if ($Body -match '(?im)^\s*(?:void|bool|int(?:8|16|32|64)?|uint(?:8|16|32|64)?|float(?:32|64)?|double|FString|FName|TArray|TMap|TSet|TOptional|auto|[AUF][A-Za-z_]\w*)\s+[A-Za-z_]\w*\s*(?:\(|=|;)') { return $true }
    if ($CppTheme -in @('Syntax','Compiler','Preprocessor') -and -not [string]::IsNullOrWhiteSpace($Body)) { return $true }
    return $false
}

function New-ThemeRow(
    [string]$ThemeId,
    [string]$ThemeKind,
    [string]$TargetRoot,
    [string]$QuestionIds,
    [string]$FixturePolicy,
    [string]$AuthoringMode = 'Handwritten',
    [string]$CurrentState = 'MissingPlanned',
    [string]$Blocker = ''
) {
    [pscustomobject][ordered]@{
        ThemeId = $ThemeId
        ThemeKind = $ThemeKind
        TargetRoot = $TargetRoot
        QuestionIds = $QuestionIds
        FixturePolicy = $FixturePolicy
        AuthoringMode = $AuthoringMode
        CurrentState = $CurrentState
        Blocker = $Blocker
    }
}

$ThemeRows = New-Object System.Collections.Generic.List[object]
$ThemeRows.Add((New-ThemeRow 'Bindings' 'Contract' 'TestSource/Bindings' 'bind-contract' 'Per-callable contract' 'Handwritten' 'MaterializedBlocked'))
$ThemeRows.Add((New-ThemeRow 'TestFramework' 'Framework' 'TestSource/TestFramework' 'host-machinery' 'Independent C++ external oracle' 'Handwritten' 'MaterializedProvisional'))

$LanguageLeaves = @(
    'Operators.Arithmetic','Operators.Bitwise','Operators.Logical','Operators.Comparison','Operators.Assignment','Operators.Ternary','Operators.Overload','Operators.Precedence',
    'ControlFlow.If','ControlFlow.For','ControlFlow.While','ControlFlow.Switch','ControlFlow.Jump','ControlFlow.Foreach',
    'Syntax.Comments','Syntax.Keywords','Syntax.Class','Syntax.Struct','Syntax.Enum','Syntax.Interface','Syntax.Function','Syntax.Variable','Syntax.Reference','Syntax.Constructor','Syntax.Destructor','Syntax.Block','Syntax.Exceptions','Syntax.EdgeCases',
    'Literals.Integer','Literals.Float','Literals.Bool','Literals.FString','Access','Casting','Namespace','Preprocessor','Const'
)
foreach ($Leaf in $LanguageLeaves) {
    $ThemeRows.Add((New-ThemeRow "Language.$Leaf" 'Semantic' ("TestSource/Language/" + $Leaf.Replace('.', '/')) 'surface-form;behavior-matrix;same-as-profile' 'Pure engine unless the scenario explicitly needs World'))
}

foreach ($Leaf in @('UEnum','UStruct','UClass','UFunction','UProperty','UInterface','Meta')) {
    $ThemeRows.Add((New-ThemeRow "Definitions.$Leaf" 'Semantic' "TestSource/Definitions/$Leaf" 'surface-form;bind-contract;behavior-matrix;reload-generation;same-as-profile;world-story' 'World only for live instance behavior'))
}

foreach ($Leaf in @('TArray','TMap','TSet','TOptional','TSubclassOf','TWeakObjectPtr','TSoftObjectPtr','TObjectPtr')) {
    $ThemeRows.Add((New-ThemeRow "Containers.$Leaf" 'Semantic' "TestSource/Containers/$Leaf" 'surface-form;bind-contract;behavior-matrix;same-as-profile;world-story' 'World only for live UObject ownership'))
}

foreach ($Leaf in @('Mixin','Delegates','DefaultComponent','Attach','PropertyAccess','Inheritance','Asset','Default','Access')) {
    $ThemeRows.Add((New-ThemeRow "Feature.$Leaf" 'Semantic' "TestSource/Feature/$Leaf" 'surface-form;behavior-matrix;reload-generation;world-story' 'World for live Actor/CDO/readback cases'))
}

foreach ($Leaf in @('Actor','Component','Subsystem.World','Subsystem.GameInstance','Subsystem.LocalPlayer','Subsystem.Engine','Subsystem.Editor','Blueprint','Widget')) {
    $ThemeRows.Add((New-ThemeRow "World.$Leaf" 'Semantic' ("TestSource/World/" + $Leaf.Replace('.', '/')) 'world-story;reload-generation' 'Runner-owned World and explicit teardown'))
}

foreach ($Leaf in @('FMath','FVector','FRotator','FQuat','FTransform','FLinearColor','FVector2D','Input','Physics','Widget','Net','Assets','Timer','Debug','CVar','Anim','Save','Material')) {
    if ($Leaf -eq 'FMath') {
        $ThemeRows.Add((New-ThemeRow 'Gameplay.FMath' 'Semantic' 'TestSource/Gameplay/FMath' 'bind-contract;behavior-matrix;same-as-profile' 'Pure values unless a case needs World' 'Handwritten' 'Blocked' 'improve-as-library-namespace-canonicalization'))
    }
    else {
        $ThemeRows.Add((New-ThemeRow "Gameplay.$Leaf" 'Semantic' "TestSource/Gameplay/$Leaf" 'bind-contract;behavior-matrix;world-story;same-as-profile' 'Case-specific; isolate World/global state'))
    }
}

$ThemeRows.Add((New-ThemeRow 'Optional.GameplayTags' 'Semantic' 'TestSource/Optional/GameplayTags' 'bind-contract;behavior-matrix;world-story' 'Optional plugin fixture and explicit cleanup'))
$ThemeRows.Add((New-ThemeRow 'Optional.GAS' 'Semantic' 'TestSource/Optional/GAS' 'bind-contract;behavior-matrix;world-story' 'Ability-system World fixture and explicit cleanup'))
$ThemeRows.Add((New-ThemeRow 'HotReload' 'Transition' 'TestSource/HotReload' 'reload-generation' 'Version pair plus reload/session cleanup'))
$ThemeRows.Add((New-ThemeRow 'Debugger' 'ProtocolPayload' 'TestSource/Debugger' 'host-machinery' 'Stable markers; driver owns DAP session'))
$ThemeRows.Add((New-ThemeRow 'Generation' 'Tooling' 'TestSource/Generation' 'none' 'Separate generation OpenSpec' 'Generated' 'SeparatePackage' 'test-as-source-generation-rules'))

$ThemeById = @{}
foreach ($Row in $ThemeRows) { $ThemeById[$Row.ThemeId] = $Row }

function Get-LeafTheme([string]$Module, [string]$CppTheme, [string]$Path, [string]$ClassName, [string]$MethodName) {
    if ($Module -eq 'GameplayTags') { return 'Optional.GameplayTags' }
    if ($Module -eq 'GAS') { return 'Optional.GAS' }
    if ($CppTheme -eq 'HotReload') { return 'HotReload' }
    if ($CppTheme -eq 'Debugger') { return 'Debugger' }

    $Key = "$Path $ClassName $MethodName".ToLowerInvariant()

    if ($Key -match 'attachsocket|overridecomponent|rootcomponent|attachment|\battach') { return 'Feature.Attach' }
    if ($Key -match 'defaultcomponent') { return 'Feature.DefaultComponent' }
    if ($Key -match 'propertyaccess|propertyaccessor|getset') { return 'Feature.PropertyAccess' }
    if ($Key -match 'delegate|eventbroadcast|multicast') { return 'Feature.Delegates' }
    if ($Key -match 'mixin') { return 'Feature.Mixin' }
    if ($Key -match 'inherit|override|supercall') { return 'Feature.Inheritance' }
    if ($Key -match 'literalasset|assetdeclaration|assetliteral') { return 'Feature.Asset' }
    if ($Key -match 'defaultstatement|classdefault|defaultsand') { return 'Feature.Default' }
    if ($Key -match 'accessspecifier|customaccess|namedaccess') { return 'Feature.Access' }

    if ($Key -match 'uinterface|scriptinterface') { return 'Definitions.UInterface' }
    if ($Key -match 'ufunction|functionspecifier|rpcfunction|blueprintoverride') { return 'Definitions.UFunction' }
    if ($Key -match 'uproperty|classproperty|propertyspecifier') { return 'Definitions.UProperty' }
    if ($Key -match 'ustruct|structmember|scriptstruct') { return 'Definitions.UStruct' }
    if ($Key -match 'uenum|scriptenum') { return 'Definitions.UEnum' }
    if ($Key -match 'uclass|classfeature|classlifecycle|scriptclass|generatedclass') { return 'Definitions.UClass' }
    if ($Key -match 'metadata|metaspecifier|macros') { return 'Definitions.Meta' }

    if ($Key -match 'tsubclassof|subclass') { return 'Containers.TSubclassOf' }
    if ($Key -match 'tweakobjectptr|weakreference|weakobject') { return 'Containers.TWeakObjectPtr' }
    if ($Key -match 'tsoftobjectptr|softreference|softobject') { return 'Containers.TSoftObjectPtr' }
    if ($Key -match 'tobjectptr|objecthandle|handles') { return 'Containers.TObjectPtr' }
    if ($Key -match 'toptional|optional') { return 'Containers.TOptional' }
    if ($Key -match 'tarray|array') { return 'Containers.TArray' }
    if ($Key -match 'tset|setcontainer|coverage.*set') { return 'Containers.TSet' }
    if ($Key -match 'tmap|mapcontainer|coverage.*map') { return 'Containers.TMap' }

    if ($Key -match 'subsystem.*gameinstance') { return 'World.Subsystem.GameInstance' }
    if ($Key -match 'subsystem.*localplayer') { return 'World.Subsystem.LocalPlayer' }
    if ($Key -match 'subsystem.*editor') { return 'World.Subsystem.Editor' }
    if ($Key -match 'subsystem.*engine') { return 'World.Subsystem.Engine' }
    if ($Key -match 'subsystem') { return 'World.Subsystem.World' }
    if ($Key -match 'bindwidget|worldwidget') { return 'World.Widget' }
    if ($Key -match 'blueprintchild|blueprintimpact|blueprintsubclass') { return 'World.Blueprint' }
    if ($Key -match 'component' -and $Key -notmatch 'defaultcomponent') { return 'World.Component' }
    if ($Key -match 'actor|pawn|character|beginplay|endplay|spawnpattern') { return 'World.Actor' }

    if ($Key -match 'linearcolor') { return 'Gameplay.FLinearColor' }
    if ($Key -match 'vector2d') { return 'Gameplay.FVector2D' }
    if ($Key -match 'fvector|vectorbindings|vectorexpression') { return 'Gameplay.FVector' }
    if ($Key -match 'rotator') { return 'Gameplay.FRotator' }
    if ($Key -match 'quaternion|\bquat') { return 'Gameplay.FQuat' }
    if ($Key -match 'transform') { return 'Gameplay.FTransform' }
    if ($Key -match 'fmath|mathnamespace|mathmodule') { return 'Gameplay.FMath' }
    if ($Key -match 'enhancedinput|inputaction|inputbinding|inputcomponent|inputsettings|\binput') { return 'Gameplay.Input' }
    if ($Key -match 'collision|physics|trace|overlap|hitresult') { return 'Gameplay.Physics' }
    if ($Key -match 'userwidget|umg|widget') { return 'Gameplay.Widget' }
    if ($Key -match 'network|replication|rpc|\bnet') { return 'Gameplay.Net' }
    if ($Key -match 'assetmanager|assetloading|softpath|assetregistry') { return 'Gameplay.Assets' }
    if ($Key -match 'timer|latentdelay') { return 'Gameplay.Timer' }
    if ($Key -match 'debug|logging|errorhandling|callstack') { return 'Gameplay.Debug' }
    if ($Key -match 'consolevariable|\bcvar') { return 'Gameplay.CVar' }
    if ($Key -match 'anim|notify') { return 'Gameplay.Anim' }
    if ($Key -match 'savegame|\bsave') { return 'Gameplay.Save' }
    if ($Key -match 'material|rendering') { return 'Gameplay.Material' }

    if ($Key -match 'comment') { return 'Language.Syntax.Comments' }
    if ($Key -match 'keyword') { return 'Language.Syntax.Keywords' }
    if ($Key -match 'constructor') { return 'Language.Syntax.Constructor' }
    if ($Key -match 'destructor') { return 'Language.Syntax.Destructor' }
    if ($Key -match 'reference') { return 'Language.Syntax.Reference' }
    if ($Key -match 'plainstruct|structdeclaration') { return 'Language.Syntax.Struct' }
    if ($Key -match 'enumdeclaration') { return 'Language.Syntax.Enum' }
    if ($Key -match 'interfacedeclaration') { return 'Language.Syntax.Interface' }
    if ($Key -match 'functiondeclaration|functionsyntax') { return 'Language.Syntax.Function' }
    if ($Key -match 'variable|autotype') { return 'Language.Syntax.Variable' }
    if ($Key -match 'exception|throw') { return 'Language.Syntax.Exceptions' }
    if ($Key -match 'nestedblock|\bblock') { return 'Language.Syntax.Block' }
    if ($Key -match 'preprocessor|include|conditionalcompilation') { return 'Language.Preprocessor' }
    if ($Key -match 'namespace') { return 'Language.Namespace' }
    if ($Key -match 'casting|conversion') { return 'Language.Casting' }
    if ($Key -match '\bconst') { return 'Language.Const' }
    if ($Key -match 'fstring|stringliteral|interpolation|formatstring') { return 'Language.Literals.FString' }
    if ($Key -match 'boolliteral') { return 'Language.Literals.Bool' }
    if ($Key -match 'floatliteral') { return 'Language.Literals.Float' }
    if ($Key -match 'integerliteral|intliteral') { return 'Language.Literals.Integer' }
    if ($Key -match 'foreach') { return 'Language.ControlFlow.Foreach' }
    if ($Key -match 'switch') { return 'Language.ControlFlow.Switch' }
    if ($Key -match 'while') { return 'Language.ControlFlow.While' }
    if ($Key -match '\bfor\b|forloop') { return 'Language.ControlFlow.For' }
    if ($Key -match 'ifelse|conditional|\bif\b') { return 'Language.ControlFlow.If' }
    if ($Key -match 'break|continue|return') { return 'Language.ControlFlow.Jump' }
    if ($Key -match 'precedence') { return 'Language.Operators.Precedence' }
    if ($Key -match 'operatoroverload|overloadedoperator') { return 'Language.Operators.Overload' }
    if ($Key -match 'ternary') { return 'Language.Operators.Ternary' }
    if ($Key -match 'assignment') { return 'Language.Operators.Assignment' }
    if ($Key -match 'comparison|equality|relational') { return 'Language.Operators.Comparison' }
    if ($Key -match 'logical') { return 'Language.Operators.Logical' }
    if ($Key -match 'bitwise') { return 'Language.Operators.Bitwise' }
    if ($Key -match 'arithmetic|operator|expression') { return 'Language.Operators.Arithmetic' }
    if ($Key -match 'access') { return 'Language.Access' }

    if ($CppTheme -eq 'Preprocessor') { return 'Language.Preprocessor' }
    if ($CppTheme -eq 'Networking') { return 'Gameplay.Net' }
    if ($CppTheme -eq 'Delegate') { return 'Feature.Delegates' }
    return 'Language.Syntax.EdgeCases'
}

function Get-QuestionId([string]$Module, [string]$CppTheme, [string]$LeafTheme) {
    if ($CppTheme -eq 'AngelScriptSDK') { return 'native-fork' }
    if ($LeafTheme -eq 'HotReload' -or $CppTheme -eq 'Generator') { return 'reload-generation' }
    if ($LeafTheme -eq 'Debugger') { return 'host-machinery' }
    if ($CppTheme -in @('Syntax','Compiler','Preprocessor')) { return 'surface-form' }
    if ($CppTheme -in @('Bindings','FunctionLibraries')) { return 'bind-contract' }
    if ($Module -in @('GameplayTags','GAS') -and $CppTheme -eq 'Bindings') { return 'bind-contract' }
    if ($CppTheme -eq 'Functional' -or ($Module -eq 'GAS' -and $CppTheme -eq 'Functional')) { return 'world-story' }
    return 'behavior-matrix'
}

function Get-Disposition([string]$Module, [string]$CppTheme, [string]$Path, [string]$MethodName, [int]$RawBlockCount, [string]$LeafTheme) {
    if ($RawBlockCount -eq 0) { return 'NoReusableAngelScript' }
    if ($CppTheme -eq 'AngelScriptSDK') { return 'ReferenceOnlyNativeSDK' }
    if ($Module -eq 'Core' -and $CppTheme -eq 'Bindings') { return 'ExistingTestSource' }
    if ($Module -eq 'Core' -and $CppTheme -eq 'Testing') { return 'ExistingTestSource' }

    $HostThemes = @('Cache','Core','Dump','Editor','FileSystem','GC','Memory','Performance','RuntimeJIT','Shared','StaticJIT','Template','UHTTool','Validation')
    if ($CppTheme -in $HostThemes) { return 'HostOnly' }

    $Key = "$Path $MethodName".ToLowerInvariant()
    if ($Key -match '(bool|int|float)expressiontests|expressionmatrix|generatedexpressions|literalmatrix|definitionpermutation|specifiercombinations|combinatorial|cartesian|randomized|randomprogram') {
        return 'GeneratedLater'
    }
    if ($LeafTheme -eq 'Gameplay.FMath') { return 'Blocked' }
    if ($CppTheme -eq 'Generator' -and $LeafTheme -notmatch '^(Definitions|Feature|HotReload)') { return 'HostOnly' }
    return 'PlanHandwrittenSource'
}

function Get-DispositionReason([string]$Disposition, [string]$CppTheme, [string]$LeafTheme) {
    switch ($Disposition) {
        'PlanHandwrittenSource' { return 'Reusable non-generated AS scenario; plan an exact TestSource file.' }
        'ExistingTestSource' { return "Already represented by the materialized $CppTheme theme; retain as reference evidence." }
        'ReferenceOnlyNativeSDK' { return 'Native fork owner remains authoritative; do not create TestSource/AngelScriptSDK.' }
        'ReferenceOnlyTeaching' { return 'Host Script source remains teaching or project test content; do not copy wholesale.' }
        'HostOnly' { return 'The oracle is C++ host machinery; an incidental script does not justify a source theme.' }
        'DuplicateReference' { return 'File-scope/helper evidence is associated indirectly; method/block tasks own reusable scenarios.' }
        'GeneratedLater' { return 'Homogeneous/combinatorial program belongs to test-as-source-generation-rules.' }
        'Blocked' { return "Theme $LeafTheme is blocked by improve-as-library-namespace-canonicalization." }
        'NoReusableAngelScript' { return 'No candidate inline script block is present in this test method.' }
        default { return 'Explicitly classified by the theme inventory.' }
    }
}

$TestRoots = @(
    [pscustomobject]@{ Module = 'Core'; Root = Join-Path $RepoRoot 'Plugins\Angelscript\Source\AngelscriptTest'; ThemeMode = 'First' },
    [pscustomobject]@{ Module = 'GameplayTags'; Root = Join-Path $RepoRoot 'Plugins\AngelscriptGameplayTags\Source\AngelscriptGameplayTagsTest'; ThemeMode = 'PrivateChild' },
    [pscustomobject]@{ Module = 'GAS'; Root = Join-Path $RepoRoot 'Plugins\AngelscriptGAS\Source\AngelscriptGASTest'; ThemeMode = 'PrivateChild' }
)

$MethodWork = New-Object System.Collections.Generic.List[object]
$RawWork = New-Object System.Collections.Generic.List[object]
$MethodSequence = 0
$RawPattern = New-Object System.Text.RegularExpressions.Regex('R"(?<Delimiter>[A-Za-z0-9_]*)\((?<Body>.*?)\)\k<Delimiter>"', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$ClassPattern = New-Object System.Text.RegularExpressions.Regex('\bTEST_CLASS(?:_WITH_FLAGS)?\s*\(\s*([A-Za-z_]\w*)')
$MethodPattern = New-Object System.Text.RegularExpressions.Regex('\bTEST_METHOD(?:_WITH_FLAGS)?\s*\(\s*([A-Za-z_]\w*)')

foreach ($TestRoot in $TestRoots) {
    if (-not (Test-Path -LiteralPath $TestRoot.Root)) { continue }
    $Files = Get-ChildItem -LiteralPath $TestRoot.Root -Recurse -File -Filter '*.cpp' | Sort-Object FullName
    foreach ($File in $Files) {
        $Content = Normalize-Text ([System.IO.File]::ReadAllText($File.FullName))
        $RelativeToTestRoot = $File.FullName.Substring($TestRoot.Root.Length).TrimStart('\', '/').Replace('\', '/')
        $Parts = $RelativeToTestRoot.Split('/')
        if ($TestRoot.ThemeMode -eq 'First') {
            $CppTheme = if ($Parts.Count -gt 1) { $Parts[0] } else { $File.BaseName }
        }
        else {
            $PrivateIndex = [Array]::IndexOf($Parts, 'Private')
            if ($PrivateIndex -ge 0 -and $PrivateIndex + 1 -lt $Parts.Count) { $CppTheme = $Parts[$PrivateIndex + 1] }
            else { $CppTheme = $Parts[0] }
        }

        $RepoPath = Get-RelativePath $File.FullName
        $ClassMatches = $ClassPattern.Matches($Content)
        $MethodMatches = $MethodPattern.Matches($Content)
        $RawMatches = $RawPattern.Matches($Content)
        $FileMethodObjects = New-Object System.Collections.Generic.List[object]

        for ($MethodIndex = 0; $MethodIndex -lt $MethodMatches.Count; $MethodIndex++) {
            $Match = $MethodMatches[$MethodIndex]
            $EndIndex = if ($MethodIndex + 1 -lt $MethodMatches.Count) { $MethodMatches[$MethodIndex + 1].Index } else { $Content.Length }
            $ClassName = ''
            foreach ($ClassMatch in $ClassMatches) {
                if ($ClassMatch.Index -gt $Match.Index) { break }
                $ClassName = $ClassMatch.Groups[1].Value
            }
            $MethodName = $Match.Groups[1].Value
            $MethodText = $Content.Substring($Match.Index, $EndIndex - $Match.Index)
            $MethodRawMatches = @($RawMatches | Where-Object { $_.Index -ge $Match.Index -and $_.Index -lt $EndIndex })
            $MethodScriptRawMatches = @($MethodRawMatches | Where-Object {
                $PrefixStart = [Math]::Max(0, $_.Index - 80)
                $Prefix = $Content.Substring($PrefixStart, $_.Index - $PrefixStart)
                Test-ProbablyAngelScript $_.Groups['Body'].Value $Prefix $CppTheme
            })
            $LeafTheme = Get-LeafTheme $TestRoot.Module $CppTheme $RepoPath $ClassName $MethodName
            $QuestionId = Get-QuestionId $TestRoot.Module $CppTheme $LeafTheme
            $Disposition = Get-Disposition $TestRoot.Module $CppTheme $RepoPath $MethodName $MethodScriptRawMatches.Count $LeafTheme
            $MethodSequence++
            $MethodObject = [pscustomobject]@{
                MethodId = ('TM-{0:D5}' -f $MethodSequence)
                Module = $TestRoot.Module
                CppTheme = $CppTheme
                Path = $RepoPath
                TestClass = $ClassName
                TestMethod = $MethodName
                StartIndex = $Match.Index
                EndIndex = $EndIndex
                StartLine = Get-LineNumber $Content $Match.Index
                RawBlockCount = $MethodRawMatches.Count
                ScriptCandidateCount = $MethodScriptRawMatches.Count
                LeafThemeId = $LeafTheme
                QuestionId = $QuestionId
                Disposition = $Disposition
                DispositionReason = Get-DispositionReason $Disposition $CppTheme $LeafTheme
                OracleHints = Get-OracleHints $MethodText
                ReferenceIds = New-Object System.Collections.Generic.List[string]
            }
            $MethodWork.Add($MethodObject)
            $FileMethodObjects.Add($MethodObject)
        }

        foreach ($RawMatch in $RawMatches) {
            $Owner = $null
            foreach ($Candidate in $FileMethodObjects) {
                if ($RawMatch.Index -ge $Candidate.StartIndex -and $RawMatch.Index -lt $Candidate.EndIndex) {
                    $Owner = $Candidate
                    break
                }
            }
            $Association = if ($null -ne $Owner) { 'NearestTestMethodSpan' } else { 'FileScopeOrHelper' }
            $Body = Normalize-Text $RawMatch.Groups['Body'].Value
            $PrefixStart = [Math]::Max(0, $RawMatch.Index - 80)
            $Prefix = $Content.Substring($PrefixStart, $RawMatch.Index - $PrefixStart)
            $IsScriptCandidate = Test-ProbablyAngelScript $Body $Prefix $CppTheme
            $RawDisposition = if (-not $IsScriptCandidate) { 'DuplicateReference' } elseif ($null -ne $Owner) { $Owner.Disposition } elseif ($CppTheme -eq 'AngelScriptSDK') { 'ReferenceOnlyNativeSDK' } elseif ($CppTheme -in @('Cache','Core','Dump','Editor','FileSystem','GC','Memory','Performance','RuntimeJIT','Shared','StaticJIT','Template','UHTTool','Validation')) { 'HostOnly' } else { 'DuplicateReference' }
            $RawWork.Add([pscustomobject]@{
                Module = $TestRoot.Module
                CppTheme = $CppTheme
                Path = $RepoPath
                TestClass = if ($null -ne $Owner) { $Owner.TestClass } else { '' }
                TestMethod = if ($null -ne $Owner) { $Owner.TestMethod } else { '' }
                MethodId = if ($null -ne $Owner) { $Owner.MethodId } else { '' }
                Association = $Association
                Index = $RawMatch.Index
                StartLine = Get-LineNumber $Content $RawMatch.Index
                EndLine = Get-LineNumber $Content ($RawMatch.Index + $RawMatch.Length)
                Delimiter = $RawMatch.Groups['Delimiter'].Value
                Body = $Body
                IsScriptCandidate = $IsScriptCandidate
                Sha256 = Get-Sha256 $Body
                FirstMeaningfulLine = Get-FirstMeaningfulLine $Body
                DeclaredSymbols = Get-DeclaredSymbols $Body
                OracleHints = if ($null -ne $Owner) { $Owner.OracleHints } else { '' }
                LeafThemeId = if ($null -ne $Owner) { $Owner.LeafThemeId } else { Get-LeafTheme $TestRoot.Module $CppTheme $RepoPath '' '' }
                QuestionId = if ($null -ne $Owner) { $Owner.QuestionId } else { Get-QuestionId $TestRoot.Module $CppTheme (Get-LeafTheme $TestRoot.Module $CppTheme $RepoPath '' '') }
                Disposition = $RawDisposition
                DispositionReason = if (-not $IsScriptCandidate) { 'Raw string does not match the AngelScript candidate contract; retain it for audit but do not emit a source task.' } elseif ($null -ne $Owner) { $Owner.DispositionReason } else { 'Raw block is outside a TEST_METHOD span or belongs to a shared helper; retain as reference without emitting a duplicate task.' }
                Owner = $Owner
            })
        }
    }
}

$RawWorkSorted = @($RawWork | Sort-Object Module, Path, Index)
$ReferenceRows = New-Object System.Collections.Generic.List[object]
$PlannedRows = New-Object System.Collections.Generic.List[object]
$ReferenceSequence = 0
$TaskCounters = @{}
$TargetPaths = @{}

function Get-TaskPrefix([string]$LeafTheme) {
    if ($LeafTheme -like 'Language.*') { return 'TS-LANG' }
    if ($LeafTheme -like 'Definitions.*') { return 'TS-DEF' }
    if ($LeafTheme -like 'Containers.*') { return 'TS-CONT' }
    if ($LeafTheme -like 'Feature.*') { return 'TS-FEAT' }
    if ($LeafTheme -like 'World.*') { return 'TS-WORLD' }
    if ($LeafTheme -like 'Gameplay.*') { return 'TS-GAME' }
    if ($LeafTheme -like 'Optional.*') { return 'TS-OPT' }
    if ($LeafTheme -eq 'HotReload') { return 'TS-HR' }
    if ($LeafTheme -eq 'Debugger') { return 'TS-DBG' }
    return 'TS-MISC'
}

function Get-SourceTheme([string]$LeafTheme) {
    if ($LeafTheme -in @('HotReload','Debugger','Bindings','TestFramework')) { return $LeafTheme }
    return $LeafTheme.Split('.')[0]
}

function Get-EvidenceTheme([string]$Module, [string]$CppTheme, [string]$LeafTheme) {
    if ($Module -in @('GameplayTags','GAS')) { return 'Optional' }
    if ($CppTheme -eq 'Bindings') { return 'Bindings' }
    if ($CppTheme -eq 'Testing') { return 'TestFramework' }
    return Get-SourceTheme $LeafTheme
}

function Test-RequiresWorld([string]$Body, [string]$OracleHints) {
    $Key = "$Body $OracleHints"
    return $Key -match '(?i):\s*AActor\b|:\s*UActorComponent\b|SpawnActor|SpawnComponent|FAngelscriptTestWorld|CreateTestWorld|DispatchActorTick|BeginPlay\s*\(|GetTestWorld|DestroyAndDrain'
}

function Get-SourceShape([string]$LeafTheme, [string]$MethodName, [string]$Body, [string]$OracleHints) {
    $Key = "$MethodName $Body $OracleHints"
    if ($LeafTheme -eq 'HotReload') { return 'VersionPair' }
    if ($LeafTheme -eq 'Debugger') { return 'DebuggerMarker' }
    if ($Key -match '(?i)ExpectCompileFailure|CompileFailure|ExpectedError|Reject|Invalid|Unsupported|MustFail|Negative') { return 'NegativeDiagnostic' }
    if ($LeafTheme -like 'World.*' -or $LeafTheme -like 'Optional.*') { return 'WorldStory' }
    return 'Positive'
}

function Get-TargetPath([object]$Raw, [string]$ReferenceId, [int]$BlockOrdinal, [int]$MethodBlockCount) {
    $Leaf = $Raw.LeafThemeId
    $MethodSafe = Get-SafeName $Raw.TestMethod
    if ($Leaf -eq 'HotReload') {
        $Member = if ($MethodBlockCount -eq 2 -and $BlockOrdinal -eq 1) { 'Before' } elseif ($MethodBlockCount -eq 2 -and $BlockOrdinal -eq 2) { 'After' } else { 'Version_{0:D2}' -f $BlockOrdinal }
        $Candidate = "TestSource/HotReload/$MethodSafe/$Member.as"
    }
    elseif ($Leaf -eq 'Debugger') {
        $Candidate = "TestSource/Debugger/$MethodSafe/Test_Block_{0:D2}.as" -f $BlockOrdinal
    }
    elseif ($Leaf -like 'Optional.*') {
        $OptionalName = $Leaf.Split('.')[1]
        $FileName = if ($MethodBlockCount -gt 1) { "Test_${MethodSafe}_{0:D2}.as" -f $BlockOrdinal } else { "Test_${MethodSafe}.as" }
        $Candidate = "TestSource/Optional/$OptionalName/$($Raw.CppTheme)/$FileName"
    }
    else {
        if (-not $ThemeById.ContainsKey($Leaf)) { throw "Unregistered leaf theme: $Leaf" }
        $FileName = if ($MethodBlockCount -gt 1) { "Test_${MethodSafe}_{0:D2}.as" -f $BlockOrdinal } else { "Test_${MethodSafe}.as" }
        $Candidate = "$($ThemeById[$Leaf].TargetRoot)/$FileName"
    }

    if ($TargetPaths.ContainsKey($Candidate)) {
        $Base = [System.IO.Path]::GetFileNameWithoutExtension($Candidate)
        $Dir = $Candidate.Substring(0, $Candidate.LastIndexOf('/'))
        $Candidate = "$Dir/${Base}_$($ReferenceId.Replace('REF-AS-', 'R')).as"
    }
    $TargetPaths[$Candidate] = $ReferenceId
    return $Candidate
}

function Get-InputsAndSetup([string]$Leaf, [string]$Shape, [bool]$RequiresWorld) {
    if ($Shape -eq 'NegativeDiagnostic') { return 'Use the exact failing declarations and minimal prerequisite declarations from the referenced block; isolate unrelated positives.' }
    if ($RequiresWorld) { return 'Runner creates the deterministic World and required Actor/Component/UObject fixture, loads the exact semantic source, and drives only the lifecycle phases named by the C++ oracle.' }
    if ($Leaf -like 'World.*') { return 'Runner creates the deterministic World and required Actor/Component/Subsystem fixture, then supplies or locates the named script type.' }
    if ($Leaf -like 'Optional.*') { return 'Runner creates the optional-plugin module, World, UObject/ASC/tag fixtures, and deterministic initial state required by the referenced method.' }
    if ($Leaf -eq 'HotReload') { return 'Load the version members in recorded order; snapshot instance/module state before applying the next version.' }
    if ($Leaf -eq 'Debugger') { return 'Compile the source at a stable virtual path and stop only at named marker lines; driver owns the debug session.' }
    if ($Leaf -like 'Containers.*') { return 'Use explicit empty, populated, copied, and boundary containers matching the referenced AS declarations.' }
    if ($Leaf -like 'Definitions.*') { return 'Compile the exact reflected definition and supply deterministic metadata, instance, or dispatch inputs required by the C++ oracle.' }
    return 'Use the literal values, declarations, overloads, and initial state from the referenced block; add one meaningful default/empty and one boundary input when applicable.'
}

function Get-ExpectedResults([object]$Raw, [string]$Shape) {
    $Hint = Collapse-Text $Raw.OracleHints 700
    $Prefix = if ($Hint) { "Preserve these C++ oracle hints: $Hint. " } else { 'Derive the exact oracle from the referenced TEST_METHOD and raw block. ' }
    if ($Shape -eq 'NegativeDiagnostic') { return $Prefix + 'Verify failure phase, diagnostic meaning, source identity, and expected diagnostic count; successful compilation/execution is failure.' }
    if ($Raw.LeafThemeId -like 'Containers.*') { return $Prefix + 'Publish exact size, element values, ordering, duplicate/empty behavior, copy independence or aliasing, and every out/inout writeback used by the scenario.' }
    if ($Raw.LeafThemeId -like 'World.*' -or $Raw.LeafThemeId -like 'Optional.*') { return $Prefix + 'Publish exact phase order, callback count, object identity, state transition, destruction result, and cleanup-visible final state.' }
    if ($Raw.LeafThemeId -eq 'HotReload') { return $Prefix + 'Compare retained state, replaced type/function/property shape, last-good behavior after failure, generation identity, and cleanup after the transition.' }
    if ($Raw.LeafThemeId -eq 'Debugger') { return $Prefix + 'Verify marker line, stack frames, locals/watches and step sequence through the external C++/DAP oracle.' }
    return $Prefix + 'Publish every non-void return, Boolean false/true result, out/inout value, identity, ordering, side effect, or diagnostic needed to distinguish an incorrect implementation.'
}

function Get-KnowledgeCommentFocus([object]$Raw, [string]$Shape) {
    $Symbols = if ($Raw.DeclaredSymbols) { $Raw.DeclaredSymbols } else { '<no declaration hint; inspect reference body>' }
    return "Explain why the scenario uses $($Raw.LeafThemeId), inputs chosen from $($Raw.TestMethod), exact oracle, ownership/failure meaning, and declarations: $Symbols."
}

$MethodBlockOrdinals = @{}
foreach ($Raw in $RawWorkSorted) {
    $ReferenceSequence++
    $ReferenceId = 'REF-AS-{0:D5}' -f $ReferenceSequence
    $MethodKey = if ($Raw.MethodId) { $Raw.MethodId } else { "$($Raw.Path):file-scope" }
    if (-not $MethodBlockOrdinals.ContainsKey($MethodKey)) { $MethodBlockOrdinals[$MethodKey] = 0 }
    $MethodBlockOrdinals[$MethodKey]++
    $BlockOrdinal = $MethodBlockOrdinals[$MethodKey]
    $TaskId = ''
    $TargetPath = ''

    if ($Raw.Disposition -eq 'PlanHandwrittenSource' -and $Raw.MethodId -and $Raw.IsScriptCandidate) {
        $Prefix = Get-TaskPrefix $Raw.LeafThemeId
        if (-not $TaskCounters.ContainsKey($Prefix)) { $TaskCounters[$Prefix] = 0 }
        $TaskCounters[$Prefix]++
        $TaskId = '{0}-{1:D4}' -f $Prefix, $TaskCounters[$Prefix]
        $TargetPath = Get-TargetPath $Raw $ReferenceId $BlockOrdinal $Raw.Owner.RawBlockCount
        $RequiresWorld = Test-RequiresWorld $Raw.Body $Raw.OracleHints
        $Shape = Get-SourceShape $Raw.LeafThemeId $Raw.TestMethod $Raw.Body $Raw.OracleHints
        if ($RequiresWorld -and $Shape -eq 'Positive') { $Shape = 'WorldStory' }
        $EffectiveQuestion = if ($RequiresWorld -and $Shape -ne 'NegativeDiagnostic' -and $Raw.QuestionId -notin @('reload-generation','host-machinery')) { 'world-story' } else { $Raw.QuestionId }
        $ExecutionPolicy = if ($Shape -eq 'NegativeDiagnostic') { 'DiagnosticOnly' } elseif ($Raw.LeafThemeId -eq 'Debugger') { 'DiagnosticOnly' } elseif ($RequiresWorld -or $Raw.LeafThemeId -eq 'HotReload' -or $Raw.LeafThemeId -like 'World.*' -or $Raw.LeafThemeId -like 'Optional.*') { 'FixtureIsolated' } else { 'DefaultSafe' }
        $Cleanup = if ($ExecutionPolicy -eq 'FixtureIsolated') { 'Runner owns teardown on success, failure, expected diagnostic, timeout, and early exit; destroy World objects and restore module/global state.' } else { 'Source owns only local values; runner releases compiled module and any explicitly supplied object after observation.' }
        $PlannedRows.Add([pscustomobject][ordered]@{
            TaskId = $TaskId
            ThemeId = Get-SourceTheme $Raw.LeafThemeId
            LeafThemeId = $Raw.LeafThemeId
            QuestionId = $EffectiveQuestion
            TargetPath = $TargetPath
            SourceShape = $Shape
            AuthoringMode = 'Handwritten'
            ReferenceIds = $ReferenceId
            ReferencePoint = "$($Raw.Path) :: $($Raw.TestClass) :: $($Raw.TestMethod) :: block $BlockOrdinal :: lines $($Raw.StartLine)-$($Raw.EndLine) :: sha256=$($Raw.Sha256)"
            PlannedSymbols = $Raw.DeclaredSymbols
            TestScope = "Extract the exact block for $($Raw.TestMethod) ($($Raw.FirstMeaningfulLine)); preserve all declarations and the scenario represented by raw block $BlockOrdinal of $($Raw.Owner.RawBlockCount)."
            InputsAndSetup = Get-InputsAndSetup $Raw.LeafThemeId $Shape $RequiresWorld
            ExpectedResultsOrEffects = Get-ExpectedResults $Raw $Shape
            BoundaryAndNegativeCases = if ($Shape -eq 'NegativeDiagnostic') { 'Keep the failing construct minimal and add only the positive prerequisite needed to prove the diagnostic boundary.' } else { 'Cover applicable default/empty, nominal, boundary, false/null/failure, repeat-call, copy/alias, and ordering dimensions; record non-applicable dimensions explicitly.' }
            FixtureOwner = if ($ExecutionPolicy -eq 'FixtureIsolated') { 'Future C++ runner' } else { 'Pure-value source or future C++ runner inputs' }
            CleanupOwnerAndAction = $Cleanup
            ExecutionPolicy = $ExecutionPolicy
            KnowledgeCommentFocus = Get-KnowledgeCommentFocus $Raw $Shape
            ExplicitExclusions = 'Do not replace existing C++ driver/oracle, add runner integration, generate C++ inline code, or claim compile/execute success in this source-only phase.'
            BlockedBy = ''
            AcceptanceState = 'PlannedNotMaterialized'
        })
    }

    if ($Raw.Owner -and $TaskId) { $Raw.Owner.ReferenceIds.Add($ReferenceId) }
    elseif ($Raw.Owner) { $Raw.Owner.ReferenceIds.Add($ReferenceId) }

    $ReferenceRows.Add([pscustomobject][ordered]@{
        ReferenceId = $ReferenceId
        EvidenceKind = 'CppRawStringCandidate'
        ThemeId = Get-EvidenceTheme $Raw.Module $Raw.CppTheme $Raw.LeafThemeId
        Module = $Raw.Module
        CppTheme = $Raw.CppTheme
        Path = $Raw.Path
        TestClass = $Raw.TestClass
        TestMethod = $Raw.TestMethod
        MethodId = $Raw.MethodId
        Association = $Raw.Association
        BlockOrdinal = $BlockOrdinal
        StartLine = $Raw.StartLine
        EndLine = $Raw.EndLine
        Delimiter = $Raw.Delimiter
        IsScriptCandidate = $Raw.IsScriptCandidate
        Sha256 = $Raw.Sha256
        FirstMeaningfulLine = $Raw.FirstMeaningfulLine
        DeclaredSymbols = $Raw.DeclaredSymbols
        OracleHints = $Raw.OracleHints
        Disposition = $Raw.Disposition
        DispositionReason = $Raw.DispositionReason
        LeafThemeId = $Raw.LeafThemeId
        QuestionId = $Raw.QuestionId
        TargetTaskId = $TaskId
        TargetPath = $TargetPath
    })
}

foreach ($ScriptRootInfo in @(
    [pscustomobject]@{ Root = Join-Path $RepoRoot 'Script'; Module = 'HostScript'; Disposition = 'ReferenceOnlyTeaching' },
    [pscustomobject]@{ Root = Join-Path $RepoRoot 'TestSource'; Module = 'TestSource'; Disposition = 'ExistingTestSource' }
)) {
    if (-not (Test-Path -LiteralPath $ScriptRootInfo.Root)) { continue }
    foreach ($File in (Get-ChildItem -LiteralPath $ScriptRootInfo.Root -Recurse -File -Filter '*.as' | Sort-Object FullName)) {
        $ReferenceSequence++
        $Body = Normalize-Text ([System.IO.File]::ReadAllText($File.FullName))
        $RepoPath = Get-RelativePath $File.FullName
        $Top = @($File.FullName.Substring($ScriptRootInfo.Root.Length).TrimStart('\', '/') -split '[\\/]')[0]
        $Leaf = if ($ScriptRootInfo.Module -eq 'TestSource') { $Top } else { 'HostScript' }
        $ReferenceRows.Add([pscustomobject][ordered]@{
            ReferenceId = 'REF-AS-{0:D5}' -f $ReferenceSequence
            EvidenceKind = 'IndependentAsFile'
            ThemeId = if ($ScriptRootInfo.Module -eq 'TestSource') { $Top } else { 'HostScript' }
            Module = $ScriptRootInfo.Module
            CppTheme = $Top
            Path = $RepoPath
            TestClass = ''
            TestMethod = ''
            MethodId = ''
            Association = 'IndependentSource'
            BlockOrdinal = 1
            StartLine = 1
            EndLine = (Normalize-Text $Body).Split("`n").Count
            Delimiter = 'file'
            Sha256 = Get-Sha256 $Body
            FirstMeaningfulLine = Get-FirstMeaningfulLine $Body
            DeclaredSymbols = Get-DeclaredSymbols $Body
            OracleHints = ''
            Disposition = $ScriptRootInfo.Disposition
            DispositionReason = if ($ScriptRootInfo.Module -eq 'TestSource') { 'Materialized source tracked by the existing Bindings/TestFramework implementation review.' } else { 'Host teaching/project test file remains under Script and is not copied wholesale into TestSource.' }
            LeafThemeId = $Leaf
            QuestionId = if ($ScriptRootInfo.Module -eq 'TestSource') { 'existing-source' } else { 'world-story-or-teaching' }
            TargetTaskId = ''
            TargetPath = if ($ScriptRootInfo.Module -eq 'TestSource') { $RepoPath } else { '' }
        })
    }
}

$MethodRows = @($MethodWork | Sort-Object Module, Path, StartIndex | ForEach-Object {
    [pscustomobject][ordered]@{
        MethodId = $_.MethodId
        Module = $_.Module
        CppTheme = $_.CppTheme
        Path = $_.Path
        TestClass = $_.TestClass
        TestMethod = $_.TestMethod
        StartLine = $_.StartLine
        RawBlockCount = $_.RawBlockCount
        ScriptCandidateCount = $_.ScriptCandidateCount
        ReferenceIds = ($_.ReferenceIds -join ';')
        ThemeId = Get-EvidenceTheme $_.Module $_.CppTheme $_.LeafThemeId
        LeafThemeId = $_.LeafThemeId
        QuestionId = $_.QuestionId
        Disposition = $_.Disposition
        DispositionReason = $_.DispositionReason
        OracleHints = $_.OracleHints
    }
})

$NonSourceRows = New-Object System.Collections.Generic.List[object]
foreach ($Method in $MethodRows) {
    if ($Method.Disposition -ne 'PlanHandwrittenSource' -and $Method.Disposition -ne 'ExistingTestSource') {
        $NonSourceRows.Add([pscustomobject][ordered]@{
            EvidenceKind = 'TestMethod'
            EvidenceId = $Method.MethodId
            Module = $Method.Module
            ThemeId = $Method.ThemeId
            Path = $Method.Path
            TestClass = $Method.TestClass
            TestMethod = $Method.TestMethod
            Disposition = $Method.Disposition
            Reason = $Method.DispositionReason
            LeafThemeId = $Method.LeafThemeId
            ReferenceIds = $Method.ReferenceIds
        })
    }
}
foreach ($Reference in $ReferenceRows) {
    if ($Reference.Disposition -in @('HostOnly','DuplicateReference','GeneratedLater','Blocked','ReferenceOnlyNativeSDK','ReferenceOnlyTeaching')) {
        $NonSourceRows.Add([pscustomobject][ordered]@{
            EvidenceKind = $Reference.EvidenceKind
            EvidenceId = $Reference.ReferenceId
            Module = $Reference.Module
            ThemeId = $Reference.ThemeId
            Path = $Reference.Path
            TestClass = $Reference.TestClass
            TestMethod = $Reference.TestMethod
            Disposition = $Reference.Disposition
            Reason = $Reference.DispositionReason
            LeafThemeId = $Reference.LeafThemeId
            ReferenceIds = $Reference.ReferenceId
        })
    }
}

$DuplicateTaskIds = @($PlannedRows | Group-Object TaskId | Where-Object Count -ne 1)
$DuplicateTargets = @($PlannedRows | Group-Object TargetPath | Where-Object Count -ne 1)
$DuplicateReferences = @($ReferenceRows | Group-Object ReferenceId | Where-Object Count -ne 1)
if ($DuplicateTaskIds.Count -gt 0) { throw "Duplicate TaskId detected: $($DuplicateTaskIds.Name -join ', ')" }
if ($DuplicateTargets.Count -gt 0) { throw "Duplicate TargetPath detected: $($DuplicateTargets.Name -join ', ')" }
if ($DuplicateReferences.Count -gt 0) { throw "Duplicate ReferenceId detected: $($DuplicateReferences.Name -join ', ')" }

Write-GeneratedFile (Join-Path $InventoryRoot 'theme-registry.csv') (Convert-RowsToCsv @($ThemeRows | Sort-Object ThemeId))
Write-GeneratedFile (Join-Path $InventoryRoot 'current-test-methods.csv') (Convert-RowsToCsv $MethodRows)
Write-GeneratedFile (Join-Path $InventoryRoot 'current-script-references.csv') (Convert-RowsToCsv @($ReferenceRows | Sort-Object ReferenceId))
Write-GeneratedFile (Join-Path $InventoryRoot 'planned-theme-sources.csv') (Convert-RowsToCsv @($PlannedRows | Sort-Object ThemeId, LeafThemeId, TaskId))
Write-GeneratedFile (Join-Path $InventoryRoot 'host-only-dispositions.csv') (Convert-RowsToCsv @($NonSourceRows | Sort-Object Disposition, Module, Path, TestMethod, EvidenceId))

$SummaryRows = New-Object System.Collections.Generic.List[object]
$AllTopThemes = @('Bindings','TestFramework','Language','Definitions','Containers','Feature','World','Gameplay','Optional','HotReload','Debugger','Generation')
foreach ($TopTheme in $AllTopThemes) {
    $ThemeMethods = @($MethodRows | Where-Object ThemeId -eq $TopTheme)
    $ThemeRefs = @($ReferenceRows | Where-Object ThemeId -eq $TopTheme)
    $ThemePlans = @($PlannedRows | Where-Object ThemeId -eq $TopTheme)
    $SummaryRows.Add([pscustomobject][ordered]@{
        ThemeId = $TopTheme
        TestMethods = $ThemeMethods.Count
        References = $ThemeRefs.Count
        PlannedHandwrittenSources = $ThemePlans.Count
        ExistingMaterializedSources = @($ThemeRefs | Where-Object { $_.Disposition -eq 'ExistingTestSource' -and $_.Module -eq 'TestSource' }).Count
        ExistingDriverReferences = @($ThemeRefs | Where-Object { $_.Disposition -eq 'ExistingTestSource' -and $_.Module -ne 'TestSource' }).Count
        HostOnly = @($ThemeRefs | Where-Object Disposition -eq 'HostOnly').Count
        GeneratedLater = @($ThemeRefs | Where-Object Disposition -eq 'GeneratedLater').Count
        Blocked = @($ThemeRefs | Where-Object Disposition -eq 'Blocked').Count
        ReferenceOnly = @($ThemeRefs | Where-Object { $_.Disposition -like 'ReferenceOnly*' }).Count
    })
}
$Summary = [pscustomobject][ordered]@{
    GeneratedAtUtc = 'deterministic-source-scan-no-wall-clock'
    CoreCppFiles = @(Get-ChildItem -LiteralPath $TestRoots[0].Root -Recurse -File -Filter '*.cpp').Count
    GameplayTagsCppFiles = @(Get-ChildItem -LiteralPath $TestRoots[1].Root -Recurse -File -Filter '*.cpp').Count
    GASCppFiles = @(Get-ChildItem -LiteralPath $TestRoots[2].Root -Recurse -File -Filter '*.cpp').Count
    TestMethods = $MethodRows.Count
    RawStringCandidates = $RawWorkSorted.Count
    IndependentScriptReferences = @($ReferenceRows | Where-Object EvidenceKind -eq 'IndependentAsFile').Count
    PlannedHandwrittenSources = $PlannedRows.Count
    ExistingTestSourceFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'TestSource') -Recurse -File -Filter '*.as').Count
    ThemeSummary = @($SummaryRows | ForEach-Object { $_ })
}
Write-GeneratedJsonFile (Join-Path $InventoryRoot 'theme-coverage-summary.json') $Summary

$MatrixNames = [ordered]@{
    Language = '10-language.md'
    Definitions = '11-definitions.md'
    Containers = '12-containers.md'
    Feature = '13-feature.md'
    World = '14-world.md'
    Gameplay = '15-gameplay.md'
    Optional = '16-optional.md'
    HotReload = '17-hotreload.md'
    Debugger = '18-debugger.md'
}
foreach ($Entry in $MatrixNames.GetEnumerator()) {
    $TopTheme = $Entry.Key
    $Builder = New-Object System.Text.StringBuilder
    [void]$Builder.AppendLine("# $TopTheme TestSource planning matrix")
    [void]$Builder.AppendLine()
    [void]$Builder.AppendLine('This matrix is generated from `inventory/current-test-methods.csv`, `current-script-references.csv`, and `planned-theme-sources.csv`. It records planning only; no target `.as` file is materialized by this change.')
    [void]$Builder.AppendLine()
    [void]$Builder.AppendLine('| Leaf theme | Methods | References | Planned handwritten `.as` | Host-only | Generated later | Blocked |')
    [void]$Builder.AppendLine('|---|---:|---:|---:|---:|---:|---:|')
    $LeafIds = @($ThemeRows | Where-Object { (Get-SourceTheme $_.ThemeId) -eq $TopTheme -and $_.ThemeKind -ne 'Tooling' } | Select-Object -ExpandProperty ThemeId | Sort-Object)
    if ($LeafIds.Count -eq 0 -and $TopTheme -in @('HotReload','Debugger')) { $LeafIds = @($TopTheme) }
    foreach ($LeafId in $LeafIds) {
        $Methods = @($MethodRows | Where-Object { $_.ThemeId -eq $TopTheme -and $_.LeafThemeId -eq $LeafId })
        $Refs = @($ReferenceRows | Where-Object { $_.ThemeId -eq $TopTheme -and $_.LeafThemeId -eq $LeafId })
        $Plans = @($PlannedRows | Where-Object LeafThemeId -eq $LeafId)
        [void]$Builder.AppendLine("| ``$LeafId`` | $($Methods.Count) | $($Refs.Count) | $($Plans.Count) | $(@($Refs | Where-Object Disposition -eq 'HostOnly').Count) | $(@($Refs | Where-Object Disposition -eq 'GeneratedLater').Count) | $(@($Refs | Where-Object Disposition -eq 'Blocked').Count) |")
    }
    [void]$Builder.AppendLine()
    [void]$Builder.AppendLine('## Planned source tasks')
    [void]$Builder.AppendLine()
    $ThemePlans = @($PlannedRows | Where-Object ThemeId -eq $TopTheme | Sort-Object LeafThemeId, TaskId)
    if ($ThemePlans.Count -eq 0) {
        [void]$Builder.AppendLine('No handwritten source task is currently emitted. Check reference dispositions for host-only, generated-later, blocked, or already materialized evidence.')
    }
    else {
        [void]$Builder.AppendLine('| Task | Target | Reference | Scope |')
        [void]$Builder.AppendLine('|---|---|---|---|')
        foreach ($Plan in $ThemePlans) {
            [void]$Builder.AppendLine("| ``$($Plan.TaskId)`` | ``$($Plan.TargetPath)`` | ``$($Plan.ReferenceIds)`` | $(Collapse-Text $Plan.TestScope 220) |")
        }
    }
    Write-GeneratedFile (Join-Path $MatricesRoot $Entry.Value) $Builder.ToString()
}

$TaskBuilder = New-Object System.Text.StringBuilder
[void]$TaskBuilder.AppendLine('<!-- BEGIN GENERATED TESTSOURCE THEME TASKS -->')
[void]$TaskBuilder.AppendLine()
[void]$TaskBuilder.AppendLine('## 11. TestSource full-theme planning record')
[void]$TaskBuilder.AppendLine()
[void]$TaskBuilder.AppendLine('- [x] 11.1 <!-- Non-TDD --> Define the canonical TestSource theme registry, theme kinds, unique-source ownership, allowed dispositions, and Bindings/TestFramework specialization in proposal, design, research, and `as-test-source-theme-coverage` spec.')
[void]$TaskBuilder.AppendLine('- [x] 11.2 <!-- Non-TDD --> Scan every current core, GameplayTags, and GAS `TEST_METHOD`, every candidate C++ raw-string block, every `Script/**/*.as`, and every materialized `TestSource/**/*.as`; record stable method/reference identities and explicit dispositions.')
[void]$TaskBuilder.AppendLine('- [x] 11.3 <!-- Non-TDD --> Generate `theme-registry.csv`, `current-test-methods.csv`, `current-script-references.csv`, `planned-theme-sources.csv`, `host-only-dispositions.csv`, `theme-coverage-summary.json`, and theme matrices from the deterministic source scan.')
[void]$TaskBuilder.AppendLine('- [x] 11.4 <!-- Non-TDD --> Record ownership reconciliation for direction-map, data-driven harness, HotReload corpus, source generation, legacy script-corpus, and host `Script/**` without modifying sibling changes.')
[void]$TaskBuilder.AppendLine('- [x] 11.5 <!-- Non-TDD --> Verify generated planning artifacts with `scripts/BuildTestSourceThemeInventory.ps1 -Check`, uniqueness checks, strict OpenSpec validation, and a git scope audit limited to this change.')

$TaskSections = [ordered]@{
    Language = 12
    Definitions = 13
    Containers = 14
    Feature = 15
    World = 16
    Gameplay = 17
    Optional = 18
    HotReload = 19
    Debugger = 20
}
foreach ($Entry in $TaskSections.GetEnumerator()) {
    $Theme = $Entry.Key
    $Section = $Entry.Value
    [void]$TaskBuilder.AppendLine()
    [void]$TaskBuilder.AppendLine("## $Section. $Theme handwritten TestSource tasks")
    [void]$TaskBuilder.AppendLine()
    $ThemePlans = @($PlannedRows | Where-Object ThemeId -eq $Theme | Sort-Object LeafThemeId, TaskId)
    if ($ThemePlans.Count -eq 0) {
        [void]$TaskBuilder.AppendLine("- [ ] $Section.1 <!-- Non-TDD --> No handwritten source is currently emitted for $Theme; re-run the inventory after its blocked/generated/host-only owner changes and keep this placeholder unchecked.")
        continue
    }
    $TaskIndex = 0
    foreach ($Plan in $ThemePlans) {
        $TaskIndex++
        [void]$TaskBuilder.AppendLine("- [ ] $Section.$TaskIndex <!-- Non-TDD --> **$($Plan.TaskId)** - create ``$($Plan.TargetPath)``.")
        [void]$TaskBuilder.AppendLine("  - Theme/question: ``$($Plan.LeafThemeId)`` + ``$($Plan.QuestionId)``; source shape: ``$($Plan.SourceShape)``; authoring: ``$($Plan.AuthoringMode)``.")
        [void]$TaskBuilder.AppendLine("  - Reference point: $($Plan.ReferencePoint).")
        [void]$TaskBuilder.AppendLine("  - Planned symbols: ``$($Plan.PlannedSymbols)``.")
        [void]$TaskBuilder.AppendLine("  - Test scope: $($Plan.TestScope)")
        [void]$TaskBuilder.AppendLine("  - Inputs/setup: $($Plan.InputsAndSetup)")
        [void]$TaskBuilder.AppendLine("  - Expected observations: $($Plan.ExpectedResultsOrEffects)")
        [void]$TaskBuilder.AppendLine("  - Boundary/negative scope: $($Plan.BoundaryAndNegativeCases)")
        [void]$TaskBuilder.AppendLine("  - Fixture and cleanup: $($Plan.FixtureOwner); $($Plan.CleanupOwnerAndAction)")
        [void]$TaskBuilder.AppendLine("  - Execution policy: ``$($Plan.ExecutionPolicy)``.")
        [void]$TaskBuilder.AppendLine("  - Knowledge comments: $($Plan.KnowledgeCommentFocus)")
        [void]$TaskBuilder.AppendLine("  - Explicit exclusions: $($Plan.ExplicitExclusions)")
        [void]$TaskBuilder.AppendLine('  - Verification for the future source wave: exact path and declarations exist; reference hash is reviewed; every applicable result/effect crosses the runner boundary; source-semantic review passes before compilation/execution status changes.')
    }
}
[void]$TaskBuilder.AppendLine()
[void]$TaskBuilder.AppendLine('<!-- END GENERATED TESTSOURCE THEME TASKS -->')

$ExistingTasks = Normalize-Text ([System.IO.File]::ReadAllText($TasksPath))
$StartMarker = '<!-- BEGIN GENERATED TESTSOURCE THEME TASKS -->'
$EndMarker = '<!-- END GENERATED TESTSOURCE THEME TASKS -->'
$StartIndex = $ExistingTasks.IndexOf($StartMarker, [System.StringComparison]::Ordinal)
if ($StartIndex -ge 0) {
    $EndIndex = $ExistingTasks.IndexOf($EndMarker, $StartIndex, [System.StringComparison]::Ordinal)
    if ($EndIndex -lt 0) { throw 'Generated theme task start marker exists without end marker.' }
    $EndIndex += $EndMarker.Length
    $TaskBase = ($ExistingTasks.Substring(0, $StartIndex) + $ExistingTasks.Substring($EndIndex)).TrimEnd()
}
else {
    $TaskBase = $ExistingTasks.TrimEnd()
}
$ExpectedTasks = $TaskBase + "`n`n" + $TaskBuilder.ToString().TrimEnd() + "`n"
Write-GeneratedFile $TasksPath $ExpectedTasks

if ($Check -and $script:Drift.Count -gt 0) {
    throw ("Theme inventory drift detected:`n - " + ($script:Drift -join "`n - "))
}

$Mode = if ($Check) { 'checked' } else { 'generated' }
Write-Host "Theme inventory ${Mode}: methods=$($MethodRows.Count), raw-candidates=$($RawWorkSorted.Count), references=$($ReferenceRows.Count), planned=$($PlannedRows.Count), existing-testsource=$($Summary.ExistingTestSourceFiles)."
