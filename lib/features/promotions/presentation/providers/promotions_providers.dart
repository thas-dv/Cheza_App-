import 'package:cheza_app/features/promotions/domain/usecases/dalete_promo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheza_app/features/promotions/data/datasources/promotions_supabase_data_source.dart';
import 'package:cheza_app/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
// import 'package:cheza_app/features/menus/data/datasources/menus_supabase_data_source.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository.dart';
// import 'package:cheza_app/features/menus/data/repositories/menu_repository_impl.dart';
// import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
// import 'package:cheza_app/features/menus/domain/usecases/get_menus_by_place_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/add_promo_item_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/attach_promo_to_party_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/create_promo_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/get_menu_items_by_menu_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/load_promos_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/update_promo_usecase.dart';
// import 'package:cheza_app/features/promotions/domain/usecases/delete_promo_usecase.dart';
import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';
import 'package:cheza_app/features/menus/data/datasources/menus_supabase_data_source.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository_impl.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/features/menus/domain/usecases/get_menus_by_place_usecase.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 🔥 Refresh Trigger
final promotionsRefreshTickProvider = StateProvider<int>((ref) => 0);

/// 🔥 DataSources
final promotionsDataSourceProvider = Provider<PromotionsSupabaseDataSource>(
  (ref) => PromotionsSupabaseDataSource(),
);

final menusDataSourceProvider = Provider<MenusSupabaseDataSource>(
  (ref) => MenusSupabaseDataSource(),
);

/// 🔥 Repositories
final promotionsRepositoryProvider = Provider<PromotionsRepository>(
  (ref) => PromotionsRepositoryImpl(ref.read(promotionsDataSourceProvider)),
);

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepositoryImpl(ref.read(menusDataSourceProvider)),
);

/// 🔥 UseCases
final createPromoUseCaseProvider = Provider(
  (ref) => CreatePromoUseCase(ref.read(promotionsRepositoryProvider)),
);

final addPromoItemUseCaseProvider = Provider(
  (ref) => AddPromoItemUseCase(ref.read(promotionsRepositoryProvider)),
);

final attachPromoToPartyUseCaseProvider = Provider(
  (ref) => AttachPromoToPartyUseCase(ref.read(promotionsRepositoryProvider)),
);
final updatePromoUseCaseProvider = Provider(
  (ref) => UpdatePromoUseCase(ref.read(promotionsRepositoryProvider)),
);

final deletePromoUseCaseProvider = Provider(
  (ref) => DeletePromoUseCase(ref.read(promotionsRepositoryProvider)),
);
final loadPromosUseCaseProvider = Provider(
  (ref) => LoadPromosUseCase(ref.read(promotionsRepositoryProvider)),
);

final getMenusByPlaceUseCaseProvider = Provider(
  (ref) => GetMenusByPlaceUseCase(ref.read(menuRepositoryProvider)),
);

final getMenuItemsByMenuUseCaseProvider = Provider(
  (ref) => GetMenuItemsByMenuUseCase(ref.read(menuRepositoryProvider)),
);

/// 🔥 Providers

final promotionsByPartyProvider =
    FutureProvider.family<List<PromotionEntity>, int>((ref, partyId) async {
      ref.watch(promotionsRefreshTickProvider);
      return ref.read(loadPromosUseCaseProvider)(partyId: partyId);
    });

final menusByPlaceProvider = FutureProvider.family<List<MenuEntity>, int>((
  ref,
  placeId,
) async {
  return ref.read(getMenusByPlaceUseCaseProvider)(placeId: placeId);
});

// final menuItemsByMenuProvider =
//     FutureProvider.family<List<MenuItemOptionEntity>, int>((ref, menuId) async {
//       return ref.read(getMenuItemsByMenuUseCaseProvider)(menuId: menuId);
//     });
final menuItemsByMenuProvider =
    FutureProvider.family<List<MenuItemOptionEntity>, int>((ref, menuId) async {
      try {
        final useCase = ref.read(getMenuItemsByMenuUseCaseProvider);

        final result = await useCase(menuId: menuId);

        return result;
      } catch (e, stack) {
        // 🔥 Log utile pour debug
        print('Erreur menuItemsByMenuProvider: $e');
        print("stackTrace: $stack");

        // Important : rethrow pour que Riverpod passe en error
        throw Exception('Impossible de charger les articles du menu');
      }
    });

class PromotionsActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int> createAndAttachPromo({
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
    required int partyId,
  }) async {
    state = const AsyncLoading();
    try {
      final promoId = await ref.read(createPromoUseCaseProvider)(
        description: description,
        unlimited: unlimited,
        limit: limit,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );

      await ref.read(attachPromoToPartyUseCaseProvider)(
        promoId: promoId,
        partyId: partyId,
      );

      ref.read(promotionsRefreshTickProvider.notifier).state++;
      state = const AsyncData(null);
      return promoId;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> addItemToPromo({
    required int promoId,
    required int itemId,
    required bool isFreeOffer,
    String? discountType,
    double? discountValue,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addPromoItemUseCaseProvider)(
        promoId: promoId,
        itemId: itemId,
        isFreeOffer: isFreeOffer,
        discountType: discountType,
        discountValue: discountValue,
      );

      ref.read(promotionsRefreshTickProvider.notifier).state++;
    });
  }

  Future<void> updatePromo({
    required int promoId,
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updatePromoUseCaseProvider)(
        promoId: promoId,
        description: description,
        unlimited: unlimited,
        limit: limit,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );
      ref.read(promotionsRefreshTickProvider.notifier).state++;
    });
  }

  Future<void> deletePromo({required int promoId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deletePromoUseCaseProvider)(promoId: promoId);
      ref.read(promotionsRefreshTickProvider.notifier).state++;
    });
  }
}

final promotionsActionProvider =
    AsyncNotifierProvider<PromotionsActionNotifier, void>(
      PromotionsActionNotifier.new,
    );
