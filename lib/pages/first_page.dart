import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/role.dart';
import '../providers/sign_up_providers.dart';
import '../widgets/role_button.dart';

class FirstPage extends ConsumerStatefulWidget {
  const FirstPage({super.key});

  @override
  ConsumerState<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends ConsumerState<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'lib/assets/images/lam3a-logo2.png',
              fit: BoxFit.contain,
              colorBlendMode: BlendMode.modulate,
              color: Colors.white.withAlpha(100),
            ),
          ),
          const SizedBox(height: 40),
          Text('Who are you ?', style: Theme.of(context).textTheme.titleLarge!),

          const SizedBox(height: 10),
          Text(
            'Please select your role to continue',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // --- Role Buttons ---
          AlignedRoleButton(
            image: 'lib/assets/images/car.png',
            title: 'Client',
            subtitle: 'I want to book a car service',
            onPressed: () {
              ref.read(signupProvider.notifier).updateRole(Role.client);
              Navigator.pushNamed(context, '/login_page');
            },
          ),
          const SizedBox(height: 20),
          AlignedRoleButton(
            image: 'lib/assets/images/construction-worker.png',
            title: 'Provider',
            subtitle: 'I offer car wash or detailing service',
            onPressed: () {
              ref.read(signupProvider.notifier).updateRole(Role.provider);
              Navigator.pushNamed(context, '/login_page');
            },
          ),
        ],
      ),
    );
  }
}
