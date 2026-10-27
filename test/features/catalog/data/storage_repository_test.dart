import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';

void main() {
  group('StorageRepository Unit Tests', () {
    test('1. Buckets match Supabase full_setup.sql definitions', () {
      expect(StorageRepository.productBucket, 'product-media');
      expect(StorageRepository.bannerBucket, 'banners');
    });

    test('2. inferContentType correctly detects image mime types from filenames', () {
      expect(StorageRepository.inferContentType('shirt.png'), 'image/png');
      expect(StorageRepository.inferContentType('PANTS.PNG'), 'image/png');
      expect(StorageRepository.inferContentType('banner.webp'), 'image/webp');
      expect(StorageRepository.inferContentType('icon.gif'), 'image/gif');
      expect(StorageRepository.inferContentType('photo.jpg'), 'image/jpeg');
      expect(StorageRepository.inferContentType('photo.jpeg'), 'image/jpeg');
      expect(StorageRepository.inferContentType('unknown_file'), 'image/jpeg');
      expect(StorageRepository.inferContentType('dotted.name.image.png'), 'image/png');
    });

    test('3. getPublicUrl returns full URL directly if already absolute', () {
      final repo = StorageRepository(null);
      const httpUrl = 'https://images.unsplash.com/photo-123456';
      expect(repo.getPublicUrl(bucket: 'product-media', path: httpUrl), httpUrl);
      expect(repo.getProductImageUrl(httpUrl), httpUrl);
      expect(repo.getBannerImageUrl(httpUrl), httpUrl);
    });

    test('4. getPublicUrl returns empty string when client is null and path is relative', () {
      final repo = StorageRepository(null);
      expect(repo.getPublicUrl(bucket: 'product-media', path: 'temp/photo.jpg'), '');
      expect(repo.getProductImageUrl('temp/photo.jpg'), '');
      expect(repo.getProductImageUrl(null), '');
      expect(repo.getProductImageUrl(''), '');
    });
  });
}
