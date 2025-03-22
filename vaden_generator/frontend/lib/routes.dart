import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/generate/generate_page.dart';
import 'ui/link_tree/vaden_link_tree.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        child: GeneratePage(),
      ),
    ),
    GoRoute(
      path: '/linktree',
      pageBuilder: (context, state) => MaterialPage(
        child: VadenLinkTree(),
      ),
    ),
  ],
);
