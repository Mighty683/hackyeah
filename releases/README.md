# Tuptu Android demo

[`tuptu-release.apk`](tuptu-release.apk) is the universal Android release APK (version 0.1.0, build 1), built from app source at commit `2bd26d6`. It supports the Android architectures bundled by Flutter, so users do not need to choose a separate download for their phone.

Requires Android 7.0 or newer. Download the APK on an Android phone, open it, allow installation from the browser or file manager when prompted, and tap **Install**. Launch **Tuptu** after installation. Flutter and the Android SDK are not required to use it.

The release build uses the existing debug signing configuration for hackathon distribution. It is not a Play Store release. If Android reports a signing conflict with an existing installation, uninstall the previous app first; uninstalling deletes its saved local data.

Use fictional family details for demos. Training and the unreviewed help prototype are not for real emergencies. Android narration requires an installed offline Polish TTS voice. Map walking guidance requires an accompanying adult and works only within the bundled TAURON Arena area.

To refresh the committed APK from the repository root:

```sh
cd mobile
flutter build apk --release
cd ..
cp mobile/build/app/outputs/flutter-apk/app-release.apk releases/tuptu-release.apk
sha256sum releases/tuptu-release.apk > releases/SHA256SUMS
```

Update the source commit and version above when replacing the APK, then commit the APK, checksum and documentation together.
