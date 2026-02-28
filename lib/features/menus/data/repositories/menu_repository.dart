import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';

abstract class MenuRepository {
   Future<List<MenuEntity>> fetchMenusByPlace({required int placeId});

  Future<List<MenuItemOptionEntity>> fetchMenuItemsByMenu({required int menuId});
}
