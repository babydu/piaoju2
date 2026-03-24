import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/presentation/pages/splash_page.dart';
import 'package:bill_keeper/presentation/pages/login_page.dart';
import 'package:bill_keeper/presentation/pages/home_page.dart';
import 'package:bill_keeper/presentation/pages/personal_center_page.dart';
import 'package:bill_keeper/presentation/pages/settings_page.dart';
import 'package:bill_keeper/presentation/pages/image_edit_page.dart';
import 'package:bill_keeper/presentation/pages/bill_detail_page.dart';
import 'package:bill_keeper/presentation/pages/bill_edit_page.dart';
import 'package:bill_keeper/presentation/pages/search_page.dart';
import 'package:bill_keeper/presentation/pages/tag_management_page.dart';
import 'package:bill_keeper/presentation/pages/collection_management_page.dart';
import 'package:bill_keeper/presentation/pages/recycle_bin_page.dart';
import 'package:bill_keeper/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/personal-center',
        builder: (context, state) => const PersonalCenterPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/image-edit',
        builder: (context, state) => const ImageEditPage(),
      ),
      GoRoute(
        path: '/bill/:id',
        builder: (context, state) => BillDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/bill/:id/edit',
        builder: (context, state) => BillEditPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/tag-management',
        builder: (context, state) => const TagManagementPage(),
      ),
      GoRoute(
        path: '/collection-management',
        builder: (context, state) => const CollectionManagementPage(),
      ),
      GoRoute(
        path: '/recycle-bin',
        builder: (context, state) => const RecycleBinPage(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.valueOrNull == AuthState.authenticated;
      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLoginPage) {
        return '/login';
      }

      if (isLoggedIn && isOnLoginPage) {
        return '/home';
      }

      return null;
    },
  );
});
