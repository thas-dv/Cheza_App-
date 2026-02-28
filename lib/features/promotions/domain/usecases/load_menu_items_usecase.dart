import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class LoadMenuItemsUseCase {
  const LoadMenuItemsUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<List<MenuItemOptionEntity>> call({required int placeId}) {
    return _repository.loadMenuItems(placeId: placeId);
  }
}
