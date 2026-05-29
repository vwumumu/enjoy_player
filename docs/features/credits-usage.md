# Credits usage audit

## Summary

Signed-in users can open **Profile → Credits usage** (route `/credits`) to view **read-only** AI credits consumption records returned by the Enjoy Worker `GET /credits/usages` endpoint.

## Behavior

- **Auth**: `/credits` requires the same session as profile; guests are redirected to sign-in (see `app_router` redirect).
- **Base URL**: Requests use the configured **AI API base URL** (`aiApiClientProvider`), not the Rails API URL.
- **Filters**: Optional UTC `YYYY-MM-DD` start/end dates and optional service type (`tts`, `asr`, `translation`, `llm`, `assessment`), matching the web credits page.
- **Pagination**: Fixed page size (50). Next/previous adjust `offset` until a page returns fewer than `limit` rows.
- **Mobile layout** (viewport &lt; 720px): Filter card uses side-by-side date fields with theme `InputDecoration`; each log card shows one locale-aware local timestamp, a `UTC · YYYY-MM-DD` audit line, a colored allowed/denied pill, service/tier chips, and a two-column required/used-after summary. Pagination stacks page info above full-width Previous/Next buttons.

## Related

- Worker route: `apps/worker/src/routes/credits.ts`
- Web reference: `apps/web/src/routes/credits.tsx`
