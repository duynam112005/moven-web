---
description: Apply to MOVEN Supabase Auth, RLS, Storage, admin
  permissions, secrets, RPC/Edge Functions, checkout, order state,
  reviews, and inventory security.
trigger: model_decision
---

# MOVEN Security Rules

## Trust boundaries

-   Use least privilege and default-deny authorization.
-   Enable and verify RLS for every application table exposed through
    Supabase APIs. Test `anon`, authenticated customer, and admin
    access.
-   Client validation and GoRouter guards improve UX only; they never
    replace backend/database authorization.
-   Derive the current user from the trusted session/JWT. Do not trust a
    user ID or role in a payload.
-   Each sensitive RPC/Edge Function must validate caller, ownership,
    role, inputs, current state, and allowed transition. Do not assume
    RLS automatically protects every function.
-   Never expose Supabase `service_role`, database passwords, Edge
    Function secrets, or other server secrets in Flutter Web, source
    control, or logs.
-   Anonymous users may read only explicitly approved public catalog
    content. Do not expose private profiles, addresses, carts, orders,
    or inventory movements.

## Roles and profiles

-   New profiles default to `customer`.
-   Users must never assign/update their own role through signup
    metadata, profile updates, or direct API calls.
-   Admin provisioning/revocation must use a trusted, explicitly
    approved process---not a public UI flow.
-   Allow only approved profile fields for customer updates. Protect
    identity, role, moderation, payment, stock, and audit fields.

## Sensitive operations

Use a trusted server/database path with authorization and validation for
checkout and total calculation; stock changes and inventory movements;
order cancellation and transitions; COD reconciliation;
return-received/restock; admin provisioning; review
eligibility/moderation; and privileged configuration.

Never allow customers to directly set stock, order totals, payment
status, delivery timestamps, order status, review moderation fields, or
inventory audit records.

## Storage

-   Separate policies for public product/banner media and private user
    avatars as appropriate.
-   Only authorized admins may upload/replace/delete product and banner
    media. Users may manage only their own avatar.
-   Validate MIME type, size, and extension; do not trust client
    filenames.
-   Test Storage policies independently of table RLS.
-   Avoid deleting the old object before replacement metadata/object is
    safely saved.

## MOVEN invariants

-   Checkout reads current variant price and stock from the database.
-   Order snapshots remain stable if catalog or customer address data
    later changes.
-   Failed delivery is not proof goods returned; require authorized
    admin confirmation before restock.
-   Cancellation/restock is idempotent and auditable.
-   Delivered orders contribute to the MVP delivered-order revenue
    metric, but are not automatically marked as COD cash reconciled.
-   Review reports do not automatically hide reviews.
-   Enforce review eligibility and moderation on the trusted backend,
    not only in UI.

## Security tests

Test that anon cannot read private data; Customer A cannot access
Customer B's data; customers cannot self-promote or alter
price/stock/totals/payment/order/moderation state; ineligible reviews
are rejected; customers cannot upload product/banner media or write
inventory movements. Report a check as passed only if it actually ran
and its result was observed.
