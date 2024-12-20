abstract class NfcState {}

class NfcInitialState extends NfcState {}

class NfcScanningState extends NfcState {}

class NfcTagFoundState extends NfcState {
  final String tagId;
  NfcTagFoundState(this.tagId);
}

class NfcTagReadState extends NfcState {
  final String data;
  NfcTagReadState(this.data);
}

class NfcTagWriteState extends NfcState {
  final String status;
  NfcTagWriteState(this.status);
}

class NfcTagCycleState extends NfcState {
  final String status;
  NfcTagCycleState(this.status);
}

class FillNfcTagState extends NfcState {
  final String status;
  FillNfcTagState(this.status);
}

class NfcErrorState extends NfcState {
  final String errorMessage;
  NfcErrorState(this.errorMessage);
}
