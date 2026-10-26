# 4. Product Review Eligibility, Protection, and Moderation

## Context
Customer product reviews are a critical trust signal for clothing e-commerce. Without strict server-enforced controls, reviews can easily be gamed through fake reviews, duplicate spam, or competitor review-bombing. Conversely, allowing customer reports to auto-hide reviews creates a denial-of-service vulnerability where valid feedback is silenced without human oversight.

The system requires:
1. Proof of purchase before review submission.
2. Prevention of multiple reviews from the same customer for the same product.
3. Safe reporting mechanisms that cannot be abused.
4. Strict exclusion of moderated/hidden reviews from public views and rating statistics.

## Decision

1. **Review Eligibility (Proof of Delivered Purchase)**:
   - Only authenticated customers (`auth.uid()`) who have at least one completed order (`status = 'delivered'`) containing an `order_item` matching the target `product_id` are permitted to submit a review.
   - The eligibility check is enforced server-side via trusted PostgreSQL RPC (`submit_product_review`), preventing client bypass.
   - Each customer is restricted to exactly **one review per product** regardless of color/size variants (Unique constraint on `(user_id, product_id)` per Decision D-13).

2. **Review Content & Constraints**:
   - `rating`: Integer between 1 and 5 (inclusive, mandatory).
   - `comment`: Optional, max length 1,000 characters (Decision D-01).
   - `is_hidden`: Boolean flag defaulting to `false`. Clients have no permission to set or mutate this field directly.

3. **Abuse Reporting (Anti-Spam)**:
   - Authenticated customers may flag/report a review for moderation (reasons: `spam`, `inappropriate`, `fake`, `other`).
   - A customer cannot report their own review.
   - Each customer may submit at most **one report per review** (Unique composite constraint `(reporter_id, review_id)` per Decision D-12).
   - Submitting a report sets its status to `'pending'` and **does NOT auto-hide the review**.

4. **Admin Moderation & Hidden Review Segregation**:
   - Only users with verified `admin` role can moderate reviews via `admin_moderate_review`.
   - Actions:
     - `hide`: Sets `is_hidden = true` with a mandatory `hidden_reason`, and resolves pending reports.
     - `unhide`: Restores `is_hidden = false` and clears `hidden_reason`.
     - `dismiss`: Leaves review visible, sets report status to `'dismissed'`.
   - Row-Level Security (RLS) and public queries must strictly filter `is_hidden = false`.
   - Public rating metrics (average score, star distribution, review count) MUST strictly compute against `is_hidden = false` reviews only.

5. **Security Definer & RLS Architecture**:
   - Direct `INSERT`/`UPDATE` on `reviews` and `review_reports` from anonymous or standard customer sessions are locked down.
   - Mutations must go through `submit_product_review`, `report_product_review`, and `admin_moderate_review`.

## Consequences
- Guarantees 100% authentic verified-buyer reviews.
- Prevents review tampering and report-based censorship.
- Keeps public catalog rating aggregations mathematically clean and compliant with consumer protection principles.
