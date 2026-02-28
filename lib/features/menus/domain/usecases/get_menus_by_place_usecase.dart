import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/features/menus/data/repositories/menu_repository.dart';

class GetMenusByPlaceUseCase {
  const GetMenusByPlaceUseCase(this._repository);

  final MenuRepository _repository;

  Future<List<MenuEntity>> call({required int placeId}) {
    return _repository.getMenusByPlace(placeId: placeId);
  }
}
