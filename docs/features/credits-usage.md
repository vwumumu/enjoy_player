# Credits usage audit

## Summary

Signed-in users can open **Profile → Credits usage** (route `/credits`) to view **read-only** AI credits consumption records returned by the Enjoy Worker `GET /credits/usages` endpoint.

## Behavior

- **Auth**: `/credits` requires the same session as profile; guests are redirected to sign-in (see `app_router` redirect).
- **Base URL**: Requests use the configured **AI API base URL** (`aiApiClientProvider`), not the Rails API URL.
- **Filters**: Optional UTC `YYYY-MM-DD` start/end dates and optional service type (`tts`, `asr`, `translation`, `llm`, `assessment`), matching the web credits page.
- **Pagination**: Fixed page size (50). Next/previous adjust `offset` until a page returns fewer than `limit` rows.

## Related

- Worker route: `apps/worker/src/routes/credits.ts`
- Web reference: `apps/web/src/routes/credits.tsx`
