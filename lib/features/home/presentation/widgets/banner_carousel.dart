import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../catalog/data/catalog_providers.dart';
import '../../../catalog/data/storage_repository.dart';
import '../../../catalog/domain/models/banner.dart';
import '../../../catalog/domain/models/catalog_filter.dart';

/// Banner Carousel động trên Trang chủ (Storefront Banner Carousel)
class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAutoScroll(int count) {
    if (count <= 1 || _timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % count;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onBannerTapped(HomeBanner banner) {
    switch (banner.linkType) {
      case 'product':
        if (banner.linkValue != null && banner.linkValue!.isNotEmpty) {
          context.go('/product/${banner.linkValue}');
        }
        break;
      case 'category':
        if (banner.linkValue != null && banner.linkValue!.isNotEmpty) {
          ref.read(catalogFilterProvider.notifier).state =
              CatalogFilter(categoryId: banner.linkValue);
        }
        context.goNamed(RouteNames.catalog);
        break;
      case 'none':
      default:
        context.goNamed(RouteNames.catalog);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(activeBannersProvider);
    final storageRepo = ref.watch(storageRepositoryProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return _buildDefaultHeroBanner(context);
        }

        _setupAutoScroll(banners.length);

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  final imageUrl =
                      storageRepo.getBannerImageUrl(banner.imagePath);

                  return _buildBannerSlide(context, banner, imageUrl);
                },
              ),
            ),

            // Các chấm chuyển slide (Dots indicator)
            if (banners.length > 1)
              Positioned(
                bottom: AppDimensions.space16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(banners.length, (index) {
                    final isSelected = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radius4),
                      ),
                    );
                  }),
                ),
              ),

            // Nút chuyển slide trước / sau (chỉ hiện khi có > 1 banner)
            if (banners.length > 1) ...[
              Positioned(
                left: AppDimensions.space12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                    ),
                    icon: const Icon(Icons.chevron_left, size: 24),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: AppDimensions.space12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 24),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => _buildDefaultHeroBanner(context),
      error: (error, stack) => _buildDefaultHeroBanner(context),
    );
  }

  Widget _buildBannerSlide(
    BuildContext context,
    HomeBanner banner,
    String imageUrl,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền của banner (nếu có)
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),

          // Lớp phủ Gradient giúp chữ đọc rõ nét
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.beige.withValues(alpha: 0.95),
                  AppColors.beige.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Nội dung văn bản và nút bấm của Banner
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space40,
              vertical: AppDimensions.space32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radius4),
                  ),
                  child: const Text(
                    'MOVEN 2026',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Text(
                    banner.title,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 32,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (banner.subtitle != null &&
                    banner.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      banner.subtitle!,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.space24),
                AppButton(
                  label: 'Khám phá ngay',
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  onPressed: () => _onBannerTapped(banner),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space32,
        vertical: AppDimensions.space64,
      ),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
            ),
            child: const Text(
              'BỘ SƯU TẬP MỚI 2026',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Text(
            'Thời trang tối giản,\ntrải nghiệm tối ưu.',
            style: AppTypography.displayLarge,
          ),
          const SizedBox(height: AppDimensions.space16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Thiết kế tinh gọn, chất liệu cao cấp thoáng mát. Đặt hàng dễ dàng và thanh toán trực tiếp khi nhận hàng (COD).',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          AppButton(
            label: 'Khám phá bộ sưu tập',
            icon: const Icon(Icons.arrow_forward, size: 18),
            onPressed: () => context.goNamed(RouteNames.catalog),
          ),
        ],
      ),
    );
  }
}
