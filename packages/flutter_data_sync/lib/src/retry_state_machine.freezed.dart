// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'retry_state_machine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$RetryStateTearOff {
  const _$RetryStateTearOff();

  _IdleState idle() {
    return const _IdleState();
  }

  _DisabledState disabled() {
    return const _DisabledState();
  }

  _PendingRetryState pendingRetry(
      {int retryCount = 0, int lastProcessedCount = 0}) {
    return _PendingRetryState(
      retryCount: retryCount,
      lastProcessedCount: lastProcessedCount,
    );
  }

  _RetryingState retrying(
      {required int retryCount,
      required int lastProcessedCount,
      required Set<OfflineOperation> offlineOperations}) {
    return _RetryingState(
      retryCount: retryCount,
      lastProcessedCount: lastProcessedCount,
      offlineOperations: offlineOperations,
    );
  }

  _CancellingDisabledState cancellingDisabled() {
    return const _CancellingDisabledState();
  }

  _CancellingEnabledState cancellingEnabled() {
    return const _CancellingEnabledState();
  }

  _DisposingState disposing({required Completer<void> closeCompleter}) {
    return _DisposingState(
      closeCompleter: closeCompleter,
    );
  }

  _DisposedState disposed({required Completer<void> closeCompleter}) {
    return _DisposedState(
      closeCompleter: closeCompleter,
    );
  }
}

/// @nodoc
const $RetryState = _$RetryStateTearOff();

/// @nodoc
mixin _$RetryState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetryStateCopyWith<$Res> {
  factory $RetryStateCopyWith(
          RetryState value, $Res Function(RetryState) then) =
      _$RetryStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$RetryStateCopyWithImpl<$Res> implements $RetryStateCopyWith<$Res> {
  _$RetryStateCopyWithImpl(this._value, this._then);

  final RetryState _value;
  // ignore: unused_field
  final $Res Function(RetryState) _then;
}

/// @nodoc
abstract class _$IdleStateCopyWith<$Res> {
  factory _$IdleStateCopyWith(
          _IdleState value, $Res Function(_IdleState) then) =
      __$IdleStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$IdleStateCopyWithImpl<$Res> extends _$RetryStateCopyWithImpl<$Res>
    implements _$IdleStateCopyWith<$Res> {
  __$IdleStateCopyWithImpl(_IdleState _value, $Res Function(_IdleState) _then)
      : super(_value, (v) => _then(v as _IdleState));

  @override
  _IdleState get _value => super._value as _IdleState;
}

/// @nodoc

class _$_IdleState implements _IdleState {
  const _$_IdleState();

  @override
  String toString() {
    return 'RetryState.idle()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _IdleState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _IdleState implements RetryState {
  const factory _IdleState() = _$_IdleState;
}

/// @nodoc
abstract class _$DisabledStateCopyWith<$Res> {
  factory _$DisabledStateCopyWith(
          _DisabledState value, $Res Function(_DisabledState) then) =
      __$DisabledStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$DisabledStateCopyWithImpl<$Res> extends _$RetryStateCopyWithImpl<$Res>
    implements _$DisabledStateCopyWith<$Res> {
  __$DisabledStateCopyWithImpl(
      _DisabledState _value, $Res Function(_DisabledState) _then)
      : super(_value, (v) => _then(v as _DisabledState));

  @override
  _DisabledState get _value => super._value as _DisabledState;
}

/// @nodoc

class _$_DisabledState implements _DisabledState {
  const _$_DisabledState();

  @override
  String toString() {
    return 'RetryState.disabled()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _DisabledState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return disabled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return disabled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (disabled != null) {
      return disabled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return disabled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return disabled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (disabled != null) {
      return disabled(this);
    }
    return orElse();
  }
}

abstract class _DisabledState implements RetryState {
  const factory _DisabledState() = _$_DisabledState;
}

/// @nodoc
abstract class _$PendingRetryStateCopyWith<$Res> {
  factory _$PendingRetryStateCopyWith(
          _PendingRetryState value, $Res Function(_PendingRetryState) then) =
      __$PendingRetryStateCopyWithImpl<$Res>;
  $Res call({int retryCount, int lastProcessedCount});
}

/// @nodoc
class __$PendingRetryStateCopyWithImpl<$Res>
    extends _$RetryStateCopyWithImpl<$Res>
    implements _$PendingRetryStateCopyWith<$Res> {
  __$PendingRetryStateCopyWithImpl(
      _PendingRetryState _value, $Res Function(_PendingRetryState) _then)
      : super(_value, (v) => _then(v as _PendingRetryState));

  @override
  _PendingRetryState get _value => super._value as _PendingRetryState;

  @override
  $Res call({
    Object? retryCount = freezed,
    Object? lastProcessedCount = freezed,
  }) {
    return _then(_PendingRetryState(
      retryCount: retryCount == freezed
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastProcessedCount: lastProcessedCount == freezed
          ? _value.lastProcessedCount
          : lastProcessedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_PendingRetryState implements _PendingRetryState {
  const _$_PendingRetryState(
      {this.retryCount = 0, this.lastProcessedCount = 0});

  @JsonKey()
  @override
  final int retryCount;
  @JsonKey()
  @override
  final int lastProcessedCount;

  @override
  String toString() {
    return 'RetryState.pendingRetry(retryCount: $retryCount, lastProcessedCount: $lastProcessedCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PendingRetryState &&
            const DeepCollectionEquality()
                .equals(other.retryCount, retryCount) &&
            const DeepCollectionEquality()
                .equals(other.lastProcessedCount, lastProcessedCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(retryCount),
      const DeepCollectionEquality().hash(lastProcessedCount));

  @JsonKey(ignore: true)
  @override
  _$PendingRetryStateCopyWith<_PendingRetryState> get copyWith =>
      __$PendingRetryStateCopyWithImpl<_PendingRetryState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return pendingRetry(retryCount, lastProcessedCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return pendingRetry?.call(retryCount, lastProcessedCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (pendingRetry != null) {
      return pendingRetry(retryCount, lastProcessedCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return pendingRetry(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return pendingRetry?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (pendingRetry != null) {
      return pendingRetry(this);
    }
    return orElse();
  }
}

abstract class _PendingRetryState implements RetryState {
  const factory _PendingRetryState({int retryCount, int lastProcessedCount}) =
      _$_PendingRetryState;

  int get retryCount;
  int get lastProcessedCount;
  @JsonKey(ignore: true)
  _$PendingRetryStateCopyWith<_PendingRetryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$RetryingStateCopyWith<$Res> {
  factory _$RetryingStateCopyWith(
          _RetryingState value, $Res Function(_RetryingState) then) =
      __$RetryingStateCopyWithImpl<$Res>;
  $Res call(
      {int retryCount,
      int lastProcessedCount,
      Set<OfflineOperation> offlineOperations});
}

/// @nodoc
class __$RetryingStateCopyWithImpl<$Res> extends _$RetryStateCopyWithImpl<$Res>
    implements _$RetryingStateCopyWith<$Res> {
  __$RetryingStateCopyWithImpl(
      _RetryingState _value, $Res Function(_RetryingState) _then)
      : super(_value, (v) => _then(v as _RetryingState));

  @override
  _RetryingState get _value => super._value as _RetryingState;

  @override
  $Res call({
    Object? retryCount = freezed,
    Object? lastProcessedCount = freezed,
    Object? offlineOperations = freezed,
  }) {
    return _then(_RetryingState(
      retryCount: retryCount == freezed
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastProcessedCount: lastProcessedCount == freezed
          ? _value.lastProcessedCount
          : lastProcessedCount // ignore: cast_nullable_to_non_nullable
              as int,
      offlineOperations: offlineOperations == freezed
          ? _value.offlineOperations
          : offlineOperations // ignore: cast_nullable_to_non_nullable
              as Set<OfflineOperation>,
    ));
  }
}

/// @nodoc

class _$_RetryingState implements _RetryingState {
  const _$_RetryingState(
      {required this.retryCount,
      required this.lastProcessedCount,
      required this.offlineOperations});

  @override
  final int retryCount;
  @override
  final int lastProcessedCount;
  @override
  final Set<OfflineOperation> offlineOperations;

  @override
  String toString() {
    return 'RetryState.retrying(retryCount: $retryCount, lastProcessedCount: $lastProcessedCount, offlineOperations: $offlineOperations)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RetryingState &&
            const DeepCollectionEquality()
                .equals(other.retryCount, retryCount) &&
            const DeepCollectionEquality()
                .equals(other.lastProcessedCount, lastProcessedCount) &&
            const DeepCollectionEquality()
                .equals(other.offlineOperations, offlineOperations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(retryCount),
      const DeepCollectionEquality().hash(lastProcessedCount),
      const DeepCollectionEquality().hash(offlineOperations));

  @JsonKey(ignore: true)
  @override
  _$RetryingStateCopyWith<_RetryingState> get copyWith =>
      __$RetryingStateCopyWithImpl<_RetryingState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return retrying(retryCount, lastProcessedCount, offlineOperations);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return retrying?.call(retryCount, lastProcessedCount, offlineOperations);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (retrying != null) {
      return retrying(retryCount, lastProcessedCount, offlineOperations);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return retrying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return retrying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (retrying != null) {
      return retrying(this);
    }
    return orElse();
  }
}

abstract class _RetryingState implements RetryState {
  const factory _RetryingState(
      {required int retryCount,
      required int lastProcessedCount,
      required Set<OfflineOperation> offlineOperations}) = _$_RetryingState;

  int get retryCount;
  int get lastProcessedCount;
  Set<OfflineOperation> get offlineOperations;
  @JsonKey(ignore: true)
  _$RetryingStateCopyWith<_RetryingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$CancellingDisabledStateCopyWith<$Res> {
  factory _$CancellingDisabledStateCopyWith(_CancellingDisabledState value,
          $Res Function(_CancellingDisabledState) then) =
      __$CancellingDisabledStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$CancellingDisabledStateCopyWithImpl<$Res>
    extends _$RetryStateCopyWithImpl<$Res>
    implements _$CancellingDisabledStateCopyWith<$Res> {
  __$CancellingDisabledStateCopyWithImpl(_CancellingDisabledState _value,
      $Res Function(_CancellingDisabledState) _then)
      : super(_value, (v) => _then(v as _CancellingDisabledState));

  @override
  _CancellingDisabledState get _value =>
      super._value as _CancellingDisabledState;
}

/// @nodoc

class _$_CancellingDisabledState implements _CancellingDisabledState {
  const _$_CancellingDisabledState();

  @override
  String toString() {
    return 'RetryState.cancellingDisabled()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _CancellingDisabledState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return cancellingDisabled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return cancellingDisabled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (cancellingDisabled != null) {
      return cancellingDisabled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return cancellingDisabled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return cancellingDisabled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (cancellingDisabled != null) {
      return cancellingDisabled(this);
    }
    return orElse();
  }
}

abstract class _CancellingDisabledState implements RetryState {
  const factory _CancellingDisabledState() = _$_CancellingDisabledState;
}

/// @nodoc
abstract class _$CancellingEnabledStateCopyWith<$Res> {
  factory _$CancellingEnabledStateCopyWith(_CancellingEnabledState value,
          $Res Function(_CancellingEnabledState) then) =
      __$CancellingEnabledStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$CancellingEnabledStateCopyWithImpl<$Res>
    extends _$RetryStateCopyWithImpl<$Res>
    implements _$CancellingEnabledStateCopyWith<$Res> {
  __$CancellingEnabledStateCopyWithImpl(_CancellingEnabledState _value,
      $Res Function(_CancellingEnabledState) _then)
      : super(_value, (v) => _then(v as _CancellingEnabledState));

  @override
  _CancellingEnabledState get _value => super._value as _CancellingEnabledState;
}

/// @nodoc

class _$_CancellingEnabledState implements _CancellingEnabledState {
  const _$_CancellingEnabledState();

  @override
  String toString() {
    return 'RetryState.cancellingEnabled()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _CancellingEnabledState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return cancellingEnabled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return cancellingEnabled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (cancellingEnabled != null) {
      return cancellingEnabled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return cancellingEnabled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return cancellingEnabled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (cancellingEnabled != null) {
      return cancellingEnabled(this);
    }
    return orElse();
  }
}

abstract class _CancellingEnabledState implements RetryState {
  const factory _CancellingEnabledState() = _$_CancellingEnabledState;
}

/// @nodoc
abstract class _$DisposingStateCopyWith<$Res> {
  factory _$DisposingStateCopyWith(
          _DisposingState value, $Res Function(_DisposingState) then) =
      __$DisposingStateCopyWithImpl<$Res>;
  $Res call({Completer<void> closeCompleter});
}

/// @nodoc
class __$DisposingStateCopyWithImpl<$Res> extends _$RetryStateCopyWithImpl<$Res>
    implements _$DisposingStateCopyWith<$Res> {
  __$DisposingStateCopyWithImpl(
      _DisposingState _value, $Res Function(_DisposingState) _then)
      : super(_value, (v) => _then(v as _DisposingState));

  @override
  _DisposingState get _value => super._value as _DisposingState;

  @override
  $Res call({
    Object? closeCompleter = freezed,
  }) {
    return _then(_DisposingState(
      closeCompleter: closeCompleter == freezed
          ? _value.closeCompleter
          : closeCompleter // ignore: cast_nullable_to_non_nullable
              as Completer<void>,
    ));
  }
}

/// @nodoc

class _$_DisposingState implements _DisposingState {
  const _$_DisposingState({required this.closeCompleter});

  @override
  final Completer<void> closeCompleter;

  @override
  String toString() {
    return 'RetryState.disposing(closeCompleter: $closeCompleter)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DisposingState &&
            const DeepCollectionEquality()
                .equals(other.closeCompleter, closeCompleter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(closeCompleter));

  @JsonKey(ignore: true)
  @override
  _$DisposingStateCopyWith<_DisposingState> get copyWith =>
      __$DisposingStateCopyWithImpl<_DisposingState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return disposing(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return disposing?.call(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (disposing != null) {
      return disposing(closeCompleter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return disposing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return disposing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (disposing != null) {
      return disposing(this);
    }
    return orElse();
  }
}

abstract class _DisposingState implements RetryState {
  const factory _DisposingState({required Completer<void> closeCompleter}) =
      _$_DisposingState;

  Completer<void> get closeCompleter;
  @JsonKey(ignore: true)
  _$DisposingStateCopyWith<_DisposingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$DisposedStateCopyWith<$Res> {
  factory _$DisposedStateCopyWith(
          _DisposedState value, $Res Function(_DisposedState) then) =
      __$DisposedStateCopyWithImpl<$Res>;
  $Res call({Completer<void> closeCompleter});
}

/// @nodoc
class __$DisposedStateCopyWithImpl<$Res> extends _$RetryStateCopyWithImpl<$Res>
    implements _$DisposedStateCopyWith<$Res> {
  __$DisposedStateCopyWithImpl(
      _DisposedState _value, $Res Function(_DisposedState) _then)
      : super(_value, (v) => _then(v as _DisposedState));

  @override
  _DisposedState get _value => super._value as _DisposedState;

  @override
  $Res call({
    Object? closeCompleter = freezed,
  }) {
    return _then(_DisposedState(
      closeCompleter: closeCompleter == freezed
          ? _value.closeCompleter
          : closeCompleter // ignore: cast_nullable_to_non_nullable
              as Completer<void>,
    ));
  }
}

/// @nodoc

class _$_DisposedState implements _DisposedState {
  const _$_DisposedState({required this.closeCompleter});

  @override
  final Completer<void> closeCompleter;

  @override
  String toString() {
    return 'RetryState.disposed(closeCompleter: $closeCompleter)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DisposedState &&
            const DeepCollectionEquality()
                .equals(other.closeCompleter, closeCompleter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(closeCompleter));

  @JsonKey(ignore: true)
  @override
  _$DisposedStateCopyWith<_DisposedState> get copyWith =>
      __$DisposedStateCopyWithImpl<_DisposedState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() disabled,
    required TResult Function(int retryCount, int lastProcessedCount)
        pendingRetry,
    required TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)
        retrying,
    required TResult Function() cancellingDisabled,
    required TResult Function() cancellingEnabled,
    required TResult Function(Completer<void> closeCompleter) disposing,
    required TResult Function(Completer<void> closeCompleter) disposed,
  }) {
    return disposed(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
  }) {
    return disposed?.call(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? disabled,
    TResult Function(int retryCount, int lastProcessedCount)? pendingRetry,
    TResult Function(int retryCount, int lastProcessedCount,
            Set<OfflineOperation> offlineOperations)?
        retrying,
    TResult Function()? cancellingDisabled,
    TResult Function()? cancellingEnabled,
    TResult Function(Completer<void> closeCompleter)? disposing,
    TResult Function(Completer<void> closeCompleter)? disposed,
    required TResult orElse(),
  }) {
    if (disposed != null) {
      return disposed(closeCompleter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IdleState value) idle,
    required TResult Function(_DisabledState value) disabled,
    required TResult Function(_PendingRetryState value) pendingRetry,
    required TResult Function(_RetryingState value) retrying,
    required TResult Function(_CancellingDisabledState value)
        cancellingDisabled,
    required TResult Function(_CancellingEnabledState value) cancellingEnabled,
    required TResult Function(_DisposingState value) disposing,
    required TResult Function(_DisposedState value) disposed,
  }) {
    return disposed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
  }) {
    return disposed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IdleState value)? idle,
    TResult Function(_DisabledState value)? disabled,
    TResult Function(_PendingRetryState value)? pendingRetry,
    TResult Function(_RetryingState value)? retrying,
    TResult Function(_CancellingDisabledState value)? cancellingDisabled,
    TResult Function(_CancellingEnabledState value)? cancellingEnabled,
    TResult Function(_DisposingState value)? disposing,
    TResult Function(_DisposedState value)? disposed,
    required TResult orElse(),
  }) {
    if (disposed != null) {
      return disposed(this);
    }
    return orElse();
  }
}

abstract class _DisposedState implements RetryState {
  const factory _DisposedState({required Completer<void> closeCompleter}) =
      _$_DisposedState;

  Completer<void> get closeCompleter;
  @JsonKey(ignore: true)
  _$DisposedStateCopyWith<_DisposedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
class _$RetryEventTearOff {
  const _$RetryEventTearOff();

  _EnableEvent enable() {
    return const _EnableEvent();
  }

  _DisableEvent disable() {
    return const _DisableEvent();
  }

  _RetryOperationsEvent retryOperations() {
    return const _RetryOperationsEvent();
  }

  _ProcessEvent process() {
    return const _ProcessEvent();
  }

  _ProcessingDoneEvent processingDone(int processedCount) {
    return _ProcessingDoneEvent(
      processedCount,
    );
  }

  _DisposeEvent dispose(Completer<void> closeCompleter) {
    return _DisposeEvent(
      closeCompleter,
    );
  }
}

/// @nodoc
const $RetryEvent = _$RetryEventTearOff();

/// @nodoc
mixin _$RetryEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetryEventCopyWith<$Res> {
  factory $RetryEventCopyWith(
          RetryEvent value, $Res Function(RetryEvent) then) =
      _$RetryEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$RetryEventCopyWithImpl<$Res> implements $RetryEventCopyWith<$Res> {
  _$RetryEventCopyWithImpl(this._value, this._then);

  final RetryEvent _value;
  // ignore: unused_field
  final $Res Function(RetryEvent) _then;
}

/// @nodoc
abstract class _$EnableEventCopyWith<$Res> {
  factory _$EnableEventCopyWith(
          _EnableEvent value, $Res Function(_EnableEvent) then) =
      __$EnableEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$EnableEventCopyWithImpl<$Res> extends _$RetryEventCopyWithImpl<$Res>
    implements _$EnableEventCopyWith<$Res> {
  __$EnableEventCopyWithImpl(
      _EnableEvent _value, $Res Function(_EnableEvent) _then)
      : super(_value, (v) => _then(v as _EnableEvent));

  @override
  _EnableEvent get _value => super._value as _EnableEvent;
}

/// @nodoc

class _$_EnableEvent implements _EnableEvent {
  const _$_EnableEvent();

  @override
  String toString() {
    return 'RetryEvent.enable()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _EnableEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return enable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return enable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (enable != null) {
      return enable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return enable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return enable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (enable != null) {
      return enable(this);
    }
    return orElse();
  }
}

abstract class _EnableEvent implements RetryEvent {
  const factory _EnableEvent() = _$_EnableEvent;
}

/// @nodoc
abstract class _$DisableEventCopyWith<$Res> {
  factory _$DisableEventCopyWith(
          _DisableEvent value, $Res Function(_DisableEvent) then) =
      __$DisableEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$DisableEventCopyWithImpl<$Res> extends _$RetryEventCopyWithImpl<$Res>
    implements _$DisableEventCopyWith<$Res> {
  __$DisableEventCopyWithImpl(
      _DisableEvent _value, $Res Function(_DisableEvent) _then)
      : super(_value, (v) => _then(v as _DisableEvent));

  @override
  _DisableEvent get _value => super._value as _DisableEvent;
}

/// @nodoc

class _$_DisableEvent implements _DisableEvent {
  const _$_DisableEvent();

  @override
  String toString() {
    return 'RetryEvent.disable()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _DisableEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return disable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return disable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (disable != null) {
      return disable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return disable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return disable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (disable != null) {
      return disable(this);
    }
    return orElse();
  }
}

abstract class _DisableEvent implements RetryEvent {
  const factory _DisableEvent() = _$_DisableEvent;
}

/// @nodoc
abstract class _$RetryOperationsEventCopyWith<$Res> {
  factory _$RetryOperationsEventCopyWith(_RetryOperationsEvent value,
          $Res Function(_RetryOperationsEvent) then) =
      __$RetryOperationsEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$RetryOperationsEventCopyWithImpl<$Res>
    extends _$RetryEventCopyWithImpl<$Res>
    implements _$RetryOperationsEventCopyWith<$Res> {
  __$RetryOperationsEventCopyWithImpl(
      _RetryOperationsEvent _value, $Res Function(_RetryOperationsEvent) _then)
      : super(_value, (v) => _then(v as _RetryOperationsEvent));

  @override
  _RetryOperationsEvent get _value => super._value as _RetryOperationsEvent;
}

/// @nodoc

class _$_RetryOperationsEvent implements _RetryOperationsEvent {
  const _$_RetryOperationsEvent();

  @override
  String toString() {
    return 'RetryEvent.retryOperations()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _RetryOperationsEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return retryOperations();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return retryOperations?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (retryOperations != null) {
      return retryOperations();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return retryOperations(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return retryOperations?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (retryOperations != null) {
      return retryOperations(this);
    }
    return orElse();
  }
}

abstract class _RetryOperationsEvent implements RetryEvent {
  const factory _RetryOperationsEvent() = _$_RetryOperationsEvent;
}

/// @nodoc
abstract class _$ProcessEventCopyWith<$Res> {
  factory _$ProcessEventCopyWith(
          _ProcessEvent value, $Res Function(_ProcessEvent) then) =
      __$ProcessEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$ProcessEventCopyWithImpl<$Res> extends _$RetryEventCopyWithImpl<$Res>
    implements _$ProcessEventCopyWith<$Res> {
  __$ProcessEventCopyWithImpl(
      _ProcessEvent _value, $Res Function(_ProcessEvent) _then)
      : super(_value, (v) => _then(v as _ProcessEvent));

  @override
  _ProcessEvent get _value => super._value as _ProcessEvent;
}

/// @nodoc

class _$_ProcessEvent implements _ProcessEvent {
  const _$_ProcessEvent();

  @override
  String toString() {
    return 'RetryEvent.process()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _ProcessEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return process();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return process?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (process != null) {
      return process();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return process(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return process?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (process != null) {
      return process(this);
    }
    return orElse();
  }
}

abstract class _ProcessEvent implements RetryEvent {
  const factory _ProcessEvent() = _$_ProcessEvent;
}

/// @nodoc
abstract class _$ProcessingDoneEventCopyWith<$Res> {
  factory _$ProcessingDoneEventCopyWith(_ProcessingDoneEvent value,
          $Res Function(_ProcessingDoneEvent) then) =
      __$ProcessingDoneEventCopyWithImpl<$Res>;
  $Res call({int processedCount});
}

/// @nodoc
class __$ProcessingDoneEventCopyWithImpl<$Res>
    extends _$RetryEventCopyWithImpl<$Res>
    implements _$ProcessingDoneEventCopyWith<$Res> {
  __$ProcessingDoneEventCopyWithImpl(
      _ProcessingDoneEvent _value, $Res Function(_ProcessingDoneEvent) _then)
      : super(_value, (v) => _then(v as _ProcessingDoneEvent));

  @override
  _ProcessingDoneEvent get _value => super._value as _ProcessingDoneEvent;

  @override
  $Res call({
    Object? processedCount = freezed,
  }) {
    return _then(_ProcessingDoneEvent(
      processedCount == freezed
          ? _value.processedCount
          : processedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_ProcessingDoneEvent implements _ProcessingDoneEvent {
  const _$_ProcessingDoneEvent(this.processedCount);

  @override
  final int processedCount;

  @override
  String toString() {
    return 'RetryEvent.processingDone(processedCount: $processedCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProcessingDoneEvent &&
            const DeepCollectionEquality()
                .equals(other.processedCount, processedCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(processedCount));

  @JsonKey(ignore: true)
  @override
  _$ProcessingDoneEventCopyWith<_ProcessingDoneEvent> get copyWith =>
      __$ProcessingDoneEventCopyWithImpl<_ProcessingDoneEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return processingDone(processedCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return processingDone?.call(processedCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (processingDone != null) {
      return processingDone(processedCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return processingDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return processingDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (processingDone != null) {
      return processingDone(this);
    }
    return orElse();
  }
}

abstract class _ProcessingDoneEvent implements RetryEvent {
  const factory _ProcessingDoneEvent(int processedCount) =
      _$_ProcessingDoneEvent;

  int get processedCount;
  @JsonKey(ignore: true)
  _$ProcessingDoneEventCopyWith<_ProcessingDoneEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$DisposeEventCopyWith<$Res> {
  factory _$DisposeEventCopyWith(
          _DisposeEvent value, $Res Function(_DisposeEvent) then) =
      __$DisposeEventCopyWithImpl<$Res>;
  $Res call({Completer<void> closeCompleter});
}

/// @nodoc
class __$DisposeEventCopyWithImpl<$Res> extends _$RetryEventCopyWithImpl<$Res>
    implements _$DisposeEventCopyWith<$Res> {
  __$DisposeEventCopyWithImpl(
      _DisposeEvent _value, $Res Function(_DisposeEvent) _then)
      : super(_value, (v) => _then(v as _DisposeEvent));

  @override
  _DisposeEvent get _value => super._value as _DisposeEvent;

  @override
  $Res call({
    Object? closeCompleter = freezed,
  }) {
    return _then(_DisposeEvent(
      closeCompleter == freezed
          ? _value.closeCompleter
          : closeCompleter // ignore: cast_nullable_to_non_nullable
              as Completer<void>,
    ));
  }
}

/// @nodoc

class _$_DisposeEvent implements _DisposeEvent {
  const _$_DisposeEvent(this.closeCompleter);

  @override
  final Completer<void> closeCompleter;

  @override
  String toString() {
    return 'RetryEvent.dispose(closeCompleter: $closeCompleter)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DisposeEvent &&
            const DeepCollectionEquality()
                .equals(other.closeCompleter, closeCompleter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(closeCompleter));

  @JsonKey(ignore: true)
  @override
  _$DisposeEventCopyWith<_DisposeEvent> get copyWith =>
      __$DisposeEventCopyWithImpl<_DisposeEvent>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() enable,
    required TResult Function() disable,
    required TResult Function() retryOperations,
    required TResult Function() process,
    required TResult Function(int processedCount) processingDone,
    required TResult Function(Completer<void> closeCompleter) dispose,
  }) {
    return dispose(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
  }) {
    return dispose?.call(closeCompleter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? enable,
    TResult Function()? disable,
    TResult Function()? retryOperations,
    TResult Function()? process,
    TResult Function(int processedCount)? processingDone,
    TResult Function(Completer<void> closeCompleter)? dispose,
    required TResult orElse(),
  }) {
    if (dispose != null) {
      return dispose(closeCompleter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EnableEvent value) enable,
    required TResult Function(_DisableEvent value) disable,
    required TResult Function(_RetryOperationsEvent value) retryOperations,
    required TResult Function(_ProcessEvent value) process,
    required TResult Function(_ProcessingDoneEvent value) processingDone,
    required TResult Function(_DisposeEvent value) dispose,
  }) {
    return dispose(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
  }) {
    return dispose?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EnableEvent value)? enable,
    TResult Function(_DisableEvent value)? disable,
    TResult Function(_RetryOperationsEvent value)? retryOperations,
    TResult Function(_ProcessEvent value)? process,
    TResult Function(_ProcessingDoneEvent value)? processingDone,
    TResult Function(_DisposeEvent value)? dispose,
    required TResult orElse(),
  }) {
    if (dispose != null) {
      return dispose(this);
    }
    return orElse();
  }
}

abstract class _DisposeEvent implements RetryEvent {
  const factory _DisposeEvent(Completer<void> closeCompleter) = _$_DisposeEvent;

  Completer<void> get closeCompleter;
  @JsonKey(ignore: true)
  _$DisposeEventCopyWith<_DisposeEvent> get copyWith =>
      throw _privateConstructorUsedError;
}
