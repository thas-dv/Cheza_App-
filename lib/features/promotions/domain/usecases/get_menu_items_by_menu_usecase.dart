import 'package:cheza_app/features/menus/data/repositories/menu_repository.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';

class GetMenuItemsByMenuUseCase {
  const GetMenuItemsByMenuUseCase(this._repository);

   final MenuRepository _repository;

  Future<List<MenuItemOptionEntity>> call({required int menuId}) {
    return _repository.fetchMenuItemsByMenu(menuId: menuId);
  }
}
