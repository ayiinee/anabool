import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/cat_controller.dart';
import '../widgets/cat_profile_card.dart';

class CatListPage extends StatefulWidget {
  const CatListPage({super.key});

  @override
  State<CatListPage> createState() => _CatListPageState();
}

class _CatListPageState extends State<CatListPage> {
  late final CatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CatController.create()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Kucing Saya',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Kucing',
            onPressed: () async {
              await Navigator.of(context).pushNamed(RouteConstants.addCat);
              await _controller.load();
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading && _controller.cats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AnaboolColors.brown,
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 122 + bottomInset),
                  itemBuilder: (context, index) {
                    final profile = _controller.cats[index];
                    return CatProfileCard(
                      profile: profile,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          RouteConstants.catDetail,
                          arguments: profile.cat.id,
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: _controller.cats.length,
                );
              },
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                activeDestination: AppBottomNavigationDestination.profile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
