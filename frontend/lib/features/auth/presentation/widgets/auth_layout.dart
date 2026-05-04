import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    required this.title,
    required this.subtitle,
    this.contentAlignment = const Alignment(0, -0.12),
  });

  final List<Widget> children;
  final String title;
  final String subtitle;
  final AlignmentGeometry contentAlignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Align(
                    alignment: contentAlignment,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 390),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AnaboolColors.brownDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AnaboolColors.brownSoft,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AnaboolColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0x73E6B49C),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A7A3400),
                                      blurRadius: 24,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    22,
                                    24,
                                    22,
                                    22,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: children,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
