# Project Standards & AI Agent Guidelines

## 🚨 CRITICAL RULE: Line Code Limit (Max 300 LOC)
1. Never write any code file exceeding 300 lines of code (`<= 300 LOC`).
2. If a file is reaching 250 lines, proactively split it into modular sub-files following Clean Architecture and SOLID principles.
3. Every module must be broken down into:
   - Separate Schema & DDL files
   - Dedicated DAOs (Data Access Objects)
   - Granular Sub-Widgets
   - Dedicated Models & DTOs

## 🧼 Code Quality & Senior Engineering Standards
1. **No Relative Traversal Imports:** Never use relative paths like `../../../*`. Always use package imports: `package:pos_app/...`.
2. **No AI Emojis & Cliché Comments:**
   - Never put emojis (e.g. ✅, 🎉, ⚡, ❌, 🚀, ☕, 🛒) in code, snackbars, logs, or UI strings unless explicitly requested.
   - Do not write robotic numbered comments like `// 1. Simpan Header`, `// 2. Potong Stok`, `// 3. Masukkan ke Outbox`.
   - Write natural, idiomatic code where class and method names clearly express their purpose.
3. **No Navigation Drawers:** Use Bottom Navigation Bar or Bottom Sheets designed for smartphone ergonomics.
4. **Dynamic RBAC & Navigation:** Bottom navigation and available features must be dynamically driven by Super Admin & Store Owner rules per tenant and role.
5. **Multi-Unit Inventory & HPP:** Products must support multi-tier packaging (Pcs, Bundle, Dus/Karton) with conversion factors and accurate HPP calculations.
