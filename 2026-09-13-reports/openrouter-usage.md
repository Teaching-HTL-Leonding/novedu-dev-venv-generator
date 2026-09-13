# OpenRouter API-key usage — 2026-09-13

Retrieved at **2026-09-13 14:15 UTC** using the supplied management key.

**No API keys with nonzero dollar usage were returned.** OpenRouter listed one accessible workspace (“Default Workspace”) and zero API-key records. The default-workspace query and a query explicitly scoped to that workspace both returned empty lists with disabled keys included. Control queries without the disabled-key filter also returned empty lists. There were no key records to paginate or include in a usage table.

The supplied token authenticated as a management key. This result describes only the account and workspace visible to that key; it does not establish usage in any other OpenRouter account. If nonzero usage was expected, the management key may belong to a different account or workspace than the keys that incurred it.

The check used OpenRouter's documented [list workspaces](https://openrouter.ai/docs/api/api-reference/workspaces/list-workspaces) and [list API keys](https://openrouter.ai/docs/api/api-reference/api-keys/list) endpoints. The management key and any key identifiers are excluded from this document.
