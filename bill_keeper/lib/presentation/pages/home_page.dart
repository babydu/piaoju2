import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/presentation/providers/tag_provider.dart';
import 'package:bill_keeper/presentation/widgets/home/top_bar.dart';
import 'package:bill_keeper/presentation/widgets/home/upload_card.dart';
import 'package:bill_keeper/presentation/widgets/home/filter_dropdown.dart';
import 'package:bill_keeper/presentation/widgets/home/bill_grid.dart';
import 'package:bill_keeper/presentation/widgets/home/fold_menu.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(billListProvider);
      ref.read(collectionListProvider);
      ref.read(tagListProvider);
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                TopBar(onMenuTap: _toggleMenu),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('搜索票据', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const UploadCard(),
                const SizedBox(height: 12),
                const FilterDropdown(),
                const SizedBox(height: 12),
                const Expanded(child: BillGrid()),
              ],
            ),
          ),
          if (_isMenuOpen) ...[
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.black54),
            ),
            FoldMenu(onClose: _toggleMenu),
          ],
        ],
      ),
    );
  }
}
