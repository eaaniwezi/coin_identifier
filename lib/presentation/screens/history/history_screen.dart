// ignore_for_file: use_super_parameters

import 'history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/coin_history_card.dart';
import 'widgets/history_search_bar.dart';
import '../../river_pods/history_rp.dart';
import 'widgets/history_filter_sheet.dart';
import 'widgets/collection_stats_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coin_identifier/models/coin_identification.dart';
import 'package:coin_identifier/presentation/river_pods/paywall_rp.dart';
import 'package:coin_identifier/presentation/screens/paywall/paywall_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline =
          !connectivityResult.any(
            (result) =>
                result == ConnectivityResult.mobile ||
                result == ConnectivityResult.wifi ||
                result == ConnectivityResult.ethernet ||
                result == ConnectivityResult.vpn,
          );
    });
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      setState(() {
        _isOffline =
            !results.any(
              (result) =>
                  result == ConnectivityResult.mobile ||
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.ethernet ||
                  result == ConnectivityResult.vpn,
            );
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(historyProvider.notifier).loadMoreCoins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final filteredCoins = ref.watch(filteredCoinsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final collectionStats = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Collection',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (historyState.filter.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterSheet(context),
          ),
          PopupMenuButton<HistorySortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (sortOption) {
              ref.read(historyProvider.notifier).changeSortOption(sortOption);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: HistorySortOption.dateNewest,
                    child: Text('Date (Newest)'),
                  ),
                  const PopupMenuItem(
                    value: HistorySortOption.dateOldest,
                    child: Text('Date (Oldest)'),
                  ),
                  const PopupMenuItem(
                    value: HistorySortOption.priceHighest,
                    child: Text('Price (Highest)'),
                  ),
                  const PopupMenuItem(
                    value: HistorySortOption.priceLowest,
                    child: Text('Price (Lowest)'),
                  ),
                  const PopupMenuItem(
                    value: HistorySortOption.nameAZ,
                    child: Text('Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: HistorySortOption.nameZA,
                    child: Text('Name (Z-A)'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline) _buildOfflineBanner(),

          HistorySearchBar(
            onSearch: (query) {
              ref.read(historyProvider.notifier).searchCoins(query);
            },
            initialQuery: historyState.searchQuery,
          ),

          CollectionStatsHeader(
            stats: collectionStats,
            isPremium: isPremium,
            onUpgradePressed: () => _showUpgradeDialog(context),
          ),

          Expanded(
            child: _buildMainContent(historyState, filteredCoins, isPremium),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline – showing cached data',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    HistoryState historyState,
    List<CoinIdentification> coins,
    bool isPremium,
  ) {
    if (historyState.isLoading && coins.isEmpty) {
      return _buildLoadingState();
    }

    if (historyState.error != null && coins.isEmpty) {
      return _buildErrorState(historyState.error!);
    }

    if (coins.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(historyProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < coins.length) {
                return CoinHistoryCard(
                  coin: coins[index],
                  onTap: () => _navigateToDetail(coins[index]),
                  isPremium: isPremium,
                );
              }
              return null;
            }, childCount: coins.length),
          ),

          if (!isPremium && historyState.coins.length > 15)
            SliverToBoxAdapter(child: _buildPremiumPrompt()),

          if (historyState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (!historyState.hasMore && coins.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'You\'ve reached the end of your collection',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your collection...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(historyProvider.notifier).refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Coins Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start identifying coins to build your collection!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Identify Your First Coin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[100]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: Colors.amber[700], size: 32),
          const SizedBox(height: 12),
          Text(
            'Unlock Your Full Collection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have more coins! Upgrade to Pro to view your complete collection history and unlock advanced features.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.amber[700], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => HistoryFilterSheet(
            currentFilter: ref.read(historyProvider).filter,
            onApplyFilter: (filter) {
              ref.read(historyProvider.notifier).applyFilter(filter);
            },
            onClearFilters: () {
              ref.read(historyProvider.notifier).clearFilters();
            },
          ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Upgrade to Pro'),
            content: const Text(
              'Unlock unlimited coin history, advanced filters, and detailed collection analytics with Coin Identifier Pro!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaywallScreen(source: 'home'),
                    ),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Paywall integration coming soon!'),
                  //   ),
                  // );
                },
                child: const Text('Upgrade Now'),
              ),
            ],
          ),
    );
  }

  void _navigateToDetail(CoinIdentification coin) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HistoryDetailScreen(coin: coin)),
    );
  }
}
