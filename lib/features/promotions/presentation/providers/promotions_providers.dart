import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheza_app/features/promotions/data/datasources/promotions_supabase_data_source.dart';
import 'package:cheza_app/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';

import 'package:cheza_app/features/promotions/domain/usecases/add_promo_item_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/attach_promo_to_party_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/create_promo_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/get_menu_items_by_menu_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/load_promos_usecase.dart';

import 'package:cheza_app/features/menus/data/datasources/menus_supabase_data_source.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository_impl.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/features/menus/domain/usecases/get_menus_by_place_usecase.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 🔥 Refresh Trigger
final promotionsRefreshTickProvider = StateProvider<int>((ref) => 0);

/// 🔥 DataSources
final promotionsDataSourceProvider =
    Provider((ref) => PromotionsSupabaseDataSource());

final menusDataSourceProvider =
    Provider((ref) => MenusSupabaseDataSource());

/// 🔥 Repositories
final promotionsRepositoryProvider = Provider(
  (ref) => PromotionsRepositoryImpl(
    ref.read(promotionsDataSourceProvider),
  ),
);

final menuRepositoryProvider = Provider(
  (ref) => MenuRepositoryImpl(
    ref.read(menusDataSourceProvider),
  ),
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

final loadPromosUseCaseProvider = Provider(
  (ref) => LoadPromosUseCase(ref.read(promotionsRepositoryProvider)),
);

final getMenusByPlaceUseCaseProvider = Provider(
  (ref) => GetMenusByPlaceUseCase(ref.read(menuRepositoryProvider)),
);

final getMenuItemsByMenuUseCaseProvider = Provider(
  (ref) => GetMenuItemsByMenuUseCase(ref.read(promotionsRepositoryProvider)),
);

/// 🔥 Providers

final promotionsByPartyProvider =
    FutureProvider.family<List<PromotionEntity>, int>((ref, partyId) async {
  ref.watch(promotionsRefreshTickProvider);
  return ref.read(loadPromosUseCaseProvider)(partyId: partyId);
});

final menusByPlaceProvider =
    FutureProvider.family<List<MenuEntity>, int>((ref, placeId) async {
  return ref.read(getMenusByPlaceUseCaseProvider)(placeId: placeId);
});

final menuItemsByMenuProvider =
    FutureProvider.family<List<MenuItemOptionEntity>, int>((ref, menuId) async {
  return ref.read(getMenuItemsByMenuUseCaseProvider)(menuId: menuId);
});

class PromotionsActionNotifier extends StateNotifier<AsyncValue<void>> {
  PromotionsActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

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
      final promoId = await _ref.read(createPromoUseCaseProvider)(
        description: description,
        unlimited: unlimited,
        limit: limit,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );

      await _ref.read(attachPromoToPartyUseCaseProvider)(
        promoId: promoId,
        partyId: partyId,
      );

      _ref.read(promotionsRefreshTickProvider.notifier).state++;
      state = const AsyncData(null);
      return promoId;
    } catch (error, stack) {
      state = AsyncError(error, stack);
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
    try {
      await _ref.read(addPromoItemUseCaseProvider)(
        promoId: promoId,
        itemId: itemId,
        isFreeOffer: isFreeOffer,
        discountType: discountType,
        discountValue: discountValue,
      );

      _ref.read(promotionsRefreshTickProvider.notifier).state++;
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
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
    try {
      await _ref
          .read(promotionsRepositoryProvider)
          .updatePromo(
            promoId: promoId,
            description: description,
            unlimited: unlimited,
            limit: limit,
            dateStart: dateStart,
            dateEnd: dateEnd,
          );

      _ref.read(promotionsRefreshTickProvider.notifier).state++;
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> deletePromo({required int promoId}) async {
    state = const AsyncLoading();
    try {
      await _ref
          .read(promotionsRepositoryProvider)
          .deletePromo(promoId: promoId);
      _ref.read(promotionsRefreshTickProvider.notifier).state++;
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final promotionsActionProvider =
    StateNotifierProvider<PromotionsActionNotifier, AsyncValue<void>>(
      (ref) => PromotionsActionNotifier(ref),
    );
