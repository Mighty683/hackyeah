/// Native builds keep using the Android audio channel.
class BrowserNarration {
  Future<bool> initialize() async => false;
  Future<void> narrate(String text) async {}
  Future<void> playCue(String sound) async {}
  void stop() {}
}
