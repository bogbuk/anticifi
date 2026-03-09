import 'package:speech_to_text/speech_to_text.dart';

import '../storage/secure_storage.dart';

class SpeechService {
  final SecureStorage _storage;
  SpeechToText? _speech;
  bool _initialized = false;
  bool _available = false;
  bool _listening = false;

  static const int _freeLimit = 3;

  SpeechService({required SecureStorage storage}) : _storage = storage;

  bool get isListening => _listening;

  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      _speech = SpeechToText();
      _available = await _speech!.initialize();
    } catch (e) {
      _available = false;
      _speech = null;
    }
    return _available;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String? localeId,
  }) async {
    if (_speech == null) return;
    _listening = true;
    await _speech!.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) _listening = false;
      },
      localeId: localeId ?? 'ru_RU',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    _listening = false;
    try {
      await _speech?.stop();
    } catch (_) {}
  }

  String _todayKey() {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'voice_input_count_$date';
  }

  Future<int> _getUsageCount() async {
    final value = await _storage.read(key: _todayKey());
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  Future<bool> canUseVoiceInput(bool isPremium) async {
    if (isPremium) return true;
    final count = await _getUsageCount();
    return count < _freeLimit;
  }

  Future<void> incrementUsageCount() async {
    final count = await _getUsageCount();
    await _storage.write(key: _todayKey(), value: '${count + 1}');
  }

  Future<int> getRemainingUses(bool isPremium) async {
    if (isPremium) return -1; // unlimited
    final count = await _getUsageCount();
    return (_freeLimit - count).clamp(0, _freeLimit);
  }
}
