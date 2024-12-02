import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/models/moments.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:faker/faker.dart' as faker;
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

part 'moment_event.dart';
part 'moment_state.dart';

class MomentBloc extends Bloc<MomentEvent, MomentState> {
  final _faker = faker.Faker();
  List<Moment> moments = [];
  MomentBloc() : super(MomentInitial()) {
    moments = List.generate(
      2,
      (index) => Moment(
        id: nanoid(),
        momentDate: _faker.date.dateTime(),
        creator: _faker.person.name(),
        location: _faker.address.city(),
        imageUrl: 'https://picsum.photos/800/600?random=$index',
        caption: _faker.lorem.sentence(),
        likeCount: faker.random.integer(1000),
        commentCount: faker.random.integer(100),
        bookmarkCount: faker.random.integer(50),
      ),
    );

    // Deklarasi event handler
    on<MomentGetEvent>(momentGetEvent);
    on<MomentGetByIdEvent>(momentGetByIdEvent);
    on<MomentAddEvent>(momentAddEvent);
    on<MomentUpdateEvent>(momentUpdateEvent);
    on<MomentDeleteEvent>(momentDeleteEvent);
    on<MomentNavigateToAddEvent>(momentNavigateToAddEvent);
    on<MomentNavigateToUpdateEvent>(momentNavigateToUpdateEvent);
    on<MomentNavigateToDeleteEvent>(momentNavigateToDeleteEvent);
    on<MomentNavigateBackEvent>(momentNavigateBackEvent);
  }

  Moment? getMomentById(String momentId) {
    return moments.firstWhereOrNull((moment) => moment.id == momentId);
  }

  FutureOr<void> momentGetEvent(MomentGetEvent event, Emitter<MomentState> emit) async {
    emit(MomentGetLoadingState());
    try {
      Future.delayed(const Duration(seconds: 1));
      emit(MomentGetSuccessState(moments));
    } catch (e) {
      emit(MomentGetErrorActionState(e.toString()));
    }
  }

  FutureOr<void> momentAddEvent(MomentAddEvent event, Emitter<MomentState> emit) async {
    emit(MomentAddingState());
    try {
      Future.delayed(const Duration(seconds: 1));
      moments.add(event.newMoment);
      emit(MomentAddedSuccessActionState(event.newMoment));
    } catch (e) {
      emit(MomentAddedErrorActionState(e.toString()));
    }
  }

  FutureOr<void> momentUpdateEvent(MomentUpdateEvent event, Emitter<MomentState> emit) async {
    emit(MomentUpdatingState());
    try {
      final existingMoment = getMomentById(event.updatedMoment.id);
      if (existingMoment != null) {
        moments[moments.indexOf(existingMoment)] = event.updatedMoment;
        emit(MomentUpdatedSuccessActionState(event.updatedMoment));
      } else {
        emit(const MomentUpdatedErrorActionState('Moment not found'));
      }
    } catch (e) {
      emit(MomentUpdatedErrorActionState(e.toString()));
    }
  }

  FutureOr<void> momentDeleteEvent(MomentDeleteEvent event, Emitter<MomentState> emit) async {
    emit(MomentDeletingState());
    try {
      final existingMoment = getMomentById(event.momentId);
      if (existingMoment != null) {
        await Future.delayed(const Duration(seconds: 1));
        moments.remove(existingMoment);
        emit(MomentDeletedSuccessActionState());
      } else {
        emit(const MomentDeletedErrorActionState('Moment not found'));
      }
    } catch (e) {
      emit(MomentDeletedErrorActionState(e.toString()));
    }
  }

  FutureOr<void> momentNavigateToAddEvent(MomentNavigateToAddEvent event, Emitter<MomentState> emit) {
    emit(MomentNavigateToAddActionState());
  }

  FutureOr<void> momentNavigateToUpdateEvent(MomentNavigateToUpdateEvent event, Emitter<MomentState> emit) {
    emit(MomentNavigateToUpdateActionState(event.momentId));
  }

  FutureOr<void> momentNavigateToDeleteEvent(MomentNavigateToDeleteEvent event, Emitter<MomentState> emit) {
    emit(MomentNavigateToDeleteActionState(event.momentId));
  }

  FutureOr<void> momentNavigateBackEvent(MomentNavigateBackEvent event, Emitter<MomentState> emit) {
    emit(MomentNavigateBackActionState());
  }

  FutureOr<void> momentGetByIdEvent(MomentGetByIdEvent event, Emitter<MomentState> emit) async {
    emit(MomentGetByIdLoadingState());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final moment = getMomentById(event.momentId);
      if (moment != null) {
        emit(MomentGetByIdSuccessState(moment));
      } else {
        emit(const MomentGetByIdErrorActionState('Moment not found'));
      }
    } catch (e) {
      emit(MomentGetByIdErrorActionState(e.toString()));
    }
  }
}