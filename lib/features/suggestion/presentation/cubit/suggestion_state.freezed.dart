// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SuggestionState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SuggestionState()';
}


}

/// @nodoc
class $SuggestionStateCopyWith<$Res>  {
$SuggestionStateCopyWith(SuggestionState _, $Res Function(SuggestionState) __);
}


/// Adds pattern-matching-related methods to [SuggestionState].
extension SuggestionStatePatterns on SuggestionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Suggesting value)?  suggesting,TResult Function( _HasActiveTask value)?  hasActiveTask,TResult Function( _HasSuggestion value)?  hasSuggestion,TResult Function( _Empty value)?  empty,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Suggesting() when suggesting != null:
return suggesting(_that);case _HasActiveTask() when hasActiveTask != null:
return hasActiveTask(_that);case _HasSuggestion() when hasSuggestion != null:
return hasSuggestion(_that);case _Empty() when empty != null:
return empty(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Suggesting value)  suggesting,required TResult Function( _HasActiveTask value)  hasActiveTask,required TResult Function( _HasSuggestion value)  hasSuggestion,required TResult Function( _Empty value)  empty,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Suggesting():
return suggesting(_that);case _HasActiveTask():
return hasActiveTask(_that);case _HasSuggestion():
return hasSuggestion(_that);case _Empty():
return empty(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Suggesting value)?  suggesting,TResult? Function( _HasActiveTask value)?  hasActiveTask,TResult? Function( _HasSuggestion value)?  hasSuggestion,TResult? Function( _Empty value)?  empty,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Suggesting() when suggesting != null:
return suggesting(_that);case _HasActiveTask() when hasActiveTask != null:
return hasActiveTask(_that);case _HasSuggestion() when hasSuggestion != null:
return hasSuggestion(_that);case _Empty() when empty != null:
return empty(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  suggesting,TResult Function( Task activeTask)?  hasActiveTask,TResult Function( Task suggestedTask,  List<String> excludedIds)?  hasSuggestion,TResult Function( String message)?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Suggesting() when suggesting != null:
return suggesting();case _HasActiveTask() when hasActiveTask != null:
return hasActiveTask(_that.activeTask);case _HasSuggestion() when hasSuggestion != null:
return hasSuggestion(_that.suggestedTask,_that.excludedIds);case _Empty() when empty != null:
return empty(_that.message);case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  suggesting,required TResult Function( Task activeTask)  hasActiveTask,required TResult Function( Task suggestedTask,  List<String> excludedIds)  hasSuggestion,required TResult Function( String message)  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Suggesting():
return suggesting();case _HasActiveTask():
return hasActiveTask(_that.activeTask);case _HasSuggestion():
return hasSuggestion(_that.suggestedTask,_that.excludedIds);case _Empty():
return empty(_that.message);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  suggesting,TResult? Function( Task activeTask)?  hasActiveTask,TResult? Function( Task suggestedTask,  List<String> excludedIds)?  hasSuggestion,TResult? Function( String message)?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Suggesting() when suggesting != null:
return suggesting();case _HasActiveTask() when hasActiveTask != null:
return hasActiveTask(_that.activeTask);case _HasSuggestion() when hasSuggestion != null:
return hasSuggestion(_that.suggestedTask,_that.excludedIds);case _Empty() when empty != null:
return empty(_that.message);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements SuggestionState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SuggestionState.initial()';
}


}




/// @nodoc


class _Loading implements SuggestionState {
  const _Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SuggestionState.loading()';
}


}




/// @nodoc


class _Suggesting implements SuggestionState {
  const _Suggesting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggesting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SuggestionState.suggesting()';
}


}




/// @nodoc


class _HasActiveTask implements SuggestionState {
  const _HasActiveTask({required this.activeTask});
  

 final  Task activeTask;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HasActiveTaskCopyWith<_HasActiveTask> get copyWith => __$HasActiveTaskCopyWithImpl<_HasActiveTask>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HasActiveTask&&(identical(other.activeTask, activeTask) || other.activeTask == activeTask));
}


@override
int get hashCode {
    return Object.hash(runtimeType,activeTask);
}

@override
String toString() {
    return 'SuggestionState.hasActiveTask(activeTask: $activeTask)';
}


}

/// @nodoc
abstract mixin class _$HasActiveTaskCopyWith<$Res> implements $SuggestionStateCopyWith<$Res> {
  factory _$HasActiveTaskCopyWith(_HasActiveTask value, $Res Function(_HasActiveTask) _then) = __$HasActiveTaskCopyWithImpl;
@useResult
$Res call({
 Task activeTask
});


$TaskCopyWith<$Res> get activeTask;

}
/// @nodoc
class __$HasActiveTaskCopyWithImpl<$Res>
    implements _$HasActiveTaskCopyWith<$Res> {
  __$HasActiveTaskCopyWithImpl(this._self, this._then);

  final _HasActiveTask _self;
  final $Res Function(_HasActiveTask) _then;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activeTask = null,}) {
  return _then(_HasActiveTask(
activeTask: null == activeTask ? _self.activeTask : activeTask // ignore: cast_nullable_to_non_nullable
as Task,
  ));
}

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get activeTask {
  
  return $TaskCopyWith<$Res>(_self.activeTask, (value) {
    return _then(_self.copyWith(activeTask: value));
  });
}
}

/// @nodoc


class _HasSuggestion implements SuggestionState {
  const _HasSuggestion({required this.suggestedTask, required  List<String> excludedIds}): _excludedIds = excludedIds;
  

 final  Task suggestedTask;
 final  List<String> _excludedIds;
 List<String> get excludedIds {
  if (_excludedIds is EqualUnmodifiableListView) return _excludedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedIds);
}


/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HasSuggestionCopyWith<_HasSuggestion> get copyWith => __$HasSuggestionCopyWithImpl<_HasSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HasSuggestion&&(identical(other.suggestedTask, suggestedTask) || other.suggestedTask == suggestedTask)&&const DeepCollectionEquality().equals(other.excludedIds, _excludedIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,suggestedTask,const DeepCollectionEquality().hash(_excludedIds));
}

@override
String toString() {
    return 'SuggestionState.hasSuggestion(suggestedTask: $suggestedTask, excludedIds: $excludedIds)';
}


}

/// @nodoc
abstract mixin class _$HasSuggestionCopyWith<$Res> implements $SuggestionStateCopyWith<$Res> {
  factory _$HasSuggestionCopyWith(_HasSuggestion value, $Res Function(_HasSuggestion) _then) = __$HasSuggestionCopyWithImpl;
@useResult
$Res call({
 Task suggestedTask, List<String> excludedIds
});


$TaskCopyWith<$Res> get suggestedTask;

}
/// @nodoc
class __$HasSuggestionCopyWithImpl<$Res>
    implements _$HasSuggestionCopyWith<$Res> {
  __$HasSuggestionCopyWithImpl(this._self, this._then);

  final _HasSuggestion _self;
  final $Res Function(_HasSuggestion) _then;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? suggestedTask = null,Object? excludedIds = null,}) {
  return _then(_HasSuggestion(
suggestedTask: null == suggestedTask ? _self.suggestedTask : suggestedTask // ignore: cast_nullable_to_non_nullable
as Task,excludedIds: null == excludedIds ? _self._excludedIds : excludedIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get suggestedTask {
  
  return $TaskCopyWith<$Res>(_self.suggestedTask, (value) {
    return _then(_self.copyWith(suggestedTask: value));
  });
}
}

/// @nodoc


class _Empty implements SuggestionState {
  const _Empty({required this.message});
  

 final  String message;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmptyCopyWith<_Empty> get copyWith => __$EmptyCopyWithImpl<_Empty>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Empty&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'SuggestionState.empty(message: $message)';
}


}

/// @nodoc
abstract mixin class _$EmptyCopyWith<$Res> implements $SuggestionStateCopyWith<$Res> {
  factory _$EmptyCopyWith(_Empty value, $Res Function(_Empty) _then) = __$EmptyCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$EmptyCopyWithImpl<$Res>
    implements _$EmptyCopyWith<$Res> {
  __$EmptyCopyWithImpl(this._self, this._then);

  final _Empty _self;
  final $Res Function(_Empty) _then;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Empty(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements SuggestionState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'SuggestionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $SuggestionStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of SuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
