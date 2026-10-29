# 7. QR Code Payment Method, 15-Minute Expiration Restocking, and SePay Webhook Integration

## Context
MOVEN originally launched as a Cash on Delivery (COD) only e-commerce system. As customer demand grows, offering a digital payment alternative via QR Code is essential for improving checkout conversion and customer convenience.

However, introducing QR payments introduces critical operational edge cases:
1. **Inventory Lockout / Overselling**: If inventory is held indefinitely while waiting for customer payment, abandoned checkouts lock up available merchandise. If inventory is not held, customers could transfer money for items that sell out concurrently.
2. **VietQR Banking Compatibility & Scanning UX**: Customers expect standard VietQR codes (scannable by banking apps and MoMo) that auto-fill bank account, exact total amount, and order code memo (`MVN-XXXXXX`), alongside 1-click clipboard copy helpers.
3. **Automated Reconciliation**: Without automated webhooks, store operators must manually check banking apps. Integrating SePay provides automated IPN webhooks for both Sandbox and Production environments.
4. **Fulfillment State Alignment**: When an order is paid via QR, it should bypass the manual COD phone verification step and transition directly to `confirmed`.

## Decision
1. **Extend Payment Method**:
   - Update `orders.payment_method` to support `CHECK (payment_method IN ('cod', 'qr_code'))`.
   - Add `orders.payment_expired_at TIMESTAMPTZ` column.

2. **VietQR Generation & SePay QuickLink Integration**:
   - When `payment_method = 'qr_code'`, checkout generates a standardized VietQR code via SePay QuickLink API (`https://qr.sepay.vn/img?acc={acc}&bank={bank}&amount={amount}&des={orderCode}&template=compact`).
   - If offline or image fetch fails, gracefully falls back to local `QrImageView` with raw structured text.
   - UI provides 1-click clipboard copy buttons for Account Number, Amount, and Order Code memo.

3. **15-Minute Time-To-Live (TTL) & Atomic Restocking**:
   - QR orders receive an expiration timestamp (`payment_expired_at = clock_timestamp() + INTERVAL '15 minutes'`).
   - If unpaid after 15 minutes, the order is cancelled with reason `"Hết hạn thời gian thanh toán mã QR (15 phút)"`.
   - Stored procedure `cancel_expired_qr_orders()` atomically restocks reserved variants and appends `inventory_movements` with reason `'order_cancelled'`.

4. **Automated SePay Webhook (`sepay-ipn`) Edge Function**:
   - Deployed at Supabase Edge Function `sepay-ipn` (or endpoint route).
   - Handles both SePay Payment Gateway (`notification_type: 'ORDER_PAID'`) and SePay Webhooks (`transferType: 'in'`).
   - **Idempotency**: Safely ignores duplicate webhooks if `order.payment_status == 'paid'`.
   - **Verification**: Verifies incoming `transferAmount >= order.total_amount` before confirming.
   - **Post-expiration money handling**: If money arrives after an order was cancelled, appends an audit note in `order_status_history` flagging for manual refund rather than corrupting state.
   - On successful payment: transitions order to `payment_status = 'paid'` and `status = 'confirmed'`, appending an audit trail entry.

5. **Client-side Realtime Awareness**:
   - `OrderSuccessView` polls order status while active; upon receiving payment confirmation from SePay, UI transitions seamlessly from QR timer to a verified success confirmation view.

## Consequences
- **Positive**: Zero manual friction; customers transfer money and order automatically moves to fulfillment.
- **Positive**: Zero risk of stock lockout due to strict 15-minute TTL and atomic restock.
- **Positive**: Full idempotency and auditability; every webhook call and status transition is recorded in `order_status_history`.
- **Positive**: Zero breaking changes to existing COD orders.
