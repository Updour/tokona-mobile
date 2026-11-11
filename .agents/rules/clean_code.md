# Clean Code & Architectural Rules

## 1. Absolute File Size Limit (<= 300 LOC)
- No code file may exceed 300 lines of code.
- If a file reaches 250 lines, decompose it immediately into sub-files.

## 2. Senior Engineering Style & Anti-AI Guidelines
- No relative parent imports (`../../../`). Always use `package:pos_app/...`.
- No AI emojis (✅, 🎉, ⚡, ❌, ☕, 🛒) in snackbars, dialogs, titles, or comments.
- No numbered robotic commentary (`// 1.`, `// 2.`). Code should be self-documenting.
- No Drawer menus. Use ergonomic bottom navigation.

## 3. Dynamic RBAC
- Roles define specific feature keys.
- Super Admin configures tenant-level modules.
- Store Owner configures role-level permissions for their staff.
- Bottom navigation tabs are rendered dynamically from active permissions.

## 4. Multi-Unit Inventory & HPP (Mini-ERP)
- Products have a base unit (e.g. Pcs), multi-packaging units (e.g. Bundle 5, Dus 40), conversion multipliers, cost price (HPP), and selling price tiers.
- Stock reductions occur at the atomic base unit level.
