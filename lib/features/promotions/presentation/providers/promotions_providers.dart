import 'package:cheza_app/features/promotions/data/datasources/promotions_supabase_data_source.dart';
import 'package:cheza_app/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/domain/usecases/add_promo_item_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/attach_promo_to_party_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/create_promo_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/load_menu_items_usecase.dart';
import 'package:cheza_app/features/promotions/domain/usecases/load_promos_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final promotionsRefreshTickProvider = StateProvider<int>((ref) => 0);

final promotionsDataSourceProvider = Provider(
  (ref) => PromotionsSupabaseDataSource(),
);

final promotionsRepositoryProvider = Provider(
  (ref) => PromotionsRepositoryImpl(ref.read(promotionsDataSourceProvider)),
);

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

final loadMenuItemsUseCaseProvider = Provider(
  (ref) => LoadMenuItemsUseCase(ref.read(promotionsRepositoryProvider)),
);

final promotionsByPartyProvider =
    FutureProvider.family<List<PromotionEntity>, int>((ref, partyId) async {
      ref.watch(promotionsRefreshTickProvider);
      return ref.read(loadPromosUseCaseProvider)(partyId: partyId);
    });

final menuItemsByPlaceProvider =
    FutureProvider.family<List<MenuItemOptionEntity>, int>((ref, placeId) async {
      return ref.read(loadMenuItemsUseCaseProvider)(placeId: placeId);
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
      final promoId = await _ref
          .read(createPromoUseCaseProvider)(
            description: description,
            unlimited: unlimited,
            limit: limit,
            dateStart: dateStart,
            dateEnd: dateEnd,
          );

      await _ref
          .read(attachPromoToPartyUseCaseProvider)(promoId: promoId, partyId: partyId);

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
      await _ref
          .read(addPromoItemUseCaseProvider)(
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
}

final promotionsActionProvider =
    StateNotifierProvider<PromotionsActionNotifier, AsyncValue<void>>(
      (ref) => PromotionsActionNotifier(ref),
    );
