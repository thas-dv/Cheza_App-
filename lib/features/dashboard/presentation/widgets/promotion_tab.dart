import 'package:flutter/material.dart';
import 'package:cheza_app/features/promotions/presentation/pages/promotions_page.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({
    required this.placeId,
    required this.activePartyId,
    required this.placeName,
    super.key,
  });

  final int? placeId;
  final int? activePartyId;
  final String placeName;

  @override
  Widget build(BuildContext context) {
    return PromotionsPage(
      placeId: placeId,
      activePartyId: activePartyId,
      placeName: placeName,
    );
  }
}
