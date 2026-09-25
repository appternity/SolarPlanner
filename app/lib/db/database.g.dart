// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SolarModulesTable extends SolarModules
    with TableInfo<$SolarModulesTable, SolarModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolarModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pMaxWMeta = const VerificationMeta('pMaxW');
  @override
  late final GeneratedColumn<double> pMaxW = GeneratedColumn<double>(
    'p_max_w',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vmpMeta = const VerificationMeta('vmp');
  @override
  late final GeneratedColumn<double> vmp = GeneratedColumn<double>(
    'vmp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _impMeta = const VerificationMeta('imp');
  @override
  late final GeneratedColumn<double> imp = GeneratedColumn<double>(
    'imp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vocMeta = const VerificationMeta('voc');
  @override
  late final GeneratedColumn<double> voc = GeneratedColumn<double>(
    'voc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iscMeta = const VerificationMeta('isc');
  @override
  late final GeneratedColumn<double> isc = GeneratedColumn<double>(
    'isc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocTempCoeffMeta = const VerificationMeta(
    'vocTempCoeff',
  );
  @override
  late final GeneratedColumn<double> vocTempCoeff = GeneratedColumn<double>(
    'voc_temp_coeff',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(-0.3),
  );
  static const VerificationMeta _widthMmMeta = const VerificationMeta(
    'widthMm',
  );
  @override
  late final GeneratedColumn<double> widthMm = GeneratedColumn<double>(
    'width_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMmMeta = const VerificationMeta(
    'heightMm',
  );
  @override
  late final GeneratedColumn<double> heightMm = GeneratedColumn<double>(
    'height_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thicknessMmMeta = const VerificationMeta(
    'thicknessMm',
  );
  @override
  late final GeneratedColumn<double> thicknessMm = GeneratedColumn<double>(
    'thickness_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameClassMeta = const VerificationMeta(
    'frameClass',
  );
  @override
  late final GeneratedColumn<String> frameClass = GeneratedColumn<String>(
    'frame_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    manufacturer,
    pMaxW,
    vmp,
    imp,
    voc,
    isc,
    vocTempCoeff,
    widthMm,
    heightMm,
    thicknessMm,
    weightKg,
    frameClass,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solar_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<SolarModule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('p_max_w')) {
      context.handle(
        _pMaxWMeta,
        pMaxW.isAcceptableOrUnknown(data['p_max_w']!, _pMaxWMeta),
      );
    } else if (isInserting) {
      context.missing(_pMaxWMeta);
    }
    if (data.containsKey('vmp')) {
      context.handle(
        _vmpMeta,
        vmp.isAcceptableOrUnknown(data['vmp']!, _vmpMeta),
      );
    }
    if (data.containsKey('imp')) {
      context.handle(
        _impMeta,
        imp.isAcceptableOrUnknown(data['imp']!, _impMeta),
      );
    }
    if (data.containsKey('voc')) {
      context.handle(
        _vocMeta,
        voc.isAcceptableOrUnknown(data['voc']!, _vocMeta),
      );
    } else if (isInserting) {
      context.missing(_vocMeta);
    }
    if (data.containsKey('isc')) {
      context.handle(
        _iscMeta,
        isc.isAcceptableOrUnknown(data['isc']!, _iscMeta),
      );
    } else if (isInserting) {
      context.missing(_iscMeta);
    }
    if (data.containsKey('voc_temp_coeff')) {
      context.handle(
        _vocTempCoeffMeta,
        vocTempCoeff.isAcceptableOrUnknown(
          data['voc_temp_coeff']!,
          _vocTempCoeffMeta,
        ),
      );
    }
    if (data.containsKey('width_mm')) {
      context.handle(
        _widthMmMeta,
        widthMm.isAcceptableOrUnknown(data['width_mm']!, _widthMmMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMmMeta);
    }
    if (data.containsKey('height_mm')) {
      context.handle(
        _heightMmMeta,
        heightMm.isAcceptableOrUnknown(data['height_mm']!, _heightMmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMmMeta);
    }
    if (data.containsKey('thickness_mm')) {
      context.handle(
        _thicknessMmMeta,
        thicknessMm.isAcceptableOrUnknown(
          data['thickness_mm']!,
          _thicknessMmMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('frame_class')) {
      context.handle(
        _frameClassMeta,
        frameClass.isAcceptableOrUnknown(data['frame_class']!, _frameClassMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SolarModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SolarModule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      pMaxW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}p_max_w'],
      )!,
      vmp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vmp'],
      )!,
      imp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}imp'],
      )!,
      voc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voc'],
      )!,
      isc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}isc'],
      )!,
      vocTempCoeff: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voc_temp_coeff'],
      )!,
      widthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_mm'],
      )!,
      heightMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_mm'],
      )!,
      thicknessMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thickness_mm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      frameClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_class'],
      ),
    );
  }

  @override
  $SolarModulesTable createAlias(String alias) {
    return $SolarModulesTable(attachedDatabase, alias);
  }
}

class SolarModule extends DataClass implements Insertable<SolarModule> {
  final int id;
  final String name;
  final String manufacturer;

  /// Rated output in Watt (Pmax at STC).
  final double pMaxW;
  final double vmp;
  final double imp;

  /// Open-circuit voltage in Volt.
  final double voc;

  /// Short-circuit current in Ampere.
  final double isc;

  /// Temperature coefficient of Voc in %/K (typically negative).
  final double vocTempCoeff;
  final double widthMm;
  final double heightMm;
  final double thicknessMm;
  final double? weightKg;

  /// IEC protection class of the frame: 'I' (metallic frame, must be
  /// earthed) or 'II' (double insulated, no earthing needed). Null = unknown,
  /// treated as 'I' (conservative) by the VDE checks.
  final String? frameClass;
  const SolarModule({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.pMaxW,
    required this.vmp,
    required this.imp,
    required this.voc,
    required this.isc,
    required this.vocTempCoeff,
    required this.widthMm,
    required this.heightMm,
    required this.thicknessMm,
    this.weightKg,
    this.frameClass,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['p_max_w'] = Variable<double>(pMaxW);
    map['vmp'] = Variable<double>(vmp);
    map['imp'] = Variable<double>(imp);
    map['voc'] = Variable<double>(voc);
    map['isc'] = Variable<double>(isc);
    map['voc_temp_coeff'] = Variable<double>(vocTempCoeff);
    map['width_mm'] = Variable<double>(widthMm);
    map['height_mm'] = Variable<double>(heightMm);
    map['thickness_mm'] = Variable<double>(thicknessMm);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || frameClass != null) {
      map['frame_class'] = Variable<String>(frameClass);
    }
    return map;
  }

  SolarModulesCompanion toCompanion(bool nullToAbsent) {
    return SolarModulesCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: Value(manufacturer),
      pMaxW: Value(pMaxW),
      vmp: Value(vmp),
      imp: Value(imp),
      voc: Value(voc),
      isc: Value(isc),
      vocTempCoeff: Value(vocTempCoeff),
      widthMm: Value(widthMm),
      heightMm: Value(heightMm),
      thicknessMm: Value(thicknessMm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      frameClass: frameClass == null && nullToAbsent
          ? const Value.absent()
          : Value(frameClass),
    );
  }

  factory SolarModule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SolarModule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      pMaxW: serializer.fromJson<double>(json['pMaxW']),
      vmp: serializer.fromJson<double>(json['vmp']),
      imp: serializer.fromJson<double>(json['imp']),
      voc: serializer.fromJson<double>(json['voc']),
      isc: serializer.fromJson<double>(json['isc']),
      vocTempCoeff: serializer.fromJson<double>(json['vocTempCoeff']),
      widthMm: serializer.fromJson<double>(json['widthMm']),
      heightMm: serializer.fromJson<double>(json['heightMm']),
      thicknessMm: serializer.fromJson<double>(json['thicknessMm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      frameClass: serializer.fromJson<String?>(json['frameClass']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'pMaxW': serializer.toJson<double>(pMaxW),
      'vmp': serializer.toJson<double>(vmp),
      'imp': serializer.toJson<double>(imp),
      'voc': serializer.toJson<double>(voc),
      'isc': serializer.toJson<double>(isc),
      'vocTempCoeff': serializer.toJson<double>(vocTempCoeff),
      'widthMm': serializer.toJson<double>(widthMm),
      'heightMm': serializer.toJson<double>(heightMm),
      'thicknessMm': serializer.toJson<double>(thicknessMm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'frameClass': serializer.toJson<String?>(frameClass),
    };
  }

  SolarModule copyWith({
    int? id,
    String? name,
    String? manufacturer,
    double? pMaxW,
    double? vmp,
    double? imp,
    double? voc,
    double? isc,
    double? vocTempCoeff,
    double? widthMm,
    double? heightMm,
    double? thicknessMm,
    Value<double?> weightKg = const Value.absent(),
    Value<String?> frameClass = const Value.absent(),
  }) => SolarModule(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    pMaxW: pMaxW ?? this.pMaxW,
    vmp: vmp ?? this.vmp,
    imp: imp ?? this.imp,
    voc: voc ?? this.voc,
    isc: isc ?? this.isc,
    vocTempCoeff: vocTempCoeff ?? this.vocTempCoeff,
    widthMm: widthMm ?? this.widthMm,
    heightMm: heightMm ?? this.heightMm,
    thicknessMm: thicknessMm ?? this.thicknessMm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    frameClass: frameClass.present ? frameClass.value : this.frameClass,
  );
  SolarModule copyWithCompanion(SolarModulesCompanion data) {
    return SolarModule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      pMaxW: data.pMaxW.present ? data.pMaxW.value : this.pMaxW,
      vmp: data.vmp.present ? data.vmp.value : this.vmp,
      imp: data.imp.present ? data.imp.value : this.imp,
      voc: data.voc.present ? data.voc.value : this.voc,
      isc: data.isc.present ? data.isc.value : this.isc,
      vocTempCoeff: data.vocTempCoeff.present
          ? data.vocTempCoeff.value
          : this.vocTempCoeff,
      widthMm: data.widthMm.present ? data.widthMm.value : this.widthMm,
      heightMm: data.heightMm.present ? data.heightMm.value : this.heightMm,
      thicknessMm: data.thicknessMm.present
          ? data.thicknessMm.value
          : this.thicknessMm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      frameClass: data.frameClass.present
          ? data.frameClass.value
          : this.frameClass,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SolarModule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('pMaxW: $pMaxW, ')
          ..write('vmp: $vmp, ')
          ..write('imp: $imp, ')
          ..write('voc: $voc, ')
          ..write('isc: $isc, ')
          ..write('vocTempCoeff: $vocTempCoeff, ')
          ..write('widthMm: $widthMm, ')
          ..write('heightMm: $heightMm, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('weightKg: $weightKg, ')
          ..write('frameClass: $frameClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    pMaxW,
    vmp,
    imp,
    voc,
    isc,
    vocTempCoeff,
    widthMm,
    heightMm,
    thicknessMm,
    weightKg,
    frameClass,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolarModule &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.pMaxW == this.pMaxW &&
          other.vmp == this.vmp &&
          other.imp == this.imp &&
          other.voc == this.voc &&
          other.isc == this.isc &&
          other.vocTempCoeff == this.vocTempCoeff &&
          other.widthMm == this.widthMm &&
          other.heightMm == this.heightMm &&
          other.thicknessMm == this.thicknessMm &&
          other.weightKg == this.weightKg &&
          other.frameClass == this.frameClass);
}

class SolarModulesCompanion extends UpdateCompanion<SolarModule> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> manufacturer;
  final Value<double> pMaxW;
  final Value<double> vmp;
  final Value<double> imp;
  final Value<double> voc;
  final Value<double> isc;
  final Value<double> vocTempCoeff;
  final Value<double> widthMm;
  final Value<double> heightMm;
  final Value<double> thicknessMm;
  final Value<double?> weightKg;
  final Value<String?> frameClass;
  const SolarModulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.pMaxW = const Value.absent(),
    this.vmp = const Value.absent(),
    this.imp = const Value.absent(),
    this.voc = const Value.absent(),
    this.isc = const Value.absent(),
    this.vocTempCoeff = const Value.absent(),
    this.widthMm = const Value.absent(),
    this.heightMm = const Value.absent(),
    this.thicknessMm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.frameClass = const Value.absent(),
  });
  SolarModulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.manufacturer = const Value.absent(),
    required double pMaxW,
    this.vmp = const Value.absent(),
    this.imp = const Value.absent(),
    required double voc,
    required double isc,
    this.vocTempCoeff = const Value.absent(),
    required double widthMm,
    required double heightMm,
    this.thicknessMm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.frameClass = const Value.absent(),
  }) : name = Value(name),
       pMaxW = Value(pMaxW),
       voc = Value(voc),
       isc = Value(isc),
       widthMm = Value(widthMm),
       heightMm = Value(heightMm);
  static Insertable<SolarModule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<double>? pMaxW,
    Expression<double>? vmp,
    Expression<double>? imp,
    Expression<double>? voc,
    Expression<double>? isc,
    Expression<double>? vocTempCoeff,
    Expression<double>? widthMm,
    Expression<double>? heightMm,
    Expression<double>? thicknessMm,
    Expression<double>? weightKg,
    Expression<String>? frameClass,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (pMaxW != null) 'p_max_w': pMaxW,
      if (vmp != null) 'vmp': vmp,
      if (imp != null) 'imp': imp,
      if (voc != null) 'voc': voc,
      if (isc != null) 'isc': isc,
      if (vocTempCoeff != null) 'voc_temp_coeff': vocTempCoeff,
      if (widthMm != null) 'width_mm': widthMm,
      if (heightMm != null) 'height_mm': heightMm,
      if (thicknessMm != null) 'thickness_mm': thicknessMm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (frameClass != null) 'frame_class': frameClass,
    });
  }

  SolarModulesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? manufacturer,
    Value<double>? pMaxW,
    Value<double>? vmp,
    Value<double>? imp,
    Value<double>? voc,
    Value<double>? isc,
    Value<double>? vocTempCoeff,
    Value<double>? widthMm,
    Value<double>? heightMm,
    Value<double>? thicknessMm,
    Value<double?>? weightKg,
    Value<String?>? frameClass,
  }) {
    return SolarModulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      pMaxW: pMaxW ?? this.pMaxW,
      vmp: vmp ?? this.vmp,
      imp: imp ?? this.imp,
      voc: voc ?? this.voc,
      isc: isc ?? this.isc,
      vocTempCoeff: vocTempCoeff ?? this.vocTempCoeff,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      thicknessMm: thicknessMm ?? this.thicknessMm,
      weightKg: weightKg ?? this.weightKg,
      frameClass: frameClass ?? this.frameClass,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (pMaxW.present) {
      map['p_max_w'] = Variable<double>(pMaxW.value);
    }
    if (vmp.present) {
      map['vmp'] = Variable<double>(vmp.value);
    }
    if (imp.present) {
      map['imp'] = Variable<double>(imp.value);
    }
    if (voc.present) {
      map['voc'] = Variable<double>(voc.value);
    }
    if (isc.present) {
      map['isc'] = Variable<double>(isc.value);
    }
    if (vocTempCoeff.present) {
      map['voc_temp_coeff'] = Variable<double>(vocTempCoeff.value);
    }
    if (widthMm.present) {
      map['width_mm'] = Variable<double>(widthMm.value);
    }
    if (heightMm.present) {
      map['height_mm'] = Variable<double>(heightMm.value);
    }
    if (thicknessMm.present) {
      map['thickness_mm'] = Variable<double>(thicknessMm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (frameClass.present) {
      map['frame_class'] = Variable<String>(frameClass.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolarModulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('pMaxW: $pMaxW, ')
          ..write('vmp: $vmp, ')
          ..write('imp: $imp, ')
          ..write('voc: $voc, ')
          ..write('isc: $isc, ')
          ..write('vocTempCoeff: $vocTempCoeff, ')
          ..write('widthMm: $widthMm, ')
          ..write('heightMm: $heightMm, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('weightKg: $weightKg, ')
          ..write('frameClass: $frameClass')
          ..write(')'))
        .toString();
  }
}

class $InvertersTable extends Inverters
    with TableInfo<$InvertersTable, Inverter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvertersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _powerKwMeta = const VerificationMeta(
    'powerKw',
  );
  @override
  late final GeneratedColumn<double> powerKw = GeneratedColumn<double>(
    'power_kw',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mppCountMeta = const VerificationMeta(
    'mppCount',
  );
  @override
  late final GeneratedColumn<int> mppCount = GeneratedColumn<int>(
    'mpp_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _maxStringsPerMppMeta = const VerificationMeta(
    'maxStringsPerMpp',
  );
  @override
  late final GeneratedColumn<int> maxStringsPerMpp = GeneratedColumn<int>(
    'max_strings_per_mpp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _minInputVoltageMeta = const VerificationMeta(
    'minInputVoltage',
  );
  @override
  late final GeneratedColumn<double> minInputVoltage = GeneratedColumn<double>(
    'min_input_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxInputVoltageMeta = const VerificationMeta(
    'maxInputVoltage',
  );
  @override
  late final GeneratedColumn<double> maxInputVoltage = GeneratedColumn<double>(
    'max_input_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxInputCurrentPerMppMeta =
      const VerificationMeta('maxInputCurrentPerMpp');
  @override
  late final GeneratedColumn<double> maxInputCurrentPerMpp =
      GeneratedColumn<double>(
        'max_input_current_per_mpp',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _maxShortCircuitCurrentPerMppMeta =
      const VerificationMeta('maxShortCircuitCurrentPerMpp');
  @override
  late final GeneratedColumn<double> maxShortCircuitCurrentPerMpp =
      GeneratedColumn<double>(
        'max_short_circuit_current_per_mpp',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _acPhasesMeta = const VerificationMeta(
    'acPhases',
  );
  @override
  late final GeneratedColumn<int> acPhases = GeneratedColumn<int>(
    'ac_phases',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _dcVoltageClassMeta = const VerificationMeta(
    'dcVoltageClass',
  );
  @override
  late final GeneratedColumn<String> dcVoltageClass = GeneratedColumn<String>(
    'dc_voltage_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iOutAMeta = const VerificationMeta('iOutA');
  @override
  late final GeneratedColumn<double> iOutA = GeneratedColumn<double>(
    'i_out_a',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mcbAMeta = const VerificationMeta('mcbA');
  @override
  late final GeneratedColumn<int> mcbA = GeneratedColumn<int>(
    'mcb_a',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mppMinVoltageMeta = const VerificationMeta(
    'mppMinVoltage',
  );
  @override
  late final GeneratedColumn<double> mppMinVoltage = GeneratedColumn<double>(
    'mpp_min_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mppMaxVoltageMeta = const VerificationMeta(
    'mppMaxVoltage',
  );
  @override
  late final GeneratedColumn<double> mppMaxVoltage = GeneratedColumn<double>(
    'mpp_max_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qKvarMeta = const VerificationMeta('qKvar');
  @override
  late final GeneratedColumn<double> qKvar = GeneratedColumn<double>(
    'q_kvar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHybridMeta = const VerificationMeta(
    'isHybrid',
  );
  @override
  late final GeneratedColumn<bool> isHybrid = GeneratedColumn<bool>(
    'is_hybrid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hybrid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    manufacturer,
    powerKw,
    mppCount,
    maxStringsPerMpp,
    minInputVoltage,
    maxInputVoltage,
    maxInputCurrentPerMpp,
    maxShortCircuitCurrentPerMpp,
    acPhases,
    dcVoltageClass,
    iOutA,
    mcbA,
    mppMinVoltage,
    mppMaxVoltage,
    qKvar,
    isHybrid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inverters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Inverter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('power_kw')) {
      context.handle(
        _powerKwMeta,
        powerKw.isAcceptableOrUnknown(data['power_kw']!, _powerKwMeta),
      );
    } else if (isInserting) {
      context.missing(_powerKwMeta);
    }
    if (data.containsKey('mpp_count')) {
      context.handle(
        _mppCountMeta,
        mppCount.isAcceptableOrUnknown(data['mpp_count']!, _mppCountMeta),
      );
    }
    if (data.containsKey('max_strings_per_mpp')) {
      context.handle(
        _maxStringsPerMppMeta,
        maxStringsPerMpp.isAcceptableOrUnknown(
          data['max_strings_per_mpp']!,
          _maxStringsPerMppMeta,
        ),
      );
    }
    if (data.containsKey('min_input_voltage')) {
      context.handle(
        _minInputVoltageMeta,
        minInputVoltage.isAcceptableOrUnknown(
          data['min_input_voltage']!,
          _minInputVoltageMeta,
        ),
      );
    }
    if (data.containsKey('max_input_voltage')) {
      context.handle(
        _maxInputVoltageMeta,
        maxInputVoltage.isAcceptableOrUnknown(
          data['max_input_voltage']!,
          _maxInputVoltageMeta,
        ),
      );
    }
    if (data.containsKey('max_input_current_per_mpp')) {
      context.handle(
        _maxInputCurrentPerMppMeta,
        maxInputCurrentPerMpp.isAcceptableOrUnknown(
          data['max_input_current_per_mpp']!,
          _maxInputCurrentPerMppMeta,
        ),
      );
    }
    if (data.containsKey('max_short_circuit_current_per_mpp')) {
      context.handle(
        _maxShortCircuitCurrentPerMppMeta,
        maxShortCircuitCurrentPerMpp.isAcceptableOrUnknown(
          data['max_short_circuit_current_per_mpp']!,
          _maxShortCircuitCurrentPerMppMeta,
        ),
      );
    }
    if (data.containsKey('ac_phases')) {
      context.handle(
        _acPhasesMeta,
        acPhases.isAcceptableOrUnknown(data['ac_phases']!, _acPhasesMeta),
      );
    }
    if (data.containsKey('dc_voltage_class')) {
      context.handle(
        _dcVoltageClassMeta,
        dcVoltageClass.isAcceptableOrUnknown(
          data['dc_voltage_class']!,
          _dcVoltageClassMeta,
        ),
      );
    }
    if (data.containsKey('i_out_a')) {
      context.handle(
        _iOutAMeta,
        iOutA.isAcceptableOrUnknown(data['i_out_a']!, _iOutAMeta),
      );
    }
    if (data.containsKey('mcb_a')) {
      context.handle(
        _mcbAMeta,
        mcbA.isAcceptableOrUnknown(data['mcb_a']!, _mcbAMeta),
      );
    }
    if (data.containsKey('mpp_min_voltage')) {
      context.handle(
        _mppMinVoltageMeta,
        mppMinVoltage.isAcceptableOrUnknown(
          data['mpp_min_voltage']!,
          _mppMinVoltageMeta,
        ),
      );
    }
    if (data.containsKey('mpp_max_voltage')) {
      context.handle(
        _mppMaxVoltageMeta,
        mppMaxVoltage.isAcceptableOrUnknown(
          data['mpp_max_voltage']!,
          _mppMaxVoltageMeta,
        ),
      );
    }
    if (data.containsKey('q_kvar')) {
      context.handle(
        _qKvarMeta,
        qKvar.isAcceptableOrUnknown(data['q_kvar']!, _qKvarMeta),
      );
    }
    if (data.containsKey('is_hybrid')) {
      context.handle(
        _isHybridMeta,
        isHybrid.isAcceptableOrUnknown(data['is_hybrid']!, _isHybridMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Inverter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inverter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      powerKw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_kw'],
      )!,
      mppCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mpp_count'],
      )!,
      maxStringsPerMpp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_strings_per_mpp'],
      )!,
      minInputVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_input_voltage'],
      ),
      maxInputVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_input_voltage'],
      ),
      maxInputCurrentPerMpp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_input_current_per_mpp'],
      ),
      maxShortCircuitCurrentPerMpp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_short_circuit_current_per_mpp'],
      ),
      acPhases: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ac_phases'],
      )!,
      dcVoltageClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dc_voltage_class'],
      ),
      iOutA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}i_out_a'],
      ),
      mcbA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mcb_a'],
      ),
      mppMinVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mpp_min_voltage'],
      ),
      mppMaxVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mpp_max_voltage'],
      ),
      qKvar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}q_kvar'],
      ),
      isHybrid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hybrid'],
      )!,
    );
  }

  @override
  $InvertersTable createAlias(String alias) {
    return $InvertersTable(attachedDatabase, alias);
  }
}

class Inverter extends DataClass implements Insertable<Inverter> {
  final int id;
  final String name;
  final String manufacturer;

  /// Nominal AC power in kW.
  final double powerKw;

  /// Number of MPPT trackers.
  final int mppCount;

  /// Strings that can be paralleled per MPPT.
  final int maxStringsPerMpp;
  final double? minInputVoltage;
  final double? maxInputVoltage;
  final double? maxInputCurrentPerMpp;
  final double? maxShortCircuitCurrentPerMpp;

  /// AC connection: 1 (single-phase) or 3 (three-phase). Drives the output
  /// current formula I_out = P/(U·cosφ) (VDE-AR-N 4105 §2).
  final int acPhases;

  /// DC voltage class of the device, e.g. '1000V' / '1500V'. Informational:
  /// the cold-Voc check uses min(1500, maxInputVoltage) regardless.
  final String? dcVoltageClass;

  /// Rated AC output current in A, straight from the datasheet. When null it
  /// is derived as P/(U·cosφ) with cos φ = 1.
  final double? iOutA;

  /// Recommended MCB (LS-Schalter) rating in A for the AC output connection,
  /// derived from [iOutA] (next IEC 60898 rating). Stored per inventory item;
  /// `validateProject` shows it for the project's active inverter only.
  final int? mcbA;

  /// MPP operating voltage window from the datasheet (V). Planning aid for
  /// the VDE-AR-N 4105 §3.3 MPP check: `Vmp(T_cell,hot) >= mppMinVoltage` and
  /// `Vmp(T_cell,cold) <= mppMaxVoltage`. Null = not specified (check skipped).
  final double? mppMinVoltage;
  final double? mppMaxVoltage;

  /// Reactive power capability in kvar (VDE-AR-N 4105 §2, Q(U)/P(Q)).
  /// Informational only — no sizing is derived from it.
  final double? qKvar;
  final bool isHybrid;
  const Inverter({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.powerKw,
    required this.mppCount,
    required this.maxStringsPerMpp,
    this.minInputVoltage,
    this.maxInputVoltage,
    this.maxInputCurrentPerMpp,
    this.maxShortCircuitCurrentPerMpp,
    required this.acPhases,
    this.dcVoltageClass,
    this.iOutA,
    this.mcbA,
    this.mppMinVoltage,
    this.mppMaxVoltage,
    this.qKvar,
    required this.isHybrid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['power_kw'] = Variable<double>(powerKw);
    map['mpp_count'] = Variable<int>(mppCount);
    map['max_strings_per_mpp'] = Variable<int>(maxStringsPerMpp);
    if (!nullToAbsent || minInputVoltage != null) {
      map['min_input_voltage'] = Variable<double>(minInputVoltage);
    }
    if (!nullToAbsent || maxInputVoltage != null) {
      map['max_input_voltage'] = Variable<double>(maxInputVoltage);
    }
    if (!nullToAbsent || maxInputCurrentPerMpp != null) {
      map['max_input_current_per_mpp'] = Variable<double>(
        maxInputCurrentPerMpp,
      );
    }
    if (!nullToAbsent || maxShortCircuitCurrentPerMpp != null) {
      map['max_short_circuit_current_per_mpp'] = Variable<double>(
        maxShortCircuitCurrentPerMpp,
      );
    }
    map['ac_phases'] = Variable<int>(acPhases);
    if (!nullToAbsent || dcVoltageClass != null) {
      map['dc_voltage_class'] = Variable<String>(dcVoltageClass);
    }
    if (!nullToAbsent || iOutA != null) {
      map['i_out_a'] = Variable<double>(iOutA);
    }
    if (!nullToAbsent || mcbA != null) {
      map['mcb_a'] = Variable<int>(mcbA);
    }
    if (!nullToAbsent || mppMinVoltage != null) {
      map['mpp_min_voltage'] = Variable<double>(mppMinVoltage);
    }
    if (!nullToAbsent || mppMaxVoltage != null) {
      map['mpp_max_voltage'] = Variable<double>(mppMaxVoltage);
    }
    if (!nullToAbsent || qKvar != null) {
      map['q_kvar'] = Variable<double>(qKvar);
    }
    map['is_hybrid'] = Variable<bool>(isHybrid);
    return map;
  }

  InvertersCompanion toCompanion(bool nullToAbsent) {
    return InvertersCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: Value(manufacturer),
      powerKw: Value(powerKw),
      mppCount: Value(mppCount),
      maxStringsPerMpp: Value(maxStringsPerMpp),
      minInputVoltage: minInputVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(minInputVoltage),
      maxInputVoltage: maxInputVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(maxInputVoltage),
      maxInputCurrentPerMpp: maxInputCurrentPerMpp == null && nullToAbsent
          ? const Value.absent()
          : Value(maxInputCurrentPerMpp),
      maxShortCircuitCurrentPerMpp:
          maxShortCircuitCurrentPerMpp == null && nullToAbsent
          ? const Value.absent()
          : Value(maxShortCircuitCurrentPerMpp),
      acPhases: Value(acPhases),
      dcVoltageClass: dcVoltageClass == null && nullToAbsent
          ? const Value.absent()
          : Value(dcVoltageClass),
      iOutA: iOutA == null && nullToAbsent
          ? const Value.absent()
          : Value(iOutA),
      mcbA: mcbA == null && nullToAbsent ? const Value.absent() : Value(mcbA),
      mppMinVoltage: mppMinVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(mppMinVoltage),
      mppMaxVoltage: mppMaxVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(mppMaxVoltage),
      qKvar: qKvar == null && nullToAbsent
          ? const Value.absent()
          : Value(qKvar),
      isHybrid: Value(isHybrid),
    );
  }

  factory Inverter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inverter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      powerKw: serializer.fromJson<double>(json['powerKw']),
      mppCount: serializer.fromJson<int>(json['mppCount']),
      maxStringsPerMpp: serializer.fromJson<int>(json['maxStringsPerMpp']),
      minInputVoltage: serializer.fromJson<double?>(json['minInputVoltage']),
      maxInputVoltage: serializer.fromJson<double?>(json['maxInputVoltage']),
      maxInputCurrentPerMpp: serializer.fromJson<double?>(
        json['maxInputCurrentPerMpp'],
      ),
      maxShortCircuitCurrentPerMpp: serializer.fromJson<double?>(
        json['maxShortCircuitCurrentPerMpp'],
      ),
      acPhases: serializer.fromJson<int>(json['acPhases']),
      dcVoltageClass: serializer.fromJson<String?>(json['dcVoltageClass']),
      iOutA: serializer.fromJson<double?>(json['iOutA']),
      mcbA: serializer.fromJson<int?>(json['mcbA']),
      mppMinVoltage: serializer.fromJson<double?>(json['mppMinVoltage']),
      mppMaxVoltage: serializer.fromJson<double?>(json['mppMaxVoltage']),
      qKvar: serializer.fromJson<double?>(json['qKvar']),
      isHybrid: serializer.fromJson<bool>(json['isHybrid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'powerKw': serializer.toJson<double>(powerKw),
      'mppCount': serializer.toJson<int>(mppCount),
      'maxStringsPerMpp': serializer.toJson<int>(maxStringsPerMpp),
      'minInputVoltage': serializer.toJson<double?>(minInputVoltage),
      'maxInputVoltage': serializer.toJson<double?>(maxInputVoltage),
      'maxInputCurrentPerMpp': serializer.toJson<double?>(
        maxInputCurrentPerMpp,
      ),
      'maxShortCircuitCurrentPerMpp': serializer.toJson<double?>(
        maxShortCircuitCurrentPerMpp,
      ),
      'acPhases': serializer.toJson<int>(acPhases),
      'dcVoltageClass': serializer.toJson<String?>(dcVoltageClass),
      'iOutA': serializer.toJson<double?>(iOutA),
      'mcbA': serializer.toJson<int?>(mcbA),
      'mppMinVoltage': serializer.toJson<double?>(mppMinVoltage),
      'mppMaxVoltage': serializer.toJson<double?>(mppMaxVoltage),
      'qKvar': serializer.toJson<double?>(qKvar),
      'isHybrid': serializer.toJson<bool>(isHybrid),
    };
  }

  Inverter copyWith({
    int? id,
    String? name,
    String? manufacturer,
    double? powerKw,
    int? mppCount,
    int? maxStringsPerMpp,
    Value<double?> minInputVoltage = const Value.absent(),
    Value<double?> maxInputVoltage = const Value.absent(),
    Value<double?> maxInputCurrentPerMpp = const Value.absent(),
    Value<double?> maxShortCircuitCurrentPerMpp = const Value.absent(),
    int? acPhases,
    Value<String?> dcVoltageClass = const Value.absent(),
    Value<double?> iOutA = const Value.absent(),
    Value<int?> mcbA = const Value.absent(),
    Value<double?> mppMinVoltage = const Value.absent(),
    Value<double?> mppMaxVoltage = const Value.absent(),
    Value<double?> qKvar = const Value.absent(),
    bool? isHybrid,
  }) => Inverter(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    powerKw: powerKw ?? this.powerKw,
    mppCount: mppCount ?? this.mppCount,
    maxStringsPerMpp: maxStringsPerMpp ?? this.maxStringsPerMpp,
    minInputVoltage: minInputVoltage.present
        ? minInputVoltage.value
        : this.minInputVoltage,
    maxInputVoltage: maxInputVoltage.present
        ? maxInputVoltage.value
        : this.maxInputVoltage,
    maxInputCurrentPerMpp: maxInputCurrentPerMpp.present
        ? maxInputCurrentPerMpp.value
        : this.maxInputCurrentPerMpp,
    maxShortCircuitCurrentPerMpp: maxShortCircuitCurrentPerMpp.present
        ? maxShortCircuitCurrentPerMpp.value
        : this.maxShortCircuitCurrentPerMpp,
    acPhases: acPhases ?? this.acPhases,
    dcVoltageClass: dcVoltageClass.present
        ? dcVoltageClass.value
        : this.dcVoltageClass,
    iOutA: iOutA.present ? iOutA.value : this.iOutA,
    mcbA: mcbA.present ? mcbA.value : this.mcbA,
    mppMinVoltage: mppMinVoltage.present
        ? mppMinVoltage.value
        : this.mppMinVoltage,
    mppMaxVoltage: mppMaxVoltage.present
        ? mppMaxVoltage.value
        : this.mppMaxVoltage,
    qKvar: qKvar.present ? qKvar.value : this.qKvar,
    isHybrid: isHybrid ?? this.isHybrid,
  );
  Inverter copyWithCompanion(InvertersCompanion data) {
    return Inverter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      powerKw: data.powerKw.present ? data.powerKw.value : this.powerKw,
      mppCount: data.mppCount.present ? data.mppCount.value : this.mppCount,
      maxStringsPerMpp: data.maxStringsPerMpp.present
          ? data.maxStringsPerMpp.value
          : this.maxStringsPerMpp,
      minInputVoltage: data.minInputVoltage.present
          ? data.minInputVoltage.value
          : this.minInputVoltage,
      maxInputVoltage: data.maxInputVoltage.present
          ? data.maxInputVoltage.value
          : this.maxInputVoltage,
      maxInputCurrentPerMpp: data.maxInputCurrentPerMpp.present
          ? data.maxInputCurrentPerMpp.value
          : this.maxInputCurrentPerMpp,
      maxShortCircuitCurrentPerMpp: data.maxShortCircuitCurrentPerMpp.present
          ? data.maxShortCircuitCurrentPerMpp.value
          : this.maxShortCircuitCurrentPerMpp,
      acPhases: data.acPhases.present ? data.acPhases.value : this.acPhases,
      dcVoltageClass: data.dcVoltageClass.present
          ? data.dcVoltageClass.value
          : this.dcVoltageClass,
      iOutA: data.iOutA.present ? data.iOutA.value : this.iOutA,
      mcbA: data.mcbA.present ? data.mcbA.value : this.mcbA,
      mppMinVoltage: data.mppMinVoltage.present
          ? data.mppMinVoltage.value
          : this.mppMinVoltage,
      mppMaxVoltage: data.mppMaxVoltage.present
          ? data.mppMaxVoltage.value
          : this.mppMaxVoltage,
      qKvar: data.qKvar.present ? data.qKvar.value : this.qKvar,
      isHybrid: data.isHybrid.present ? data.isHybrid.value : this.isHybrid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inverter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('powerKw: $powerKw, ')
          ..write('mppCount: $mppCount, ')
          ..write('maxStringsPerMpp: $maxStringsPerMpp, ')
          ..write('minInputVoltage: $minInputVoltage, ')
          ..write('maxInputVoltage: $maxInputVoltage, ')
          ..write('maxInputCurrentPerMpp: $maxInputCurrentPerMpp, ')
          ..write(
            'maxShortCircuitCurrentPerMpp: $maxShortCircuitCurrentPerMpp, ',
          )
          ..write('acPhases: $acPhases, ')
          ..write('dcVoltageClass: $dcVoltageClass, ')
          ..write('iOutA: $iOutA, ')
          ..write('mcbA: $mcbA, ')
          ..write('mppMinVoltage: $mppMinVoltage, ')
          ..write('mppMaxVoltage: $mppMaxVoltage, ')
          ..write('qKvar: $qKvar, ')
          ..write('isHybrid: $isHybrid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    powerKw,
    mppCount,
    maxStringsPerMpp,
    minInputVoltage,
    maxInputVoltage,
    maxInputCurrentPerMpp,
    maxShortCircuitCurrentPerMpp,
    acPhases,
    dcVoltageClass,
    iOutA,
    mcbA,
    mppMinVoltage,
    mppMaxVoltage,
    qKvar,
    isHybrid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inverter &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.powerKw == this.powerKw &&
          other.mppCount == this.mppCount &&
          other.maxStringsPerMpp == this.maxStringsPerMpp &&
          other.minInputVoltage == this.minInputVoltage &&
          other.maxInputVoltage == this.maxInputVoltage &&
          other.maxInputCurrentPerMpp == this.maxInputCurrentPerMpp &&
          other.maxShortCircuitCurrentPerMpp ==
              this.maxShortCircuitCurrentPerMpp &&
          other.acPhases == this.acPhases &&
          other.dcVoltageClass == this.dcVoltageClass &&
          other.iOutA == this.iOutA &&
          other.mcbA == this.mcbA &&
          other.mppMinVoltage == this.mppMinVoltage &&
          other.mppMaxVoltage == this.mppMaxVoltage &&
          other.qKvar == this.qKvar &&
          other.isHybrid == this.isHybrid);
}

class InvertersCompanion extends UpdateCompanion<Inverter> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> manufacturer;
  final Value<double> powerKw;
  final Value<int> mppCount;
  final Value<int> maxStringsPerMpp;
  final Value<double?> minInputVoltage;
  final Value<double?> maxInputVoltage;
  final Value<double?> maxInputCurrentPerMpp;
  final Value<double?> maxShortCircuitCurrentPerMpp;
  final Value<int> acPhases;
  final Value<String?> dcVoltageClass;
  final Value<double?> iOutA;
  final Value<int?> mcbA;
  final Value<double?> mppMinVoltage;
  final Value<double?> mppMaxVoltage;
  final Value<double?> qKvar;
  final Value<bool> isHybrid;
  const InvertersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.powerKw = const Value.absent(),
    this.mppCount = const Value.absent(),
    this.maxStringsPerMpp = const Value.absent(),
    this.minInputVoltage = const Value.absent(),
    this.maxInputVoltage = const Value.absent(),
    this.maxInputCurrentPerMpp = const Value.absent(),
    this.maxShortCircuitCurrentPerMpp = const Value.absent(),
    this.acPhases = const Value.absent(),
    this.dcVoltageClass = const Value.absent(),
    this.iOutA = const Value.absent(),
    this.mcbA = const Value.absent(),
    this.mppMinVoltage = const Value.absent(),
    this.mppMaxVoltage = const Value.absent(),
    this.qKvar = const Value.absent(),
    this.isHybrid = const Value.absent(),
  });
  InvertersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.manufacturer = const Value.absent(),
    required double powerKw,
    this.mppCount = const Value.absent(),
    this.maxStringsPerMpp = const Value.absent(),
    this.minInputVoltage = const Value.absent(),
    this.maxInputVoltage = const Value.absent(),
    this.maxInputCurrentPerMpp = const Value.absent(),
    this.maxShortCircuitCurrentPerMpp = const Value.absent(),
    this.acPhases = const Value.absent(),
    this.dcVoltageClass = const Value.absent(),
    this.iOutA = const Value.absent(),
    this.mcbA = const Value.absent(),
    this.mppMinVoltage = const Value.absent(),
    this.mppMaxVoltage = const Value.absent(),
    this.qKvar = const Value.absent(),
    this.isHybrid = const Value.absent(),
  }) : name = Value(name),
       powerKw = Value(powerKw);
  static Insertable<Inverter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<double>? powerKw,
    Expression<int>? mppCount,
    Expression<int>? maxStringsPerMpp,
    Expression<double>? minInputVoltage,
    Expression<double>? maxInputVoltage,
    Expression<double>? maxInputCurrentPerMpp,
    Expression<double>? maxShortCircuitCurrentPerMpp,
    Expression<int>? acPhases,
    Expression<String>? dcVoltageClass,
    Expression<double>? iOutA,
    Expression<int>? mcbA,
    Expression<double>? mppMinVoltage,
    Expression<double>? mppMaxVoltage,
    Expression<double>? qKvar,
    Expression<bool>? isHybrid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (powerKw != null) 'power_kw': powerKw,
      if (mppCount != null) 'mpp_count': mppCount,
      if (maxStringsPerMpp != null) 'max_strings_per_mpp': maxStringsPerMpp,
      if (minInputVoltage != null) 'min_input_voltage': minInputVoltage,
      if (maxInputVoltage != null) 'max_input_voltage': maxInputVoltage,
      if (maxInputCurrentPerMpp != null)
        'max_input_current_per_mpp': maxInputCurrentPerMpp,
      if (maxShortCircuitCurrentPerMpp != null)
        'max_short_circuit_current_per_mpp': maxShortCircuitCurrentPerMpp,
      if (acPhases != null) 'ac_phases': acPhases,
      if (dcVoltageClass != null) 'dc_voltage_class': dcVoltageClass,
      if (iOutA != null) 'i_out_a': iOutA,
      if (mcbA != null) 'mcb_a': mcbA,
      if (mppMinVoltage != null) 'mpp_min_voltage': mppMinVoltage,
      if (mppMaxVoltage != null) 'mpp_max_voltage': mppMaxVoltage,
      if (qKvar != null) 'q_kvar': qKvar,
      if (isHybrid != null) 'is_hybrid': isHybrid,
    });
  }

  InvertersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? manufacturer,
    Value<double>? powerKw,
    Value<int>? mppCount,
    Value<int>? maxStringsPerMpp,
    Value<double?>? minInputVoltage,
    Value<double?>? maxInputVoltage,
    Value<double?>? maxInputCurrentPerMpp,
    Value<double?>? maxShortCircuitCurrentPerMpp,
    Value<int>? acPhases,
    Value<String?>? dcVoltageClass,
    Value<double?>? iOutA,
    Value<int?>? mcbA,
    Value<double?>? mppMinVoltage,
    Value<double?>? mppMaxVoltage,
    Value<double?>? qKvar,
    Value<bool>? isHybrid,
  }) {
    return InvertersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      powerKw: powerKw ?? this.powerKw,
      mppCount: mppCount ?? this.mppCount,
      maxStringsPerMpp: maxStringsPerMpp ?? this.maxStringsPerMpp,
      minInputVoltage: minInputVoltage ?? this.minInputVoltage,
      maxInputVoltage: maxInputVoltage ?? this.maxInputVoltage,
      maxInputCurrentPerMpp:
          maxInputCurrentPerMpp ?? this.maxInputCurrentPerMpp,
      maxShortCircuitCurrentPerMpp:
          maxShortCircuitCurrentPerMpp ?? this.maxShortCircuitCurrentPerMpp,
      acPhases: acPhases ?? this.acPhases,
      dcVoltageClass: dcVoltageClass ?? this.dcVoltageClass,
      iOutA: iOutA ?? this.iOutA,
      mcbA: mcbA ?? this.mcbA,
      mppMinVoltage: mppMinVoltage ?? this.mppMinVoltage,
      mppMaxVoltage: mppMaxVoltage ?? this.mppMaxVoltage,
      qKvar: qKvar ?? this.qKvar,
      isHybrid: isHybrid ?? this.isHybrid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (powerKw.present) {
      map['power_kw'] = Variable<double>(powerKw.value);
    }
    if (mppCount.present) {
      map['mpp_count'] = Variable<int>(mppCount.value);
    }
    if (maxStringsPerMpp.present) {
      map['max_strings_per_mpp'] = Variable<int>(maxStringsPerMpp.value);
    }
    if (minInputVoltage.present) {
      map['min_input_voltage'] = Variable<double>(minInputVoltage.value);
    }
    if (maxInputVoltage.present) {
      map['max_input_voltage'] = Variable<double>(maxInputVoltage.value);
    }
    if (maxInputCurrentPerMpp.present) {
      map['max_input_current_per_mpp'] = Variable<double>(
        maxInputCurrentPerMpp.value,
      );
    }
    if (maxShortCircuitCurrentPerMpp.present) {
      map['max_short_circuit_current_per_mpp'] = Variable<double>(
        maxShortCircuitCurrentPerMpp.value,
      );
    }
    if (acPhases.present) {
      map['ac_phases'] = Variable<int>(acPhases.value);
    }
    if (dcVoltageClass.present) {
      map['dc_voltage_class'] = Variable<String>(dcVoltageClass.value);
    }
    if (iOutA.present) {
      map['i_out_a'] = Variable<double>(iOutA.value);
    }
    if (mcbA.present) {
      map['mcb_a'] = Variable<int>(mcbA.value);
    }
    if (mppMinVoltage.present) {
      map['mpp_min_voltage'] = Variable<double>(mppMinVoltage.value);
    }
    if (mppMaxVoltage.present) {
      map['mpp_max_voltage'] = Variable<double>(mppMaxVoltage.value);
    }
    if (qKvar.present) {
      map['q_kvar'] = Variable<double>(qKvar.value);
    }
    if (isHybrid.present) {
      map['is_hybrid'] = Variable<bool>(isHybrid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvertersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('powerKw: $powerKw, ')
          ..write('mppCount: $mppCount, ')
          ..write('maxStringsPerMpp: $maxStringsPerMpp, ')
          ..write('minInputVoltage: $minInputVoltage, ')
          ..write('maxInputVoltage: $maxInputVoltage, ')
          ..write('maxInputCurrentPerMpp: $maxInputCurrentPerMpp, ')
          ..write(
            'maxShortCircuitCurrentPerMpp: $maxShortCircuitCurrentPerMpp, ',
          )
          ..write('acPhases: $acPhases, ')
          ..write('dcVoltageClass: $dcVoltageClass, ')
          ..write('iOutA: $iOutA, ')
          ..write('mcbA: $mcbA, ')
          ..write('mppMinVoltage: $mppMinVoltage, ')
          ..write('mppMaxVoltage: $mppMaxVoltage, ')
          ..write('qKvar: $qKvar, ')
          ..write('isHybrid: $isHybrid')
          ..write(')'))
        .toString();
  }
}

class $BatteriesTable extends Batteries
    with TableInfo<$BatteriesTable, Battery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _capacityKwhMeta = const VerificationMeta(
    'capacityKwh',
  );
  @override
  late final GeneratedColumn<double> capacityKwh = GeneratedColumn<double>(
    'capacity_kwh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalVoltageMeta = const VerificationMeta(
    'nominalVoltage',
  );
  @override
  late final GeneratedColumn<double> nominalVoltage = GeneratedColumn<double>(
    'nominal_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chemistryMeta = const VerificationMeta(
    'chemistry',
  );
  @override
  late final GeneratedColumn<String> chemistry = GeneratedColumn<String>(
    'chemistry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LiFePO4'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    manufacturer,
    capacityKwh,
    nominalVoltage,
    chemistry,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batteries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Battery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('capacity_kwh')) {
      context.handle(
        _capacityKwhMeta,
        capacityKwh.isAcceptableOrUnknown(
          data['capacity_kwh']!,
          _capacityKwhMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capacityKwhMeta);
    }
    if (data.containsKey('nominal_voltage')) {
      context.handle(
        _nominalVoltageMeta,
        nominalVoltage.isAcceptableOrUnknown(
          data['nominal_voltage']!,
          _nominalVoltageMeta,
        ),
      );
    }
    if (data.containsKey('chemistry')) {
      context.handle(
        _chemistryMeta,
        chemistry.isAcceptableOrUnknown(data['chemistry']!, _chemistryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Battery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Battery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      capacityKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}capacity_kwh'],
      )!,
      nominalVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nominal_voltage'],
      ),
      chemistry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chemistry'],
      )!,
    );
  }

  @override
  $BatteriesTable createAlias(String alias) {
    return $BatteriesTable(attachedDatabase, alias);
  }
}

class Battery extends DataClass implements Insertable<Battery> {
  final int id;
  final String name;
  final String manufacturer;

  /// Usable capacity in kWh.
  final double capacityKwh;
  final double? nominalVoltage;
  final String chemistry;
  const Battery({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.capacityKwh,
    this.nominalVoltage,
    required this.chemistry,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['capacity_kwh'] = Variable<double>(capacityKwh);
    if (!nullToAbsent || nominalVoltage != null) {
      map['nominal_voltage'] = Variable<double>(nominalVoltage);
    }
    map['chemistry'] = Variable<String>(chemistry);
    return map;
  }

  BatteriesCompanion toCompanion(bool nullToAbsent) {
    return BatteriesCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: Value(manufacturer),
      capacityKwh: Value(capacityKwh),
      nominalVoltage: nominalVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(nominalVoltage),
      chemistry: Value(chemistry),
    );
  }

  factory Battery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Battery(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      capacityKwh: serializer.fromJson<double>(json['capacityKwh']),
      nominalVoltage: serializer.fromJson<double?>(json['nominalVoltage']),
      chemistry: serializer.fromJson<String>(json['chemistry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'capacityKwh': serializer.toJson<double>(capacityKwh),
      'nominalVoltage': serializer.toJson<double?>(nominalVoltage),
      'chemistry': serializer.toJson<String>(chemistry),
    };
  }

  Battery copyWith({
    int? id,
    String? name,
    String? manufacturer,
    double? capacityKwh,
    Value<double?> nominalVoltage = const Value.absent(),
    String? chemistry,
  }) => Battery(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    capacityKwh: capacityKwh ?? this.capacityKwh,
    nominalVoltage: nominalVoltage.present
        ? nominalVoltage.value
        : this.nominalVoltage,
    chemistry: chemistry ?? this.chemistry,
  );
  Battery copyWithCompanion(BatteriesCompanion data) {
    return Battery(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      capacityKwh: data.capacityKwh.present
          ? data.capacityKwh.value
          : this.capacityKwh,
      nominalVoltage: data.nominalVoltage.present
          ? data.nominalVoltage.value
          : this.nominalVoltage,
      chemistry: data.chemistry.present ? data.chemistry.value : this.chemistry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Battery(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('capacityKwh: $capacityKwh, ')
          ..write('nominalVoltage: $nominalVoltage, ')
          ..write('chemistry: $chemistry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    capacityKwh,
    nominalVoltage,
    chemistry,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Battery &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.capacityKwh == this.capacityKwh &&
          other.nominalVoltage == this.nominalVoltage &&
          other.chemistry == this.chemistry);
}

class BatteriesCompanion extends UpdateCompanion<Battery> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> manufacturer;
  final Value<double> capacityKwh;
  final Value<double?> nominalVoltage;
  final Value<String> chemistry;
  const BatteriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.capacityKwh = const Value.absent(),
    this.nominalVoltage = const Value.absent(),
    this.chemistry = const Value.absent(),
  });
  BatteriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.manufacturer = const Value.absent(),
    required double capacityKwh,
    this.nominalVoltage = const Value.absent(),
    this.chemistry = const Value.absent(),
  }) : name = Value(name),
       capacityKwh = Value(capacityKwh);
  static Insertable<Battery> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<double>? capacityKwh,
    Expression<double>? nominalVoltage,
    Expression<String>? chemistry,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (capacityKwh != null) 'capacity_kwh': capacityKwh,
      if (nominalVoltage != null) 'nominal_voltage': nominalVoltage,
      if (chemistry != null) 'chemistry': chemistry,
    });
  }

  BatteriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? manufacturer,
    Value<double>? capacityKwh,
    Value<double?>? nominalVoltage,
    Value<String>? chemistry,
  }) {
    return BatteriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      capacityKwh: capacityKwh ?? this.capacityKwh,
      nominalVoltage: nominalVoltage ?? this.nominalVoltage,
      chemistry: chemistry ?? this.chemistry,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (capacityKwh.present) {
      map['capacity_kwh'] = Variable<double>(capacityKwh.value);
    }
    if (nominalVoltage.present) {
      map['nominal_voltage'] = Variable<double>(nominalVoltage.value);
    }
    if (chemistry.present) {
      map['chemistry'] = Variable<String>(chemistry.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('capacityKwh: $capacityKwh, ')
          ..write('nominalVoltage: $nominalVoltage, ')
          ..write('chemistry: $chemistry')
          ..write(')'))
        .toString();
  }
}

class $WallboxesTable extends Wallboxes
    with TableInfo<$WallboxesTable, Wallbox> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WallboxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _powerKwMeta = const VerificationMeta(
    'powerKw',
  );
  @override
  late final GeneratedColumn<double> powerKw = GeneratedColumn<double>(
    'power_kw',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phasesMeta = const VerificationMeta('phases');
  @override
  late final GeneratedColumn<int> phases = GeneratedColumn<int>(
    'phases',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _rcdTypeMeta = const VerificationMeta(
    'rcdType',
  );
  @override
  late final GeneratedColumn<String> rcdType = GeneratedColumn<String>(
    'rcd_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('B'),
  );
  static const VerificationMeta _breakerAMeta = const VerificationMeta(
    'breakerA',
  );
  @override
  late final GeneratedColumn<double> breakerA = GeneratedColumn<double>(
    'breaker_a',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rcdRatedAMeta = const VerificationMeta(
    'rcdRatedA',
  );
  @override
  late final GeneratedColumn<double> rcdRatedA = GeneratedColumn<double>(
    'rcd_rated_a',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    manufacturer,
    powerKw,
    phases,
    rcdType,
    breakerA,
    rcdRatedA,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallboxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wallbox> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('power_kw')) {
      context.handle(
        _powerKwMeta,
        powerKw.isAcceptableOrUnknown(data['power_kw']!, _powerKwMeta),
      );
    } else if (isInserting) {
      context.missing(_powerKwMeta);
    }
    if (data.containsKey('phases')) {
      context.handle(
        _phasesMeta,
        phases.isAcceptableOrUnknown(data['phases']!, _phasesMeta),
      );
    }
    if (data.containsKey('rcd_type')) {
      context.handle(
        _rcdTypeMeta,
        rcdType.isAcceptableOrUnknown(data['rcd_type']!, _rcdTypeMeta),
      );
    }
    if (data.containsKey('breaker_a')) {
      context.handle(
        _breakerAMeta,
        breakerA.isAcceptableOrUnknown(data['breaker_a']!, _breakerAMeta),
      );
    }
    if (data.containsKey('rcd_rated_a')) {
      context.handle(
        _rcdRatedAMeta,
        rcdRatedA.isAcceptableOrUnknown(data['rcd_rated_a']!, _rcdRatedAMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallbox map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallbox(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      powerKw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_kw'],
      )!,
      phases: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phases'],
      )!,
      rcdType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rcd_type'],
      )!,
      breakerA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breaker_a'],
      ),
      rcdRatedA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rcd_rated_a'],
      ),
    );
  }

  @override
  $WallboxesTable createAlias(String alias) {
    return $WallboxesTable(attachedDatabase, alias);
  }
}

class Wallbox extends DataClass implements Insertable<Wallbox> {
  final int id;
  final String name;
  final String manufacturer;

  /// Charging power in kW.
  final double powerKw;
  final int phases;

  /// Required RCD type for the charging circuit: 'A' or 'B'. EV circuits
  /// require Type B (smooth DC fault detection, VDE 0100-534).
  final String rcdType;

  /// Rated current of the circuit breaker (LS) protecting the charging
  /// circuit in A. Null = not specified; `validateProject` then only asks for
  /// the value instead of checking I_charge <= breakerA (VDE 0100-443).
  final double? breakerA;

  /// Rated current of the RCD (FI) for the charging circuit in A. Null = not
  /// specified; same handling as [breakerA] (VDE 0100-534).
  final double? rcdRatedA;
  const Wallbox({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.powerKw,
    required this.phases,
    required this.rcdType,
    this.breakerA,
    this.rcdRatedA,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['power_kw'] = Variable<double>(powerKw);
    map['phases'] = Variable<int>(phases);
    map['rcd_type'] = Variable<String>(rcdType);
    if (!nullToAbsent || breakerA != null) {
      map['breaker_a'] = Variable<double>(breakerA);
    }
    if (!nullToAbsent || rcdRatedA != null) {
      map['rcd_rated_a'] = Variable<double>(rcdRatedA);
    }
    return map;
  }

  WallboxesCompanion toCompanion(bool nullToAbsent) {
    return WallboxesCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: Value(manufacturer),
      powerKw: Value(powerKw),
      phases: Value(phases),
      rcdType: Value(rcdType),
      breakerA: breakerA == null && nullToAbsent
          ? const Value.absent()
          : Value(breakerA),
      rcdRatedA: rcdRatedA == null && nullToAbsent
          ? const Value.absent()
          : Value(rcdRatedA),
    );
  }

  factory Wallbox.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallbox(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      powerKw: serializer.fromJson<double>(json['powerKw']),
      phases: serializer.fromJson<int>(json['phases']),
      rcdType: serializer.fromJson<String>(json['rcdType']),
      breakerA: serializer.fromJson<double?>(json['breakerA']),
      rcdRatedA: serializer.fromJson<double?>(json['rcdRatedA']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'powerKw': serializer.toJson<double>(powerKw),
      'phases': serializer.toJson<int>(phases),
      'rcdType': serializer.toJson<String>(rcdType),
      'breakerA': serializer.toJson<double?>(breakerA),
      'rcdRatedA': serializer.toJson<double?>(rcdRatedA),
    };
  }

  Wallbox copyWith({
    int? id,
    String? name,
    String? manufacturer,
    double? powerKw,
    int? phases,
    String? rcdType,
    Value<double?> breakerA = const Value.absent(),
    Value<double?> rcdRatedA = const Value.absent(),
  }) => Wallbox(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    powerKw: powerKw ?? this.powerKw,
    phases: phases ?? this.phases,
    rcdType: rcdType ?? this.rcdType,
    breakerA: breakerA.present ? breakerA.value : this.breakerA,
    rcdRatedA: rcdRatedA.present ? rcdRatedA.value : this.rcdRatedA,
  );
  Wallbox copyWithCompanion(WallboxesCompanion data) {
    return Wallbox(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      powerKw: data.powerKw.present ? data.powerKw.value : this.powerKw,
      phases: data.phases.present ? data.phases.value : this.phases,
      rcdType: data.rcdType.present ? data.rcdType.value : this.rcdType,
      breakerA: data.breakerA.present ? data.breakerA.value : this.breakerA,
      rcdRatedA: data.rcdRatedA.present ? data.rcdRatedA.value : this.rcdRatedA,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallbox(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('powerKw: $powerKw, ')
          ..write('phases: $phases, ')
          ..write('rcdType: $rcdType, ')
          ..write('breakerA: $breakerA, ')
          ..write('rcdRatedA: $rcdRatedA')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    powerKw,
    phases,
    rcdType,
    breakerA,
    rcdRatedA,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallbox &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.powerKw == this.powerKw &&
          other.phases == this.phases &&
          other.rcdType == this.rcdType &&
          other.breakerA == this.breakerA &&
          other.rcdRatedA == this.rcdRatedA);
}

class WallboxesCompanion extends UpdateCompanion<Wallbox> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> manufacturer;
  final Value<double> powerKw;
  final Value<int> phases;
  final Value<String> rcdType;
  final Value<double?> breakerA;
  final Value<double?> rcdRatedA;
  const WallboxesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.powerKw = const Value.absent(),
    this.phases = const Value.absent(),
    this.rcdType = const Value.absent(),
    this.breakerA = const Value.absent(),
    this.rcdRatedA = const Value.absent(),
  });
  WallboxesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.manufacturer = const Value.absent(),
    required double powerKw,
    this.phases = const Value.absent(),
    this.rcdType = const Value.absent(),
    this.breakerA = const Value.absent(),
    this.rcdRatedA = const Value.absent(),
  }) : name = Value(name),
       powerKw = Value(powerKw);
  static Insertable<Wallbox> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<double>? powerKw,
    Expression<int>? phases,
    Expression<String>? rcdType,
    Expression<double>? breakerA,
    Expression<double>? rcdRatedA,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (powerKw != null) 'power_kw': powerKw,
      if (phases != null) 'phases': phases,
      if (rcdType != null) 'rcd_type': rcdType,
      if (breakerA != null) 'breaker_a': breakerA,
      if (rcdRatedA != null) 'rcd_rated_a': rcdRatedA,
    });
  }

  WallboxesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? manufacturer,
    Value<double>? powerKw,
    Value<int>? phases,
    Value<String>? rcdType,
    Value<double?>? breakerA,
    Value<double?>? rcdRatedA,
  }) {
    return WallboxesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      powerKw: powerKw ?? this.powerKw,
      phases: phases ?? this.phases,
      rcdType: rcdType ?? this.rcdType,
      breakerA: breakerA ?? this.breakerA,
      rcdRatedA: rcdRatedA ?? this.rcdRatedA,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (powerKw.present) {
      map['power_kw'] = Variable<double>(powerKw.value);
    }
    if (phases.present) {
      map['phases'] = Variable<int>(phases.value);
    }
    if (rcdType.present) {
      map['rcd_type'] = Variable<String>(rcdType.value);
    }
    if (breakerA.present) {
      map['breaker_a'] = Variable<double>(breakerA.value);
    }
    if (rcdRatedA.present) {
      map['rcd_rated_a'] = Variable<double>(rcdRatedA.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WallboxesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('powerKw: $powerKw, ')
          ..write('phases: $phases, ')
          ..write('rcdType: $rcdType, ')
          ..write('breakerA: $breakerA, ')
          ..write('rcdRatedA: $rcdRatedA')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(51.0),
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(10.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeModuleTypeIdMeta =
      const VerificationMeta('activeModuleTypeId');
  @override
  late final GeneratedColumn<int> activeModuleTypeId = GeneratedColumn<int>(
    'active_module_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeInverterIdMeta = const VerificationMeta(
    'activeInverterId',
  );
  @override
  late final GeneratedColumn<int> activeInverterId = GeneratedColumn<int>(
    'active_inverter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tAmbientMinCMeta = const VerificationMeta(
    'tAmbientMinC',
  );
  @override
  late final GeneratedColumn<double> tAmbientMinC = GeneratedColumn<double>(
    't_ambient_min_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(-25),
  );
  static const VerificationMeta _tAmbientMaxCMeta = const VerificationMeta(
    'tAmbientMaxC',
  );
  @override
  late final GeneratedColumn<double> tAmbientMaxC = GeneratedColumn<double>(
    't_ambient_max_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _gridPhasesMeta = const VerificationMeta(
    'gridPhases',
  );
  @override
  late final GeneratedColumn<int> gridPhases = GeneratedColumn<int>(
    'grid_phases',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _maxFeedInKwMeta = const VerificationMeta(
    'maxFeedInKw',
  );
  @override
  late final GeneratedColumn<double> maxFeedInKw = GeneratedColumn<double>(
    'max_feed_in_kw',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasMainEquipotentialMeta =
      const VerificationMeta('hasMainEquipotential');
  @override
  late final GeneratedColumn<bool> hasMainEquipotential = GeneratedColumn<bool>(
    'has_main_equipotential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_main_equipotential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBoltedMountingMeta = const VerificationMeta(
    'isBoltedMounting',
  );
  @override
  late final GeneratedColumn<bool> isBoltedMounting = GeneratedColumn<bool>(
    'is_bolted_mounting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bolted_mounting" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    latitude,
    longitude,
    createdAt,
    updatedAt,
    activeModuleTypeId,
    activeInverterId,
    tAmbientMinC,
    tAmbientMaxC,
    gridPhases,
    maxFeedInKw,
    hasMainEquipotential,
    isBoltedMounting,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('active_module_type_id')) {
      context.handle(
        _activeModuleTypeIdMeta,
        activeModuleTypeId.isAcceptableOrUnknown(
          data['active_module_type_id']!,
          _activeModuleTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('active_inverter_id')) {
      context.handle(
        _activeInverterIdMeta,
        activeInverterId.isAcceptableOrUnknown(
          data['active_inverter_id']!,
          _activeInverterIdMeta,
        ),
      );
    }
    if (data.containsKey('t_ambient_min_c')) {
      context.handle(
        _tAmbientMinCMeta,
        tAmbientMinC.isAcceptableOrUnknown(
          data['t_ambient_min_c']!,
          _tAmbientMinCMeta,
        ),
      );
    }
    if (data.containsKey('t_ambient_max_c')) {
      context.handle(
        _tAmbientMaxCMeta,
        tAmbientMaxC.isAcceptableOrUnknown(
          data['t_ambient_max_c']!,
          _tAmbientMaxCMeta,
        ),
      );
    }
    if (data.containsKey('grid_phases')) {
      context.handle(
        _gridPhasesMeta,
        gridPhases.isAcceptableOrUnknown(data['grid_phases']!, _gridPhasesMeta),
      );
    }
    if (data.containsKey('max_feed_in_kw')) {
      context.handle(
        _maxFeedInKwMeta,
        maxFeedInKw.isAcceptableOrUnknown(
          data['max_feed_in_kw']!,
          _maxFeedInKwMeta,
        ),
      );
    }
    if (data.containsKey('has_main_equipotential')) {
      context.handle(
        _hasMainEquipotentialMeta,
        hasMainEquipotential.isAcceptableOrUnknown(
          data['has_main_equipotential']!,
          _hasMainEquipotentialMeta,
        ),
      );
    }
    if (data.containsKey('is_bolted_mounting')) {
      context.handle(
        _isBoltedMountingMeta,
        isBoltedMounting.isAcceptableOrUnknown(
          data['is_bolted_mounting']!,
          _isBoltedMountingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      activeModuleTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_module_type_id'],
      ),
      activeInverterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_inverter_id'],
      ),
      tAmbientMinC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}t_ambient_min_c'],
      )!,
      tAmbientMaxC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}t_ambient_max_c'],
      )!,
      gridPhases: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grid_phases'],
      )!,
      maxFeedInKw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_feed_in_kw'],
      ),
      hasMainEquipotential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_main_equipotential'],
      )!,
      isBoltedMounting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bolted_mounting'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  /// Epoch milliseconds.
  final int createdAt;
  final int updatedAt;

  /// The module type the user is currently placing / auto-filling with.
  final int? activeModuleTypeId;

  /// The inverter the user has selected for stringing.
  final int? activeInverterId;

  /// Coldest expected ambient temperature in °C — fixed IEC cold condition
  /// (−25 °C, read-only in the UI). Cell temperature for the cold-Voc check
  /// is T_ambient,min − 10 K (planning assumption).
  final double tAmbientMinC;

  /// Hottest expected ambient temperature in °C — fixed at 40 °C (read-only
  /// in the UI). Cell temperature for the hot-Voc (start-up) check is
  /// T_ambient,max + 30 K.
  final double tAmbientMaxC;

  /// Grid connection phases at the coupling device: 1 or 3.
  final int gridPhases;

  /// Agreed maximum feed-in power in kW (grid operator). Null = not set.
  final double? maxFeedInKw;

  /// Whether a main equipotential (Haupt-Potenzialausgleich) is available
  /// for module frames / inverter (VDE 0100-600 §542).
  final bool hasMainEquipotential;

  /// Whether the mounting is bolted. Ballasted (non-bolted) flat-roof
  /// mounting makes the natural protective conductor questionable → a
  /// dedicated PE conductor is recommended.
  final bool isBoltedMounting;
  const Project({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.activeModuleTypeId,
    this.activeInverterId,
    required this.tAmbientMinC,
    required this.tAmbientMaxC,
    required this.gridPhases,
    this.maxFeedInKw,
    required this.hasMainEquipotential,
    required this.isBoltedMounting,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || activeModuleTypeId != null) {
      map['active_module_type_id'] = Variable<int>(activeModuleTypeId);
    }
    if (!nullToAbsent || activeInverterId != null) {
      map['active_inverter_id'] = Variable<int>(activeInverterId);
    }
    map['t_ambient_min_c'] = Variable<double>(tAmbientMinC);
    map['t_ambient_max_c'] = Variable<double>(tAmbientMaxC);
    map['grid_phases'] = Variable<int>(gridPhases);
    if (!nullToAbsent || maxFeedInKw != null) {
      map['max_feed_in_kw'] = Variable<double>(maxFeedInKw);
    }
    map['has_main_equipotential'] = Variable<bool>(hasMainEquipotential);
    map['is_bolted_mounting'] = Variable<bool>(isBoltedMounting);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      latitude: Value(latitude),
      longitude: Value(longitude),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      activeModuleTypeId: activeModuleTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeModuleTypeId),
      activeInverterId: activeInverterId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeInverterId),
      tAmbientMinC: Value(tAmbientMinC),
      tAmbientMaxC: Value(tAmbientMaxC),
      gridPhases: Value(gridPhases),
      maxFeedInKw: maxFeedInKw == null && nullToAbsent
          ? const Value.absent()
          : Value(maxFeedInKw),
      hasMainEquipotential: Value(hasMainEquipotential),
      isBoltedMounting: Value(isBoltedMounting),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      activeModuleTypeId: serializer.fromJson<int?>(json['activeModuleTypeId']),
      activeInverterId: serializer.fromJson<int?>(json['activeInverterId']),
      tAmbientMinC: serializer.fromJson<double>(json['tAmbientMinC']),
      tAmbientMaxC: serializer.fromJson<double>(json['tAmbientMaxC']),
      gridPhases: serializer.fromJson<int>(json['gridPhases']),
      maxFeedInKw: serializer.fromJson<double?>(json['maxFeedInKw']),
      hasMainEquipotential: serializer.fromJson<bool>(
        json['hasMainEquipotential'],
      ),
      isBoltedMounting: serializer.fromJson<bool>(json['isBoltedMounting']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'activeModuleTypeId': serializer.toJson<int?>(activeModuleTypeId),
      'activeInverterId': serializer.toJson<int?>(activeInverterId),
      'tAmbientMinC': serializer.toJson<double>(tAmbientMinC),
      'tAmbientMaxC': serializer.toJson<double>(tAmbientMaxC),
      'gridPhases': serializer.toJson<int>(gridPhases),
      'maxFeedInKw': serializer.toJson<double?>(maxFeedInKw),
      'hasMainEquipotential': serializer.toJson<bool>(hasMainEquipotential),
      'isBoltedMounting': serializer.toJson<bool>(isBoltedMounting),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? createdAt,
    int? updatedAt,
    Value<int?> activeModuleTypeId = const Value.absent(),
    Value<int?> activeInverterId = const Value.absent(),
    double? tAmbientMinC,
    double? tAmbientMaxC,
    int? gridPhases,
    Value<double?> maxFeedInKw = const Value.absent(),
    bool? hasMainEquipotential,
    bool? isBoltedMounting,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    activeModuleTypeId: activeModuleTypeId.present
        ? activeModuleTypeId.value
        : this.activeModuleTypeId,
    activeInverterId: activeInverterId.present
        ? activeInverterId.value
        : this.activeInverterId,
    tAmbientMinC: tAmbientMinC ?? this.tAmbientMinC,
    tAmbientMaxC: tAmbientMaxC ?? this.tAmbientMaxC,
    gridPhases: gridPhases ?? this.gridPhases,
    maxFeedInKw: maxFeedInKw.present ? maxFeedInKw.value : this.maxFeedInKw,
    hasMainEquipotential: hasMainEquipotential ?? this.hasMainEquipotential,
    isBoltedMounting: isBoltedMounting ?? this.isBoltedMounting,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      activeModuleTypeId: data.activeModuleTypeId.present
          ? data.activeModuleTypeId.value
          : this.activeModuleTypeId,
      activeInverterId: data.activeInverterId.present
          ? data.activeInverterId.value
          : this.activeInverterId,
      tAmbientMinC: data.tAmbientMinC.present
          ? data.tAmbientMinC.value
          : this.tAmbientMinC,
      tAmbientMaxC: data.tAmbientMaxC.present
          ? data.tAmbientMaxC.value
          : this.tAmbientMaxC,
      gridPhases: data.gridPhases.present
          ? data.gridPhases.value
          : this.gridPhases,
      maxFeedInKw: data.maxFeedInKw.present
          ? data.maxFeedInKw.value
          : this.maxFeedInKw,
      hasMainEquipotential: data.hasMainEquipotential.present
          ? data.hasMainEquipotential.value
          : this.hasMainEquipotential,
      isBoltedMounting: data.isBoltedMounting.present
          ? data.isBoltedMounting.value
          : this.isBoltedMounting,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('activeModuleTypeId: $activeModuleTypeId, ')
          ..write('activeInverterId: $activeInverterId, ')
          ..write('tAmbientMinC: $tAmbientMinC, ')
          ..write('tAmbientMaxC: $tAmbientMaxC, ')
          ..write('gridPhases: $gridPhases, ')
          ..write('maxFeedInKw: $maxFeedInKw, ')
          ..write('hasMainEquipotential: $hasMainEquipotential, ')
          ..write('isBoltedMounting: $isBoltedMounting')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    latitude,
    longitude,
    createdAt,
    updatedAt,
    activeModuleTypeId,
    activeInverterId,
    tAmbientMinC,
    tAmbientMaxC,
    gridPhases,
    maxFeedInKw,
    hasMainEquipotential,
    isBoltedMounting,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.activeModuleTypeId == this.activeModuleTypeId &&
          other.activeInverterId == this.activeInverterId &&
          other.tAmbientMinC == this.tAmbientMinC &&
          other.tAmbientMaxC == this.tAmbientMaxC &&
          other.gridPhases == this.gridPhases &&
          other.maxFeedInKw == this.maxFeedInKw &&
          other.hasMainEquipotential == this.hasMainEquipotential &&
          other.isBoltedMounting == this.isBoltedMounting);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> address;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> activeModuleTypeId;
  final Value<int?> activeInverterId;
  final Value<double> tAmbientMinC;
  final Value<double> tAmbientMaxC;
  final Value<int> gridPhases;
  final Value<double?> maxFeedInKw;
  final Value<bool> hasMainEquipotential;
  final Value<bool> isBoltedMounting;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.activeModuleTypeId = const Value.absent(),
    this.activeInverterId = const Value.absent(),
    this.tAmbientMinC = const Value.absent(),
    this.tAmbientMaxC = const Value.absent(),
    this.gridPhases = const Value.absent(),
    this.maxFeedInKw = const Value.absent(),
    this.hasMainEquipotential = const Value.absent(),
    this.isBoltedMounting = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.activeModuleTypeId = const Value.absent(),
    this.activeInverterId = const Value.absent(),
    this.tAmbientMinC = const Value.absent(),
    this.tAmbientMaxC = const Value.absent(),
    this.gridPhases = const Value.absent(),
    this.maxFeedInKw = const Value.absent(),
    this.hasMainEquipotential = const Value.absent(),
    this.isBoltedMounting = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? activeModuleTypeId,
    Expression<int>? activeInverterId,
    Expression<double>? tAmbientMinC,
    Expression<double>? tAmbientMaxC,
    Expression<int>? gridPhases,
    Expression<double>? maxFeedInKw,
    Expression<bool>? hasMainEquipotential,
    Expression<bool>? isBoltedMounting,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (activeModuleTypeId != null)
        'active_module_type_id': activeModuleTypeId,
      if (activeInverterId != null) 'active_inverter_id': activeInverterId,
      if (tAmbientMinC != null) 't_ambient_min_c': tAmbientMinC,
      if (tAmbientMaxC != null) 't_ambient_max_c': tAmbientMaxC,
      if (gridPhases != null) 'grid_phases': gridPhases,
      if (maxFeedInKw != null) 'max_feed_in_kw': maxFeedInKw,
      if (hasMainEquipotential != null)
        'has_main_equipotential': hasMainEquipotential,
      if (isBoltedMounting != null) 'is_bolted_mounting': isBoltedMounting,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? address,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? activeModuleTypeId,
    Value<int?>? activeInverterId,
    Value<double>? tAmbientMinC,
    Value<double>? tAmbientMaxC,
    Value<int>? gridPhases,
    Value<double?>? maxFeedInKw,
    Value<bool>? hasMainEquipotential,
    Value<bool>? isBoltedMounting,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeModuleTypeId: activeModuleTypeId ?? this.activeModuleTypeId,
      activeInverterId: activeInverterId ?? this.activeInverterId,
      tAmbientMinC: tAmbientMinC ?? this.tAmbientMinC,
      tAmbientMaxC: tAmbientMaxC ?? this.tAmbientMaxC,
      gridPhases: gridPhases ?? this.gridPhases,
      maxFeedInKw: maxFeedInKw ?? this.maxFeedInKw,
      hasMainEquipotential: hasMainEquipotential ?? this.hasMainEquipotential,
      isBoltedMounting: isBoltedMounting ?? this.isBoltedMounting,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (activeModuleTypeId.present) {
      map['active_module_type_id'] = Variable<int>(activeModuleTypeId.value);
    }
    if (activeInverterId.present) {
      map['active_inverter_id'] = Variable<int>(activeInverterId.value);
    }
    if (tAmbientMinC.present) {
      map['t_ambient_min_c'] = Variable<double>(tAmbientMinC.value);
    }
    if (tAmbientMaxC.present) {
      map['t_ambient_max_c'] = Variable<double>(tAmbientMaxC.value);
    }
    if (gridPhases.present) {
      map['grid_phases'] = Variable<int>(gridPhases.value);
    }
    if (maxFeedInKw.present) {
      map['max_feed_in_kw'] = Variable<double>(maxFeedInKw.value);
    }
    if (hasMainEquipotential.present) {
      map['has_main_equipotential'] = Variable<bool>(
        hasMainEquipotential.value,
      );
    }
    if (isBoltedMounting.present) {
      map['is_bolted_mounting'] = Variable<bool>(isBoltedMounting.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('activeModuleTypeId: $activeModuleTypeId, ')
          ..write('activeInverterId: $activeInverterId, ')
          ..write('tAmbientMinC: $tAmbientMinC, ')
          ..write('tAmbientMaxC: $tAmbientMaxC, ')
          ..write('gridPhases: $gridPhases, ')
          ..write('maxFeedInKw: $maxFeedInKw, ')
          ..write('hasMainEquipotential: $hasMainEquipotential, ')
          ..write('isBoltedMounting: $isBoltedMounting')
          ..write(')'))
        .toString();
  }
}

class $RoofsTable extends Roofs with TableInfo<$RoofsTable, Roof> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoofsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polygonMeta = const VerificationMeta(
    'polygon',
  );
  @override
  late final GeneratedColumn<String> polygon = GeneratedColumn<String>(
    'polygon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMMeta = const VerificationMeta(
    'lengthM',
  );
  @override
  late final GeneratedColumn<double> lengthM = GeneratedColumn<double>(
    'length_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMMeta = const VerificationMeta('widthM');
  @override
  late final GeneratedColumn<double> widthM = GeneratedColumn<double>(
    'width_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pitchDegMeta = const VerificationMeta(
    'pitchDeg',
  );
  @override
  late final GeneratedColumn<double> pitchDeg = GeneratedColumn<double>(
    'pitch_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _azimuthDegMeta = const VerificationMeta(
    'azimuthDeg',
  );
  @override
  late final GeneratedColumn<double> azimuthDeg = GeneratedColumn<double>(
    'azimuth_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(180),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pitched'),
  );
  static const VerificationMeta _flatBaseHeightCmMeta = const VerificationMeta(
    'flatBaseHeightCm',
  );
  @override
  late final GeneratedColumn<double> flatBaseHeightCm = GeneratedColumn<double>(
    'flat_base_height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flatAttikaHeightCmMeta =
      const VerificationMeta('flatAttikaHeightCm');
  @override
  late final GeneratedColumn<double> flatAttikaHeightCm =
      GeneratedColumn<double>(
        'flat_attika_height_cm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _flatAttikaWidthCmMeta = const VerificationMeta(
    'flatAttikaWidthCm',
  );
  @override
  late final GeneratedColumn<double> flatAttikaWidthCm =
      GeneratedColumn<double>(
        'flat_attika_width_cm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rafterWidthCmMeta = const VerificationMeta(
    'rafterWidthCm',
  );
  @override
  late final GeneratedColumn<double> rafterWidthCm = GeneratedColumn<double>(
    'rafter_width_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rafterDepthCmMeta = const VerificationMeta(
    'rafterDepthCm',
  );
  @override
  late final GeneratedColumn<double> rafterDepthCm = GeneratedColumn<double>(
    'rafter_depth_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rafterSpacingCmMeta = const VerificationMeta(
    'rafterSpacingCm',
  );
  @override
  late final GeneratedColumn<double> rafterSpacingCm = GeneratedColumn<double>(
    'rafter_spacing_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _battenThicknessCmMeta = const VerificationMeta(
    'battenThicknessCm',
  );
  @override
  late final GeneratedColumn<double> battenThicknessCm =
      GeneratedColumn<double>(
        'batten_thickness_cm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rafterStraightMeta = const VerificationMeta(
    'rafterStraight',
  );
  @override
  late final GeneratedColumn<bool> rafterStraight = GeneratedColumn<bool>(
    'rafter_straight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rafter_straight" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hasCounterBattenMeta = const VerificationMeta(
    'hasCounterBatten',
  );
  @override
  late final GeneratedColumn<bool> hasCounterBatten = GeneratedColumn<bool>(
    'has_counter_batten',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_counter_batten" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tilesVisibleWidthMeta = const VerificationMeta(
    'tilesVisibleWidth',
  );
  @override
  late final GeneratedColumn<int> tilesVisibleWidth = GeneratedColumn<int>(
    'tiles_visible_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tilesVisibleHeightMeta =
      const VerificationMeta('tilesVisibleHeight');
  @override
  late final GeneratedColumn<int> tilesVisibleHeight = GeneratedColumn<int>(
    'tiles_visible_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tileOverlapCmMeta = const VerificationMeta(
    'tileOverlapCm',
  );
  @override
  late final GeneratedColumn<double> tileOverlapCm = GeneratedColumn<double>(
    'tile_overlap_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tileMaterialMeta = const VerificationMeta(
    'tileMaterial',
  );
  @override
  late final GeneratedColumn<String> tileMaterial = GeneratedColumn<String>(
    'tile_material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clay'),
  );
  static const VerificationMeta _hasSpareTilesMeta = const VerificationMeta(
    'hasSpareTiles',
  );
  @override
  late final GeneratedColumn<bool> hasSpareTiles = GeneratedColumn<bool>(
    'has_spare_tiles',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_spare_tiles" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasInsulationMeta = const VerificationMeta(
    'hasInsulation',
  );
  @override
  late final GeneratedColumn<bool> hasInsulation = GeneratedColumn<bool>(
    'has_insulation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_insulation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _insulationThicknessCmMeta =
      const VerificationMeta('insulationThicknessCm');
  @override
  late final GeneratedColumn<double> insulationThicknessCm =
      GeneratedColumn<double>(
        'insulation_thickness_cm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _moduleMarginMMeta = const VerificationMeta(
    'moduleMarginM',
  );
  @override
  late final GeneratedColumn<double> moduleMarginM = GeneratedColumn<double>(
    'module_margin_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moduleGapMMeta = const VerificationMeta(
    'moduleGapM',
  );
  @override
  late final GeneratedColumn<double> moduleGapM = GeneratedColumn<double>(
    'module_gap_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    polygon,
    lengthM,
    widthM,
    pitchDeg,
    azimuthDeg,
    type,
    flatBaseHeightCm,
    flatAttikaHeightCm,
    flatAttikaWidthCm,
    rafterWidthCm,
    rafterDepthCm,
    rafterSpacingCm,
    battenThicknessCm,
    rafterStraight,
    hasCounterBatten,
    tilesVisibleWidth,
    tilesVisibleHeight,
    tileOverlapCm,
    tileMaterial,
    hasSpareTiles,
    hasInsulation,
    insulationThicknessCm,
    moduleMarginM,
    moduleGapM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roofs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Roof> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('polygon')) {
      context.handle(
        _polygonMeta,
        polygon.isAcceptableOrUnknown(data['polygon']!, _polygonMeta),
      );
    } else if (isInserting) {
      context.missing(_polygonMeta);
    }
    if (data.containsKey('length_m')) {
      context.handle(
        _lengthMMeta,
        lengthM.isAcceptableOrUnknown(data['length_m']!, _lengthMMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthMMeta);
    }
    if (data.containsKey('width_m')) {
      context.handle(
        _widthMMeta,
        widthM.isAcceptableOrUnknown(data['width_m']!, _widthMMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMMeta);
    }
    if (data.containsKey('pitch_deg')) {
      context.handle(
        _pitchDegMeta,
        pitchDeg.isAcceptableOrUnknown(data['pitch_deg']!, _pitchDegMeta),
      );
    }
    if (data.containsKey('azimuth_deg')) {
      context.handle(
        _azimuthDegMeta,
        azimuthDeg.isAcceptableOrUnknown(data['azimuth_deg']!, _azimuthDegMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('flat_base_height_cm')) {
      context.handle(
        _flatBaseHeightCmMeta,
        flatBaseHeightCm.isAcceptableOrUnknown(
          data['flat_base_height_cm']!,
          _flatBaseHeightCmMeta,
        ),
      );
    }
    if (data.containsKey('flat_attika_height_cm')) {
      context.handle(
        _flatAttikaHeightCmMeta,
        flatAttikaHeightCm.isAcceptableOrUnknown(
          data['flat_attika_height_cm']!,
          _flatAttikaHeightCmMeta,
        ),
      );
    }
    if (data.containsKey('flat_attika_width_cm')) {
      context.handle(
        _flatAttikaWidthCmMeta,
        flatAttikaWidthCm.isAcceptableOrUnknown(
          data['flat_attika_width_cm']!,
          _flatAttikaWidthCmMeta,
        ),
      );
    }
    if (data.containsKey('rafter_width_cm')) {
      context.handle(
        _rafterWidthCmMeta,
        rafterWidthCm.isAcceptableOrUnknown(
          data['rafter_width_cm']!,
          _rafterWidthCmMeta,
        ),
      );
    }
    if (data.containsKey('rafter_depth_cm')) {
      context.handle(
        _rafterDepthCmMeta,
        rafterDepthCm.isAcceptableOrUnknown(
          data['rafter_depth_cm']!,
          _rafterDepthCmMeta,
        ),
      );
    }
    if (data.containsKey('rafter_spacing_cm')) {
      context.handle(
        _rafterSpacingCmMeta,
        rafterSpacingCm.isAcceptableOrUnknown(
          data['rafter_spacing_cm']!,
          _rafterSpacingCmMeta,
        ),
      );
    }
    if (data.containsKey('batten_thickness_cm')) {
      context.handle(
        _battenThicknessCmMeta,
        battenThicknessCm.isAcceptableOrUnknown(
          data['batten_thickness_cm']!,
          _battenThicknessCmMeta,
        ),
      );
    }
    if (data.containsKey('rafter_straight')) {
      context.handle(
        _rafterStraightMeta,
        rafterStraight.isAcceptableOrUnknown(
          data['rafter_straight']!,
          _rafterStraightMeta,
        ),
      );
    }
    if (data.containsKey('has_counter_batten')) {
      context.handle(
        _hasCounterBattenMeta,
        hasCounterBatten.isAcceptableOrUnknown(
          data['has_counter_batten']!,
          _hasCounterBattenMeta,
        ),
      );
    }
    if (data.containsKey('tiles_visible_width')) {
      context.handle(
        _tilesVisibleWidthMeta,
        tilesVisibleWidth.isAcceptableOrUnknown(
          data['tiles_visible_width']!,
          _tilesVisibleWidthMeta,
        ),
      );
    }
    if (data.containsKey('tiles_visible_height')) {
      context.handle(
        _tilesVisibleHeightMeta,
        tilesVisibleHeight.isAcceptableOrUnknown(
          data['tiles_visible_height']!,
          _tilesVisibleHeightMeta,
        ),
      );
    }
    if (data.containsKey('tile_overlap_cm')) {
      context.handle(
        _tileOverlapCmMeta,
        tileOverlapCm.isAcceptableOrUnknown(
          data['tile_overlap_cm']!,
          _tileOverlapCmMeta,
        ),
      );
    }
    if (data.containsKey('tile_material')) {
      context.handle(
        _tileMaterialMeta,
        tileMaterial.isAcceptableOrUnknown(
          data['tile_material']!,
          _tileMaterialMeta,
        ),
      );
    }
    if (data.containsKey('has_spare_tiles')) {
      context.handle(
        _hasSpareTilesMeta,
        hasSpareTiles.isAcceptableOrUnknown(
          data['has_spare_tiles']!,
          _hasSpareTilesMeta,
        ),
      );
    }
    if (data.containsKey('has_insulation')) {
      context.handle(
        _hasInsulationMeta,
        hasInsulation.isAcceptableOrUnknown(
          data['has_insulation']!,
          _hasInsulationMeta,
        ),
      );
    }
    if (data.containsKey('insulation_thickness_cm')) {
      context.handle(
        _insulationThicknessCmMeta,
        insulationThicknessCm.isAcceptableOrUnknown(
          data['insulation_thickness_cm']!,
          _insulationThicknessCmMeta,
        ),
      );
    }
    if (data.containsKey('module_margin_m')) {
      context.handle(
        _moduleMarginMMeta,
        moduleMarginM.isAcceptableOrUnknown(
          data['module_margin_m']!,
          _moduleMarginMMeta,
        ),
      );
    }
    if (data.containsKey('module_gap_m')) {
      context.handle(
        _moduleGapMMeta,
        moduleGapM.isAcceptableOrUnknown(
          data['module_gap_m']!,
          _moduleGapMMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Roof map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Roof(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      polygon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon'],
      )!,
      lengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_m'],
      )!,
      widthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_m'],
      )!,
      pitchDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pitch_deg'],
      )!,
      azimuthDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}azimuth_deg'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      flatBaseHeightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}flat_base_height_cm'],
      ),
      flatAttikaHeightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}flat_attika_height_cm'],
      ),
      flatAttikaWidthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}flat_attika_width_cm'],
      ),
      rafterWidthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rafter_width_cm'],
      ),
      rafterDepthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rafter_depth_cm'],
      ),
      rafterSpacingCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rafter_spacing_cm'],
      ),
      battenThicknessCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}batten_thickness_cm'],
      ),
      rafterStraight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rafter_straight'],
      )!,
      hasCounterBatten: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_counter_batten'],
      )!,
      tilesVisibleWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tiles_visible_width'],
      ),
      tilesVisibleHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tiles_visible_height'],
      ),
      tileOverlapCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tile_overlap_cm'],
      ),
      tileMaterial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tile_material'],
      )!,
      hasSpareTiles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_spare_tiles'],
      )!,
      hasInsulation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_insulation'],
      )!,
      insulationThicknessCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insulation_thickness_cm'],
      ),
      moduleMarginM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}module_margin_m'],
      ),
      moduleGapM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}module_gap_m'],
      ),
    );
  }

  @override
  $RoofsTable createAlias(String alias) {
    return $RoofsTable(attachedDatabase, alias);
  }
}

class Roof extends DataClass implements Insertable<Roof> {
  final int id;
  final int projectId;
  final String name;

  /// JSON-encoded list of [x, y] points in meters (plan view, y = north).
  final String polygon;

  /// Roof length (ridge direction) in meters.
  final double lengthM;

  /// Roof width (slope direction) in meters.
  final double widthM;

  /// Roof pitch in degrees (0 = flat).
  final double pitchDeg;

  /// Direction the roof faces/slopes down toward, degrees clockwise from
  /// north (180 = south).
  final double azimuthDeg;

  /// 'flat' or 'pitched'.
  final String type;

  /// Height of the lowest point above ground in cm.
  final double? flatBaseHeightCm;

  /// Parapet (Attika) height in cm.
  final double? flatAttikaHeightCm;

  /// Parapet (Attika) width in cm.
  final double? flatAttikaWidthCm;

  /// Rafter width in cm.
  final double? rafterWidthCm;

  /// Rafter depth in cm.
  final double? rafterDepthCm;

  /// Rafter spacing in cm.
  final double? rafterSpacingCm;

  /// Batten (Dachlatte) thickness in cm.
  final double? battenThicknessCm;

  /// Whether the rafters are straight.
  final bool rafterStraight;

  /// Whether counter-battens (Konterlattung) are used.
  final bool hasCounterBatten;

  /// Number of visible tile courses across the slope width.
  final int? tilesVisibleWidth;

  /// Number of visible tile courses up the slope height.
  final int? tilesVisibleHeight;

  /// Tile overlap (Überdeckung) in cm.
  final double? tileOverlapCm;

  /// 'clay' (Ton) or 'concrete' (Beton).
  final String tileMaterial;

  /// Whether spare tiles are available.
  final bool hasSpareTiles;

  /// Whether insulation (Aufsparrendämmung) is present.
  final bool hasInsulation;

  /// Insulation thickness in cm.
  final double? insulationThicknessCm;

  /// Edge margin for auto-filled modules, in meters. Null = use the default
  /// (one tile row ≈ 5 cm for pitched, 15 cm clearance for flat roofs).
  final double? moduleMarginM;

  /// Gap between auto-filled modules, in meters. Null = use the default
  /// (2 cm clamp width).
  final double? moduleGapM;
  const Roof({
    required this.id,
    required this.projectId,
    required this.name,
    required this.polygon,
    required this.lengthM,
    required this.widthM,
    required this.pitchDeg,
    required this.azimuthDeg,
    required this.type,
    this.flatBaseHeightCm,
    this.flatAttikaHeightCm,
    this.flatAttikaWidthCm,
    this.rafterWidthCm,
    this.rafterDepthCm,
    this.rafterSpacingCm,
    this.battenThicknessCm,
    required this.rafterStraight,
    required this.hasCounterBatten,
    this.tilesVisibleWidth,
    this.tilesVisibleHeight,
    this.tileOverlapCm,
    required this.tileMaterial,
    required this.hasSpareTiles,
    required this.hasInsulation,
    this.insulationThicknessCm,
    this.moduleMarginM,
    this.moduleGapM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['name'] = Variable<String>(name);
    map['polygon'] = Variable<String>(polygon);
    map['length_m'] = Variable<double>(lengthM);
    map['width_m'] = Variable<double>(widthM);
    map['pitch_deg'] = Variable<double>(pitchDeg);
    map['azimuth_deg'] = Variable<double>(azimuthDeg);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || flatBaseHeightCm != null) {
      map['flat_base_height_cm'] = Variable<double>(flatBaseHeightCm);
    }
    if (!nullToAbsent || flatAttikaHeightCm != null) {
      map['flat_attika_height_cm'] = Variable<double>(flatAttikaHeightCm);
    }
    if (!nullToAbsent || flatAttikaWidthCm != null) {
      map['flat_attika_width_cm'] = Variable<double>(flatAttikaWidthCm);
    }
    if (!nullToAbsent || rafterWidthCm != null) {
      map['rafter_width_cm'] = Variable<double>(rafterWidthCm);
    }
    if (!nullToAbsent || rafterDepthCm != null) {
      map['rafter_depth_cm'] = Variable<double>(rafterDepthCm);
    }
    if (!nullToAbsent || rafterSpacingCm != null) {
      map['rafter_spacing_cm'] = Variable<double>(rafterSpacingCm);
    }
    if (!nullToAbsent || battenThicknessCm != null) {
      map['batten_thickness_cm'] = Variable<double>(battenThicknessCm);
    }
    map['rafter_straight'] = Variable<bool>(rafterStraight);
    map['has_counter_batten'] = Variable<bool>(hasCounterBatten);
    if (!nullToAbsent || tilesVisibleWidth != null) {
      map['tiles_visible_width'] = Variable<int>(tilesVisibleWidth);
    }
    if (!nullToAbsent || tilesVisibleHeight != null) {
      map['tiles_visible_height'] = Variable<int>(tilesVisibleHeight);
    }
    if (!nullToAbsent || tileOverlapCm != null) {
      map['tile_overlap_cm'] = Variable<double>(tileOverlapCm);
    }
    map['tile_material'] = Variable<String>(tileMaterial);
    map['has_spare_tiles'] = Variable<bool>(hasSpareTiles);
    map['has_insulation'] = Variable<bool>(hasInsulation);
    if (!nullToAbsent || insulationThicknessCm != null) {
      map['insulation_thickness_cm'] = Variable<double>(insulationThicknessCm);
    }
    if (!nullToAbsent || moduleMarginM != null) {
      map['module_margin_m'] = Variable<double>(moduleMarginM);
    }
    if (!nullToAbsent || moduleGapM != null) {
      map['module_gap_m'] = Variable<double>(moduleGapM);
    }
    return map;
  }

  RoofsCompanion toCompanion(bool nullToAbsent) {
    return RoofsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      polygon: Value(polygon),
      lengthM: Value(lengthM),
      widthM: Value(widthM),
      pitchDeg: Value(pitchDeg),
      azimuthDeg: Value(azimuthDeg),
      type: Value(type),
      flatBaseHeightCm: flatBaseHeightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(flatBaseHeightCm),
      flatAttikaHeightCm: flatAttikaHeightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(flatAttikaHeightCm),
      flatAttikaWidthCm: flatAttikaWidthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(flatAttikaWidthCm),
      rafterWidthCm: rafterWidthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rafterWidthCm),
      rafterDepthCm: rafterDepthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rafterDepthCm),
      rafterSpacingCm: rafterSpacingCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rafterSpacingCm),
      battenThicknessCm: battenThicknessCm == null && nullToAbsent
          ? const Value.absent()
          : Value(battenThicknessCm),
      rafterStraight: Value(rafterStraight),
      hasCounterBatten: Value(hasCounterBatten),
      tilesVisibleWidth: tilesVisibleWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(tilesVisibleWidth),
      tilesVisibleHeight: tilesVisibleHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(tilesVisibleHeight),
      tileOverlapCm: tileOverlapCm == null && nullToAbsent
          ? const Value.absent()
          : Value(tileOverlapCm),
      tileMaterial: Value(tileMaterial),
      hasSpareTiles: Value(hasSpareTiles),
      hasInsulation: Value(hasInsulation),
      insulationThicknessCm: insulationThicknessCm == null && nullToAbsent
          ? const Value.absent()
          : Value(insulationThicknessCm),
      moduleMarginM: moduleMarginM == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleMarginM),
      moduleGapM: moduleGapM == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleGapM),
    );
  }

  factory Roof.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Roof(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      polygon: serializer.fromJson<String>(json['polygon']),
      lengthM: serializer.fromJson<double>(json['lengthM']),
      widthM: serializer.fromJson<double>(json['widthM']),
      pitchDeg: serializer.fromJson<double>(json['pitchDeg']),
      azimuthDeg: serializer.fromJson<double>(json['azimuthDeg']),
      type: serializer.fromJson<String>(json['type']),
      flatBaseHeightCm: serializer.fromJson<double?>(json['flatBaseHeightCm']),
      flatAttikaHeightCm: serializer.fromJson<double?>(
        json['flatAttikaHeightCm'],
      ),
      flatAttikaWidthCm: serializer.fromJson<double?>(
        json['flatAttikaWidthCm'],
      ),
      rafterWidthCm: serializer.fromJson<double?>(json['rafterWidthCm']),
      rafterDepthCm: serializer.fromJson<double?>(json['rafterDepthCm']),
      rafterSpacingCm: serializer.fromJson<double?>(json['rafterSpacingCm']),
      battenThicknessCm: serializer.fromJson<double?>(
        json['battenThicknessCm'],
      ),
      rafterStraight: serializer.fromJson<bool>(json['rafterStraight']),
      hasCounterBatten: serializer.fromJson<bool>(json['hasCounterBatten']),
      tilesVisibleWidth: serializer.fromJson<int?>(json['tilesVisibleWidth']),
      tilesVisibleHeight: serializer.fromJson<int?>(json['tilesVisibleHeight']),
      tileOverlapCm: serializer.fromJson<double?>(json['tileOverlapCm']),
      tileMaterial: serializer.fromJson<String>(json['tileMaterial']),
      hasSpareTiles: serializer.fromJson<bool>(json['hasSpareTiles']),
      hasInsulation: serializer.fromJson<bool>(json['hasInsulation']),
      insulationThicknessCm: serializer.fromJson<double?>(
        json['insulationThicknessCm'],
      ),
      moduleMarginM: serializer.fromJson<double?>(json['moduleMarginM']),
      moduleGapM: serializer.fromJson<double?>(json['moduleGapM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'name': serializer.toJson<String>(name),
      'polygon': serializer.toJson<String>(polygon),
      'lengthM': serializer.toJson<double>(lengthM),
      'widthM': serializer.toJson<double>(widthM),
      'pitchDeg': serializer.toJson<double>(pitchDeg),
      'azimuthDeg': serializer.toJson<double>(azimuthDeg),
      'type': serializer.toJson<String>(type),
      'flatBaseHeightCm': serializer.toJson<double?>(flatBaseHeightCm),
      'flatAttikaHeightCm': serializer.toJson<double?>(flatAttikaHeightCm),
      'flatAttikaWidthCm': serializer.toJson<double?>(flatAttikaWidthCm),
      'rafterWidthCm': serializer.toJson<double?>(rafterWidthCm),
      'rafterDepthCm': serializer.toJson<double?>(rafterDepthCm),
      'rafterSpacingCm': serializer.toJson<double?>(rafterSpacingCm),
      'battenThicknessCm': serializer.toJson<double?>(battenThicknessCm),
      'rafterStraight': serializer.toJson<bool>(rafterStraight),
      'hasCounterBatten': serializer.toJson<bool>(hasCounterBatten),
      'tilesVisibleWidth': serializer.toJson<int?>(tilesVisibleWidth),
      'tilesVisibleHeight': serializer.toJson<int?>(tilesVisibleHeight),
      'tileOverlapCm': serializer.toJson<double?>(tileOverlapCm),
      'tileMaterial': serializer.toJson<String>(tileMaterial),
      'hasSpareTiles': serializer.toJson<bool>(hasSpareTiles),
      'hasInsulation': serializer.toJson<bool>(hasInsulation),
      'insulationThicknessCm': serializer.toJson<double?>(
        insulationThicknessCm,
      ),
      'moduleMarginM': serializer.toJson<double?>(moduleMarginM),
      'moduleGapM': serializer.toJson<double?>(moduleGapM),
    };
  }

  Roof copyWith({
    int? id,
    int? projectId,
    String? name,
    String? polygon,
    double? lengthM,
    double? widthM,
    double? pitchDeg,
    double? azimuthDeg,
    String? type,
    Value<double?> flatBaseHeightCm = const Value.absent(),
    Value<double?> flatAttikaHeightCm = const Value.absent(),
    Value<double?> flatAttikaWidthCm = const Value.absent(),
    Value<double?> rafterWidthCm = const Value.absent(),
    Value<double?> rafterDepthCm = const Value.absent(),
    Value<double?> rafterSpacingCm = const Value.absent(),
    Value<double?> battenThicknessCm = const Value.absent(),
    bool? rafterStraight,
    bool? hasCounterBatten,
    Value<int?> tilesVisibleWidth = const Value.absent(),
    Value<int?> tilesVisibleHeight = const Value.absent(),
    Value<double?> tileOverlapCm = const Value.absent(),
    String? tileMaterial,
    bool? hasSpareTiles,
    bool? hasInsulation,
    Value<double?> insulationThicknessCm = const Value.absent(),
    Value<double?> moduleMarginM = const Value.absent(),
    Value<double?> moduleGapM = const Value.absent(),
  }) => Roof(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    polygon: polygon ?? this.polygon,
    lengthM: lengthM ?? this.lengthM,
    widthM: widthM ?? this.widthM,
    pitchDeg: pitchDeg ?? this.pitchDeg,
    azimuthDeg: azimuthDeg ?? this.azimuthDeg,
    type: type ?? this.type,
    flatBaseHeightCm: flatBaseHeightCm.present
        ? flatBaseHeightCm.value
        : this.flatBaseHeightCm,
    flatAttikaHeightCm: flatAttikaHeightCm.present
        ? flatAttikaHeightCm.value
        : this.flatAttikaHeightCm,
    flatAttikaWidthCm: flatAttikaWidthCm.present
        ? flatAttikaWidthCm.value
        : this.flatAttikaWidthCm,
    rafterWidthCm: rafterWidthCm.present
        ? rafterWidthCm.value
        : this.rafterWidthCm,
    rafterDepthCm: rafterDepthCm.present
        ? rafterDepthCm.value
        : this.rafterDepthCm,
    rafterSpacingCm: rafterSpacingCm.present
        ? rafterSpacingCm.value
        : this.rafterSpacingCm,
    battenThicknessCm: battenThicknessCm.present
        ? battenThicknessCm.value
        : this.battenThicknessCm,
    rafterStraight: rafterStraight ?? this.rafterStraight,
    hasCounterBatten: hasCounterBatten ?? this.hasCounterBatten,
    tilesVisibleWidth: tilesVisibleWidth.present
        ? tilesVisibleWidth.value
        : this.tilesVisibleWidth,
    tilesVisibleHeight: tilesVisibleHeight.present
        ? tilesVisibleHeight.value
        : this.tilesVisibleHeight,
    tileOverlapCm: tileOverlapCm.present
        ? tileOverlapCm.value
        : this.tileOverlapCm,
    tileMaterial: tileMaterial ?? this.tileMaterial,
    hasSpareTiles: hasSpareTiles ?? this.hasSpareTiles,
    hasInsulation: hasInsulation ?? this.hasInsulation,
    insulationThicknessCm: insulationThicknessCm.present
        ? insulationThicknessCm.value
        : this.insulationThicknessCm,
    moduleMarginM: moduleMarginM.present
        ? moduleMarginM.value
        : this.moduleMarginM,
    moduleGapM: moduleGapM.present ? moduleGapM.value : this.moduleGapM,
  );
  Roof copyWithCompanion(RoofsCompanion data) {
    return Roof(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      polygon: data.polygon.present ? data.polygon.value : this.polygon,
      lengthM: data.lengthM.present ? data.lengthM.value : this.lengthM,
      widthM: data.widthM.present ? data.widthM.value : this.widthM,
      pitchDeg: data.pitchDeg.present ? data.pitchDeg.value : this.pitchDeg,
      azimuthDeg: data.azimuthDeg.present
          ? data.azimuthDeg.value
          : this.azimuthDeg,
      type: data.type.present ? data.type.value : this.type,
      flatBaseHeightCm: data.flatBaseHeightCm.present
          ? data.flatBaseHeightCm.value
          : this.flatBaseHeightCm,
      flatAttikaHeightCm: data.flatAttikaHeightCm.present
          ? data.flatAttikaHeightCm.value
          : this.flatAttikaHeightCm,
      flatAttikaWidthCm: data.flatAttikaWidthCm.present
          ? data.flatAttikaWidthCm.value
          : this.flatAttikaWidthCm,
      rafterWidthCm: data.rafterWidthCm.present
          ? data.rafterWidthCm.value
          : this.rafterWidthCm,
      rafterDepthCm: data.rafterDepthCm.present
          ? data.rafterDepthCm.value
          : this.rafterDepthCm,
      rafterSpacingCm: data.rafterSpacingCm.present
          ? data.rafterSpacingCm.value
          : this.rafterSpacingCm,
      battenThicknessCm: data.battenThicknessCm.present
          ? data.battenThicknessCm.value
          : this.battenThicknessCm,
      rafterStraight: data.rafterStraight.present
          ? data.rafterStraight.value
          : this.rafterStraight,
      hasCounterBatten: data.hasCounterBatten.present
          ? data.hasCounterBatten.value
          : this.hasCounterBatten,
      tilesVisibleWidth: data.tilesVisibleWidth.present
          ? data.tilesVisibleWidth.value
          : this.tilesVisibleWidth,
      tilesVisibleHeight: data.tilesVisibleHeight.present
          ? data.tilesVisibleHeight.value
          : this.tilesVisibleHeight,
      tileOverlapCm: data.tileOverlapCm.present
          ? data.tileOverlapCm.value
          : this.tileOverlapCm,
      tileMaterial: data.tileMaterial.present
          ? data.tileMaterial.value
          : this.tileMaterial,
      hasSpareTiles: data.hasSpareTiles.present
          ? data.hasSpareTiles.value
          : this.hasSpareTiles,
      hasInsulation: data.hasInsulation.present
          ? data.hasInsulation.value
          : this.hasInsulation,
      insulationThicknessCm: data.insulationThicknessCm.present
          ? data.insulationThicknessCm.value
          : this.insulationThicknessCm,
      moduleMarginM: data.moduleMarginM.present
          ? data.moduleMarginM.value
          : this.moduleMarginM,
      moduleGapM: data.moduleGapM.present
          ? data.moduleGapM.value
          : this.moduleGapM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Roof(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('polygon: $polygon, ')
          ..write('lengthM: $lengthM, ')
          ..write('widthM: $widthM, ')
          ..write('pitchDeg: $pitchDeg, ')
          ..write('azimuthDeg: $azimuthDeg, ')
          ..write('type: $type, ')
          ..write('flatBaseHeightCm: $flatBaseHeightCm, ')
          ..write('flatAttikaHeightCm: $flatAttikaHeightCm, ')
          ..write('flatAttikaWidthCm: $flatAttikaWidthCm, ')
          ..write('rafterWidthCm: $rafterWidthCm, ')
          ..write('rafterDepthCm: $rafterDepthCm, ')
          ..write('rafterSpacingCm: $rafterSpacingCm, ')
          ..write('battenThicknessCm: $battenThicknessCm, ')
          ..write('rafterStraight: $rafterStraight, ')
          ..write('hasCounterBatten: $hasCounterBatten, ')
          ..write('tilesVisibleWidth: $tilesVisibleWidth, ')
          ..write('tilesVisibleHeight: $tilesVisibleHeight, ')
          ..write('tileOverlapCm: $tileOverlapCm, ')
          ..write('tileMaterial: $tileMaterial, ')
          ..write('hasSpareTiles: $hasSpareTiles, ')
          ..write('hasInsulation: $hasInsulation, ')
          ..write('insulationThicknessCm: $insulationThicknessCm, ')
          ..write('moduleMarginM: $moduleMarginM, ')
          ..write('moduleGapM: $moduleGapM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    projectId,
    name,
    polygon,
    lengthM,
    widthM,
    pitchDeg,
    azimuthDeg,
    type,
    flatBaseHeightCm,
    flatAttikaHeightCm,
    flatAttikaWidthCm,
    rafterWidthCm,
    rafterDepthCm,
    rafterSpacingCm,
    battenThicknessCm,
    rafterStraight,
    hasCounterBatten,
    tilesVisibleWidth,
    tilesVisibleHeight,
    tileOverlapCm,
    tileMaterial,
    hasSpareTiles,
    hasInsulation,
    insulationThicknessCm,
    moduleMarginM,
    moduleGapM,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Roof &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.polygon == this.polygon &&
          other.lengthM == this.lengthM &&
          other.widthM == this.widthM &&
          other.pitchDeg == this.pitchDeg &&
          other.azimuthDeg == this.azimuthDeg &&
          other.type == this.type &&
          other.flatBaseHeightCm == this.flatBaseHeightCm &&
          other.flatAttikaHeightCm == this.flatAttikaHeightCm &&
          other.flatAttikaWidthCm == this.flatAttikaWidthCm &&
          other.rafterWidthCm == this.rafterWidthCm &&
          other.rafterDepthCm == this.rafterDepthCm &&
          other.rafterSpacingCm == this.rafterSpacingCm &&
          other.battenThicknessCm == this.battenThicknessCm &&
          other.rafterStraight == this.rafterStraight &&
          other.hasCounterBatten == this.hasCounterBatten &&
          other.tilesVisibleWidth == this.tilesVisibleWidth &&
          other.tilesVisibleHeight == this.tilesVisibleHeight &&
          other.tileOverlapCm == this.tileOverlapCm &&
          other.tileMaterial == this.tileMaterial &&
          other.hasSpareTiles == this.hasSpareTiles &&
          other.hasInsulation == this.hasInsulation &&
          other.insulationThicknessCm == this.insulationThicknessCm &&
          other.moduleMarginM == this.moduleMarginM &&
          other.moduleGapM == this.moduleGapM);
}

class RoofsCompanion extends UpdateCompanion<Roof> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> name;
  final Value<String> polygon;
  final Value<double> lengthM;
  final Value<double> widthM;
  final Value<double> pitchDeg;
  final Value<double> azimuthDeg;
  final Value<String> type;
  final Value<double?> flatBaseHeightCm;
  final Value<double?> flatAttikaHeightCm;
  final Value<double?> flatAttikaWidthCm;
  final Value<double?> rafterWidthCm;
  final Value<double?> rafterDepthCm;
  final Value<double?> rafterSpacingCm;
  final Value<double?> battenThicknessCm;
  final Value<bool> rafterStraight;
  final Value<bool> hasCounterBatten;
  final Value<int?> tilesVisibleWidth;
  final Value<int?> tilesVisibleHeight;
  final Value<double?> tileOverlapCm;
  final Value<String> tileMaterial;
  final Value<bool> hasSpareTiles;
  final Value<bool> hasInsulation;
  final Value<double?> insulationThicknessCm;
  final Value<double?> moduleMarginM;
  final Value<double?> moduleGapM;
  const RoofsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.polygon = const Value.absent(),
    this.lengthM = const Value.absent(),
    this.widthM = const Value.absent(),
    this.pitchDeg = const Value.absent(),
    this.azimuthDeg = const Value.absent(),
    this.type = const Value.absent(),
    this.flatBaseHeightCm = const Value.absent(),
    this.flatAttikaHeightCm = const Value.absent(),
    this.flatAttikaWidthCm = const Value.absent(),
    this.rafterWidthCm = const Value.absent(),
    this.rafterDepthCm = const Value.absent(),
    this.rafterSpacingCm = const Value.absent(),
    this.battenThicknessCm = const Value.absent(),
    this.rafterStraight = const Value.absent(),
    this.hasCounterBatten = const Value.absent(),
    this.tilesVisibleWidth = const Value.absent(),
    this.tilesVisibleHeight = const Value.absent(),
    this.tileOverlapCm = const Value.absent(),
    this.tileMaterial = const Value.absent(),
    this.hasSpareTiles = const Value.absent(),
    this.hasInsulation = const Value.absent(),
    this.insulationThicknessCm = const Value.absent(),
    this.moduleMarginM = const Value.absent(),
    this.moduleGapM = const Value.absent(),
  });
  RoofsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String name,
    required String polygon,
    required double lengthM,
    required double widthM,
    this.pitchDeg = const Value.absent(),
    this.azimuthDeg = const Value.absent(),
    this.type = const Value.absent(),
    this.flatBaseHeightCm = const Value.absent(),
    this.flatAttikaHeightCm = const Value.absent(),
    this.flatAttikaWidthCm = const Value.absent(),
    this.rafterWidthCm = const Value.absent(),
    this.rafterDepthCm = const Value.absent(),
    this.rafterSpacingCm = const Value.absent(),
    this.battenThicknessCm = const Value.absent(),
    this.rafterStraight = const Value.absent(),
    this.hasCounterBatten = const Value.absent(),
    this.tilesVisibleWidth = const Value.absent(),
    this.tilesVisibleHeight = const Value.absent(),
    this.tileOverlapCm = const Value.absent(),
    this.tileMaterial = const Value.absent(),
    this.hasSpareTiles = const Value.absent(),
    this.hasInsulation = const Value.absent(),
    this.insulationThicknessCm = const Value.absent(),
    this.moduleMarginM = const Value.absent(),
    this.moduleGapM = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name),
       polygon = Value(polygon),
       lengthM = Value(lengthM),
       widthM = Value(widthM);
  static Insertable<Roof> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? name,
    Expression<String>? polygon,
    Expression<double>? lengthM,
    Expression<double>? widthM,
    Expression<double>? pitchDeg,
    Expression<double>? azimuthDeg,
    Expression<String>? type,
    Expression<double>? flatBaseHeightCm,
    Expression<double>? flatAttikaHeightCm,
    Expression<double>? flatAttikaWidthCm,
    Expression<double>? rafterWidthCm,
    Expression<double>? rafterDepthCm,
    Expression<double>? rafterSpacingCm,
    Expression<double>? battenThicknessCm,
    Expression<bool>? rafterStraight,
    Expression<bool>? hasCounterBatten,
    Expression<int>? tilesVisibleWidth,
    Expression<int>? tilesVisibleHeight,
    Expression<double>? tileOverlapCm,
    Expression<String>? tileMaterial,
    Expression<bool>? hasSpareTiles,
    Expression<bool>? hasInsulation,
    Expression<double>? insulationThicknessCm,
    Expression<double>? moduleMarginM,
    Expression<double>? moduleGapM,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (polygon != null) 'polygon': polygon,
      if (lengthM != null) 'length_m': lengthM,
      if (widthM != null) 'width_m': widthM,
      if (pitchDeg != null) 'pitch_deg': pitchDeg,
      if (azimuthDeg != null) 'azimuth_deg': azimuthDeg,
      if (type != null) 'type': type,
      if (flatBaseHeightCm != null) 'flat_base_height_cm': flatBaseHeightCm,
      if (flatAttikaHeightCm != null)
        'flat_attika_height_cm': flatAttikaHeightCm,
      if (flatAttikaWidthCm != null) 'flat_attika_width_cm': flatAttikaWidthCm,
      if (rafterWidthCm != null) 'rafter_width_cm': rafterWidthCm,
      if (rafterDepthCm != null) 'rafter_depth_cm': rafterDepthCm,
      if (rafterSpacingCm != null) 'rafter_spacing_cm': rafterSpacingCm,
      if (battenThicknessCm != null) 'batten_thickness_cm': battenThicknessCm,
      if (rafterStraight != null) 'rafter_straight': rafterStraight,
      if (hasCounterBatten != null) 'has_counter_batten': hasCounterBatten,
      if (tilesVisibleWidth != null) 'tiles_visible_width': tilesVisibleWidth,
      if (tilesVisibleHeight != null)
        'tiles_visible_height': tilesVisibleHeight,
      if (tileOverlapCm != null) 'tile_overlap_cm': tileOverlapCm,
      if (tileMaterial != null) 'tile_material': tileMaterial,
      if (hasSpareTiles != null) 'has_spare_tiles': hasSpareTiles,
      if (hasInsulation != null) 'has_insulation': hasInsulation,
      if (insulationThicknessCm != null)
        'insulation_thickness_cm': insulationThicknessCm,
      if (moduleMarginM != null) 'module_margin_m': moduleMarginM,
      if (moduleGapM != null) 'module_gap_m': moduleGapM,
    });
  }

  RoofsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? name,
    Value<String>? polygon,
    Value<double>? lengthM,
    Value<double>? widthM,
    Value<double>? pitchDeg,
    Value<double>? azimuthDeg,
    Value<String>? type,
    Value<double?>? flatBaseHeightCm,
    Value<double?>? flatAttikaHeightCm,
    Value<double?>? flatAttikaWidthCm,
    Value<double?>? rafterWidthCm,
    Value<double?>? rafterDepthCm,
    Value<double?>? rafterSpacingCm,
    Value<double?>? battenThicknessCm,
    Value<bool>? rafterStraight,
    Value<bool>? hasCounterBatten,
    Value<int?>? tilesVisibleWidth,
    Value<int?>? tilesVisibleHeight,
    Value<double?>? tileOverlapCm,
    Value<String>? tileMaterial,
    Value<bool>? hasSpareTiles,
    Value<bool>? hasInsulation,
    Value<double?>? insulationThicknessCm,
    Value<double?>? moduleMarginM,
    Value<double?>? moduleGapM,
  }) {
    return RoofsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      polygon: polygon ?? this.polygon,
      lengthM: lengthM ?? this.lengthM,
      widthM: widthM ?? this.widthM,
      pitchDeg: pitchDeg ?? this.pitchDeg,
      azimuthDeg: azimuthDeg ?? this.azimuthDeg,
      type: type ?? this.type,
      flatBaseHeightCm: flatBaseHeightCm ?? this.flatBaseHeightCm,
      flatAttikaHeightCm: flatAttikaHeightCm ?? this.flatAttikaHeightCm,
      flatAttikaWidthCm: flatAttikaWidthCm ?? this.flatAttikaWidthCm,
      rafterWidthCm: rafterWidthCm ?? this.rafterWidthCm,
      rafterDepthCm: rafterDepthCm ?? this.rafterDepthCm,
      rafterSpacingCm: rafterSpacingCm ?? this.rafterSpacingCm,
      battenThicknessCm: battenThicknessCm ?? this.battenThicknessCm,
      rafterStraight: rafterStraight ?? this.rafterStraight,
      hasCounterBatten: hasCounterBatten ?? this.hasCounterBatten,
      tilesVisibleWidth: tilesVisibleWidth ?? this.tilesVisibleWidth,
      tilesVisibleHeight: tilesVisibleHeight ?? this.tilesVisibleHeight,
      tileOverlapCm: tileOverlapCm ?? this.tileOverlapCm,
      tileMaterial: tileMaterial ?? this.tileMaterial,
      hasSpareTiles: hasSpareTiles ?? this.hasSpareTiles,
      hasInsulation: hasInsulation ?? this.hasInsulation,
      insulationThicknessCm:
          insulationThicknessCm ?? this.insulationThicknessCm,
      moduleMarginM: moduleMarginM ?? this.moduleMarginM,
      moduleGapM: moduleGapM ?? this.moduleGapM,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (polygon.present) {
      map['polygon'] = Variable<String>(polygon.value);
    }
    if (lengthM.present) {
      map['length_m'] = Variable<double>(lengthM.value);
    }
    if (widthM.present) {
      map['width_m'] = Variable<double>(widthM.value);
    }
    if (pitchDeg.present) {
      map['pitch_deg'] = Variable<double>(pitchDeg.value);
    }
    if (azimuthDeg.present) {
      map['azimuth_deg'] = Variable<double>(azimuthDeg.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (flatBaseHeightCm.present) {
      map['flat_base_height_cm'] = Variable<double>(flatBaseHeightCm.value);
    }
    if (flatAttikaHeightCm.present) {
      map['flat_attika_height_cm'] = Variable<double>(flatAttikaHeightCm.value);
    }
    if (flatAttikaWidthCm.present) {
      map['flat_attika_width_cm'] = Variable<double>(flatAttikaWidthCm.value);
    }
    if (rafterWidthCm.present) {
      map['rafter_width_cm'] = Variable<double>(rafterWidthCm.value);
    }
    if (rafterDepthCm.present) {
      map['rafter_depth_cm'] = Variable<double>(rafterDepthCm.value);
    }
    if (rafterSpacingCm.present) {
      map['rafter_spacing_cm'] = Variable<double>(rafterSpacingCm.value);
    }
    if (battenThicknessCm.present) {
      map['batten_thickness_cm'] = Variable<double>(battenThicknessCm.value);
    }
    if (rafterStraight.present) {
      map['rafter_straight'] = Variable<bool>(rafterStraight.value);
    }
    if (hasCounterBatten.present) {
      map['has_counter_batten'] = Variable<bool>(hasCounterBatten.value);
    }
    if (tilesVisibleWidth.present) {
      map['tiles_visible_width'] = Variable<int>(tilesVisibleWidth.value);
    }
    if (tilesVisibleHeight.present) {
      map['tiles_visible_height'] = Variable<int>(tilesVisibleHeight.value);
    }
    if (tileOverlapCm.present) {
      map['tile_overlap_cm'] = Variable<double>(tileOverlapCm.value);
    }
    if (tileMaterial.present) {
      map['tile_material'] = Variable<String>(tileMaterial.value);
    }
    if (hasSpareTiles.present) {
      map['has_spare_tiles'] = Variable<bool>(hasSpareTiles.value);
    }
    if (hasInsulation.present) {
      map['has_insulation'] = Variable<bool>(hasInsulation.value);
    }
    if (insulationThicknessCm.present) {
      map['insulation_thickness_cm'] = Variable<double>(
        insulationThicknessCm.value,
      );
    }
    if (moduleMarginM.present) {
      map['module_margin_m'] = Variable<double>(moduleMarginM.value);
    }
    if (moduleGapM.present) {
      map['module_gap_m'] = Variable<double>(moduleGapM.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoofsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('polygon: $polygon, ')
          ..write('lengthM: $lengthM, ')
          ..write('widthM: $widthM, ')
          ..write('pitchDeg: $pitchDeg, ')
          ..write('azimuthDeg: $azimuthDeg, ')
          ..write('type: $type, ')
          ..write('flatBaseHeightCm: $flatBaseHeightCm, ')
          ..write('flatAttikaHeightCm: $flatAttikaHeightCm, ')
          ..write('flatAttikaWidthCm: $flatAttikaWidthCm, ')
          ..write('rafterWidthCm: $rafterWidthCm, ')
          ..write('rafterDepthCm: $rafterDepthCm, ')
          ..write('rafterSpacingCm: $rafterSpacingCm, ')
          ..write('battenThicknessCm: $battenThicknessCm, ')
          ..write('rafterStraight: $rafterStraight, ')
          ..write('hasCounterBatten: $hasCounterBatten, ')
          ..write('tilesVisibleWidth: $tilesVisibleWidth, ')
          ..write('tilesVisibleHeight: $tilesVisibleHeight, ')
          ..write('tileOverlapCm: $tileOverlapCm, ')
          ..write('tileMaterial: $tileMaterial, ')
          ..write('hasSpareTiles: $hasSpareTiles, ')
          ..write('hasInsulation: $hasInsulation, ')
          ..write('insulationThicknessCm: $insulationThicknessCm, ')
          ..write('moduleMarginM: $moduleMarginM, ')
          ..write('moduleGapM: $moduleGapM')
          ..write(')'))
        .toString();
  }
}

class $ObstaclesTable extends Obstacles
    with TableInfo<$ObstaclesTable, Obstacle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObstaclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polygonMeta = const VerificationMeta(
    'polygon',
  );
  @override
  late final GeneratedColumn<String> polygon = GeneratedColumn<String>(
    'polygon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMMeta = const VerificationMeta(
    'heightM',
  );
  @override
  late final GeneratedColumn<double> heightM = GeneratedColumn<double>(
    'height_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, kind, polygon, heightM];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obstacles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Obstacle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('polygon')) {
      context.handle(
        _polygonMeta,
        polygon.isAcceptableOrUnknown(data['polygon']!, _polygonMeta),
      );
    } else if (isInserting) {
      context.missing(_polygonMeta);
    }
    if (data.containsKey('height_m')) {
      context.handle(
        _heightMMeta,
        heightM.isAcceptableOrUnknown(data['height_m']!, _heightMMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Obstacle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Obstacle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      polygon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon'],
      )!,
      heightM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_m'],
      )!,
    );
  }

  @override
  $ObstaclesTable createAlias(String alias) {
    return $ObstaclesTable(attachedDatabase, alias);
  }
}

class Obstacle extends DataClass implements Insertable<Obstacle> {
  final int id;
  final int projectId;

  /// One of: chimney, tree, building, other.
  final String kind;

  /// JSON-encoded polygon in meters (plan view).
  final String polygon;

  /// Height above ground in meters.
  final double heightM;
  const Obstacle({
    required this.id,
    required this.projectId,
    required this.kind,
    required this.polygon,
    required this.heightM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['kind'] = Variable<String>(kind);
    map['polygon'] = Variable<String>(polygon);
    map['height_m'] = Variable<double>(heightM);
    return map;
  }

  ObstaclesCompanion toCompanion(bool nullToAbsent) {
    return ObstaclesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      kind: Value(kind),
      polygon: Value(polygon),
      heightM: Value(heightM),
    );
  }

  factory Obstacle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Obstacle(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      kind: serializer.fromJson<String>(json['kind']),
      polygon: serializer.fromJson<String>(json['polygon']),
      heightM: serializer.fromJson<double>(json['heightM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'kind': serializer.toJson<String>(kind),
      'polygon': serializer.toJson<String>(polygon),
      'heightM': serializer.toJson<double>(heightM),
    };
  }

  Obstacle copyWith({
    int? id,
    int? projectId,
    String? kind,
    String? polygon,
    double? heightM,
  }) => Obstacle(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    kind: kind ?? this.kind,
    polygon: polygon ?? this.polygon,
    heightM: heightM ?? this.heightM,
  );
  Obstacle copyWithCompanion(ObstaclesCompanion data) {
    return Obstacle(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      kind: data.kind.present ? data.kind.value : this.kind,
      polygon: data.polygon.present ? data.polygon.value : this.polygon,
      heightM: data.heightM.present ? data.heightM.value : this.heightM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Obstacle(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('polygon: $polygon, ')
          ..write('heightM: $heightM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, kind, polygon, heightM);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Obstacle &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.kind == this.kind &&
          other.polygon == this.polygon &&
          other.heightM == this.heightM);
}

class ObstaclesCompanion extends UpdateCompanion<Obstacle> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> kind;
  final Value<String> polygon;
  final Value<double> heightM;
  const ObstaclesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.kind = const Value.absent(),
    this.polygon = const Value.absent(),
    this.heightM = const Value.absent(),
  });
  ObstaclesCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String kind,
    required String polygon,
    required double heightM,
  }) : projectId = Value(projectId),
       kind = Value(kind),
       polygon = Value(polygon),
       heightM = Value(heightM);
  static Insertable<Obstacle> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? kind,
    Expression<String>? polygon,
    Expression<double>? heightM,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (kind != null) 'kind': kind,
      if (polygon != null) 'polygon': polygon,
      if (heightM != null) 'height_m': heightM,
    });
  }

  ObstaclesCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? kind,
    Value<String>? polygon,
    Value<double>? heightM,
  }) {
    return ObstaclesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      polygon: polygon ?? this.polygon,
      heightM: heightM ?? this.heightM,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (polygon.present) {
      map['polygon'] = Variable<String>(polygon.value);
    }
    if (heightM.present) {
      map['height_m'] = Variable<double>(heightM.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObstaclesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('polygon: $polygon, ')
          ..write('heightM: $heightM')
          ..write(')'))
        .toString();
  }
}

class $PlacedModulesTable extends PlacedModules
    with TableInfo<$PlacedModulesTable, PlacedModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacedModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roofIdMeta = const VerificationMeta('roofId');
  @override
  late final GeneratedColumn<int> roofId = GeneratedColumn<int>(
    'roof_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<int> moduleId = GeneratedColumn<int>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationDegMeta = const VerificationMeta(
    'rotationDeg',
  );
  @override
  late final GeneratedColumn<double> rotationDeg = GeneratedColumn<double>(
    'rotation_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roofId,
    moduleId,
    x,
    y,
    rotationDeg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'placed_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlacedModule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('roof_id')) {
      context.handle(
        _roofIdMeta,
        roofId.isAcceptableOrUnknown(data['roof_id']!, _roofIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roofIdMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('rotation_deg')) {
      context.handle(
        _rotationDegMeta,
        rotationDeg.isAcceptableOrUnknown(
          data['rotation_deg']!,
          _rotationDegMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlacedModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlacedModule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roofId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}roof_id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}module_id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      rotationDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rotation_deg'],
      )!,
    );
  }

  @override
  $PlacedModulesTable createAlias(String alias) {
    return $PlacedModulesTable(attachedDatabase, alias);
  }
}

class PlacedModule extends DataClass implements Insertable<PlacedModule> {
  final int id;
  final int roofId;

  /// Reference to the inventory module type.
  final int moduleId;

  /// Center position on the roof plane in meters.
  final double x;
  final double y;

  /// Rotation around the vertical axis in degrees.
  final double rotationDeg;
  const PlacedModule({
    required this.id,
    required this.roofId,
    required this.moduleId,
    required this.x,
    required this.y,
    required this.rotationDeg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['roof_id'] = Variable<int>(roofId);
    map['module_id'] = Variable<int>(moduleId);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['rotation_deg'] = Variable<double>(rotationDeg);
    return map;
  }

  PlacedModulesCompanion toCompanion(bool nullToAbsent) {
    return PlacedModulesCompanion(
      id: Value(id),
      roofId: Value(roofId),
      moduleId: Value(moduleId),
      x: Value(x),
      y: Value(y),
      rotationDeg: Value(rotationDeg),
    );
  }

  factory PlacedModule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlacedModule(
      id: serializer.fromJson<int>(json['id']),
      roofId: serializer.fromJson<int>(json['roofId']),
      moduleId: serializer.fromJson<int>(json['moduleId']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      rotationDeg: serializer.fromJson<double>(json['rotationDeg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roofId': serializer.toJson<int>(roofId),
      'moduleId': serializer.toJson<int>(moduleId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'rotationDeg': serializer.toJson<double>(rotationDeg),
    };
  }

  PlacedModule copyWith({
    int? id,
    int? roofId,
    int? moduleId,
    double? x,
    double? y,
    double? rotationDeg,
  }) => PlacedModule(
    id: id ?? this.id,
    roofId: roofId ?? this.roofId,
    moduleId: moduleId ?? this.moduleId,
    x: x ?? this.x,
    y: y ?? this.y,
    rotationDeg: rotationDeg ?? this.rotationDeg,
  );
  PlacedModule copyWithCompanion(PlacedModulesCompanion data) {
    return PlacedModule(
      id: data.id.present ? data.id.value : this.id,
      roofId: data.roofId.present ? data.roofId.value : this.roofId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      rotationDeg: data.rotationDeg.present
          ? data.rotationDeg.value
          : this.rotationDeg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlacedModule(')
          ..write('id: $id, ')
          ..write('roofId: $roofId, ')
          ..write('moduleId: $moduleId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rotationDeg: $rotationDeg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roofId, moduleId, x, y, rotationDeg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlacedModule &&
          other.id == this.id &&
          other.roofId == this.roofId &&
          other.moduleId == this.moduleId &&
          other.x == this.x &&
          other.y == this.y &&
          other.rotationDeg == this.rotationDeg);
}

class PlacedModulesCompanion extends UpdateCompanion<PlacedModule> {
  final Value<int> id;
  final Value<int> roofId;
  final Value<int> moduleId;
  final Value<double> x;
  final Value<double> y;
  final Value<double> rotationDeg;
  const PlacedModulesCompanion({
    this.id = const Value.absent(),
    this.roofId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rotationDeg = const Value.absent(),
  });
  PlacedModulesCompanion.insert({
    this.id = const Value.absent(),
    required int roofId,
    required int moduleId,
    required double x,
    required double y,
    this.rotationDeg = const Value.absent(),
  }) : roofId = Value(roofId),
       moduleId = Value(moduleId),
       x = Value(x),
       y = Value(y);
  static Insertable<PlacedModule> custom({
    Expression<int>? id,
    Expression<int>? roofId,
    Expression<int>? moduleId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? rotationDeg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roofId != null) 'roof_id': roofId,
      if (moduleId != null) 'module_id': moduleId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rotationDeg != null) 'rotation_deg': rotationDeg,
    });
  }

  PlacedModulesCompanion copyWith({
    Value<int>? id,
    Value<int>? roofId,
    Value<int>? moduleId,
    Value<double>? x,
    Value<double>? y,
    Value<double>? rotationDeg,
  }) {
    return PlacedModulesCompanion(
      id: id ?? this.id,
      roofId: roofId ?? this.roofId,
      moduleId: moduleId ?? this.moduleId,
      x: x ?? this.x,
      y: y ?? this.y,
      rotationDeg: rotationDeg ?? this.rotationDeg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roofId.present) {
      map['roof_id'] = Variable<int>(roofId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<int>(moduleId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (rotationDeg.present) {
      map['rotation_deg'] = Variable<double>(rotationDeg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacedModulesCompanion(')
          ..write('id: $id, ')
          ..write('roofId: $roofId, ')
          ..write('moduleId: $moduleId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rotationDeg: $rotationDeg')
          ..write(')'))
        .toString();
  }
}

class $ModuleStringsTable extends ModuleStrings
    with TableInfo<$ModuleStringsTable, ModuleString> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleStringsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inverterIdMeta = const VerificationMeta(
    'inverterId',
  );
  @override
  late final GeneratedColumn<int> inverterId = GeneratedColumn<int>(
    'inverter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mppIndexMeta = const VerificationMeta(
    'mppIndex',
  );
  @override
  late final GeneratedColumn<int> mppIndex = GeneratedColumn<int>(
    'mpp_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dcCableMm2Meta = const VerificationMeta(
    'dcCableMm2',
  );
  @override
  late final GeneratedColumn<double> dcCableMm2 = GeneratedColumn<double>(
    'dc_cable_mm2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuseAMeta = const VerificationMeta('fuseA');
  @override
  late final GeneratedColumn<double> fuseA = GeneratedColumn<double>(
    'fuse_a',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    inverterId,
    mppIndex,
    dcCableMm2,
    fuseA,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_strings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModuleString> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('inverter_id')) {
      context.handle(
        _inverterIdMeta,
        inverterId.isAcceptableOrUnknown(data['inverter_id']!, _inverterIdMeta),
      );
    }
    if (data.containsKey('mpp_index')) {
      context.handle(
        _mppIndexMeta,
        mppIndex.isAcceptableOrUnknown(data['mpp_index']!, _mppIndexMeta),
      );
    }
    if (data.containsKey('dc_cable_mm2')) {
      context.handle(
        _dcCableMm2Meta,
        dcCableMm2.isAcceptableOrUnknown(
          data['dc_cable_mm2']!,
          _dcCableMm2Meta,
        ),
      );
    }
    if (data.containsKey('fuse_a')) {
      context.handle(
        _fuseAMeta,
        fuseA.isAcceptableOrUnknown(data['fuse_a']!, _fuseAMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModuleString map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleString(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      inverterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inverter_id'],
      ),
      mppIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mpp_index'],
      ),
      dcCableMm2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dc_cable_mm2'],
      ),
      fuseA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuse_a'],
      ),
    );
  }

  @override
  $ModuleStringsTable createAlias(String alias) {
    return $ModuleStringsTable(attachedDatabase, alias);
  }
}

class ModuleString extends DataClass implements Insertable<ModuleString> {
  final int id;
  final int projectId;
  final String name;
  final int? inverterId;

  /// Index of the MPPT tracker on the inverter (0-based).
  final int? mppIndex;

  /// DC cable cross-section in mm² (VDE 0100-443). Null = not specified.
  final double? dcCableMm2;

  /// Installed DC fuse rating in A. Null = not specified.
  final double? fuseA;
  const ModuleString({
    required this.id,
    required this.projectId,
    required this.name,
    this.inverterId,
    this.mppIndex,
    this.dcCableMm2,
    this.fuseA,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || inverterId != null) {
      map['inverter_id'] = Variable<int>(inverterId);
    }
    if (!nullToAbsent || mppIndex != null) {
      map['mpp_index'] = Variable<int>(mppIndex);
    }
    if (!nullToAbsent || dcCableMm2 != null) {
      map['dc_cable_mm2'] = Variable<double>(dcCableMm2);
    }
    if (!nullToAbsent || fuseA != null) {
      map['fuse_a'] = Variable<double>(fuseA);
    }
    return map;
  }

  ModuleStringsCompanion toCompanion(bool nullToAbsent) {
    return ModuleStringsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      inverterId: inverterId == null && nullToAbsent
          ? const Value.absent()
          : Value(inverterId),
      mppIndex: mppIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(mppIndex),
      dcCableMm2: dcCableMm2 == null && nullToAbsent
          ? const Value.absent()
          : Value(dcCableMm2),
      fuseA: fuseA == null && nullToAbsent
          ? const Value.absent()
          : Value(fuseA),
    );
  }

  factory ModuleString.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleString(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      inverterId: serializer.fromJson<int?>(json['inverterId']),
      mppIndex: serializer.fromJson<int?>(json['mppIndex']),
      dcCableMm2: serializer.fromJson<double?>(json['dcCableMm2']),
      fuseA: serializer.fromJson<double?>(json['fuseA']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'name': serializer.toJson<String>(name),
      'inverterId': serializer.toJson<int?>(inverterId),
      'mppIndex': serializer.toJson<int?>(mppIndex),
      'dcCableMm2': serializer.toJson<double?>(dcCableMm2),
      'fuseA': serializer.toJson<double?>(fuseA),
    };
  }

  ModuleString copyWith({
    int? id,
    int? projectId,
    String? name,
    Value<int?> inverterId = const Value.absent(),
    Value<int?> mppIndex = const Value.absent(),
    Value<double?> dcCableMm2 = const Value.absent(),
    Value<double?> fuseA = const Value.absent(),
  }) => ModuleString(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    inverterId: inverterId.present ? inverterId.value : this.inverterId,
    mppIndex: mppIndex.present ? mppIndex.value : this.mppIndex,
    dcCableMm2: dcCableMm2.present ? dcCableMm2.value : this.dcCableMm2,
    fuseA: fuseA.present ? fuseA.value : this.fuseA,
  );
  ModuleString copyWithCompanion(ModuleStringsCompanion data) {
    return ModuleString(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      inverterId: data.inverterId.present
          ? data.inverterId.value
          : this.inverterId,
      mppIndex: data.mppIndex.present ? data.mppIndex.value : this.mppIndex,
      dcCableMm2: data.dcCableMm2.present
          ? data.dcCableMm2.value
          : this.dcCableMm2,
      fuseA: data.fuseA.present ? data.fuseA.value : this.fuseA,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleString(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('inverterId: $inverterId, ')
          ..write('mppIndex: $mppIndex, ')
          ..write('dcCableMm2: $dcCableMm2, ')
          ..write('fuseA: $fuseA')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, name, inverterId, mppIndex, dcCableMm2, fuseA);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleString &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.inverterId == this.inverterId &&
          other.mppIndex == this.mppIndex &&
          other.dcCableMm2 == this.dcCableMm2 &&
          other.fuseA == this.fuseA);
}

class ModuleStringsCompanion extends UpdateCompanion<ModuleString> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> name;
  final Value<int?> inverterId;
  final Value<int?> mppIndex;
  final Value<double?> dcCableMm2;
  final Value<double?> fuseA;
  const ModuleStringsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.inverterId = const Value.absent(),
    this.mppIndex = const Value.absent(),
    this.dcCableMm2 = const Value.absent(),
    this.fuseA = const Value.absent(),
  });
  ModuleStringsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String name,
    this.inverterId = const Value.absent(),
    this.mppIndex = const Value.absent(),
    this.dcCableMm2 = const Value.absent(),
    this.fuseA = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name);
  static Insertable<ModuleString> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? name,
    Expression<int>? inverterId,
    Expression<int>? mppIndex,
    Expression<double>? dcCableMm2,
    Expression<double>? fuseA,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (inverterId != null) 'inverter_id': inverterId,
      if (mppIndex != null) 'mpp_index': mppIndex,
      if (dcCableMm2 != null) 'dc_cable_mm2': dcCableMm2,
      if (fuseA != null) 'fuse_a': fuseA,
    });
  }

  ModuleStringsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? name,
    Value<int?>? inverterId,
    Value<int?>? mppIndex,
    Value<double?>? dcCableMm2,
    Value<double?>? fuseA,
  }) {
    return ModuleStringsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      inverterId: inverterId ?? this.inverterId,
      mppIndex: mppIndex ?? this.mppIndex,
      dcCableMm2: dcCableMm2 ?? this.dcCableMm2,
      fuseA: fuseA ?? this.fuseA,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inverterId.present) {
      map['inverter_id'] = Variable<int>(inverterId.value);
    }
    if (mppIndex.present) {
      map['mpp_index'] = Variable<int>(mppIndex.value);
    }
    if (dcCableMm2.present) {
      map['dc_cable_mm2'] = Variable<double>(dcCableMm2.value);
    }
    if (fuseA.present) {
      map['fuse_a'] = Variable<double>(fuseA.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleStringsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('inverterId: $inverterId, ')
          ..write('mppIndex: $mppIndex, ')
          ..write('dcCableMm2: $dcCableMm2, ')
          ..write('fuseA: $fuseA')
          ..write(')'))
        .toString();
  }
}

class $StringModulesTable extends StringModules
    with TableInfo<$StringModulesTable, StringModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StringModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stringIdMeta = const VerificationMeta(
    'stringId',
  );
  @override
  late final GeneratedColumn<int> stringId = GeneratedColumn<int>(
    'string_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placedModuleIdMeta = const VerificationMeta(
    'placedModuleId',
  );
  @override
  late final GeneratedColumn<int> placedModuleId = GeneratedColumn<int>(
    'placed_module_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [stringId, placedModuleId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'string_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<StringModule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('string_id')) {
      context.handle(
        _stringIdMeta,
        stringId.isAcceptableOrUnknown(data['string_id']!, _stringIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stringIdMeta);
    }
    if (data.containsKey('placed_module_id')) {
      context.handle(
        _placedModuleIdMeta,
        placedModuleId.isAcceptableOrUnknown(
          data['placed_module_id']!,
          _placedModuleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placedModuleIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stringId, placedModuleId};
  @override
  StringModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StringModule(
      stringId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}string_id'],
      )!,
      placedModuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placed_module_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $StringModulesTable createAlias(String alias) {
    return $StringModulesTable(attachedDatabase, alias);
  }
}

class StringModule extends DataClass implements Insertable<StringModule> {
  final int stringId;
  final int placedModuleId;

  /// Position in the series chain (0-based).
  final int position;
  const StringModule({
    required this.stringId,
    required this.placedModuleId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['string_id'] = Variable<int>(stringId);
    map['placed_module_id'] = Variable<int>(placedModuleId);
    map['position'] = Variable<int>(position);
    return map;
  }

  StringModulesCompanion toCompanion(bool nullToAbsent) {
    return StringModulesCompanion(
      stringId: Value(stringId),
      placedModuleId: Value(placedModuleId),
      position: Value(position),
    );
  }

  factory StringModule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StringModule(
      stringId: serializer.fromJson<int>(json['stringId']),
      placedModuleId: serializer.fromJson<int>(json['placedModuleId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stringId': serializer.toJson<int>(stringId),
      'placedModuleId': serializer.toJson<int>(placedModuleId),
      'position': serializer.toJson<int>(position),
    };
  }

  StringModule copyWith({int? stringId, int? placedModuleId, int? position}) =>
      StringModule(
        stringId: stringId ?? this.stringId,
        placedModuleId: placedModuleId ?? this.placedModuleId,
        position: position ?? this.position,
      );
  StringModule copyWithCompanion(StringModulesCompanion data) {
    return StringModule(
      stringId: data.stringId.present ? data.stringId.value : this.stringId,
      placedModuleId: data.placedModuleId.present
          ? data.placedModuleId.value
          : this.placedModuleId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StringModule(')
          ..write('stringId: $stringId, ')
          ..write('placedModuleId: $placedModuleId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stringId, placedModuleId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StringModule &&
          other.stringId == this.stringId &&
          other.placedModuleId == this.placedModuleId &&
          other.position == this.position);
}

class StringModulesCompanion extends UpdateCompanion<StringModule> {
  final Value<int> stringId;
  final Value<int> placedModuleId;
  final Value<int> position;
  final Value<int> rowid;
  const StringModulesCompanion({
    this.stringId = const Value.absent(),
    this.placedModuleId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StringModulesCompanion.insert({
    required int stringId,
    required int placedModuleId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stringId = Value(stringId),
       placedModuleId = Value(placedModuleId);
  static Insertable<StringModule> custom({
    Expression<int>? stringId,
    Expression<int>? placedModuleId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stringId != null) 'string_id': stringId,
      if (placedModuleId != null) 'placed_module_id': placedModuleId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StringModulesCompanion copyWith({
    Value<int>? stringId,
    Value<int>? placedModuleId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return StringModulesCompanion(
      stringId: stringId ?? this.stringId,
      placedModuleId: placedModuleId ?? this.placedModuleId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stringId.present) {
      map['string_id'] = Variable<int>(stringId.value);
    }
    if (placedModuleId.present) {
      map['placed_module_id'] = Variable<int>(placedModuleId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StringModulesCompanion(')
          ..write('stringId: $stringId, ')
          ..write('placedModuleId: $placedModuleId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenariosTable extends Scenarios
    with TableInfo<$ScenariosTable, Scenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inverterIdMeta = const VerificationMeta(
    'inverterId',
  );
  @override
  late final GeneratedColumn<int> inverterId = GeneratedColumn<int>(
    'inverter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryIdMeta = const VerificationMeta(
    'batteryId',
  );
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
    'battery_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wallboxIdMeta = const VerificationMeta(
    'wallboxId',
  );
  @override
  late final GeneratedColumn<int> wallboxId = GeneratedColumn<int>(
    'wallbox_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    inverterId,
    batteryId,
    wallboxId,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('inverter_id')) {
      context.handle(
        _inverterIdMeta,
        inverterId.isAcceptableOrUnknown(data['inverter_id']!, _inverterIdMeta),
      );
    }
    if (data.containsKey('battery_id')) {
      context.handle(
        _batteryIdMeta,
        batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta),
      );
    }
    if (data.containsKey('wallbox_id')) {
      context.handle(
        _wallboxIdMeta,
        wallboxId.isAcceptableOrUnknown(data['wallbox_id']!, _wallboxIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      inverterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inverter_id'],
      ),
      batteryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_id'],
      ),
      wallboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallbox_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ScenariosTable createAlias(String alias) {
    return $ScenariosTable(attachedDatabase, alias);
  }
}

class Scenario extends DataClass implements Insertable<Scenario> {
  final int id;
  final int projectId;
  final String name;
  final int? inverterId;
  final int? batteryId;
  final int? wallboxId;
  final String notes;
  const Scenario({
    required this.id,
    required this.projectId,
    required this.name,
    this.inverterId,
    this.batteryId,
    this.wallboxId,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || inverterId != null) {
      map['inverter_id'] = Variable<int>(inverterId);
    }
    if (!nullToAbsent || batteryId != null) {
      map['battery_id'] = Variable<int>(batteryId);
    }
    if (!nullToAbsent || wallboxId != null) {
      map['wallbox_id'] = Variable<int>(wallboxId);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ScenariosCompanion toCompanion(bool nullToAbsent) {
    return ScenariosCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      inverterId: inverterId == null && nullToAbsent
          ? const Value.absent()
          : Value(inverterId),
      batteryId: batteryId == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryId),
      wallboxId: wallboxId == null && nullToAbsent
          ? const Value.absent()
          : Value(wallboxId),
      notes: Value(notes),
    );
  }

  factory Scenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scenario(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      inverterId: serializer.fromJson<int?>(json['inverterId']),
      batteryId: serializer.fromJson<int?>(json['batteryId']),
      wallboxId: serializer.fromJson<int?>(json['wallboxId']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'name': serializer.toJson<String>(name),
      'inverterId': serializer.toJson<int?>(inverterId),
      'batteryId': serializer.toJson<int?>(batteryId),
      'wallboxId': serializer.toJson<int?>(wallboxId),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Scenario copyWith({
    int? id,
    int? projectId,
    String? name,
    Value<int?> inverterId = const Value.absent(),
    Value<int?> batteryId = const Value.absent(),
    Value<int?> wallboxId = const Value.absent(),
    String? notes,
  }) => Scenario(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    inverterId: inverterId.present ? inverterId.value : this.inverterId,
    batteryId: batteryId.present ? batteryId.value : this.batteryId,
    wallboxId: wallboxId.present ? wallboxId.value : this.wallboxId,
    notes: notes ?? this.notes,
  );
  Scenario copyWithCompanion(ScenariosCompanion data) {
    return Scenario(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      inverterId: data.inverterId.present
          ? data.inverterId.value
          : this.inverterId,
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      wallboxId: data.wallboxId.present ? data.wallboxId.value : this.wallboxId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scenario(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('inverterId: $inverterId, ')
          ..write('batteryId: $batteryId, ')
          ..write('wallboxId: $wallboxId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, name, inverterId, batteryId, wallboxId, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scenario &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.inverterId == this.inverterId &&
          other.batteryId == this.batteryId &&
          other.wallboxId == this.wallboxId &&
          other.notes == this.notes);
}

class ScenariosCompanion extends UpdateCompanion<Scenario> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> name;
  final Value<int?> inverterId;
  final Value<int?> batteryId;
  final Value<int?> wallboxId;
  final Value<String> notes;
  const ScenariosCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.inverterId = const Value.absent(),
    this.batteryId = const Value.absent(),
    this.wallboxId = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ScenariosCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String name,
    this.inverterId = const Value.absent(),
    this.batteryId = const Value.absent(),
    this.wallboxId = const Value.absent(),
    this.notes = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name);
  static Insertable<Scenario> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? name,
    Expression<int>? inverterId,
    Expression<int>? batteryId,
    Expression<int>? wallboxId,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (inverterId != null) 'inverter_id': inverterId,
      if (batteryId != null) 'battery_id': batteryId,
      if (wallboxId != null) 'wallbox_id': wallboxId,
      if (notes != null) 'notes': notes,
    });
  }

  ScenariosCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? name,
    Value<int?>? inverterId,
    Value<int?>? batteryId,
    Value<int?>? wallboxId,
    Value<String>? notes,
  }) {
    return ScenariosCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      inverterId: inverterId ?? this.inverterId,
      batteryId: batteryId ?? this.batteryId,
      wallboxId: wallboxId ?? this.wallboxId,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inverterId.present) {
      map['inverter_id'] = Variable<int>(inverterId.value);
    }
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (wallboxId.present) {
      map['wallbox_id'] = Variable<int>(wallboxId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('inverterId: $inverterId, ')
          ..write('batteryId: $batteryId, ')
          ..write('wallboxId: $wallboxId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ScenarioResultsTable extends ScenarioResults
    with TableInfo<$ScenarioResultsTable, ScenarioResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenarioResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<int> scenarioId = GeneratedColumn<int>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualYieldKwhMeta = const VerificationMeta(
    'annualYieldKwh',
  );
  @override
  late final GeneratedColumn<double> annualYieldKwh = GeneratedColumn<double>(
    'annual_yield_kwh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shadingLossPctMeta = const VerificationMeta(
    'shadingLossPct',
  );
  @override
  late final GeneratedColumn<double> shadingLossPct = GeneratedColumn<double>(
    'shading_loss_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specificYieldKwhPerKwpMeta =
      const VerificationMeta('specificYieldKwhPerKwp');
  @override
  late final GeneratedColumn<double> specificYieldKwhPerKwp =
      GeneratedColumn<double>(
        'specific_yield_kwh_per_kwp',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<int> computedAt = GeneratedColumn<int>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    annualYieldKwh,
    shadingLossPct,
    specificYieldKwhPerKwp,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenario_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScenarioResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scenarioIdMeta);
    }
    if (data.containsKey('annual_yield_kwh')) {
      context.handle(
        _annualYieldKwhMeta,
        annualYieldKwh.isAcceptableOrUnknown(
          data['annual_yield_kwh']!,
          _annualYieldKwhMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annualYieldKwhMeta);
    }
    if (data.containsKey('shading_loss_pct')) {
      context.handle(
        _shadingLossPctMeta,
        shadingLossPct.isAcceptableOrUnknown(
          data['shading_loss_pct']!,
          _shadingLossPctMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shadingLossPctMeta);
    }
    if (data.containsKey('specific_yield_kwh_per_kwp')) {
      context.handle(
        _specificYieldKwhPerKwpMeta,
        specificYieldKwhPerKwp.isAcceptableOrUnknown(
          data['specific_yield_kwh_per_kwp']!,
          _specificYieldKwhPerKwpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_specificYieldKwhPerKwpMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScenarioResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScenarioResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scenario_id'],
      )!,
      annualYieldKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_yield_kwh'],
      )!,
      shadingLossPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shading_loss_pct'],
      )!,
      specificYieldKwhPerKwp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}specific_yield_kwh_per_kwp'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computed_at'],
      )!,
    );
  }

  @override
  $ScenarioResultsTable createAlias(String alias) {
    return $ScenarioResultsTable(attachedDatabase, alias);
  }
}

class ScenarioResult extends DataClass implements Insertable<ScenarioResult> {
  final int id;
  final int scenarioId;
  final double annualYieldKwh;
  final double shadingLossPct;
  final double specificYieldKwhPerKwp;

  /// Epoch milliseconds.
  final int computedAt;
  const ScenarioResult({
    required this.id,
    required this.scenarioId,
    required this.annualYieldKwh,
    required this.shadingLossPct,
    required this.specificYieldKwhPerKwp,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scenario_id'] = Variable<int>(scenarioId);
    map['annual_yield_kwh'] = Variable<double>(annualYieldKwh);
    map['shading_loss_pct'] = Variable<double>(shadingLossPct);
    map['specific_yield_kwh_per_kwp'] = Variable<double>(
      specificYieldKwhPerKwp,
    );
    map['computed_at'] = Variable<int>(computedAt);
    return map;
  }

  ScenarioResultsCompanion toCompanion(bool nullToAbsent) {
    return ScenarioResultsCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      annualYieldKwh: Value(annualYieldKwh),
      shadingLossPct: Value(shadingLossPct),
      specificYieldKwhPerKwp: Value(specificYieldKwhPerKwp),
      computedAt: Value(computedAt),
    );
  }

  factory ScenarioResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScenarioResult(
      id: serializer.fromJson<int>(json['id']),
      scenarioId: serializer.fromJson<int>(json['scenarioId']),
      annualYieldKwh: serializer.fromJson<double>(json['annualYieldKwh']),
      shadingLossPct: serializer.fromJson<double>(json['shadingLossPct']),
      specificYieldKwhPerKwp: serializer.fromJson<double>(
        json['specificYieldKwhPerKwp'],
      ),
      computedAt: serializer.fromJson<int>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scenarioId': serializer.toJson<int>(scenarioId),
      'annualYieldKwh': serializer.toJson<double>(annualYieldKwh),
      'shadingLossPct': serializer.toJson<double>(shadingLossPct),
      'specificYieldKwhPerKwp': serializer.toJson<double>(
        specificYieldKwhPerKwp,
      ),
      'computedAt': serializer.toJson<int>(computedAt),
    };
  }

  ScenarioResult copyWith({
    int? id,
    int? scenarioId,
    double? annualYieldKwh,
    double? shadingLossPct,
    double? specificYieldKwhPerKwp,
    int? computedAt,
  }) => ScenarioResult(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    annualYieldKwh: annualYieldKwh ?? this.annualYieldKwh,
    shadingLossPct: shadingLossPct ?? this.shadingLossPct,
    specificYieldKwhPerKwp:
        specificYieldKwhPerKwp ?? this.specificYieldKwhPerKwp,
    computedAt: computedAt ?? this.computedAt,
  );
  ScenarioResult copyWithCompanion(ScenarioResultsCompanion data) {
    return ScenarioResult(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      annualYieldKwh: data.annualYieldKwh.present
          ? data.annualYieldKwh.value
          : this.annualYieldKwh,
      shadingLossPct: data.shadingLossPct.present
          ? data.shadingLossPct.value
          : this.shadingLossPct,
      specificYieldKwhPerKwp: data.specificYieldKwhPerKwp.present
          ? data.specificYieldKwhPerKwp.value
          : this.specificYieldKwhPerKwp,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScenarioResult(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('annualYieldKwh: $annualYieldKwh, ')
          ..write('shadingLossPct: $shadingLossPct, ')
          ..write('specificYieldKwhPerKwp: $specificYieldKwhPerKwp, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioId,
    annualYieldKwh,
    shadingLossPct,
    specificYieldKwhPerKwp,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScenarioResult &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.annualYieldKwh == this.annualYieldKwh &&
          other.shadingLossPct == this.shadingLossPct &&
          other.specificYieldKwhPerKwp == this.specificYieldKwhPerKwp &&
          other.computedAt == this.computedAt);
}

class ScenarioResultsCompanion extends UpdateCompanion<ScenarioResult> {
  final Value<int> id;
  final Value<int> scenarioId;
  final Value<double> annualYieldKwh;
  final Value<double> shadingLossPct;
  final Value<double> specificYieldKwhPerKwp;
  final Value<int> computedAt;
  const ScenarioResultsCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.annualYieldKwh = const Value.absent(),
    this.shadingLossPct = const Value.absent(),
    this.specificYieldKwhPerKwp = const Value.absent(),
    this.computedAt = const Value.absent(),
  });
  ScenarioResultsCompanion.insert({
    this.id = const Value.absent(),
    required int scenarioId,
    required double annualYieldKwh,
    required double shadingLossPct,
    required double specificYieldKwhPerKwp,
    required int computedAt,
  }) : scenarioId = Value(scenarioId),
       annualYieldKwh = Value(annualYieldKwh),
       shadingLossPct = Value(shadingLossPct),
       specificYieldKwhPerKwp = Value(specificYieldKwhPerKwp),
       computedAt = Value(computedAt);
  static Insertable<ScenarioResult> custom({
    Expression<int>? id,
    Expression<int>? scenarioId,
    Expression<double>? annualYieldKwh,
    Expression<double>? shadingLossPct,
    Expression<double>? specificYieldKwhPerKwp,
    Expression<int>? computedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (annualYieldKwh != null) 'annual_yield_kwh': annualYieldKwh,
      if (shadingLossPct != null) 'shading_loss_pct': shadingLossPct,
      if (specificYieldKwhPerKwp != null)
        'specific_yield_kwh_per_kwp': specificYieldKwhPerKwp,
      if (computedAt != null) 'computed_at': computedAt,
    });
  }

  ScenarioResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? scenarioId,
    Value<double>? annualYieldKwh,
    Value<double>? shadingLossPct,
    Value<double>? specificYieldKwhPerKwp,
    Value<int>? computedAt,
  }) {
    return ScenarioResultsCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      annualYieldKwh: annualYieldKwh ?? this.annualYieldKwh,
      shadingLossPct: shadingLossPct ?? this.shadingLossPct,
      specificYieldKwhPerKwp:
          specificYieldKwhPerKwp ?? this.specificYieldKwhPerKwp,
      computedAt: computedAt ?? this.computedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<int>(scenarioId.value);
    }
    if (annualYieldKwh.present) {
      map['annual_yield_kwh'] = Variable<double>(annualYieldKwh.value);
    }
    if (shadingLossPct.present) {
      map['shading_loss_pct'] = Variable<double>(shadingLossPct.value);
    }
    if (specificYieldKwhPerKwp.present) {
      map['specific_yield_kwh_per_kwp'] = Variable<double>(
        specificYieldKwhPerKwp.value,
      );
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<int>(computedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenarioResultsCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('annualYieldKwh: $annualYieldKwh, ')
          ..write('shadingLossPct: $shadingLossPct, ')
          ..write('specificYieldKwhPerKwp: $specificYieldKwhPerKwp, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SolarModulesTable solarModules = $SolarModulesTable(this);
  late final $InvertersTable inverters = $InvertersTable(this);
  late final $BatteriesTable batteries = $BatteriesTable(this);
  late final $WallboxesTable wallboxes = $WallboxesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $RoofsTable roofs = $RoofsTable(this);
  late final $ObstaclesTable obstacles = $ObstaclesTable(this);
  late final $PlacedModulesTable placedModules = $PlacedModulesTable(this);
  late final $ModuleStringsTable moduleStrings = $ModuleStringsTable(this);
  late final $StringModulesTable stringModules = $StringModulesTable(this);
  late final $ScenariosTable scenarios = $ScenariosTable(this);
  late final $ScenarioResultsTable scenarioResults = $ScenarioResultsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    solarModules,
    inverters,
    batteries,
    wallboxes,
    projects,
    roofs,
    obstacles,
    placedModules,
    moduleStrings,
    stringModules,
    scenarios,
    scenarioResults,
  ];
}

typedef $$SolarModulesTableCreateCompanionBuilder =
    SolarModulesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> manufacturer,
      required double pMaxW,
      Value<double> vmp,
      Value<double> imp,
      required double voc,
      required double isc,
      Value<double> vocTempCoeff,
      required double widthMm,
      required double heightMm,
      Value<double> thicknessMm,
      Value<double?> weightKg,
      Value<String?> frameClass,
    });
typedef $$SolarModulesTableUpdateCompanionBuilder =
    SolarModulesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> manufacturer,
      Value<double> pMaxW,
      Value<double> vmp,
      Value<double> imp,
      Value<double> voc,
      Value<double> isc,
      Value<double> vocTempCoeff,
      Value<double> widthMm,
      Value<double> heightMm,
      Value<double> thicknessMm,
      Value<double?> weightKg,
      Value<String?> frameClass,
    });

class $$SolarModulesTableFilterComposer
    extends Composer<_$AppDatabase, $SolarModulesTable> {
  $$SolarModulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pMaxW => $composableBuilder(
    column: $table.pMaxW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vmp => $composableBuilder(
    column: $table.vmp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get imp => $composableBuilder(
    column: $table.imp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voc => $composableBuilder(
    column: $table.voc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get isc => $composableBuilder(
    column: $table.isc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vocTempCoeff => $composableBuilder(
    column: $table.vocTempCoeff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frameClass => $composableBuilder(
    column: $table.frameClass,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SolarModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SolarModulesTable> {
  $$SolarModulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pMaxW => $composableBuilder(
    column: $table.pMaxW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vmp => $composableBuilder(
    column: $table.vmp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get imp => $composableBuilder(
    column: $table.imp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voc => $composableBuilder(
    column: $table.voc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get isc => $composableBuilder(
    column: $table.isc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vocTempCoeff => $composableBuilder(
    column: $table.vocTempCoeff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frameClass => $composableBuilder(
    column: $table.frameClass,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SolarModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolarModulesTable> {
  $$SolarModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pMaxW =>
      $composableBuilder(column: $table.pMaxW, builder: (column) => column);

  GeneratedColumn<double> get vmp =>
      $composableBuilder(column: $table.vmp, builder: (column) => column);

  GeneratedColumn<double> get imp =>
      $composableBuilder(column: $table.imp, builder: (column) => column);

  GeneratedColumn<double> get voc =>
      $composableBuilder(column: $table.voc, builder: (column) => column);

  GeneratedColumn<double> get isc =>
      $composableBuilder(column: $table.isc, builder: (column) => column);

  GeneratedColumn<double> get vocTempCoeff => $composableBuilder(
    column: $table.vocTempCoeff,
    builder: (column) => column,
  );

  GeneratedColumn<double> get widthMm =>
      $composableBuilder(column: $table.widthMm, builder: (column) => column);

  GeneratedColumn<double> get heightMm =>
      $composableBuilder(column: $table.heightMm, builder: (column) => column);

  GeneratedColumn<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get frameClass => $composableBuilder(
    column: $table.frameClass,
    builder: (column) => column,
  );
}

class $$SolarModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SolarModulesTable,
          SolarModule,
          $$SolarModulesTableFilterComposer,
          $$SolarModulesTableOrderingComposer,
          $$SolarModulesTableAnnotationComposer,
          $$SolarModulesTableCreateCompanionBuilder,
          $$SolarModulesTableUpdateCompanionBuilder,
          (
            SolarModule,
            BaseReferences<_$AppDatabase, $SolarModulesTable, SolarModule>,
          ),
          SolarModule,
          PrefetchHooks Function()
        > {
  $$SolarModulesTableTableManager(_$AppDatabase db, $SolarModulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SolarModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SolarModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SolarModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<double> pMaxW = const Value.absent(),
                Value<double> vmp = const Value.absent(),
                Value<double> imp = const Value.absent(),
                Value<double> voc = const Value.absent(),
                Value<double> isc = const Value.absent(),
                Value<double> vocTempCoeff = const Value.absent(),
                Value<double> widthMm = const Value.absent(),
                Value<double> heightMm = const Value.absent(),
                Value<double> thicknessMm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> frameClass = const Value.absent(),
              }) => SolarModulesCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                pMaxW: pMaxW,
                vmp: vmp,
                imp: imp,
                voc: voc,
                isc: isc,
                vocTempCoeff: vocTempCoeff,
                widthMm: widthMm,
                heightMm: heightMm,
                thicknessMm: thicknessMm,
                weightKg: weightKg,
                frameClass: frameClass,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> manufacturer = const Value.absent(),
                required double pMaxW,
                Value<double> vmp = const Value.absent(),
                Value<double> imp = const Value.absent(),
                required double voc,
                required double isc,
                Value<double> vocTempCoeff = const Value.absent(),
                required double widthMm,
                required double heightMm,
                Value<double> thicknessMm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> frameClass = const Value.absent(),
              }) => SolarModulesCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                pMaxW: pMaxW,
                vmp: vmp,
                imp: imp,
                voc: voc,
                isc: isc,
                vocTempCoeff: vocTempCoeff,
                widthMm: widthMm,
                heightMm: heightMm,
                thicknessMm: thicknessMm,
                weightKg: weightKg,
                frameClass: frameClass,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SolarModulesTable, SolarModule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SolarModulesTable,
                    SolarModule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SolarModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SolarModulesTable,
      SolarModule,
      $$SolarModulesTableFilterComposer,
      $$SolarModulesTableOrderingComposer,
      $$SolarModulesTableAnnotationComposer,
      $$SolarModulesTableCreateCompanionBuilder,
      $$SolarModulesTableUpdateCompanionBuilder,
      (
        SolarModule,
        BaseReferences<_$AppDatabase, $SolarModulesTable, SolarModule>,
      ),
      SolarModule,
      PrefetchHooks Function()
    >;
typedef $$InvertersTableCreateCompanionBuilder = InvertersCompanion Function({
  Value<int> id,
  required String name,
  Value<String> manufacturer,
  required double powerKw,
  Value<int> mppCount,
  Value<int> maxStringsPerMpp,
  Value<double?> minInputVoltage,
  Value<double?> maxInputVoltage,
  Value<double?> maxInputCurrentPerMpp,
  Value<double?> maxShortCircuitCurrentPerMpp,
  Value<int> acPhases,
  Value<String?> dcVoltageClass,
  Value<double?> iOutA,
  Value<int?> mcbA,
  Value<double?> mppMinVoltage,
  Value<double?> mppMaxVoltage,
  Value<double?> qKvar,
  Value<bool> isHybrid,
});
typedef $$InvertersTableUpdateCompanionBuilder = InvertersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> manufacturer,
  Value<double> powerKw,
  Value<int> mppCount,
  Value<int> maxStringsPerMpp,
  Value<double?> minInputVoltage,
  Value<double?> maxInputVoltage,
  Value<double?> maxInputCurrentPerMpp,
  Value<double?> maxShortCircuitCurrentPerMpp,
  Value<int> acPhases,
  Value<String?> dcVoltageClass,
  Value<double?> iOutA,
  Value<int?> mcbA,
  Value<double?> mppMinVoltage,
  Value<double?> mppMaxVoltage,
  Value<double?> qKvar,
  Value<bool> isHybrid,
});

class $$InvertersTableFilterComposer
    extends Composer<_$AppDatabase, $InvertersTable> {
  $$InvertersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerKw => $composableBuilder(
    column: $table.powerKw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mppCount => $composableBuilder(
    column: $table.mppCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxStringsPerMpp => $composableBuilder(
    column: $table.maxStringsPerMpp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minInputVoltage => $composableBuilder(
    column: $table.minInputVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxInputVoltage => $composableBuilder(
    column: $table.maxInputVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxInputCurrentPerMpp => $composableBuilder(
    column: $table.maxInputCurrentPerMpp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxShortCircuitCurrentPerMpp => $composableBuilder(
    column: $table.maxShortCircuitCurrentPerMpp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acPhases => $composableBuilder(
    column: $table.acPhases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dcVoltageClass => $composableBuilder(
    column: $table.dcVoltageClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iOutA => $composableBuilder(
    column: $table.iOutA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mcbA => $composableBuilder(
    column: $table.mcbA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mppMinVoltage => $composableBuilder(
    column: $table.mppMinVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mppMaxVoltage => $composableBuilder(
    column: $table.mppMaxVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qKvar => $composableBuilder(
    column: $table.qKvar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHybrid => $composableBuilder(
    column: $table.isHybrid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvertersTableOrderingComposer
    extends Composer<_$AppDatabase, $InvertersTable> {
  $$InvertersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerKw => $composableBuilder(
    column: $table.powerKw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mppCount => $composableBuilder(
    column: $table.mppCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxStringsPerMpp => $composableBuilder(
    column: $table.maxStringsPerMpp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minInputVoltage => $composableBuilder(
    column: $table.minInputVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxInputVoltage => $composableBuilder(
    column: $table.maxInputVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxInputCurrentPerMpp => $composableBuilder(
    column: $table.maxInputCurrentPerMpp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxShortCircuitCurrentPerMpp =>
      $composableBuilder(
        column: $table.maxShortCircuitCurrentPerMpp,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get acPhases => $composableBuilder(
    column: $table.acPhases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dcVoltageClass => $composableBuilder(
    column: $table.dcVoltageClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iOutA => $composableBuilder(
    column: $table.iOutA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mcbA => $composableBuilder(
    column: $table.mcbA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mppMinVoltage => $composableBuilder(
    column: $table.mppMinVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mppMaxVoltage => $composableBuilder(
    column: $table.mppMaxVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qKvar => $composableBuilder(
    column: $table.qKvar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHybrid => $composableBuilder(
    column: $table.isHybrid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvertersTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvertersTable> {
  $$InvertersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powerKw =>
      $composableBuilder(column: $table.powerKw, builder: (column) => column);

  GeneratedColumn<int> get mppCount =>
      $composableBuilder(column: $table.mppCount, builder: (column) => column);

  GeneratedColumn<int> get maxStringsPerMpp => $composableBuilder(
    column: $table.maxStringsPerMpp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minInputVoltage => $composableBuilder(
    column: $table.minInputVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxInputVoltage => $composableBuilder(
    column: $table.maxInputVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxInputCurrentPerMpp => $composableBuilder(
    column: $table.maxInputCurrentPerMpp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxShortCircuitCurrentPerMpp =>
      $composableBuilder(
        column: $table.maxShortCircuitCurrentPerMpp,
        builder: (column) => column,
      );

  GeneratedColumn<int> get acPhases =>
      $composableBuilder(column: $table.acPhases, builder: (column) => column);

  GeneratedColumn<String> get dcVoltageClass => $composableBuilder(
    column: $table.dcVoltageClass,
    builder: (column) => column,
  );

  GeneratedColumn<double> get iOutA =>
      $composableBuilder(column: $table.iOutA, builder: (column) => column);

  GeneratedColumn<int> get mcbA =>
      $composableBuilder(column: $table.mcbA, builder: (column) => column);

  GeneratedColumn<double> get mppMinVoltage => $composableBuilder(
    column: $table.mppMinVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mppMaxVoltage => $composableBuilder(
    column: $table.mppMaxVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qKvar =>
      $composableBuilder(column: $table.qKvar, builder: (column) => column);

  GeneratedColumn<bool> get isHybrid =>
      $composableBuilder(column: $table.isHybrid, builder: (column) => column);
}

class $$InvertersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvertersTable,
          Inverter,
          $$InvertersTableFilterComposer,
          $$InvertersTableOrderingComposer,
          $$InvertersTableAnnotationComposer,
          $$InvertersTableCreateCompanionBuilder,
          $$InvertersTableUpdateCompanionBuilder,
          (Inverter, BaseReferences<_$AppDatabase, $InvertersTable, Inverter>),
          Inverter,
          PrefetchHooks Function()
        > {
  $$InvertersTableTableManager(_$AppDatabase db, $InvertersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvertersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvertersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvertersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<double> powerKw = const Value.absent(),
                Value<int> mppCount = const Value.absent(),
                Value<int> maxStringsPerMpp = const Value.absent(),
                Value<double?> minInputVoltage = const Value.absent(),
                Value<double?> maxInputVoltage = const Value.absent(),
                Value<double?> maxInputCurrentPerMpp = const Value.absent(),
                Value<double?> maxShortCircuitCurrentPerMpp =
                    const Value.absent(),
                Value<int> acPhases = const Value.absent(),
                Value<String?> dcVoltageClass = const Value.absent(),
                Value<double?> iOutA = const Value.absent(),
                Value<int?> mcbA = const Value.absent(),
                Value<double?> mppMinVoltage = const Value.absent(),
                Value<double?> mppMaxVoltage = const Value.absent(),
                Value<double?> qKvar = const Value.absent(),
                Value<bool> isHybrid = const Value.absent(),
              }) => InvertersCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                powerKw: powerKw,
                mppCount: mppCount,
                maxStringsPerMpp: maxStringsPerMpp,
                minInputVoltage: minInputVoltage,
                maxInputVoltage: maxInputVoltage,
                maxInputCurrentPerMpp: maxInputCurrentPerMpp,
                maxShortCircuitCurrentPerMpp: maxShortCircuitCurrentPerMpp,
                acPhases: acPhases,
                dcVoltageClass: dcVoltageClass,
                iOutA: iOutA,
                mcbA: mcbA,
                mppMinVoltage: mppMinVoltage,
                mppMaxVoltage: mppMaxVoltage,
                qKvar: qKvar,
                isHybrid: isHybrid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> manufacturer = const Value.absent(),
                required double powerKw,
                Value<int> mppCount = const Value.absent(),
                Value<int> maxStringsPerMpp = const Value.absent(),
                Value<double?> minInputVoltage = const Value.absent(),
                Value<double?> maxInputVoltage = const Value.absent(),
                Value<double?> maxInputCurrentPerMpp = const Value.absent(),
                Value<double?> maxShortCircuitCurrentPerMpp =
                    const Value.absent(),
                Value<int> acPhases = const Value.absent(),
                Value<String?> dcVoltageClass = const Value.absent(),
                Value<double?> iOutA = const Value.absent(),
                Value<int?> mcbA = const Value.absent(),
                Value<double?> mppMinVoltage = const Value.absent(),
                Value<double?> mppMaxVoltage = const Value.absent(),
                Value<double?> qKvar = const Value.absent(),
                Value<bool> isHybrid = const Value.absent(),
              }) => InvertersCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                powerKw: powerKw,
                mppCount: mppCount,
                maxStringsPerMpp: maxStringsPerMpp,
                minInputVoltage: minInputVoltage,
                maxInputVoltage: maxInputVoltage,
                maxInputCurrentPerMpp: maxInputCurrentPerMpp,
                maxShortCircuitCurrentPerMpp: maxShortCircuitCurrentPerMpp,
                acPhases: acPhases,
                dcVoltageClass: dcVoltageClass,
                iOutA: iOutA,
                mcbA: mcbA,
                mppMinVoltage: mppMinVoltage,
                mppMaxVoltage: mppMaxVoltage,
                qKvar: qKvar,
                isHybrid: isHybrid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvertersTable, Inverter>(table),
                  BaseReferences<_$AppDatabase, $InvertersTable, Inverter>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvertersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvertersTable,
      Inverter,
      $$InvertersTableFilterComposer,
      $$InvertersTableOrderingComposer,
      $$InvertersTableAnnotationComposer,
      $$InvertersTableCreateCompanionBuilder,
      $$InvertersTableUpdateCompanionBuilder,
      (Inverter, BaseReferences<_$AppDatabase, $InvertersTable, Inverter>),
      Inverter,
      PrefetchHooks Function()
    >;
typedef $$BatteriesTableCreateCompanionBuilder = BatteriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> manufacturer,
  required double capacityKwh,
  Value<double?> nominalVoltage,
  Value<String> chemistry,
});
typedef $$BatteriesTableUpdateCompanionBuilder = BatteriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> manufacturer,
  Value<double> capacityKwh,
  Value<double?> nominalVoltage,
  Value<String> chemistry,
});

class $$BatteriesTableFilterComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get capacityKwh => $composableBuilder(
    column: $table.capacityKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nominalVoltage => $composableBuilder(
    column: $table.nominalVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chemistry => $composableBuilder(
    column: $table.chemistry,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatteriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get capacityKwh => $composableBuilder(
    column: $table.capacityKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nominalVoltage => $composableBuilder(
    column: $table.nominalVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chemistry => $composableBuilder(
    column: $table.chemistry,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatteriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get capacityKwh => $composableBuilder(
    column: $table.capacityKwh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nominalVoltage => $composableBuilder(
    column: $table.nominalVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chemistry =>
      $composableBuilder(column: $table.chemistry, builder: (column) => column);
}

class $$BatteriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatteriesTable,
          Battery,
          $$BatteriesTableFilterComposer,
          $$BatteriesTableOrderingComposer,
          $$BatteriesTableAnnotationComposer,
          $$BatteriesTableCreateCompanionBuilder,
          $$BatteriesTableUpdateCompanionBuilder,
          (Battery, BaseReferences<_$AppDatabase, $BatteriesTable, Battery>),
          Battery,
          PrefetchHooks Function()
        > {
  $$BatteriesTableTableManager(_$AppDatabase db, $BatteriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<double> capacityKwh = const Value.absent(),
                Value<double?> nominalVoltage = const Value.absent(),
                Value<String> chemistry = const Value.absent(),
              }) => BatteriesCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                capacityKwh: capacityKwh,
                nominalVoltage: nominalVoltage,
                chemistry: chemistry,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> manufacturer = const Value.absent(),
                required double capacityKwh,
                Value<double?> nominalVoltage = const Value.absent(),
                Value<String> chemistry = const Value.absent(),
              }) => BatteriesCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                capacityKwh: capacityKwh,
                nominalVoltage: nominalVoltage,
                chemistry: chemistry,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatteriesTable, Battery>(table),
                  BaseReferences<_$AppDatabase, $BatteriesTable, Battery>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatteriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatteriesTable,
      Battery,
      $$BatteriesTableFilterComposer,
      $$BatteriesTableOrderingComposer,
      $$BatteriesTableAnnotationComposer,
      $$BatteriesTableCreateCompanionBuilder,
      $$BatteriesTableUpdateCompanionBuilder,
      (Battery, BaseReferences<_$AppDatabase, $BatteriesTable, Battery>),
      Battery,
      PrefetchHooks Function()
    >;
typedef $$WallboxesTableCreateCompanionBuilder = WallboxesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> manufacturer,
  required double powerKw,
  Value<int> phases,
  Value<String> rcdType,
  Value<double?> breakerA,
  Value<double?> rcdRatedA,
});
typedef $$WallboxesTableUpdateCompanionBuilder = WallboxesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> manufacturer,
  Value<double> powerKw,
  Value<int> phases,
  Value<String> rcdType,
  Value<double?> breakerA,
  Value<double?> rcdRatedA,
});

class $$WallboxesTableFilterComposer
    extends Composer<_$AppDatabase, $WallboxesTable> {
  $$WallboxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerKw => $composableBuilder(
    column: $table.powerKw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phases => $composableBuilder(
    column: $table.phases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rcdType => $composableBuilder(
    column: $table.rcdType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breakerA => $composableBuilder(
    column: $table.breakerA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rcdRatedA => $composableBuilder(
    column: $table.rcdRatedA,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WallboxesTableOrderingComposer
    extends Composer<_$AppDatabase, $WallboxesTable> {
  $$WallboxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerKw => $composableBuilder(
    column: $table.powerKw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phases => $composableBuilder(
    column: $table.phases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rcdType => $composableBuilder(
    column: $table.rcdType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breakerA => $composableBuilder(
    column: $table.breakerA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rcdRatedA => $composableBuilder(
    column: $table.rcdRatedA,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WallboxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WallboxesTable> {
  $$WallboxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powerKw =>
      $composableBuilder(column: $table.powerKw, builder: (column) => column);

  GeneratedColumn<int> get phases =>
      $composableBuilder(column: $table.phases, builder: (column) => column);

  GeneratedColumn<String> get rcdType =>
      $composableBuilder(column: $table.rcdType, builder: (column) => column);

  GeneratedColumn<double> get breakerA =>
      $composableBuilder(column: $table.breakerA, builder: (column) => column);

  GeneratedColumn<double> get rcdRatedA =>
      $composableBuilder(column: $table.rcdRatedA, builder: (column) => column);
}

class $$WallboxesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WallboxesTable,
          Wallbox,
          $$WallboxesTableFilterComposer,
          $$WallboxesTableOrderingComposer,
          $$WallboxesTableAnnotationComposer,
          $$WallboxesTableCreateCompanionBuilder,
          $$WallboxesTableUpdateCompanionBuilder,
          (Wallbox, BaseReferences<_$AppDatabase, $WallboxesTable, Wallbox>),
          Wallbox,
          PrefetchHooks Function()
        > {
  $$WallboxesTableTableManager(_$AppDatabase db, $WallboxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WallboxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WallboxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WallboxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<double> powerKw = const Value.absent(),
                Value<int> phases = const Value.absent(),
                Value<String> rcdType = const Value.absent(),
                Value<double?> breakerA = const Value.absent(),
                Value<double?> rcdRatedA = const Value.absent(),
              }) => WallboxesCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                powerKw: powerKw,
                phases: phases,
                rcdType: rcdType,
                breakerA: breakerA,
                rcdRatedA: rcdRatedA,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> manufacturer = const Value.absent(),
                required double powerKw,
                Value<int> phases = const Value.absent(),
                Value<String> rcdType = const Value.absent(),
                Value<double?> breakerA = const Value.absent(),
                Value<double?> rcdRatedA = const Value.absent(),
              }) => WallboxesCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                powerKw: powerKw,
                phases: phases,
                rcdType: rcdType,
                breakerA: breakerA,
                rcdRatedA: rcdRatedA,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WallboxesTable, Wallbox>(table),
                  BaseReferences<_$AppDatabase, $WallboxesTable, Wallbox>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WallboxesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WallboxesTable,
      Wallbox,
      $$WallboxesTableFilterComposer,
      $$WallboxesTableOrderingComposer,
      $$WallboxesTableAnnotationComposer,
      $$WallboxesTableCreateCompanionBuilder,
      $$WallboxesTableUpdateCompanionBuilder,
      (Wallbox, BaseReferences<_$AppDatabase, $WallboxesTable, Wallbox>),
      Wallbox,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> address,
  Value<double> latitude,
  Value<double> longitude,
  required int createdAt,
  required int updatedAt,
  Value<int?> activeModuleTypeId,
  Value<int?> activeInverterId,
  Value<double> tAmbientMinC,
  Value<double> tAmbientMaxC,
  Value<int> gridPhases,
  Value<double?> maxFeedInKw,
  Value<bool> hasMainEquipotential,
  Value<bool> isBoltedMounting,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> address,
  Value<double> latitude,
  Value<double> longitude,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> activeModuleTypeId,
  Value<int?> activeInverterId,
  Value<double> tAmbientMinC,
  Value<double> tAmbientMaxC,
  Value<int> gridPhases,
  Value<double?> maxFeedInKw,
  Value<bool> hasMainEquipotential,
  Value<bool> isBoltedMounting,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeModuleTypeId => $composableBuilder(
    column: $table.activeModuleTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeInverterId => $composableBuilder(
    column: $table.activeInverterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tAmbientMinC => $composableBuilder(
    column: $table.tAmbientMinC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tAmbientMaxC => $composableBuilder(
    column: $table.tAmbientMaxC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridPhases => $composableBuilder(
    column: $table.gridPhases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxFeedInKw => $composableBuilder(
    column: $table.maxFeedInKw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMainEquipotential => $composableBuilder(
    column: $table.hasMainEquipotential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBoltedMounting => $composableBuilder(
    column: $table.isBoltedMounting,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeModuleTypeId => $composableBuilder(
    column: $table.activeModuleTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeInverterId => $composableBuilder(
    column: $table.activeInverterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tAmbientMinC => $composableBuilder(
    column: $table.tAmbientMinC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tAmbientMaxC => $composableBuilder(
    column: $table.tAmbientMaxC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridPhases => $composableBuilder(
    column: $table.gridPhases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxFeedInKw => $composableBuilder(
    column: $table.maxFeedInKw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMainEquipotential => $composableBuilder(
    column: $table.hasMainEquipotential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBoltedMounting => $composableBuilder(
    column: $table.isBoltedMounting,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get activeModuleTypeId => $composableBuilder(
    column: $table.activeModuleTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeInverterId => $composableBuilder(
    column: $table.activeInverterId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tAmbientMinC => $composableBuilder(
    column: $table.tAmbientMinC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tAmbientMaxC => $composableBuilder(
    column: $table.tAmbientMaxC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gridPhases => $composableBuilder(
    column: $table.gridPhases,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxFeedInKw => $composableBuilder(
    column: $table.maxFeedInKw,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasMainEquipotential => $composableBuilder(
    column: $table.hasMainEquipotential,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBoltedMounting => $composableBuilder(
    column: $table.isBoltedMounting,
    builder: (column) => column,
  );
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> activeModuleTypeId = const Value.absent(),
                Value<int?> activeInverterId = const Value.absent(),
                Value<double> tAmbientMinC = const Value.absent(),
                Value<double> tAmbientMaxC = const Value.absent(),
                Value<int> gridPhases = const Value.absent(),
                Value<double?> maxFeedInKw = const Value.absent(),
                Value<bool> hasMainEquipotential = const Value.absent(),
                Value<bool> isBoltedMounting = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
                activeModuleTypeId: activeModuleTypeId,
                activeInverterId: activeInverterId,
                tAmbientMinC: tAmbientMinC,
                tAmbientMaxC: tAmbientMaxC,
                gridPhases: gridPhases,
                maxFeedInKw: maxFeedInKw,
                hasMainEquipotential: hasMainEquipotential,
                isBoltedMounting: isBoltedMounting,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> address = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> activeModuleTypeId = const Value.absent(),
                Value<int?> activeInverterId = const Value.absent(),
                Value<double> tAmbientMinC = const Value.absent(),
                Value<double> tAmbientMaxC = const Value.absent(),
                Value<int> gridPhases = const Value.absent(),
                Value<double?> maxFeedInKw = const Value.absent(),
                Value<bool> hasMainEquipotential = const Value.absent(),
                Value<bool> isBoltedMounting = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
                activeModuleTypeId: activeModuleTypeId,
                activeInverterId: activeInverterId,
                tAmbientMinC: tAmbientMinC,
                tAmbientMaxC: tAmbientMaxC,
                gridPhases: gridPhases,
                maxFeedInKw: maxFeedInKw,
                hasMainEquipotential: hasMainEquipotential,
                isBoltedMounting: isBoltedMounting,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  BaseReferences<_$AppDatabase, $ProjectsTable, Project>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$RoofsTableCreateCompanionBuilder = RoofsCompanion Function({
  Value<int> id,
  required int projectId,
  required String name,
  required String polygon,
  required double lengthM,
  required double widthM,
  Value<double> pitchDeg,
  Value<double> azimuthDeg,
  Value<String> type,
  Value<double?> flatBaseHeightCm,
  Value<double?> flatAttikaHeightCm,
  Value<double?> flatAttikaWidthCm,
  Value<double?> rafterWidthCm,
  Value<double?> rafterDepthCm,
  Value<double?> rafterSpacingCm,
  Value<double?> battenThicknessCm,
  Value<bool> rafterStraight,
  Value<bool> hasCounterBatten,
  Value<int?> tilesVisibleWidth,
  Value<int?> tilesVisibleHeight,
  Value<double?> tileOverlapCm,
  Value<String> tileMaterial,
  Value<bool> hasSpareTiles,
  Value<bool> hasInsulation,
  Value<double?> insulationThicknessCm,
  Value<double?> moduleMarginM,
  Value<double?> moduleGapM,
});
typedef $$RoofsTableUpdateCompanionBuilder = RoofsCompanion Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> name,
  Value<String> polygon,
  Value<double> lengthM,
  Value<double> widthM,
  Value<double> pitchDeg,
  Value<double> azimuthDeg,
  Value<String> type,
  Value<double?> flatBaseHeightCm,
  Value<double?> flatAttikaHeightCm,
  Value<double?> flatAttikaWidthCm,
  Value<double?> rafterWidthCm,
  Value<double?> rafterDepthCm,
  Value<double?> rafterSpacingCm,
  Value<double?> battenThicknessCm,
  Value<bool> rafterStraight,
  Value<bool> hasCounterBatten,
  Value<int?> tilesVisibleWidth,
  Value<int?> tilesVisibleHeight,
  Value<double?> tileOverlapCm,
  Value<String> tileMaterial,
  Value<bool> hasSpareTiles,
  Value<bool> hasInsulation,
  Value<double?> insulationThicknessCm,
  Value<double?> moduleMarginM,
  Value<double?> moduleGapM,
});

class $$RoofsTableFilterComposer extends Composer<_$AppDatabase, $RoofsTable> {
  $$RoofsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthM => $composableBuilder(
    column: $table.lengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthM => $composableBuilder(
    column: $table.widthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pitchDeg => $composableBuilder(
    column: $table.pitchDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get azimuthDeg => $composableBuilder(
    column: $table.azimuthDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get flatBaseHeightCm => $composableBuilder(
    column: $table.flatBaseHeightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get flatAttikaHeightCm => $composableBuilder(
    column: $table.flatAttikaHeightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get flatAttikaWidthCm => $composableBuilder(
    column: $table.flatAttikaWidthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rafterWidthCm => $composableBuilder(
    column: $table.rafterWidthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rafterDepthCm => $composableBuilder(
    column: $table.rafterDepthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rafterSpacingCm => $composableBuilder(
    column: $table.rafterSpacingCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get battenThicknessCm => $composableBuilder(
    column: $table.battenThicknessCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rafterStraight => $composableBuilder(
    column: $table.rafterStraight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCounterBatten => $composableBuilder(
    column: $table.hasCounterBatten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tilesVisibleWidth => $composableBuilder(
    column: $table.tilesVisibleWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tilesVisibleHeight => $composableBuilder(
    column: $table.tilesVisibleHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tileOverlapCm => $composableBuilder(
    column: $table.tileOverlapCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tileMaterial => $composableBuilder(
    column: $table.tileMaterial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSpareTiles => $composableBuilder(
    column: $table.hasSpareTiles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasInsulation => $composableBuilder(
    column: $table.hasInsulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insulationThicknessCm => $composableBuilder(
    column: $table.insulationThicknessCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get moduleMarginM => $composableBuilder(
    column: $table.moduleMarginM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get moduleGapM => $composableBuilder(
    column: $table.moduleGapM,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoofsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoofsTable> {
  $$RoofsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthM => $composableBuilder(
    column: $table.lengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthM => $composableBuilder(
    column: $table.widthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pitchDeg => $composableBuilder(
    column: $table.pitchDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get azimuthDeg => $composableBuilder(
    column: $table.azimuthDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get flatBaseHeightCm => $composableBuilder(
    column: $table.flatBaseHeightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get flatAttikaHeightCm => $composableBuilder(
    column: $table.flatAttikaHeightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get flatAttikaWidthCm => $composableBuilder(
    column: $table.flatAttikaWidthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rafterWidthCm => $composableBuilder(
    column: $table.rafterWidthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rafterDepthCm => $composableBuilder(
    column: $table.rafterDepthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rafterSpacingCm => $composableBuilder(
    column: $table.rafterSpacingCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get battenThicknessCm => $composableBuilder(
    column: $table.battenThicknessCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rafterStraight => $composableBuilder(
    column: $table.rafterStraight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCounterBatten => $composableBuilder(
    column: $table.hasCounterBatten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tilesVisibleWidth => $composableBuilder(
    column: $table.tilesVisibleWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tilesVisibleHeight => $composableBuilder(
    column: $table.tilesVisibleHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tileOverlapCm => $composableBuilder(
    column: $table.tileOverlapCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tileMaterial => $composableBuilder(
    column: $table.tileMaterial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSpareTiles => $composableBuilder(
    column: $table.hasSpareTiles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasInsulation => $composableBuilder(
    column: $table.hasInsulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insulationThicknessCm => $composableBuilder(
    column: $table.insulationThicknessCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get moduleMarginM => $composableBuilder(
    column: $table.moduleMarginM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get moduleGapM => $composableBuilder(
    column: $table.moduleGapM,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoofsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoofsTable> {
  $$RoofsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get polygon =>
      $composableBuilder(column: $table.polygon, builder: (column) => column);

  GeneratedColumn<double> get lengthM =>
      $composableBuilder(column: $table.lengthM, builder: (column) => column);

  GeneratedColumn<double> get widthM =>
      $composableBuilder(column: $table.widthM, builder: (column) => column);

  GeneratedColumn<double> get pitchDeg =>
      $composableBuilder(column: $table.pitchDeg, builder: (column) => column);

  GeneratedColumn<double> get azimuthDeg => $composableBuilder(
    column: $table.azimuthDeg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get flatBaseHeightCm => $composableBuilder(
    column: $table.flatBaseHeightCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get flatAttikaHeightCm => $composableBuilder(
    column: $table.flatAttikaHeightCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get flatAttikaWidthCm => $composableBuilder(
    column: $table.flatAttikaWidthCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rafterWidthCm => $composableBuilder(
    column: $table.rafterWidthCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rafterDepthCm => $composableBuilder(
    column: $table.rafterDepthCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rafterSpacingCm => $composableBuilder(
    column: $table.rafterSpacingCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get battenThicknessCm => $composableBuilder(
    column: $table.battenThicknessCm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rafterStraight => $composableBuilder(
    column: $table.rafterStraight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasCounterBatten => $composableBuilder(
    column: $table.hasCounterBatten,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tilesVisibleWidth => $composableBuilder(
    column: $table.tilesVisibleWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tilesVisibleHeight => $composableBuilder(
    column: $table.tilesVisibleHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tileOverlapCm => $composableBuilder(
    column: $table.tileOverlapCm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tileMaterial => $composableBuilder(
    column: $table.tileMaterial,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSpareTiles => $composableBuilder(
    column: $table.hasSpareTiles,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasInsulation => $composableBuilder(
    column: $table.hasInsulation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insulationThicknessCm => $composableBuilder(
    column: $table.insulationThicknessCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get moduleMarginM => $composableBuilder(
    column: $table.moduleMarginM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get moduleGapM => $composableBuilder(
    column: $table.moduleGapM,
    builder: (column) => column,
  );
}

class $$RoofsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoofsTable,
          Roof,
          $$RoofsTableFilterComposer,
          $$RoofsTableOrderingComposer,
          $$RoofsTableAnnotationComposer,
          $$RoofsTableCreateCompanionBuilder,
          $$RoofsTableUpdateCompanionBuilder,
          (Roof, BaseReferences<_$AppDatabase, $RoofsTable, Roof>),
          Roof,
          PrefetchHooks Function()
        > {
  $$RoofsTableTableManager(_$AppDatabase db, $RoofsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoofsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoofsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoofsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> polygon = const Value.absent(),
                Value<double> lengthM = const Value.absent(),
                Value<double> widthM = const Value.absent(),
                Value<double> pitchDeg = const Value.absent(),
                Value<double> azimuthDeg = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double?> flatBaseHeightCm = const Value.absent(),
                Value<double?> flatAttikaHeightCm = const Value.absent(),
                Value<double?> flatAttikaWidthCm = const Value.absent(),
                Value<double?> rafterWidthCm = const Value.absent(),
                Value<double?> rafterDepthCm = const Value.absent(),
                Value<double?> rafterSpacingCm = const Value.absent(),
                Value<double?> battenThicknessCm = const Value.absent(),
                Value<bool> rafterStraight = const Value.absent(),
                Value<bool> hasCounterBatten = const Value.absent(),
                Value<int?> tilesVisibleWidth = const Value.absent(),
                Value<int?> tilesVisibleHeight = const Value.absent(),
                Value<double?> tileOverlapCm = const Value.absent(),
                Value<String> tileMaterial = const Value.absent(),
                Value<bool> hasSpareTiles = const Value.absent(),
                Value<bool> hasInsulation = const Value.absent(),
                Value<double?> insulationThicknessCm = const Value.absent(),
                Value<double?> moduleMarginM = const Value.absent(),
                Value<double?> moduleGapM = const Value.absent(),
              }) => RoofsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                polygon: polygon,
                lengthM: lengthM,
                widthM: widthM,
                pitchDeg: pitchDeg,
                azimuthDeg: azimuthDeg,
                type: type,
                flatBaseHeightCm: flatBaseHeightCm,
                flatAttikaHeightCm: flatAttikaHeightCm,
                flatAttikaWidthCm: flatAttikaWidthCm,
                rafterWidthCm: rafterWidthCm,
                rafterDepthCm: rafterDepthCm,
                rafterSpacingCm: rafterSpacingCm,
                battenThicknessCm: battenThicknessCm,
                rafterStraight: rafterStraight,
                hasCounterBatten: hasCounterBatten,
                tilesVisibleWidth: tilesVisibleWidth,
                tilesVisibleHeight: tilesVisibleHeight,
                tileOverlapCm: tileOverlapCm,
                tileMaterial: tileMaterial,
                hasSpareTiles: hasSpareTiles,
                hasInsulation: hasInsulation,
                insulationThicknessCm: insulationThicknessCm,
                moduleMarginM: moduleMarginM,
                moduleGapM: moduleGapM,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String name,
                required String polygon,
                required double lengthM,
                required double widthM,
                Value<double> pitchDeg = const Value.absent(),
                Value<double> azimuthDeg = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double?> flatBaseHeightCm = const Value.absent(),
                Value<double?> flatAttikaHeightCm = const Value.absent(),
                Value<double?> flatAttikaWidthCm = const Value.absent(),
                Value<double?> rafterWidthCm = const Value.absent(),
                Value<double?> rafterDepthCm = const Value.absent(),
                Value<double?> rafterSpacingCm = const Value.absent(),
                Value<double?> battenThicknessCm = const Value.absent(),
                Value<bool> rafterStraight = const Value.absent(),
                Value<bool> hasCounterBatten = const Value.absent(),
                Value<int?> tilesVisibleWidth = const Value.absent(),
                Value<int?> tilesVisibleHeight = const Value.absent(),
                Value<double?> tileOverlapCm = const Value.absent(),
                Value<String> tileMaterial = const Value.absent(),
                Value<bool> hasSpareTiles = const Value.absent(),
                Value<bool> hasInsulation = const Value.absent(),
                Value<double?> insulationThicknessCm = const Value.absent(),
                Value<double?> moduleMarginM = const Value.absent(),
                Value<double?> moduleGapM = const Value.absent(),
              }) => RoofsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                polygon: polygon,
                lengthM: lengthM,
                widthM: widthM,
                pitchDeg: pitchDeg,
                azimuthDeg: azimuthDeg,
                type: type,
                flatBaseHeightCm: flatBaseHeightCm,
                flatAttikaHeightCm: flatAttikaHeightCm,
                flatAttikaWidthCm: flatAttikaWidthCm,
                rafterWidthCm: rafterWidthCm,
                rafterDepthCm: rafterDepthCm,
                rafterSpacingCm: rafterSpacingCm,
                battenThicknessCm: battenThicknessCm,
                rafterStraight: rafterStraight,
                hasCounterBatten: hasCounterBatten,
                tilesVisibleWidth: tilesVisibleWidth,
                tilesVisibleHeight: tilesVisibleHeight,
                tileOverlapCm: tileOverlapCm,
                tileMaterial: tileMaterial,
                hasSpareTiles: hasSpareTiles,
                hasInsulation: hasInsulation,
                insulationThicknessCm: insulationThicknessCm,
                moduleMarginM: moduleMarginM,
                moduleGapM: moduleGapM,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoofsTable, Roof>(table),
                  BaseReferences<_$AppDatabase, $RoofsTable, Roof>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoofsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoofsTable,
      Roof,
      $$RoofsTableFilterComposer,
      $$RoofsTableOrderingComposer,
      $$RoofsTableAnnotationComposer,
      $$RoofsTableCreateCompanionBuilder,
      $$RoofsTableUpdateCompanionBuilder,
      (Roof, BaseReferences<_$AppDatabase, $RoofsTable, Roof>),
      Roof,
      PrefetchHooks Function()
    >;
typedef $$ObstaclesTableCreateCompanionBuilder = ObstaclesCompanion Function({
  Value<int> id,
  required int projectId,
  required String kind,
  required String polygon,
  required double heightM,
});
typedef $$ObstaclesTableUpdateCompanionBuilder = ObstaclesCompanion Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> kind,
  Value<String> polygon,
  Value<double> heightM,
});

class $$ObstaclesTableFilterComposer
    extends Composer<_$AppDatabase, $ObstaclesTable> {
  $$ObstaclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightM => $composableBuilder(
    column: $table.heightM,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObstaclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ObstaclesTable> {
  $$ObstaclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightM => $composableBuilder(
    column: $table.heightM,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObstaclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObstaclesTable> {
  $$ObstaclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get polygon =>
      $composableBuilder(column: $table.polygon, builder: (column) => column);

  GeneratedColumn<double> get heightM =>
      $composableBuilder(column: $table.heightM, builder: (column) => column);
}

class $$ObstaclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObstaclesTable,
          Obstacle,
          $$ObstaclesTableFilterComposer,
          $$ObstaclesTableOrderingComposer,
          $$ObstaclesTableAnnotationComposer,
          $$ObstaclesTableCreateCompanionBuilder,
          $$ObstaclesTableUpdateCompanionBuilder,
          (Obstacle, BaseReferences<_$AppDatabase, $ObstaclesTable, Obstacle>),
          Obstacle,
          PrefetchHooks Function()
        > {
  $$ObstaclesTableTableManager(_$AppDatabase db, $ObstaclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObstaclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObstaclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObstaclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> polygon = const Value.absent(),
                Value<double> heightM = const Value.absent(),
              }) => ObstaclesCompanion(
                id: id,
                projectId: projectId,
                kind: kind,
                polygon: polygon,
                heightM: heightM,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String kind,
                required String polygon,
                required double heightM,
              }) => ObstaclesCompanion.insert(
                id: id,
                projectId: projectId,
                kind: kind,
                polygon: polygon,
                heightM: heightM,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObstaclesTable, Obstacle>(table),
                  BaseReferences<_$AppDatabase, $ObstaclesTable, Obstacle>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObstaclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObstaclesTable,
      Obstacle,
      $$ObstaclesTableFilterComposer,
      $$ObstaclesTableOrderingComposer,
      $$ObstaclesTableAnnotationComposer,
      $$ObstaclesTableCreateCompanionBuilder,
      $$ObstaclesTableUpdateCompanionBuilder,
      (Obstacle, BaseReferences<_$AppDatabase, $ObstaclesTable, Obstacle>),
      Obstacle,
      PrefetchHooks Function()
    >;
typedef $$PlacedModulesTableCreateCompanionBuilder =
    PlacedModulesCompanion Function({
      Value<int> id,
      required int roofId,
      required int moduleId,
      required double x,
      required double y,
      Value<double> rotationDeg,
    });
typedef $$PlacedModulesTableUpdateCompanionBuilder =
    PlacedModulesCompanion Function({
      Value<int> id,
      Value<int> roofId,
      Value<int> moduleId,
      Value<double> x,
      Value<double> y,
      Value<double> rotationDeg,
    });

class $$PlacedModulesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacedModulesTable> {
  $$PlacedModulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roofId => $composableBuilder(
    column: $table.roofId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rotationDeg => $composableBuilder(
    column: $table.rotationDeg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacedModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacedModulesTable> {
  $$PlacedModulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roofId => $composableBuilder(
    column: $table.roofId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rotationDeg => $composableBuilder(
    column: $table.rotationDeg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacedModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacedModulesTable> {
  $$PlacedModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roofId =>
      $composableBuilder(column: $table.roofId, builder: (column) => column);

  GeneratedColumn<int> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get rotationDeg => $composableBuilder(
    column: $table.rotationDeg,
    builder: (column) => column,
  );
}

class $$PlacedModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacedModulesTable,
          PlacedModule,
          $$PlacedModulesTableFilterComposer,
          $$PlacedModulesTableOrderingComposer,
          $$PlacedModulesTableAnnotationComposer,
          $$PlacedModulesTableCreateCompanionBuilder,
          $$PlacedModulesTableUpdateCompanionBuilder,
          (
            PlacedModule,
            BaseReferences<_$AppDatabase, $PlacedModulesTable, PlacedModule>,
          ),
          PlacedModule,
          PrefetchHooks Function()
        > {
  $$PlacedModulesTableTableManager(_$AppDatabase db, $PlacedModulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacedModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacedModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacedModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roofId = const Value.absent(),
                Value<int> moduleId = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> rotationDeg = const Value.absent(),
              }) => PlacedModulesCompanion(
                id: id,
                roofId: roofId,
                moduleId: moduleId,
                x: x,
                y: y,
                rotationDeg: rotationDeg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roofId,
                required int moduleId,
                required double x,
                required double y,
                Value<double> rotationDeg = const Value.absent(),
              }) => PlacedModulesCompanion.insert(
                id: id,
                roofId: roofId,
                moduleId: moduleId,
                x: x,
                y: y,
                rotationDeg: rotationDeg,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlacedModulesTable, PlacedModule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlacedModulesTable,
                    PlacedModule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacedModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacedModulesTable,
      PlacedModule,
      $$PlacedModulesTableFilterComposer,
      $$PlacedModulesTableOrderingComposer,
      $$PlacedModulesTableAnnotationComposer,
      $$PlacedModulesTableCreateCompanionBuilder,
      $$PlacedModulesTableUpdateCompanionBuilder,
      (
        PlacedModule,
        BaseReferences<_$AppDatabase, $PlacedModulesTable, PlacedModule>,
      ),
      PlacedModule,
      PrefetchHooks Function()
    >;
typedef $$ModuleStringsTableCreateCompanionBuilder =
    ModuleStringsCompanion Function({
      Value<int> id,
      required int projectId,
      required String name,
      Value<int?> inverterId,
      Value<int?> mppIndex,
      Value<double?> dcCableMm2,
      Value<double?> fuseA,
    });
typedef $$ModuleStringsTableUpdateCompanionBuilder =
    ModuleStringsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> name,
      Value<int?> inverterId,
      Value<int?> mppIndex,
      Value<double?> dcCableMm2,
      Value<double?> fuseA,
    });

class $$ModuleStringsTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleStringsTable> {
  $$ModuleStringsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mppIndex => $composableBuilder(
    column: $table.mppIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dcCableMm2 => $composableBuilder(
    column: $table.dcCableMm2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuseA => $composableBuilder(
    column: $table.fuseA,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModuleStringsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleStringsTable> {
  $$ModuleStringsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mppIndex => $composableBuilder(
    column: $table.mppIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dcCableMm2 => $composableBuilder(
    column: $table.dcCableMm2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuseA => $composableBuilder(
    column: $table.fuseA,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModuleStringsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleStringsTable> {
  $$ModuleStringsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mppIndex =>
      $composableBuilder(column: $table.mppIndex, builder: (column) => column);

  GeneratedColumn<double> get dcCableMm2 => $composableBuilder(
    column: $table.dcCableMm2,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fuseA =>
      $composableBuilder(column: $table.fuseA, builder: (column) => column);
}

class $$ModuleStringsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModuleStringsTable,
          ModuleString,
          $$ModuleStringsTableFilterComposer,
          $$ModuleStringsTableOrderingComposer,
          $$ModuleStringsTableAnnotationComposer,
          $$ModuleStringsTableCreateCompanionBuilder,
          $$ModuleStringsTableUpdateCompanionBuilder,
          (
            ModuleString,
            BaseReferences<_$AppDatabase, $ModuleStringsTable, ModuleString>,
          ),
          ModuleString,
          PrefetchHooks Function()
        > {
  $$ModuleStringsTableTableManager(_$AppDatabase db, $ModuleStringsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleStringsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModuleStringsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModuleStringsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> inverterId = const Value.absent(),
                Value<int?> mppIndex = const Value.absent(),
                Value<double?> dcCableMm2 = const Value.absent(),
                Value<double?> fuseA = const Value.absent(),
              }) => ModuleStringsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                inverterId: inverterId,
                mppIndex: mppIndex,
                dcCableMm2: dcCableMm2,
                fuseA: fuseA,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String name,
                Value<int?> inverterId = const Value.absent(),
                Value<int?> mppIndex = const Value.absent(),
                Value<double?> dcCableMm2 = const Value.absent(),
                Value<double?> fuseA = const Value.absent(),
              }) => ModuleStringsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                inverterId: inverterId,
                mppIndex: mppIndex,
                dcCableMm2: dcCableMm2,
                fuseA: fuseA,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModuleStringsTable, ModuleString>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ModuleStringsTable,
                    ModuleString
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModuleStringsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModuleStringsTable,
      ModuleString,
      $$ModuleStringsTableFilterComposer,
      $$ModuleStringsTableOrderingComposer,
      $$ModuleStringsTableAnnotationComposer,
      $$ModuleStringsTableCreateCompanionBuilder,
      $$ModuleStringsTableUpdateCompanionBuilder,
      (
        ModuleString,
        BaseReferences<_$AppDatabase, $ModuleStringsTable, ModuleString>,
      ),
      ModuleString,
      PrefetchHooks Function()
    >;
typedef $$StringModulesTableCreateCompanionBuilder =
    StringModulesCompanion Function({
      required int stringId,
      required int placedModuleId,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$StringModulesTableUpdateCompanionBuilder =
    StringModulesCompanion Function({
      Value<int> stringId,
      Value<int> placedModuleId,
      Value<int> position,
      Value<int> rowid,
    });

class $$StringModulesTableFilterComposer
    extends Composer<_$AppDatabase, $StringModulesTable> {
  $$StringModulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stringId => $composableBuilder(
    column: $table.stringId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placedModuleId => $composableBuilder(
    column: $table.placedModuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StringModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $StringModulesTable> {
  $$StringModulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stringId => $composableBuilder(
    column: $table.stringId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placedModuleId => $composableBuilder(
    column: $table.placedModuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StringModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StringModulesTable> {
  $$StringModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stringId =>
      $composableBuilder(column: $table.stringId, builder: (column) => column);

  GeneratedColumn<int> get placedModuleId => $composableBuilder(
    column: $table.placedModuleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$StringModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StringModulesTable,
          StringModule,
          $$StringModulesTableFilterComposer,
          $$StringModulesTableOrderingComposer,
          $$StringModulesTableAnnotationComposer,
          $$StringModulesTableCreateCompanionBuilder,
          $$StringModulesTableUpdateCompanionBuilder,
          (
            StringModule,
            BaseReferences<_$AppDatabase, $StringModulesTable, StringModule>,
          ),
          StringModule,
          PrefetchHooks Function()
        > {
  $$StringModulesTableTableManager(_$AppDatabase db, $StringModulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StringModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StringModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StringModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> stringId = const Value.absent(),
                Value<int> placedModuleId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StringModulesCompanion(
                stringId: stringId,
                placedModuleId: placedModuleId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int stringId,
                required int placedModuleId,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StringModulesCompanion.insert(
                stringId: stringId,
                placedModuleId: placedModuleId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StringModulesTable, StringModule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StringModulesTable,
                    StringModule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StringModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StringModulesTable,
      StringModule,
      $$StringModulesTableFilterComposer,
      $$StringModulesTableOrderingComposer,
      $$StringModulesTableAnnotationComposer,
      $$StringModulesTableCreateCompanionBuilder,
      $$StringModulesTableUpdateCompanionBuilder,
      (
        StringModule,
        BaseReferences<_$AppDatabase, $StringModulesTable, StringModule>,
      ),
      StringModule,
      PrefetchHooks Function()
    >;
typedef $$ScenariosTableCreateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  required int projectId,
  required String name,
  Value<int?> inverterId,
  Value<int?> batteryId,
  Value<int?> wallboxId,
  Value<String> notes,
});
typedef $$ScenariosTableUpdateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> name,
  Value<int?> inverterId,
  Value<int?> batteryId,
  Value<int?> wallboxId,
  Value<String> notes,
});

class $$ScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryId => $composableBuilder(
    column: $table.batteryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wallboxId => $composableBuilder(
    column: $table.wallboxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryId => $composableBuilder(
    column: $table.batteryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wallboxId => $composableBuilder(
    column: $table.wallboxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get inverterId => $composableBuilder(
    column: $table.inverterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryId =>
      $composableBuilder(column: $table.batteryId, builder: (column) => column);

  GeneratedColumn<int> get wallboxId =>
      $composableBuilder(column: $table.wallboxId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenariosTable,
          Scenario,
          $$ScenariosTableFilterComposer,
          $$ScenariosTableOrderingComposer,
          $$ScenariosTableAnnotationComposer,
          $$ScenariosTableCreateCompanionBuilder,
          $$ScenariosTableUpdateCompanionBuilder,
          (Scenario, BaseReferences<_$AppDatabase, $ScenariosTable, Scenario>),
          Scenario,
          PrefetchHooks Function()
        > {
  $$ScenariosTableTableManager(_$AppDatabase db, $ScenariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> inverterId = const Value.absent(),
                Value<int?> batteryId = const Value.absent(),
                Value<int?> wallboxId = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => ScenariosCompanion(
                id: id,
                projectId: projectId,
                name: name,
                inverterId: inverterId,
                batteryId: batteryId,
                wallboxId: wallboxId,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String name,
                Value<int?> inverterId = const Value.absent(),
                Value<int?> batteryId = const Value.absent(),
                Value<int?> wallboxId = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => ScenariosCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                inverterId: inverterId,
                batteryId: batteryId,
                wallboxId: wallboxId,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScenariosTable, Scenario>(table),
                  BaseReferences<_$AppDatabase, $ScenariosTable, Scenario>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenariosTable,
      Scenario,
      $$ScenariosTableFilterComposer,
      $$ScenariosTableOrderingComposer,
      $$ScenariosTableAnnotationComposer,
      $$ScenariosTableCreateCompanionBuilder,
      $$ScenariosTableUpdateCompanionBuilder,
      (Scenario, BaseReferences<_$AppDatabase, $ScenariosTable, Scenario>),
      Scenario,
      PrefetchHooks Function()
    >;
typedef $$ScenarioResultsTableCreateCompanionBuilder =
    ScenarioResultsCompanion Function({
      Value<int> id,
      required int scenarioId,
      required double annualYieldKwh,
      required double shadingLossPct,
      required double specificYieldKwhPerKwp,
      required int computedAt,
    });
typedef $$ScenarioResultsTableUpdateCompanionBuilder =
    ScenarioResultsCompanion Function({
      Value<int> id,
      Value<int> scenarioId,
      Value<double> annualYieldKwh,
      Value<double> shadingLossPct,
      Value<double> specificYieldKwhPerKwp,
      Value<int> computedAt,
    });

class $$ScenarioResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ScenarioResultsTable> {
  $$ScenarioResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualYieldKwh => $composableBuilder(
    column: $table.annualYieldKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shadingLossPct => $composableBuilder(
    column: $table.shadingLossPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get specificYieldKwhPerKwp => $composableBuilder(
    column: $table.specificYieldKwhPerKwp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScenarioResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenarioResultsTable> {
  $$ScenarioResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualYieldKwh => $composableBuilder(
    column: $table.annualYieldKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shadingLossPct => $composableBuilder(
    column: $table.shadingLossPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get specificYieldKwhPerKwp => $composableBuilder(
    column: $table.specificYieldKwhPerKwp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScenarioResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenarioResultsTable> {
  $$ScenarioResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualYieldKwh => $composableBuilder(
    column: $table.annualYieldKwh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shadingLossPct => $composableBuilder(
    column: $table.shadingLossPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get specificYieldKwhPerKwp => $composableBuilder(
    column: $table.specificYieldKwhPerKwp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );
}

class $$ScenarioResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenarioResultsTable,
          ScenarioResult,
          $$ScenarioResultsTableFilterComposer,
          $$ScenarioResultsTableOrderingComposer,
          $$ScenarioResultsTableAnnotationComposer,
          $$ScenarioResultsTableCreateCompanionBuilder,
          $$ScenarioResultsTableUpdateCompanionBuilder,
          (
            ScenarioResult,
            BaseReferences<
              _$AppDatabase,
              $ScenarioResultsTable,
              ScenarioResult
            >,
          ),
          ScenarioResult,
          PrefetchHooks Function()
        > {
  $$ScenarioResultsTableTableManager(
    _$AppDatabase db,
    $ScenarioResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenarioResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenarioResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenarioResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scenarioId = const Value.absent(),
                Value<double> annualYieldKwh = const Value.absent(),
                Value<double> shadingLossPct = const Value.absent(),
                Value<double> specificYieldKwhPerKwp = const Value.absent(),
                Value<int> computedAt = const Value.absent(),
              }) => ScenarioResultsCompanion(
                id: id,
                scenarioId: scenarioId,
                annualYieldKwh: annualYieldKwh,
                shadingLossPct: shadingLossPct,
                specificYieldKwhPerKwp: specificYieldKwhPerKwp,
                computedAt: computedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scenarioId,
                required double annualYieldKwh,
                required double shadingLossPct,
                required double specificYieldKwhPerKwp,
                required int computedAt,
              }) => ScenarioResultsCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                annualYieldKwh: annualYieldKwh,
                shadingLossPct: shadingLossPct,
                specificYieldKwhPerKwp: specificYieldKwhPerKwp,
                computedAt: computedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScenarioResultsTable, ScenarioResult>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScenarioResultsTable,
                    ScenarioResult
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScenarioResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenarioResultsTable,
      ScenarioResult,
      $$ScenarioResultsTableFilterComposer,
      $$ScenarioResultsTableOrderingComposer,
      $$ScenarioResultsTableAnnotationComposer,
      $$ScenarioResultsTableCreateCompanionBuilder,
      $$ScenarioResultsTableUpdateCompanionBuilder,
      (
        ScenarioResult,
        BaseReferences<_$AppDatabase, $ScenarioResultsTable, ScenarioResult>,
      ),
      ScenarioResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SolarModulesTableTableManager get solarModules =>
      $$SolarModulesTableTableManager(_db, _db.solarModules);
  $$InvertersTableTableManager get inverters =>
      $$InvertersTableTableManager(_db, _db.inverters);
  $$BatteriesTableTableManager get batteries =>
      $$BatteriesTableTableManager(_db, _db.batteries);
  $$WallboxesTableTableManager get wallboxes =>
      $$WallboxesTableTableManager(_db, _db.wallboxes);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$RoofsTableTableManager get roofs =>
      $$RoofsTableTableManager(_db, _db.roofs);
  $$ObstaclesTableTableManager get obstacles =>
      $$ObstaclesTableTableManager(_db, _db.obstacles);
  $$PlacedModulesTableTableManager get placedModules =>
      $$PlacedModulesTableTableManager(_db, _db.placedModules);
  $$ModuleStringsTableTableManager get moduleStrings =>
      $$ModuleStringsTableTableManager(_db, _db.moduleStrings);
  $$StringModulesTableTableManager get stringModules =>
      $$StringModulesTableTableManager(_db, _db.stringModules);
  $$ScenariosTableTableManager get scenarios =>
      $$ScenariosTableTableManager(_db, _db.scenarios);
  $$ScenarioResultsTableTableManager get scenarioResults =>
      $$ScenarioResultsTableTableManager(_db, _db.scenarioResults);
}
