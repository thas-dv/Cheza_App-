import 'package:cheza_app/features/menus/data/datasources/menus_supabase_data_source.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._dataSource);

  final MenusSupabaseDataSource _dataSource;

  @override
  Future<List<MenuEntity>> getMenusByPlace({required int placeId}) async {
    final rawMenus = await _dataSource.fetchMenusByPlace(placeId: placeId);

    return rawMenus
        .map(
          (menu) => MenuEntity(
            id: menu['id'] as int,
            name: menu['menu_name']?.toString() ?? 'Menu',
            placeId: menu['place_id'] as int? ?? placeId,
          ),
        )
        .toList();
  }
}
