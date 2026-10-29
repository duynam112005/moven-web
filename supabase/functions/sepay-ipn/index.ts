import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Supabase Edge Function: sepay-ipn
 * Xử lý Webhook IPN từ SePay (Sandbox & Production)
 * - Tự động đối soát tiền chuyển khoản qua VietQR / Cổng thanh toán
 * - Idempotent: Chống xử lý trùng lặp giao dịch
 * - Tự động chuyển trạng thái đơn hàng sang `paid` và `confirmed`
 */

serve(async (req: Request) => {
  // 1. Xử lý preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const payload = await req.json();
    console.log("SePay IPN Payload nhận được:", JSON.stringify(payload));

    let orderCode: string | null = null;
    let amount = 0;
    let refCode = "";
    let gateway = "SePay";

    // Trường hợp 1: SePay Payment Gateway (notification_type === "ORDER_PAID")
    if (payload.notification_type === "ORDER_PAID" || payload.order) {
      const desc =
        payload.order?.order_description ||
        payload.order?.order_id ||
        payload.order?.orderInvoiceNumber ||
        "";
      const match = desc.match(/MVN-[A-Za-z0-9]+/i);
      if (match) {
        orderCode = match[0].toUpperCase();
      }
      amount = Number(payload.transaction?.amount || payload.order?.order_amount || 0);
      refCode = payload.transaction?.id || payload.order?.id || "";
      gateway = "SePay Payment Gateway";
    }
    // Trường hợp 2: SePay Webhooks biến động số dư chuyển khoản (transferType === "in")
    else if (
      payload.transferType === "in" ||
      payload.transferType === "credit" ||
      payload.content
    ) {
      const content = payload.content || "";
      const match = content.match(/MVN-[A-Za-z0-9]+/i);
      if (match) {
        orderCode = match[0].toUpperCase();
      }
      amount = Number(payload.transferAmount || payload.amount || 0);
      refCode = payload.referenceCode || payload.id?.toString() || "";
      gateway = payload.gateway || "Chuyển khoản VietQR";
    }

    // Nếu không tìm thấy mã đơn hàng có định dạng MVN-XXXXXX
    if (!orderCode) {
      console.warn("Bỏ qua: Không tìm thấy mã đơn hàng MVN hợp lệ trong nội dung giao dịch.");
      return new Response(
        JSON.stringify({ success: true, message: "Ignored: No matching order code" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log(`Bắt đầu đối soát đơn hàng: ${orderCode}, Số tiền: ${amount} VND, Mã GD: ${refCode}`);

    // Khởi tạo Supabase Admin Client bằng Service Role Key
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Truy vấn thông tin đơn hàng
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select("id, order_code, user_id, total_amount, payment_status, status, payment_expired_at")
      .eq("order_code", orderCode)
      .maybeSingle();

    if (orderError || !order) {
      console.error(`Không tìm thấy đơn hàng ${orderCode} trong cơ sở dữ liệu:`, orderError);
      return new Response(
        JSON.stringify({ success: true, message: `Order ${orderCode} not found` }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 2. Kiểm tra Idempotency: Đơn đã thanh toán trước đó
    if (order.payment_status === "paid") {
      console.log(`Đơn hàng ${orderCode} đã thanh toán trước đó. Bỏ qua cập nhật trùng.`);
      return new Response(
        JSON.stringify({ success: true, message: "Order already paid" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 3. Kiểm tra số tiền thanh toán
    if (amount < Number(order.total_amount)) {
      console.warn(
        `Cảnh báo: Số tiền chuyển (${amount} VND) nhỏ hơn tổng đơn hàng (${order.total_amount} VND).`
      );
      await supabase.from("order_status_history").insert({
        order_id: order.id,
        from_status: order.status,
        to_status: order.status,
        note: `SePay báo nhận thiếu tiền: ${amount}đ / ${order.total_amount}đ (Mã GD: ${refCode}). Cần kiểm tra lại.`,
      });
      return new Response(
        JSON.stringify({ success: true, message: "Amount less than total" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 4. Kiểm tra trường hợp đơn đã bị hủy (ví dụ quá hạn 15 phút)
    if (order.status === "cancelled") {
      console.warn(`Đơn hàng ${orderCode} đã bị hủy trước khi nhận được tiền. Cần hoàn tiền thủ công.`);
      await supabase.from("order_status_history").insert({
        order_id: order.id,
        from_status: "cancelled",
        to_status: "cancelled",
        note: `Nhận tiền cho đơn đã hủy (${gateway}, ${amount}đ, Mã GD: ${refCode}). Cần nhân viên hoàn tiền.`,
      });
      return new Response(
        JSON.stringify({ success: true, message: "Order was already cancelled" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 5. Cập nhật đơn hàng sang `paid` và tự động xác nhận `confirmed`
    const nextStatus = order.status === "pending_confirmation" ? "confirmed" : order.status;

    const { error: updateError } = await supabase
      .from("orders")
      .update({
        payment_status: "paid",
        status: nextStatus,
        updated_at: new Date().toISOString(),
      })
      .eq("id", order.id);

    if (updateError) {
      console.error(`Lỗi khi cập nhật trạng thái đơn ${orderCode}:`, updateError);
      throw updateError;
    }

    // 6. Ghi nhật ký vào order_status_history
    await supabase.from("order_status_history").insert({
      order_id: order.id,
      from_status: order.status,
      to_status: nextStatus,
      note: `SePay tự động xác nhận thanh toán (${gateway}, ${amount}đ, Mã GD: ${refCode})`,
    });

    console.log(`Đã xác nhận thanh toán thành công cho đơn hàng: ${orderCode}`);

    // SePay yêu cầu phản hồi HTTP 200 và body chứa {"success": true}
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    console.error("Lỗi ngoại lệ khi xử lý SePay IPN:", err);
    // Luôn trả về 200 kèm success: true để SePay không gửi lại vô hạn nếu lỗi logic nội bộ
    return new Response(
      JSON.stringify({
        success: true,
        error: err instanceof Error ? err.message : String(err),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
