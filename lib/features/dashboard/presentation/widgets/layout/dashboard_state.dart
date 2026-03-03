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

  DashboardState({
    this.isLoading = true,
    this.hasNetworkError = false,
    this.isOpen = false,
    this.placeId,
    this.placeName = "Chargement...",
    this.activePartyId,
    this.partyName = "",
    this.openTime,
    this.closeTime,
    this.visitors = 0,
    this.posts = 0,
    this.selectedIndex = 0,
  });

  String? get imageUrl => null;

  int get notes => 0;

  int get engagement => 0;

  get totalRevenue => null;

  get totalBookings => null;

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
    int? visitors,
    int? posts,
    int? selectedIndex,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      hasNetworkError: hasNetworkError ?? this.hasNetworkError,
      isOpen: isOpen ?? this.isOpen,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      activePartyId: activePartyId ?? this.activePartyId,
      partyName: partyName ?? this.partyName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      visitors: visitors ?? this.visitors,
      posts: posts ?? this.posts,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
