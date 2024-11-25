// Mocks generated by Mockito 5.4.4 from annotations
// in inventory_app_revised/test/unit/repositories/product_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i7;

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as _i3;
import 'package:firebase_core/firebase_core.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFirebaseApp_0 extends _i1.SmartFake implements _i2.FirebaseApp {
  _FakeFirebaseApp_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSettings_1 extends _i1.SmartFake implements _i3.Settings {
  _FakeSettings_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCollectionReference_2<T extends Object?> extends _i1.SmartFake
    implements _i4.CollectionReference<T> {
  _FakeCollectionReference_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWriteBatch_3 extends _i1.SmartFake implements _i4.WriteBatch {
  _FakeWriteBatch_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLoadBundleTask_4 extends _i1.SmartFake
    implements _i4.LoadBundleTask {
  _FakeLoadBundleTask_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuerySnapshot_5<T1 extends Object?> extends _i1.SmartFake
    implements _i4.QuerySnapshot<T1> {
  _FakeQuerySnapshot_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuery_6<T extends Object?> extends _i1.SmartFake
    implements _i4.Query<T> {
  _FakeQuery_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDocumentReference_7<T extends Object?> extends _i1.SmartFake
    implements _i4.DocumentReference<T> {
  _FakeDocumentReference_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_8<T1> extends _i1.SmartFake implements _i5.Future<T1> {
  _FakeFuture_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseFirestore_9 extends _i1.SmartFake
    implements _i4.FirebaseFirestore {
  _FakeFirebaseFirestore_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAggregateQuery_10 extends _i1.SmartFake
    implements _i4.AggregateQuery {
  _FakeAggregateQuery_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDocumentSnapshot_11<T extends Object?> extends _i1.SmartFake
    implements _i4.DocumentSnapshot<T> {
  _FakeDocumentSnapshot_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSnapshotMetadata_12 extends _i1.SmartFake
    implements _i4.SnapshotMetadata {
  _FakeSnapshotMetadata_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FirebaseFirestore].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirestore extends _i1.Mock implements _i4.FirebaseFirestore {
  MockFirestore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_0(
          this,
          Invocation.getter(#app),
        ),
      ) as _i2.FirebaseApp);

  @override
  set app(_i2.FirebaseApp? _app) => super.noSuchMethod(
        Invocation.setter(
          #app,
          _app,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseURL => (super.noSuchMethod(
        Invocation.getter(#databaseURL),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#databaseURL),
        ),
      ) as String);

  @override
  set databaseURL(String? _databaseURL) => super.noSuchMethod(
        Invocation.setter(
          #databaseURL,
          _databaseURL,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseId => (super.noSuchMethod(
        Invocation.getter(#databaseId),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#databaseId),
        ),
      ) as String);

  @override
  set databaseId(String? _databaseId) => super.noSuchMethod(
        Invocation.setter(
          #databaseId,
          _databaseId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set settings(_i3.Settings? settings) => super.noSuchMethod(
        Invocation.setter(
          #settings,
          settings,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Settings get settings => (super.noSuchMethod(
        Invocation.getter(#settings),
        returnValue: _FakeSettings_1(
          this,
          Invocation.getter(#settings),
        ),
      ) as _i3.Settings);

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  _i4.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collection,
          [collectionPath],
        ),
        returnValue: _FakeCollectionReference_2<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collection,
            [collectionPath],
          ),
        ),
      ) as _i4.CollectionReference<Map<String, dynamic>>);

  @override
  _i4.WriteBatch batch() => (super.noSuchMethod(
        Invocation.method(
          #batch,
          [],
        ),
        returnValue: _FakeWriteBatch_3(
          this,
          Invocation.method(
            #batch,
            [],
          ),
        ),
      ) as _i4.WriteBatch);

  @override
  _i5.Future<void> clearPersistence() => (super.noSuchMethod(
        Invocation.method(
          #clearPersistence,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> enablePersistence(
          [_i3.PersistenceSettings? persistenceSettings]) =>
      (super.noSuchMethod(
        Invocation.method(
          #enablePersistence,
          [persistenceSettings],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.LoadBundleTask loadBundle(_i7.Uint8List? bundle) => (super.noSuchMethod(
        Invocation.method(
          #loadBundle,
          [bundle],
        ),
        returnValue: _FakeLoadBundleTask_4(
          this,
          Invocation.method(
            #loadBundle,
            [bundle],
          ),
        ),
      ) as _i4.LoadBundleTask);

  @override
  void useFirestoreEmulator(
    String? host,
    int? port, {
    bool? sslEnabled = false,
    bool? automaticHostMapping = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #useFirestoreEmulator,
          [
            host,
            port,
          ],
          {
            #sslEnabled: sslEnabled,
            #automaticHostMapping: automaticHostMapping,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i4.QuerySnapshot<T>> namedQueryWithConverterGet<T>(
    String? name, {
    _i3.GetOptions? options = const _i3.GetOptions(),
    required _i4.FromFirestore<T>? fromFirestore,
    required _i4.ToFirestore<T>? toFirestore,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryWithConverterGet,
          [name],
          {
            #options: options,
            #fromFirestore: fromFirestore,
            #toFirestore: toFirestore,
          },
        ),
        returnValue:
            _i5.Future<_i4.QuerySnapshot<T>>.value(_FakeQuerySnapshot_5<T>(
          this,
          Invocation.method(
            #namedQueryWithConverterGet,
            [name],
            {
              #options: options,
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        )),
      ) as _i5.Future<_i4.QuerySnapshot<T>>);

  @override
  _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
    String? name, {
    _i3.GetOptions? options = const _i3.GetOptions(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryGet,
          [name],
          {#options: options},
        ),
        returnValue: _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>.value(
            _FakeQuerySnapshot_5<Map<String, dynamic>>(
          this,
          Invocation.method(
            #namedQueryGet,
            [name],
            {#options: options},
          ),
        )),
      ) as _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i4.Query<Map<String, dynamic>> collectionGroup(String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collectionGroup,
          [collectionPath],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collectionGroup,
            [collectionPath],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i5.Future<void> disableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #disableNetwork,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.DocumentReference<Map<String, dynamic>> doc(String? documentPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #doc,
          [documentPath],
        ),
        returnValue: _FakeDocumentReference_7<Map<String, dynamic>>(
          this,
          Invocation.method(
            #doc,
            [documentPath],
          ),
        ),
      ) as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i5.Future<void> enableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #enableNetwork,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Stream<void> snapshotsInSync() => (super.noSuchMethod(
        Invocation.method(
          #snapshotsInSync,
          [],
        ),
        returnValue: _i5.Stream<void>.empty(),
      ) as _i5.Stream<void>);

  @override
  _i5.Future<T> runTransaction<T>(
    _i4.TransactionHandler<T>? transactionHandler, {
    Duration? timeout = const Duration(seconds: 30),
    int? maxAttempts = 5,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runTransaction,
          [transactionHandler],
          {
            #timeout: timeout,
            #maxAttempts: maxAttempts,
          },
        ),
        returnValue: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runTransaction,
                  [transactionHandler],
                  {
                    #timeout: timeout,
                    #maxAttempts: maxAttempts,
                  },
                ),
              ),
              (T v) => _i5.Future<T>.value(v),
            ) ??
            _FakeFuture_8<T>(
              this,
              Invocation.method(
                #runTransaction,
                [transactionHandler],
                {
                  #timeout: timeout,
                  #maxAttempts: maxAttempts,
                },
              ),
            ),
      ) as _i5.Future<T>);

  @override
  _i5.Future<void> terminate() => (super.noSuchMethod(
        Invocation.method(
          #terminate,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> waitForPendingWrites() => (super.noSuchMethod(
        Invocation.method(
          #waitForPendingWrites,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfiguration({
    required List<_i3.Index>? indexes,
    List<_i3.FieldOverrides>? fieldOverrides,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfiguration,
          [],
          {
            #indexes: indexes,
            #fieldOverrides: fieldOverrides,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfigurationFromJSON(String? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfigurationFromJSON,
          [json],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [CollectionReference].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockProductCollection extends _i1.Mock
    implements _i4.CollectionReference<Map<String, dynamic>> {
  MockProductCollection() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#path),
        ),
      ) as String);

  @override
  _i4.FirebaseFirestore get firestore => (super.noSuchMethod(
        Invocation.getter(#firestore),
        returnValue: _FakeFirebaseFirestore_9(
          this,
          Invocation.getter(#firestore),
        ),
      ) as _i4.FirebaseFirestore);

  @override
  Map<String, dynamic> get parameters => (super.noSuchMethod(
        Invocation.getter(#parameters),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  _i5.Future<_i4.DocumentReference<Map<String, dynamic>>> add(
          Map<String, dynamic>? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #add,
          [data],
        ),
        returnValue:
            _i5.Future<_i4.DocumentReference<Map<String, dynamic>>>.value(
                _FakeDocumentReference_7<Map<String, dynamic>>(
          this,
          Invocation.method(
            #add,
            [data],
          ),
        )),
      ) as _i5.Future<_i4.DocumentReference<Map<String, dynamic>>>);

  @override
  _i4.DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      (super.noSuchMethod(
        Invocation.method(
          #doc,
          [path],
        ),
        returnValue: _FakeDocumentReference_7<Map<String, dynamic>>(
          this,
          Invocation.method(
            #doc,
            [path],
          ),
        ),
      ) as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i4.CollectionReference<R> withConverter<R extends Object?>({
    required _i4.FromFirestore<R>? fromFirestore,
    required _i4.ToFirestore<R>? toFirestore,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #withConverter,
          [],
          {
            #fromFirestore: fromFirestore,
            #toFirestore: toFirestore,
          },
        ),
        returnValue: _FakeCollectionReference_2<R>(
          this,
          Invocation.method(
            #withConverter,
            [],
            {
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        ),
      ) as _i4.CollectionReference<R>);

  @override
  _i4.Query<Map<String, dynamic>> endAtDocument(
          _i4.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
        Invocation.method(
          #endAtDocument,
          [documentSnapshot],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #endAtDocument,
            [documentSnapshot],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> endAt(Iterable<Object?>? values) =>
      (super.noSuchMethod(
        Invocation.method(
          #endAt,
          [values],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #endAt,
            [values],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> endBeforeDocument(
          _i4.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
        Invocation.method(
          #endBeforeDocument,
          [documentSnapshot],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #endBeforeDocument,
            [documentSnapshot],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> endBefore(Iterable<Object?>? values) =>
      (super.noSuchMethod(
        Invocation.method(
          #endBefore,
          [values],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #endBefore,
            [values],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>> get(
          [_i3.GetOptions? options]) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [options],
        ),
        returnValue: _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>.value(
            _FakeQuerySnapshot_5<Map<String, dynamic>>(
          this,
          Invocation.method(
            #get,
            [options],
          ),
        )),
      ) as _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i4.Query<Map<String, dynamic>> limit(int? limit) => (super.noSuchMethod(
        Invocation.method(
          #limit,
          [limit],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #limit,
            [limit],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> limitToLast(int? limit) =>
      (super.noSuchMethod(
        Invocation.method(
          #limitToLast,
          [limit],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #limitToLast,
            [limit],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i5.Stream<_i4.QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool? includeMetadataChanges = false,
    _i3.ListenSource? source = _i3.ListenSource.defaultSource,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #snapshots,
          [],
          {
            #includeMetadataChanges: includeMetadataChanges,
            #source: source,
          },
        ),
        returnValue:
            _i5.Stream<_i4.QuerySnapshot<Map<String, dynamic>>>.empty(),
      ) as _i5.Stream<_i4.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i4.Query<Map<String, dynamic>> orderBy(
    Object? field, {
    bool? descending = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #orderBy,
          [field],
          {#descending: descending},
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #orderBy,
            [field],
            {#descending: descending},
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> startAfterDocument(
          _i4.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
        Invocation.method(
          #startAfterDocument,
          [documentSnapshot],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #startAfterDocument,
            [documentSnapshot],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> startAfter(Iterable<Object?>? values) =>
      (super.noSuchMethod(
        Invocation.method(
          #startAfter,
          [values],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #startAfter,
            [values],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> startAtDocument(
          _i4.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
        Invocation.method(
          #startAtDocument,
          [documentSnapshot],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #startAtDocument,
            [documentSnapshot],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> startAt(Iterable<Object?>? values) =>
      (super.noSuchMethod(
        Invocation.method(
          #startAt,
          [values],
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #startAt,
            [values],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.Query<Map<String, dynamic>> where(
    Object? field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #where,
          [field],
          {
            #isEqualTo: isEqualTo,
            #isNotEqualTo: isNotEqualTo,
            #isLessThan: isLessThan,
            #isLessThanOrEqualTo: isLessThanOrEqualTo,
            #isGreaterThan: isGreaterThan,
            #isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            #arrayContains: arrayContains,
            #arrayContainsAny: arrayContainsAny,
            #whereIn: whereIn,
            #whereNotIn: whereNotIn,
            #isNull: isNull,
          },
        ),
        returnValue: _FakeQuery_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #where,
            [field],
            {
              #isEqualTo: isEqualTo,
              #isNotEqualTo: isNotEqualTo,
              #isLessThan: isLessThan,
              #isLessThanOrEqualTo: isLessThanOrEqualTo,
              #isGreaterThan: isGreaterThan,
              #isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
              #arrayContains: arrayContains,
              #arrayContainsAny: arrayContainsAny,
              #whereIn: whereIn,
              #whereNotIn: whereNotIn,
              #isNull: isNull,
            },
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i4.AggregateQuery count() => (super.noSuchMethod(
        Invocation.method(
          #count,
          [],
        ),
        returnValue: _FakeAggregateQuery_10(
          this,
          Invocation.method(
            #count,
            [],
          ),
        ),
      ) as _i4.AggregateQuery);

  @override
  _i4.AggregateQuery aggregate(
    _i3.AggregateField? aggregateField1, [
    _i3.AggregateField? aggregateField2,
    _i3.AggregateField? aggregateField3,
    _i3.AggregateField? aggregateField4,
    _i3.AggregateField? aggregateField5,
    _i3.AggregateField? aggregateField6,
    _i3.AggregateField? aggregateField7,
    _i3.AggregateField? aggregateField8,
    _i3.AggregateField? aggregateField9,
    _i3.AggregateField? aggregateField10,
    _i3.AggregateField? aggregateField11,
    _i3.AggregateField? aggregateField12,
    _i3.AggregateField? aggregateField13,
    _i3.AggregateField? aggregateField14,
    _i3.AggregateField? aggregateField15,
    _i3.AggregateField? aggregateField16,
    _i3.AggregateField? aggregateField17,
    _i3.AggregateField? aggregateField18,
    _i3.AggregateField? aggregateField19,
    _i3.AggregateField? aggregateField20,
    _i3.AggregateField? aggregateField21,
    _i3.AggregateField? aggregateField22,
    _i3.AggregateField? aggregateField23,
    _i3.AggregateField? aggregateField24,
    _i3.AggregateField? aggregateField25,
    _i3.AggregateField? aggregateField26,
    _i3.AggregateField? aggregateField27,
    _i3.AggregateField? aggregateField28,
    _i3.AggregateField? aggregateField29,
    _i3.AggregateField? aggregateField30,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #aggregate,
          [
            aggregateField1,
            aggregateField2,
            aggregateField3,
            aggregateField4,
            aggregateField5,
            aggregateField6,
            aggregateField7,
            aggregateField8,
            aggregateField9,
            aggregateField10,
            aggregateField11,
            aggregateField12,
            aggregateField13,
            aggregateField14,
            aggregateField15,
            aggregateField16,
            aggregateField17,
            aggregateField18,
            aggregateField19,
            aggregateField20,
            aggregateField21,
            aggregateField22,
            aggregateField23,
            aggregateField24,
            aggregateField25,
            aggregateField26,
            aggregateField27,
            aggregateField28,
            aggregateField29,
            aggregateField30,
          ],
        ),
        returnValue: _FakeAggregateQuery_10(
          this,
          Invocation.method(
            #aggregate,
            [
              aggregateField1,
              aggregateField2,
              aggregateField3,
              aggregateField4,
              aggregateField5,
              aggregateField6,
              aggregateField7,
              aggregateField8,
              aggregateField9,
              aggregateField10,
              aggregateField11,
              aggregateField12,
              aggregateField13,
              aggregateField14,
              aggregateField15,
              aggregateField16,
              aggregateField17,
              aggregateField18,
              aggregateField19,
              aggregateField20,
              aggregateField21,
              aggregateField22,
              aggregateField23,
              aggregateField24,
              aggregateField25,
              aggregateField26,
              aggregateField27,
              aggregateField28,
              aggregateField29,
              aggregateField30,
            ],
          ),
        ),
      ) as _i4.AggregateQuery);
}

/// A class which mocks [DocumentReference].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockProductDocument extends _i1.Mock
    implements _i4.DocumentReference<Map<String, dynamic>> {
  MockProductDocument() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.FirebaseFirestore get firestore => (super.noSuchMethod(
        Invocation.getter(#firestore),
        returnValue: _FakeFirebaseFirestore_9(
          this,
          Invocation.getter(#firestore),
        ),
      ) as _i4.FirebaseFirestore);

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  _i4.CollectionReference<Map<String, dynamic>> get parent =>
      (super.noSuchMethod(
        Invocation.getter(#parent),
        returnValue: _FakeCollectionReference_2<Map<String, dynamic>>(
          this,
          Invocation.getter(#parent),
        ),
      ) as _i4.CollectionReference<Map<String, dynamic>>);

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#path),
        ),
      ) as String);

  @override
  _i4.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collection,
          [collectionPath],
        ),
        returnValue: _FakeCollectionReference_2<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collection,
            [collectionPath],
          ),
        ),
      ) as _i4.CollectionReference<Map<String, dynamic>>);

  @override
  _i5.Future<void> delete() => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> update(Map<Object, Object?>? data) => (super.noSuchMethod(
        Invocation.method(
          #update,
          [data],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<_i4.DocumentSnapshot<Map<String, dynamic>>> get(
          [_i3.GetOptions? options]) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [options],
        ),
        returnValue:
            _i5.Future<_i4.DocumentSnapshot<Map<String, dynamic>>>.value(
                _FakeDocumentSnapshot_11<Map<String, dynamic>>(
          this,
          Invocation.method(
            #get,
            [options],
          ),
        )),
      ) as _i5.Future<_i4.DocumentSnapshot<Map<String, dynamic>>>);

  @override
  _i5.Stream<_i4.DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool? includeMetadataChanges = false,
    _i3.ListenSource? source = _i3.ListenSource.defaultSource,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #snapshots,
          [],
          {
            #includeMetadataChanges: includeMetadataChanges,
            #source: source,
          },
        ),
        returnValue:
            _i5.Stream<_i4.DocumentSnapshot<Map<String, dynamic>>>.empty(),
      ) as _i5.Stream<_i4.DocumentSnapshot<Map<String, dynamic>>>);

  @override
  _i5.Future<void> set(
    Map<String, dynamic>? data, [
    _i3.SetOptions? options,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #set,
          [
            data,
            options,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.DocumentReference<R> withConverter<R>({
    required _i4.FromFirestore<R>? fromFirestore,
    required _i4.ToFirestore<R>? toFirestore,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #withConverter,
          [],
          {
            #fromFirestore: fromFirestore,
            #toFirestore: toFirestore,
          },
        ),
        returnValue: _FakeDocumentReference_7<R>(
          this,
          Invocation.method(
            #withConverter,
            [],
            {
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        ),
      ) as _i4.DocumentReference<R>);
}

/// A class which mocks [DocumentSnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockProductSnapshot extends _i1.Mock
    implements _i4.DocumentSnapshot<Map<String, dynamic>> {
  MockProductSnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  _i4.DocumentReference<Map<String, dynamic>> get reference =>
      (super.noSuchMethod(
        Invocation.getter(#reference),
        returnValue: _FakeDocumentReference_7<Map<String, dynamic>>(
          this,
          Invocation.getter(#reference),
        ),
      ) as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i4.SnapshotMetadata get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeSnapshotMetadata_12(
          this,
          Invocation.getter(#metadata),
        ),
      ) as _i4.SnapshotMetadata);

  @override
  bool get exists => (super.noSuchMethod(
        Invocation.getter(#exists),
        returnValue: false,
      ) as bool);

  @override
  dynamic get(Object? field) => super.noSuchMethod(Invocation.method(
        #get,
        [field],
      ));

  @override
  dynamic operator [](Object? field) => super.noSuchMethod(Invocation.method(
        #[],
        [field],
      ));
}

/// A class which mocks [QuerySnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockProductQuerySnapshot extends _i1.Mock
    implements _i4.QuerySnapshot<Map<String, dynamic>> {
  MockProductQuerySnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i4.QueryDocumentSnapshot<Map<String, dynamic>>> get docs =>
      (super.noSuchMethod(
        Invocation.getter(#docs),
        returnValue: <_i4.QueryDocumentSnapshot<Map<String, dynamic>>>[],
      ) as List<_i4.QueryDocumentSnapshot<Map<String, dynamic>>>);

  @override
  List<_i4.DocumentChange<Map<String, dynamic>>> get docChanges =>
      (super.noSuchMethod(
        Invocation.getter(#docChanges),
        returnValue: <_i4.DocumentChange<Map<String, dynamic>>>[],
      ) as List<_i4.DocumentChange<Map<String, dynamic>>>);

  @override
  _i4.SnapshotMetadata get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeSnapshotMetadata_12(
          this,
          Invocation.getter(#metadata),
        ),
      ) as _i4.SnapshotMetadata);

  @override
  int get size => (super.noSuchMethod(
        Invocation.getter(#size),
        returnValue: 0,
      ) as int);
}

/// A class which mocks [QueryDocumentSnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockProductQueryDocSnapshot extends _i1.Mock
    implements _i4.QueryDocumentSnapshot<Map<String, dynamic>> {
  MockProductQueryDocSnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  _i4.DocumentReference<Map<String, dynamic>> get reference =>
      (super.noSuchMethod(
        Invocation.getter(#reference),
        returnValue: _FakeDocumentReference_7<Map<String, dynamic>>(
          this,
          Invocation.getter(#reference),
        ),
      ) as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i4.SnapshotMetadata get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeSnapshotMetadata_12(
          this,
          Invocation.getter(#metadata),
        ),
      ) as _i4.SnapshotMetadata);

  @override
  bool get exists => (super.noSuchMethod(
        Invocation.getter(#exists),
        returnValue: false,
      ) as bool);

  @override
  Map<String, dynamic> data() => (super.noSuchMethod(
        Invocation.method(
          #data,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  dynamic get(Object? field) => super.noSuchMethod(Invocation.method(
        #get,
        [field],
      ));

  @override
  dynamic operator [](Object? field) => super.noSuchMethod(Invocation.method(
        #[],
        [field],
      ));
}
