---
description: Apply when working on MOVEN PostgreSQL schema, migrations,
  constraints, indexes, RPC/functions, transactions, orders, reviews, or
  inventory.
trigger: model_decision
---

# MOVEN Database Rules

## Before database work

-   Read current `DATABASE_SPEC.md`, `ERD.md`, `BUSINESS_FLOWS.md`,
    `OPEN_DECISIONS.md`, and relevant security requirements when
    available.
-   Do not write SQL, migrations, triggers, or schema-changing code
    while a relevant decision is unresolved or specifications conflict.
-   Before a schema change, propose the objective, affected
    tables/columns/functions, migration and backfill plan, tests,
    rollback risks, and open decisions. Wait for explicit approval.
-   Use reviewed, version-controlled migration history. Never make
    undocumented ad hoc schema changes.
-   Use PostgreSQL on Supabase. Do not change database engines without
    approval.

## Data integrity

-   Follow approved conventions; the current baseline proposes UUID IDs,
    `snake_case`, UTC `timestamptz`, and integer VND money values.
-   Store Storage object paths/keys, not expiring signed URLs.
-   Preserve order and inventory history. Archive/disable catalog
    records with historical references rather than deleting transaction
    history.
-   Define FK delete behavior explicitly; do not cascade-delete orders,
    order items, or inventory movements.
-   Use constraints/indexes for real invariants and queries; avoid
    speculative indexes.

## Orders, money, inventory

-   Database variant price is authoritative. Never trust client-supplied
    prices, subtotal, shipping, discount, or total.
-   Calculate totals on the trusted server/database side and snapshot
    item details, prices, recipient/address, and shipping fee.
-   Checkout is atomic: order, order items, stock decrement, inventory
    movements, and cart cleanup all succeed or all roll back.
-   Prevent overselling with transactions and appropriate
    locking/conditional updates.
-   Cancellation/restock must be atomic, auditable, and idempotent.
-   `delivery_failed` does not authorize restock. Only trusted admin
    confirmation that goods were received may restock.
-   Every stock change must have a movement record in the same
    transaction.
-   Keep delivery state separate from COD reconciliation; `delivered`
    does not prove cash receipt.
-   Validate review ownership, delivered-order eligibility, and product
    match on the server. Enforce one review per customer/product.
-   Use integer VND, never floating point, for money.

## Known blockers in current specifications

-   `returned_to_stock` is present as an order status in the database
    baseline, while `OPEN_DECISIONS.md` questions whether restock should
    instead be a separate event/flag.
-   `order_status_history` is proposed in `OPEN_DECISIONS.md` but is not
    consistently represented in `DATABASE_SPEC.md` and `ERD.md`.
-   Review comment limits, low-stock threshold, SKU/order-code rules,
    and address representation need confirmed decisions where they
    affect implementation.

Treat these as blockers for affected schema work. Do not select a
"proposed" default without user approval.

## Migration safety

-   Migrations must be deterministic, reviewable, ordered, and
    version-controlled.
-   Explain destructive/data-transforming impact, backup/rollback, and
    compatibility before proposing such work.
-   Do not run migrations, seeds, database reset commands, or database
    writes without explicit approval for the exact action.
-   Include constraints, RLS assumptions, and relevant tests in the
    migration review.
