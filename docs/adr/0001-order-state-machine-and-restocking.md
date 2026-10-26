# 1. Order State Machine and Restocking Policy

## Context
In a Cash on Delivery (COD) fashion e-commerce model, delivery failures occur frequently due to missed courier calls, rescheduling, or address issues. Previous specifications had conflicting terms (`returned` vs `returned_to_stock`) and ambiguity regarding whether `delivery_failed` should return goods to stock.

Allowing premature inventory restocking on delivery failure leads to phantom inventory, overselling, and lost goods because physical items remain in transit with courier personnel until manually returned to the merchant warehouse.

## Decision
1. Standardize fulfillment statuses to 6 mutually exclusive states:
   - `pending`: Newly placed order, stock decremented at checkout.
   - `shipping`: Package handed to shipping courier.
   - `delivered`: Courier successfully handed package to customer.
   - `delivery_failed`: Courier failed delivery attempt; physical goods remain with courier.
   - `cancelled`: Order cancelled while in `pending` state; stock immediately restocked.
   - `returned`: Admin explicitly confirms physical receipt of returned goods at warehouse; stock immediately restocked.

2. State Transitions:
   - `pending` -> `shipping` (Admin)
   - `pending` -> `cancelled` (Customer or Admin; with mandatory reason)
   - `shipping` -> `delivered` (Admin manual update)
   - `shipping` -> `delivery_failed` (Admin manual update)
   - `delivery_failed` -> `shipping` (Admin retry delivery)
   - `delivery_failed` -> `returned` (Admin warehouse receipt confirmation)

3. Inventory Restock Invariant:
   - Restocking MUST occur atomically in the database within the state change transaction, paired with an `inventory_movements` record of type `'restock'`.
   - Restocking is strictly prohibited on `delivery_failed`. It is ONLY executed when transitioning to `cancelled` or `returned`.

4. Enforcement:
   - State mutations cannot be executed via direct table `UPDATE`. They must be executed through trusted PostgreSQL stored procedures (`customer_cancel_order`, `admin_update_order_status`) with `SECURITY DEFINER`.

## Consequences
- Prevents stock discrepancies and phantom inventory from delivery failures.
- Maintains a clean audit trail through `inventory_movements` and `order_status_history`.
- Customer cancellation is strictly bounded to the `pending` stage before fulfillment starts.
