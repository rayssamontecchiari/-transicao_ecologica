// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RegiaoTable extends Regiao with TableInfo<$RegiaoTable, RegiaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegiaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nome];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regiao';
  @override
  VerificationContext validateIntegrity(Insertable<RegiaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegiaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegiaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
    );
  }

  @override
  $RegiaoTable createAlias(String alias) {
    return $RegiaoTable(attachedDatabase, alias);
  }
}

class RegiaoData extends DataClass implements Insertable<RegiaoData> {
  final int id;
  final String nome;
  const RegiaoData({required this.id, required this.nome});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    return map;
  }

  RegiaoCompanion toCompanion(bool nullToAbsent) {
    return RegiaoCompanion(
      id: Value(id),
      nome: Value(nome),
    );
  }

  factory RegiaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegiaoData(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
    };
  }

  RegiaoData copyWith({int? id, String? nome}) => RegiaoData(
        id: id ?? this.id,
        nome: nome ?? this.nome,
      );
  RegiaoData copyWithCompanion(RegiaoCompanion data) {
    return RegiaoData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegiaoData(')
          ..write('id: $id, ')
          ..write('nome: $nome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegiaoData && other.id == this.id && other.nome == this.nome);
}

class RegiaoCompanion extends UpdateCompanion<RegiaoData> {
  final Value<int> id;
  final Value<String> nome;
  const RegiaoCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
  });
  RegiaoCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
  }) : nome = Value(nome);
  static Insertable<RegiaoData> custom({
    Expression<int>? id,
    Expression<String>? nome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
    });
  }

  RegiaoCompanion copyWith({Value<int>? id, Value<String>? nome}) {
    return RegiaoCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegiaoCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome')
          ..write(')'))
        .toString();
  }
}

class $FamiliaTable extends Familia with TableInfo<$FamiliaTable, FamiliaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeResponsavelMeta =
      const VerificationMeta('nomeResponsavel');
  @override
  late final GeneratedColumn<String> nomeResponsavel = GeneratedColumn<String>(
      'nome_responsavel', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefoneMeta =
      const VerificationMeta('telefone');
  @override
  late final GeneratedColumn<String> telefone = GeneratedColumn<String>(
      'telefone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enderecoMeta =
      const VerificationMeta('endereco');
  @override
  late final GeneratedColumn<String> endereco = GeneratedColumn<String>(
      'endereco', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _regiaoIdMeta =
      const VerificationMeta('regiaoId');
  @override
  late final GeneratedColumn<int> regiaoId = GeneratedColumn<int>(
      'regiao_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES regiao (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nomeResponsavel, telefone, endereco, regiaoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'familia';
  @override
  VerificationContext validateIntegrity(Insertable<FamiliaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome_responsavel')) {
      context.handle(
          _nomeResponsavelMeta,
          nomeResponsavel.isAcceptableOrUnknown(
              data['nome_responsavel']!, _nomeResponsavelMeta));
    } else if (isInserting) {
      context.missing(_nomeResponsavelMeta);
    }
    if (data.containsKey('telefone')) {
      context.handle(_telefoneMeta,
          telefone.isAcceptableOrUnknown(data['telefone']!, _telefoneMeta));
    } else if (isInserting) {
      context.missing(_telefoneMeta);
    }
    if (data.containsKey('endereco')) {
      context.handle(_enderecoMeta,
          endereco.isAcceptableOrUnknown(data['endereco']!, _enderecoMeta));
    } else if (isInserting) {
      context.missing(_enderecoMeta);
    }
    if (data.containsKey('regiao_id')) {
      context.handle(_regiaoIdMeta,
          regiaoId.isAcceptableOrUnknown(data['regiao_id']!, _regiaoIdMeta));
    } else if (isInserting) {
      context.missing(_regiaoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamiliaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamiliaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nomeResponsavel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nome_responsavel'])!,
      telefone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefone'])!,
      endereco: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endereco'])!,
      regiaoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}regiao_id'])!,
    );
  }

  @override
  $FamiliaTable createAlias(String alias) {
    return $FamiliaTable(attachedDatabase, alias);
  }
}

class FamiliaData extends DataClass implements Insertable<FamiliaData> {
  final int id;
  final String nomeResponsavel;
  final String telefone;
  final String endereco;
  final int regiaoId;
  const FamiliaData(
      {required this.id,
      required this.nomeResponsavel,
      required this.telefone,
      required this.endereco,
      required this.regiaoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome_responsavel'] = Variable<String>(nomeResponsavel);
    map['telefone'] = Variable<String>(telefone);
    map['endereco'] = Variable<String>(endereco);
    map['regiao_id'] = Variable<int>(regiaoId);
    return map;
  }

  FamiliaCompanion toCompanion(bool nullToAbsent) {
    return FamiliaCompanion(
      id: Value(id),
      nomeResponsavel: Value(nomeResponsavel),
      telefone: Value(telefone),
      endereco: Value(endereco),
      regiaoId: Value(regiaoId),
    );
  }

  factory FamiliaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamiliaData(
      id: serializer.fromJson<int>(json['id']),
      nomeResponsavel: serializer.fromJson<String>(json['nomeResponsavel']),
      telefone: serializer.fromJson<String>(json['telefone']),
      endereco: serializer.fromJson<String>(json['endereco']),
      regiaoId: serializer.fromJson<int>(json['regiaoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nomeResponsavel': serializer.toJson<String>(nomeResponsavel),
      'telefone': serializer.toJson<String>(telefone),
      'endereco': serializer.toJson<String>(endereco),
      'regiaoId': serializer.toJson<int>(regiaoId),
    };
  }

  FamiliaData copyWith(
          {int? id,
          String? nomeResponsavel,
          String? telefone,
          String? endereco,
          int? regiaoId}) =>
      FamiliaData(
        id: id ?? this.id,
        nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
        telefone: telefone ?? this.telefone,
        endereco: endereco ?? this.endereco,
        regiaoId: regiaoId ?? this.regiaoId,
      );
  FamiliaData copyWithCompanion(FamiliaCompanion data) {
    return FamiliaData(
      id: data.id.present ? data.id.value : this.id,
      nomeResponsavel: data.nomeResponsavel.present
          ? data.nomeResponsavel.value
          : this.nomeResponsavel,
      telefone: data.telefone.present ? data.telefone.value : this.telefone,
      endereco: data.endereco.present ? data.endereco.value : this.endereco,
      regiaoId: data.regiaoId.present ? data.regiaoId.value : this.regiaoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamiliaData(')
          ..write('id: $id, ')
          ..write('nomeResponsavel: $nomeResponsavel, ')
          ..write('telefone: $telefone, ')
          ..write('endereco: $endereco, ')
          ..write('regiaoId: $regiaoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nomeResponsavel, telefone, endereco, regiaoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamiliaData &&
          other.id == this.id &&
          other.nomeResponsavel == this.nomeResponsavel &&
          other.telefone == this.telefone &&
          other.endereco == this.endereco &&
          other.regiaoId == this.regiaoId);
}

class FamiliaCompanion extends UpdateCompanion<FamiliaData> {
  final Value<int> id;
  final Value<String> nomeResponsavel;
  final Value<String> telefone;
  final Value<String> endereco;
  final Value<int> regiaoId;
  const FamiliaCompanion({
    this.id = const Value.absent(),
    this.nomeResponsavel = const Value.absent(),
    this.telefone = const Value.absent(),
    this.endereco = const Value.absent(),
    this.regiaoId = const Value.absent(),
  });
  FamiliaCompanion.insert({
    this.id = const Value.absent(),
    required String nomeResponsavel,
    required String telefone,
    required String endereco,
    required int regiaoId,
  })  : nomeResponsavel = Value(nomeResponsavel),
        telefone = Value(telefone),
        endereco = Value(endereco),
        regiaoId = Value(regiaoId);
  static Insertable<FamiliaData> custom({
    Expression<int>? id,
    Expression<String>? nomeResponsavel,
    Expression<String>? telefone,
    Expression<String>? endereco,
    Expression<int>? regiaoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nomeResponsavel != null) 'nome_responsavel': nomeResponsavel,
      if (telefone != null) 'telefone': telefone,
      if (endereco != null) 'endereco': endereco,
      if (regiaoId != null) 'regiao_id': regiaoId,
    });
  }

  FamiliaCompanion copyWith(
      {Value<int>? id,
      Value<String>? nomeResponsavel,
      Value<String>? telefone,
      Value<String>? endereco,
      Value<int>? regiaoId}) {
    return FamiliaCompanion(
      id: id ?? this.id,
      nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      regiaoId: regiaoId ?? this.regiaoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nomeResponsavel.present) {
      map['nome_responsavel'] = Variable<String>(nomeResponsavel.value);
    }
    if (telefone.present) {
      map['telefone'] = Variable<String>(telefone.value);
    }
    if (endereco.present) {
      map['endereco'] = Variable<String>(endereco.value);
    }
    if (regiaoId.present) {
      map['regiao_id'] = Variable<int>(regiaoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliaCompanion(')
          ..write('id: $id, ')
          ..write('nomeResponsavel: $nomeResponsavel, ')
          ..write('telefone: $telefone, ')
          ..write('endereco: $endereco, ')
          ..write('regiaoId: $regiaoId')
          ..write(')'))
        .toString();
  }
}

class $CategoriaTable extends Categoria
    with TableInfo<$CategoriaTable, CategoriaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, nome, descricao];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categoria';
  @override
  VerificationContext validateIntegrity(Insertable<CategoriaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao']),
    );
  }

  @override
  $CategoriaTable createAlias(String alias) {
    return $CategoriaTable(attachedDatabase, alias);
  }
}

class CategoriaData extends DataClass implements Insertable<CategoriaData> {
  final int id;
  final String nome;
  final String? descricao;
  const CategoriaData({required this.id, required this.nome, this.descricao});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || descricao != null) {
      map['descricao'] = Variable<String>(descricao);
    }
    return map;
  }

  CategoriaCompanion toCompanion(bool nullToAbsent) {
    return CategoriaCompanion(
      id: Value(id),
      nome: Value(nome),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
    );
  }

  factory CategoriaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriaData(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      descricao: serializer.fromJson<String?>(json['descricao']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'descricao': serializer.toJson<String?>(descricao),
    };
  }

  CategoriaData copyWith(
          {int? id,
          String? nome,
          Value<String?> descricao = const Value.absent()}) =>
      CategoriaData(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        descricao: descricao.present ? descricao.value : this.descricao,
      );
  CategoriaData copyWithCompanion(CategoriaCompanion data) {
    return CategoriaData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriaData(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, descricao);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriaData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.descricao == this.descricao);
}

class CategoriaCompanion extends UpdateCompanion<CategoriaData> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String?> descricao;
  const CategoriaCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.descricao = const Value.absent(),
  });
  CategoriaCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.descricao = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<CategoriaData> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? descricao,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
    });
  }

  CategoriaCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<String?>? descricao}) {
    return CategoriaCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriaCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao')
          ..write(')'))
        .toString();
  }
}

class $DimensaoTable extends Dimensao
    with TableInfo<$DimensaoTable, DimensaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DimensaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
      'categoria_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categoria (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, nome, categoriaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dimensao';
  @override
  VerificationContext validateIntegrity(Insertable<DimensaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DimensaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DimensaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id'])!,
    );
  }

  @override
  $DimensaoTable createAlias(String alias) {
    return $DimensaoTable(attachedDatabase, alias);
  }
}

class DimensaoData extends DataClass implements Insertable<DimensaoData> {
  final int id;
  final String nome;

  /// referência para a categoria à qual esta dimensão pertence. Mantemos o
  /// vínculo à categoria para consultas mais simples e para manter coerência
  /// quando vários níveis de hierarquia forem necessários.
  final int categoriaId;
  const DimensaoData(
      {required this.id, required this.nome, required this.categoriaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['categoria_id'] = Variable<int>(categoriaId);
    return map;
  }

  DimensaoCompanion toCompanion(bool nullToAbsent) {
    return DimensaoCompanion(
      id: Value(id),
      nome: Value(nome),
      categoriaId: Value(categoriaId),
    );
  }

  factory DimensaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DimensaoData(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'categoriaId': serializer.toJson<int>(categoriaId),
    };
  }

  DimensaoData copyWith({int? id, String? nome, int? categoriaId}) =>
      DimensaoData(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        categoriaId: categoriaId ?? this.categoriaId,
      );
  DimensaoData copyWithCompanion(DimensaoCompanion data) {
    return DimensaoData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DimensaoData(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, categoriaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DimensaoData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.categoriaId == this.categoriaId);
}

class DimensaoCompanion extends UpdateCompanion<DimensaoData> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> categoriaId;
  const DimensaoCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.categoriaId = const Value.absent(),
  });
  DimensaoCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int categoriaId,
  })  : nome = Value(nome),
        categoriaId = Value(categoriaId);
  static Insertable<DimensaoData> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? categoriaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (categoriaId != null) 'categoria_id': categoriaId,
    });
  }

  DimensaoCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<int>? categoriaId}) {
    return DimensaoCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DimensaoCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }
}

class $PraticaTable extends Pratica with TableInfo<$PraticaTable, PraticaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraticaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
      'categoria_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categoria (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, nome, categoriaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pratica';
  @override
  VerificationContext validateIntegrity(Insertable<PraticaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PraticaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraticaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id'])!,
    );
  }

  @override
  $PraticaTable createAlias(String alias) {
    return $PraticaTable(attachedDatabase, alias);
  }
}

class PraticaData extends DataClass implements Insertable<PraticaData> {
  final int id;
  final String nome;

  /// Referência para a categoria à qual esta prática pertence.
  final int categoriaId;
  const PraticaData(
      {required this.id, required this.nome, required this.categoriaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['categoria_id'] = Variable<int>(categoriaId);
    return map;
  }

  PraticaCompanion toCompanion(bool nullToAbsent) {
    return PraticaCompanion(
      id: Value(id),
      nome: Value(nome),
      categoriaId: Value(categoriaId),
    );
  }

  factory PraticaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraticaData(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'categoriaId': serializer.toJson<int>(categoriaId),
    };
  }

  PraticaData copyWith({int? id, String? nome, int? categoriaId}) =>
      PraticaData(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        categoriaId: categoriaId ?? this.categoriaId,
      );
  PraticaData copyWithCompanion(PraticaCompanion data) {
    return PraticaData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraticaData(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, categoriaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraticaData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.categoriaId == this.categoriaId);
}

class PraticaCompanion extends UpdateCompanion<PraticaData> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> categoriaId;
  const PraticaCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.categoriaId = const Value.absent(),
  });
  PraticaCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int categoriaId,
  })  : nome = Value(nome),
        categoriaId = Value(categoriaId);
  static Insertable<PraticaData> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? categoriaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (categoriaId != null) 'categoria_id': categoriaId,
    });
  }

  PraticaCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<int>? categoriaId}) {
    return PraticaCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraticaCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }
}

class $IndicadorTable extends Indicador
    with TableInfo<$IndicadorTable, IndicadorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndicadorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
      'peso', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
      'categoria_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categoria (id)'));
  static const VerificationMeta _dimensaoIdMeta =
      const VerificationMeta('dimensaoId');
  @override
  late final GeneratedColumn<int> dimensaoId = GeneratedColumn<int>(
      'dimensao_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dimensao (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nome, descricao, peso, categoriaId, dimensaoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'indicador';
  @override
  VerificationContext validateIntegrity(Insertable<IndicadorData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
          _pesoMeta, peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta));
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('dimensao_id')) {
      context.handle(
          _dimensaoIdMeta,
          dimensaoId.isAcceptableOrUnknown(
              data['dimensao_id']!, _dimensaoIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IndicadorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndicadorData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao'])!,
      peso: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peso'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id'])!,
      dimensaoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dimensao_id']),
    );
  }

  @override
  $IndicadorTable createAlias(String alias) {
    return $IndicadorTable(attachedDatabase, alias);
  }
}

class IndicadorData extends DataClass implements Insertable<IndicadorData> {
  final int id;
  final String nome;
  final String descricao;
  final double peso;
  final int categoriaId;
  final int? dimensaoId;
  const IndicadorData(
      {required this.id,
      required this.nome,
      required this.descricao,
      required this.peso,
      required this.categoriaId,
      this.dimensaoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['descricao'] = Variable<String>(descricao);
    map['peso'] = Variable<double>(peso);
    map['categoria_id'] = Variable<int>(categoriaId);
    if (!nullToAbsent || dimensaoId != null) {
      map['dimensao_id'] = Variable<int>(dimensaoId);
    }
    return map;
  }

  IndicadorCompanion toCompanion(bool nullToAbsent) {
    return IndicadorCompanion(
      id: Value(id),
      nome: Value(nome),
      descricao: Value(descricao),
      peso: Value(peso),
      categoriaId: Value(categoriaId),
      dimensaoId: dimensaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(dimensaoId),
    );
  }

  factory IndicadorData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndicadorData(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      descricao: serializer.fromJson<String>(json['descricao']),
      peso: serializer.fromJson<double>(json['peso']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      dimensaoId: serializer.fromJson<int?>(json['dimensaoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'descricao': serializer.toJson<String>(descricao),
      'peso': serializer.toJson<double>(peso),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'dimensaoId': serializer.toJson<int?>(dimensaoId),
    };
  }

  IndicadorData copyWith(
          {int? id,
          String? nome,
          String? descricao,
          double? peso,
          int? categoriaId,
          Value<int?> dimensaoId = const Value.absent()}) =>
      IndicadorData(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        descricao: descricao ?? this.descricao,
        peso: peso ?? this.peso,
        categoriaId: categoriaId ?? this.categoriaId,
        dimensaoId: dimensaoId.present ? dimensaoId.value : this.dimensaoId,
      );
  IndicadorData copyWithCompanion(IndicadorCompanion data) {
    return IndicadorData(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      peso: data.peso.present ? data.peso.value : this.peso,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
      dimensaoId:
          data.dimensaoId.present ? data.dimensaoId.value : this.dimensaoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndicadorData(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao, ')
          ..write('peso: $peso, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('dimensaoId: $dimensaoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, descricao, peso, categoriaId, dimensaoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndicadorData &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.descricao == this.descricao &&
          other.peso == this.peso &&
          other.categoriaId == this.categoriaId &&
          other.dimensaoId == this.dimensaoId);
}

class IndicadorCompanion extends UpdateCompanion<IndicadorData> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> descricao;
  final Value<double> peso;
  final Value<int> categoriaId;
  final Value<int?> dimensaoId;
  const IndicadorCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.descricao = const Value.absent(),
    this.peso = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.dimensaoId = const Value.absent(),
  });
  IndicadorCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String descricao,
    this.peso = const Value.absent(),
    required int categoriaId,
    this.dimensaoId = const Value.absent(),
  })  : nome = Value(nome),
        descricao = Value(descricao),
        categoriaId = Value(categoriaId);
  static Insertable<IndicadorData> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? descricao,
    Expression<double>? peso,
    Expression<int>? categoriaId,
    Expression<int>? dimensaoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (peso != null) 'peso': peso,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (dimensaoId != null) 'dimensao_id': dimensaoId,
    });
  }

  IndicadorCompanion copyWith(
      {Value<int>? id,
      Value<String>? nome,
      Value<String>? descricao,
      Value<double>? peso,
      Value<int>? categoriaId,
      Value<int?>? dimensaoId}) {
    return IndicadorCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      peso: peso ?? this.peso,
      categoriaId: categoriaId ?? this.categoriaId,
      dimensaoId: dimensaoId ?? this.dimensaoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (dimensaoId.present) {
      map['dimensao_id'] = Variable<int>(dimensaoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndicadorCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao, ')
          ..write('peso: $peso, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('dimensaoId: $dimensaoId')
          ..write(')'))
        .toString();
  }
}

class $AvaliacaoTable extends Avaliacao
    with TableInfo<$AvaliacaoTable, AvaliacaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvaliacaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
      'data', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dataAlteracaoMeta =
      const VerificationMeta('dataAlteracao');
  @override
  late final GeneratedColumn<DateTime> dataAlteracao =
      GeneratedColumn<DateTime>('data_alteracao', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _avaliadorMeta =
      const VerificationMeta('avaliador');
  @override
  late final GeneratedColumn<String> avaliador = GeneratedColumn<String>(
      'avaliador', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observacoesMeta =
      const VerificationMeta('observacoes');
  @override
  late final GeneratedColumn<String> observacoes = GeneratedColumn<String>(
      'observacoes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _familiaIdMeta =
      const VerificationMeta('familiaId');
  @override
  late final GeneratedColumn<int> familiaId = GeneratedColumn<int>(
      'familia_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES familia (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, data, dataAlteracao, avaliador, observacoes, status, familiaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avaliacao';
  @override
  VerificationContext validateIntegrity(Insertable<AvaliacaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('data_alteracao')) {
      context.handle(
          _dataAlteracaoMeta,
          dataAlteracao.isAcceptableOrUnknown(
              data['data_alteracao']!, _dataAlteracaoMeta));
    }
    if (data.containsKey('avaliador')) {
      context.handle(_avaliadorMeta,
          avaliador.isAcceptableOrUnknown(data['avaliador']!, _avaliadorMeta));
    } else if (isInserting) {
      context.missing(_avaliadorMeta);
    }
    if (data.containsKey('observacoes')) {
      context.handle(
          _observacoesMeta,
          observacoes.isAcceptableOrUnknown(
              data['observacoes']!, _observacoesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('familia_id')) {
      context.handle(_familiaIdMeta,
          familiaId.isAcceptableOrUnknown(data['familia_id']!, _familiaIdMeta));
    } else if (isInserting) {
      context.missing(_familiaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AvaliacaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvaliacaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data'])!,
      dataAlteracao: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_alteracao'])!,
      avaliador: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avaliador'])!,
      observacoes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observacoes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      familiaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}familia_id'])!,
    );
  }

  @override
  $AvaliacaoTable createAlias(String alias) {
    return $AvaliacaoTable(attachedDatabase, alias);
  }
}

class AvaliacaoData extends DataClass implements Insertable<AvaliacaoData> {
  final int id;
  final DateTime data;
  final DateTime dataAlteracao;
  final String avaliador;
  final String? observacoes;

  /// 'draft' = em progresso, 'completed' = finalizada
  final String status;

  /// Qual categoria o usuário está preenchendo (0-3)
  final int familiaId;
  const AvaliacaoData(
      {required this.id,
      required this.data,
      required this.dataAlteracao,
      required this.avaliador,
      this.observacoes,
      required this.status,
      required this.familiaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<DateTime>(data);
    map['data_alteracao'] = Variable<DateTime>(dataAlteracao);
    map['avaliador'] = Variable<String>(avaliador);
    if (!nullToAbsent || observacoes != null) {
      map['observacoes'] = Variable<String>(observacoes);
    }
    map['status'] = Variable<String>(status);
    map['familia_id'] = Variable<int>(familiaId);
    return map;
  }

  AvaliacaoCompanion toCompanion(bool nullToAbsent) {
    return AvaliacaoCompanion(
      id: Value(id),
      data: Value(data),
      dataAlteracao: Value(dataAlteracao),
      avaliador: Value(avaliador),
      observacoes: observacoes == null && nullToAbsent
          ? const Value.absent()
          : Value(observacoes),
      status: Value(status),
      familiaId: Value(familiaId),
    );
  }

  factory AvaliacaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvaliacaoData(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<DateTime>(json['data']),
      dataAlteracao: serializer.fromJson<DateTime>(json['dataAlteracao']),
      avaliador: serializer.fromJson<String>(json['avaliador']),
      observacoes: serializer.fromJson<String?>(json['observacoes']),
      status: serializer.fromJson<String>(json['status']),
      familiaId: serializer.fromJson<int>(json['familiaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<DateTime>(data),
      'dataAlteracao': serializer.toJson<DateTime>(dataAlteracao),
      'avaliador': serializer.toJson<String>(avaliador),
      'observacoes': serializer.toJson<String?>(observacoes),
      'status': serializer.toJson<String>(status),
      'familiaId': serializer.toJson<int>(familiaId),
    };
  }

  AvaliacaoData copyWith(
          {int? id,
          DateTime? data,
          DateTime? dataAlteracao,
          String? avaliador,
          Value<String?> observacoes = const Value.absent(),
          String? status,
          int? familiaId}) =>
      AvaliacaoData(
        id: id ?? this.id,
        data: data ?? this.data,
        dataAlteracao: dataAlteracao ?? this.dataAlteracao,
        avaliador: avaliador ?? this.avaliador,
        observacoes: observacoes.present ? observacoes.value : this.observacoes,
        status: status ?? this.status,
        familiaId: familiaId ?? this.familiaId,
      );
  AvaliacaoData copyWithCompanion(AvaliacaoCompanion data) {
    return AvaliacaoData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      dataAlteracao: data.dataAlteracao.present
          ? data.dataAlteracao.value
          : this.dataAlteracao,
      avaliador: data.avaliador.present ? data.avaliador.value : this.avaliador,
      observacoes:
          data.observacoes.present ? data.observacoes.value : this.observacoes,
      status: data.status.present ? data.status.value : this.status,
      familiaId: data.familiaId.present ? data.familiaId.value : this.familiaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvaliacaoData(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('dataAlteracao: $dataAlteracao, ')
          ..write('avaliador: $avaliador, ')
          ..write('observacoes: $observacoes, ')
          ..write('status: $status, ')
          ..write('familiaId: $familiaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, data, dataAlteracao, avaliador, observacoes, status, familiaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvaliacaoData &&
          other.id == this.id &&
          other.data == this.data &&
          other.dataAlteracao == this.dataAlteracao &&
          other.avaliador == this.avaliador &&
          other.observacoes == this.observacoes &&
          other.status == this.status &&
          other.familiaId == this.familiaId);
}

class AvaliacaoCompanion extends UpdateCompanion<AvaliacaoData> {
  final Value<int> id;
  final Value<DateTime> data;
  final Value<DateTime> dataAlteracao;
  final Value<String> avaliador;
  final Value<String?> observacoes;
  final Value<String> status;
  final Value<int> familiaId;
  const AvaliacaoCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.dataAlteracao = const Value.absent(),
    this.avaliador = const Value.absent(),
    this.observacoes = const Value.absent(),
    this.status = const Value.absent(),
    this.familiaId = const Value.absent(),
  });
  AvaliacaoCompanion.insert({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.dataAlteracao = const Value.absent(),
    required String avaliador,
    this.observacoes = const Value.absent(),
    this.status = const Value.absent(),
    required int familiaId,
  })  : avaliador = Value(avaliador),
        familiaId = Value(familiaId);
  static Insertable<AvaliacaoData> custom({
    Expression<int>? id,
    Expression<DateTime>? data,
    Expression<DateTime>? dataAlteracao,
    Expression<String>? avaliador,
    Expression<String>? observacoes,
    Expression<String>? status,
    Expression<int>? familiaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (dataAlteracao != null) 'data_alteracao': dataAlteracao,
      if (avaliador != null) 'avaliador': avaliador,
      if (observacoes != null) 'observacoes': observacoes,
      if (status != null) 'status': status,
      if (familiaId != null) 'familia_id': familiaId,
    });
  }

  AvaliacaoCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? data,
      Value<DateTime>? dataAlteracao,
      Value<String>? avaliador,
      Value<String?>? observacoes,
      Value<String>? status,
      Value<int>? familiaId}) {
    return AvaliacaoCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      dataAlteracao: dataAlteracao ?? this.dataAlteracao,
      avaliador: avaliador ?? this.avaliador,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      familiaId: familiaId ?? this.familiaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (dataAlteracao.present) {
      map['data_alteracao'] = Variable<DateTime>(dataAlteracao.value);
    }
    if (avaliador.present) {
      map['avaliador'] = Variable<String>(avaliador.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (familiaId.present) {
      map['familia_id'] = Variable<int>(familiaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvaliacaoCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('dataAlteracao: $dataAlteracao, ')
          ..write('avaliador: $avaliador, ')
          ..write('observacoes: $observacoes, ')
          ..write('status: $status, ')
          ..write('familiaId: $familiaId')
          ..write(')'))
        .toString();
  }
}

class $AvaliacaoItemTable extends AvaliacaoItem
    with TableInfo<$AvaliacaoItemTable, AvaliacaoItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvaliacaoItemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _avaliacaoIdMeta =
      const VerificationMeta('avaliacaoId');
  @override
  late final GeneratedColumn<int> avaliacaoId = GeneratedColumn<int>(
      'avaliacao_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES avaliacao (id)'));
  static const VerificationMeta _indicadorIdMeta =
      const VerificationMeta('indicadorId');
  @override
  late final GeneratedColumn<int> indicadorId = GeneratedColumn<int>(
      'indicador_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES indicador (id)'));
  static const VerificationMeta _praticaIdMeta =
      const VerificationMeta('praticaId');
  @override
  late final GeneratedColumn<int> praticaId = GeneratedColumn<int>(
      'pratica_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES pratica (id)'));
  static const VerificationMeta _valorLikertMeta =
      const VerificationMeta('valorLikert');
  @override
  late final GeneratedColumn<int> valorLikert = GeneratedColumn<int>(
      'valor_likert', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'CHECK (valor_likert BETWEEN 1 AND 5)');
  static const VerificationMeta _valorFuzzyMeta =
      const VerificationMeta('valorFuzzy');
  @override
  late final GeneratedColumn<double> valorFuzzy = GeneratedColumn<double>(
      'valor_fuzzy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, avaliacaoId, indicadorId, praticaId, valorLikert, valorFuzzy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avaliacao_item';
  @override
  VerificationContext validateIntegrity(Insertable<AvaliacaoItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('avaliacao_id')) {
      context.handle(
          _avaliacaoIdMeta,
          avaliacaoId.isAcceptableOrUnknown(
              data['avaliacao_id']!, _avaliacaoIdMeta));
    } else if (isInserting) {
      context.missing(_avaliacaoIdMeta);
    }
    if (data.containsKey('indicador_id')) {
      context.handle(
          _indicadorIdMeta,
          indicadorId.isAcceptableOrUnknown(
              data['indicador_id']!, _indicadorIdMeta));
    } else if (isInserting) {
      context.missing(_indicadorIdMeta);
    }
    if (data.containsKey('pratica_id')) {
      context.handle(_praticaIdMeta,
          praticaId.isAcceptableOrUnknown(data['pratica_id']!, _praticaIdMeta));
    }
    if (data.containsKey('valor_likert')) {
      context.handle(
          _valorLikertMeta,
          valorLikert.isAcceptableOrUnknown(
              data['valor_likert']!, _valorLikertMeta));
    }
    if (data.containsKey('valor_fuzzy')) {
      context.handle(
          _valorFuzzyMeta,
          valorFuzzy.isAcceptableOrUnknown(
              data['valor_fuzzy']!, _valorFuzzyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AvaliacaoItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvaliacaoItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      avaliacaoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}avaliacao_id'])!,
      indicadorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}indicador_id'])!,
      praticaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pratica_id']),
      valorLikert: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}valor_likert']),
      valorFuzzy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valor_fuzzy']),
    );
  }

  @override
  $AvaliacaoItemTable createAlias(String alias) {
    return $AvaliacaoItemTable(attachedDatabase, alias);
  }
}

class AvaliacaoItemData extends DataClass
    implements Insertable<AvaliacaoItemData> {
  final int id;
  final int avaliacaoId;
  final int indicadorId;

  /// When evaluating the special "Multidimensional" category, an item is
  /// tied to a particular agricultural practice. For other categories this
  /// column remains null.
  final int? praticaId;
  final int? valorLikert;
  final double? valorFuzzy;
  const AvaliacaoItemData(
      {required this.id,
      required this.avaliacaoId,
      required this.indicadorId,
      this.praticaId,
      this.valorLikert,
      this.valorFuzzy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['avaliacao_id'] = Variable<int>(avaliacaoId);
    map['indicador_id'] = Variable<int>(indicadorId);
    if (!nullToAbsent || praticaId != null) {
      map['pratica_id'] = Variable<int>(praticaId);
    }
    if (!nullToAbsent || valorLikert != null) {
      map['valor_likert'] = Variable<int>(valorLikert);
    }
    if (!nullToAbsent || valorFuzzy != null) {
      map['valor_fuzzy'] = Variable<double>(valorFuzzy);
    }
    return map;
  }

  AvaliacaoItemCompanion toCompanion(bool nullToAbsent) {
    return AvaliacaoItemCompanion(
      id: Value(id),
      avaliacaoId: Value(avaliacaoId),
      indicadorId: Value(indicadorId),
      praticaId: praticaId == null && nullToAbsent
          ? const Value.absent()
          : Value(praticaId),
      valorLikert: valorLikert == null && nullToAbsent
          ? const Value.absent()
          : Value(valorLikert),
      valorFuzzy: valorFuzzy == null && nullToAbsent
          ? const Value.absent()
          : Value(valorFuzzy),
    );
  }

  factory AvaliacaoItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvaliacaoItemData(
      id: serializer.fromJson<int>(json['id']),
      avaliacaoId: serializer.fromJson<int>(json['avaliacaoId']),
      indicadorId: serializer.fromJson<int>(json['indicadorId']),
      praticaId: serializer.fromJson<int?>(json['praticaId']),
      valorLikert: serializer.fromJson<int?>(json['valorLikert']),
      valorFuzzy: serializer.fromJson<double?>(json['valorFuzzy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'avaliacaoId': serializer.toJson<int>(avaliacaoId),
      'indicadorId': serializer.toJson<int>(indicadorId),
      'praticaId': serializer.toJson<int?>(praticaId),
      'valorLikert': serializer.toJson<int?>(valorLikert),
      'valorFuzzy': serializer.toJson<double?>(valorFuzzy),
    };
  }

  AvaliacaoItemData copyWith(
          {int? id,
          int? avaliacaoId,
          int? indicadorId,
          Value<int?> praticaId = const Value.absent(),
          Value<int?> valorLikert = const Value.absent(),
          Value<double?> valorFuzzy = const Value.absent()}) =>
      AvaliacaoItemData(
        id: id ?? this.id,
        avaliacaoId: avaliacaoId ?? this.avaliacaoId,
        indicadorId: indicadorId ?? this.indicadorId,
        praticaId: praticaId.present ? praticaId.value : this.praticaId,
        valorLikert: valorLikert.present ? valorLikert.value : this.valorLikert,
        valorFuzzy: valorFuzzy.present ? valorFuzzy.value : this.valorFuzzy,
      );
  AvaliacaoItemData copyWithCompanion(AvaliacaoItemCompanion data) {
    return AvaliacaoItemData(
      id: data.id.present ? data.id.value : this.id,
      avaliacaoId:
          data.avaliacaoId.present ? data.avaliacaoId.value : this.avaliacaoId,
      indicadorId:
          data.indicadorId.present ? data.indicadorId.value : this.indicadorId,
      praticaId: data.praticaId.present ? data.praticaId.value : this.praticaId,
      valorLikert:
          data.valorLikert.present ? data.valorLikert.value : this.valorLikert,
      valorFuzzy:
          data.valorFuzzy.present ? data.valorFuzzy.value : this.valorFuzzy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvaliacaoItemData(')
          ..write('id: $id, ')
          ..write('avaliacaoId: $avaliacaoId, ')
          ..write('indicadorId: $indicadorId, ')
          ..write('praticaId: $praticaId, ')
          ..write('valorLikert: $valorLikert, ')
          ..write('valorFuzzy: $valorFuzzy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, avaliacaoId, indicadorId, praticaId, valorLikert, valorFuzzy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvaliacaoItemData &&
          other.id == this.id &&
          other.avaliacaoId == this.avaliacaoId &&
          other.indicadorId == this.indicadorId &&
          other.praticaId == this.praticaId &&
          other.valorLikert == this.valorLikert &&
          other.valorFuzzy == this.valorFuzzy);
}

class AvaliacaoItemCompanion extends UpdateCompanion<AvaliacaoItemData> {
  final Value<int> id;
  final Value<int> avaliacaoId;
  final Value<int> indicadorId;
  final Value<int?> praticaId;
  final Value<int?> valorLikert;
  final Value<double?> valorFuzzy;
  const AvaliacaoItemCompanion({
    this.id = const Value.absent(),
    this.avaliacaoId = const Value.absent(),
    this.indicadorId = const Value.absent(),
    this.praticaId = const Value.absent(),
    this.valorLikert = const Value.absent(),
    this.valorFuzzy = const Value.absent(),
  });
  AvaliacaoItemCompanion.insert({
    this.id = const Value.absent(),
    required int avaliacaoId,
    required int indicadorId,
    this.praticaId = const Value.absent(),
    this.valorLikert = const Value.absent(),
    this.valorFuzzy = const Value.absent(),
  })  : avaliacaoId = Value(avaliacaoId),
        indicadorId = Value(indicadorId);
  static Insertable<AvaliacaoItemData> custom({
    Expression<int>? id,
    Expression<int>? avaliacaoId,
    Expression<int>? indicadorId,
    Expression<int>? praticaId,
    Expression<int>? valorLikert,
    Expression<double>? valorFuzzy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (avaliacaoId != null) 'avaliacao_id': avaliacaoId,
      if (indicadorId != null) 'indicador_id': indicadorId,
      if (praticaId != null) 'pratica_id': praticaId,
      if (valorLikert != null) 'valor_likert': valorLikert,
      if (valorFuzzy != null) 'valor_fuzzy': valorFuzzy,
    });
  }

  AvaliacaoItemCompanion copyWith(
      {Value<int>? id,
      Value<int>? avaliacaoId,
      Value<int>? indicadorId,
      Value<int?>? praticaId,
      Value<int?>? valorLikert,
      Value<double?>? valorFuzzy}) {
    return AvaliacaoItemCompanion(
      id: id ?? this.id,
      avaliacaoId: avaliacaoId ?? this.avaliacaoId,
      indicadorId: indicadorId ?? this.indicadorId,
      praticaId: praticaId ?? this.praticaId,
      valorLikert: valorLikert ?? this.valorLikert,
      valorFuzzy: valorFuzzy ?? this.valorFuzzy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (avaliacaoId.present) {
      map['avaliacao_id'] = Variable<int>(avaliacaoId.value);
    }
    if (indicadorId.present) {
      map['indicador_id'] = Variable<int>(indicadorId.value);
    }
    if (praticaId.present) {
      map['pratica_id'] = Variable<int>(praticaId.value);
    }
    if (valorLikert.present) {
      map['valor_likert'] = Variable<int>(valorLikert.value);
    }
    if (valorFuzzy.present) {
      map['valor_fuzzy'] = Variable<double>(valorFuzzy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvaliacaoItemCompanion(')
          ..write('id: $id, ')
          ..write('avaliacaoId: $avaliacaoId, ')
          ..write('indicadorId: $indicadorId, ')
          ..write('praticaId: $praticaId, ')
          ..write('valorLikert: $valorLikert, ')
          ..write('valorFuzzy: $valorFuzzy')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RegiaoTable regiao = $RegiaoTable(this);
  late final $FamiliaTable familia = $FamiliaTable(this);
  late final $CategoriaTable categoria = $CategoriaTable(this);
  late final $DimensaoTable dimensao = $DimensaoTable(this);
  late final $PraticaTable pratica = $PraticaTable(this);
  late final $IndicadorTable indicador = $IndicadorTable(this);
  late final $AvaliacaoTable avaliacao = $AvaliacaoTable(this);
  late final $AvaliacaoItemTable avaliacaoItem = $AvaliacaoItemTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        regiao,
        familia,
        categoria,
        dimensao,
        pratica,
        indicador,
        avaliacao,
        avaliacaoItem
      ];
}

typedef $$RegiaoTableCreateCompanionBuilder = RegiaoCompanion Function({
  Value<int> id,
  required String nome,
});
typedef $$RegiaoTableUpdateCompanionBuilder = RegiaoCompanion Function({
  Value<int> id,
  Value<String> nome,
});

class $$RegiaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegiaoTable,
    RegiaoData,
    $$RegiaoTableFilterComposer,
    $$RegiaoTableOrderingComposer,
    $$RegiaoTableCreateCompanionBuilder,
    $$RegiaoTableUpdateCompanionBuilder> {
  $$RegiaoTableTableManager(_$AppDatabase db, $RegiaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RegiaoTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RegiaoTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
          }) =>
              RegiaoCompanion(
            id: id,
            nome: nome,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
          }) =>
              RegiaoCompanion.insert(
            id: id,
            nome: nome,
          ),
        ));
}

class $$RegiaoTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RegiaoTable> {
  $$RegiaoTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter familiaRefs(
      ComposableFilter Function($$FamiliaTableFilterComposer f) f) {
    final $$FamiliaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.familia,
        getReferencedColumn: (t) => t.regiaoId,
        builder: (joinBuilder, parentComposers) => $$FamiliaTableFilterComposer(
            ComposerState(
                $state.db, $state.db.familia, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$RegiaoTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RegiaoTable> {
  $$RegiaoTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FamiliaTableCreateCompanionBuilder = FamiliaCompanion Function({
  Value<int> id,
  required String nomeResponsavel,
  required String telefone,
  required String endereco,
  required int regiaoId,
});
typedef $$FamiliaTableUpdateCompanionBuilder = FamiliaCompanion Function({
  Value<int> id,
  Value<String> nomeResponsavel,
  Value<String> telefone,
  Value<String> endereco,
  Value<int> regiaoId,
});

class $$FamiliaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamiliaTable,
    FamiliaData,
    $$FamiliaTableFilterComposer,
    $$FamiliaTableOrderingComposer,
    $$FamiliaTableCreateCompanionBuilder,
    $$FamiliaTableUpdateCompanionBuilder> {
  $$FamiliaTableTableManager(_$AppDatabase db, $FamiliaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FamiliaTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FamiliaTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nomeResponsavel = const Value.absent(),
            Value<String> telefone = const Value.absent(),
            Value<String> endereco = const Value.absent(),
            Value<int> regiaoId = const Value.absent(),
          }) =>
              FamiliaCompanion(
            id: id,
            nomeResponsavel: nomeResponsavel,
            telefone: telefone,
            endereco: endereco,
            regiaoId: regiaoId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nomeResponsavel,
            required String telefone,
            required String endereco,
            required int regiaoId,
          }) =>
              FamiliaCompanion.insert(
            id: id,
            nomeResponsavel: nomeResponsavel,
            telefone: telefone,
            endereco: endereco,
            regiaoId: regiaoId,
          ),
        ));
}

class $$FamiliaTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FamiliaTable> {
  $$FamiliaTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nomeResponsavel => $state.composableBuilder(
      column: $state.table.nomeResponsavel,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get telefone => $state.composableBuilder(
      column: $state.table.telefone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get endereco => $state.composableBuilder(
      column: $state.table.endereco,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$RegiaoTableFilterComposer get regiaoId {
    final $$RegiaoTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regiaoId,
        referencedTable: $state.db.regiao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$RegiaoTableFilterComposer(
            ComposerState(
                $state.db, $state.db.regiao, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoRefs(
      ComposableFilter Function($$AvaliacaoTableFilterComposer f) f) {
    final $$AvaliacaoTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacao,
        getReferencedColumn: (t) => t.familiaId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoTableFilterComposer(ComposerState(
                $state.db, $state.db.avaliacao, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$FamiliaTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FamiliaTable> {
  $$FamiliaTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nomeResponsavel => $state.composableBuilder(
      column: $state.table.nomeResponsavel,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get telefone => $state.composableBuilder(
      column: $state.table.telefone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get endereco => $state.composableBuilder(
      column: $state.table.endereco,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$RegiaoTableOrderingComposer get regiaoId {
    final $$RegiaoTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regiaoId,
        referencedTable: $state.db.regiao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RegiaoTableOrderingComposer(ComposerState(
                $state.db, $state.db.regiao, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$CategoriaTableCreateCompanionBuilder = CategoriaCompanion Function({
  Value<int> id,
  required String nome,
  Value<String?> descricao,
});
typedef $$CategoriaTableUpdateCompanionBuilder = CategoriaCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String?> descricao,
});

class $$CategoriaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriaTable,
    CategoriaData,
    $$CategoriaTableFilterComposer,
    $$CategoriaTableOrderingComposer,
    $$CategoriaTableCreateCompanionBuilder,
    $$CategoriaTableUpdateCompanionBuilder> {
  $$CategoriaTableTableManager(_$AppDatabase db, $CategoriaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriaTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriaTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> descricao = const Value.absent(),
          }) =>
              CategoriaCompanion(
            id: id,
            nome: nome,
            descricao: descricao,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            Value<String?> descricao = const Value.absent(),
          }) =>
              CategoriaCompanion.insert(
            id: id,
            nome: nome,
            descricao: descricao,
          ),
        ));
}

class $$CategoriaTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriaTable> {
  $$CategoriaTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get descricao => $state.composableBuilder(
      column: $state.table.descricao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter dimensaoRefs(
      ComposableFilter Function($$DimensaoTableFilterComposer f) f) {
    final $$DimensaoTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.dimensao,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) =>
            $$DimensaoTableFilterComposer(ComposerState(
                $state.db, $state.db.dimensao, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter praticaRefs(
      ComposableFilter Function($$PraticaTableFilterComposer f) f) {
    final $$PraticaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.pratica,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) => $$PraticaTableFilterComposer(
            ComposerState(
                $state.db, $state.db.pratica, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter indicadorRefs(
      ComposableFilter Function($$IndicadorTableFilterComposer f) f) {
    final $$IndicadorTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.indicador,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadorTableFilterComposer(ComposerState(
                $state.db, $state.db.indicador, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CategoriaTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriaTable> {
  $$CategoriaTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get descricao => $state.composableBuilder(
      column: $state.table.descricao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DimensaoTableCreateCompanionBuilder = DimensaoCompanion Function({
  Value<int> id,
  required String nome,
  required int categoriaId,
});
typedef $$DimensaoTableUpdateCompanionBuilder = DimensaoCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> categoriaId,
});

class $$DimensaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DimensaoTable,
    DimensaoData,
    $$DimensaoTableFilterComposer,
    $$DimensaoTableOrderingComposer,
    $$DimensaoTableCreateCompanionBuilder,
    $$DimensaoTableUpdateCompanionBuilder> {
  $$DimensaoTableTableManager(_$AppDatabase db, $DimensaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DimensaoTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DimensaoTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
          }) =>
              DimensaoCompanion(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            required int categoriaId,
          }) =>
              DimensaoCompanion.insert(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
        ));
}

class $$DimensaoTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DimensaoTable> {
  $$DimensaoTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriaTableFilterComposer get categoriaId {
    final $$CategoriaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableFilterComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter indicadorRefs(
      ComposableFilter Function($$IndicadorTableFilterComposer f) f) {
    final $$IndicadorTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.indicador,
        getReferencedColumn: (t) => t.dimensaoId,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadorTableFilterComposer(ComposerState(
                $state.db, $state.db.indicador, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$DimensaoTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DimensaoTable> {
  $$DimensaoTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriaTableOrderingComposer get categoriaId {
    final $$CategoriaTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableOrderingComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$PraticaTableCreateCompanionBuilder = PraticaCompanion Function({
  Value<int> id,
  required String nome,
  required int categoriaId,
});
typedef $$PraticaTableUpdateCompanionBuilder = PraticaCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> categoriaId,
});

class $$PraticaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PraticaTable,
    PraticaData,
    $$PraticaTableFilterComposer,
    $$PraticaTableOrderingComposer,
    $$PraticaTableCreateCompanionBuilder,
    $$PraticaTableUpdateCompanionBuilder> {
  $$PraticaTableTableManager(_$AppDatabase db, $PraticaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PraticaTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PraticaTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
          }) =>
              PraticaCompanion(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            required int categoriaId,
          }) =>
              PraticaCompanion.insert(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
        ));
}

class $$PraticaTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PraticaTable> {
  $$PraticaTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriaTableFilterComposer get categoriaId {
    final $$CategoriaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableFilterComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItemRefs(
      ComposableFilter Function($$AvaliacaoItemTableFilterComposer f) f) {
    final $$AvaliacaoItemTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItem,
        getReferencedColumn: (t) => t.praticaId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItemTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$PraticaTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PraticaTable> {
  $$PraticaTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriaTableOrderingComposer get categoriaId {
    final $$CategoriaTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableOrderingComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$IndicadorTableCreateCompanionBuilder = IndicadorCompanion Function({
  Value<int> id,
  required String nome,
  required String descricao,
  Value<double> peso,
  required int categoriaId,
  Value<int?> dimensaoId,
});
typedef $$IndicadorTableUpdateCompanionBuilder = IndicadorCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> descricao,
  Value<double> peso,
  Value<int> categoriaId,
  Value<int?> dimensaoId,
});

class $$IndicadorTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IndicadorTable,
    IndicadorData,
    $$IndicadorTableFilterComposer,
    $$IndicadorTableOrderingComposer,
    $$IndicadorTableCreateCompanionBuilder,
    $$IndicadorTableUpdateCompanionBuilder> {
  $$IndicadorTableTableManager(_$AppDatabase db, $IndicadorTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IndicadorTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IndicadorTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<double> peso = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
            Value<int?> dimensaoId = const Value.absent(),
          }) =>
              IndicadorCompanion(
            id: id,
            nome: nome,
            descricao: descricao,
            peso: peso,
            categoriaId: categoriaId,
            dimensaoId: dimensaoId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            required String descricao,
            Value<double> peso = const Value.absent(),
            required int categoriaId,
            Value<int?> dimensaoId = const Value.absent(),
          }) =>
              IndicadorCompanion.insert(
            id: id,
            nome: nome,
            descricao: descricao,
            peso: peso,
            categoriaId: categoriaId,
            dimensaoId: dimensaoId,
          ),
        ));
}

class $$IndicadorTableFilterComposer
    extends FilterComposer<_$AppDatabase, $IndicadorTable> {
  $$IndicadorTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get descricao => $state.composableBuilder(
      column: $state.table.descricao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get peso => $state.composableBuilder(
      column: $state.table.peso,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriaTableFilterComposer get categoriaId {
    final $$CategoriaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableFilterComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }

  $$DimensaoTableFilterComposer get dimensaoId {
    final $$DimensaoTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensaoId,
        referencedTable: $state.db.dimensao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DimensaoTableFilterComposer(ComposerState(
                $state.db, $state.db.dimensao, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItemRefs(
      ComposableFilter Function($$AvaliacaoItemTableFilterComposer f) f) {
    final $$AvaliacaoItemTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItem,
        getReferencedColumn: (t) => t.indicadorId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItemTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$IndicadorTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $IndicadorTable> {
  $$IndicadorTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get descricao => $state.composableBuilder(
      column: $state.table.descricao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get peso => $state.composableBuilder(
      column: $state.table.peso,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriaTableOrderingComposer get categoriaId {
    final $$CategoriaTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categoria,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriaTableOrderingComposer(ComposerState(
                $state.db, $state.db.categoria, joinBuilder, parentComposers)));
    return composer;
  }

  $$DimensaoTableOrderingComposer get dimensaoId {
    final $$DimensaoTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensaoId,
        referencedTable: $state.db.dimensao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DimensaoTableOrderingComposer(ComposerState(
                $state.db, $state.db.dimensao, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AvaliacaoTableCreateCompanionBuilder = AvaliacaoCompanion Function({
  Value<int> id,
  Value<DateTime> data,
  Value<DateTime> dataAlteracao,
  required String avaliador,
  Value<String?> observacoes,
  Value<String> status,
  required int familiaId,
});
typedef $$AvaliacaoTableUpdateCompanionBuilder = AvaliacaoCompanion Function({
  Value<int> id,
  Value<DateTime> data,
  Value<DateTime> dataAlteracao,
  Value<String> avaliador,
  Value<String?> observacoes,
  Value<String> status,
  Value<int> familiaId,
});

class $$AvaliacaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AvaliacaoTable,
    AvaliacaoData,
    $$AvaliacaoTableFilterComposer,
    $$AvaliacaoTableOrderingComposer,
    $$AvaliacaoTableCreateCompanionBuilder,
    $$AvaliacaoTableUpdateCompanionBuilder> {
  $$AvaliacaoTableTableManager(_$AppDatabase db, $AvaliacaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AvaliacaoTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AvaliacaoTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> data = const Value.absent(),
            Value<DateTime> dataAlteracao = const Value.absent(),
            Value<String> avaliador = const Value.absent(),
            Value<String?> observacoes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> familiaId = const Value.absent(),
          }) =>
              AvaliacaoCompanion(
            id: id,
            data: data,
            dataAlteracao: dataAlteracao,
            avaliador: avaliador,
            observacoes: observacoes,
            status: status,
            familiaId: familiaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> data = const Value.absent(),
            Value<DateTime> dataAlteracao = const Value.absent(),
            required String avaliador,
            Value<String?> observacoes = const Value.absent(),
            Value<String> status = const Value.absent(),
            required int familiaId,
          }) =>
              AvaliacaoCompanion.insert(
            id: id,
            data: data,
            dataAlteracao: dataAlteracao,
            avaliador: avaliador,
            observacoes: observacoes,
            status: status,
            familiaId: familiaId,
          ),
        ));
}

class $$AvaliacaoTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AvaliacaoTable> {
  $$AvaliacaoTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dataAlteracao => $state.composableBuilder(
      column: $state.table.dataAlteracao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avaliador => $state.composableBuilder(
      column: $state.table.avaliador,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get observacoes => $state.composableBuilder(
      column: $state.table.observacoes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$FamiliaTableFilterComposer get familiaId {
    final $$FamiliaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.familiaId,
        referencedTable: $state.db.familia,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FamiliaTableFilterComposer(
            ComposerState(
                $state.db, $state.db.familia, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItemRefs(
      ComposableFilter Function($$AvaliacaoItemTableFilterComposer f) f) {
    final $$AvaliacaoItemTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItem,
        getReferencedColumn: (t) => t.avaliacaoId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItemTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AvaliacaoTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AvaliacaoTable> {
  $$AvaliacaoTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dataAlteracao => $state.composableBuilder(
      column: $state.table.dataAlteracao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avaliador => $state.composableBuilder(
      column: $state.table.avaliador,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get observacoes => $state.composableBuilder(
      column: $state.table.observacoes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$FamiliaTableOrderingComposer get familiaId {
    final $$FamiliaTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.familiaId,
        referencedTable: $state.db.familia,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FamiliaTableOrderingComposer(ComposerState(
                $state.db, $state.db.familia, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AvaliacaoItemTableCreateCompanionBuilder = AvaliacaoItemCompanion
    Function({
  Value<int> id,
  required int avaliacaoId,
  required int indicadorId,
  Value<int?> praticaId,
  Value<int?> valorLikert,
  Value<double?> valorFuzzy,
});
typedef $$AvaliacaoItemTableUpdateCompanionBuilder = AvaliacaoItemCompanion
    Function({
  Value<int> id,
  Value<int> avaliacaoId,
  Value<int> indicadorId,
  Value<int?> praticaId,
  Value<int?> valorLikert,
  Value<double?> valorFuzzy,
});

class $$AvaliacaoItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AvaliacaoItemTable,
    AvaliacaoItemData,
    $$AvaliacaoItemTableFilterComposer,
    $$AvaliacaoItemTableOrderingComposer,
    $$AvaliacaoItemTableCreateCompanionBuilder,
    $$AvaliacaoItemTableUpdateCompanionBuilder> {
  $$AvaliacaoItemTableTableManager(_$AppDatabase db, $AvaliacaoItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AvaliacaoItemTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AvaliacaoItemTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> avaliacaoId = const Value.absent(),
            Value<int> indicadorId = const Value.absent(),
            Value<int?> praticaId = const Value.absent(),
            Value<int?> valorLikert = const Value.absent(),
            Value<double?> valorFuzzy = const Value.absent(),
          }) =>
              AvaliacaoItemCompanion(
            id: id,
            avaliacaoId: avaliacaoId,
            indicadorId: indicadorId,
            praticaId: praticaId,
            valorLikert: valorLikert,
            valorFuzzy: valorFuzzy,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int avaliacaoId,
            required int indicadorId,
            Value<int?> praticaId = const Value.absent(),
            Value<int?> valorLikert = const Value.absent(),
            Value<double?> valorFuzzy = const Value.absent(),
          }) =>
              AvaliacaoItemCompanion.insert(
            id: id,
            avaliacaoId: avaliacaoId,
            indicadorId: indicadorId,
            praticaId: praticaId,
            valorLikert: valorLikert,
            valorFuzzy: valorFuzzy,
          ),
        ));
}

class $$AvaliacaoItemTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AvaliacaoItemTable> {
  $$AvaliacaoItemTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get valorLikert => $state.composableBuilder(
      column: $state.table.valorLikert,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get valorFuzzy => $state.composableBuilder(
      column: $state.table.valorFuzzy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AvaliacaoTableFilterComposer get avaliacaoId {
    final $$AvaliacaoTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avaliacaoId,
        referencedTable: $state.db.avaliacao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoTableFilterComposer(ComposerState(
                $state.db, $state.db.avaliacao, joinBuilder, parentComposers)));
    return composer;
  }

  $$IndicadorTableFilterComposer get indicadorId {
    final $$IndicadorTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.indicadorId,
        referencedTable: $state.db.indicador,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadorTableFilterComposer(ComposerState(
                $state.db, $state.db.indicador, joinBuilder, parentComposers)));
    return composer;
  }

  $$PraticaTableFilterComposer get praticaId {
    final $$PraticaTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.praticaId,
        referencedTable: $state.db.pratica,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$PraticaTableFilterComposer(
            ComposerState(
                $state.db, $state.db.pratica, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$AvaliacaoItemTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AvaliacaoItemTable> {
  $$AvaliacaoItemTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get valorLikert => $state.composableBuilder(
      column: $state.table.valorLikert,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get valorFuzzy => $state.composableBuilder(
      column: $state.table.valorFuzzy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AvaliacaoTableOrderingComposer get avaliacaoId {
    final $$AvaliacaoTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avaliacaoId,
        referencedTable: $state.db.avaliacao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoTableOrderingComposer(ComposerState(
                $state.db, $state.db.avaliacao, joinBuilder, parentComposers)));
    return composer;
  }

  $$IndicadorTableOrderingComposer get indicadorId {
    final $$IndicadorTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.indicadorId,
        referencedTable: $state.db.indicador,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadorTableOrderingComposer(ComposerState(
                $state.db, $state.db.indicador, joinBuilder, parentComposers)));
    return composer;
  }

  $$PraticaTableOrderingComposer get praticaId {
    final $$PraticaTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.praticaId,
        referencedTable: $state.db.pratica,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PraticaTableOrderingComposer(ComposerState(
                $state.db, $state.db.pratica, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RegiaoTableTableManager get regiao =>
      $$RegiaoTableTableManager(_db, _db.regiao);
  $$FamiliaTableTableManager get familia =>
      $$FamiliaTableTableManager(_db, _db.familia);
  $$CategoriaTableTableManager get categoria =>
      $$CategoriaTableTableManager(_db, _db.categoria);
  $$DimensaoTableTableManager get dimensao =>
      $$DimensaoTableTableManager(_db, _db.dimensao);
  $$PraticaTableTableManager get pratica =>
      $$PraticaTableTableManager(_db, _db.pratica);
  $$IndicadorTableTableManager get indicador =>
      $$IndicadorTableTableManager(_db, _db.indicador);
  $$AvaliacaoTableTableManager get avaliacao =>
      $$AvaliacaoTableTableManager(_db, _db.avaliacao);
  $$AvaliacaoItemTableTableManager get avaliacaoItem =>
      $$AvaliacaoItemTableTableManager(_db, _db.avaliacaoItem);
}
