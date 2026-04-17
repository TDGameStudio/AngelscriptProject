#pragma once

#include "Core/AngelscriptEngine.h"

struct FAngelscriptInterfaceSignatureTestAccess
{
	static int32 GetSignatureCount(const FAngelscriptEngine& Engine)
	{
		return Engine.InterfaceMethodSignatures.Num();
	}
};
