In `tac-app-react`, the page header is duplicated: the shared top bar already shows the page title ("My Attendance"), but the page component below it renders its own large `<h1>My Attendance</h1>` + subtitle ("Track your working hours, attendance history, and field check-ins.") again, right underneath. Remove that duplicate page-level heading block from the page component — keep only the shared top bar's title, don't touch the top bar itself.

Also update the top bar's user info corner (avatar + name) to match this reference: add a small dropdown chevron next to the name/role text (currently missing), so it reads as a clickable user menu, consistent with the reference screenshot.

This same duplicated-heading pattern likely exists on other pages too (Sites DB, Daily Activities, etc.) if they follow the same layout convention — check whether it's a shared layout wrapper each page reuses, and if so fix it once at that shared level rather than per-page; otherwise list which pages need the same removal.

After the change, typecheck (`npx tsc -b`), commit, and let me know the push command to run.
