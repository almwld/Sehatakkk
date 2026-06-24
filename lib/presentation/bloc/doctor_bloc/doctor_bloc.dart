import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/doctor_models/doctor_model.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}
class DoctorLoading extends DoctorState {}
class DoctorsLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  const DoctorsLoaded(this.doctors);
  @override
  List<Object?> get props => [doctors];
}
class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorEvent {}

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  DoctorBloc() : super(DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
  }

  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(DoctorsLoaded(const []));
  }
}
