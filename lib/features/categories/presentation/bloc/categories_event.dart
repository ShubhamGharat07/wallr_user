// lib/features/categories/presentation/bloc/categories_event.dart

import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested();
}
