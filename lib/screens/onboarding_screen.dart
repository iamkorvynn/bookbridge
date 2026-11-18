import 'package:material_ui/material_ui.dart';

/// First-run walkthrough: list a book, browse, contact on WhatsApp.
/// Shown once; the flag is stored in SQLite by the caller.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.add_a_photo,
      title: 'List a textbook in a minute',
      body:
          'Snap a photo, add the title, subject, price and condition, '
          'and your book is up for sale on your campus.',
    ),
    (
      icon: Icons.search,
      title: 'Find books cheaper',
      body:
          'Browse what seniors are selling, search by title or author, '
          'and filter by subject or condition to find your exact book.',
    ),
    (
      icon: Icons.chat,
      title: 'Contact on WhatsApp',
      body:
          'Tap WhatsApp on any listing to message the seller directly '
          'with a prefilled message — no middleman, no commission.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _page == i
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _page == _pages.length - 1 ? 'Start browsing' : 'Next',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onDone,
              child: const Text('Skip'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
