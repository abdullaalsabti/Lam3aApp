import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/providers/brands_provider.dart';
import 'package:lamaa/pages/garage_add.dart';

class EmptyGarage extends ConsumerWidget {
  final VoidCallback? onAdd;
  const EmptyGarage({super.key, this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;

    void add(){
      if (onAdd != null) {
        onAdd!();
      } else {
        // Pre-fetch brands in background before navigation
        // This will start fetching immediately while navigation animation happens
        ref.read(brandsProvider.future);
        
        // Navigate to garage_add page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GarageAdd()),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          // add horizontal padding so text starts away from the screen edge
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your garage is empty 😞',
                textAlign: TextAlign.left,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 33),
              ),

              const SizedBox(height: 8),

              Text(
                'Add vehicles for a Lam3a',
                textAlign: TextAlign.left,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 24),

              Flexible(
                flex: 2,
                child: Expanded(
                  child: Center(
                    child: Image.asset(
                      'lib/assets/images/empty_garage.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: add,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      minimumSize: Size(80, 80),
                    ),
                    child: Icon(Icons.add, size: 30,),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text('skip', style: TextStyle(fontSize: 20)),
                        Icon(
                            Icons.arrow_forward_outlined, size: 20,),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
