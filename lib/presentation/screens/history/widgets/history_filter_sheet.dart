import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../river_pods/history_rp.dart';

class HistoryFilterSheet extends StatefulWidget {
  final HistoryFilter currentFilter;
  final Function(HistoryFilter) onApplyFilter;
  final VoidCallback onClearFilters;

  const HistoryFilterSheet({
    Key? key,
    required this.currentFilter,
    required this.onApplyFilter,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late HistoryFilter _filter;

  DateTime? _startDate;
  DateTime? _endDate;

  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _isPriceFilterActive = false;

  String? _selectedRarity;

  String? _selectedOrigin;

  final List<String> _rarityOptions = [
    'Common',
    'Uncommon',
    'Rare',
    'Very Rare',
    'Error',
  ];

  final List<String> _originOptions = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Mexico',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;

    if (_filter.dateRange != null) {
      _startDate = _filter.dateRange!.startDate;
      _endDate = _filter.dateRange!.endDate;
    }

    if (_filter.priceRange != null) {
      _minPrice = _filter.priceRange!.minPrice;
      _maxPrice = _filter.priceRange!.maxPrice;
      _isPriceFilterActive = true;
    }

    _selectedRarity = _filter.rarity;
    _selectedOrigin = _filter.origin;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Coins',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeFilter(),

                  const SizedBox(height: 24),

                  _buildPriceRangeFilter(),

                  const SizedBox(height: 24),

                  _buildRarityFilter(),

                  const SizedBox(height: 24),

                  _buildOriginFilter(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                label: 'Start Date',
                date: _startDate,
                onTap: () => _selectStartDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateButton(
                label: 'End Date',
                date: _endDate,
                onTap: () => _selectEndDate(context),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: _clearDateFilter,
              child: const Text('Clear Date Filter'),
            ),
          ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Select date',
              style: TextStyle(
                fontSize: 14,
                color: date != null ? Colors.black87 : Colors.grey[500],
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Switch(
              value: _isPriceFilterActive,
              onChanged: (value) {
                setState(() {
                  _isPriceFilterActive = value;
                });
              },
            ),
          ],
        ),
        if (_isPriceFilterActive) ...[
          const SizedBox(height: 12),
          Text(
            '\$${_minPrice.toInt()} - \$${_maxPrice.toInt()}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000,
            divisions: 100,
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },

            labels: RangeLabels(
              '\$${_minPrice.toInt()}',
              '\$${_maxPrice.toInt()}',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRarityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rarity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _rarityOptions.map((rarity) {
                final isSelected = _selectedRarity == rarity;
                return FilterChip(
                  label: Text(rarity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRarity = selected ? rarity : null;
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[700],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildOriginFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Origin Country',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedOrigin,
          decoration: InputDecoration(
            hintText: 'Select country',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Countries'),
            ),
            ..._originOptions.map((origin) {
              return DropdownMenuItem<String>(
                value: origin,
                child: Text(origin),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOrigin = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && date.isAfter(_endDate!)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minPrice = 0;
      _maxPrice = 1000;
      _isPriceFilterActive = false;
      _selectedRarity = null;
      _selectedOrigin = null;
    });
  }

  void _applyFilters() {
    final filter = HistoryFilter(
      dateRange:
          (_startDate != null && _endDate != null)
              ? DateRange(startDate: _startDate!, endDate: _endDate!)
              : null,
      priceRange:
          _isPriceFilterActive
              ? PriceRange(minPrice: _minPrice, maxPrice: _maxPrice)
              : null,
      rarity: _selectedRarity,
      origin: _selectedOrigin,
    );

    widget.onApplyFilter(filter);
    Navigator.of(context).pop();
  }
}
