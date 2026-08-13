class UReceiver
{
	int Value;
}

void SemanticExternalInit(UReceiver Receiver) external_implicit_this
{
	Value = 7;
}
