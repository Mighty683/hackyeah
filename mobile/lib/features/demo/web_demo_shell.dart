import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Presenter controls sit outside the reused Android screens and decisions.
class WebDemoShell extends StatelessWidget {
  const WebDemoShell({required this.child, required this.onReset, super.key});

  final Widget child;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: BaseboundColors.cream,
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 4,
              children: [
                const Text('Web demo · practice only'),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Reset web demo'),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _viewport(context, constraints.biggest);
                }
                // Keep a phone's logical viewport even on short laptop screens.
                // Scale the whole device instead of changing the app's layout.
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        width: 414,
                        height: 868,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24282B),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _viewport(context, const Size(390, 844)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Mock device features. Fictional data stays in this tab. '
              'Refresh or reset discards edits.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _viewport(BuildContext context, Size size) => MediaQuery(
    data: MediaQuery.of(context).copyWith(size: size),
    // Route semantics must not hide the presenter controls.
    child: Semantics(container: true, child: child),
  );
}
