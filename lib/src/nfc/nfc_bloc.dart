import 'package:flutter_bloc/flutter_bloc.dart';
import 'nfc_event.dart';
import 'nfc_state.dart';
import '../services/nfc_service.dart';

class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcService _nfcService;

  NfcBloc(this._nfcService) : super(NfcInitialState()) {
    on<ReadNfcTagEvent>((event, emit) async {
      try {
        emit(NfcScanningState());
        var tag = await _nfcService.readNfc();
        emit(NfcTagFoundState(tag ?? "Nothing"));
      } catch (e) {
        emit(NfcErrorState('Error reading NFC tag: $e'));
      }
    });

    on<WriteNfcTagEvent>((event, emit) async {
      try {
        emit(NfcTagWriteState('Writing to NFC tag'));
        await _nfcService.writeNfc();
        emit(NfcTagWriteState("Written!"));
      } catch (e) {
        emit(NfcErrorState('Error writing NFC tag: $e'));
      }
    });

    on<FillNfcTagEvent>((event, emit) async {
      try {
        emit(FillNfcTagState('Filling NFC tag'));
        await _nfcService.fillNfc();
        emit(FillNfcTagState("Filling Done"));
      } catch (e) {
        emit(NfcErrorState('Error Filling NFC tag: $e'));
      }
    });

    on<CycleNfcTagEvent>((event, emit) async {
      try {
        emit(NfcTagCycleState('Cycling NFC tag'));
        await _nfcService.cycleNfc();
        emit(NfcTagCycleState("Cycling Done"));
      } catch (e) {
        emit(NfcErrorState('Error cycling NFC tag: $e'));
      }
    });
  }
}
