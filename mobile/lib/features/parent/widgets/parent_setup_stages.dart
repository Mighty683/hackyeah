import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../../../ui/parent_setup_ui.dart';

import '../data/family_plan.dart';
import 'parent_setup_layout.dart';

class ParentIntroductionStage extends StatelessWidget {
  const ParentIntroductionStage({required this.onOpenLandmarks, super.key});

  final VoidCallback onOpenLandmarks;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading('Przygotuj plan rodziny', BaseboundIconName.family),
      const Text(
        'Dodaj dane dziecka, kontakty i bezpieczne miejsca. Krok po kroku.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      const ParentEditorNote(
        message: 'W demo używaj fikcyjnych danych osobowych. Wszystkie dane są opcjonalne.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 16),
      const Text(
        kIsWeb
            ? 'Dane demo pozostają w tej karcie przeglądarki. Odświeżenie lub reset usuwa zmiany. Używaj fikcyjnych danych. Bez szyfrowania, blokady rodzicielskiej i synchronizacji z chmurą.'
            : 'Zapisane dane są szyfrowane na urządzeniu. Każdy użytkownik aplikacji może je otworzyć. Bez blokady rodzicielskiej i synchronizacji z chmurą.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      BaseboundActionTile(
        label: 'Wspólny spacer',
        icon: BaseboundIconName.map,
        onPressed: onOpenLandmarks,
      ),
    ],
  );
}

class ParentContactsStage extends StatelessWidget {
  const ParentContactsStage({
    required this.contacts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<TrustedContact> contacts;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading(
        'Z kim dziecko może się skontaktować?',
        BaseboundIconName.family,
      ),
      Text(
        'Dodaj maksymalnie trzy zaufane osoby dorosłe. Zapisano: ${contacts.length}/3.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < contacts.length; index++)
        ParentSetupEntry(
          title: contacts[index].name.isEmpty
              ? 'Kontakt ${index + 1}'
              : contacts[index].name,
          subtitle: [
            contacts[index].relationship,
            contacts[index].phone,
          ].where((value) => value.isNotEmpty).join(' · '),
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
          icon: BaseboundIconName.adult,
        ),
      if (contacts.length < FamilyPlan.maxContacts)
        BaseboundActionTile(
          label: 'Dodaj zaufany kontakt',
          icon: BaseboundIconName.addAdult,
          onPressed: onAdd,
        ),
      const SizedBox(height: 24),
      const Text(
        'Zapisanie kontaktu nie wykonuje połączenia ani nie sprawdza numeru.',
        style: parentSetupSubtitleStyle,
      ),
    ],
  );
}

class ParentPlacesStage extends StatelessWidget {
  const ParentPlacesStage({
    required this.points,
    required this.meetingPoint,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<SafePoint> points;
  final Widget meetingPoint;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading(
        'Wybierz bezpieczne miejsca dziecka',
        BaseboundIconName.pin,
      ),
      const Text(
        'Wybierz miejsca docelowe do planu awaryjnego rodziny.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 16),
      const ParentEditorNote(
        message: 'Demo zapisuje tylko znaczniki mapy. Nie sprawdza bezpieczeństwa i nie wyznacza tras w prawdziwych zagrożeniach.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < points.length; index++)
        ParentSetupEntry(
          title: points[index].displayName,
          subtitle: 'Dotknij, aby edytować to bezpieczne miejsce.',
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
          icon: BaseboundIconName.pin,
        ),
      BaseboundActionTile(
        label: 'Dodaj bezpieczne miejsce',
        icon: BaseboundIconName.addPlace,
        onPressed: onAdd,
      ),
      const SizedBox(height: 28),
      meetingPoint,
    ],
  );
}

class ParentReadyStage extends StatelessWidget {
  const ParentReadyStage({
    required this.plan,
    required this.onOpenLandmarks,
    required this.onReview,
    super.key,
  });

  final FamilyPlan plan;
  final VoidCallback onOpenLandmarks;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading(
        'Gotowi do wspólnych ćwiczeń',
        BaseboundIconName.check,
      ),
      Text(
        'Zapisane kontakty: ${plan.contacts.length} · bezpieczne miejsca: ${plan.safePoints.length}',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      ParentEditorNote(
        message: plan.safePoints.isEmpty
            ? 'Nie wybrano bezpiecznego miejsca. Dodaj miejsce lub poznaj Naszą mapę.'
            : 'Zapisane miejsca są dostępne na Naszej mapie.',
        icon: BaseboundIconName.play,
      ),
      const SizedBox(height: 16),
      const Text(
        'Tylko ćwiczenie. Bezpieczeństwo zapisanych miejsc nie jest sprawdzane. Bez nawigacji i pomocy w prawdziwych zagrożeniach.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 16),
      const Text(
        'Ćwiczenie zgubienia się uczy rozpoznawania wybranego zdjęcia i znacznika na Naszej mapie. '
        'Połączenia, odpowiedzi i potwierdzenie bezpieczeństwa są symulowane. Żadna wiadomość nie jest wysyłana.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      BaseboundActionTile(
        label: 'Wspólny spacer',
        icon: BaseboundIconName.map,
        onPressed: onOpenLandmarks,
      ),
      const SizedBox(height: 12),
      BaseboundActionTile(
        label: 'Sprawdź ustawienia',
        icon: BaseboundIconName.edit,
        onPressed: onReview,
      ),
    ],
  );
}
