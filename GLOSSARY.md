# MOVEN Domain Glossary

This glossary defines the authoritative domain terminology for MOVEN, a single-store clothing e-commerce system specializing in Cash on Delivery (COD) fulfillment.

## Fulfillment & Orders

**Order**:
A customer's formal request to purchase specific product variants with an authoritative price snapshot and shipping fee.
_Avoid_: Purchase, transaction, booking.

**Order Code**:
A human-readable, unique identifier for an order displayed to customers and shipping couriers (e.g., `ORD-20261026-XXXX`).
_Avoid_: Order number, receipt ID, tracking ID.

**Fulfillment Status**:
The current physical delivery state of an order within the state machine (`pending`, `shipping`, `delivered`, `delivery_failed`, `cancelled`, `returned`).
_Avoid_: Order status, delivery phase.

**Delivery Failed**:
A logistics state where courier could not hand over the package to the customer. Goods remain with courier/logistics and are NOT returned to warehouse inventory.
_Avoid_: Returned, rejected, lost.

**Returned**:
A logistics state confirmed exclusively by an authorized admin that physical goods have arrived back at the warehouse, triggering atomic inventory restocking.
_Avoid_: Delivery failed, returned to stock, restocked.

**Restock**:
The atomic process of incrementing product variant inventory and logging an `inventory_movements` record upon order cancellation or confirmed return.
_Avoid_: Stock refund, inventory rollback.

**COD Payment Status**:
The monetary reconciliation state of Cash on Delivery proceeds (`unpaid`, `paid`), tracked independently from physical fulfillment status.
_Avoid_: Payment condition, cash state.

**Order Status History**:
An immutable audit log recording every transition of an order's fulfillment state, capturing timestamps, the actor responsible, and operational notes.
_Avoid_: Order logs, status audit, tracking timeline.
