// UI Batch 1 — shared components: page transition + reduced motion,
// theme consistency (SnackBar, AppBar hairline, dark card border),
// empty/error states with actions, skeleton loading, loading semantics,
// PrimaryButton theming, AppSnackBar, and the favorite tooltip.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_page_transitions.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/repositories/favorites_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/favorites/favorites_bloc.dart';
import 'package:vcare/logic/blocs/favorites/favorites_event.dart';
import 'package:vcare/presentation/widgets/app_card.dart';
import 'package:vcare/presentation/widgets/app_snack_bar.dart';
import 'package:vcare/presentation/widgets/content_constraint.dart';
import 'package:vcare/presentation/widgets/doctor_card.dart';
import 'package:vcare/presentation/widgets/empty_state_view.dart';
import 'package:vcare/presentation/widgets/error_state_view.dart';
import 'package:vcare/presentation/widgets/motion.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import 'package:vcare/presentation/widgets/section_header.dart';
import 'package:vcare/presentation/widgets/skeleton.dart';
import 'package:vcare/presentation/widgets/status_chip.dart';

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(Widget body,
        {ThemeData? theme,
        Locale locale = const Locale('en'),
        bool reduceMotion = false}) =>
    MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(body: body),
    );

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<int>> getFavoriteIds() async => {1};
  @override
  Future<Set<int>> toggleFavorite(int doctorId) async => {};
}

void main() {
  group('Theme consistency (H1/H4)', () {
    testWidgets('page transitions are themed for every platform',
        (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final builders = theme.pageTransitionsTheme.builders;
        expect(builders.keys, containsAll(TargetPlatform.values));
        expect(
            builders.values, everyElement(isA<VCarePageTransitionsBuilder>()));
      }
      expect(const VCarePageTransitionsBuilder().transitionDuration,
          AppDurations.normal);
    });

    testWidgets('SnackBar is floating/rounded and readable in both modes',
        (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final p = theme.extension<AppPalette>()!;
        final s = theme.snackBarTheme;
        expect(s.behavior, SnackBarBehavior.floating);
        expect(s.backgroundColor, p.textPrimary);
        expect(s.contentTextStyle?.color, p.background);
        expect((s.shape as RoundedRectangleBorder).borderRadius,
            BorderRadius.circular(AppDimensions.radiusMd));
      }
    });

    testWidgets('AppBar has a hairline; cards get a border only in dark',
        (tester) async {
      final light = AppTheme.light;
      final dark = AppTheme.dark;
      expect(light.appBarTheme.shape, isA<Border>());
      expect(light.extension<AppPalette>()!.cardBorder, Colors.transparent);
      expect(dark.extension<AppPalette>()!.cardBorder,
          dark.extension<AppPalette>()!.divider);
      final side = (dark.cardTheme.shape as RoundedRectangleBorder).side;
      expect(side.color, dark.extension<AppPalette>()!.cardBorder);
      // The new token takes part in equality/lerp like every other one.
      expect(AppPalette.light.copyWith(cardBorder: Colors.red),
          isNot(AppPalette.light));
      expect(AppPalette.light.lerp(AppPalette.dark, 1).cardBorder,
          AppPalette.dark.cardBorder);
    });
  });

  group('Motion helpers', () {
    testWidgets('context.motion() collapses to zero under reduced motion',
        (tester) async {
      late Duration normal;
      late Duration reduced;
      await tester.pumpWidget(_app(Builder(builder: (context) {
        normal = context.motion();
        return const SizedBox();
      })));
      await tester.pumpWidget(_app(Builder(builder: (context) {
        reduced = context.motion();
        return const SizedBox();
      }), reduceMotion: true));
      expect(normal, AppDurations.normal);
      expect(reduced, Duration.zero);
    });

    testWidgets('FadeIn ends fully visible; instant under reduced motion',
        (tester) async {
      await tester.pumpWidget(_app(const FadeIn(child: Text('hello'))));
      await tester.pump(); // post-frame → visible
      await tester.pump(AppDurations.normal);
      final opacity = tester.widget<Opacity>(find.ancestor(
          of: find.text('hello'), matching: find.byType(Opacity)));
      expect(opacity.opacity, 1);

      await tester.pumpWidget(
          _app(const FadeIn(child: Text('now')), reduceMotion: true));
      expect(find.byType(Opacity), findsNothing,
          reason: 'no animation wrapper at all under reduced motion');
      expect(find.text('now'), findsOneWidget);
    });

    testWidgets(
        'page transition builder returns the page untouched under '
        'reduced motion', (tester) async {
      await tester.pumpWidget(_app(Builder(builder: (context) {
        const child = Text('page');
        final result = const VCarePageTransitionsBuilder().buildTransitions(
            MaterialPageRoute(builder: (_) => child),
            context,
            kAlwaysCompleteAnimation,
            kAlwaysDismissedAnimation,
            child);
        expect(identical(result, child), isTrue);
        return const SizedBox();
      }), reduceMotion: true));
    });
  });

  group('Empty / error states (C5/H5)', () {
    testWidgets('EmptyStateView shows an optional action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_app(EmptyStateView(
        message: 'Nothing here',
        actionLabel: 'Browse',
        onAction: () => tapped = true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse'));
      expect(tapped, isTrue);
      final button =
          tester.getSize(find.widgetWithText(OutlinedButton, 'Browse'));
      expect(button.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));

      await tester
          .pumpWidget(_app(const EmptyStateView(message: 'Nothing here')));
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('ErrorStateView localizes the code and retries',
        (tester) async {
      var retried = 0;
      await tester.pumpWidget(_app(
          ErrorStateView(
              error: const AppErrorInfo(
                  AppErrorCode.network, 'raw english fallback'),
              onRetry: () => retried++),
          locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(_ar.errorNetwork), findsOneWidget);
      expect(find.text('raw english fallback'), findsNothing);
      await tester.tap(find.text(_ar.retry));
      expect(retried, 1);
      // Error icon is error-tinted (not the hint grey of an empty state).
      final icon =
          tester.widget<Icon>(find.byIcon(Icons.error_outline_rounded));
      expect(icon.color, AppPalette.light.error);
    });

    testWidgets('InlineErrorRow shows message + Retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(_app(InlineErrorRow(
          message: 'Section failed', onRetry: () => retried = true)));
      await tester.tap(find.text(_en.retry));
      expect(retried, isTrue);
      expect(find.text('Section failed'), findsOneWidget);
    });
  });

  group('Loading (C6/P3)', () {
    testWidgets('SkeletonList renders card placeholders announced as Loading',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SkeletonList(itemCount: 3)));
      await tester.pump();
      expect(find.byType(DoctorCardSkeleton), findsNWidgets(3));
      expect(find.bySemanticsLabel(_en.loading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      handle.dispose();
    });

    testWidgets('skeleton boxes use the theme fill (dark-safe)',
        (tester) async {
      await tester
          .pumpWidget(_app(const SkeletonBox(width: 40), theme: AppTheme.dark));
      final box = tester.widget<Container>(find.byType(Container));
      expect(
          (box.decoration as BoxDecoration).color, AppPalette.dark.inputFill);
    });

    testWidgets('skeleton is static under reduced motion', (tester) async {
      await tester.pumpWidget(_app(
          const SkeletonPulse(child: SkeletonBox(width: 40)),
          reduceMotion: true));
      expect(find.byType(FadeTransition), findsNothing);
      await tester.pumpAndSettle(); // must not spin forever
    });

    testWidgets('LoadingView spinner is labelled in the active language',
        (tester) async {
      await tester
          .pumpWidget(_app(const LoadingView(), locale: const Locale('ar')));
      final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator));
      expect(spinner.semanticsLabel, _ar.loading);
    });
  });

  group('PrimaryButton', () {
    testWidgets('spinner uses onPrimary and is labelled', (tester) async {
      await tester.pumpWidget(_app(
          const PrimaryButton(label: 'Go', isLoading: true, onPressed: null),
          theme: AppTheme.dark));
      await tester.pump(AppDurations.fast);
      final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator));
      expect(spinner.color, AppPalette.dark.onPrimary);
      expect(spinner.semanticsLabel, _en.loading);
    });
  });

  group('AppSnackBar', () {
    testWidgets('error variant shows an icon; a new message replaces the old',
        (tester) async {
      await tester.pumpWidget(_app(Builder(
        builder: (context) => Column(children: [
          TextButton(
              onPressed: () => AppSnackBar.show(context, 'first'),
              child: const Text('a')),
          TextButton(
              onPressed: () => AppSnackBar.error(context, 'second'),
              child: const Text('b')),
        ]),
      )));
      await tester.tap(find.text('a'));
      await tester.pump();
      expect(find.text('first'), findsOneWidget);
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });

  group('Shared building blocks', () {
    testWidgets('AppCard: surface color, ripple only when tappable',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(Column(children: [
        AppCard(onTap: () => taps++, child: const Text('tap me')),
        const AppCard(child: Text('static')),
      ])));
      await tester.tap(find.text('tap me'));
      expect(taps, 1);
      expect(find.byType(InkWell), findsOneWidget);
      final material = tester.widget<Material>(find
          .ancestor(of: find.text('static'), matching: find.byType(Material))
          .first);
      expect(material.color, AppPalette.light.surface);
    });

    testWidgets('SectionHeader ellipsizes and exposes the action',
        (tester) async {
      var seeAll = false;
      await tester.pumpWidget(_app(SectionHeader(
          title: 'A' * 200,
          actionLabel: 'See All',
          onAction: () => seeAll = true)));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('See All'));
      expect(seeAll, isTrue);
    });

    testWidgets('StatusChip tints from its color', (tester) async {
      await tester.pumpWidget(
          _app(const StatusChip(label: 'Pending', color: Colors.orange)));
      final text = tester.widget<Text>(find.text('Pending'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets(
        'ContentConstraint wraps a short child in a bounded slot and '
        'lets an expanding child fill a page', (tester) async {
      // Loose height, like a Scaffold bottomNavigationBar slot.
      await tester.pumpWidget(_app(Column(children: [
        ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: const ContentConstraint(
                child: SizedBox(height: 40, child: Text('bar')))),
      ])));
      expect(tester.getSize(find.byType(ContentConstraint)).height, 40,
          reason: 'a bottom bar must not become a full-height box');

      await tester.pumpWidget(_app(const SizedBox(
          height: 600,
          child: ContentConstraint(child: Center(child: Text('page'))))));
      expect(tester.getSize(find.byType(ContentConstraint)).height, 600);
    });

    testWidgets('ContentConstraint caps width on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(const ContentConstraint(
          child:
              SizedBox(width: double.infinity, height: 10, child: Text('w')))));
      expect(tester.getSize(find.byType(SizedBox).first).width,
          AppDimensions.contentMaxWidth);
    });
  });

  group('DoctorCard (C4)', () {
    testWidgets('favorite button has a localized tooltip in both states',
        (tester) async {
      final bloc = FavoritesBloc(_FakeFavoritesRepository());
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<FavoritesBloc>.value(
        value: bloc,
        child: _app(
            const Column(children: [
              DoctorCard(doctor: DoctorModel(id: 1, name: 'Dr. One')),
              DoctorCard(doctor: DoctorModel(id: 2, name: 'Dr. Two')),
            ]),
            locale: const Locale('ar')),
      ));
      // Initial state: nothing favorited yet.
      expect(find.byTooltip(_ar.addToFavorites), findsNWidgets(2));
      bloc.add(const FavoritesStarted());
      await tester.pumpAndSettle();
      expect(find.byTooltip(_ar.removeFromFavorites), findsOneWidget);
      expect(find.byTooltip(_ar.addToFavorites), findsOneWidget);
    });
  });
}
