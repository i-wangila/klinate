import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import 'provider_profile_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final List<Map<String, String>> items;
  final String category;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.items,
    required this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredItems = [];
  String? _selectedCounty;

  final List<String> _kenyanCounties = [
    'All Counties',
    'Nairobi',
    'Mombasa',
    'Kisumu',
    'Nakuru',
    'Eldoret',
    'Thika',
    'Malindi',
    'Kitale',
    'Garissa',
    'Kakamega',
    'Nyeri',
    'Meru',
    'Machakos',
    'Kiambu',
    'Kajiado',
    'Naivasha',
    'Nanyuki',
    'Kericho',
    'Bungoma',
    'Embu',
    'Kisii',
    'Homa Bay',
    'Migori',
    'Siaya',
    'Busia',
    'Vihiga',
    'Bomet',
    'Narok',
    'Trans Nzoia',
    'Uasin Gishu',
    'Elgeyo Marakwet',
    'Nandi',
    'Baringo',
    'Laikipia',
    'Samburu',
    'Turkana',
    'West Pokot',
    'Marsabit',
    'Isiolo',
    'Wajir',
    'Mandera',
    'Tana River',
    'Lamu',
    'Taita Taveta',
    'Kwale',
    'Kilifi',
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final title = item['title']?.toLowerCase() ?? '';
        final matchesSearch = query.isEmpty || title.contains(query);

        // Filter by county if selected
        if (_selectedCounty != null && _selectedCounty != 'All Counties') {
          final itemLocation = item['location']?.toLowerCase() ?? '';
          // Match exact county name or if county appears in the location string
          final selectedCountyLower = _selectedCounty!.toLowerCase();
          final matchesCounty =
              itemLocation == selectedCountyLower ||
              itemLocation.contains(selectedCountyLower);
          return matchesSearch && matchesCounty;
        }

        return matchesSearch;
      }).toList();
    });
  }

  void _showCountyFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by County',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _kenyanCounties.length,
                  itemBuilder: (context, index) {
                    final county = _kenyanCounties[index];
                    final isSelected = _selectedCounty == county;
                    return ListTile(
                      title: Text(county),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCounty = county;
                          _filterItems();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ${widget.title}...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showCountyFilter,
          ),
        ],
      ),
      body: _filteredItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedCounty != null &&
                      _selectedCounty != 'All Counties')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCounty = 'All Counties';
                            _filterItems();
                          });
                        },
                        child: const Text('Clear county filter'),
                      ),
                    ),
                ],
              ),
            )
          : Column(
              children: [
                if (_selectedCounty != null &&
                    _selectedCounty != 'All Counties')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Showing results in $_selectedCounty',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCounty = 'All Counties';
                              _filterItems();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 16),
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(context, _filteredItems[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, String> item) {
    IconData getIcon() {
      // All categories are now individual healthcare providers
      if (widget.category.contains('Doctors') ||
          widget.category.contains('Practitioners')) {
        return Icons.person;
      }
      if (widget.category.contains('Nurses')) {
        return Icons.healing;
      }
      if (widget.category.contains('Therapists')) {
        return Icons.psychology;
      }
      if (widget.category.contains('Nutritionist')) {
        return Icons.restaurant;
      }
      if (widget.category.contains('Home Care')) {
        return Icons.home_work;
      }
      return Icons.medical_services;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to provider profile (no facilities anymore, only individual providers)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderProfileScreen(
              providerId: item['id'] ?? item['title'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: item['imageUrl'] != null && item['imageUrl']!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        item['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              getIcon(),
                              size: 60,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(getIcon(), size: 60, color: Colors.grey[600]),
                    ),
            ),
            // Content container
            Padding(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  if (item['rating'] != null && item['rating']!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          item['rating']!,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
