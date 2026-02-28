import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';

abstract class MenuRepository {
  Future<List<MenuEntity>> getMenusByPlace({required int placeId});
}
