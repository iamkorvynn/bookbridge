import 'package:bookbridge/models/listing.dart';
import 'package:bookbridge/screens/onboarding_screen.dart';
import 'package:bookbridge/widgets/condition_badge.dart';
import 'package:bookbridge/widgets/listing_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding shows list step first and advances on Next',
      (WidgetTester tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onDone: () => done = true),
      ),
    );

    expect(find.text('List a textbook in a minute'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Find books cheaper'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Contact on WhatsApp'), findsOneWidget);

    await tester.tap(find.text('Start browsing'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });

  testWidgets('onboarding Skip finishes immediately',
      (WidgetTester tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onDone: () => done = true),
      ),
    );
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });

  testWidgets('listing card shows title, price and condition badge',
      (WidgetTester tester) async {
    final listing = Listing(
      title: 'Engineering Mathematics',
      author: 'B. S. Grewal',
      subject: 'Mathematics',
      price: 250,
      condition: 'Good',
      sellerName: 'Asha',
      sellerPhone: '9876543210',
      createdAt: DateTime(2026, 11, 18),
    );
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingCard(
            listing: listing,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Engineering Mathematics'), findsOneWidget);
    expect(find.text('₹250'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.textContaining('Seller: Asha'), findsOneWidget);

    await tester.tap(find.byType(ListingCard));
    expect(tapped, isTrue);
  });

  testWidgets('sold listing card badges SOLD and strikes the price',
      (WidgetTester tester) async {
    final listing = Listing(
      title: 'Thermodynamics',
      subject: 'Mechanical',
      price: 400,
      condition: 'Fair',
      sellerName: 'Rahul',
      sellerPhone: '9876543210',
      isSold: true,
      createdAt: DateTime(2026, 11, 18),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ListingCard(listing: listing, onTap: () {})),
      ),
    );

    expect(find.byType(ConditionBadge), findsOneWidget);
    expect(find.text('SOLD'), findsOneWidget);
  });
}
