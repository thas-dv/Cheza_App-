import 'package:cheza_app/features/menus/data/datasources/menus_supabase_data_source.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._dataSource);

  final MenusSupabaseDataSource _dataSource;

  @override
  Future<List<MenuEntity>> fetchMenusByPlace({required int placeId}) async {
    final rawMenus = await _dataSource.fetchMenusByPlace(placeId: placeId);

    return rawMenus
        .map(
          (menu) => MenuEntity(
            id: menu['id'] as int,
            name: menu['name']?.toString() ?? 'Menu',
            placeId: menu['place_id'] as int? ?? placeId,
          ),
        )
        .toList();
  }

  @override
  Future<List<MenuItemOptionEntity>> fetchMenuItemsByMenu({
    required int menuId,
  }) async {
    final rawItems = await _dataSource.fetchMenuItemsByMenu(menuId: menuId);

    return rawItems
        .map(
          (item) => MenuItemOptionEntity(
            id: item['id'] as int,
            name: item['item_name']?.toString() ?? 'Article',
            price: (item['price'] as num?)?.toDouble() ?? 0,
            menuId: item['menu_id'] as int? ?? menuId,
          ),
        )
        .toList();
  }
}
