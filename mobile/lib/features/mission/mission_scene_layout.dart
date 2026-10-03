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
  'window': Rect.fromLTWH(0, .015, .18, .40),
  'door': Rect.fromLTWH(.77, .10, .22, .50),
  'interior': Rect.fromLTWH(.35, .15, .29, .44),
};

const _apartmentTargets = {
  'living_room': Rect.fromLTWH(.085, .07, .335, .34),
  'bedroom': Rect.fromLTWH(.595, .07, .305, .34),
  'kitchen': Rect.fromLTWH(.04, .54, .38, .35),
  'hallway': Rect.fromLTWH(.425, .44, .16, .43),
};

const _streetDestinations = {
  // Wrong destinations stop along the street: the child has not arrived.
  'home': Offset(.43, .70),
  'school': Offset(.53, .70),
  'shelter': Offset(.70, .50),
  'park': Offset(.38, .79),
  'bus_stop': Offset(.58, .80),
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
      asset: 'assets/illustrations/home-practice-v2.png',
      targets: _homeTargets,
      selectedChildWidth: .24,
      selectedTargets: {
        'window': Rect.fromLTWH(.025, .18, .34, .14),
        'door': Rect.fromLTWH(.635, .12, .34, .14),
        'interior': Rect.fromLTWH(.35, .25, .30, .14),
      },
      destinations: {
        'window': Offset(.21, .62),
        'door': Offset(.81, .57),
        'interior': Offset(.49, .52),
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
        'hallway': Offset(.505, .75),
      },
    ),
    'destination' => const MissionSceneLayout(
      family: MissionVisual.street,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {
        'home': Rect.fromLTWH(.025, .16, .37, .23),
        'school': Rect.fromLTWH(.62, .16, .35, .19),
        'shelter': Rect.fromLTWH(.56, .38, .41, .23),
        'more_places': Rect.fromLTWH(.025, .80, .40, .18),
      },
      childFeet: Offset(.47, .84),
      childWidth: .31,
      destinations: _streetDestinations,
      selectedTargets: _streetSelectedTargets,
      selectedChildWidth: .24,
    ),
    'outdoor_places' => const MissionSceneLayout(
      family: MissionVisual.street,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {
        'park': Rect.fromLTWH(.025, .64, .39, .20),
        'bus_stop': Rect.fromLTWH(.63, .71, .34, .25),
        'shelter': Rect.fromLTWH(.56, .38, .41, .23),
      },
      childFeet: Offset(.47, .84),
      childWidth: .31,
      destinations: _streetDestinations,
      selectedTargets: _streetSelectedTargets,
      selectedChildWidth: .24,
    ),
    'contacts' => const MissionSceneLayout(
      family: MissionVisual.contacts,
      targets: {
        'mom': Rect.fromLTWH(.21, .20, .58, .19),
        'dad': Rect.fromLTWH(.21, .41, .58, .19),
        'grandparent': Rect.fromLTWH(.21, .62, .58, .19),
      },
      childWidth: 0,
    ),
    'communication' => const MissionSceneLayout(
      family: MissionVisual.communication,
      targets: {'call': Rect.fromLTWH(.21, .37, .58, .20)},
      childWidth: 0,
    ),
    'sms' => const MissionSceneLayout(
      family: MissionVisual.communication,
      targets: {'message': Rect.fromLTWH(.21, .37, .58, .20)},
      childWidth: 0,
    ),
    'noise' => const MissionSceneLayout(
      family: MissionVisual.apartment,
      targets: {
        'window': Rect.fromLTWH(.11, .05, .30, .17),
        'door': Rect.fromLTWH(.405, .85, .21, .135),
        'stay': Rect.fromLTWH(.425, .56, .16, .285),
      },
      childFeet: Offset(.505, .75),
      childWidth: .18,
      destinations: {'window': Offset(.25, .28), 'door': Offset(.505, .91)},
    ),
    'quiet' => const MissionSceneLayout(
      family: MissionVisual.quiet,
      asset: 'assets/illustrations/hallway-practice-v2.png',
      targets: {
        'leave': Rect.fromLTWH(.815, 0, .16, .68),
        'stay': Rect.fromLTWH(.27, .51, .37, .40),
      },
      childFeet: Offset(.47, .76),
      childWidth: .35,
    ),
    'outdoor_noise' => const MissionSceneLayout(
      family: MissionVisual.street,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {},
      childWidth: 0,
    ),
    'get_down' => const MissionSceneLayout(
      family: MissionVisual.getDown,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {
        'stay': Rect.fromLTWH(.04, .46, .44, .50),
        'down': Rect.fromLTWH(.52, .46, .44, .50),
      },
      childWidth: 0,
    ),
    'protect_head' => const MissionSceneLayout(
      family: MissionVisual.protectHead,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {
        'stay': Rect.fromLTWH(.04, .46, .44, .50),
        'protect_head': Rect.fromLTWH(.52, .46, .44, .50),
      },
      childWidth: 0,
    ),
    'outdoor_recover' => const MissionSceneLayout(
      family: MissionVisual.protectHead,
      asset: 'assets/illustrations/street-practice-v2.png',
      targets: {},
      childWidth: 0,
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
    asset: 'assets/illustrations/home-practice-v2.png',
    targets: visual == MissionVisual.room ? _homeTargets : const {},
  ),
  MissionVisual.sheltered || MissionVisual.quiet => MissionSceneLayout(
    family: visual,
    asset: 'assets/illustrations/hallway-practice-v2.png',
    targets: const {},
    childFeet: const Offset(.47, .83),
  ),
  MissionVisual.street => const MissionSceneLayout(
    family: MissionVisual.street,
    asset: 'assets/illustrations/street-practice-v2.png',
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
