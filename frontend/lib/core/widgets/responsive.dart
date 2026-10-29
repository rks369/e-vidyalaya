import 'package:evidyalaya/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

abstract final class Breakpoints {

  static const double wide = 840;
  static const double split = 900;
  static const double formWidth = 440;

}

class AuthLayout extends StatelessWidget {

  const AuthLayout({
    super.key,
    required this.child,
    this.title = 'E-Vidyalaya',
    this.tagline = 'Classes, notes and chat for your institute, in one place.',
  });

  final Widget child;
  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        final split = constraints.maxWidth >= Breakpoints.split;

        final form = SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(split ? 40 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.formWidth),
                child: child,
              ),
            ),
          ),
        );

        if (!split) {
          return Scaffold(body: form);
        }

        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 5,
                child: _BrandPanel(
                  title: title,
                  tagline: tagline,
                ),
              ),
              Expanded(
                flex: 4,
                child: form,
              ),
            ],
          ),
        );

      },
    );

  }

}

class _BrandPanel extends StatelessWidget {

  const _BrandPanel({
    required this.title,
    required this.tagline,
  });

  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.tertiary,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(),
            const SizedBox(height: 32),
            Text(
              title,
              style: text.displaySmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tagline,
              style: text.titleMedium?.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );

  }

}

class DashboardGrid extends StatelessWidget {

  const DashboardGrid({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        final columns = (constraints.maxWidth / 200).floor().clamp(2, children.length < 2 ? 2 : children.length);

        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: children,
        );

      },
    );

  }

}
