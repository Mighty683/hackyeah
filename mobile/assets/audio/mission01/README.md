# Mission 01 offline audio

This folder bundles audio for a fictional, unreviewed training mission. The cues
are brief playback excerpts, not complete emergency signals. Narration uses an
installed offline Android English text-to-speech voice; no speech is downloaded
or generated through a remote service. If no suitable voice is installed, the
app asks for adult help and permits another initialization attempt.

## Official Polish alarm recordings

Publisher: Rządowe Centrum Bezpieczeństwa (Government Centre for Security),
Poland. Downloaded 2026-10-03 from its [Sygnały alarmowe page](https://www.gov.pl/web/rcb/sygnaly-alarmowe3).

| Bundled file | Original download | SHA-256 |
| --- | --- | --- |
| `alarm.wav` | [Ogłoszenie Alarmu.wav](https://www.gov.pl/attachment/7d861509-e143-4c42-a45f-ec107c13654e) | `266e9f0ef31b691b18bd46c911bffbc8ea9b72046aa429b7c412b5a702c8c8d4` |
| `all_clear.wav` | [Odwołanie Alarmu.wav](https://www.gov.pl/attachment/25b0c8db-a687-4c21-810a-2d448b19e6b3) | `0676766372cdf5d8158bf19f1ab4fb2d027de90526aec45c1091382c0881a0aa` |

Both files retain their original downloaded bytes and contain mono 8 kHz G.711
A-law audio. Android decodes an excerpt into memory for playback at reduced
volume: warning seconds 6–10, all-clear seconds 2–5. No shortened, edited or
re-encoded version of either official recording is distributed.

The source page's default audiovisual license is
[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/): attribution,
noncommercial use, and no sharing adapted materials. Preserve this attribution
and license notice with the demo. Commercial distribution or sharing edited
recordings requires separate permission or replacement assets.

The [Ministry of Interior's signal description](https://www.gov.pl/web/mswia/alarmowanie-i-ostrzeganie)
describes the full Polish general warning as a modulated three-minute siren and
the all-clear as a continuous three-minute siren. These are general alarm
signals, not a distinct air-raid-specific siren code. The short training excerpts
must not be mistaken for the full signal or for an actual warning.

## Synthetic environmental cue

`noise.wav` is an original one-second, quiet, low-frequency environmental cue
generated for this project, with smooth onset and ending. It contains no real
explosion recording, speech, panic, or official signal. It is project-created
demo audio and has no third-party attribution requirement.

## Playback lifecycle

`basebound/mission_audio` supplies initialization, narration, stop and disposal.
Each new instruction cancels the previous cue and speech. Exiting or pausing the
activity stops audio; disposing the screen releases text-to-speech resources.
Network-required voices and voices marked not installed are rejected. Android
voice availability remains device-dependent; prepare an offline English voice
before a child-facing demo.
