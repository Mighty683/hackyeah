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
  'window': Rect.fromLTWH(.025, .16, .31, .40),
  'door': Rect.fromLTWH(.655, .15, .32, .45),
  'interior': Rect.fromLTWH(.355, .25, .28, .40),
};

const _apartmentTargets = {
  'living_room': Rect.fromLTWH(.07, .10, .36, .33),
  'bedroom': Rect.fromLTWH(.58, .10, .35, .33),
  'kitchen': Rect.fromLTWH(.07, .54, .36, .35),
  'hallway': Rect.fromLTWH(.58, .54, .29, .34),
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
        'hallway': Offset(.76, .70),
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
      targets: {
        'call': Rect.fromLTWH(.21, .28, .58, .28),
        'message': Rect.fromLTWH(.21, .60, .58, .28),
      },
      childWidth: 0,
    ),
    'noise' => const MissionSceneLayout(
      family: MissionVisual.apartment,
      targets: {
        'window': Rect.fromLTWH(.07, .08, .36, .35),
        'door': Rect.fromLTWH(.57, .37, .36, .18),
        'stay': Rect.fromLTWH(.58, .59, .29, .30),
      },
      childFeet: Offset(.76, .70),
      childWidth: .20,
      destinations: {'window': Offset(.25, .28), 'door': Offset(.76, .28)},
    ),
    'quiet' => const MissionSceneLayout(
      family: MissionVisual.quiet,
      asset: 'assets/illustrations/hallway-practice-v2.png',
      targets: {
        'leave': Rect.fromLTWH(.655, .20, .31, .40),
        'stay': Rect.fromLTWH(.24, .66, .40, .30),
      },
      childFeet: Offset(.47, .76),
      childWidth: .35,
      destinations: {'leave': Offset(.89, .435)},
      selectedTargets: {'leave': Rect.fromLTWH(.62, .18, .35, .13)},
      selectedChildWidth: .18,
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
