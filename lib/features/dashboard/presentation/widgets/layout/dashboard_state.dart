class DashboardState {
  static const Object _unset = Object();
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
  final bool placeOpenedFromDb;
  final int posts;
  final int selectedIndex;
  final bool isStatusUpdating;
  final String? placeImageUrl;
  final String adminName;
  final String? placeDescription;
  final String? placeAddress;
  final int notes;
  final int engagement;
  const DashboardState({
    this.placeOpenedFromDb = false,
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
    this.isStatusUpdating = false,
  });

  DashboardState copyWith({
    bool? placeOpenedFromDb,
    bool? isLoading,
    bool? hasNetworkError,
    bool? isOpen,
    Object? placeId = _unset,
    String? placeName,
    Object? activePartyId = _unset,
    String? partyName,
    Object? openTime = _unset,
    Object? closeTime = _unset,
    Object? placeImageUrl = _unset,
    String? adminName,
    Object? placeDescription = _unset,
    Object? placeAddress = _unset,
    int? visitors,
    int? posts,
    int? notes,
    int? engagement,
    int? selectedIndex,
    bool? isStatusUpdating,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      hasNetworkError: hasNetworkError ?? this.hasNetworkError,
      isOpen: isOpen ?? this.isOpen,
      placeId: placeId == _unset ? this.placeId : placeId as int?,
      placeOpenedFromDb: placeOpenedFromDb ?? this.placeOpenedFromDb,
      placeName: placeName ?? this.placeName,
      placeImageUrl: placeImageUrl == _unset
          ? this.placeImageUrl
          : placeImageUrl as String?,
      adminName: adminName ?? this.adminName,
      placeDescription: placeDescription == _unset
          ? this.placeDescription
          : placeDescription as String?,
      placeAddress: placeAddress == _unset
          ? this.placeAddress
          : placeAddress as String?,
      activePartyId: activePartyId == _unset
          ? this.activePartyId
          : activePartyId as int?,
      partyName: partyName ?? this.partyName,
      openTime: openTime == _unset ? this.openTime : openTime as DateTime?,
      closeTime: closeTime == _unset ? this.closeTime : closeTime as DateTime?,
      visitors: visitors ?? this.visitors,
      posts: posts ?? this.posts,
      notes: notes ?? this.notes,
      engagement: engagement ?? this.engagement,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isStatusUpdating: isStatusUpdating ?? this.isStatusUpdating,
    );
  }
}
