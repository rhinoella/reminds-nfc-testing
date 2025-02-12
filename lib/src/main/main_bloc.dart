import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class RemindsEvent {}

class DispenseEvent extends RemindsEvent {}

class ReturnEvent extends RemindsEvent {}

// States
abstract class RemindsState {}

class NfcInitial extends RemindsState {}

class DispenseSuccessState extends RemindsState {}

class ReturnSuccessState extends RemindsState {}

class RemindsBloc extends Bloc<RemindsEvent, RemindsState> {
  RemindsBloc() : super(NfcInitial()) {
    on<DispenseEvent>((event, emit) {
      // Simulate success
      emit(DispenseSuccessState());
    });

    on<ReturnEvent>((event, emit) {
      emit(ReturnSuccessState());
    });
  }
}
