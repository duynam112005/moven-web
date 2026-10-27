# 6. Admin Inventory Management, Catalog Synchronization, and Audit Trail

## Context
In the MOVEN single-store apparel e-commerce architecture, managing stock at the variant level (`product_variants`), maintaining an immutable inventory movement history (`inventory_movements`), and providing intuitive administrative controls across all store management facets are critical.

Previous implementation iterations left the inventory management route (`/admin/inventory`) as an `EmptyStateView` placeholder and lacked a cohesive desktop dashboard design language across Catalog, Orders, Banners, and Reviews. Furthermore, when the database has no historical orders or reports, screens must provide graceful, informative interfaces and full mock parity during UI preview and development.

## Decision

1. **Dedicated Inventory Management & Stock Adjustment (`/admin/inventory`)**:
   - **KPI Highlights**:
     - Total Tracked Variants: Count of all active product variants.
     - Out of Stock Variants: Count of variants where `stock_quantity = 0`.
     - Low Stock Variants: Count of variants where `0 < stock_quantity <= store_settings.low_stock_threshold`.
   - **Variant Inventory Table**:
     - Columns: Product Name, SKU, Attributes (Size & Color), Unit Price, Current Stock, Status Badge (In Stock, Low Stock, Out of Stock), Actions.
     - Search & Filters: Real-time search by SKU or Product Name, plus quick status filters (All, Low Stock, Out of Stock).
   - **Atomic Stock Adjustment**:
     - Administrators can directly adjust variant inventory by specifying a target quantity or delta, accompanied by a mandatory reason string.
     - Stock adjustments record an atomic `inventory_movements` entry with `reason = 'adjustment'` and positive/negative `quantity_delta`.
   - **Inventory Audit Trail Tab**:
     - Provides a transparent, paginated history of all `inventory_movements` (`order_created`, `order_cancelled`, `return_received`, `restock`, `adjustment`), referencing associated order codes, actors, and timestamps in Vietnam Local Time (`Asia/Ho_Chi_Minh`).

2. **Unified Dashboard UI Standardization**:
   - Eliminate standard mobile-centric `AppBar` widgets from desktop admin screens (`AdminCatalogScreen`, `AdminBannerScreen`).
   - Standardize all 7 administrative screens (`Dashboard`, `Catalog`, `Inventory`, `Orders`, `Banners`, `Reviews`, `Settings`) under the unified `AdminShellScreen` desktop architecture featuring:
     - Prominent section headers with action buttons.
     - Standardized filter chips and search toolbars.
     - High-contrast data tables with alternating hover effects and rounded cards.
     - Consistent modal dialogs for creation, editing, and confirmation.

3. **Data Availability and Resilience**:
   - Every admin module is equipped with comprehensive data providers that query Supabase tables and RPCs when connected, with automatic fallback to rich, realistic in-memory mock datasets in preview/development mode.
   - Ensures zero blank screens: administrators immediately see populated tables, cards, and actionable controls upon visiting any screen.

## Consequences
- Completely eliminates placeholder screens across the entire admin module.
- Guarantees full auditability and traceability for every manual and automated inventory change.
- Enhances merchant operational efficiency with a polished, cohesive, responsive desktop interface.
