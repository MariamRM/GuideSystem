part of 'main.dart';

const double zoneOffsetAmount = 0.04;

class PlaceSpec {
  final String id;
  final String type;
  final String label;
  final String? code;
  final String? publicCode;
  final String? codeOnPlan;
  final String? normalizedCode;
  final String? doorId;
  final String? floor;
  final String? wing;
  final String? zone;
  final Offset? norm;

  const PlaceSpec({
    required this.id,
    required this.type,
    required this.label,
    this.code,
    this.publicCode,
    this.codeOnPlan,
    this.normalizedCode,
    this.doorId,
    this.floor,
    this.wing,
    this.zone,
    this.norm,
  });

  factory PlaceSpec.fromJson(Map<String, dynamic> json) {
    final codeOnPlan =
        (json['codeOnPlan'] as String?) ?? (json['code'] as String?);
    final id =
        (json['id'] as String?) ??
        codeOnPlan ??
        (json['code'] as String?) ??
        'UNKNOWN';
    final type = (json['type'] as String?) ?? 'place';
    final label =
        (json['label'] as String?) ??
        (json['displayName'] as String?) ??
        (json['description'] as String?) ??
        _labelForType(type) ??
        id;
    final normalizedCode = json['normalizedCode'] as String?;
    return PlaceSpec(
      id: id,
      type: type,
      label: label,
      code: codeOnPlan,
      publicCode: json['publicCode'] as String?,
      codeOnPlan: codeOnPlan,
      normalizedCode: normalizedCode,
      doorId: json['doorId'] as String?,
      floor: json['floor'] as String?,
      wing: json['wing'] as String?,
      zone: json['zone'] as String?,
      norm: _readNorm(json),
    );
  }
}

class GraphNodeSpec {
  final String id;
  final String type;
  final String label;
  final Offset? norm;

  const GraphNodeSpec({
    required this.id,
    required this.type,
    required this.label,
    this.norm,
  });

  factory GraphNodeSpec.fromJson(Map<String, dynamic> json) {
    return GraphNodeSpec(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'node',
      label: (json['label'] as String?) ?? (json['id'] as String),
      norm: _readNorm(json),
    );
  }
}

class GraphEdgeSpec {
  final String from;
  final String to;
  final double distance;
  final String kind;

  const GraphEdgeSpec({
    required this.from,
    required this.to,
    required this.distance,
    required this.kind,
  });

  factory GraphEdgeSpec.fromJson(Map<String, dynamic> json) {
    final distanceValue = json['distance'] ?? json['cost'] ?? 1;
    return GraphEdgeSpec(
      from: json['from'] as String,
      to: json['to'] as String,
      distance: (distanceValue as num).toDouble(),
      kind: (json['kind'] as String?) ?? 'walk',
    );
  }
}

class InterFloorLink {
  final String from;
  final String to;
  final double cost;
  final String kind;

  const InterFloorLink({
    required this.from,
    required this.to,
    required this.cost,
    required this.kind,
  });

  factory InterFloorLink.fromJson(Map<String, dynamic> json) {
    return InterFloorLink(
      from: json['from'] as String,
      to: json['to'] as String,
      cost: (json['cost'] as num).toDouble(),
      kind: (json['kind'] as String?) ?? 'link',
    );
  }
}

class FloorModel {
  final String id;
  final List<PlaceSpec> landmarks;
  final List<PlaceSpec> rooms;
  final List<GraphNodeSpec> nodes;
  final List<GraphEdgeSpec> edges;

  const FloorModel({
    required this.id,
    required this.landmarks,
    required this.rooms,
    required this.nodes,
    required this.edges,
  });

  factory FloorModel.fromJson(String id, Map<String, dynamic> json) {
    final landmarks = (json['landmarks'] as List<dynamic>? ?? [])
        .map((e) => PlaceSpec.fromJson(e))
        .toList();
    final rooms = (json['rooms'] as List<dynamic>? ?? [])
        .map((e) => PlaceSpec.fromJson(e))
        .toList();
    final graph = (json['graph'] as Map<String, dynamic>? ?? {});
    final nodes = (graph['nodes'] as List<dynamic>? ?? [])
        .map((e) => GraphNodeSpec.fromJson(e))
        .toList();
    final edges = (graph['edges'] as List<dynamic>? ?? [])
        .map((e) => GraphEdgeSpec.fromJson(e))
        .toList();
    return FloorModel(
      id: id,
      landmarks: landmarks,
      rooms: rooms,
      nodes: nodes,
      edges: edges,
    );
  }
}

class MapData {
  final Map<String, FloorModel> floors;
  final List<InterFloorLink> interFloorLinks;

  const MapData({required this.floors, required this.interFloorLinks});

  factory MapData.fromJson(Map<String, dynamic> json) {
    final floorsJson = (json['floors'] as Map<String, dynamic>? ?? {});
    final floors = <String, FloorModel>{};
    for (final entry in floorsJson.entries) {
      floors[entry.key] = FloorModel.fromJson(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }
    final links = (json['interFloorLinks'] as List<dynamic>? ?? [])
        .map((e) => InterFloorLink.fromJson(e as Map<String, dynamic>))
        .toList();
    return MapData(floors: floors, interFloorLinks: links);
  }
}

bool _looksLikeNavigationGraph(Map<String, dynamic> json) {
  if (json.containsKey('schemaVersion') ||
      json.containsKey('coordinateSystem')) {
    return true;
  }
  final floors = json['floors'];
  if (floors is Map && floors.isNotEmpty) {
    for (final value in floors.values) {
      if (value is Map<String, dynamic>) {
        if (value['nodes'] is Map ||
            value['doors'] is Map ||
            value['edges'] is List) {
          return true;
        }
        if (value['rooms'] is Map) {
          return true;
        }
      }
      break;
    }
  }
  return false;
}

MapData mapDataFromNavigationGraph(Map<String, dynamic> json) {
  final coord = (json['coordinateSystem'] as Map<String, dynamic>? ?? {});
  final width = (coord['width'] as num?)?.toDouble() ?? 1.0;
  final height = (coord['height'] as num?)?.toDouble() ?? 1.0;
  final floorsJson = (json['floors'] as Map<String, dynamic>? ?? {});
  final floors = <String, FloorModel>{};

  for (final entry in floorsJson.entries) {
    final floorId = entry.key;
    final floorJson = entry.value as Map<String, dynamic>;
    final nodesJson = (floorJson['nodes'] as Map<String, dynamic>? ?? {});
    final roomsJson = (floorJson['rooms'] as Map<String, dynamic>? ?? {});
    final doorsJson = (floorJson['doors'] as Map<String, dynamic>? ?? {});
    final edgesJson = (floorJson['edges'] as List<dynamic>? ?? []);

    final nodes = <GraphNodeSpec>[];
    final landmarks = <PlaceSpec>[];

    nodesJson.forEach((id, raw) {
      if (raw is! Map<String, dynamic>) return;
      final kind = (raw['kind'] as String?) ?? 'node';
      final label = (raw['label'] as String?) ?? id;
      final norm = _normFromXY(raw, width, height);
      nodes.add(GraphNodeSpec(id: id, type: kind, label: label, norm: norm));
      if (kind == 'entrance' || kind == 'stairs') {
        landmarks.add(PlaceSpec(id: id, type: kind, label: label, norm: norm));
      }
    });

    doorsJson.forEach((id, raw) {
      if (raw is! Map<String, dynamic>) return;
      final point = _normFromPoint(
        raw['point'] as Map<String, dynamic>?,
        width,
        height,
      );
      if (point == null) return;
      nodes.add(GraphNodeSpec(id: id, type: 'door', label: id, norm: point));
    });

    final rooms = <PlaceSpec>[];
    roomsJson.forEach((id, raw) {
      if (raw is! Map<String, dynamic>) return;
      final labelPoint = _normFromPoint(
        raw['labelPoint'] as Map<String, dynamic>?,
        width,
        height,
      );
      final roomId = (raw['id'] as String?) ?? id;
      final label = (raw['label'] as String?) ?? roomId;
      rooms.add(
        PlaceSpec(
          id: roomId,
          type: (raw['type'] as String?) ?? 'room',
          label: label,
          floor: (raw['floor'] as String?) ?? floorId,
          wing: raw['wing'] as String?,
          doorId: raw['doorId'] as String?,
          norm: labelPoint,
        ),
      );
    });

    final edges = edgesJson
        .whereType<Map<String, dynamic>>()
        .map(
          (edge) => GraphEdgeSpec(
            from: edge['from'] as String,
            to: edge['to'] as String,
            distance: (edge['distance'] as num?)?.toDouble() ?? 1.0,
            kind: (edge['kind'] as String?) ?? 'corridor',
          ),
        )
        .toList();

    floors[floorId] = FloorModel(
      id: floorId,
      landmarks: landmarks,
      rooms: rooms,
      nodes: nodes,
      edges: edges,
    );
  }

  final links = (json['interFloorLinks'] as List<dynamic>? ?? [])
      .map((e) => InterFloorLink.fromJson(e as Map<String, dynamic>))
      .toList();
  return MapData(floors: floors, interFloorLinks: links);
}

class EdgeLink {
  final String to;
  final double distance;
  final String kind;

  const EdgeLink({
    required this.to,
    required this.distance,
    required this.kind,
  });
}

class FloorGraph {
  final FloorModel model;
  final Map<String, Offset> normPos;
  final Map<String, String> type;
  final Map<String, String> label;
  final Map<String, List<EdgeLink>> adj;
  final Map<String, double> edgeDistances;
  final List<PlaceSpec> rooms;
  final List<PlaceSpec> landmarks;

  const FloorGraph({
    required this.model,
    required this.normPos,
    required this.type,
    required this.label,
    required this.adj,
    required this.edgeDistances,
    required this.rooms,
    required this.landmarks,
  });

  bool isWalkNode(String id) {
    final t = type[id] ?? '';
    return t != 'room';
  }
}

Offset? _readNorm(Map<String, dynamic> json) {
  final x = json['x'];
  final y = json['y'];
  if (x == null || y == null) return null;
  return Offset((x as num).toDouble(), (y as num).toDouble());
}

Offset _clampNorm(Offset p) {
  final dx = p.dx.clamp(0.0, 1.0);
  final dy = p.dy.clamp(0.0, 1.0);
  return Offset(dx, dy);
}

Offset? _normFromNumbers(Object? x, Object? y, double width, double height) {
  if (x == null || y == null) return null;
  final w = width == 0 ? 1.0 : width;
  final h = height == 0 ? 1.0 : height;
  return _clampNorm(
    Offset((x as num).toDouble() / w, (y as num).toDouble() / h),
  );
}

Offset? _normFromXY(Map<String, dynamic> json, double width, double height) {
  return _normFromNumbers(json['x'], json['y'], width, height);
}

Offset? _normFromPoint(
  Map<String, dynamic>? json,
  double width,
  double height,
) {
  if (json == null) return null;
  return _normFromNumbers(json['x'], json['y'], width, height);
}

FloorGraph buildFloorGraph(FloorModel model) {
  final normPos = <String, Offset>{};
  final type = <String, String>{};
  final label = <String, String>{};
  final adj = <String, List<EdgeLink>>{};
  final edgeDistances = <String, double>{};

  void addNode(String id, String nodeType, String nodeLabel, Offset? pos) {
    type[id] = nodeType;
    label[id] = nodeLabel;
    if (pos != null) {
      normPos[id] = _clampNorm(pos);
    }
  }

  for (final lm in model.landmarks) {
    addNode(lm.id, lm.type, lm.label, lm.norm);
  }
  for (final node in model.nodes) {
    addNode(node.id, node.type, node.label, node.norm);
  }
  for (final room in model.rooms) {
    addNode(room.id, 'room', _placeLabel(room), room.norm);
  }

  void addEdge(String from, String to, double distance, String kind) {
    adj
        .putIfAbsent(from, () => [])
        .add(EdgeLink(to: to, distance: distance, kind: kind));
    adj
        .putIfAbsent(to, () => [])
        .add(EdgeLink(to: from, distance: distance, kind: kind));
    edgeDistances['$from|$to'] = distance;
    edgeDistances['$to|$from'] = distance;
  }

  for (final edge in model.edges) {
    if (!type.containsKey(edge.from)) {
      addNode(edge.from, 'node', edge.from, null);
    }
    if (!type.containsKey(edge.to)) {
      addNode(edge.to, 'node', edge.to, null);
    }
    addEdge(edge.from, edge.to, edge.distance, edge.kind);
  }

  final anchors = zoneAnchors[model.id] ?? {};
  Offset? anchorForZone(String? zone) {
    if (zone == null) return null;
    final anchorId = anchors[zone];
    if (anchorId != null && normPos.containsKey(anchorId)) {
      return normPos[anchorId];
    }
    return null;
  }

  Offset offsetForZone(String? zone) {
    if (zone == null) return const Offset(0, 0);
    final up = zone.contains('NORTH');
    final down = zone.contains('SOUTH');
    final east = zone.contains('EAST');
    final west = zone.contains('WEST');
    final dx = east ? zoneOffsetAmount : (west ? -zoneOffsetAmount : 0.0);
    final dy = down ? zoneOffsetAmount : (up ? -zoneOffsetAmount : 0.0);
    return Offset(dx, dy);
  }

  for (final room in model.rooms) {
    if (room.norm != null) {
      normPos[room.id] = _clampNorm(room.norm!);
      continue;
    }
    final anchor =
        anchorForZone(room.zone) ??
        (normPos.isNotEmpty ? normPos.values.first : const Offset(0.5, 0.5));
    normPos[room.id] = _clampNorm(anchor + offsetForZone(room.zone));
  }

  final unresolved = <String>{};
  for (final id in type.keys) {
    if (!normPos.containsKey(id)) unresolved.add(id);
  }
  for (var pass = 0; pass < 4; pass++) {
    var progress = false;
    for (final edge in model.edges) {
      final a = edge.from;
      final b = edge.to;
      if (normPos.containsKey(a) && !normPos.containsKey(b)) {
        normPos[b] = normPos[a]!;
        progress = true;
      } else if (normPos.containsKey(b) && !normPos.containsKey(a)) {
        normPos[a] = normPos[b]!;
        progress = true;
      }
    }
    if (!progress) break;
  }

  for (final room in model.rooms) {
    final hasEdge = adj.containsKey(room.id);
    if (hasEdge) continue;
    final anchorId = anchors[room.zone];
    if (anchorId != null) {
      addEdge(anchorId, room.id, 6, 'access');
    }
  }

  return FloorGraph(
    model: model,
    normPos: normPos,
    type: type,
    label: label,
    adj: adj,
    edgeDistances: edgeDistances,
    rooms: model.rooms,
    landmarks: model.landmarks,
  );
}

class NormalizedRoomCode {
  final String floor;
  final String wing;
  final String number;

  const NormalizedRoomCode({
    required this.floor,
    required this.wing,
    required this.number,
  });

  String get fullCode => '$floor$wing$number';
  String get normalizedCode => '$floor$number';
}

NormalizedRoomCode? normalizeRoomCode(String input) {
  final compact = input.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '').toUpperCase();
  if (compact.isEmpty) return null;
  final m1 = RegExp(r'^([GF])([EW])(\d{1,3})$').firstMatch(compact);
  if (m1 != null) {
    return NormalizedRoomCode(
      floor: m1.group(1)!,
      wing: m1.group(2)!,
      number: m1.group(3)!.padLeft(3, '0'),
    );
  }
  final m2 = RegExp(r'^([GF])(\d{1,3})([EW])$').firstMatch(compact);
  if (m2 != null) {
    return NormalizedRoomCode(
      floor: m2.group(1)!,
      wing: m2.group(3)!,
      number: m2.group(2)!.padLeft(3, '0'),
    );
  }
  final m3 = RegExp(r'^([GF])(\d{1,3})$').firstMatch(compact);
  if (m3 != null) {
    return NormalizedRoomCode(
      floor: m3.group(1)!,
      wing: '',
      number: m3.group(2)!.padLeft(3, '0'),
    );
  }
  return null;
}

String _compactSearch(String input) {
  return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

NormalizedRoomCode? _normalizedFromPlace(PlaceSpec place) {
  final raw = place.codeOnPlan ?? place.code ?? place.id;
  return normalizeRoomCode(raw);
}
