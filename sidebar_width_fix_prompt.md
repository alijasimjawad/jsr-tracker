# Fix: reduce sidebar width

## Do not touch
- Do NOT modify any calculation, query, or data logic on any page — this is a pure CSS width change to the sidebar, nothing else.
- Do NOT touch the mobile drawer's slide-in behavior, collapse/expand logic, or any component in `src/pages/`.

## File
`src/components/Sidebar.module.css`

## Change
The desktop sidebar is currently wider than it needs to be. Reduce its width:

1. Find (near the top of the file, in the `.sidebar` rule):
```css
.sidebar {
  width: 284px;
  min-width: 284px;
  ...
}
```
Change `284px` to `240px` in both places.

2. Find, inside the `@media (max-width: 768px)` block near the bottom of the file, these two spots that also use `280px` (the mobile drawer width, and the `.sidebarCollapsed` override that forces full width on mobile):
```css
  .sidebar {
    position: fixed;
    ...
    width: 280px;
    min-width: 280px;
  }
  ...
  .sidebarCollapsed {
    width: 280px;
    min-width: 280px;
  }
```
Change both `280px` occurrences to `240px` as well, so the mobile drawer matches the new desktop width.

Leave the collapsed-desktop width (`80px`, in `.sidebarCollapsed` outside the media query) unchanged.

## Verify
- Run `npm run build` to confirm no errors.
- Visually confirm: sidebar is narrower, nav labels/icons still fit without wrapping or overflow, collapse/expand toggle still works, and the mobile hamburger drawer still opens at the new width.

## Commit and push
```
git add -A
git commit -m "Reduce sidebar width from 284px to 240px"
git push origin main
```
