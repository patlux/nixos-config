# ClickUp API Access

Use this when a task mentions ClickUp tickets, ClickUp task URLs, or fetching ticket details from the CLI.

## Token

The personal ClickUp API token is stored in macOS Keychain as:

```sh
PIPARO_CLICKUP_API_KEY
```

Never print, paste, log, or commit the token.

Load it into the current shell:

```sh
export CLICKUP_API_TOKEN="$(security find-generic-password -s PIPARO_CLICKUP_API_KEY -w)"
```

Verify without exposing it:

```sh
test -n "$CLICKUP_API_TOKEN" && echo "ClickUp token loaded"
```

If missing, generate a token in ClickUp:

```text
Settings → Integrations & ClickApps → ClickUp API → API Token
```

## Fetch a ticket

Ticket URLs look like:

```text
https://app.clickup.com/t/86c629u10
```

The task ID is the last path segment, for example `86c629u10`.

```sh
task_id=86c629u10

curl -sS \
  -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/task/${task_id}" | jq
```

Compact output:

```sh
curl -sS \
  -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/task/${task_id}" \
  | jq '{id, custom_id, name, status: .status.status, url, description}'
```

## Fetch tasks from a list

List URLs include the list ID:

```text
https://app.clickup.com/90151687809/v/l/li/901516573106
```

Example list ID: `901516573106`.

```sh
list_id=901516573106

curl -sS \
  -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/list/${list_id}/task?include_closed=true&subtasks=true" \
  | jq '.tasks[] | {id, name, status: .status.status, url}'
```

## Script convention

Scripts should read `CLICKUP_API_TOKEN` from the environment. macOS-only local helpers may load Keychain as a fallback:

```sh
: "${CLICKUP_API_TOKEN:=$(security find-generic-password -s PIPARO_CLICKUP_API_KEY -w 2>/dev/null)}"
export CLICKUP_API_TOKEN
```

CI should use its own secret store and set `CLICKUP_API_TOKEN` directly.
