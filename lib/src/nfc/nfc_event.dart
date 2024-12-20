// nfc_event.dart
abstract class NfcEvent {}

class ReadNfcTagEvent extends NfcEvent {}

class WriteNfcTagEvent extends NfcEvent {}

class CycleNfcTagEvent extends NfcEvent {}

class FillNfcTagEvent extends NfcEvent {}
