import 'package:flutter/material.dart';

import 'air_raid_mission.dart';

/// Scene art and native controls share this uncropped portrait coordinate space.
const missionSceneSize = Size(400, 600);

class MissionSceneLayout {
  const MissionSceneLayout({
    required this.family,
    required this.targets,
    this.childFeet = const Offset(.39, .95),
    this.childWidth = .40,
    this.destinations = const {},
    this.selectedTargets = const {},
    this.selectedChildWidth,
    this.asset,
  });

  final MissionVisual family;
  final Map<String, Rect> targets;
  final Offset childFeet;
  final double childWidth;
  final Map<String, Offset> destinations;
  final Map<String, Rect> selectedTargets;
  final double? selectedChildWidth;
  final String? asset;
}

const _homeTargets = {
  'window': Rect.fromLTWH(.025, .40, .34, .16),
  'door': Rect.fromLTWH(.635, .40, .34, .16),
  'interior': Rect.fromLTWH(.565, .77, .405, .16),
};

const _apartmentTargets = {
  'living_room': Rect.fromLTWH(.055, .29, .385, .15),
  'bedroom': Rect.fromLTWH(.565, .29, .385, .15),
  'kitchen': Rect.fromLTWH(.055, .73, .385, .15),
  'hallway': Rect.fromLTWH(.565, .73, .385, .15),
};

const _streetDestinations = {
  'home': Offset(.19, .265),
  'school': Offset(.85, .277),
  'shelter': Offset(.70, .50),
  'park': Offset(.22, .74),
  'bus_stop': Offset(.84, .795),
};

const _streetSelectedTargets = {
  'home': Rect.fromLTWH(.02, .285, .38, .12),
  'school': Rect.fromLTWH(.60, .30, .38, .12),
  'shelter': Rect.fromLTWH(.56, .28, .42, .11),
  'park': Rect.fromLTWH(.025, .50, .35, .11),
  'bus_stop': Rect.fromLTWH(.63, .57, .34, .12),
};

MissionSceneLayout missionSceneLayout(String? stepId, MissionVisual visual) {
  return switch (stepId) {
    'room' => const MissionSceneLayout(
      family: MissionVisual.room,
      asset: 'assets/illustrations/home-practice-portrait.png',
      targets: _homeTargets,
      selectedChildWidth: .24,
      selectedTargets: {
        'window': Rect.fromLTWH(.025, .18, .34, .14),
        'door': Rect.fromLTWH(.635, .12, .34, .14),
        'interior': Rect.fromLTWH(.565, .55, .405, .15),
      },
      destinations: {
        'window': Offset(.21, .63),
        'door': Offset(.75, .50),
        'interior': Offset(.80, .91),
      },
    ),
    'apartment' => const MissionSceneLayout(
      family: MissionVisual.apartment,
      targets: _apartmentTargets,
      childFeet: Offset(.50, .57),
      childWidth: .17,
      destinations: {
        'living_room': Offset(.25, .28),
        'bedroom': Offset(.76, .28),
        'kitchen': Offset(.25, .71),
        'hallway': Offset(.76, .70),
      },
    ),
    'destination' => const MissionSceneLayout(
      family: MissionVisual.street,
      asset: 'assets/illustrations/street-practice-portrait.png',
      targets: {
        'home': Rect.fromLTWH(.02, .23, .38, .16),
        'school': Rect.fromLTWH(.60, .18, .38, .16),
        'shelter': Rect.fromLTWH(.56, .37, .42, .17),
        'more_places': Rect.fromLTWH(.02, .81, .40, .16),
      },
      childFeet: Offset(.47, .84),
      childWidth: .31,
      destinations: _streetDestinations,
      selectedTargets: _streetSelectedTargets,
      selectedChildWidth: .16,
    ),
    'outdoor_places' => const MissionSceneLayout(
      family: MissionVisual.street,
      asset: 'assets/illustrations/street-practice-portrait.png',
      targets: {
        'park': Rect.fromLTWH(.025, .64, .35, .15),
        'bus_stop': Rect.fromLTWH(.63, .78, .34, .17),
        'shelter': Rect.fromLTWH(.56, .37, .42, .17),
      },
      childFeet: Offset(.47, .84),
      childWidth: .31,
      destinations: _streetDestinations,
      selectedTargets: _streetSelectedTargets,
      selectedChildWidth: .16,
    ),
    'contacts' => const MissionSceneLayout(
      family: MissionVisual.contacts,
      targets: {
        'mom': Rect.fromLTWH(.21, .22, .58, .14),
        'dad': Rect.fromLTWH(.21, .43, .58, .14),
        'grandparent': Rect.fromLTWH(.21, .64, .58, .14),
      },
      childWidth: 0,
    ),
    'communication' => const MissionSceneLayout(
      family: MissionVisual.communication,
      targets: {
        'call': Rect.fromLTWH(.21, .32, .58, .18),
        'message': Rect.fromLTWH(.21, .59, .58, .18),
      },
      childWidth: 0,
    ),
    'noise' => const MissionSceneLayout(
      family: MissionVisual.apartment,
      targets: {
        'window': Rect.fromLTWH(.055, .29, .385, .15),
        'door': Rect.fromLTWH(.565, .29, .385, .15),
        'stay': Rect.fromLTWH(.565, .73, .385, .15),
      },
      childFeet: Offset(.76, .70),
      childWidth: .20,
      destinations: {'window': Offset(.25, .28), 'door': Offset(.76, .28)},
    ),
    'quiet' => const MissionSceneLayout(
      family: MissionVisual.quiet,
      asset: 'assets/illustrations/hallway-practice-portrait.png',
      targets: {
        'leave': Rect.fromLTWH(.635, .36, .34, .17),
        'stay': Rect.fromLTWH(.24, .79, .52, .17),
      },
      childFeet: Offset(.47, .76),
      childWidth: .35,
      destinations: {'leave': Offset(.89, .435)},
      selectedTargets: {'leave': Rect.fromLTWH(.62, .18, .35, .13)},
      selectedChildWidth: .18,
    ),
    'get_down' => const MissionSceneLayout(
      family: MissionVisual.getDown,
      targets: {
        'stay': Rect.fromLTWH(.625, .42, .35, .18),
        'down': Rect.fromLTWH(.03, .77, .39, .17),
      },
      childFeet: Offset(.49, .77),
      childWidth: .52,
    ),
    'protect_head' => const MissionSceneLayout(
      family: MissionVisual.protectHead,
      targets: {
        'stay': Rect.fromLTWH(.03, .72, .40, .18),
        'protect_head': Rect.fromLTWH(.55, .36, .425, .17),
      },
      childFeet: Offset(.49, .77),
      childWidth: .52,
    ),
    _ => _nonDecisionLayout(visual),
  };
}

MissionSceneLayout _nonDecisionLayout(MissionVisual visual) => switch (visual) {
  MissionVisual.twoWalls => const MissionSceneLayout(
    family: MissionVisual.twoWalls,
    targets: {},
    childFeet: Offset(.29, .73),
    childWidth: .42,
  ),
  MissionVisual.alarm ||
  MissionVisual.allClear ||
  MissionVisual.room => MissionSceneLayout(
    family: visual,
    asset: 'assets/illustrations/home-practice-portrait.png',
    targets: visual == MissionVisual.room ? _homeTargets : const {},
  ),
  MissionVisual.sheltered || MissionVisual.quiet => MissionSceneLayout(
    family: visual,
    asset: 'assets/illustrations/hallway-practice-portrait.png',
    targets: const {},
    childFeet: const Offset(.47, .83),
  ),
  MissionVisual.street => const MissionSceneLayout(
    family: MissionVisual.street,
    asset: 'assets/illustrations/street-practice-portrait.png',
    targets: {},
    childFeet: Offset(.47, .84),
    childWidth: .31,
  ),
  MissionVisual.apartment => const MissionSceneLayout(
    family: MissionVisual.apartment,
    targets: _apartmentTargets,
    childFeet: Offset(.50, .57),
    childWidth: .17,
  ),
  MissionVisual.contacts ||
  MissionVisual.communication ||
  MissionVisual.message ||
  MissionVisual.recall => MissionSceneLayout(
    family: visual,
    targets: const {},
    childWidth: 0,
  ),
  _ => MissionSceneLayout(family: visual, targets: const {}),
};
