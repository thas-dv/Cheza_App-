import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class GetMenuItemsByMenuUseCase {
  const GetMenuItemsByMenuUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<List<MenuItemOptionEntity>> call({required int menuId}) {
    return _repository.getMenuItemsByMenu(menuId: menuId);
  }
}
