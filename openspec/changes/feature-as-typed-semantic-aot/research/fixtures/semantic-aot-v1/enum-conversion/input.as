enum ESemanticMode
{
	Disabled = 0,
	Enabled = 1
}

bool SemanticEnumEnabled(ESemanticMode Mode)
{
	return int(Mode) != 0;
}
