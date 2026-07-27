[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..\..')).Path
}
if ([string]::IsNullOrWhiteSpace($OutputRoot))
{
	$OutputRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$RuntimeRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptRuntime'
$PublicHeader = Join-Path $RuntimeRoot 'Core\angelscript.h'
$VendoredRoot = Join-Path $RuntimeRoot 'ThirdParty\angelscript\source'
$ContextHeader = Join-Path $VendoredRoot 'as_context.h'
$FunctionHeader = Join-Path $VendoredRoot 'as_scriptfunction.h'

foreach ($RequiredPath in @($PublicHeader, $VendoredRoot, $ContextHeader, $FunctionHeader))
{
	if (-not (Test-Path -LiteralPath $RequiredPath))
	{
		throw "Required AngelScript source was not found: $RequiredPath"
	}
}

function Get-PublicOwner
{
	param([string]$Interface, [string]$Method)

	switch ($Interface)
	{
		'asIScriptEngine'
		{
			if ($Method -match '^(ParseToken)$') { return 'Frontend' }
			if ($Method -match '^(CreateContext|RequestContext|ReturnContext|SetContextCallbacks)$') { return 'Runtime' }
			if ($Method -match '^(GarbageCollect|GetGCStatistics|NotifyGarbageCollectorOfNewObject|GetObjectInGC|GCEnumCallback|ForwardGC)') { return 'Runtime' }
			if ($Method -match '^(Register|GetGlobalFunction|GetGlobalProperty|GetStringFactory|GetDefaultArray|GetEnum|GetFuncdef|GetTypedef|BeginConfigGroup|EndConfigGroup|RemoveConfigGroup|SetDefaultAccessMask|SetDefaultNamespace)') { return 'Embedding' }
			if ($Method -match '^(GetType|GetSizeOfPrimitiveType|CreateScriptObject|CreateUninitializedScriptObject|CreateDelegate|AssignScriptObject|ReleaseScriptObject|AddRefScriptObject|RefCastObject|GetWeakRefFlag)') { return 'TypeSystem' }
			if ($Method -match '^(GetModule|DiscardModule)') { return 'Module' }
			return 'Engine'
		}
		'asIScriptModule' { return 'Module' }
		'asIScriptContext' { return 'Runtime' }
		'asIScriptGeneric' { return 'Embedding' }
		'asIScriptObject' { return 'Runtime' }
		'asITypeInfo' { return 'TypeSystem' }
		'asIScriptFunction' { return 'TypeSystem' }
		'asIStringFactory' { return 'Embedding' }
		'asIBinaryStream' { return 'Module' }
		'asIJITCompiler' { return 'Compiler' }
		'asILockableSharedBool' { return 'Engine' }
		'asIThreadManager' { return 'Engine' }
		default { return 'Unassigned' }
	}
}

function Get-CoverageLinks
{
	param([string]$Owner, [string]$Interface = '', [string]$Method = '')

	$Links = [System.Collections.Generic.List[string]]::new()
	if ($Interface -eq 'asIScriptContext' -and $Method -match 'Callback|Callstack|Function|LineNumber|Var|This|PushState|PopState|IsNested')
	{
		$Links.Add('DBG-CALLBACK-STATE-PATH')
		$Links.Add('DBG-STACK-FRAME-QUERY')
		$Links.Add('DBG-LOCAL-TYPE-ROLE-QUERY')
		$Links.Add('DBG-NEST-STATE')
	}
	if ($Interface -eq 'asIScriptFunction' -and $Method -match 'Section|Module|Name|Declaration|Var|Line|ByteCode')
	{
		$Links.Add('DBG-FUNCTION-METADATA')
	}
	if ($Interface -eq 'asIScriptObject')
	{
		$Links.Add('LANG-REF-LIFETIME')
		$Links.Add('LANG-CTOR-KIND-CALL')
		$Links.Add('LANG-DTOR-OWNER-EXIT')
	}
	return @($Links | Sort-Object -Unique) -join ';'
}

function Get-UnitOwner
{
	param([string]$Name)

	if ($Name -match '^as_callfunc') { return 'Embedding' }
	if ($Name -in @('as_atomic.cpp', 'as_memory.cpp', 'as_scriptengine.cpp', 'as_thread.cpp')) { return 'Engine' }
	if ($Name -in @('as_builder.cpp', 'as_bytecode.cpp', 'as_compiler.cpp', 'as_outputbuffer.cpp')) { return 'Compiler' }
	if ($Name -in @('as_parser.cpp', 'as_scriptcode.cpp', 'as_scriptnode.cpp', 'as_string.cpp', 'as_string_util.cpp', 'as_tokenizer.cpp')) { return 'Frontend' }
	if ($Name -in @('as_context.cpp', 'as_gc.cpp', 'as_generic.cpp', 'as_scriptobject.cpp')) { return 'Runtime' }
	if ($Name -in @('as_module.cpp', 'as_restore.cpp')) { return 'Module' }
	if ($Name -in @('as_configgroup.cpp', 'as_datatype.cpp', 'as_globalproperty.cpp', 'as_objecttype.cpp', 'as_scriptfunction.cpp', 'as_typeinfo.cpp', 'as_variablescope.cpp')) { return 'TypeSystem' }
	return 'PendingReview'
}

function Get-PublicFamily
{
	param([string]$Interface, [string]$Method)

	if ($Interface -eq 'asIScriptContext' -and $Method -match '^(SetExceptionCallback|ClearExceptionCallback|SetInstructionCallback|ClearInstructionCallback|ClearLineCallback|GetCallstackSize|GetFunction|GetLineNumber|GetVarCount|GetVarName|GetVarDeclaration|GetVarTypeId|GetAddressOfVar|IsVarInScope|GetThisTypeId|GetThisPointer)$')
	{
		return 'Debug'
	}
	if ($Interface -eq 'asIScriptFunction' -and $Method -match '^(GetScriptSectionName|GetVarCount|GetVar|GetVarDecl|FindNextLineWithCode|GetByteCode)$')
	{
		return 'DebugMetadata'
	}
	if ($Method -match '^(AddRef|Release|ShutDownAndRelease|Discard|Unprepare)$') { return 'Lifecycle' }
	if ($Method -match '^(Set|Get|Clear).*(Callback|UserData)|^SetUserData$|^GetUserData$') { return 'CallbackOrUserData' }
	if ($Method -match '^(Register|BeginConfigGroup|EndConfigGroup|RemoveConfigGroup)') { return 'Registration' }
	if ($Method -match '^(AddScriptSection|Build|CompileFunction|SaveByteCode|LoadByteCode)') { return 'CompilationOrPersistence' }
	if ($Method -match '^(Prepare|Execute|Abort|Suspend|PushState|PopState|IsNested|SetArg|GetAddressOfArg)') { return 'Invocation' }
	if ($Method -match '^(GetReturn|SetReturn|GetAddressOfReturn)') { return 'ReturnValue' }
	if ($Method -match '^(GarbageCollect|GetGCStatistics|NotifyGarbageCollectorOfNewObject|GetObjectInGC|GCEnumCallback|ForwardGC)') { return 'GarbageCollector' }
	if ($Method -match '^(Get|Is|DerivesFrom|ShadowsFrom|Implements|FindNextLineWithCode)') { return 'Introspection' }
	return 'Operation'
}

$ExistingPublicById = @{}
$ExistingPublicPath = Join-Path $OutputRoot 'public-api.csv'
if (Test-Path -LiteralPath $ExistingPublicPath)
{
	foreach ($ExistingRow in Import-Csv -LiteralPath $ExistingPublicPath)
	{
		$ExistingPublicById[$ExistingRow.CoverageId] = $ExistingRow
	}
}

$PublicRows = [System.Collections.Generic.List[object]]::new()
$CurrentInterface = ''
$AwaitingBody = $false
$InBody = $false
$InScriptObjectInternalSurface = $false
$LineNumber = 0

foreach ($Line in Get-Content -LiteralPath $PublicHeader)
{
	++$LineNumber
	if (-not $InBody -and $Line -match '^class(?:\s+AS_API)?\s+(?<Interface>asI[A-Za-z0-9_]+)\s*$')
	{
		$CurrentInterface = $Matches['Interface']
		$AwaitingBody = $true
		$InScriptObjectInternalSurface = $false
		continue
	}

	if ($AwaitingBody -and $Line -match '^\{')
	{
		$AwaitingBody = $false
		$InBody = $true
		continue
	}

	if ($InBody -and $Line -match '^\};')
	{
		$CurrentInterface = ''
		$InBody = $false
		$InScriptObjectInternalSurface = $false
		continue
	}

	if ($InBody -and
		$CurrentInterface -eq 'asIScriptObject' -and
		$Line -match '^\s*/\*\s*Internal\s*\*/\s*$')
	{
		$InScriptObjectInternalSurface = $true
		continue
	}

	$IsVirtualMethod = $Line -match '^\s*virtual\s+'
	$IsScriptObjectMethod =
		$CurrentInterface -eq 'asIScriptObject' -and
		-not $InScriptObjectInternalSurface -and
		$Line -match '^\s*[A-Za-z_].*\([^;]*\)\s*(?:const\s*)?;\s*$'
	if (-not $InBody -or (-not $IsVirtualMethod -and -not $IsScriptObjectMethod))
	{
		continue
	}

	$Signature = $Line.Trim()
	$MethodMatch = [regex]::Match($Signature, '(?<Method>~?[A-Za-z_][A-Za-z0-9_]*)\s*\(')
	if (-not $MethodMatch.Success)
	{
		$MethodMatch = [regex]::Match($Signature, '(?<Method>operator[^\s(]+)\s*\(')
	}
	if (-not $MethodMatch.Success)
	{
		throw "Unable to parse public method at ${PublicHeader}:$LineNumber`: $Signature"
	}

	$Method = $MethodMatch.Groups['Method'].Value
	if ($Method.StartsWith('~'))
	{
		continue
	}

	$Owner = Get-PublicOwner -Interface $CurrentInterface -Method $Method
	$Family = Get-PublicFamily -Interface $CurrentInterface -Method $Method
	$CoverageId = ('API-{0}-{1}' -f $CurrentInterface.ToUpperInvariant(), $Method.ToUpperInvariant())
	$ExistingRow = $ExistingPublicById[$CoverageId]
	$PublicRows.Add([pscustomobject]@{
		Interface = $CurrentInterface
		Method = $Method
		Family = $Family
		OwnerDomain = $Owner
		CoverageId = $CoverageId
		Declaration = $Signature
		HeaderLine = $LineNumber
		CurrentStatus = $(if ($null -ne $ExistingRow) { $ExistingRow.CurrentStatus } else { 'PendingCoverageReview' })
		FinalCoverageIds = $(if ($null -ne $ExistingRow) { $ExistingRow.FinalCoverageIds } else { Get-CoverageLinks -Owner $Owner -Interface $CurrentInterface -Method $Method })
	})
}

$UnitRows = [System.Collections.Generic.List[object]]::new()
$InternalMethodRows = [System.Collections.Generic.List[object]]::new()
$CppFiles = @(Get-ChildItem -LiteralPath $VendoredRoot -Filter 'as_*.cpp' -File | Sort-Object Name)

foreach ($CppFile in $CppFiles)
{
	$Text = Get-Content -LiteralPath $CppFile.FullName -Raw
	$MethodMatches = [regex]::Matches(
		$Text,
		'(?m)^\s*(?:[A-Za-z_][A-Za-z0-9_:<>,*&\s]*?\s+)?(?<Class>as[A-Z][A-Za-z0-9_]*)::(?<Method>~?[A-Za-z_][A-Za-z0-9_]*)\s*\(',
		[System.Text.RegularExpressions.RegexOptions]::Multiline)
	if ($CppFile.Name -eq 'as_scriptobject.cpp')
	{
		$ScriptObjectHelperMatches = [regex]::Matches(
			$Text,
			'(?m)^\s*(?:asIScriptObject\s*&|void\s*\*)\s*(?<Class>asIScriptObject)::(?<Method>operator=|AllocateUninitializedObject)\s*\(',
			[System.Text.RegularExpressions.RegexOptions]::Multiline)
		$MethodMatches = @($MethodMatches) + @($ScriptObjectHelperMatches)
	}
	$Classes = @($MethodMatches | ForEach-Object { $_.Groups['Class'].Value } | Sort-Object -Unique)
	$LineCount = (Get-Content -LiteralPath $CppFile.FullName).Count

	$UnitOwner = Get-UnitOwner -Name $CppFile.Name
	$Disposition = if ($CppFile.Name -match '^as_callfunc_' -and $CppFile.Name -ne 'as_callfunc_x64_msvc.cpp') { 'PlatformNA' } elseif ($CppFile.Name -match '^as_callfunc') { 'ActiveBackend' } else { 'DirectAndBehavioral' }
	$UnitRows.Add([pscustomobject]@{
		ImplementationUnit = $CppFile.Name
		LineCount = $LineCount
		OutOfLineMethodCount = $MethodMatches.Count
		ConcreteClasses = ($Classes -join ';')
		OwnerDomain = $UnitOwner
		Disposition = $Disposition
		FinalCoverageIds = Get-CoverageLinks -Owner $UnitOwner
	})

	foreach ($MethodMatch in $MethodMatches)
	{
		$Line = ($Text.Substring(0, $MethodMatch.Index) -split "`n").Count
		$InternalMethodRows.Add([pscustomobject]@{
			ImplementationUnit = $CppFile.Name
			Class = $MethodMatch.Groups['Class'].Value
			Method = $MethodMatch.Groups['Method'].Value
			Line = $Line
			CurrentStatus = 'PendingCoverageReview'
			FinalCoverageIds = Get-CoverageLinks -Owner $UnitOwner
		})
	}
}

$ContextText = Get-Content -LiteralPath $ContextHeader -Raw
$FunctionText = Get-Content -LiteralPath $FunctionHeader -Raw
$ConcreteDebugNames = @(
	'GetState', 'PushState', 'PopState', 'IsNested',
	'SetException', 'GetExceptionLineNumber', 'GetExceptionFunction', 'GetExceptionString', 'WillExceptionBeCaught',
	'SetExceptionCallback', 'ClearExceptionCallback',
	'SetLineCallback', 'SetLoopDetectionCallback', 'ClearLineCallback',
	'SetStackPopCallback', 'ClearStackPopCallback',
	'SetInstructionCallback', 'ClearInstructionCallback',
	'GetCallstackSize', 'GetFunction', 'GetBlueprintCallstackFrame', 'GetLineNumber',
	'GetVarCount', 'GetVarName', 'GetVarDeclaration', 'GetVarTypeId', 'GetAddressOfVar', 'IsVarInScope',
	'GetThisTypeId', 'GetThisPointer', 'GetStackFrame', 'GetStackFrameSize'
)
$FunctionDebugNames = @(
	'GetId', 'GetFuncType', 'GetModuleName', 'GetModule', 'GetScriptSectionName',
	'GetObjectType', 'GetObjectName', 'GetName', 'GetNamespace', 'GetDeclaration',
	'GetVarCount', 'GetVar', 'GetVarDecl', 'FindNextLineWithCode', 'GetByteCode'
)
$DebugRows = [System.Collections.Generic.List[object]]::new()

foreach ($Name in $ConcreteDebugNames)
{
	$Public = @($PublicRows | Where-Object { $_.Interface -eq 'asIScriptContext' -and $_.Method -eq $Name }).Count -gt 0
	$Concrete = $ContextText -match ('\b' + [regex]::Escape($Name) + '\s*\(')
	$DebugRows.Add([pscustomobject]@{
		Surface = 'Context'
		Api = $Name
		PublicInterface = $Public
		ConcreteForkClass = $Concrete
		Classification = $(if ($Concrete) { 'CurrentFork' } else { 'ApiDeferred' })
		RequiredEvidence = $(if ($Name -match 'Callback') { 'Runtime;OrderedEvents;Cleanup' } elseif ($Name -match 'Var|This|Frame|Function|LineNumber|Callstack') { 'Runtime;Metadata;InvalidState' } else { 'Runtime' })
		CoverageId = ('DBG-CTX-{0}' -f $Name.ToUpperInvariant())
		FinalCoverageIds = $(if ($Name -match 'Callback') { 'DBG-CALLBACK-STATE-PATH' } elseif ($Name -match 'PushState|PopState|IsNested|GetState') { 'DBG-NEST-STATE' } elseif ($Name -match 'Var') { 'DBG-LOCAL-TYPE-ROLE-QUERY' } elseif ($Name -match 'This') { 'DBG-THIS-CALL-FRAME' } else { 'DBG-STACK-FRAME-QUERY' })
	})
}

$DebugRows.Add([pscustomobject]@{
	Surface = 'Context'
	Api = 'DebugFramePtr'
	PublicInterface = $false
	ConcreteForkClass = $ContextText -match '\bDebugFramePtr\b'
	Classification = 'CurrentFork'
	RequiredEvidence = 'PointerIdentity;NestedState;Cleanup'
	CoverageId = 'DBG-CTX-DEBUGFRAMEPTR'
	FinalCoverageIds = 'DBG-NEST-STATE'
})

foreach ($Name in $FunctionDebugNames)
{
	$Public = @($PublicRows | Where-Object { $_.Interface -eq 'asIScriptFunction' -and $_.Method -eq $Name }).Count -gt 0
	$Concrete = $FunctionText -match ('\b' + [regex]::Escape($Name) + '\s*\(')
	$DebugRows.Add([pscustomobject]@{
		Surface = 'Function'
		Api = $Name
		PublicInterface = $Public
		ConcreteForkClass = $Concrete
		Classification = $(if ($Concrete) { 'CurrentFork' } else { 'ApiDeferred' })
		RequiredEvidence = 'Metadata;Boundary;Rebuild'
		CoverageId = ('DBG-FN-{0}' -f $Name.ToUpperInvariant())
		FinalCoverageIds = 'DBG-FUNCTION-METADATA'
	})
}

$PublicRows | Export-Csv -LiteralPath (Join-Path $OutputRoot 'public-api.csv') -NoTypeInformation -Encoding utf8
$ExpectedInterfaces = @('asIScriptEngine', 'asIScriptModule', 'asIScriptContext', 'asIScriptGeneric', 'asIScriptObject', 'asITypeInfo', 'asIScriptFunction', 'asIBinaryStream', 'asIJITCompiler', 'asIThreadManager', 'asILockableSharedBool', 'asIStringFactory')
$InterfaceRows = foreach ($Interface in $ExpectedInterfaces)
{
	$Methods = @($PublicRows | Where-Object Interface -eq $Interface)
	[pscustomobject]@{
		Interface = $Interface
		MethodCount = $Methods.Count
		OwnerDomain = $(if ($Methods.Count -gt 0) { $Methods[0].OwnerDomain } elseif ($Interface -eq 'asIThreadManager') { 'Engine' } else { 'PendingReview' })
		Disposition = $(if ($Interface -eq 'asIThreadManager') { 'EmptyInterfaceContract' } elseif ($Interface -eq 'asIScriptObject') { 'ForkConcretePublicSurface' } else { 'PublicInterface' })
		FinalCoverageIds = Get-CoverageLinks -Owner $(if ($Methods.Count -gt 0) { $Methods[0].OwnerDomain } else { 'Engine' }) -Interface $Interface
	}
}
$InterfaceRows | Export-Csv -LiteralPath (Join-Path $OutputRoot 'public-interfaces.csv') -NoTypeInformation -Encoding utf8
$UnitRows | Export-Csv -LiteralPath (Join-Path $OutputRoot 'internal-units.csv') -NoTypeInformation -Encoding utf8
$InternalMethodRows | Sort-Object ImplementationUnit, Class, Method, Line | Export-Csv -LiteralPath (Join-Path $OutputRoot 'internal-methods.csv') -NoTypeInformation -Encoding utf8
$InternalClassRows = foreach ($ClassGroup in $InternalMethodRows | Group-Object Class | Sort-Object Name)
{
	$First = $ClassGroup.Group[0]
	[pscustomobject]@{
		Class = $ClassGroup.Name
		Kind = $(if ($ClassGroup.Name -eq 'asIScriptObject') { 'ForkConcretePublicSurface' } elseif ($ClassGroup.Name -match '^asC') { 'ConcreteInternalClass' } else { 'InternalHelperType' })
		OutOfLineMethodCount = $ClassGroup.Count
		ImplementationUnits = (@($ClassGroup.Group.ImplementationUnit | Sort-Object -Unique) -join ';')
		OwnerDomain = Get-UnitOwner -Name $First.ImplementationUnit
		Disposition = 'DirectOrBehavioralCoverageRequired'
		FinalCoverageIds = Get-CoverageLinks -Owner (Get-UnitOwner -Name $First.ImplementationUnit) -Interface $(if ($ClassGroup.Name -eq 'asIScriptObject') { 'asIScriptObject' } else { '' })
	}
}
$InternalClassRows | Export-Csv -LiteralPath (Join-Path $OutputRoot 'internal-classes.csv') -NoTypeInformation -Encoding utf8
$DebugRows | Export-Csv -LiteralPath (Join-Path $OutputRoot 'debug-api.csv') -NoTypeInformation -Encoding utf8

[pscustomobject]@{
	PublicMethods = $PublicRows.Count
	PublicInterfaces = $InterfaceRows.Count
	ImplementationUnits = $UnitRows.Count
	InternalOutOfLineMethods = $InternalMethodRows.Count
	InternalClasses = @($InternalMethodRows.Class | Sort-Object -Unique).Count
	DebugApis = $DebugRows.Count
}
