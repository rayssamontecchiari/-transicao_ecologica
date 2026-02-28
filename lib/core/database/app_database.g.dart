// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RegioesTable extends Regioes with TableInfo<$RegioesTable, Regioe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegioesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'regioes';
  @override
  VerificationContext validateIntegrity(Insertable<Regioe> instance,
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
  Regioe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Regioe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
    );
  }

  @override
  $RegioesTable createAlias(String alias) {
    return $RegioesTable(attachedDatabase, alias);
  }
}

class Regioe extends DataClass implements Insertable<Regioe> {
  final int id;
  final String nome;
  const Regioe({required this.id, required this.nome});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    return map;
  }

  RegioesCompanion toCompanion(bool nullToAbsent) {
    return RegioesCompanion(
      id: Value(id),
      nome: Value(nome),
    );
  }

  factory Regioe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Regioe(
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

  Regioe copyWith({int? id, String? nome}) => Regioe(
        id: id ?? this.id,
        nome: nome ?? this.nome,
      );
  Regioe copyWithCompanion(RegioesCompanion data) {
    return Regioe(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Regioe(')
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
      (other is Regioe && other.id == this.id && other.nome == this.nome);
}

class RegioesCompanion extends UpdateCompanion<Regioe> {
  final Value<int> id;
  final Value<String> nome;
  const RegioesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
  });
  RegioesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
  }) : nome = Value(nome);
  static Insertable<Regioe> custom({
    Expression<int>? id,
    Expression<String>? nome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
    });
  }

  RegioesCompanion copyWith({Value<int>? id, Value<String>? nome}) {
    return RegioesCompanion(
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
    return (StringBuffer('RegioesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome')
          ..write(')'))
        .toString();
  }
}

class $FamiliasTable extends Familias with TableInfo<$FamiliasTable, Familia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliasTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES regioes (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nomeResponsavel, telefone, endereco, regiaoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'familias';
  @override
  VerificationContext validateIntegrity(Insertable<Familia> instance,
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
  Familia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Familia(
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
  $FamiliasTable createAlias(String alias) {
    return $FamiliasTable(attachedDatabase, alias);
  }
}

class Familia extends DataClass implements Insertable<Familia> {
  final int id;
  final String nomeResponsavel;
  final String telefone;
  final String endereco;
  final int regiaoId;
  const Familia(
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

  FamiliasCompanion toCompanion(bool nullToAbsent) {
    return FamiliasCompanion(
      id: Value(id),
      nomeResponsavel: Value(nomeResponsavel),
      telefone: Value(telefone),
      endereco: Value(endereco),
      regiaoId: Value(regiaoId),
    );
  }

  factory Familia.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Familia(
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

  Familia copyWith(
          {int? id,
          String? nomeResponsavel,
          String? telefone,
          String? endereco,
          int? regiaoId}) =>
      Familia(
        id: id ?? this.id,
        nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
        telefone: telefone ?? this.telefone,
        endereco: endereco ?? this.endereco,
        regiaoId: regiaoId ?? this.regiaoId,
      );
  Familia copyWithCompanion(FamiliasCompanion data) {
    return Familia(
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
    return (StringBuffer('Familia(')
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
      (other is Familia &&
          other.id == this.id &&
          other.nomeResponsavel == this.nomeResponsavel &&
          other.telefone == this.telefone &&
          other.endereco == this.endereco &&
          other.regiaoId == this.regiaoId);
}

class FamiliasCompanion extends UpdateCompanion<Familia> {
  final Value<int> id;
  final Value<String> nomeResponsavel;
  final Value<String> telefone;
  final Value<String> endereco;
  final Value<int> regiaoId;
  const FamiliasCompanion({
    this.id = const Value.absent(),
    this.nomeResponsavel = const Value.absent(),
    this.telefone = const Value.absent(),
    this.endereco = const Value.absent(),
    this.regiaoId = const Value.absent(),
  });
  FamiliasCompanion.insert({
    this.id = const Value.absent(),
    required String nomeResponsavel,
    required String telefone,
    required String endereco,
    required int regiaoId,
  })  : nomeResponsavel = Value(nomeResponsavel),
        telefone = Value(telefone),
        endereco = Value(endereco),
        regiaoId = Value(regiaoId);
  static Insertable<Familia> custom({
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

  FamiliasCompanion copyWith(
      {Value<int>? id,
      Value<String>? nomeResponsavel,
      Value<String>? telefone,
      Value<String>? endereco,
      Value<int>? regiaoId}) {
    return FamiliasCompanion(
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
    return (StringBuffer('FamiliasCompanion(')
          ..write('id: $id, ')
          ..write('nomeResponsavel: $nomeResponsavel, ')
          ..write('telefone: $telefone, ')
          ..write('endereco: $endereco, ')
          ..write('regiaoId: $regiaoId')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(Insertable<Categoria> instance,
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
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao']),
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nome;
  final String? descricao;
  const Categoria({required this.id, required this.nome, this.descricao});
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

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nome: Value(nome),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
    );
  }

  factory Categoria.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
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

  Categoria copyWith(
          {int? id,
          String? nome,
          Value<String?> descricao = const Value.absent()}) =>
      Categoria(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        descricao: descricao.present ? descricao.value : this.descricao,
      );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
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
      (other is Categoria &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.descricao == this.descricao);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String?> descricao;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.descricao = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.descricao = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Categoria> custom({
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

  CategoriasCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<String?>? descricao}) {
    return CategoriasCompanion(
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
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('descricao: $descricao')
          ..write(')'))
        .toString();
  }
}

class $DimensoesTable extends Dimensoes
    with TableInfo<$DimensoesTable, Dimensoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DimensoesTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES categorias (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, nome, categoriaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dimensoes';
  @override
  VerificationContext validateIntegrity(Insertable<Dimensoe> instance,
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
  Dimensoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dimensoe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id'])!,
    );
  }

  @override
  $DimensoesTable createAlias(String alias) {
    return $DimensoesTable(attachedDatabase, alias);
  }
}

class Dimensoe extends DataClass implements Insertable<Dimensoe> {
  final int id;
  final String nome;

  /// referência para a categoria à qual esta dimensão pertence. Mantemos o
  /// vínculo à categoria para consultas mais simples e para manter coerência
  /// quando vários níveis de hierarquia forem necessários.
  final int categoriaId;
  const Dimensoe(
      {required this.id, required this.nome, required this.categoriaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['categoria_id'] = Variable<int>(categoriaId);
    return map;
  }

  DimensoesCompanion toCompanion(bool nullToAbsent) {
    return DimensoesCompanion(
      id: Value(id),
      nome: Value(nome),
      categoriaId: Value(categoriaId),
    );
  }

  factory Dimensoe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dimensoe(
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

  Dimensoe copyWith({int? id, String? nome, int? categoriaId}) => Dimensoe(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        categoriaId: categoriaId ?? this.categoriaId,
      );
  Dimensoe copyWithCompanion(DimensoesCompanion data) {
    return Dimensoe(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dimensoe(')
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
      (other is Dimensoe &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.categoriaId == this.categoriaId);
}

class DimensoesCompanion extends UpdateCompanion<Dimensoe> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> categoriaId;
  const DimensoesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.categoriaId = const Value.absent(),
  });
  DimensoesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int categoriaId,
  })  : nome = Value(nome),
        categoriaId = Value(categoriaId);
  static Insertable<Dimensoe> custom({
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

  DimensoesCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<int>? categoriaId}) {
    return DimensoesCompanion(
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
    return (StringBuffer('DimensoesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }
}

class $PraticasTable extends Praticas with TableInfo<$PraticasTable, Pratica> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraticasTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES categorias (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, nome, categoriaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praticas';
  @override
  VerificationContext validateIntegrity(Insertable<Pratica> instance,
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
  Pratica map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pratica(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id'])!,
    );
  }

  @override
  $PraticasTable createAlias(String alias) {
    return $PraticasTable(attachedDatabase, alias);
  }
}

class Pratica extends DataClass implements Insertable<Pratica> {
  final int id;
  final String nome;

  /// Referência para a categoria à qual esta prática pertence.
  final int categoriaId;
  const Pratica(
      {required this.id, required this.nome, required this.categoriaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['categoria_id'] = Variable<int>(categoriaId);
    return map;
  }

  PraticasCompanion toCompanion(bool nullToAbsent) {
    return PraticasCompanion(
      id: Value(id),
      nome: Value(nome),
      categoriaId: Value(categoriaId),
    );
  }

  factory Pratica.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pratica(
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

  Pratica copyWith({int? id, String? nome, int? categoriaId}) => Pratica(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        categoriaId: categoriaId ?? this.categoriaId,
      );
  Pratica copyWithCompanion(PraticasCompanion data) {
    return Pratica(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pratica(')
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
      (other is Pratica &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.categoriaId == this.categoriaId);
}

class PraticasCompanion extends UpdateCompanion<Pratica> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> categoriaId;
  const PraticasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.categoriaId = const Value.absent(),
  });
  PraticasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int categoriaId,
  })  : nome = Value(nome),
        categoriaId = Value(categoriaId);
  static Insertable<Pratica> custom({
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

  PraticasCompanion copyWith(
      {Value<int>? id, Value<String>? nome, Value<int>? categoriaId}) {
    return PraticasCompanion(
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
    return (StringBuffer('PraticasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }
}

class $IndicadoresTable extends Indicadores
    with TableInfo<$IndicadoresTable, Indicadore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndicadoresTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES categorias (id)'));
  static const VerificationMeta _dimensaoIdMeta =
      const VerificationMeta('dimensaoId');
  @override
  late final GeneratedColumn<int> dimensaoId = GeneratedColumn<int>(
      'dimensao_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dimensoes (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nome, descricao, peso, categoriaId, dimensaoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'indicadores';
  @override
  VerificationContext validateIntegrity(Insertable<Indicadore> instance,
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
  Indicadore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Indicadore(
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
  $IndicadoresTable createAlias(String alias) {
    return $IndicadoresTable(attachedDatabase, alias);
  }
}

class Indicadore extends DataClass implements Insertable<Indicadore> {
  final int id;
  final String nome;
  final String descricao;
  final double peso;
  final int categoriaId;
  final int? dimensaoId;
  const Indicadore(
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

  IndicadoresCompanion toCompanion(bool nullToAbsent) {
    return IndicadoresCompanion(
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

  factory Indicadore.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Indicadore(
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

  Indicadore copyWith(
          {int? id,
          String? nome,
          String? descricao,
          double? peso,
          int? categoriaId,
          Value<int?> dimensaoId = const Value.absent()}) =>
      Indicadore(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        descricao: descricao ?? this.descricao,
        peso: peso ?? this.peso,
        categoriaId: categoriaId ?? this.categoriaId,
        dimensaoId: dimensaoId.present ? dimensaoId.value : this.dimensaoId,
      );
  Indicadore copyWithCompanion(IndicadoresCompanion data) {
    return Indicadore(
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
    return (StringBuffer('Indicadore(')
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
      (other is Indicadore &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.descricao == this.descricao &&
          other.peso == this.peso &&
          other.categoriaId == this.categoriaId &&
          other.dimensaoId == this.dimensaoId);
}

class IndicadoresCompanion extends UpdateCompanion<Indicadore> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> descricao;
  final Value<double> peso;
  final Value<int> categoriaId;
  final Value<int?> dimensaoId;
  const IndicadoresCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.descricao = const Value.absent(),
    this.peso = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.dimensaoId = const Value.absent(),
  });
  IndicadoresCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String descricao,
    this.peso = const Value.absent(),
    required int categoriaId,
    this.dimensaoId = const Value.absent(),
  })  : nome = Value(nome),
        descricao = Value(descricao),
        categoriaId = Value(categoriaId);
  static Insertable<Indicadore> custom({
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

  IndicadoresCompanion copyWith(
      {Value<int>? id,
      Value<String>? nome,
      Value<String>? descricao,
      Value<double>? peso,
      Value<int>? categoriaId,
      Value<int?>? dimensaoId}) {
    return IndicadoresCompanion(
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
    return (StringBuffer('IndicadoresCompanion(')
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

class $AvaliacoesTable extends Avaliacoes
    with TableInfo<$AvaliacoesTable, Avaliacoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvaliacoesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _familiaIdMeta =
      const VerificationMeta('familiaId');
  @override
  late final GeneratedColumn<int> familiaId = GeneratedColumn<int>(
      'familia_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES familias (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, data, avaliador, observacoes, familiaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avaliacoes';
  @override
  VerificationContext validateIntegrity(Insertable<Avaliacoe> instance,
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
  Avaliacoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Avaliacoe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data'])!,
      avaliador: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avaliador'])!,
      observacoes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observacoes']),
      familiaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}familia_id'])!,
    );
  }

  @override
  $AvaliacoesTable createAlias(String alias) {
    return $AvaliacoesTable(attachedDatabase, alias);
  }
}

class Avaliacoe extends DataClass implements Insertable<Avaliacoe> {
  final int id;
  final DateTime data;
  final String avaliador;
  final String? observacoes;
  final int familiaId;
  const Avaliacoe(
      {required this.id,
      required this.data,
      required this.avaliador,
      this.observacoes,
      required this.familiaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<DateTime>(data);
    map['avaliador'] = Variable<String>(avaliador);
    if (!nullToAbsent || observacoes != null) {
      map['observacoes'] = Variable<String>(observacoes);
    }
    map['familia_id'] = Variable<int>(familiaId);
    return map;
  }

  AvaliacoesCompanion toCompanion(bool nullToAbsent) {
    return AvaliacoesCompanion(
      id: Value(id),
      data: Value(data),
      avaliador: Value(avaliador),
      observacoes: observacoes == null && nullToAbsent
          ? const Value.absent()
          : Value(observacoes),
      familiaId: Value(familiaId),
    );
  }

  factory Avaliacoe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Avaliacoe(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<DateTime>(json['data']),
      avaliador: serializer.fromJson<String>(json['avaliador']),
      observacoes: serializer.fromJson<String?>(json['observacoes']),
      familiaId: serializer.fromJson<int>(json['familiaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<DateTime>(data),
      'avaliador': serializer.toJson<String>(avaliador),
      'observacoes': serializer.toJson<String?>(observacoes),
      'familiaId': serializer.toJson<int>(familiaId),
    };
  }

  Avaliacoe copyWith(
          {int? id,
          DateTime? data,
          String? avaliador,
          Value<String?> observacoes = const Value.absent(),
          int? familiaId}) =>
      Avaliacoe(
        id: id ?? this.id,
        data: data ?? this.data,
        avaliador: avaliador ?? this.avaliador,
        observacoes: observacoes.present ? observacoes.value : this.observacoes,
        familiaId: familiaId ?? this.familiaId,
      );
  Avaliacoe copyWithCompanion(AvaliacoesCompanion data) {
    return Avaliacoe(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      avaliador: data.avaliador.present ? data.avaliador.value : this.avaliador,
      observacoes:
          data.observacoes.present ? data.observacoes.value : this.observacoes,
      familiaId: data.familiaId.present ? data.familiaId.value : this.familiaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Avaliacoe(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('avaliador: $avaliador, ')
          ..write('observacoes: $observacoes, ')
          ..write('familiaId: $familiaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, avaliador, observacoes, familiaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Avaliacoe &&
          other.id == this.id &&
          other.data == this.data &&
          other.avaliador == this.avaliador &&
          other.observacoes == this.observacoes &&
          other.familiaId == this.familiaId);
}

class AvaliacoesCompanion extends UpdateCompanion<Avaliacoe> {
  final Value<int> id;
  final Value<DateTime> data;
  final Value<String> avaliador;
  final Value<String?> observacoes;
  final Value<int> familiaId;
  const AvaliacoesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.avaliador = const Value.absent(),
    this.observacoes = const Value.absent(),
    this.familiaId = const Value.absent(),
  });
  AvaliacoesCompanion.insert({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    required String avaliador,
    this.observacoes = const Value.absent(),
    required int familiaId,
  })  : avaliador = Value(avaliador),
        familiaId = Value(familiaId);
  static Insertable<Avaliacoe> custom({
    Expression<int>? id,
    Expression<DateTime>? data,
    Expression<String>? avaliador,
    Expression<String>? observacoes,
    Expression<int>? familiaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (avaliador != null) 'avaliador': avaliador,
      if (observacoes != null) 'observacoes': observacoes,
      if (familiaId != null) 'familia_id': familiaId,
    });
  }

  AvaliacoesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? data,
      Value<String>? avaliador,
      Value<String?>? observacoes,
      Value<int>? familiaId}) {
    return AvaliacoesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      avaliador: avaliador ?? this.avaliador,
      observacoes: observacoes ?? this.observacoes,
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
    if (avaliador.present) {
      map['avaliador'] = Variable<String>(avaliador.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    if (familiaId.present) {
      map['familia_id'] = Variable<int>(familiaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvaliacoesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('avaliador: $avaliador, ')
          ..write('observacoes: $observacoes, ')
          ..write('familiaId: $familiaId')
          ..write(')'))
        .toString();
  }
}

class $AvaliacaoItensTable extends AvaliacaoItens
    with TableInfo<$AvaliacaoItensTable, AvaliacaoIten> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvaliacaoItensTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES avaliacoes (id)'));
  static const VerificationMeta _indicadorIdMeta =
      const VerificationMeta('indicadorId');
  @override
  late final GeneratedColumn<int> indicadorId = GeneratedColumn<int>(
      'indicador_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES indicadores (id)'));
  static const VerificationMeta _praticaIdMeta =
      const VerificationMeta('praticaId');
  @override
  late final GeneratedColumn<int> praticaId = GeneratedColumn<int>(
      'pratica_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES praticas (id)'));
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
  static const String $name = 'avaliacao_itens';
  @override
  VerificationContext validateIntegrity(Insertable<AvaliacaoIten> instance,
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
  AvaliacaoIten map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvaliacaoIten(
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
  $AvaliacaoItensTable createAlias(String alias) {
    return $AvaliacaoItensTable(attachedDatabase, alias);
  }
}

class AvaliacaoIten extends DataClass implements Insertable<AvaliacaoIten> {
  final int id;
  final int avaliacaoId;
  final int indicadorId;

  /// When evaluating the special "Multidimensional" category, an item is
  /// tied to a particular agricultural practice. For other categories this
  /// column remains null.
  final int? praticaId;
  final int? valorLikert;
  final double? valorFuzzy;
  const AvaliacaoIten(
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

  AvaliacaoItensCompanion toCompanion(bool nullToAbsent) {
    return AvaliacaoItensCompanion(
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

  factory AvaliacaoIten.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvaliacaoIten(
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

  AvaliacaoIten copyWith(
          {int? id,
          int? avaliacaoId,
          int? indicadorId,
          Value<int?> praticaId = const Value.absent(),
          Value<int?> valorLikert = const Value.absent(),
          Value<double?> valorFuzzy = const Value.absent()}) =>
      AvaliacaoIten(
        id: id ?? this.id,
        avaliacaoId: avaliacaoId ?? this.avaliacaoId,
        indicadorId: indicadorId ?? this.indicadorId,
        praticaId: praticaId.present ? praticaId.value : this.praticaId,
        valorLikert: valorLikert.present ? valorLikert.value : this.valorLikert,
        valorFuzzy: valorFuzzy.present ? valorFuzzy.value : this.valorFuzzy,
      );
  AvaliacaoIten copyWithCompanion(AvaliacaoItensCompanion data) {
    return AvaliacaoIten(
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
    return (StringBuffer('AvaliacaoIten(')
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
      (other is AvaliacaoIten &&
          other.id == this.id &&
          other.avaliacaoId == this.avaliacaoId &&
          other.indicadorId == this.indicadorId &&
          other.praticaId == this.praticaId &&
          other.valorLikert == this.valorLikert &&
          other.valorFuzzy == this.valorFuzzy);
}

class AvaliacaoItensCompanion extends UpdateCompanion<AvaliacaoIten> {
  final Value<int> id;
  final Value<int> avaliacaoId;
  final Value<int> indicadorId;
  final Value<int?> praticaId;
  final Value<int?> valorLikert;
  final Value<double?> valorFuzzy;
  const AvaliacaoItensCompanion({
    this.id = const Value.absent(),
    this.avaliacaoId = const Value.absent(),
    this.indicadorId = const Value.absent(),
    this.praticaId = const Value.absent(),
    this.valorLikert = const Value.absent(),
    this.valorFuzzy = const Value.absent(),
  });
  AvaliacaoItensCompanion.insert({
    this.id = const Value.absent(),
    required int avaliacaoId,
    required int indicadorId,
    this.praticaId = const Value.absent(),
    this.valorLikert = const Value.absent(),
    this.valorFuzzy = const Value.absent(),
  })  : avaliacaoId = Value(avaliacaoId),
        indicadorId = Value(indicadorId);
  static Insertable<AvaliacaoIten> custom({
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

  AvaliacaoItensCompanion copyWith(
      {Value<int>? id,
      Value<int>? avaliacaoId,
      Value<int>? indicadorId,
      Value<int?>? praticaId,
      Value<int?>? valorLikert,
      Value<double?>? valorFuzzy}) {
    return AvaliacaoItensCompanion(
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
    return (StringBuffer('AvaliacaoItensCompanion(')
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
  late final $RegioesTable regioes = $RegioesTable(this);
  late final $FamiliasTable familias = $FamiliasTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $DimensoesTable dimensoes = $DimensoesTable(this);
  late final $PraticasTable praticas = $PraticasTable(this);
  late final $IndicadoresTable indicadores = $IndicadoresTable(this);
  late final $AvaliacoesTable avaliacoes = $AvaliacoesTable(this);
  late final $AvaliacaoItensTable avaliacaoItens = $AvaliacaoItensTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        regioes,
        familias,
        categorias,
        dimensoes,
        praticas,
        indicadores,
        avaliacoes,
        avaliacaoItens
      ];
}

typedef $$RegioesTableCreateCompanionBuilder = RegioesCompanion Function({
  Value<int> id,
  required String nome,
});
typedef $$RegioesTableUpdateCompanionBuilder = RegioesCompanion Function({
  Value<int> id,
  Value<String> nome,
});

class $$RegioesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegioesTable,
    Regioe,
    $$RegioesTableFilterComposer,
    $$RegioesTableOrderingComposer,
    $$RegioesTableCreateCompanionBuilder,
    $$RegioesTableUpdateCompanionBuilder> {
  $$RegioesTableTableManager(_$AppDatabase db, $RegioesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RegioesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RegioesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
          }) =>
              RegioesCompanion(
            id: id,
            nome: nome,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
          }) =>
              RegioesCompanion.insert(
            id: id,
            nome: nome,
          ),
        ));
}

class $$RegioesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RegioesTable> {
  $$RegioesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter familiasRefs(
      ComposableFilter Function($$FamiliasTableFilterComposer f) f) {
    final $$FamiliasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.familias,
        getReferencedColumn: (t) => t.regiaoId,
        builder: (joinBuilder, parentComposers) =>
            $$FamiliasTableFilterComposer(ComposerState(
                $state.db, $state.db.familias, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$RegioesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RegioesTable> {
  $$RegioesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FamiliasTableCreateCompanionBuilder = FamiliasCompanion Function({
  Value<int> id,
  required String nomeResponsavel,
  required String telefone,
  required String endereco,
  required int regiaoId,
});
typedef $$FamiliasTableUpdateCompanionBuilder = FamiliasCompanion Function({
  Value<int> id,
  Value<String> nomeResponsavel,
  Value<String> telefone,
  Value<String> endereco,
  Value<int> regiaoId,
});

class $$FamiliasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamiliasTable,
    Familia,
    $$FamiliasTableFilterComposer,
    $$FamiliasTableOrderingComposer,
    $$FamiliasTableCreateCompanionBuilder,
    $$FamiliasTableUpdateCompanionBuilder> {
  $$FamiliasTableTableManager(_$AppDatabase db, $FamiliasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FamiliasTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FamiliasTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nomeResponsavel = const Value.absent(),
            Value<String> telefone = const Value.absent(),
            Value<String> endereco = const Value.absent(),
            Value<int> regiaoId = const Value.absent(),
          }) =>
              FamiliasCompanion(
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
              FamiliasCompanion.insert(
            id: id,
            nomeResponsavel: nomeResponsavel,
            telefone: telefone,
            endereco: endereco,
            regiaoId: regiaoId,
          ),
        ));
}

class $$FamiliasTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FamiliasTable> {
  $$FamiliasTableFilterComposer(super.$state);
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

  $$RegioesTableFilterComposer get regiaoId {
    final $$RegioesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regiaoId,
        referencedTable: $state.db.regioes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$RegioesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.regioes, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacoesRefs(
      ComposableFilter Function($$AvaliacoesTableFilterComposer f) f) {
    final $$AvaliacoesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacoes,
        getReferencedColumn: (t) => t.familiaId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacoesTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacoes, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$FamiliasTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FamiliasTable> {
  $$FamiliasTableOrderingComposer(super.$state);
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

  $$RegioesTableOrderingComposer get regiaoId {
    final $$RegioesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regiaoId,
        referencedTable: $state.db.regioes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RegioesTableOrderingComposer(ComposerState(
                $state.db, $state.db.regioes, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nome,
  Value<String?> descricao,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String?> descricao,
});

class $$CategoriasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriasTable,
    Categoria,
    $$CategoriasTableFilterComposer,
    $$CategoriasTableOrderingComposer,
    $$CategoriasTableCreateCompanionBuilder,
    $$CategoriasTableUpdateCompanionBuilder> {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriasTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriasTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> descricao = const Value.absent(),
          }) =>
              CategoriasCompanion(
            id: id,
            nome: nome,
            descricao: descricao,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            Value<String?> descricao = const Value.absent(),
          }) =>
              CategoriasCompanion.insert(
            id: id,
            nome: nome,
            descricao: descricao,
          ),
        ));
}

class $$CategoriasTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer(super.$state);
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

  ComposableFilter dimensoesRefs(
      ComposableFilter Function($$DimensoesTableFilterComposer f) f) {
    final $$DimensoesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.dimensoes,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) =>
            $$DimensoesTableFilterComposer(ComposerState(
                $state.db, $state.db.dimensoes, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter praticasRefs(
      ComposableFilter Function($$PraticasTableFilterComposer f) f) {
    final $$PraticasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.praticas,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) =>
            $$PraticasTableFilterComposer(ComposerState(
                $state.db, $state.db.praticas, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter indicadoresRefs(
      ComposableFilter Function($$IndicadoresTableFilterComposer f) f) {
    final $$IndicadoresTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.indicadores,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadoresTableFilterComposer(ComposerState($state.db,
                $state.db.indicadores, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer(super.$state);
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

typedef $$DimensoesTableCreateCompanionBuilder = DimensoesCompanion Function({
  Value<int> id,
  required String nome,
  required int categoriaId,
});
typedef $$DimensoesTableUpdateCompanionBuilder = DimensoesCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> categoriaId,
});

class $$DimensoesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DimensoesTable,
    Dimensoe,
    $$DimensoesTableFilterComposer,
    $$DimensoesTableOrderingComposer,
    $$DimensoesTableCreateCompanionBuilder,
    $$DimensoesTableUpdateCompanionBuilder> {
  $$DimensoesTableTableManager(_$AppDatabase db, $DimensoesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DimensoesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DimensoesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
          }) =>
              DimensoesCompanion(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            required int categoriaId,
          }) =>
              DimensoesCompanion.insert(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
        ));
}

class $$DimensoesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DimensoesTable> {
  $$DimensoesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableFilterComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter indicadoresRefs(
      ComposableFilter Function($$IndicadoresTableFilterComposer f) f) {
    final $$IndicadoresTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.indicadores,
        getReferencedColumn: (t) => t.dimensaoId,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadoresTableFilterComposer(ComposerState($state.db,
                $state.db.indicadores, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$DimensoesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DimensoesTable> {
  $$DimensoesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableOrderingComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$PraticasTableCreateCompanionBuilder = PraticasCompanion Function({
  Value<int> id,
  required String nome,
  required int categoriaId,
});
typedef $$PraticasTableUpdateCompanionBuilder = PraticasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> categoriaId,
});

class $$PraticasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PraticasTable,
    Pratica,
    $$PraticasTableFilterComposer,
    $$PraticasTableOrderingComposer,
    $$PraticasTableCreateCompanionBuilder,
    $$PraticasTableUpdateCompanionBuilder> {
  $$PraticasTableTableManager(_$AppDatabase db, $PraticasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PraticasTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PraticasTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
          }) =>
              PraticasCompanion(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            required int categoriaId,
          }) =>
              PraticasCompanion.insert(
            id: id,
            nome: nome,
            categoriaId: categoriaId,
          ),
        ));
}

class $$PraticasTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PraticasTable> {
  $$PraticasTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableFilterComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItensRefs(
      ComposableFilter Function($$AvaliacaoItensTableFilterComposer f) f) {
    final $$AvaliacaoItensTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItens,
        getReferencedColumn: (t) => t.praticaId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItensTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItens, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$PraticasTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PraticasTable> {
  $$PraticasTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableOrderingComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$IndicadoresTableCreateCompanionBuilder = IndicadoresCompanion
    Function({
  Value<int> id,
  required String nome,
  required String descricao,
  Value<double> peso,
  required int categoriaId,
  Value<int?> dimensaoId,
});
typedef $$IndicadoresTableUpdateCompanionBuilder = IndicadoresCompanion
    Function({
  Value<int> id,
  Value<String> nome,
  Value<String> descricao,
  Value<double> peso,
  Value<int> categoriaId,
  Value<int?> dimensaoId,
});

class $$IndicadoresTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IndicadoresTable,
    Indicadore,
    $$IndicadoresTableFilterComposer,
    $$IndicadoresTableOrderingComposer,
    $$IndicadoresTableCreateCompanionBuilder,
    $$IndicadoresTableUpdateCompanionBuilder> {
  $$IndicadoresTableTableManager(_$AppDatabase db, $IndicadoresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IndicadoresTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IndicadoresTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<double> peso = const Value.absent(),
            Value<int> categoriaId = const Value.absent(),
            Value<int?> dimensaoId = const Value.absent(),
          }) =>
              IndicadoresCompanion(
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
              IndicadoresCompanion.insert(
            id: id,
            nome: nome,
            descricao: descricao,
            peso: peso,
            categoriaId: categoriaId,
            dimensaoId: dimensaoId,
          ),
        ));
}

class $$IndicadoresTableFilterComposer
    extends FilterComposer<_$AppDatabase, $IndicadoresTable> {
  $$IndicadoresTableFilterComposer(super.$state);
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

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableFilterComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }

  $$DimensoesTableFilterComposer get dimensaoId {
    final $$DimensoesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensaoId,
        referencedTable: $state.db.dimensoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DimensoesTableFilterComposer(ComposerState(
                $state.db, $state.db.dimensoes, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItensRefs(
      ComposableFilter Function($$AvaliacaoItensTableFilterComposer f) f) {
    final $$AvaliacaoItensTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItens,
        getReferencedColumn: (t) => t.indicadorId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItensTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItens, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$IndicadoresTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $IndicadoresTable> {
  $$IndicadoresTableOrderingComposer(super.$state);
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

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $state.db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriasTableOrderingComposer(ComposerState($state.db,
                $state.db.categorias, joinBuilder, parentComposers)));
    return composer;
  }

  $$DimensoesTableOrderingComposer get dimensaoId {
    final $$DimensoesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensaoId,
        referencedTable: $state.db.dimensoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DimensoesTableOrderingComposer(ComposerState(
                $state.db, $state.db.dimensoes, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AvaliacoesTableCreateCompanionBuilder = AvaliacoesCompanion Function({
  Value<int> id,
  Value<DateTime> data,
  required String avaliador,
  Value<String?> observacoes,
  required int familiaId,
});
typedef $$AvaliacoesTableUpdateCompanionBuilder = AvaliacoesCompanion Function({
  Value<int> id,
  Value<DateTime> data,
  Value<String> avaliador,
  Value<String?> observacoes,
  Value<int> familiaId,
});

class $$AvaliacoesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AvaliacoesTable,
    Avaliacoe,
    $$AvaliacoesTableFilterComposer,
    $$AvaliacoesTableOrderingComposer,
    $$AvaliacoesTableCreateCompanionBuilder,
    $$AvaliacoesTableUpdateCompanionBuilder> {
  $$AvaliacoesTableTableManager(_$AppDatabase db, $AvaliacoesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AvaliacoesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AvaliacoesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> data = const Value.absent(),
            Value<String> avaliador = const Value.absent(),
            Value<String?> observacoes = const Value.absent(),
            Value<int> familiaId = const Value.absent(),
          }) =>
              AvaliacoesCompanion(
            id: id,
            data: data,
            avaliador: avaliador,
            observacoes: observacoes,
            familiaId: familiaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> data = const Value.absent(),
            required String avaliador,
            Value<String?> observacoes = const Value.absent(),
            required int familiaId,
          }) =>
              AvaliacoesCompanion.insert(
            id: id,
            data: data,
            avaliador: avaliador,
            observacoes: observacoes,
            familiaId: familiaId,
          ),
        ));
}

class $$AvaliacoesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AvaliacoesTable> {
  $$AvaliacoesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get data => $state.composableBuilder(
      column: $state.table.data,
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

  $$FamiliasTableFilterComposer get familiaId {
    final $$FamiliasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.familiaId,
        referencedTable: $state.db.familias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FamiliasTableFilterComposer(ComposerState(
                $state.db, $state.db.familias, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter avaliacaoItensRefs(
      ComposableFilter Function($$AvaliacaoItensTableFilterComposer f) f) {
    final $$AvaliacaoItensTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.avaliacaoItens,
        getReferencedColumn: (t) => t.avaliacaoId,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacaoItensTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacaoItens, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AvaliacoesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AvaliacoesTable> {
  $$AvaliacoesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get data => $state.composableBuilder(
      column: $state.table.data,
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

  $$FamiliasTableOrderingComposer get familiaId {
    final $$FamiliasTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.familiaId,
        referencedTable: $state.db.familias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FamiliasTableOrderingComposer(ComposerState(
                $state.db, $state.db.familias, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AvaliacaoItensTableCreateCompanionBuilder = AvaliacaoItensCompanion
    Function({
  Value<int> id,
  required int avaliacaoId,
  required int indicadorId,
  Value<int?> praticaId,
  Value<int?> valorLikert,
  Value<double?> valorFuzzy,
});
typedef $$AvaliacaoItensTableUpdateCompanionBuilder = AvaliacaoItensCompanion
    Function({
  Value<int> id,
  Value<int> avaliacaoId,
  Value<int> indicadorId,
  Value<int?> praticaId,
  Value<int?> valorLikert,
  Value<double?> valorFuzzy,
});

class $$AvaliacaoItensTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AvaliacaoItensTable,
    AvaliacaoIten,
    $$AvaliacaoItensTableFilterComposer,
    $$AvaliacaoItensTableOrderingComposer,
    $$AvaliacaoItensTableCreateCompanionBuilder,
    $$AvaliacaoItensTableUpdateCompanionBuilder> {
  $$AvaliacaoItensTableTableManager(
      _$AppDatabase db, $AvaliacaoItensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AvaliacaoItensTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AvaliacaoItensTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> avaliacaoId = const Value.absent(),
            Value<int> indicadorId = const Value.absent(),
            Value<int?> praticaId = const Value.absent(),
            Value<int?> valorLikert = const Value.absent(),
            Value<double?> valorFuzzy = const Value.absent(),
          }) =>
              AvaliacaoItensCompanion(
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
              AvaliacaoItensCompanion.insert(
            id: id,
            avaliacaoId: avaliacaoId,
            indicadorId: indicadorId,
            praticaId: praticaId,
            valorLikert: valorLikert,
            valorFuzzy: valorFuzzy,
          ),
        ));
}

class $$AvaliacaoItensTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AvaliacaoItensTable> {
  $$AvaliacaoItensTableFilterComposer(super.$state);
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

  $$AvaliacoesTableFilterComposer get avaliacaoId {
    final $$AvaliacoesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avaliacaoId,
        referencedTable: $state.db.avaliacoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacoesTableFilterComposer(ComposerState($state.db,
                $state.db.avaliacoes, joinBuilder, parentComposers)));
    return composer;
  }

  $$IndicadoresTableFilterComposer get indicadorId {
    final $$IndicadoresTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.indicadorId,
        referencedTable: $state.db.indicadores,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadoresTableFilterComposer(ComposerState($state.db,
                $state.db.indicadores, joinBuilder, parentComposers)));
    return composer;
  }

  $$PraticasTableFilterComposer get praticaId {
    final $$PraticasTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.praticaId,
        referencedTable: $state.db.praticas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PraticasTableFilterComposer(ComposerState(
                $state.db, $state.db.praticas, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$AvaliacaoItensTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AvaliacaoItensTable> {
  $$AvaliacaoItensTableOrderingComposer(super.$state);
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

  $$AvaliacoesTableOrderingComposer get avaliacaoId {
    final $$AvaliacoesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avaliacaoId,
        referencedTable: $state.db.avaliacoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AvaliacoesTableOrderingComposer(ComposerState($state.db,
                $state.db.avaliacoes, joinBuilder, parentComposers)));
    return composer;
  }

  $$IndicadoresTableOrderingComposer get indicadorId {
    final $$IndicadoresTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.indicadorId,
        referencedTable: $state.db.indicadores,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$IndicadoresTableOrderingComposer(ComposerState($state.db,
                $state.db.indicadores, joinBuilder, parentComposers)));
    return composer;
  }

  $$PraticasTableOrderingComposer get praticaId {
    final $$PraticasTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.praticaId,
        referencedTable: $state.db.praticas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PraticasTableOrderingComposer(ComposerState(
                $state.db, $state.db.praticas, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RegioesTableTableManager get regioes =>
      $$RegioesTableTableManager(_db, _db.regioes);
  $$FamiliasTableTableManager get familias =>
      $$FamiliasTableTableManager(_db, _db.familias);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$DimensoesTableTableManager get dimensoes =>
      $$DimensoesTableTableManager(_db, _db.dimensoes);
  $$PraticasTableTableManager get praticas =>
      $$PraticasTableTableManager(_db, _db.praticas);
  $$IndicadoresTableTableManager get indicadores =>
      $$IndicadoresTableTableManager(_db, _db.indicadores);
  $$AvaliacoesTableTableManager get avaliacoes =>
      $$AvaliacoesTableTableManager(_db, _db.avaliacoes);
  $$AvaliacaoItensTableTableManager get avaliacaoItens =>
      $$AvaliacaoItensTableTableManager(_db, _db.avaliacaoItens);
}
