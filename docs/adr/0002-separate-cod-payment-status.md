# 2. Separation of COD Payment Status from Fulfillment Delivery Status

## Context
Under a Cash on Delivery (COD) payment structure, an order marked as `delivered` indicates physical delivery to the recipient by the courier, but does not guarantee that collected cash has been remitted and reconciled in the store's bank account or cash drawer.

Conflating delivery status with payment collection leads to distorted accounting and prevents proper financial auditing of logistics partners.

## Decision
1. Introduce a dedicated `payment_status` field on the `orders` table with allowed values:
   - `'unpaid'`: Initial default state for all newly created COD orders.
   - `'paid'`: Reconciled state when courier remittances or cash collections are verified by store administration.

2. Metrics & Revenue Invariant:
   - Dashboard reported revenue in MVP strictly measures the gross merchandise value of `delivered` orders, not reconciled cash.
   - Cash reconciliation is managed independently through `payment_status` and does not block the customer from reviewing delivered items or completing their order lifecycle.

## Consequences
- Physical logistics flows and financial reconciliation flows can progress independently without blocking each other.
- Admin portal can filter by both fulfillment progress and cash reconciliation status.
