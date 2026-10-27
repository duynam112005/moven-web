# 5. Store Settings, Shipping Fee, and Dashboard Metrics

## Context
E-commerce business operations require centralized store-wide configuration (default shipping fee, low stock alert threshold, contact info) and business analytics dashboard metrics. In a Cash on Delivery (COD) fulfillment model:
1. Shipping fee must remain configurable by merchant admins while ensuring that orders already placed retain an immutable snapshot of the fee applied at the moment of checkout.
2. Low stock alert thresholds must dynamically highlight active variants nearing stockout across warehouse operations.
3. Revenue reporting in previous informal definitions could easily be skewed if unpaid, cancelled, or failed delivery orders were factored into gross sales figures.
4. Product rankings (best sellers) must reflect genuine consumer fulfillment rather than unfulfilled or cancelled order attempts.

## Decision

1. **Store Settings Singleton Architecture (Decision D-08)**:
   - The `store_settings` table is restricted to exactly one authoritative configuration row via a primary key singleton pattern (`id = '00000000-0000-0000-0000-000000000001'` or single-row constraint).
   - `default_shipping_fee`: Integer VND (non-negative, default 20,000 VND).
   - `low_stock_threshold`: Non-negative integer (default 5, per Decision D-02).
   - Row-Level Security:
     - Public/authenticated read allowed for store name and default shipping fee.
     - Mutation (`UPDATE`) is strictly restricted to authenticated administrators.

2. **Shipping Fee Snapshot Invariant**:
   - When a customer checks out, the current `default_shipping_fee` from `store_settings` is evaluated server-side and snapshotted into `orders.shipping_fee`.
   - Subsequent changes to store settings do NOT alter previous orders' shipping fees.

3. **Dashboard Revenue Definition (Delivered Revenue Only)**:
   - Reported revenue strictly computes the sum of `total_amount` of orders in `delivered` status within the chosen date range (`status = 'delivered'`).
   - Orders with fulfillment statuses `pending_confirmation`, `confirmed`, `preparing`, `shipping`, `delivery_failed`, `cancelled`, or `returned` are excluded from gross delivered revenue.
   - Reporting timezone is standardized to Vietnam Local Time (`Asia/Ho_Chi_Minh`, UTC+7).

4. **Best Sellers & Low Stock Calculation Invariants**:
   - **Best Sellers**: Computed from the aggregation of `order_items.quantity` strictly within `delivered` orders, grouped by product and ordered descending.
   - **Low Stock Alerts**: Computed dynamically from active variants (`is_active = true`) where `stock_quantity <= store_settings.low_stock_threshold`.

5. **Server-Side Trusted Metric Computation**:
   - Dashboard metrics are queried via a trusted stored procedure (`admin_get_dashboard_metrics`), eliminating heavy client-side joins and ensuring consistency between SQL calculations and admin screens.

## Consequences
- Eliminates ambiguous revenue figures, providing accurate financial reconciliation.
- Protects historical order pricing while allowing flexible store management.
- Guarantees immediate operational visibility into inventory depletion.
