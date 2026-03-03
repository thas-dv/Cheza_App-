class DashboardState {
  final bool isLoading;
  final bool hasNetworkError;
  final bool isOpen;
  final int? placeId;
  final String placeName;
  final int? activePartyId;
  final String partyName;
  final DateTime? openTime;
  final DateTime? closeTime;
  final int visitors;
  final int posts;
  final int selectedIndex;
final String? placeImageUrl;
  final String adminName;
  final String? placeDescription;
  final String? placeAddress;
   final int notes;
  final int engagement;
  const DashboardState({
    this.isLoading = true,
    this.hasNetworkError = false,
    this.isOpen = false,
    this.placeId,
    this.placeName = 'Chargement...',
    this.placeImageUrl,
    this.adminName = 'Admin',
    this.placeDescription,
    this.placeAddress,
    this.activePartyId,
    this.partyName = '',
    this.openTime,
    this.closeTime,
    this.visitors = 0,
    this.posts = 0,
     this.notes = 0,
    this.engagement = 0,
    this.selectedIndex = 0,
  });

 

  DashboardState copyWith({
    bool? isLoading,
    bool? hasNetworkError,
    bool? isOpen,
    int? placeId,
    String? placeName,
    int? activePartyId,
    String? partyName,
    DateTime? openTime,
    DateTime? closeTime,
      String? placeImageUrl,
    String? adminName,
    String? placeDescription,
    String? placeAddress,
    int? visitors,
    int? posts,
    int? notes,
    int? engagement,
    int? selectedIndex,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      hasNetworkError: hasNetworkError ?? this.hasNetworkError,
      isOpen: isOpen ?? this.isOpen,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
       placeImageUrl: placeImageUrl ?? this.placeImageUrl,
      adminName: adminName ?? this.adminName,
      placeDescription: placeDescription ?? this.placeDescription,
      placeAddress: placeAddress ?? this.placeAddress,
      activePartyId: activePartyId ?? this.activePartyId,
      partyName: partyName ?? this.partyName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      visitors: visitors ?? this.visitors,
      posts: posts ?? this.posts,
      notes: notes ?? this.notes,
      engagement: engagement ?? this.engagement,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
