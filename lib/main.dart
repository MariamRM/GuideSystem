import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

part 'guide_data.dart';
part 'guide_translations.dart';

void main() {
  runApp(const ClassGuideApp());
}

class ClassGuideApp extends StatefulWidget {
  const ClassGuideApp({super.key});

  @override
  State<ClassGuideApp> createState() => _ClassGuideAppState();
}

class _ClassGuideAppState extends State<ClassGuideApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B4AA2);
    return MaterialApp(
      title: 'ClassGuide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F7FF),
      ),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: GuideHomePage(locale: _locale, onLocaleChanged: _setLocale),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum FloorKind { ff, gf }

enum SetMode { my, dest }

enum EditAction {
  none,
  addNode,
  selectNode,
  moveNode,
  connect,
  drawPath,
  deleteNode,
  addDoor,
}

enum NodeKind { corridor, junction, entrance, stairs }

class FacilityKind {
  final String type;
  final String labelKey;
  final IconData icon;
  final Color color;

  const FacilityKind({
    required this.type,
    required this.labelKey,
    required this.icon,
    required this.color,
  });
}

class FacilityMarker {
  final String id;
  final Offset imagePos;
  final IconData icon;
  final Color color;

  const FacilityMarker({
    required this.id,
    required this.imagePos,
    required this.icon,
    required this.color,
  });
}

const List<FacilityKind> facilityKinds = [
  FacilityKind(
    type: 'bathroom_male',
    labelKey: 'facility_bathroom_male',
    icon: Icons.male,
    color: Color(0xFF2563EB),
  ),
  FacilityKind(
    type: 'bathroom_female',
    labelKey: 'facility_bathroom_female',
    icon: Icons.female,
    color: Color(0xFFEC4899),
  ),
  FacilityKind(
    type: 'prayer_male',
    labelKey: 'facility_prayer_male',
    icon: Icons.mosque,
    color: Color(0xFF10B981),
  ),
  FacilityKind(
    type: 'prayer_female',
    labelKey: 'facility_prayer_female',
    icon: Icons.mosque,
    color: Color(0xFF14B8A6),
  ),
  FacilityKind(
    type: 'library',
    labelKey: 'facility_library',
    icon: Icons.local_library,
    color: Color(0xFF7C3AED),
  ),
  FacilityKind(
    type: 'cafe',
    labelKey: 'facility_cafe',
    icon: Icons.local_cafe,
    color: Color(0xFFF59E0B),
  ),
];

final Map<String, FacilityKind> facilityByType = {
  for (final kind in facilityKinds) kind.type: kind,
};

// New floorplan images are square (6000x6000) with a dark background.
// These bounds tightly fit the visible plan area.
const Rect ffBounds = Rect.fromLTRB(1496, 140, 5192, 5904);
const Rect gfBounds = Rect.fromLTRB(1384, 104, 5172, 5872);

const String mapDataJson = r'''
{
  "schemaVersion": "2.0",
  "generatedAt": "2026-03-09T20:50:37+00:00",
  "coordinateSystem": {
    "width": 1000,
    "height": 1000,
    "origin": "top-left"
  },
  "floors": {
    "G": {
      "nodes": {
        "G_ENT_1": {
          "id": "G_ENT_1",
          "x": 554.1863405342765,
          "y": 251.87373772848736,
          "kind": "entrance"
        },
        "G_ENT_3": {
          "id": "G_ENT_3",
          "x": 42.36560671928088,
          "y": 498.98121878360524,
          "kind": "entrance"
        },
        "G_ENT_4": {
          "id": "G_ENT_4",
          "x": 593.3643452251076,
          "y": 760.0176322080599,
          "kind": "entrance"
        },
        "G_COR_1": {
          "id": "G_COR_1",
          "x": 152.81571671333774,
          "y": 498.7085257305855,
          "kind": "corridor"
        },
        "G_COR_2": {
          "id": "G_COR_2",
          "x": 158.21312913214118,
          "y": 455.2531179826244,
          "kind": "corridor"
        },
        "G_COR_3": {
          "id": "G_COR_3",
          "x": 228.61834856595246,
          "y": 410.00782071803695,
          "kind": "corridor"
        },
        "G_COR_5": {
          "id": "G_COR_5",
          "x": 194.29353528817217,
          "y": 430.4826256906281,
          "kind": "corridor"
        },
        "G_COR_6": {
          "id": "G_COR_6",
          "x": 157.82231605590772,
          "y": 544.1752039926258,
          "kind": "corridor"
        },
        "G_COR_4": {
          "id": "G_COR_4",
          "x": 190.8227867015653,
          "y": 382.399373365984,
          "kind": "corridor"
        },
        "G_COR_7": {
          "id": "G_COR_7",
          "x": 390.69253139962495,
          "y": 286.28450521953727,
          "kind": "corridor"
        },
        "G_COR_8": {
          "id": "G_COR_8",
          "x": 308.2767910325114,
          "y": 393.2997572566334,
          "kind": "corridor"
        },
        "G_COR_9": {
          "id": "G_COR_9",
          "x": 385.5716358825058,
          "y": 341.4144425990786,
          "kind": "corridor"
        },
        "G_COR_10": {
          "id": "G_COR_10",
          "x": 447.27983428341594,
          "y": 303.841535048523,
          "kind": "corridor"
        },
        "G_COR_11": {
          "id": "G_COR_11",
          "x": 350.1221722342741,
          "y": 314.78261579503334,
          "kind": "corridor"
        },
        "G_COR_12": {
          "id": "G_COR_12",
          "x": 56.860688307382965,
          "y": 499.32899010255363,
          "kind": "corridor"
        },
        "G_COR_13": {
          "id": "G_COR_13",
          "x": 159.48281774505585,
          "y": 454.34551409619843,
          "kind": "corridor"
        },
        "G_COR_14": {
          "id": "G_COR_14",
          "x": 190.63206671718746,
          "y": 382.6112779204335,
          "kind": "corridor"
        },
        "G_COR_15": {
          "id": "G_COR_15",
          "x": 191.45560783410923,
          "y": 279.4232534254005,
          "kind": "corridor"
        },
        "G_COR_16": {
          "id": "G_COR_16",
          "x": 190.63330462051957,
          "y": 204.67648240123356,
          "kind": "corridor"
        },
        "G_COR_17": {
          "id": "G_COR_17",
          "x": 519.1000138821408,
          "y": 274.11997314402083,
          "kind": "corridor"
        },
        "G_COR_18": {
          "id": "G_COR_18",
          "x": 499.5476113831952,
          "y": 263.96976986644654,
          "kind": "corridor"
        },
        "G_COR_19": {
          "id": "G_COR_19",
          "x": 584.8322909037714,
          "y": 320.04241202972145,
          "kind": "corridor"
        },
        "G_COR_20": {
          "id": "G_COR_20",
          "x": 618.7337625137928,
          "y": 345.04859895724735,
          "kind": "corridor"
        },
        "G_COR_21": {
          "id": "G_COR_21",
          "x": 655.560113906421,
          "y": 370.7758740418571,
          "kind": "corridor"
        },
        "G_COR_22": {
          "id": "G_COR_22",
          "x": 690.9965884736755,
          "y": 391.72843825935865,
          "kind": "corridor"
        },
        "G_COR_23": {
          "id": "G_COR_23",
          "x": 710.1138366890773,
          "y": 404.946064336137,
          "kind": "corridor"
        },
        "G_COR_25": {
          "id": "G_COR_25",
          "x": 735.7668780892596,
          "y": 424.6871120444991,
          "kind": "corridor"
        },
        "G_COR_24": {
          "id": "G_COR_24",
          "x": 775.6819127337559,
          "y": 448.64447153365603,
          "kind": "corridor"
        },
        "G_COR_26": {
          "id": "G_COR_26",
          "x": 818.4042669258914,
          "y": 476.4548911289462,
          "kind": "corridor"
        },
        "G_COR_28": {
          "id": "G_COR_28",
          "x": 828.9207539060277,
          "y": 519.1339055506921,
          "kind": "corridor"
        },
        "G_COR_29": {
          "id": "G_COR_29",
          "x": 773.5743649521908,
          "y": 553.3963820970422,
          "kind": "corridor"
        },
        "G_COR_30": {
          "id": "G_COR_30",
          "x": 190.34421018011903,
          "y": 127.48141304049837,
          "kind": "corridor"
        },
        "G_COR_31": {
          "id": "G_COR_31",
          "x": 224.08939679959173,
          "y": 590.8402553979511,
          "kind": "corridor"
        },
        "G_COR_32": {
          "id": "G_COR_32",
          "x": 259.86209646520035,
          "y": 573.0625974170432,
          "kind": "corridor"
        },
        "G_COR_33": {
          "id": "G_COR_33",
          "x": 189.12841682141215,
          "y": 621.0162650321616,
          "kind": "corridor"
        },
        "G_COR_34": {
          "id": "G_COR_34",
          "x": 189.2188619627217,
          "y": 655.8708851770448,
          "kind": "corridor"
        },
        "G_COR_35": {
          "id": "G_COR_35",
          "x": 190.28213788432862,
          "y": 683.5916753850088,
          "kind": "corridor"
        },
        "G_COR_36": {
          "id": "G_COR_36",
          "x": 187.96642940364927,
          "y": 705.2831107054282,
          "kind": "corridor"
        },
        "G_COR_37": {
          "id": "G_COR_37",
          "x": 190.06523244248984,
          "y": 772.1852841267046,
          "kind": "corridor"
        },
        "G_COR_38": {
          "id": "G_COR_38",
          "x": 233.05282530727152,
          "y": 708.9184709591765,
          "kind": "corridor"
        },
        "G_COR_39": {
          "id": "G_COR_39",
          "x": 286.2791234222892,
          "y": 746.0684901521773,
          "kind": "corridor"
        },
        "G_COR_40": {
          "id": "G_COR_40",
          "x": 330.36443467597604,
          "y": 774.7356450915299,
          "kind": "corridor"
        },
        "G_COR_41": {
          "id": "G_COR_41",
          "x": 363.9647515452357,
          "y": 799.557310360899,
          "kind": "corridor"
        },
        "G_COR_42": {
          "id": "G_COR_42",
          "x": 419.8645745793118,
          "y": 764.505025064263,
          "kind": "corridor"
        },
        "G_COR_43": {
          "id": "G_COR_43",
          "x": 442.71569349023474,
          "y": 776.616258172347,
          "kind": "corridor"
        },
        "G_COR_44": {
          "id": "G_COR_44",
          "x": 466.8079916947357,
          "y": 762.0538467508585,
          "kind": "corridor"
        },
        "G_COR_45": {
          "id": "G_COR_45",
          "x": 503.7372983506071,
          "y": 781.5573882712383,
          "kind": "corridor"
        },
        "G_COR_46": {
          "id": "G_COR_46",
          "x": 359.2273759847173,
          "y": 815.8050143840251,
          "kind": "corridor"
        },
        "G_COR_47": {
          "id": "G_COR_47",
          "x": 318.88219722813864,
          "y": 842.9637262449298,
          "kind": "corridor"
        },
        "G_COR_48": {
          "id": "G_COR_48",
          "x": 282.2685846580126,
          "y": 865.9520372148909,
          "kind": "corridor"
        },
        "G_COR_49": {
          "id": "G_COR_49",
          "x": 226.58623290339247,
          "y": 905.4827438031108,
          "kind": "corridor"
        },
        "G_COR_50": {
          "id": "G_COR_50",
          "x": 203.82239904522476,
          "y": 917.1429898466495,
          "kind": "corridor"
        },
        "G_COR_51": {
          "id": "G_COR_51",
          "x": 188.9218771147571,
          "y": 929.9963949308503,
          "kind": "corridor"
        },
        "G_COR_52": {
          "id": "G_COR_52",
          "x": 190.0394623721484,
          "y": 839.3884053566959,
          "kind": "corridor"
        },
        "G_COR_27": {
          "id": "G_COR_27",
          "x": 841.3561552771042,
          "y": 490.256457973522,
          "kind": "corridor"
        },
        "G_COR_53": {
          "id": "G_COR_53",
          "x": 854.6044757104717,
          "y": 501.22320213123027,
          "kind": "corridor"
        },
        "G_COR_54": {
          "id": "G_COR_54",
          "x": 880.635981592331,
          "y": 498.53308052060606,
          "kind": "corridor"
        },
        "G_COR_55": {
          "id": "G_COR_55",
          "x": 733.3535798431765,
          "y": 579.2238789921845,
          "kind": "corridor"
        },
        "G_COR_56": {
          "id": "G_COR_56",
          "x": 697.3954654415036,
          "y": 607.8047605094481,
          "kind": "corridor"
        },
        "G_COR_57": {
          "id": "G_COR_57",
          "x": 661.3497020403267,
          "y": 633.1055586608696,
          "kind": "corridor"
        },
        "G_COR_58": {
          "id": "G_COR_58",
          "x": 621.2040293745998,
          "y": 657.935419359449,
          "kind": "corridor"
        },
        "G_COR_59": {
          "id": "G_COR_59",
          "x": 581.071082967146,
          "y": 680.4388679007358,
          "kind": "corridor"
        },
        "G_COR_60": {
          "id": "G_COR_60",
          "x": 522.0383373128732,
          "y": 717.2116172092894,
          "kind": "corridor"
        },
        "G_COR_61": {
          "id": "G_COR_61",
          "x": 549.0254929429682,
          "y": 701.5128166383461,
          "kind": "corridor"
        },
        "G_COR_62": {
          "id": "G_COR_62",
          "x": 491.33583108059423,
          "y": 741.0107422590739,
          "kind": "corridor"
        },
        "G_COR_63": {
          "id": "G_COR_63",
          "x": 474.9459867439409,
          "y": 753.0981181126375,
          "kind": "corridor"
        },
        "G_COR_64": {
          "id": "G_COR_64",
          "x": 459.7558841671037,
          "y": 723.7087225543623,
          "kind": "corridor"
        },
        "G_COR_65": {
          "id": "G_COR_65",
          "x": 474.71441918752396,
          "y": 713.9480039974479,
          "kind": "corridor"
        },
        "G_COR_66": {
          "id": "G_COR_66",
          "x": 447.6661209147093,
          "y": 719.3954248255758,
          "kind": "corridor"
        },
        "G_COR_67": {
          "id": "G_COR_67",
          "x": 424.9455364980009,
          "y": 733.8429369531717,
          "kind": "corridor"
        },
        "G_COR_68": {
          "id": "G_COR_68",
          "x": 387.89303031358236,
          "y": 712.9872829294125,
          "kind": "corridor"
        },
        "G_COR_69": {
          "id": "G_COR_69",
          "x": 345.1719511040528,
          "y": 685.5040291701018,
          "kind": "corridor"
        },
        "G_COR_70": {
          "id": "G_COR_70",
          "x": 387.5030711857637,
          "y": 658.2674489826446,
          "kind": "corridor"
        },
        "G_COR_71": {
          "id": "G_COR_71",
          "x": 307.36877134027105,
          "y": 605.4586654671932,
          "kind": "corridor"
        },
        "G_COR_72": {
          "id": "G_COR_72",
          "x": 379.8390801632785,
          "y": 555.0263270578498,
          "kind": "corridor"
        },
        "G_COR_73": {
          "id": "G_COR_73",
          "x": 252.7382823541967,
          "y": 428.20828165503013,
          "kind": "corridor"
        },
        "G_COR_74": {
          "id": "G_COR_74",
          "x": 213.0942596595459,
          "y": 265.6862537082931,
          "kind": "corridor"
        },
        "G_COR_75": {
          "id": "G_COR_75",
          "x": 259.06629721870075,
          "y": 294.0503258387563,
          "kind": "corridor"
        },
        "G_COR_76": {
          "id": "G_COR_76",
          "x": 346.3056862309325,
          "y": 234.30197995539686,
          "kind": "corridor"
        },
        "G_COR_77": {
          "id": "G_COR_77",
          "x": 462.54874562732834,
          "y": 237.91015576574353,
          "kind": "corridor"
        },
        "G_COR_78": {
          "id": "G_COR_78",
          "x": 440.77568826408395,
          "y": 223.89056208800284,
          "kind": "corridor"
        },
        "G_COR_79": {
          "id": "G_COR_79",
          "x": 420.38695679114386,
          "y": 235.93327538114343,
          "kind": "corridor"
        },
        "G_COR_80": {
          "id": "G_COR_80",
          "x": 396.22921603489726,
          "y": 217.92248941391853,
          "kind": "corridor"
        },
        "G_COR_81": {
          "id": "G_COR_81",
          "x": 367.3776912736359,
          "y": 198.26437585854117,
          "kind": "corridor"
        },
        "G_COR_82": {
          "id": "G_COR_82",
          "x": 334.55905833240274,
          "y": 201.81704632988104,
          "kind": "corridor"
        },
        "G_COR_83": {
          "id": "G_COR_83",
          "x": 346.50951506157423,
          "y": 419.84977891348905,
          "kind": "corridor"
        },
        "G_COR_84": {
          "id": "G_COR_84",
          "x": 371.5126295533906,
          "y": 438.3029662485978,
          "kind": "corridor"
        },
        "G_COR_86": {
          "id": "G_COR_86",
          "x": 630.5207853621073,
          "y": 641.3443523258103,
          "kind": "corridor"
        }
      },
      "edges": [
        {
          "from": "G_COR_3",
          "to": "G_COR_5",
          "distance": 39.967617457388236
        },
        {
          "from": "G_COR_5",
          "to": "G_COR_2",
          "distance": 43.764974543257864
        },
        {
          "from": "G_COR_6",
          "to": "G_COR_1",
          "distance": 45.74150051278283
        },
        {
          "from": "G_COR_4",
          "to": "G_COR_3",
          "distance": 46.80524395658886
        },
        {
          "from": "G_COR_8",
          "to": "G_COR_9",
          "distance": 93.09446233529778
        },
        {
          "from": "G_COR_9",
          "to": "G_COR_10",
          "distance": 72.24697316627656
        },
        {
          "from": "G_COR_9",
          "to": "G_COR_11",
          "distance": 44.33868144034015
        },
        {
          "from": "G_COR_1",
          "to": "G_COR_12",
          "distance": 95.95703440824164
        },
        {
          "from": "G_COR_1",
          "to": "G_COR_13",
          "distance": 44.86119745882738
        },
        {
          "from": "G_COR_14",
          "to": "G_COR_15",
          "distance": 103.19131077352779
        },
        {
          "from": "G_COR_15",
          "to": "G_COR_4",
          "distance": 102.97806436617087
        },
        {
          "from": "G_COR_15",
          "to": "G_COR_16",
          "distance": 74.75129404307542
        },
        {
          "from": "G_ENT_1",
          "to": "G_COR_17",
          "distance": 41.54449792816975
        },
        {
          "from": "G_COR_17",
          "to": "G_COR_19",
          "distance": 80.18480302188995
        },
        {
          "from": "G_COR_19",
          "to": "G_COR_20",
          "distance": 42.126228907646784
        },
        {
          "from": "G_COR_20",
          "to": "G_COR_21",
          "distance": 44.92296562085482
        },
        {
          "from": "G_COR_23",
          "to": "G_COR_25",
          "distance": 32.369545837149126
        },
        {
          "from": "G_COR_28",
          "to": "G_COR_29",
          "distance": 65.09331816184047
        },
        {
          "from": "G_COR_16",
          "to": "G_COR_30",
          "distance": 77.19561068612767
        },
        {
          "from": "G_COR_6",
          "to": "G_COR_31",
          "distance": 81.04907780444873
        },
        {
          "from": "G_COR_31",
          "to": "G_COR_32",
          "distance": 39.94660391888117
        },
        {
          "from": "G_COR_31",
          "to": "G_COR_33",
          "distance": 46.182915439355305
        },
        {
          "from": "G_COR_33",
          "to": "G_COR_34",
          "distance": 34.85473749388568
        },
        {
          "from": "G_COR_34",
          "to": "G_COR_35",
          "distance": 27.74117455046599
        },
        {
          "from": "G_COR_35",
          "to": "G_COR_36",
          "distance": 21.81469394759934
        },
        {
          "from": "G_COR_36",
          "to": "G_COR_37",
          "distance": 66.93508633509327
        },
        {
          "from": "G_COR_35",
          "to": "G_COR_38",
          "distance": 49.70692383045612
        },
        {
          "from": "G_COR_38",
          "to": "G_COR_39",
          "distance": 64.90888026355923
        },
        {
          "from": "G_COR_39",
          "to": "G_COR_40",
          "distance": 52.58631419534263
        },
        {
          "from": "G_COR_40",
          "to": "G_COR_41",
          "distance": 41.7743505091253
        },
        {
          "from": "G_COR_41",
          "to": "G_COR_42",
          "distance": 65.98070111599142
        },
        {
          "from": "G_COR_42",
          "to": "G_COR_43",
          "distance": 25.862242804511162
        },
        {
          "from": "G_COR_43",
          "to": "G_COR_44",
          "distance": 28.151423750554738
        },
        {
          "from": "G_COR_44",
          "to": "G_COR_45",
          "distance": 41.76316345681405
        },
        {
          "from": "G_COR_41",
          "to": "G_COR_46",
          "distance": 16.924261083560005
        },
        {
          "from": "G_COR_46",
          "to": "G_COR_47",
          "distance": 48.634648953641424
        },
        {
          "from": "G_COR_47",
          "to": "G_COR_48",
          "distance": 43.232153158117406
        },
        {
          "from": "G_COR_48",
          "to": "G_COR_49",
          "distance": 68.28763475395223
        },
        {
          "from": "G_COR_49",
          "to": "G_COR_50",
          "distance": 25.576424099512465
        },
        {
          "from": "G_COR_50",
          "to": "G_COR_51",
          "distance": 19.678302164031017
        },
        {
          "from": "G_COR_51",
          "to": "G_COR_52",
          "distance": 90.61488162259893
        },
        {
          "from": "G_COR_25",
          "to": "G_COR_24",
          "distance": 46.55282015478798
        },
        {
          "from": "G_COR_24",
          "to": "G_COR_26",
          "distance": 50.97665137868884
        },
        {
          "from": "G_COR_25",
          "to": "D_GW112",
          "distance": 31.12292350311213
        },
        {
          "from": "G_COR_19",
          "to": "D_GW103",
          "distance": 28.837003570988156
        },
        {
          "from": "G_COR_20",
          "to": "D_GW104",
          "distance": 22.725723285572435
        },
        {
          "from": "G_COR_20",
          "to": "D_GW105",
          "distance": 23.021837957070336
        },
        {
          "from": "G_COR_24",
          "to": "D_GW113",
          "distance": 27.06776222730934
        },
        {
          "from": "G_COR_28",
          "to": "G_COR_53",
          "distance": 31.312088124364898
        },
        {
          "from": "G_COR_53",
          "to": "G_COR_27",
          "distance": 17.198472947497677
        },
        {
          "from": "G_COR_27",
          "to": "G_COR_26",
          "distance": 26.781942167285628
        },
        {
          "from": "G_COR_53",
          "to": "G_COR_54",
          "distance": 26.17013665912393
        },
        {
          "from": "G_COR_29",
          "to": "G_COR_55",
          "distance": 47.799279813132024
        },
        {
          "from": "G_COR_55",
          "to": "G_COR_56",
          "distance": 45.93313378845011
        },
        {
          "from": "G_COR_56",
          "to": "G_COR_57",
          "distance": 44.03893103008512
        },
        {
          "from": "G_COR_57",
          "to": "G_COR_58",
          "distance": 47.203781798649906
        },
        {
          "from": "G_COR_58",
          "to": "G_COR_59",
          "distance": 46.01150490468551
        },
        {
          "from": "G_COR_59",
          "to": "G_COR_61",
          "distance": 38.35402397914869
        },
        {
          "from": "G_COR_61",
          "to": "G_COR_60",
          "distance": 31.22112919753577
        },
        {
          "from": "G_COR_60",
          "to": "G_COR_62",
          "distance": 38.84639290948913
        },
        {
          "from": "G_COR_62",
          "to": "G_COR_63",
          "distance": 20.364961389726187
        },
        {
          "from": "G_COR_63",
          "to": "G_COR_44",
          "distance": 12.100910662522084
        },
        {
          "from": "G_COR_62",
          "to": "G_COR_64",
          "distance": 36.0090673708874
        },
        {
          "from": "G_COR_64",
          "to": "G_COR_65",
          "distance": 17.86139403026629
        },
        {
          "from": "G_COR_64",
          "to": "G_COR_66",
          "distance": 12.836156465083347
        },
        {
          "from": "G_COR_66",
          "to": "G_COR_67",
          "distance": 26.924998847053015
        },
        {
          "from": "G_COR_67",
          "to": "G_COR_68",
          "distance": 42.518778431478
        },
        {
          "from": "G_COR_69",
          "to": "G_COR_68",
          "distance": 50.79783308395702
        },
        {
          "from": "G_COR_69",
          "to": "G_COR_70",
          "distance": 50.336418502710465
        },
        {
          "from": "G_COR_70",
          "to": "G_COR_71",
          "distance": 95.97017051203532
        },
        {
          "from": "G_COR_32",
          "to": "G_COR_71",
          "distance": 57.501212011536104
        },
        {
          "from": "G_COR_65",
          "to": "G_COR_70",
          "distance": 103.47049544213398
        },
        {
          "from": "G_COR_52",
          "to": "G_COR_37",
          "distance": 67.20312617095604
        },
        {
          "from": "G_ENT_4",
          "to": "G_COR_60",
          "distance": 83.18506070666231
        },
        {
          "from": "G_COR_71",
          "to": "G_COR_72",
          "distance": 88.29137227575865
        },
        {
          "from": "G_COR_8",
          "to": "G_COR_73",
          "distance": 65.59825471675825
        },
        {
          "from": "G_COR_73",
          "to": "G_COR_3",
          "distance": 30.216352927980925
        },
        {
          "from": "G_COR_11",
          "to": "G_COR_7",
          "distance": 49.579192703983885
        },
        {
          "from": "G_COR_15",
          "to": "G_COR_74",
          "distance": 25.63077084385646
        },
        {
          "from": "G_COR_74",
          "to": "G_COR_75",
          "distance": 54.01804166352628
        },
        {
          "from": "G_COR_75",
          "to": "G_COR_76",
          "distance": 105.73824204622024
        },
        {
          "from": "G_COR_17",
          "to": "G_COR_18",
          "distance": 22.030049252256692
        },
        {
          "from": "G_COR_18",
          "to": "G_COR_10",
          "distance": 65.7394720216618
        },
        {
          "from": "G_COR_18",
          "to": "G_COR_77",
          "distance": 45.25505004193694
        },
        {
          "from": "G_COR_77",
          "to": "G_COR_78",
          "distance": 25.896235900842374
        },
        {
          "from": "G_COR_78",
          "to": "G_COR_79",
          "distance": 23.679681470333236
        },
        {
          "from": "G_COR_79",
          "to": "G_COR_80",
          "distance": 30.132786953801723
        },
        {
          "from": "G_COR_80",
          "to": "G_COR_81",
          "distance": 34.912059658602054
        },
        {
          "from": "G_COR_81",
          "to": "G_COR_82",
          "distance": 33.01036406356833
        },
        {
          "from": "G_COR_82",
          "to": "G_COR_76",
          "distance": 34.5435113970871
        },
        {
          "from": "G_COR_21",
          "to": "G_COR_22",
          "distance": 41.167386084669076
        },
        {
          "from": "G_COR_22",
          "to": "G_COR_23",
          "distance": 23.241661266673983
        },
        {
          "from": "G_COR_22",
          "to": "D_GW106",
          "distance": 29.84237205945074
        },
        {
          "from": "G_COR_21",
          "to": "D_GW108",
          "distance": 32.20261916843361
        },
        {
          "from": "G_COR_29",
          "to": "D_GE113",
          "distance": 24.30677447954351
        },
        {
          "from": "G_COR_45",
          "to": "D_GE520",
          "distance": 22.305023432946978
        },
        {
          "from": "G_COR_21",
          "to": "D_GW109",
          "distance": 28.429887228005224
        },
        {
          "from": "G_COR_56",
          "to": "D_GE109",
          "distance": 23.457833737557625
        },
        {
          "from": "G_COR_23",
          "to": "D_GW_LIB_F",
          "distance": 41.034130123201614
        },
        {
          "from": "G_COR_8",
          "to": "G_COR_83",
          "distance": 46.54723232010662
        },
        {
          "from": "G_COR_83",
          "to": "G_COR_84",
          "distance": 31.075325535149172
        },
        {
          "from": "G_COR_12",
          "to": "G_ENT_3",
          "distance": 14.499252916478802
        },
        {
          "from": "G_COR_19",
          "to": "D_GE103",
          "distance": 0
        },
        {
          "from": "G_COR_58",
          "to": "D_GE104",
          "distance": 29.669445192825588
        },
        {
          "from": "G_COR_57",
          "to": "D_GE106",
          "distance": 24.634222441841647
        },
        {
          "from": "G_COR_57",
          "to": "D_GE107",
          "distance": 32.87202719549528
        },
        {
          "from": "G_COR_86",
          "to": "G_COR_57",
          "distance": 31.91081046614241
        },
        {
          "from": "G_COR_86",
          "to": "D_GE105",
          "distance": 23.264165838061714
        },
        {
          "from": "G_COR_55",
          "to": "D_GE112",
          "distance": 21.625217106626003
        },
        {
          "from": "G_COR_28",
          "to": "D_GE114",
          "distance": 20.776574237499403
        },
        {
          "from": "G_COR_26",
          "to": "D_GW114",
          "distance": 27.52195460014478
        }
      ],
      "rooms": {
        "GE107": {
          "id": "GE107",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE107"
        },
        "GE109": {
          "id": "GE109",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE109"
        },
        "GE111": {
          "id": "GE111",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE113": {
          "id": "GE113",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE113"
        },
        "GE114": {
          "id": "GE114",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE114"
        },
        "GE118": {
          "id": "GE118",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE119": {
          "id": "GE119",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE127": {
          "id": "GE127",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE129": {
          "id": "GE129",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE130": {
          "id": "GE130",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE133": {
          "id": "GE133",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE135": {
          "id": "GE135",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE136": {
          "id": "GE136",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE201": {
          "id": "GE201",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE203": {
          "id": "GE203",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE204": {
          "id": "GE204",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE205": {
          "id": "GE205",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE206": {
          "id": "GE206",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE208": {
          "id": "GE208",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE211": {
          "id": "GE211",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE212": {
          "id": "GE212",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE214": {
          "id": "GE214",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE216": {
          "id": "GE216",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE301": {
          "id": "GE301",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE303": {
          "id": "GE303",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE304": {
          "id": "GE304",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE305": {
          "id": "GE305",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE306": {
          "id": "GE306",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE308": {
          "id": "GE308",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE311": {
          "id": "GE311",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE312": {
          "id": "GE312",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE314": {
          "id": "GE314",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE315": {
          "id": "GE315",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE316": {
          "id": "GE316",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE318": {
          "id": "GE318",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE322": {
          "id": "GE322",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE401": {
          "id": "GE401",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE403": {
          "id": "GE403",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE404": {
          "id": "GE404",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE405": {
          "id": "GE405",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE406": {
          "id": "GE406",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE408": {
          "id": "GE408",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE411": {
          "id": "GE411",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE412": {
          "id": "GE412",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE414": {
          "id": "GE414",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE416": {
          "id": "GE416",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE418": {
          "id": "GE418",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE420": {
          "id": "GE420",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE501": {
          "id": "GE501",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE503": {
          "id": "GE503",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE504": {
          "id": "GE504",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE505": {
          "id": "GE505",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE506": {
          "id": "GE506",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE508": {
          "id": "GE508",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE511": {
          "id": "GE511",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE512": {
          "id": "GE512",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE514": {
          "id": "GE514",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE516": {
          "id": "GE516",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE518": {
          "id": "GE518",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE520": {
          "id": "GE520",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE520"
        },
        "GE601": {
          "id": "GE601",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE603": {
          "id": "GE603",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE604": {
          "id": "GE604",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE605": {
          "id": "GE605",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE606": {
          "id": "GE606",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE608": {
          "id": "GE608",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE611": {
          "id": "GE611",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE612": {
          "id": "GE612",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE614": {
          "id": "GE614",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE616": {
          "id": "GE616",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE618": {
          "id": "GE618",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE620": {
          "id": "GE620",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GW106": {
          "id": "GW106",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW106"
        },
        "GW108": {
          "id": "GW108",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW108"
        },
        "GW110": {
          "id": "GW110",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW112": {
          "id": "GW112",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW112"
        },
        "GW115": {
          "id": "GW115",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW116": {
          "id": "GW116",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW117": {
          "id": "GW117",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW120": {
          "id": "GW120",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW128": {
          "id": "GW128",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW131": {
          "id": "GW131",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW132": {
          "id": "GW132",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW134": {
          "id": "GW134",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW202": {
          "id": "GW202",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW207": {
          "id": "GW207",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW209": {
          "id": "GW209",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW210": {
          "id": "GW210",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW213": {
          "id": "GW213",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW215": {
          "id": "GW215",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW217": {
          "id": "GW217",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW218": {
          "id": "GW218",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW219": {
          "id": "GW219",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW302": {
          "id": "GW302",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW307": {
          "id": "GW307",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW309": {
          "id": "GW309",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW310": {
          "id": "GW310",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW313": {
          "id": "GW313",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW317": {
          "id": "GW317",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW319": {
          "id": "GW319",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW320": {
          "id": "GW320",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW321": {
          "id": "GW321",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW402": {
          "id": "GW402",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW407": {
          "id": "GW407",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW409": {
          "id": "GW409",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW410": {
          "id": "GW410",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW413": {
          "id": "GW413",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW415": {
          "id": "GW415",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW417": {
          "id": "GW417",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW419": {
          "id": "GW419",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW502": {
          "id": "GW502",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW507": {
          "id": "GW507",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW509": {
          "id": "GW509",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW510": {
          "id": "GW510",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW513": {
          "id": "GW513",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW515": {
          "id": "GW515",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW517": {
          "id": "GW517",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW519": {
          "id": "GW519",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW602": {
          "id": "GW602",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW607": {
          "id": "GW607",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW609": {
          "id": "GW609",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW610": {
          "id": "GW610",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW613": {
          "id": "GW613",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW615": {
          "id": "GW615",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW617": {
          "id": "GW617",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW619": {
          "id": "GW619",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW103": {
          "id": "GW103",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW103"
        },
        "GW104": {
          "id": "GW104",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW104"
        },
        "GW105": {
          "id": "GW105",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW105"
        },
        "GW113": {
          "id": "GW113",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW113"
        },
        "GW109": {
          "id": "GW109",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW109"
        },
        "GW_LIB_F": {
          "id": "GW_LIB_F",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW_LIB_F"
        },
        "GE_LIB_M": {
          "id": "GE_LIB_M",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GW_CAFE_F1": {
          "id": "GW_CAFE_F1",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GW_CAFE_F2": {
          "id": "GW_CAFE_F2",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "GE_CAFE_M1": {
          "id": "GE_CAFE_M1",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE_CAFE_M2": {
          "id": "GE_CAFE_M2",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "GE103": {
          "id": "GE103",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE103"
        },
        "GE104": {
          "id": "GE104",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE104"
        },
        "GE106": {
          "id": "GE106",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE106"
        },
        "GE112": {
          "id": "GE112",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE112"
        },
        "GW114": {
          "id": "GW114",
          "floor": "G",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_GW114"
        },
        "GE105": {
          "id": "GE105",
          "floor": "G",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_GE105"
        }
      },
      "doors": {
        "D_GW112": {
          "id": "D_GW112",
          "roomId": "GW112",
          "corridorNodeId": "G_COR_25",
          "point": {
            "x": 757.8286975816593,
            "y": 402.7346067645693
          }
        },
        "D_GW103": {
          "id": "D_GW103",
          "roomId": "GW103",
          "corridorNodeId": "G_COR_19",
          "point": {
            "x": 607.1746949216316,
            "y": 301.81085264342954
          }
        },
        "D_GW104": {
          "id": "D_GW104",
          "roomId": "GW104",
          "corridorNodeId": "G_COR_20",
          "point": {
            "x": 636.5036833316648,
            "y": 330.8821451674321
          }
        },
        "D_GW105": {
          "id": "D_GW105",
          "roomId": "GW105",
          "corridorNodeId": "G_COR_20",
          "point": {
            "x": 598.9450551793059,
            "y": 356.81346550777084
          }
        },
        "D_GW113": {
          "id": "D_GW113",
          "roomId": "GW113",
          "corridorNodeId": "G_COR_24",
          "point": {
            "x": 794.4014491615634,
            "y": 429.0934432250953
          }
        },
        "D_GW106": {
          "id": "D_GW106",
          "roomId": "GW106",
          "corridorNodeId": "G_COR_22",
          "point": {
            "x": 714.7991054816559,
            "y": 373.7282339766432
          }
        },
        "D_GW108": {
          "id": "D_GW108",
          "roomId": "GW108",
          "corridorNodeId": "G_COR_21",
          "point": {
            "x": 630.0445303642739,
            "y": 390.4218323491243
          }
        },
        "D_GE114": {
          "id": "D_GE114",
          "roomId": "GE114",
          "corridorNodeId": "G_COR_28",
          "point": {
            "x": 843.5956940547991,
            "y": 533.8414603670544
          }
        },
        "D_GE113": {
          "id": "D_GE113",
          "roomId": "GE113",
          "corridorNodeId": "G_COR_29",
          "point": {
            "x": 794.247305113687,
            "y": 566.181092914209
          }
        },
        "D_GE520": {
          "id": "D_GE520",
          "roomId": "GE520",
          "corridorNodeId": "G_COR_45",
          "point": {
            "x": 500.23353313018436,
            "y": 803.585499847687
          }
        },
        "D_GW109": {
          "id": "D_GW109",
          "roomId": "GW109",
          "corridorNodeId": "G_COR_21",
          "point": {
            "x": 678.9625088000766,
            "y": 354.63318526214965
          }
        },
        "D_GE109": {
          "id": "D_GE109",
          "roomId": "GE109",
          "corridorNodeId": "G_COR_56",
          "point": {
            "x": 715.1094920964363,
            "y": 623.1827715423233
          }
        },
        "D_GW_LIB_F": {
          "id": "D_GW_LIB_F",
          "roomId": "GW_LIB_F",
          "corridorNodeId": "G_COR_23",
          "point": {
            "x": 677.2773442114549,
            "y": 429.55428647295315
          }
        },
        "D_GE103": {
          "id": "D_GE103",
          "roomId": "GE103",
          "corridorNodeId": "G_COR_19",
          "point": {
            "x": 584.8322909037714,
            "y": 320.04241202972145
          }
        },
        "D_GE104": {
          "id": "D_GE104",
          "roomId": "GE104",
          "corridorNodeId": "G_COR_58",
          "point": {
            "x": 645.932757839542,
            "y": 674.3295026384019
          }
        },
        "D_GE106": {
          "id": "D_GE106",
          "roomId": "GE106",
          "corridorNodeId": "G_COR_57",
          "point": {
            "x": 679.8372986054352,
            "y": 649.3860282044647
          }
        },
        "D_GE112": {
          "id": "D_GE112",
          "roomId": "GE112",
          "corridorNodeId": "G_COR_55",
          "point": {
            "x": 750.8035753245573,
            "y": 591.9968063233995
          }
        },
        "D_GW114": {
          "id": "D_GW114",
          "roomId": "GW114",
          "corridorNodeId": "G_COR_26",
          "point": {
            "x": 843.2431027684559,
            "y": 464.602034131641
          }
        },
        "D_GE105": {
          "id": "D_GE105",
          "roomId": "GE105",
          "corridorNodeId": "G_COR_86",
          "point": {
            "x": 608.7141161754508,
            "y": 633.2393790917665
          }
        },
        "D_GE107": {
          "id": "D_GE107",
          "roomId": "GE107",
          "corridorNodeId": "G_COR_57",
          "point": {
            "x": 633.8418967755189,
            "y": 615.1085916537656
          }
        }
      }
    },
    "F": {
      "nodes": {
        "Elevator and Stairs W": {
          "id": "Elevator and Stairs W",
          "x": 513.3425101066491,
          "y": 316.0296866714995,
          "kind": "stairs"
        },
        "Elevator and Stairs M": {
          "id": "Elevator and Stairs M",
          "x": 518.3812619906788,
          "y": 677.9913472076332,
          "kind": "stairs"
        },
        "F_COR_1": {
          "id": "F_COR_1",
          "x": 533.68234675792,
          "y": 296.9617994066821,
          "kind": "corridor"
        },
        "F_COR_2": {
          "id": "F_COR_2",
          "x": 568.9154082598059,
          "y": 321.481422844812,
          "kind": "corridor"
        },
        "F_COR_3": {
          "id": "F_COR_3",
          "x": 604.667461289074,
          "y": 340.71662059252526,
          "kind": "corridor"
        },
        "F_COR_4": {
          "id": "F_COR_4",
          "x": 623.150525667593,
          "y": 354.6296641840811,
          "kind": "corridor"
        },
        "F_COR_5": {
          "id": "F_COR_5",
          "x": 657.9164992524813,
          "y": 376.03866667504667,
          "kind": "corridor"
        },
        "F_COR_6": {
          "id": "F_COR_6",
          "x": 699.292224037408,
          "y": 402.5598736178189,
          "kind": "corridor"
        },
        "F_COR_7": {
          "id": "F_COR_7",
          "x": 715.9807870794912,
          "y": 411.12496145517565,
          "kind": "corridor"
        },
        "F_COR_8": {
          "id": "F_COR_8",
          "x": 766.2013538254544,
          "y": 445.12165788294595,
          "kind": "corridor"
        },
        "F_COR_9": {
          "id": "F_COR_9",
          "x": 788.9546640346897,
          "y": 461.82897351214723,
          "kind": "corridor"
        },
        "F_COR_10": {
          "id": "F_COR_10",
          "x": 809.7506247827043,
          "y": 475.9980631917589,
          "kind": "corridor"
        },
        "F_STAIR_2": {
          "id": "F_STAIR_2",
          "x": 858.7115261741694,
          "y": 519.3170258106643,
          "kind": "stairs"
        },
        "F_COR_11": {
          "id": "F_COR_11",
          "x": 842.7328004635543,
          "y": 496.82605829188816,
          "kind": "corridor"
        },
        "F_COR_12": {
          "id": "F_COR_12",
          "x": 831.9751801549611,
          "y": 505.9409801422733,
          "kind": "corridor"
        },
        "F_STAIR_1": {
          "id": "F_STAIR_1",
          "x": 854.6246405338825,
          "y": 475.4577622728071,
          "kind": "stairs"
        },
        "F_COR_13": {
          "id": "F_COR_13",
          "x": 808.2399010384561,
          "y": 522.4937245070113,
          "kind": "corridor"
        },
        "F_COR_14": {
          "id": "F_COR_14",
          "x": 793.1534673077292,
          "y": 534.8507606593394,
          "kind": "corridor"
        },
        "F_COR_15": {
          "id": "F_COR_15",
          "x": 769.279567416739,
          "y": 552.2303224879539,
          "kind": "corridor"
        },
        "F_COR_16": {
          "id": "F_COR_16",
          "x": 716.5331451202007,
          "y": 586.2750312526874,
          "kind": "corridor"
        },
        "F_COR_17": {
          "id": "F_COR_17",
          "x": 665.1389869365076,
          "y": 620.9781275636402,
          "kind": "corridor"
        },
        "F_COR_18": {
          "id": "F_COR_18",
          "x": 622.0523993012005,
          "y": 643.6745896172683,
          "kind": "corridor"
        },
        "F_COR_19": {
          "id": "F_COR_19",
          "x": 608.4490664255677,
          "y": 654.4729226269039,
          "kind": "corridor"
        },
        "F_COR_20": {
          "id": "F_COR_20",
          "x": 572.6418552054567,
          "y": 675.5968261225355,
          "kind": "corridor"
        },
        "F_COR_21": {
          "id": "F_COR_21",
          "x": 540.8679012965863,
          "y": 695.8855564654426,
          "kind": "corridor"
        },
        "F_COR_22": {
          "id": "F_COR_22",
          "x": 527.9311680824107,
          "y": 686.6422031475053,
          "kind": "corridor"
        },
        "F_COR_24": {
          "id": "F_COR_24",
          "x": 504.46149590610077,
          "y": 671.5739901888289,
          "kind": "corridor"
        },
        "F_COR_25": {
          "id": "F_COR_25",
          "x": 452.4757632292732,
          "y": 704.6393794698868,
          "kind": "corridor"
        },
        "F_COR_23": {
          "id": "F_COR_23",
          "x": 828.5459896409392,
          "y": 485.479685710278,
          "kind": "corridor"
        },
        "F_COR_27": {
          "id": "F_COR_27",
          "x": 775.0086095107313,
          "y": 473.5981819569962,
          "kind": "corridor"
        },
        "F_COR_26": {
          "id": "F_COR_26",
          "x": 742.8593928335703,
          "y": 491.17907104043366,
          "kind": "corridor"
        },
        "F_COR_28": {
          "id": "F_COR_28",
          "x": 716.6433038876846,
          "y": 495.2997963405029,
          "kind": "corridor"
        },
        "F_COR_29": {
          "id": "F_COR_29",
          "x": 693.4491516484015,
          "y": 510.6638638997755,
          "kind": "corridor"
        },
        "F_COR_31": {
          "id": "F_COR_31",
          "x": 772.9756755410406,
          "y": 514.0991232396977,
          "kind": "corridor"
        },
        "F_COR_32": {
          "id": "F_COR_32",
          "x": 410.1076992539566,
          "y": 733.3612564774817,
          "kind": "corridor"
        },
        "F_COR_33": {
          "id": "F_COR_33",
          "x": 783.1266204169368,
          "y": 521.1256733327003,
          "kind": "corridor"
        },
        "F_COR_34": {
          "id": "F_COR_34",
          "x": 759.5637584592819,
          "y": 539.4188671334882,
          "kind": "corridor"
        },
        "F_COR_36": {
          "id": "F_COR_36",
          "x": 734.7017407703925,
          "y": 553.8151304876008,
          "kind": "corridor"
        },
        "F_COR_30": {
          "id": "F_COR_30",
          "x": 373.35703731732883,
          "y": 709.387844445335,
          "kind": "corridor"
        }
      },
      "edges": [
        {
          "from": "F_COR_1",
          "to": "F_COR_2",
          "distance": 42.925290404880975
        },
        {
          "from": "F_COR_2",
          "to": "F_COR_3",
          "distance": 40.598055719470544
        },
        {
          "from": "F_COR_3",
          "to": "F_COR_4",
          "distance": 23.134313277056872
        },
        {
          "from": "F_COR_4",
          "to": "F_COR_5",
          "distance": 40.82913551574811
        },
        {
          "from": "F_COR_5",
          "to": "F_COR_6",
          "distance": 49.14595628512424
        },
        {
          "from": "F_COR_6",
          "to": "F_COR_7",
          "distance": 18.758167982807404
        },
        {
          "from": "F_COR_7",
          "to": "F_COR_8",
          "distance": 60.64553316022306
        },
        {
          "from": "F_COR_8",
          "to": "F_COR_9",
          "distance": 28.228487756368498
        },
        {
          "from": "F_COR_9",
          "to": "F_COR_10",
          "distance": 25.16416272761411
        },
        {
          "from": "F_COR_10",
          "to": "F_COR_11",
          "distance": 39.00806701867527
        },
        {
          "from": "F_COR_11",
          "to": "F_COR_12",
          "distance": 14.099935994269126
        },
        {
          "from": "F_COR_12",
          "to": "F_COR_13",
          "distance": 28.93711839044731
        },
        {
          "from": "F_COR_13",
          "to": "F_COR_14",
          "distance": 19.501200608720392
        },
        {
          "from": "F_COR_14",
          "to": "F_COR_15",
          "distance": 29.529853798480897
        },
        {
          "from": "F_COR_15",
          "to": "F_COR_16",
          "distance": 62.77919448320658
        },
        {
          "from": "F_COR_16",
          "to": "F_COR_17",
          "distance": 62.01342103914065
        },
        {
          "from": "F_COR_17",
          "to": "F_COR_18",
          "distance": 48.69890577627784
        },
        {
          "from": "F_COR_18",
          "to": "F_COR_19",
          "distance": 17.368208344911597
        },
        {
          "from": "F_COR_19",
          "to": "F_COR_20",
          "distance": 41.573737795084
        },
        {
          "from": "F_COR_20",
          "to": "F_COR_21",
          "distance": 37.699028182835484
        },
        {
          "from": "F_COR_21",
          "to": "F_COR_22",
          "distance": 15.899642977594699
        },
        {
          "from": "F_COR_22",
          "to": "Elevator and Stairs M",
          "distance": 12.885573904693498
        },
        {
          "from": "Elevator and Stairs M",
          "to": "F_COR_24",
          "distance": 15.327829557904339
        },
        {
          "from": "F_COR_24",
          "to": "F_COR_25",
          "distance": 61.610359277109175
        },
        {
          "from": "F_COR_10",
          "to": "F_COR_23",
          "distance": 21.05152977191581
        },
        {
          "from": "F_COR_23",
          "to": "F_COR_11",
          "distance": 18.16606099509152
        },
        {
          "from": "F_COR_27",
          "to": "F_COR_9",
          "distance": 18.24847128401515
        },
        {
          "from": "F_COR_27",
          "to": "F_COR_26",
          "distance": 36.642322441668156
        },
        {
          "from": "F_COR_26",
          "to": "F_COR_28",
          "distance": 26.537967077702433
        },
        {
          "from": "F_COR_28",
          "to": "F_COR_29",
          "distance": 27.821273695949532
        },
        {
          "from": "F_COR_26",
          "to": "F_COR_31",
          "distance": 37.84599419929757
        },
        {
          "from": "F_COR_31",
          "to": "F_COR_14",
          "distance": 28.944321311375013
        },
        {
          "from": "F_COR_31",
          "to": "F_COR_33",
          "distance": 12.345610073340191
        },
        {
          "from": "F_COR_33",
          "to": "F_COR_14",
          "distance": 16.997519839531307
        },
        {
          "from": "F_COR_33",
          "to": "F_COR_34",
          "distance": 29.83034366326823
        },
        {
          "from": "F_COR_34",
          "to": "F_COR_36",
          "distance": 28.729293797857498
        },
        {
          "from": "F_COR_32",
          "to": "F_COR_25",
          "distance": 51.18592642373419
        },
        {
          "from": "F_COR_32",
          "to": "F_COR_30",
          "distance": 43.87864671162246
        },
        {
          "from": "Elevator and Stairs W",
          "to": "F_COR_1",
          "distance": 27.879979909321456
        },
        {
          "from": "F_STAIR_1",
          "to": "F_COR_23",
          "distance": 27.938056156120467
        },
        {
          "from": "F_STAIR_2",
          "to": "F_COR_12",
          "distance": 29.895665173762538
        },
        {
          "from": "F_COR_2",
          "to": "D_FW102",
          "distance": 27.195993635773984
        },
        {
          "from": "F_COR_4",
          "to": "D_FW104",
          "distance": 32.00951835458217
        },
        {
          "from": "F_COR_8",
          "to": "D_FW112",
          "distance": 26.884057047542512
        },
        {
          "from": "F_COR_27",
          "to": "D_FW202",
          "distance": 53.93398955411978
        },
        {
          "from": "F_COR_10",
          "to": "D_FW114",
          "distance": 34.27618726501244
        },
        {
          "from": "F_COR_29",
          "to": "D_FE205",
          "distance": 39.55351185195461
        },
        {
          "from": "F_COR_16",
          "to": "D_FE111",
          "distance": 28.774268614611362
        },
        {
          "from": "F_COR_19",
          "to": "D_FE103",
          "distance": 16.303307339507406
        },
        {
          "from": "F_COR_13",
          "to": "D_FE114",
          "distance": 30.093646183440498
        },
        {
          "from": "F_COR_17",
          "to": "D_FE108",
          "distance": 18.909789308229854
        },
        {
          "from": "F_COR_18",
          "to": "D_FE104",
          "distance": 37.546005030842146
        },
        {
          "from": "F_COR_5",
          "to": "D_FW105",
          "distance": 30.215193106404698
        },
        {
          "from": "F_COR_3",
          "to": "D_FW103",
          "distance": 34.22794959439835
        },
        {
          "from": "F_COR_6",
          "to": "D_FW201",
          "distance": 28.042819841310028
        },
        {
          "from": "F_COR_7",
          "to": "D_FW109",
          "distance": 27.062915831005675
        },
        {
          "from": "F_COR_36",
          "to": "D_FE202",
          "distance": 37.55352879211449
        },
        {
          "from": "F_COR_16",
          "to": "D_FE201",
          "distance": 25.770205600244406
        },
        {
          "from": "F_COR_15",
          "to": "D_FE112",
          "distance": 28.46723078957185
        },
        {
          "from": "F_COR_20",
          "to": "D_FE102",
          "distance": 23.834206982811228
        }
      ],
      "rooms": {
        "FE101": {
          "id": "FE101",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE103": {
          "id": "FE103",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE103"
        },
        "FE105": {
          "id": "FE105",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE107": {
          "id": "FE107",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE109": {
          "id": "FE109",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE111": {
          "id": "FE111",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE111"
        },
        "FE113": {
          "id": "FE113",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE115": {
          "id": "FE115",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE117": {
          "id": "FE117",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE119": {
          "id": "FE119",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE201": {
          "id": "FE201",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE201"
        },
        "FE203": {
          "id": "FE203",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE205": {
          "id": "FE205",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE205"
        },
        "FE207": {
          "id": "FE207",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE209": {
          "id": "FE209",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE211": {
          "id": "FE211",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE213": {
          "id": "FE213",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE215": {
          "id": "FE215",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE217": {
          "id": "FE217",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE219": {
          "id": "FE219",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE301": {
          "id": "FE301",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE303": {
          "id": "FE303",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE305": {
          "id": "FE305",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE307": {
          "id": "FE307",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE309": {
          "id": "FE309",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE311": {
          "id": "FE311",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE313": {
          "id": "FE313",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE315": {
          "id": "FE315",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE317": {
          "id": "FE317",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE319": {
          "id": "FE319",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE401": {
          "id": "FE401",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE403": {
          "id": "FE403",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE405": {
          "id": "FE405",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE407": {
          "id": "FE407",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE409": {
          "id": "FE409",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE411": {
          "id": "FE411",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE413": {
          "id": "FE413",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE415": {
          "id": "FE415",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE417": {
          "id": "FE417",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE419": {
          "id": "FE419",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE501": {
          "id": "FE501",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE503": {
          "id": "FE503",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE505": {
          "id": "FE505",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE507": {
          "id": "FE507",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE509": {
          "id": "FE509",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE511": {
          "id": "FE511",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE513": {
          "id": "FE513",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE515": {
          "id": "FE515",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE517": {
          "id": "FE517",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE519": {
          "id": "FE519",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE601": {
          "id": "FE601",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE603": {
          "id": "FE603",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE605": {
          "id": "FE605",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE607": {
          "id": "FE607",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE609": {
          "id": "FE609",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE611": {
          "id": "FE611",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE613": {
          "id": "FE613",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE615": {
          "id": "FE615",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE617": {
          "id": "FE617",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE619": {
          "id": "FE619",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FW102": {
          "id": "FW102",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW102"
        },
        "FW104": {
          "id": "FW104",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW104"
        },
        "FW106": {
          "id": "FW106",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW108": {
          "id": "FW108",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW110": {
          "id": "FW110",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW112": {
          "id": "FW112",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW112"
        },
        "FW114": {
          "id": "FW114",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW114"
        },
        "FW116": {
          "id": "FW116",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW118": {
          "id": "FW118",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW120": {
          "id": "FW120",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW202": {
          "id": "FW202",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW202"
        },
        "FW204": {
          "id": "FW204",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW206": {
          "id": "FW206",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW208": {
          "id": "FW208",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW210": {
          "id": "FW210",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW212": {
          "id": "FW212",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW214": {
          "id": "FW214",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW216": {
          "id": "FW216",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW218": {
          "id": "FW218",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW220": {
          "id": "FW220",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW302": {
          "id": "FW302",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW304": {
          "id": "FW304",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW306": {
          "id": "FW306",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW308": {
          "id": "FW308",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW310": {
          "id": "FW310",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW312": {
          "id": "FW312",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW314": {
          "id": "FW314",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW316": {
          "id": "FW316",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW318": {
          "id": "FW318",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW320": {
          "id": "FW320",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW402": {
          "id": "FW402",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW404": {
          "id": "FW404",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW406": {
          "id": "FW406",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW408": {
          "id": "FW408",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW410": {
          "id": "FW410",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW412": {
          "id": "FW412",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW414": {
          "id": "FW414",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW416": {
          "id": "FW416",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW418": {
          "id": "FW418",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW420": {
          "id": "FW420",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW502": {
          "id": "FW502",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW504": {
          "id": "FW504",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW506": {
          "id": "FW506",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW508": {
          "id": "FW508",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW510": {
          "id": "FW510",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW512": {
          "id": "FW512",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW514": {
          "id": "FW514",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW516": {
          "id": "FW516",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW518": {
          "id": "FW518",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW520": {
          "id": "FW520",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW602": {
          "id": "FW602",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW604": {
          "id": "FW604",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW606": {
          "id": "FW606",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW608": {
          "id": "FW608",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW610": {
          "id": "FW610",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW612": {
          "id": "FW612",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW614": {
          "id": "FW614",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW616": {
          "id": "FW616",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW618": {
          "id": "FW618",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW620": {
          "id": "FW620",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FW652": {
          "id": "FW652",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          }
        },
        "FE202": {
          "id": "FE202",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE202"
        },
        "FE214": {
          "id": "FE214",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          }
        },
        "FE114": {
          "id": "FE114",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE114"
        },
        "FE108": {
          "id": "FE108",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE108"
        },
        "FE104": {
          "id": "FE104",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE104"
        },
        "FW103": {
          "id": "FW103",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW103"
        },
        "FW105": {
          "id": "FW105",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW105"
        },
        "FW109": {
          "id": "FW109",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW109"
        },
        "FW201": {
          "id": "FW201",
          "floor": "F",
          "wing": "W",
          "labelPoint": {
            "x": 250,
            "y": 650
          },
          "doorId": "D_FW201"
        },
        "FE102": {
          "id": "FE102",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE102"
        },
        "FE112": {
          "id": "FE112",
          "floor": "F",
          "wing": "E",
          "labelPoint": {
            "x": 750,
            "y": 650
          },
          "doorId": "D_FE112"
        }
      },
      "doors": {
        "D_FW102": {
          "id": "D_FW102",
          "roomId": "FW102",
          "corridorNodeId": "F_COR_2",
          "point": {
            "x": 591.2433605559364,
            "y": 305.95452308668973
          }
        },
        "D_FW104": {
          "id": "D_FW104",
          "roomId": "FW104",
          "corridorNodeId": "F_COR_4",
          "point": {
            "x": 594.2011654420271,
            "y": 368.2877682920002
          }
        },
        "D_FW112": {
          "id": "D_FW112",
          "roomId": "FW112",
          "corridorNodeId": "F_COR_8",
          "point": {
            "x": 788.84959818216,
            "y": 430.6368537456967
          }
        },
        "D_FW114": {
          "id": "D_FW114",
          "roomId": "FW114",
          "corridorNodeId": "F_COR_10",
          "point": {
            "x": 838.4605794801971,
            "y": 457.2738672225293
          }
        },
        "D_FE205": {
          "id": "D_FE205",
          "roomId": "FE205",
          "corridorNodeId": "F_COR_29",
          "point": {
            "x": 658.3175995571625,
            "y": 528.8367653600066
          }
        },
        "D_FE111": {
          "id": "D_FE111",
          "roomId": "FE111",
          "corridorNodeId": "F_COR_16",
          "point": {
            "x": 739.4188554049484,
            "y": 603.7164417194015
          }
        },
        "D_FE103": {
          "id": "D_FE103",
          "roomId": "FE103",
          "corridorNodeId": "F_COR_19",
          "point": {
            "x": 622.5683385470991,
            "y": 662.6242406163203
          }
        },
        "D_FE114": {
          "id": "D_FE114",
          "roomId": "FE114",
          "corridorNodeId": "F_COR_13",
          "point": {
            "x": 833.8130617529507,
            "y": 538.356920644131
          }
        },
        "D_FE108": {
          "id": "D_FE108",
          "roomId": "FE108",
          "corridorNodeId": "F_COR_17",
          "point": {
            "x": 680.6661069569826,
            "y": 631.7711195284019
          }
        },
        "D_FE104": {
          "id": "D_FE104",
          "roomId": "FE104",
          "corridorNodeId": "F_COR_18",
          "point": {
            "x": 590.831155617068,
            "y": 622.8194598743959
          }
        },
        "D_FW105": {
          "id": "D_FW105",
          "roomId": "FW105",
          "corridorNodeId": "F_COR_5",
          "point": {
            "x": 683.726563654313,
            "y": 360.32884586032617
          }
        },
        "D_FW103": {
          "id": "D_FW103",
          "roomId": "FW103",
          "corridorNodeId": "F_COR_3",
          "point": {
            "x": 632.5124096480648,
            "y": 320.8115613280616
          }
        },
        "D_FW201": {
          "id": "D_FW201",
          "roomId": "FW201",
          "corridorNodeId": "F_COR_6",
          "point": {
            "x": 676.3281643466048,
            "y": 418.65495694066624
          }
        },
        "D_FW109": {
          "id": "D_FW109",
          "roomId": "FW109",
          "corridorNodeId": "F_COR_7",
          "point": {
            "x": 737.5500749907146,
            "y": 394.77971039320516
          }
        },
        "D_FW202": {
          "id": "D_FW202",
          "roomId": "FW202",
          "corridorNodeId": "F_COR_27",
          "point": {
            "x": 727.351887376324,
            "y": 448.3452204548713
          }
        },
        "D_FE202": {
          "id": "D_FE202",
          "roomId": "FE202",
          "corridorNodeId": "F_COR_36",
          "point": {
            "x": 702.7027218305423,
            "y": 534.1598433712221
          }
        },
        "D_FE201": {
          "id": "D_FE201",
          "roomId": "FE201",
          "corridorNodeId": "F_COR_16",
          "point": {
            "x": 694.5712625418082,
            "y": 572.7924791837441
          }
        },
        "D_FE112": {
          "id": "D_FE112",
          "roomId": "FE112",
          "corridorNodeId": "F_COR_15",
          "point": {
            "x": 793.36545448934,
            "y": 567.404421233931
          }
        },
        "D_FE102": {
          "id": "D_FE102",
          "roomId": "FE102",
          "corridorNodeId": "F_COR_20",
          "point": {
            "x": 592.1088885392912,
            "y": 689.3483364279116
          }
        }
      }
    }
  },
  "interFloorLinks": [
    {
      "from": "G_STAIR_W",
      "to": "F_STAIR_W",
      "kind": "stairs",
      "cost": 25
    },
    {
      "from": "G_STAIR_E",
      "to": "F_STAIR_E",
      "kind": "stairs",
      "cost": 25
    }
  ]
}
''';

const Map<String, Map<String, String>> zoneAnchors = {
  'G': {
    'G_NORTH_EAST': 'G_COR_EAST',
    'G_NORTH_WEST': 'G_COR_WEST',
    'G_SOUTH_EAST': 'G_LOBBY',
    'G_SOUTH_WEST': 'G_LOBBY',
    'G_NORTH': 'G_JUNC_NORTH',
  },
  'F': {
    'F_NORTH_EAST': 'F_COR_EAST',
    'F_NORTH_WEST': 'F_COR_WEST',
    'F_SOUTH_EAST': 'F_RING',
    'F_SOUTH_WEST': 'F_RING',
    'F_NORTH': 'F_JUNC_NORTH',
  },
};


String? _labelForType(String? raw) {
  final type = (raw ?? '').trim().toLowerCase();
  if (type.isEmpty || type == 'unknown' || type == 'place') return 'Room';
  const map = {
    'lecture_hall': 'Lecture Hall',
    'library': 'Library',
    'cafe': 'Cafe',
    'cafeteria': 'Cafeteria',
    'bathroom': 'Bathroom',
    'bathroom_male': 'Bathroom (Men)',
    'bathroom_female': 'Bathroom (Women)',
    'prayer_room': 'Prayer Room',
    'prayer_male': 'Prayer (Men)',
    'prayer_female': 'Prayer (Women)',
    'classroom': 'Classroom',
    'lab': 'Lab',
    'computer_lab': 'Computer Lab',
    'ai_lab': 'AI Lab',
    'meeting_room': 'Meeting Room',
    'file_room': 'File Room',
    'office': 'Office',
    'waiting': 'Waiting Area',
    'lounge': 'Rest Area',
    'service': 'Service',
    'health_services': 'Health Services',
    'counter': 'Service Counter',
    'reception': 'Reception',
    'stationery': 'Stationery',
    'store': 'Store',
    'workshop': 'Workshop',
  };
  if (map.containsKey(type)) return map[type]!;
  return _titleCase(type.replaceAll('_', ' '));
}

const Map<String, String> _typeTranslationKeys = {
  'lecture_hall': 'room_type_lecture_hall',
  'library': 'room_type_library',
  'cafe': 'room_type_cafe',
  'cafeteria': 'room_type_cafeteria',
  'bathroom': 'room_type_bathroom',
  'bathroom_male': 'room_type_bathroom_male',
  'bathroom_female': 'room_type_bathroom_female',
  'prayer_room': 'room_type_prayer_room',
  'prayer_male': 'room_type_prayer_male',
  'prayer_female': 'room_type_prayer_female',
  'classroom': 'room_type_classroom',
  'lab': 'room_type_lab',
  'computer_lab': 'room_type_computer_lab',
  'ai_lab': 'room_type_ai_lab',
  'meeting_room': 'room_type_meeting_room',
  'file_room': 'room_type_file_room',
  'office': 'room_type_office',
  'waiting': 'room_type_waiting',
  'lounge': 'room_type_lounge',
  'service': 'room_type_service',
  'health_services': 'room_type_health_services',
  'counter': 'room_type_counter',
  'reception': 'room_type_reception',
  'stationery': 'room_type_stationery',
  'store': 'room_type_store',
  'workshop': 'room_type_workshop',
};

const Map<String, String> _roomTypeOverridesById = {
  // Fill exact room IDs here when the architectural drawings confirm them.
};

const List<String> _editableRoomTypes = [
  'unknown',
  'classroom',
  'office',
  'lecture_hall',
  'library',
  'lab',
  'computer_lab',
  'ai_lab',
  'meeting_room',
  'file_room',
  'waiting',
  'lounge',
  'service',
  'health_services',
  'counter',
  'reception',
  'stationery',
  'store',
  'workshop',
  'cafe',
  'cafeteria',
  'bathroom',
  'bathroom_male',
  'bathroom_female',
  'prayer_room',
  'prayer_male',
  'prayer_female',
];

const Map<String, String> _landmarkTranslationKeysById = {
  'G_ENT_1': 'landmark_women_entrance',
  'G_ENT_3': 'landmark_main_entrance',
  'G_ENT_4': 'landmark_male_entrance',
  'Elevator and Stairs W': 'landmark_stairs_1',
  'F_STAIR_1': 'landmark_stairs_1',
  'Elevator and Stairs M': 'landmark_stairs_2',
  'F_STAIR_2': 'landmark_stairs_2',
};

String _titleCase(String input) {
  return input
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

bool _looksLikeStandardAcademicRoom(PlaceSpec place) {
  final normalized = _normalizedFromPlace(place);
  if (normalized != null) return true;
  final raw = (place.codeOnPlan ?? place.code ?? place.id).trim().toUpperCase();
  return RegExp(r'^[GF](?:[EW])?\d{3}$').hasMatch(raw);
}

String _defaultTypeLabel(String? raw, {PlaceSpec? place}) {
  final overrideType = place == null ? null : _roomTypeOverridesById[place.id];
  final type = (overrideType ?? raw ?? '').trim().toLowerCase();
  if (type.isEmpty || type == 'unknown' || type == 'place' || type == 'room') {
    if (place != null && _looksLikeStandardAcademicRoom(place)) {
      return 'Classroom';
    }
    return 'Room';
  }
  return _labelForType(type) ?? _titleCase(type.replaceAll('_', ' '));
}

bool _labelLooksLikeRoomCode(PlaceSpec place) {
  final label = _compactSearch(place.label);
  if (label.isEmpty) return false;
  final norm = _normalizedFromPlace(place);
  final candidates = <String>{
    _compactSearch(place.id),
    if (place.code != null) _compactSearch(place.code!),
    if (place.publicCode != null) _compactSearch(place.publicCode!),
    if (place.codeOnPlan != null) _compactSearch(place.codeOnPlan!),
    if (place.normalizedCode != null) _compactSearch(place.normalizedCode!),
    if (norm != null) _compactSearch(norm.fullCode),
    if (norm != null) _compactSearch(norm.normalizedCode),
  };
  return candidates.contains(label);
}

String _displayCodeForPlace(PlaceSpec place) {
  for (final candidate in [
    place.codeOnPlan,
    place.code,
    place.publicCode,
    place.normalizedCode,
  ]) {
    final value = candidate?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  final id = place.id.trim();
  if (id.isEmpty) return '';
  if (normalizeRoomCode(id) != null) return id;
  if (RegExp(r'^[A-Z]+\d+$').hasMatch(id.toUpperCase())) return id;
  return '';
}

String _localizedTypeLabel(
  String? raw,
  String Function(String key) t, {
  PlaceSpec? place,
}) {
  final overrideType = place == null ? null : _roomTypeOverridesById[place.id];
  final type = (overrideType ?? raw ?? '').trim().toLowerCase();
  if (type.isEmpty || type == 'unknown' || type == 'place' || type == 'room') {
    if (place != null && _looksLikeStandardAcademicRoom(place)) {
      return t('room_type_classroom');
    }
    return t('room_type_room');
  }
  final key = _typeTranslationKeys[type];
  if (key != null) return t(key);
  return _labelForType(type) ?? _titleCase(type.replaceAll('_', ' '));
}

String _localizedPlaceLabel(PlaceSpec place, String Function(String key) t) {
  final overrideType = _roomTypeOverridesById[place.id];
  final resolvedType = overrideType ?? place.type;
  final label = place.label.trim();
  if (label.isEmpty) return _localizedTypeLabel(resolvedType, t, place: place);

  final lower = label.toLowerCase();
  if (lower == 'room' || lower == 'place' || _labelLooksLikeRoomCode(place)) {
    return _localizedTypeLabel(resolvedType, t, place: place);
  }

  final defaultTypeLabel = _defaultTypeLabel(
    resolvedType,
    place: place,
  ).toLowerCase();
  if (defaultTypeLabel.isNotEmpty && lower == defaultTypeLabel) {
    return _localizedTypeLabel(resolvedType, t, place: place);
  }

  for (final entry in _typeTranslationKeys.entries) {
    final englishLabel = (_labelForType(entry.key) ?? '').toLowerCase();
    if (englishLabel.isNotEmpty && lower == englishLabel) {
      return t(entry.value);
    }
  }

  return label;
}

String _nodeKindValue(NodeKind kind) {
  switch (kind) {
    case NodeKind.corridor:
      return 'corridor';
    case NodeKind.junction:
      return 'junction';
    case NodeKind.entrance:
      return 'entrance';
    case NodeKind.stairs:
      return 'stairs';
  }
}

String? _shortWing(String? wing, String? floor) {
  if (wing == null || wing.trim().isEmpty) return null;
  final w = wing.trim().toUpperCase();
  if (w.length == 2 && floor != null && w.startsWith(floor.toUpperCase())) {
    return w.substring(1);
  }
  if (w == 'E' || w == 'W') return w;
  return w;
}

String? _guessZoneForCatalog(Map<String, dynamic> room) {
  final raw =
      (room['codeOnPlan'] as String?) ??
      (room['code'] as String?) ??
      (room['id'] as String?);
  final norm = raw == null ? null : normalizeRoomCode(raw);
  final floor = (room['floor'] as String?)?.toUpperCase() ?? norm?.floor;
  final wingRaw = (room['wing'] as String?)?.toUpperCase();
  final wing = _shortWing(wingRaw, floor) ?? norm?.wing;
  final number = norm?.number;
  final numValue = number == null ? null : int.tryParse(number);
  final isSouth = numValue != null && numValue >= 600;

  if (floor == 'G') {
    if (wing == 'E') return isSouth ? 'G_SOUTH_EAST' : 'G_NORTH_EAST';
    if (wing == 'W') return isSouth ? 'G_SOUTH_WEST' : 'G_NORTH_WEST';
    return isSouth ? 'G_SOUTH_EAST' : 'G_NORTH';
  }
  if (floor == 'F') {
    if (wing == 'E') return isSouth ? 'F_SOUTH_EAST' : 'F_NORTH_EAST';
    if (wing == 'W') return isSouth ? 'F_SOUTH_WEST' : 'F_NORTH_WEST';
    return isSouth ? 'F_SOUTH_EAST' : 'F_NORTH';
  }
  return null;
}

PlaceSpec _mergeCatalogIntoPlace(
  PlaceSpec existing,
  Map<String, dynamic> incoming,
) {
  final incomingType = (incoming['type'] as String?)?.trim();
  final type =
      (incomingType == null ||
          incomingType.isEmpty ||
          incomingType.toLowerCase() == 'unknown')
      ? existing.type
      : incomingType;
  final incomingLabel =
      (incoming['label'] as String?) ??
      (incoming['displayName'] as String?) ??
      (incoming['description'] as String?);
  final label = (incomingLabel == null || incomingLabel.trim().isEmpty)
      ? (existing.label.isNotEmpty
            ? existing.label
            : (_labelForType(type) ?? existing.id))
      : incomingLabel;
  final incomingDoorId = (incoming['doorId'] as String?)?.trim();
  final doorId = (incomingDoorId == null || incomingDoorId.isEmpty)
      ? existing.doorId
      : incomingDoorId;
  final codeOnPlan =
      (incoming['codeOnPlan'] as String?) ??
      (incoming['code'] as String?) ??
      existing.codeOnPlan;
  final normalizedCode =
      (incoming['normalizedCode'] as String?) ??
      existing.normalizedCode ??
      normalizeRoomCode(codeOnPlan ?? existing.id)?.normalizedCode;
  return PlaceSpec(
    id: existing.id,
    type: type,
    label: label,
    code: codeOnPlan ?? existing.code,
    publicCode: existing.publicCode,
    codeOnPlan: codeOnPlan ?? existing.codeOnPlan,
    normalizedCode: normalizedCode,
    doorId: doorId,
    floor: (incoming['floor'] as String?) ?? existing.floor,
    wing: (incoming['wing'] as String?) ?? existing.wing,
    zone: existing.zone,
    norm: existing.norm,
  );
}

MapData mergeCatalogRooms(
  MapData base,
  List<Map<String, dynamic>> catalogRooms,
) {
  if (catalogRooms.isEmpty) return base;
  final byFloor = <String, List<Map<String, dynamic>>>{};
  for (final room in catalogRooms) {
    final floor = (room['floor'] as String?)?.toUpperCase();
    if (floor == null || floor.isEmpty) continue;
    byFloor.putIfAbsent(floor, () => []).add(room);
  }

  final mergedFloors = <String, FloorModel>{};
  for (final entry in base.floors.entries) {
    final floorId = entry.key;
    final floorModel = entry.value;
    final incoming = byFloor[floorId] ?? const [];
    if (incoming.isEmpty) {
      mergedFloors[floorId] = floorModel;
      continue;
    }

    final existingById = {for (final r in floorModel.rooms) r.id: r};
    final mergedRooms = List<PlaceSpec>.from(floorModel.rooms);

    for (final room in incoming) {
      final code =
          (room['code'] as String?) ??
          (room['codeOnPlan'] as String?) ??
          (room['id'] as String?);
      if (code == null || code.trim().isEmpty) continue;
      final id = (room['id'] as String?) ?? code;
      if (existingById.containsKey(id)) {
        final updated = _mergeCatalogIntoPlace(existingById[id]!, room);
        final index = mergedRooms.indexWhere((r) => r.id == id);
        if (index >= 0) {
          mergedRooms[index] = updated;
        }
        existingById[id] = updated;
        continue;
      }

      final normalized = normalizeRoomCode(code);
      final map = Map<String, dynamic>.from(room);
      map['id'] = id;
      map['codeOnPlan'] ??= code;
      map['normalizedCode'] ??= normalized?.normalizedCode;
      map['label'] ??= _labelForType(room['type'] as String?);
      map['zone'] ??= _guessZoneForCatalog(map);
      final created = PlaceSpec.fromJson(map);
      mergedRooms.add(created);
      existingById[id] = created;
    }

    mergedFloors[floorId] = FloorModel(
      id: floorModel.id,
      landmarks: floorModel.landmarks,
      rooms: mergedRooms,
      nodes: floorModel.nodes,
      edges: floorModel.edges,
    );
  }

  return MapData(floors: mergedFloors, interFloorLinks: base.interFloorLinks);
}

String _placeDisplay(PlaceSpec place, String Function(String key) t) {
  final norm = _normalizedFromPlace(place);
  final code = _displayCodeForPlace(place);
  final rawWing =
      _shortWing(place.wing, place.floor ?? norm?.floor) ?? norm?.wing;
  final wing = (rawWing != null && rawWing.isNotEmpty) ? rawWing : null;
  final codeUpper = code.toUpperCase();
  final codeAlreadyContainsWing =
      wing != null &&
      RegExp(
        '^[GF]${RegExp.escape(wing)}'
        r'\d{3}$',
      ).hasMatch(codeUpper);
  final showWing = wing != null && !codeAlreadyContainsWing;
  final wingSuffix = showWing ? ' ($wing)' : '';
  final localizedLabel = _localizedPlaceLabel(place, t);
  final localizedType = _localizedTypeLabel(place.type, t, place: place);
  final details = localizedLabel == localizedType
      ? localizedLabel
      : '$localizedLabel ($localizedType)';
  if (code.isEmpty) return details;
  return details.isEmpty ? '$code$wingSuffix' : '$code$wingSuffix $details';
}

String _placeLabel(PlaceSpec place) {
  final code = _displayCodeForPlace(place);
  final label = _labelLooksLikeRoomCode(place)
      ? _defaultTypeLabel(place.type, place: place)
      : place.label.trim();
  final fallback = _defaultTypeLabel(place.type, place: place);
  final details = label.isEmpty || label == fallback
      ? fallback
      : '$label ($fallback)';
  if (code.isEmpty) return details;
  return details.isEmpty ? code : '$code $details';
}

String _placeSearchText(PlaceSpec place) {
  final norm = _normalizedFromPlace(place);
  final tokens = <String>[
    place.id,
    if (place.code != null) place.code!,
    if (place.publicCode != null) place.publicCode!,
    if (place.codeOnPlan != null) place.codeOnPlan!,
    if (place.normalizedCode != null) place.normalizedCode!,
    if (place.floor != null) place.floor!,
    if (place.wing != null) place.wing!,
    place.label,
    place.type,
    if (norm != null) norm.fullCode,
    if (norm != null) norm.normalizedCode,
  ];
  final plain = tokens.join(' ').toLowerCase();
  final compact = _compactSearch(plain);
  return '$plain $compact';
}

Offset _normToImage(Offset norm, Rect bounds) {
  return Offset(
    bounds.left + norm.dx * bounds.width,
    bounds.top + norm.dy * bounds.height,
  );
}

List<String>? dijkstra(FloorGraph graph, String start, String goal) {
  if (!graph.adj.containsKey(start) || !graph.adj.containsKey(goal)) {
    return null;
  }
  final dist = <String, double>{start: 0};
  final prev = <String, String?>{start: null};
  final visited = <String>{};

  while (true) {
    String? current;
    var best = double.infinity;
    for (final entry in dist.entries) {
      if (visited.contains(entry.key)) continue;
      if (entry.value < best) {
        best = entry.value;
        current = entry.key;
      }
    }
    if (current == null) break;
    if (current == goal) break;
    visited.add(current);
    final edges = graph.adj[current] ?? [];
    for (final edge in edges) {
      final nd = best + edge.distance;
      if (nd < (dist[edge.to] ?? double.infinity)) {
        dist[edge.to] = nd;
        prev[edge.to] = current;
      }
    }
  }

  if (!prev.containsKey(goal)) return null;
  final path = <String>[];
  String? cur = goal;
  while (cur != null) {
    path.add(cur);
    cur = prev[cur];
  }
  return path.reversed.toList();
}

String compassFromPoints(Offset a, Offset b) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  if (dx == 0 && dy == 0) return 'N';
  var bearing = math.atan2(dx, -dy) * 180 / math.pi;
  if (bearing < 0) bearing += 360;
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final idx = ((bearing + 22.5) / 45).floor() % 8;
  return dirs[idx];
}

String compassWord(String d) {
  switch (d) {
    case 'N':
      return 'north';
    case 'S':
      return 'south';
    case 'E':
      return 'east';
    case 'W':
      return 'west';
    case 'NE':
      return 'north-east';
    case 'NW':
      return 'north-west';
    case 'SE':
      return 'south-east';
    case 'SW':
      return 'south-west';
    default:
      return 'forward';
  }
}

String turnNameCompass(String prev, String next) {
  const order = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final pi = order.indexOf(prev);
  final ni = order.indexOf(next);
  if (pi == -1 || ni == -1) return 'Continue';
  final diff = (ni - pi + 8) % 8;
  if (diff == 0) return 'Go straight';
  if (diff == 1) return 'Slight right';
  if (diff == 2) return 'Turn right';
  if (diff == 6) return 'Turn left';
  if (diff == 7) return 'Slight left';
  return 'Turn back';
}

class RouteInfo {
  final List<String> steps;
  final int turns;
  final double distance;

  const RouteInfo({
    required this.steps,
    required this.turns,
    required this.distance,
  });
}

class GuideHomePage extends StatefulWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const GuideHomePage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  @override
  State<GuideHomePage> createState() => _GuideHomePageState();
}

class _GuideHomePageState extends State<GuideHomePage> {
  String get _langCode => widget.locale.languageCode;
  bool get _isArabic => _langCode == 'ar';

  String t(String key) {
    return guideTranslations[_langCode]?[key] ??
        guideTranslations['en']?[key] ??
        key;
  }

  String tr(String key, {Map<String, String> args = const {}}) {
    var text = t(key);
    args.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  FloorKind _floor = FloorKind.gf;
  SetMode _mode = SetMode.my;

  late MapData _mapData;
  late Map<String, FloorGraph> _graphs;

  ui.Image? _ffImage;
  ui.Image? _gfImage;
  String? _startNodeId;
  String? _myNodeId;
  String? _selectedRoomId;
  List<Offset> _routeImage = [];
  Offset? _myImagePos;
  Offset? _destImagePos;
  Offset? _cameraAnchorImagePos;
  double _mapRotationRadians = 0.0;
  final Map<String, Offset> _manualNorm = {};

  Map<String, dynamic>? _navGraph;
  double _navWidth = 1.0;
  double _navHeight = 1.0;
  bool _editMode = false;
  EditAction _editAction = EditAction.none;
  NodeKind _editNodeKind = NodeKind.corridor;
  String _editNodeId = '';
  String? _selectedNodeId;
  String? _pendingEdgeFrom;
  String? _editorRoomId;
  bool _dragNodes = true;
  String? _dragNodeId;
  bool _chainConnect = true;
  String? _pathCursorId;

  String _statusKey = 'status_waiting';
  Map<String, String> _statusArgs = const {};
  bool _statusOk = false;
  String _fromLabel = '';
  String _toLabel = '';
  double? _distance;
  int? _turns;
  List<String> _steps = [];
  List<String> _lastPath = [];
  String? _lastPathFloorId;
  bool _pickCoords = false;
  String _pickTargetId = '';
  Offset? _lastImageCoord;
  Offset? _lastNormCoord;

  String _searchQuery = '';
  final Set<String> _activeFacilityTypes = {};
  final ValueNotifier<int> _adminTick = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    final decoded = jsonDecode(mapDataJson) as Map<String, dynamic>;
    _mapData = _mapDataFromDecoded(decoded, seedNavGraph: true);
    _graphs = {
      for (final entry in _mapData.floors.entries)
        entry.key: buildFloorGraph(entry.value),
    };
    _setDefaultStart();
    _setDefaultDestination();
    _loadImages();
    _loadRoomCatalog();
    _loadNavigationGraph();
  }

  @override
  void didUpdateWidget(covariant GuideHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale.languageCode != widget.locale.languageCode) {
      setState(() {
        _refreshLabelsForLocale();
        _refreshStepsForLocale();
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
    _adminTick.value++;
  }

  @override
  void dispose() {
    _adminTick.dispose();
    super.dispose();
  }

  void _refreshLabelsForLocale() {
    final graph = _graphForFloor();
    final startId = _myNodeId ?? _startNodeId;
    _fromLabel = startId == null
        ? t('not_set')
        : '${_floorLabel()} @ ${_displayNodeLabel(startId, graph)}';

    final rooms = _filteredRooms();
    if (rooms.isEmpty) {
      _toLabel = t('not_set');
      return;
    }
    if (_selectedRoomId != null && rooms.any((r) => r.id == _selectedRoomId)) {
      final room = rooms.firstWhere((r) => r.id == _selectedRoomId);
      _toLabel = _placeDisplay(room, t);
      return;
    }
    if (_searchQuery.trim().isNotEmpty && rooms.length > 1) {
      _toLabel = t('select_destination');
      return;
    }
    _toLabel = _placeDisplay(rooms.first, t);
  }

  void _refreshStepsForLocale() {
    if (_lastPath.isEmpty || _lastPathFloorId == null) return;
    final graph = _graphs[_lastPathFloorId!];
    if (graph == null) return;
    final info = _buildStepsFromPath(_lastPath, graph);
    _steps = info.steps;
    _distance = info.distance;
    _turns = info.turns;
  }

  MapData _mapDataFromDecoded(
    Map<String, dynamic> decoded, {
    bool seedNavGraph = false,
  }) {
    if (_looksLikeNavigationGraph(decoded)) {
      if (seedNavGraph) {
        _navGraph = decoded;
        final coord =
            decoded['coordinateSystem'] as Map<String, dynamic>? ?? {};
        _navWidth = (coord['width'] as num?)?.toDouble() ?? 1000.0;
        _navHeight = (coord['height'] as num?)?.toDouble() ?? 1000.0;
      }
      return mapDataFromNavigationGraph(decoded);
    }
    return MapData.fromJson(decoded);
  }

  Future<void> _loadImages() async {
    final ff = await _loadUiImage('assets/maps/BranchFF1.png');
    final gf = await _loadUiImage('assets/maps/GroundFloor.png');
    if (!mounted) return;
    setState(() {
      _ffImage = ff;
      _gfImage = gf;
    });
  }

  Future<void> _loadRoomCatalog() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/classguide_rooms.json',
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final rooms = (decoded['rooms'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (rooms.isEmpty) return;
      final merged = mergeCatalogRooms(_mapData, rooms);
      if (!mounted) return;
      setState(() {
        _mapData = merged;
        _graphs = {
          for (final entry in _mapData.floors.entries)
            entry.key: buildFloorGraph(entry.value),
        };
        _setDefaultDestination(clearRoute: true);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _setStatus('status_room_catalog_not_loaded', false);
      });
    }
  }

  Future<void> _loadNavigationGraph() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/navigation_graph_recreated.json',
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded.isEmpty || !decoded.containsKey('floors')) return;
      final mapData = _mapDataFromDecoded(decoded, seedNavGraph: true);
      if (!mounted) return;
      setState(() {
        _mapData = mapData;
        _graphs = {
          for (final entry in _mapData.floors.entries)
            entry.key: buildFloorGraph(entry.value),
        };
        _setDefaultStart();
        _setDefaultDestination(clearRoute: true);
        _setStatus('status_nav_graph_loaded', true);
      });
      await _loadRoomCatalog();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _setStatus('status_nav_graph_not_loaded', false);
      });
    }
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  String _floorKey() => _floor == FloorKind.gf ? 'G' : 'F';

  FloorGraph _graphForFloor() => _graphs[_floorKey()]!;

  Rect _boundsForFloorKind(FloorKind floor) =>
      floor == FloorKind.gf ? gfBounds : ffBounds;

  Rect _boundsForFloor() => _boundsForFloorKind(_floor);

  String _navFloorId() => _floor == FloorKind.gf ? 'G' : 'F';

  Map<String, dynamic> _navFloor(String floorId) {
    final graph = _navGraph ??= <String, dynamic>{};
    graph.putIfAbsent('floors', () => <String, dynamic>{});
    final floors = graph['floors'] as Map<String, dynamic>;
    floors.putIfAbsent(
      floorId,
      () => <String, dynamic>{
        'nodes': <String, dynamic>{},
        'edges': <dynamic>[],
        'rooms': <String, dynamic>{},
        'doors': <String, dynamic>{},
      },
    );
    return floors[floorId] as Map<String, dynamic>;
  }

  Map<String, dynamic> _navNodes(String floorId) {
    final floor = _navFloor(floorId);
    floor.putIfAbsent('nodes', () => <String, dynamic>{});
    return floor['nodes'] as Map<String, dynamic>;
  }

  Map<String, dynamic> _navDoors(String floorId) {
    final floor = _navFloor(floorId);
    floor.putIfAbsent('doors', () => <String, dynamic>{});
    return floor['doors'] as Map<String, dynamic>;
  }

  Map<String, dynamic> _navRooms(String floorId) {
    final floor = _navFloor(floorId);
    floor.putIfAbsent('rooms', () => <String, dynamic>{});
    return floor['rooms'] as Map<String, dynamic>;
  }

  List<dynamic> _navEdges(String floorId) {
    final floor = _navFloor(floorId);
    floor.putIfAbsent('edges', () => <dynamic>[]);
    return floor['edges'] as List<dynamic>;
  }

  String _labelHandleId(String roomId) => 'LBL_$roomId';

  String? _roomIdFromLabelHandle(String id) {
    const prefix = 'LBL_';
    if (!id.startsWith(prefix) || id.length <= prefix.length) return null;
    return id.substring(prefix.length);
  }

  String _editorDisplayId(String? id) {
    if (id == null || id.isEmpty) return '-';
    return _roomIdFromLabelHandle(id) ?? id;
  }

  String? _selectedEditorId({
    bool includeDoors = true,
    bool includeLabels = true,
  }) {
    final id = _selectedNodeId;
    if (id == null) return null;
    if (!includeLabels && _roomIdFromLabelHandle(id) != null) return null;
    if (!includeDoors && _navDoors(_navFloorId()).containsKey(id)) return null;
    return id;
  }

  Offset _navCoordFromImage(Offset imagePos) {
    final norm = _imageToNorm(imagePos, _boundsForFloor());
    return Offset(norm.dx * _navWidth, norm.dy * _navHeight);
  }

  Offset? _navPointForNodeId(String id, String floorId) {
    final nodes = _navNodes(floorId);
    final doors = _navDoors(floorId);
    Map<String, dynamic>? raw;
    if (nodes.containsKey(id)) {
      raw = nodes[id] as Map<String, dynamic>?;
    } else if (doors.containsKey(id)) {
      final door = doors[id] as Map<String, dynamic>?;
      raw = door == null ? null : (door['point'] as Map<String, dynamic>?);
    }
    if (raw == null) return null;
    final x = (raw['x'] as num?)?.toDouble();
    final y = (raw['y'] as num?)?.toDouble();
    if (x == null || y == null) return null;
    return Offset(x, y);
  }

  Map<String, double> _defaultLabelPointForDoor({
    required String floorId,
    required String corridorId,
    required Offset doorPoint,
  }) {
    final corridorPoint = _navPointForNodeId(corridorId, floorId);
    var labelPoint = doorPoint + const Offset(18, -18);
    if (corridorPoint != null) {
      final delta = doorPoint - corridorPoint;
      if (delta.distanceSquared > 0.0001) {
        final direction = delta / delta.distance;
        labelPoint = doorPoint + (direction * 28);
      }
    }
    final margin = 12.0;
    return {
      'x': labelPoint.dx.clamp(margin, _navWidth - margin),
      'y': labelPoint.dy.clamp(margin, _navHeight - margin),
    };
  }

  void _applyNavGraph() {
    if (_navGraph == null) return;
    final mapData = mapDataFromNavigationGraph(_navGraph!);
    setState(() {
      _mapData = mapData;
      _graphs = {
        for (final entry in _mapData.floors.entries)
          entry.key: buildFloorGraph(entry.value),
      };
      _setDefaultStart();
      _setDefaultDestination(clearRoute: true);
      _setStatus('status_nav_graph_updated', true);
    });
  }

  List<PlaceSpec> _roomsForFloor() {
    final byId = <String, PlaceSpec>{};
    for (final room in _graphForFloor().rooms) {
      byId[room.id] = room;
    }
    final rooms = byId.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return rooms;
  }

  List<PlaceSpec> _filteredRooms() {
    final rawQuery = _searchQuery.trim();
    final query = rawQuery.toLowerCase();
    final applyFacilityFilter = rawQuery.isEmpty;
    final rooms = applyFacilityFilter
        ? _roomsForFloor().where(_matchesFacilityFilter).toList()
        : _roomsForFloor().toList();
    if (query.isEmpty) return rooms;
    final compact = _compactSearch(rawQuery);
    return rooms.where((r) {
      final hay = _placeSearchText(r);
      if (hay.contains(query)) return true;
      if (compact.isNotEmpty && hay.contains(compact)) return true;
      return false;
    }).toList();
  }

  bool _matchesFacilityFilter(PlaceSpec room) {
    if (_activeFacilityTypes.isEmpty) return true;
    return _activeFacilityTypes.contains(room.type);
  }

  String _facilityLabel(String type) {
    final kind = facilityByType[type];
    if (kind != null) return t(kind.labelKey);
    return _labelForType(type) ?? type;
  }

  List<FacilityMarker> _facilityMarkersForFloor(FloorGraph graph, Rect bounds) {
    final markers = <FacilityMarker>[];
    final liveRooms = _editMode && _navGraph != null
        ? _navRooms(_navFloorId())
        : const <String, dynamic>{};
    for (final room in graph.rooms) {
      final kind = facilityByType[room.type];
      if (kind == null) continue;
      if (_activeFacilityTypes.isNotEmpty &&
          !_activeFacilityTypes.contains(room.type)) {
        continue;
      }
      Offset? norm;
      final raw = liveRooms[room.id];
      if (raw is Map<String, dynamic>) {
        norm = _normFromPoint(
          raw['labelPoint'] as Map<String, dynamic>?,
          _navWidth,
          _navHeight,
        );
      }
      norm ??= _nodeNorm(graph, room.id) ?? room.norm;
      if (norm == null) continue;
      markers.add(
        FacilityMarker(
          id: room.id,
          imagePos: _normToImage(norm, bounds),
          icon: kind.icon,
          color: kind.color,
        ),
      );
    }
    return markers;
  }

  PlaceSpec? _nearestRoomByType(FloorGraph graph, String type) {
    final rooms = graph.rooms.where((r) => r.type == type).toList();
    if (rooms.isEmpty) return null;
    final startId = _myNodeId ?? _startNodeId;
    if (startId == null) return null;
    final bounds = _boundsForFloor();
    final startNorm = _myImagePos != null
        ? _imageToNorm(_myImagePos!, bounds)
        : _nodeNorm(graph, startId);
    if (startNorm == null) return null;
    final startNode = _resolveStartRouteNode(graph, startId, startNorm);
    if (startNode == null) return null;

    PlaceSpec? bestRoom;
    double bestDistance = double.infinity;

    for (final room in rooms) {
      final doorId = _doorNodeIdForRoom(graph, room);
      final doorNorm =
          (doorId == null ? null : _nodeNorm(graph, doorId)) ?? room.norm;
      if (doorNorm == null) continue;
      String? destNode;
      if (doorId != null) {
        final corridorId = _doorCorridorNodeId(_navFloorId(), doorId);
        if (corridorId != null &&
            _isCorridorNodeId(graph, corridorId) &&
            _nodeNorm(graph, corridorId) != null) {
          destNode = corridorId;
        }
      }
      destNode ??= _nearestCorridorNode(graph, doorNorm);
      if (destNode == null) continue;
      final path = startNode == destNode
          ? <String>[startNode]
          : dijkstra(graph, startNode, destNode);
      if (path == null || path.isEmpty) continue;
      final info = _buildStepsFromPath(path, graph);
      if (info.distance < bestDistance) {
        bestDistance = info.distance;
        bestRoom = room;
      }
    }
    return bestRoom;
  }

  void _selectNearestFacility(String type) {
    final graph = _graphForFloor();
    final room = _nearestRoomByType(graph, type);
    if (room == null) {
      setState(() {
        _setStatus(
          'status_no_facility_found',
          false,
          args: {'facility': _facilityLabel(type)},
        );
      });
      return;
    }
    _selectRoom(room.id);
    _buildRoute();
  }

  void _toggleFacilityFilter(String type) {
    setState(() {
      if (_activeFacilityTypes.contains(type)) {
        _activeFacilityTypes.remove(type);
      } else {
        _activeFacilityTypes.add(type);
      }
      _setDefaultDestination(clearRoute: true);
    });
  }

  void _clearFacilityFilters() {
    setState(() {
      _activeFacilityTypes.clear();
      _setDefaultDestination(clearRoute: true);
    });
  }

  Offset? _nodeImagePos(FloorGraph graph, String nodeId) {
    final norm = _manualNorm[nodeId] ?? graph.normPos[nodeId];
    if (norm == null) return null;
    return _normToImage(norm, _boundsForFloor());
  }

  PlaceSpec? _roomById(String id) {
    for (final room in _roomsForFloor()) {
      if (room.id == id) return room;
    }
    return null;
  }

  String _landmarkDisplay(PlaceSpec landmark) {
    final key = _landmarkTranslationKeysById[landmark.id];
    if (key != null) return t(key);
    return landmark.label;
  }

  String _displayNodeLabel(String id, FloorGraph graph) {
    for (final landmark in graph.landmarks) {
      if (landmark.id == id) return _landmarkDisplay(landmark);
    }
    for (final room in graph.rooms) {
      if (room.id == id) return _placeDisplay(room, t);
    }
    return graph.label[id] ?? id;
  }

  String? _doorNodeIdForRoom(FloorGraph graph, PlaceSpec room) {
    final candidates = <String>[
      if (room.doorId != null) room.doorId!,
      'D_${room.id}',
      if (room.codeOnPlan != null)
        'D_${room.codeOnPlan!.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '')}',
      if (room.code != null)
        'D_${room.code!.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '')}',
    ];
    for (final id in candidates) {
      if (id.isEmpty) continue;
      if (graph.type.containsKey(id) || _manualNorm.containsKey(id)) {
        return id;
      }
    }
    return null;
  }

  String? _doorCorridorNodeId(String floorId, String doorId) {
    if (_navGraph == null) return null;
    final doors = _navDoors(floorId);
    final raw = doors[doorId];
    if (raw is! Map<String, dynamic>) return null;
    final corridorId = raw['corridorNodeId'] as String?;
    if (corridorId == null || corridorId.isEmpty) return null;
    return corridorId;
  }

  Offset? _nodeNorm(FloorGraph graph, String id) =>
      _manualNorm[id] ?? graph.normPos[id];

  Offset _imageToNorm(Offset image, Rect bounds) {
    final nx = ((image.dx - bounds.left) / bounds.width).clamp(0.0, 1.0);
    final ny = ((image.dy - bounds.top) / bounds.height).clamp(0.0, 1.0);
    return Offset(nx, ny);
  }

  bool _isCorridorNodeId(FloorGraph graph, String id) {
    final t = graph.type[id];
    if (t != null) return t != 'room' && t != 'door';
    if (id.startsWith('D_')) return false;
    if (_roomById(id) != null) return false;
    return true;
  }

  String? _nearestCorridorNode(FloorGraph graph, Offset norm) {
    double best = double.infinity;
    String? bestId;
    final ids = <String>{...graph.normPos.keys, ..._manualNorm.keys};
    for (final id in ids) {
      if (!_isCorridorNodeId(graph, id)) continue;
      final p = _nodeNorm(graph, id);
      if (p == null) continue;
      final d = (p - norm).distanceSquared;
      if (d < best) {
        best = d;
        bestId = id;
      }
    }
    return bestId;
  }

  String _selectedEditableRoomType() {
    final roomId = (_editorRoomId ?? _selectedRoomId)?.trim();
    if (roomId == null || roomId.isEmpty) return 'unknown';
    final raw = _navRooms(_navFloorId())[roomId];
    final rawType = raw is Map<String, dynamic>
        ? (raw['type'] as String?)
        : null;
    final resolved = (rawType ?? _roomById(roomId)?.type ?? 'unknown')
        .trim()
        .toLowerCase();
    if (resolved.isEmpty) return 'unknown';
    return _editableRoomTypes.contains(resolved) ? resolved : 'unknown';
  }

  String _sanitizeEditableRoomId(String input) {
    return input
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Z0-9_]+'), '')
        .replaceAll(RegExp(r'_+'), '_');
  }

  String? _upsertEditableRoom({
    required String roomId,
    required String type,
    required String floorId,
  }) {
    if (_navGraph == null) return null;
    final sanitizedId = _sanitizeEditableRoomId(roomId);
    if (sanitizedId.isEmpty) return null;
    final rooms = _navRooms(floorId);
    rooms.putIfAbsent(
      sanitizedId,
      () => <String, dynamic>{'id': sanitizedId, 'floor': floorId},
    );
    final room = rooms[sanitizedId] as Map<String, dynamic>;
    final previousType = (room['type'] as String?)?.trim().toLowerCase();
    final existingLabel = (room['label'] as String?)?.trim();
    final previousDefaultLabel = _labelForType(previousType) ?? 'Room';
    final resolvedType = type.trim().isEmpty ? 'unknown' : type.trim().toLowerCase();
    final defaultLabel = _labelForType(resolvedType) ?? 'Room';
    final normalized = normalizeRoomCode(sanitizedId);

    room['id'] = sanitizedId;
    room['floor'] = floorId;
    room['type'] = resolvedType;
    room['codeOnPlan'] = sanitizedId;
    room['code'] = sanitizedId;

    final shouldResetLabel =
        existingLabel == null ||
        existingLabel.isEmpty ||
        existingLabel.toLowerCase() == sanitizedId.toLowerCase() ||
        existingLabel.toLowerCase() == previousDefaultLabel.toLowerCase();
    if (shouldResetLabel) {
      room['label'] = defaultLabel;
    }

    if (normalized != null) {
      room['normalizedCode'] = normalized.normalizedCode;
      room['wing'] = normalized.wing.isEmpty
          ? null
          : '${normalized.floor}${normalized.wing}';
    }
    room['zone'] = _guessZoneForCatalog(room);
    return sanitizedId;
  }

  void _setSelectedRoomType(String type) {
    if (_navGraph == null) return;
    final roomId = (_editorRoomId ?? _selectedRoomId)?.trim();
    if (roomId == null || roomId.isEmpty) return;
    final floorId = _navFloorId();
    final rooms = _navRooms(floorId);
    rooms.putIfAbsent(
      roomId,
      () => <String, dynamic>{'id': roomId, 'floor': floorId},
    );
    final room = rooms[roomId] as Map<String, dynamic>;
    room['type'] = type.trim().isEmpty ? 'unknown' : type.trim().toLowerCase();
    _applyNavGraph();
  }

  Future<void> _openCreateRoomDoorDialog() async {
    if (_navGraph == null) return;
    final roomController = TextEditingController(
      text: (_editorRoomId ?? _selectedRoomId ?? '').trim(),
    );
    var selectedType = _selectedEditableRoomType();
    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setModalState) {
              return AlertDialog(
                title: Text(t('create_room_door')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roomController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: t('new_room_number'),
                        hintText: t('new_room_number_hint'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: t('editor_room_type'),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        isDense: true,
                      ),
                      items: _editableRoomTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type == 'unknown'
                                    ? t('room_type_room')
                                    : _localizedTypeLabel(type, t),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(t('admin_cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop({
                        'roomId': roomController.text,
                        'type': selectedType,
                      });
                    },
                    child: Text(t('create')),
                  ),
                ],
              );
            },
          );
        },
      );
      if (!mounted || result == null) return;

      final roomId = _sanitizeEditableRoomId(result['roomId'] ?? '');
      if (roomId.isEmpty) {
        setState(() {
          _setStatus('status_room_id_required', false);
        });
        return;
      }

      final floorId = _navFloorId();
      final normalized = normalizeRoomCode(roomId);
      if (normalized != null && normalized.floor != floorId) {
        setState(() {
          _setStatus(
            'status_room_floor_mismatch',
            false,
            args: {'id': roomId, 'floor': floorId},
          );
        });
        return;
      }

      final createdRoomId = _upsertEditableRoom(
        roomId: roomId,
        type: result['type'] ?? 'unknown',
        floorId: floorId,
      );
      if (createdRoomId == null) {
        setState(() {
          _setStatus('status_room_id_required', false);
        });
        return;
      }

      _applyNavGraph();
      setState(() {
        _editorRoomId = createdRoomId;
        _selectedRoomId = createdRoomId;
        _editAction = EditAction.addDoor;
        _setStatus(
          'status_room_created_place_door',
          true,
          args: {'id': createdRoomId},
        );
      });
    } finally {
      roomController.dispose();
    }
  }

  String _compassWord(String d) {
    switch (d) {
      case 'N':
        return t('dir_n');
      case 'S':
        return t('dir_s');
      case 'E':
        return t('dir_e');
      case 'W':
        return t('dir_w');
      case 'NE':
        return t('dir_ne');
      case 'NW':
        return t('dir_nw');
      case 'SE':
        return t('dir_se');
      case 'SW':
        return t('dir_sw');
      default:
        return t('dir_forward');
    }
  }

  String _turnNameCompass(String prev, String next) {
    const order = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final pi = order.indexOf(prev);
    final ni = order.indexOf(next);
    if (pi == -1 || ni == -1) return t('turn_continue');
    final diff = (ni - pi + 8) % 8;
    if (diff == 0) return t('turn_straight');
    if (diff == 1) return t('turn_slight_right');
    if (diff == 2) return t('turn_right');
    if (diff == 6) return t('turn_left');
    if (diff == 7) return t('turn_slight_left');
    return t('turn_back');
  }

  RouteInfo _buildStepsFromPath(List<String> path, FloorGraph graph) {
    final pos = <String, Offset>{...graph.normPos, ..._manualNorm};
    if (path.length < 2) {
      return const RouteInfo(steps: [], turns: 0, distance: 0);
    }
    final segs = <Map<String, dynamic>>[];
    for (var i = 0; i < path.length - 1; i++) {
      final a = pos[path[i]];
      final b = pos[path[i + 1]];
      if (a == null || b == null) continue;
      final dir = compassFromPoints(a, b);
      final dist = graph.edgeDistances['${path[i]}|${path[i + 1]}'] ?? 1.0;
      if (segs.isNotEmpty && segs.last['dir'] == dir) {
        segs.last['dist'] = (segs.last['dist'] as double) + dist;
      } else {
        segs.add({'dir': dir, 'dist': dist});
      }
    }

    if (segs.isEmpty) {
      return const RouteInfo(steps: [], turns: 0, distance: 0);
    }

    final steps = <String>[];
    var current = segs.first['dir'] as String;
    final firstDist = (segs.first['dist'] as double).round();
    steps.add(
      tr(
        'step_head',
        args: {'dir': _compassWord(current), 'dist': '$firstDist'},
      ),
    );
    for (var i = 1; i < segs.length; i++) {
      final next = segs[i]['dir'] as String;
      final dist = (segs[i]['dist'] as double).round();
      steps.add(
        tr(
          'step_turn',
          args: {
            'turn': _turnNameCompass(current, next),
            'dir': _compassWord(next),
            'dist': '$dist',
          },
        ),
      );
      current = next;
    }
    steps.add(t('step_arrived'));

    final total = segs.fold<double>(0, (sum, e) => sum + (e['dist'] as double));
    return RouteInfo(
      steps: steps,
      turns: math.max(0, segs.length - 1),
      distance: total,
    );
  }

  String? _nearestNode(
    FloorGraph graph,
    Offset norm, {
    required bool walkOnly,
  }) {
    double best = double.infinity;
    String? bestId;
    for (final entry in graph.normPos.entries) {
      if (walkOnly && !graph.isWalkNode(entry.key)) continue;
      final d = (entry.value - norm).distanceSquared;
      if (d < best) {
        best = d;
        bestId = entry.key;
      }
    }
    return bestId;
  }

  String? _nearestRoom(FloorGraph graph, Offset norm) {
    double best = double.infinity;
    String? bestId;
    for (final room in graph.rooms) {
      final doorId = _doorNodeIdForRoom(graph, room);
      final p =
          (doorId == null ? null : _nodeNorm(graph, doorId)) ??
          graph.normPos[room.id];
      if (p == null) continue;
      final d = (p - norm).distanceSquared;
      if (d < best) {
        best = d;
        bestId = room.id;
      }
    }
    return bestId;
  }

  void _setDefaultStart() {
    final graph = _graphForFloor();
    final entrances = graph.landmarks
        .where((e) => e.type == 'entrance')
        .toList();
    final start = entrances.isNotEmpty
        ? entrances.first
        : (graph.landmarks.isNotEmpty ? graph.landmarks.first : null);
    _startNodeId = start?.id;
    _myNodeId = null;
    _myImagePos = start == null ? null : _nodeImagePos(graph, start.id);
    _cameraAnchorImagePos = _myImagePos;
    _mapRotationRadians = 0.0;
    _fromLabel = start == null
        ? t('not_set')
        : '${_floorLabel()} @ ${_landmarkDisplay(start)}';
  }

  void _setDefaultDestination({bool clearRoute = false}) {
    final list = _filteredRooms();
    final graph = _graphForFloor();
    if (list.isEmpty) {
      _selectedRoomId = null;
      _destImagePos = null;
      _toLabel = t('not_set');
      if (clearRoute) _clearRoute();
      return;
    }

    if (_selectedRoomId != null && list.any((r) => r.id == _selectedRoomId)) {
      final room = list.firstWhere((r) => r.id == _selectedRoomId);
      final destId = _doorNodeIdForRoom(graph, room) ?? room.id;
      _destImagePos = _nodeImagePos(graph, destId);
      _toLabel = _placeDisplay(room, t);
      if (clearRoute) _clearRoute();
      return;
    }

    _selectedRoomId = list.first.id;
    final destId = _doorNodeIdForRoom(graph, list.first) ?? list.first.id;
    _destImagePos = _nodeImagePos(graph, destId);
    _toLabel = _placeDisplay(list.first, t);
    if (clearRoute) _clearRoute();
  }

  void _setStatus(String key, bool ok, {Map<String, String> args = const {}}) {
    _statusKey = key;
    _statusArgs = args;
    _statusOk = ok;
  }

  void _clearRoute() {
    _routeImage = [];
    _steps = [];
    _distance = null;
    _turns = null;
    _lastPath = [];
    _lastPathFloorId = null;
    _mapRotationRadians = 0.0;
    _cameraAnchorImagePos = _myImagePos;
  }

  String _autoNodeId(NodeKind kind) {
    final floorId = _navFloorId();
    final nodes = _navNodes(floorId);
    final prefix = switch (kind) {
      NodeKind.corridor => '${floorId}_COR_',
      NodeKind.junction => '${floorId}_JUNC_',
      NodeKind.entrance => '${floorId}_ENT_',
      NodeKind.stairs => '${floorId}_STAIR_',
    };
    var index = 1;
    while (nodes.containsKey('$prefix$index')) {
      index++;
    }
    return '$prefix$index';
  }

  double _navDistance(String fromId, String toId, String floorId) {
    final a = _navPointForNodeId(fromId, floorId);
    final b = _navPointForNodeId(toId, floorId);
    if (a == null || b == null) return 1.0;
    return (a - b).distance;
  }

  void _recomputeEdgeDistances(String floorId) {
    final edges = _navEdges(floorId);
    for (final raw in edges) {
      if (raw is! Map<String, dynamic>) continue;
      final from = raw['from'] as String?;
      final to = raw['to'] as String?;
      if (from == null || to == null) continue;
      raw['distance'] = _navDistance(from, to, floorId);
    }
  }

  void _addEdge(String fromId, String toId, String floorId) {
    final edges = _navEdges(floorId);
    final exists = edges.any((raw) {
      if (raw is! Map<String, dynamic>) return false;
      final a = raw['from'];
      final b = raw['to'];
      return (a == fromId && b == toId) || (a == toId && b == fromId);
    });
    if (exists) return;
    edges.add({
      'from': fromId,
      'to': toId,
      'distance': _navDistance(fromId, toId, floorId),
    });
  }

  void _deleteNode(String id, String floorId) {
    final nodes = _navNodes(floorId);
    final doors = _navDoors(floorId);
    final rooms = _navRooms(floorId);
    final roomId = _roomIdFromLabelHandle(id);
    var removedDoorId = '';
    if (roomId != null) {
      final room = rooms.remove(roomId) as Map<String, dynamic>?;
      final doorId = room == null ? null : (room['doorId'] as String?);
      if (doorId != null && doors.containsKey(doorId)) {
        doors.remove(doorId);
        removedDoorId = doorId;
      }
    } else if (nodes.containsKey(id)) {
      nodes.remove(id);
    } else if (doors.containsKey(id)) {
      final door = doors.remove(id) as Map<String, dynamic>?;
      final doorRoomId = door == null ? null : (door['roomId'] as String?);
      if (doorRoomId != null && rooms.containsKey(doorRoomId)) {
        final room = rooms[doorRoomId] as Map<String, dynamic>?;
        if (room != null && room['doorId'] == id) {
          room.remove('doorId');
        }
      }
    }
    final edges = _navEdges(floorId);
    edges.removeWhere((raw) {
      if (raw is! Map<String, dynamic>) return false;
      return raw['from'] == id ||
          raw['to'] == id ||
          (removedDoorId.isNotEmpty &&
              (raw['from'] == removedDoorId || raw['to'] == removedDoorId));
    });
  }

  List<_EditorNode> _editorNodesForFloor({
    required bool includeDoors,
    required bool includeLabels,
  }) {
    if (!_editMode || _navGraph == null) return const [];
    final floorId = _navFloorId();
    final bounds = _boundsForFloor();
    final nodes = _navNodes(floorId);
    final list = <_EditorNode>[];
    nodes.forEach((id, raw) {
      if (raw is! Map<String, dynamic>) return;
      final x = (raw['x'] as num?)?.toDouble();
      final y = (raw['y'] as num?)?.toDouble();
      if (x == null || y == null) return;
      final norm = Offset(x / _navWidth, y / _navHeight);
      final img = _normToImage(norm, bounds);
      list.add(
        _EditorNode(
          id: id,
          kind: (raw['kind'] as String?) ?? 'corridor',
          imagePos: img,
          label: id,
        ),
      );
    });
    if (includeDoors) {
      final doors = _navDoors(floorId);
      doors.forEach((id, raw) {
        if (raw is! Map<String, dynamic>) return;
        final point = raw['point'] as Map<String, dynamic>?;
        if (point == null) return;
        final x = (point['x'] as num?)?.toDouble();
        final y = (point['y'] as num?)?.toDouble();
        if (x == null || y == null) return;
        final norm = Offset(x / _navWidth, y / _navHeight);
        final img = _normToImage(norm, bounds);
        list.add(_EditorNode(id: id, kind: 'door', imagePos: img, label: id));
      });
    }
    if (includeLabels) {
      final graphRooms = {
        for (final room in _graphForFloor().rooms) room.id: room,
      };
      final rooms = _navRooms(floorId);
      for (final room in graphRooms.values) {
        if (!facilityByType.containsKey(room.type)) continue;
        Offset? norm;
        final raw = rooms[room.id];
        if (raw is Map<String, dynamic>) {
          norm = _normFromPoint(
            raw['labelPoint'] as Map<String, dynamic>?,
            _navWidth,
            _navHeight,
          );
        }
        norm ??= room.norm;
        if (norm == null) continue;
        final img = _normToImage(norm, bounds);
        list.add(
          _EditorNode(
            id: _labelHandleId(room.id),
            kind: 'label',
            imagePos: img,
            label: _localizedPlaceLabel(room, t),
          ),
        );
      }
    }
    return list;
  }

  List<_EditorEdge> _editorEdgesForFloor(Map<String, Offset> nodeIndex) {
    if (!_editMode || _navGraph == null) return const [];
    final floorId = _navFloorId();
    final edges = _navEdges(floorId);
    final list = <_EditorEdge>[];
    for (final raw in edges) {
      if (raw is! Map<String, dynamic>) continue;
      final from = raw['from'] as String?;
      final to = raw['to'] as String?;
      if (from == null || to == null) continue;
      final a = nodeIndex[from];
      final b = nodeIndex[to];
      if (a == null || b == null) continue;
      list.add(_EditorEdge(from: a, to: b));
    }
    return list;
  }

  String? _nearestEditorNodeId(
    Offset imagePos, {
    bool includeDoors = true,
    bool includeLabels = true,
    double maxPx = 80,
  }) {
    final nodes = _editorNodesForFloor(
      includeDoors: includeDoors,
      includeLabels: includeLabels,
    );
    var best = maxPx * maxPx;
    String? bestId;
    for (final node in nodes) {
      if (!includeDoors && node.kind == 'door') continue;
      if (!includeLabels && node.kind == 'label') continue;
      final d = (node.imagePos - imagePos).distanceSquared;
      if (d < best) {
        best = d;
        bestId = node.id;
      }
    }
    return bestId;
  }

  bool _canDragNodes() =>
      _editMode && _dragNodes && _editAction == EditAction.moveNode;

  bool _updateNodePosition(String id, Offset imagePos) {
    if (_navGraph == null) return false;
    final floorId = _navFloorId();
    final navPos = _navCoordFromImage(imagePos);
    final roomId = _roomIdFromLabelHandle(id);
    if (roomId != null) {
      final rooms = _navRooms(floorId);
      rooms.putIfAbsent(
        roomId,
        () => <String, dynamic>{'id': roomId, 'floor': floorId},
      );
      final room = rooms[roomId] as Map<String, dynamic>;
      room['labelPoint'] = {'x': navPos.dx, 'y': navPos.dy};
      return true;
    }
    final nodes = _navNodes(floorId);
    final doors = _navDoors(floorId);
    if (nodes.containsKey(id)) {
      final node = nodes[id] as Map<String, dynamic>;
      node['x'] = navPos.dx;
      node['y'] = navPos.dy;
      return true;
    }
    if (doors.containsKey(id)) {
      final door = doors[id] as Map<String, dynamic>;
      door['point'] = {'x': navPos.dx, 'y': navPos.dy};
      return true;
    }
    return false;
  }

  void _handleEditNodeDragStart(String id, Offset imagePos) {
    if (!_canDragNodes()) return;
    final bounds = _boundsForFloor();
    if (!bounds.contains(imagePos)) {
      setState(() {
        _setStatus('status_tap_inside_bounds', false);
      });
      return;
    }
    if (!_updateNodePosition(id, imagePos)) return;
    setState(() {
      _dragNodeId = id;
      _selectedNodeId = id;
      _setStatus('status_dragging', true, args: {'id': _editorDisplayId(id)});
    });
  }

  void _handleEditNodeDragUpdate(String id, Offset imagePos) {
    if (_dragNodeId != id) return;
    final bounds = _boundsForFloor();
    if (!bounds.contains(imagePos)) return;
    if (!_updateNodePosition(id, imagePos)) return;
    setState(() {});
  }

  void _handleEditNodeDragEnd(String id) {
    if (_dragNodeId != id) return;
    _dragNodeId = null;
    if (_roomIdFromLabelHandle(id) == null) {
      _recomputeEdgeDistances(_navFloorId());
    }
    _applyNavGraph();
  }

  void _handleEditTap(Offset imagePos) {
    if (_navGraph == null) {
      setState(() {
        _setStatus('status_nav_graph_not_loaded', false);
      });
      return;
    }
    final bounds = _boundsForFloor();
    if (!bounds.contains(imagePos)) {
      setState(() {
        _setStatus('status_tap_inside_bounds', false);
      });
      return;
    }
    final floorId = _navFloorId();
    final navPos = _navCoordFromImage(imagePos);

    switch (_editAction) {
      case EditAction.addNode:
        final id = _editNodeId.trim().isEmpty
            ? _autoNodeId(_editNodeKind)
            : _editNodeId.trim();
        final nodes = _navNodes(floorId);
        nodes[id] = {
          'id': id,
          'x': navPos.dx,
          'y': navPos.dy,
          'kind': _nodeKindValue(_editNodeKind),
        };
        _editNodeId = '';
        _selectedNodeId = id;
        _applyNavGraph();
        break;
      case EditAction.selectNode:
        final id = _nearestEditorNodeId(imagePos);
        setState(() {
          _selectedNodeId = id;
          _setStatus(
            id == null ? 'status_no_node_nearby' : 'status_selected',
            id != null,
            args: id == null ? const {} : {'id': _editorDisplayId(id)},
          );
        });
        break;
      case EditAction.moveNode:
        final targetId = _selectedNodeId ?? _nearestEditorNodeId(imagePos);
        setState(() {
          _selectedNodeId = targetId;
          _setStatus(
            targetId == null ? 'status_no_node_nearby' : 'status_selected_drag',
            targetId != null,
            args: targetId == null
                ? const {}
                : {'id': _editorDisplayId(targetId)},
          );
        });
        break;
      case EditAction.connect:
        if (_pendingEdgeFrom == null) {
          final fromId =
              _selectedEditorId(includeDoors: false, includeLabels: false) ??
              _nearestEditorNodeId(
                imagePos,
                includeDoors: false,
                includeLabels: false,
              );
          if (fromId == null) {
            setState(() {
              _setStatus('status_select_corridor_start', false);
            });
            return;
          }
          setState(() {
            _pendingEdgeFrom = fromId;
            _setStatus('status_select_target_node', true);
          });
          return;
        }
        final toId =
            _selectedEditorId(includeDoors: false, includeLabels: false) ??
            _nearestEditorNodeId(
              imagePos,
              includeDoors: false,
              includeLabels: false,
            );
        if (toId == null || toId == _pendingEdgeFrom) {
          setState(() {
            _setStatus('status_select_different_target', false);
          });
          return;
        }
        _addEdge(_pendingEdgeFrom!, toId, floorId);
        if (_chainConnect) {
          _pendingEdgeFrom = toId;
          _setStatus('status_connected_continue', true);
        } else {
          _pendingEdgeFrom = null;
        }
        _applyNavGraph();
        break;
      case EditAction.drawPath:
        final nearest = _nearestEditorNodeId(
          imagePos,
          includeDoors: false,
          includeLabels: false,
          maxPx: 50,
        );
        if (nearest != null) {
          if (_pathCursorId != null && nearest != _pathCursorId) {
            _addEdge(_pathCursorId!, nearest, floorId);
          }
          _pathCursorId = nearest;
          _selectedNodeId = nearest;
          _applyNavGraph();
          break;
        }
        final id = _autoNodeId(NodeKind.corridor);
        final nodes = _navNodes(floorId);
        nodes[id] = {
          'id': id,
          'x': navPos.dx,
          'y': navPos.dy,
          'kind': 'corridor',
        };
        if (_pathCursorId != null) {
          _addEdge(_pathCursorId!, id, floorId);
        }
        _pathCursorId = id;
        _selectedNodeId = id;
        _applyNavGraph();
        break;
      case EditAction.deleteNode:
        final targetId = _nearestEditorNodeId(imagePos) ?? _selectedEditorId();
        if (targetId == null) {
          setState(() {
            _setStatus('status_no_node_nearby', false);
          });
          return;
        }
        final deletedRoomId = _roomIdFromLabelHandle(targetId);
        _deleteNode(targetId, floorId);
        if (_selectedNodeId == targetId) _selectedNodeId = null;
        if (_pendingEdgeFrom == targetId) _pendingEdgeFrom = null;
        if (deletedRoomId != null) {
          if (_selectedRoomId == deletedRoomId) _selectedRoomId = null;
          if (_editorRoomId == deletedRoomId) _editorRoomId = null;
        }
        _applyNavGraph();
        break;
      case EditAction.addDoor:
        final roomId = (_editorRoomId ?? _selectedRoomId)?.trim();
        if (roomId == null || roomId.isEmpty) {
          setState(() {
            _setStatus('status_choose_room_first', false);
          });
          return;
        }
        final nodes = _navNodes(floorId);
        String? corridorId = _selectedEditorId(
          includeDoors: false,
          includeLabels: false,
        );
        if (corridorId == null || !nodes.containsKey(corridorId)) {
          corridorId = _nearestEditorNodeId(
            imagePos,
            includeDoors: false,
            includeLabels: false,
          );
        }
        if (corridorId == null || !nodes.containsKey(corridorId)) {
          setState(() {
            _setStatus('status_select_corridor_first', false);
          });
          return;
        }
        final doorId = 'D_$roomId';
        final doors = _navDoors(floorId);
        doors[doorId] = {
          'id': doorId,
          'roomId': roomId,
          'corridorNodeId': corridorId,
          'point': {'x': navPos.dx, 'y': navPos.dy},
        };
        final rooms = _navRooms(floorId);
        rooms.putIfAbsent(
          roomId,
          () => <String, dynamic>{'id': roomId, 'floor': floorId},
        );
        final room = rooms[roomId] as Map<String, dynamic>;
        room['doorId'] = doorId;
        room['labelPoint'] ??= _defaultLabelPointForDoor(
          floorId: floorId,
          corridorId: corridorId,
          doorPoint: navPos,
        );
        _addEdge(corridorId, doorId, floorId);
        _selectedNodeId = doorId;
        _applyNavGraph();
        break;
      case EditAction.none:
        break;
    }
  }

  Future<void> _copyNavGraph() async {
    if (_navGraph == null) {
      setState(() {
        _setStatus('status_nav_graph_not_loaded', false);
      });
      return;
    }
    final encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(_navGraph);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() {
      _setStatus('status_graph_json_copied', true);
    });
  }

  String _floorLabel() =>
      _floor == FloorKind.ff ? t('floor_ff') : t('floor_gf');

  String _modeLabel() => _mode == SetMode.my ? t('mode_my') : t('mode_dest');

  void _setMode(SetMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _setStatus(
        _mode == SetMode.my
            ? 'status_tap_map_set_my'
            : 'status_tap_map_set_dest',
        false,
      );
    });
  }

  Widget _pinModeButton({
    required SetMode mode,
    required IconData icon,
    required String label,
  }) {
    final selected = _mode == mode;
    return Expanded(
      child: FilledButton.icon(
        onPressed: () => _setMode(mode),
        icon: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? const Color(0xFF0A3E86)
              : const Color(0xFFE6EEF9),
          foregroundColor: selected ? Colors.white : const Color(0xFF0A3E86),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String? _resolveStartRouteNode(
    FloorGraph graph,
    String? startId,
    Offset startNorm,
  ) {
    if (startId != null) {
      if (_isCorridorNodeId(graph, startId)) return startId;
      final neighbors = graph.adj[startId] ?? const <EdgeLink>[];
      String? bestId;
      var bestDistance = double.infinity;
      for (final edge in neighbors) {
        if (!_isCorridorNodeId(graph, edge.to)) continue;
        if (_nodeNorm(graph, edge.to) == null) continue;
        if (edge.distance < bestDistance) {
          bestDistance = edge.distance;
          bestId = edge.to;
        }
      }
      if (bestId != null) return bestId;
    }
    return _nearestCorridorNode(graph, startNorm);
  }

  double _routeHeadingRotation(List<Offset> route) {
    if (route.length < 2) return 0.0;
    for (var i = 0; i < route.length - 1; i++) {
      final a = route[i];
      final b = route[i + 1];
      if ((b - a).distanceSquared < 1e-6) continue;
      return (-math.pi / 2) - math.atan2(b.dy - a.dy, b.dx - a.dx);
    }
    return 0.0;
  }

  void _switchFloor(FloorKind floor) {
    setState(() {
      _floor = floor;
      _myNodeId = null;
      _myImagePos = null;
      _destImagePos = null;
      _fromLabel = t('not_set');
      _toLabel = t('not_set');
      _searchQuery = '';
      _selectedRoomId = null;
      _clearRoute();
      _setStatus('status_waiting', false);
      _mode = SetMode.my;
      _setDefaultStart();
      _setDefaultDestination();
    });
  }

  void _handleMapTapImage(Offset imagePos) {
    if (_editMode) {
      _handleEditTap(imagePos);
      return;
    }
    if (_pickCoords) {
      return;
    }
    final bounds = _boundsForFloor();
    if (!bounds.contains(imagePos)) {
      setState(() {
        _setStatus('status_tap_inside_bounds', false);
      });
      return;
    }
    final norm = Offset(
      (imagePos.dx - bounds.left) / bounds.width,
      (imagePos.dy - bounds.top) / bounds.height,
    );
    final graph = _graphForFloor();
    setState(() {
      if (_mode == SetMode.my) {
        final nodeId = _nearestNode(graph, norm, walkOnly: true);
        if (nodeId == null) {
          _setStatus('status_no_nearby_corridor', false);
          return;
        }
        _myNodeId = nodeId;
        _myImagePos = _nodeImagePos(graph, nodeId);
        _cameraAnchorImagePos = _myImagePos;
        _fromLabel = '${_floorLabel()} @ ${_displayNodeLabel(nodeId, graph)}';
        _setStatus('status_my_location_set', true);
      } else {
        final roomId = _nearestRoom(graph, norm);
        if (roomId == null) {
          _setStatus('status_no_nearby_room', false);
          return;
        }
        _selectedRoomId = roomId;
        final room = graph.rooms.firstWhere((r) => r.id == roomId);
        final destId = _doorNodeIdForRoom(graph, room) ?? room.id;
        _destImagePos = _nodeImagePos(graph, destId);
        _toLabel = _placeDisplay(room, t);
        _setStatus('status_destination_set', true);
      }
      _clearRoute();
    });
  }

  Future<void> _handlePickImage(Offset imagePos) async {
    if (!_pickCoords) return;
    final x = imagePos.dx.round();
    final y = imagePos.dy.round();
    final bounds = _boundsForFloor();
    final nx = ((imagePos.dx - bounds.left) / bounds.width).clamp(0.0, 1.0);
    final ny = ((imagePos.dy - bounds.top) / bounds.height).clamp(0.0, 1.0);
    final graph = _graphForFloor();
    final roomId = _selectedRoomId;
    final room = roomId == null ? null : _roomById(roomId);
    final doorId = room == null ? null : _doorNodeIdForRoom(graph, room);
    final manualId = _pickTargetId.trim();
    final targetId = manualId.isNotEmpty
        ? manualId
        : (doorId ?? roomId ?? (_mode == SetMode.my ? _startNodeId : null));
    final text = targetId == null
        ? 'norm(${nx.toStringAsFixed(3)},${ny.toStringAsFixed(3)}) img($x,$y)'
        : '{ "id": "$targetId", "x": ${nx.toStringAsFixed(3)}, "y": ${ny.toStringAsFixed(3)} }';
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _lastImageCoord = Offset(x.toDouble(), y.toDouble());
      _lastNormCoord = Offset(nx, ny);
      if (targetId != null) {
        _manualNorm[targetId] = Offset(nx, ny);
        if (doorId != null || roomId != null) {
          _destImagePos = _normToImage(_manualNorm[targetId]!, bounds);
        } else if (_mode == SetMode.my && _startNodeId == targetId) {
          _myImagePos = _normToImage(_manualNorm[targetId]!, bounds);
        }
        _setStatus('status_saved_coord_copied', true, args: {'id': targetId});
      } else {
        _setStatus('status_copied_text', true, args: {'text': text});
      }
    });
  }

  void _selectRoom(String id) {
    final room = _roomsForFloor().firstWhere((r) => r.id == id);
    setState(() {
      _selectedRoomId = id;
      final graph = _graphForFloor();
      final destId = _doorNodeIdForRoom(graph, room) ?? room.id;
      _destImagePos = _nodeImagePos(graph, destId);
      _toLabel = _placeDisplay(room, t);
      _clearRoute();
      _setStatus('status_destination_selected', true);
    });
  }

  void _toggleMode() {
    _setMode(_mode == SetMode.my ? SetMode.dest : SetMode.my);
  }

  void _toggleLanguage() {
    final next = _isArabic ? const Locale('en') : const Locale('ar');
    widget.onLocaleChanged(next);
  }

  void _openAdminPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _AdminPanelPage(controller: this)),
    );
  }

  void _openAdminGate() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t('admin_panel')),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: t('admin_password'),
              hintText: t('admin_hint'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('admin_cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final password = controller.text.trim();
                Navigator.of(dialogContext).pop();
                if (password == '1234') {
                  _openAdminPage();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('admin_wrong_password'))),
                );
              },
              child: Text(t('admin_open')),
            ),
          ],
        );
      },
    );
  }

  void _reset() {
    setState(() {
      _myNodeId = null;
      _myImagePos = null;
      _destImagePos = null;
      _fromLabel = t('not_set');
      _toLabel = t('not_set');
      _clearRoute();
      _setStatus('status_waiting', false);
      _mode = SetMode.my;
      _setDefaultStart();
      _setDefaultDestination();
    });
  }

  void _buildRoute() {
    final graph = _graphForFloor();
    final bounds = _boundsForFloor();
    final startId = _myNodeId ?? _startNodeId;
    final roomId = _selectedRoomId;
    if (startId == null || roomId == null) {
      setState(() {
        _setStatus('status_set_my_and_dest_first', false);
      });
      return;
    }

    final startNorm = _myImagePos != null
        ? _imageToNorm(_myImagePos!, bounds)
        : _nodeNorm(graph, startId);
    if (startNorm == null) {
      setState(() {
        _setStatus('status_start_missing_coords', false);
      });
      return;
    }

    final room = _roomById(roomId);
    if (room == null) {
      setState(() {
        _setStatus('status_destination_room_not_found', false);
      });
      return;
    }

    final doorId = _doorNodeIdForRoom(graph, room);
    final doorNorm =
        (doorId == null ? null : _nodeNorm(graph, doorId)) ?? room.norm;
    if (doorNorm == null) {
      setState(() {
        _setStatus('status_door_point_missing_coords', false);
      });
      return;
    }

    final startNode = _nearestCorridorNode(graph, startNorm);
    String? destNode;
    if (doorId != null) {
      final corridorId = _doorCorridorNodeId(_navFloorId(), doorId);
      if (corridorId != null &&
          _isCorridorNodeId(graph, corridorId) &&
          _nodeNorm(graph, corridorId) != null) {
        destNode = corridorId;
      }
    }
    destNode ??= _nearestCorridorNode(graph, doorNorm);
    if (startNode == null || destNode == null) {
      setState(() {
        _setStatus('status_corridor_nodes_missing_coords', false);
      });
      return;
    }

    final path = startNode == destNode
        ? <String>[startNode]
        : dijkstra(graph, startNode, destNode);
    if (path == null || path.isEmpty) {
      setState(() {
        _setStatus('status_no_route_found', false);
      });
      return;
    }

    final info = _buildStepsFromPath(path, graph);
    final imageRoute = <Offset>[];
    for (final id in path) {
      final norm = _nodeNorm(graph, id);
      if (norm == null) continue;
      imageRoute.add(_normToImage(norm, bounds));
    }
    imageRoute.add(_normToImage(doorNorm, bounds));

    setState(() {
      _routeImage = imageRoute;
      _steps = info.steps;
      _distance = info.distance;
      _turns = info.turns;
      _lastPath = path;
      _lastPathFloorId = _floorKey();
      final startSnap = _nodeNorm(graph, startNode);
      _myImagePos = startSnap == null
          ? _myImagePos
          : _normToImage(startSnap, bounds);
      _cameraAnchorImagePos = _myImagePos;
      _destImagePos = _normToImage(doorNorm, bounds);
      _mapRotationRadians = _routeHeadingRotation(imageRoute);
      _setStatus('status_route_ready', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 980;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildMapCard(showHeader: false),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(width: 340, child: _buildUserPanel()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMapCard(showHeader: false),
                              const SizedBox(height: 12),
                              _buildUserPanel(),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B4AA2), Color(0xFF0A3E86)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22020617),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _headerIconButton(
            icon: Icons.language,
            tooltip: _isArabic ? t('lang_english') : t('lang_arabic'),
            badge: _isArabic ? 'EN' : 'AR',
            onTap: _toggleLanguage,
          ),
          const SizedBox(width: 8),
          _headerIconButton(
            icon: Icons.admin_panel_settings,
            tooltip: t('admin_panel'),
            onTap: _openAdminGate,
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard({bool showHeader = true}) {
    final mapImage = _floor == FloorKind.ff ? _ffImage : _gfImage;
    final mapBounds = _floor == FloorKind.ff ? ffBounds : gfBounds;
    final mapTitle = _floor == FloorKind.ff
        ? t('map_title_ff')
        : t('map_title_gf');
    final textDirection = Directionality.of(context);
    final graph = _graphForFloor();
    final facilityMarkers = _facilityMarkersForFloor(graph, mapBounds);
    final editorNodes = _editMode
        ? _editorNodesForFloor(includeDoors: true, includeLabels: true)
        : const <_EditorNode>[];
    final nodeIndex = {for (final node in editorNodes) node.id: node.imagePos};
    final editorEdges = _editMode
        ? _editorEdgesForFloor(nodeIndex)
        : const <_EditorEdge>[];
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B4AA2), Color(0xFF0A3E86)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _pill(_floorLabel()),
                  _pill(tr('mode_with_value', args: {'mode': _modeLabel()})),
                  const SizedBox(width: 8),
                  _tabButton(
                    'FF',
                    _floor == FloorKind.ff,
                    () => _switchFloor(FloorKind.ff),
                  ),
                  _tabButton(
                    'GF',
                    _floor == FloorKind.gf,
                    () => _switchFloor(FloorKind.gf),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _MapView(
              routeImage: _routeImage,
              myImagePos: _myImagePos,
              destImagePos: _destImagePos,
              floor: _floor,
              mapImage: mapImage,
              mapBounds: mapBounds,
              facilityMarkers: facilityMarkers,
              editorNodes: editorNodes,
              editorEdges: editorEdges,
              selectedNodeId: _selectedNodeId,
              pendingEdgeFrom: _pendingEdgeFrom,
              showEditor: _editMode,
              enableNodeDrag: _canDragNodes(),
              mapTitle: mapTitle,
              textDirection: textDirection,
              cameraAnchorImagePos: _cameraAnchorImagePos,
              rotationRadians: _mapRotationRadians,
              onTapImage: _handleMapTapImage,
              onPickImage: _handlePickImage,
              onDragNodeStart: _handleEditNodeDragStart,
              onDragNodeUpdate: _handleEditNodeDragUpdate,
              onDragNodeEnd: _handleEditNodeDragEnd,
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FBFF),
        border: Border(top: BorderSide(color: Color(0x11020617))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _LegendItem(color: const Color(0xFF2563EB), label: t('legend_my')),
          _LegendItem(color: const Color(0xFFF97316), label: t('legend_dest')),
          _LegendItem(color: const Color(0xFF16A34A), label: t('legend_route')),
        ],
      ),
    );
  }

  Widget _buildUserPanel() {
    final rooms = _filteredRooms();
    final graph = _graphForFloor();
    final entrances = graph.landmarks
        .where((e) => e.type == 'entrance')
        .toList();
    final startOptions = entrances.isNotEmpty ? entrances : graph.landmarks;
    final startValue = startOptions.any((e) => e.id == _startNodeId)
        ? _startNodeId
        : null;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _floorChip('GF', FloorKind.gf),
                const SizedBox(width: 6),
                _floorChip('FF', FloorKind.ff),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _pinModeButton(
                  mode: SetMode.my,
                  icon: Icons.my_location,
                  label: t('pin_my_place'),
                ),
                const SizedBox(width: 8),
                _pinModeButton(
                  mode: SetMode.dest,
                  icon: Icons.flag,
                  label: t('pin_destination'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t('tap_mode_hint'),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: startValue,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('start_location'),
                prefixIcon: const Icon(Icons.login),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              items: startOptions
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(
                        _landmarkDisplay(e),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _startNodeId = value;
                  _myNodeId = null;
                  _myImagePos = _nodeImagePos(graph, value);
                  _cameraAnchorImagePos = _myImagePos;
                  _fromLabel =
                      '${_floorLabel()} @ ${_displayNodeLabel(value, graph)}';
                  _clearRoute();
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: t('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _setDefaultDestination(clearRoute: true);
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedRoomId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('destination'),
                prefixIcon: const Icon(Icons.place),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              items: rooms
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        _placeDisplay(r, t),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                _selectRoom(value);
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _iconActionButton(
                  icon: Icons.alt_route,
                  label: t('show_route'),
                  color: const Color(0xFF1F6FEB),
                  onTap: _buildRoute,
                ),
                _iconActionButton(
                  icon: Icons.restart_alt,
                  label: t('reset'),
                  color: const Color(0xFF111827),
                  onTap: _reset,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  t('facility_filters'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Tooltip(
                  message: t('facility_clear_filters'),
                  child: IconButton(
                    onPressed: _clearFacilityFilters,
                    icon: const Icon(Icons.filter_alt_off),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facilityKinds.map(_facilityFilterChip).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              t('facility_nearest'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facilityKinds.map(_nearestFacilityButton).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _statBox(
                    t('distance'),
                    _distance == null ? '-' : _distance!.round().toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statBox(t('turns'), _turns?.toString() ?? '-'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Row(
                children: [
                  const Icon(Icons.directions),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t('turn_by_turn'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _statusBadge(),
                ],
              ),
              children: [
                if (_steps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      t('no_steps'),
                      style: const TextStyle(
                        color: Color(0xFF5B6B86),
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ..._steps.asMap().entries.map(
                    (entry) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x11020617)),
                        color: Colors.white,
                      ),
                      child: Text('${entry.key + 1}. ${entry.value}'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    final rooms = _filteredRooms();
    final graph = _graphForFloor();
    final entrances = graph.landmarks
        .where((e) => e.type == 'entrance')
        .toList();
    final startOptions = entrances.isNotEmpty ? entrances : graph.landmarks;
    final startValue = startOptions.any((e) => e.id == _startNodeId)
        ? _startNodeId
        : null;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t('start_entrance'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: startValue,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('start_location'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              items: startOptions
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(
                        _landmarkDisplay(e),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _startNodeId = value;
                  _myNodeId = null;
                  _myImagePos = _nodeImagePos(graph, value);
                  _fromLabel =
                      '${_floorLabel()} @ ${_displayNodeLabel(value, graph)}';
                  _clearRoute();
                });
              },
            ),
            const SizedBox(height: 12),
            Text(
              t('search_destination'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: t('search_hint'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _setDefaultDestination(clearRoute: true);
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRoomId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('destination'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              items: rooms
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        _placeDisplay(r, t),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                _selectRoom(value);
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _actionButton(
                  t('show_route'),
                  _buildRoute,
                  color: const Color(0xFF1F6FEB),
                ),
                _actionButton(
                  t('reset'),
                  _reset,
                  color: const Color(0xFF111827),
                ),
                _actionButton(
                  t('my_dest'),
                  _toggleMode,
                  color: const Color(0xFF0A3E86),
                ),
                _actionButton(
                  _pickCoords ? t('picking_coords') : t('pick_coords'),
                  () {
                    setState(() {
                      _pickCoords = !_pickCoords;
                      _setStatus(
                        _pickCoords
                            ? 'status_tap_map_save_coord'
                            : 'status_waiting',
                        _pickCoords,
                      );
                    });
                  },
                  color: _pickCoords
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF475569),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: t('pick_target_id'),
                hintText: t('pick_target_hint'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _pickTargetId = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('graph_editor'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Switch(
                  value: _editMode,
                  onChanged: (value) {
                    setState(() {
                      _editMode = value;
                      _editAction = EditAction.none;
                      _pendingEdgeFrom = null;
                      _pathCursorId = null;
                      _dragNodeId = null;
                      if (_editMode) {
                        _pickCoords = false;
                        _dragNodes = true;
                      } else {
                        _dragNodes = false;
                      }
                      _setStatus(
                        _editMode
                            ? 'status_edit_mode_on'
                            : 'status_edit_mode_off',
                        true,
                      );
                    });
                  },
                ),
              ],
            ),
            if (_editMode) ...[
              const SizedBox(height: 6),
              DropdownButtonFormField<NodeKind>(
                initialValue: _editNodeKind,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: t('new_node_type'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  isDense: true,
                ),
                items: NodeKind.values
                    .map(
                      (kind) => DropdownMenuItem(
                        value: kind,
                        child: Text(
                          t('node_${_nodeKindValue(kind)}'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _editNodeKind = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: t('new_node_id'),
                  hintText: t('new_node_hint'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _editNodeId = value.trim();
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t('drag_nodes_label'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Switch(
                    value: _dragNodes,
                    onChanged: (value) {
                      setState(() {
                        _dragNodes = value;
                        _dragNodeId = null;
                        _setStatus(
                          value
                              ? 'status_drag_nodes_enabled'
                              : 'status_drag_nodes_disabled',
                          true,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _actionButton(t('add_node'), () {
                    setState(() {
                      _editAction = EditAction.addNode;
                      _setStatus('status_tap_map_add_node', true);
                    });
                  }, color: const Color(0xFF1F6FEB)),
                  _actionButton(t('select'), () {
                    setState(() {
                      _editAction = EditAction.selectNode;
                      _setStatus('status_tap_node_select', true);
                    });
                  }, color: const Color(0xFF0F766E)),
                  _actionButton(t('move'), () {
                    setState(() {
                      _editAction = EditAction.moveNode;
                      _dragNodes = true;
                      _setStatus('status_drag_node_move', true);
                    });
                  }, color: const Color(0xFF7C3AED)),
                  _actionButton(t('connect'), () {
                    setState(() {
                      _editAction = EditAction.connect;
                      _pendingEdgeFrom = null;
                      _pathCursorId = null;
                      _setStatus('status_tap_start_then_target', true);
                    });
                  }, color: const Color(0xFF2563EB)),
                  _actionButton(t('draw_path'), () {
                    setState(() {
                      _editAction = EditAction.drawPath;
                      _pathCursorId = _selectedNodeId;
                      _pendingEdgeFrom = null;
                      _setStatus('status_tap_drop_nodes', true);
                    });
                  }, color: const Color(0xFF0EA5E9)),
                  _actionButton(t('delete'), () {
                    setState(() {
                      _editAction = EditAction.deleteNode;
                      _setStatus('status_tap_node_delete', true);
                    });
                  }, color: const Color(0xFFB91C1C)),
                ],
              ),
              if (_editMode && _editAction == EditAction.connect) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('chain_connect'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Switch(
                      value: _chainConnect,
                      onChanged: (value) {
                        setState(() {
                          _chainConnect = value;
                          _setStatus(
                            value
                                ? 'status_chain_connect_on'
                                : 'status_chain_connect_off',
                            true,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
              if (_editAction == EditAction.moveNode) ...[
                const SizedBox(height: 6),
                Text(
                  t('move_mode_hint'),
                  style: const TextStyle(
                    color: Color(0xFF5B6B86),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _editorRoomId ?? _selectedRoomId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: t('door_room'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  isDense: true,
                ),
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(
                          _placeDisplay(r, t),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _editorRoomId = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(
                  'room-type-${_editorRoomId ?? _selectedRoomId ?? "none"}-${_selectedEditableRoomType()}',
                ),
                initialValue: _selectedEditableRoomType(),
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: t('editor_room_type'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  isDense: true,
                ),
                items: _editableRoomTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type == 'unknown'
                              ? t('room_type_room')
                              : _localizedTypeLabel(type, t),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (_editorRoomId ?? _selectedRoomId) == null
                    ? null
                    : (value) {
                        if (value == null) return;
                        _setSelectedRoomType(value);
                      },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _actionButton(
                    t('create_room_door'),
                    _openCreateRoomDoorDialog,
                    color: const Color(0xFF7C3AED),
                  ),
                  _actionButton(t('add_door'), () {
                    setState(() {
                      _editAction = EditAction.addDoor;
                      _setStatus('status_tap_corridor_place_door', true);
                    });
                  }, color: const Color(0xFFF97316)),
                  _actionButton(
                    t('copy_graph_json'),
                    _copyNavGraph,
                    color: const Color(0xFF0F172A),
                  ),
                  _actionButton(t('clear_link'), () {
                    setState(() {
                      _pendingEdgeFrom = null;
                      _pathCursorId = null;
                      _setStatus('status_edge_selection_cleared', true);
                    });
                  }, color: const Color(0xFF475569)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${t('selected_label')}: ${_editorDisplayId(_selectedNodeId)}'
                '${_pendingEdgeFrom == null ? '' : ' | ${t('linking_from')}: ${_editorDisplayId(_pendingEdgeFrom)}'}'
                '${_pathCursorId == null ? '' : ' | ${t('path_from')}: $_pathCursorId'}',
                style: const TextStyle(color: Color(0xFF5B6B86), fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            _buildStats(),
            if (_lastImageCoord != null) ...[
              const SizedBox(height: 10),
              Text(
                _lastNormCoord == null
                    ? tr(
                        'last_map_coord',
                        args: {
                          'coord':
                              '(${_lastImageCoord!.dx.round()}, ${_lastImageCoord!.dy.round()})',
                        },
                      )
                    : tr(
                        'last_map_coord_norm',
                        args: {
                          'norm':
                              '${_lastNormCoord!.dx.toStringAsFixed(3)}, ${_lastNormCoord!.dy.toStringAsFixed(3)}',
                          'img':
                              '${_lastImageCoord!.dx.round()}, ${_lastImageCoord!.dy.round()}',
                        },
                      ),
                style: const TextStyle(color: Color(0xFF5B6B86), fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('turn_by_turn'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _statusBadge(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              t('compass_note'),
              style: const TextStyle(color: Color(0xFF5B6B86), fontSize: 11),
            ),
            const SizedBox(height: 8),
            if (_steps.isEmpty)
              Text(
                t('no_steps'),
                style: const TextStyle(color: Color(0xFF5B6B86), fontSize: 12),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x11020617)),
                        color: Colors.white,
                      ),
                      child: Text('${i + 1}. ${_steps[i]}'),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              t('editor_hint'),
              style: const TextStyle(color: Color(0xFF5B6B86), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statBox(t('from'), _fromLabel)),
            const SizedBox(width: 10),
            Expanded(child: _statBox(t('to'), _toLabel)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statBox(
                t('distance'),
                _distance == null ? '-' : _distance!.round().toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _statBox(t('turns'), _turns?.toString() ?? '-')),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge() {
    final color = _statusOk ? const Color(0xFF166534) : const Color(0xFF92400E);
    final bg = _statusOk ? const Color(0x1E16A34A) : const Color(0x1ED97706);
    final label = tr(_statusKey, args: _statusArgs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11020617)),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF7FBFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5B6B86),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final fg = color;
    final bg = color.withValues(alpha: 0.12);
    final border = color.withValues(alpha: 0.45);
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: compact ? 56 : 88,
          padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _floorChip(String label, FloorKind floor) {
    final active = _floor == floor;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => _switchFloor(floor),
      selectedColor: const Color(0xFF1F6FEB),
      backgroundColor: const Color(0xFFE7EFFB),
      labelStyle: TextStyle(
        color: active ? Colors.white : const Color(0xFF1E293B),
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _facilityFilterChip(FacilityKind kind) {
    final active = _activeFacilityTypes.contains(kind.type);
    final color = kind.color;
    return Tooltip(
      message: t(kind.labelKey),
      child: InkWell(
        onTap: () => _toggleFacilityFilter(kind.type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : const Color(0x22020617)),
          ),
          child: Icon(
            kind.icon,
            color: active ? color : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _nearestFacilityButton(FacilityKind kind) {
    return Tooltip(
      message: t(kind.labelKey),
      child: InkWell(
        onTap: () => _selectNearestFacility(kind.type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kind.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kind.color.withValues(alpha: 0.5)),
          ),
          child: Icon(kind.icon, color: kind.color),
        ),
      ),
    );
  }

  Widget _actionButton(
    String text,
    VoidCallback onPressed, {
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: active
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white,
        foregroundColor: active ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _AdminPanelPage extends StatelessWidget {
  final _GuideHomePageState controller;

  const _AdminPanelPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 980;
    return ValueListenableBuilder<int>(
      valueListenable: controller._adminTick,
      builder: (context, _, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.t('admin_panel')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: controller._buildMapCard(),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 420,
                              child: controller._buildControlCard(),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            controller._buildMapCard(),
                            const SizedBox(height: 16),
                            controller._buildControlCard(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapView extends StatelessWidget {
  final List<Offset> routeImage;
  final Offset? myImagePos;
  final Offset? destImagePos;
  final FloorKind floor;
  final ui.Image? mapImage;
  final Rect mapBounds;
  final String mapTitle;
  final TextDirection textDirection;
  final Offset? cameraAnchorImagePos;
  final double rotationRadians;
  final List<FacilityMarker> facilityMarkers;
  final List<_EditorNode> editorNodes;
  final List<_EditorEdge> editorEdges;
  final String? selectedNodeId;
  final String? pendingEdgeFrom;
  final bool showEditor;
  final bool enableNodeDrag;
  final void Function(Offset imagePos)? onTapImage;
  final void Function(Offset imagePos)? onPickImage;
  final void Function(String id, Offset imagePos)? onDragNodeStart;
  final void Function(String id, Offset imagePos)? onDragNodeUpdate;
  final void Function(String id)? onDragNodeEnd;

  const _MapView({
    required this.routeImage,
    required this.myImagePos,
    required this.destImagePos,
    required this.floor,
    required this.mapImage,
    required this.mapBounds,
    required this.mapTitle,
    required this.textDirection,
    required this.cameraAnchorImagePos,
    required this.rotationRadians,
    required this.facilityMarkers,
    required this.editorNodes,
    required this.editorEdges,
    required this.selectedNodeId,
    required this.pendingEdgeFrom,
    required this.showEditor,
    required this.enableNodeDrag,
    this.onTapImage,
    this.onPickImage,
    this.onDragNodeStart,
    this.onDragNodeUpdate,
    this.onDragNodeEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (mapImage == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return AspectRatio(
      aspectRatio:
          (mapImage?.width.toDouble() ?? mapBounds.width) /
          (mapImage?.height.toDouble() ?? mapBounds.height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final transform = MapTransform.fromSize(
            size: size,
            imageSize: Size(
              mapImage?.width.toDouble() ?? mapBounds.width,
              mapImage?.height.toDouble() ?? mapBounds.height,
            ),
            rotationRadians: rotationRadians,
          );
          final handleSize = enableNodeDrag ? 48.0 : 32.0;
          final handles = <Widget>[];
          if (showEditor) {
            for (final node in editorNodes) {
              final center = transform.imageToScreen(node.imagePos);
              final topLeft = Offset(
                center.dx - handleSize / 2,
                center.dy - handleSize / 2,
              );
              final ringColor = enableNodeDrag
                  ? const Color(0xFF60A5FA).withValues(alpha: 0.25)
                  : const Color(0x00000000);
              handles.add(
                Positioned(
                  left: topLeft.dx,
                  top: topLeft.dy,
                  width: handleSize,
                  height: handleSize,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      final screenPos = topLeft + details.localPosition;
                      final imgPos = transform.screenToImage(screenPos);
                      onPickImage?.call(imgPos);
                      onTapImage?.call(imgPos);
                    },
                    onPanStart: enableNodeDrag
                        ? (details) {
                            final screenPos = topLeft + details.localPosition;
                            final imgPos = transform.screenToImage(screenPos);
                            onDragNodeStart?.call(node.id, imgPos);
                          }
                        : null,
                    onPanUpdate: enableNodeDrag
                        ? (details) {
                            final screenPos = topLeft + details.localPosition;
                            final imgPos = transform.screenToImage(screenPos);
                            onDragNodeUpdate?.call(node.id, imgPos);
                          }
                        : null,
                    onPanEnd: enableNodeDrag
                        ? (_) => onDragNodeEnd?.call(node.id)
                        : null,
                    onPanCancel: enableNodeDrag
                        ? () => onDragNodeEnd?.call(node.id)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor,
                          width: enableNodeDrag ? 2.0 : 0.0,
                        ),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          bool isNearEditorNode(Offset imgPos) {
            final threshold = (handleSize / transform.scale) * 0.65;
            final limit = threshold * threshold;
            for (final node in editorNodes) {
              final d = (node.imagePos - imgPos).distanceSquared;
              if (d <= limit) return true;
            }
            return false;
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final imgPos = transform.screenToImage(details.localPosition);
              if (showEditor && isNearEditorNode(imgPos)) return;
              onPickImage?.call(imgPos);
              onTapImage?.call(imgPos);
            },
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              boundaryMargin: const EdgeInsets.all(80),
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: size,
                      painter: _MapPainter(
                        routeImage: routeImage,
                        myImagePos: myImagePos,
                        destImagePos: destImagePos,
                        floor: floor,
                        mapImage: mapImage,
                        mapBounds: mapBounds,
                        transform: transform,
                        mapTitle: mapTitle,
                        textDirection: textDirection,
                        facilityMarkers: facilityMarkers,
                        editorNodes: editorNodes,
                        editorEdges: editorEdges,
                        selectedNodeId: selectedNodeId,
                        pendingEdgeFrom: pendingEdgeFrom,
                        showEditor: showEditor,
                      ),
                    ),
                    ...handles,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MapTransform {
  final double scale;
  final Size imageSize;
  final Offset focusImage;
  final Offset focusScreen;
  final double rotationRadians;

  MapTransform({
    required this.scale,
    required this.imageSize,
    required this.focusImage,
    required this.focusScreen,
    required this.rotationRadians,
  });

  factory MapTransform.fromSize({
    required Size size,
    required Size imageSize,
    Offset? focusImage,
    Offset? focusScreen,
    double rotationRadians = 0.0,
  }) {
    final cosTheta = math.cos(rotationRadians).abs();
    final sinTheta = math.sin(rotationRadians).abs();
    final rotatedWidth =
        imageSize.width * cosTheta + imageSize.height * sinTheta;
    final rotatedHeight =
        imageSize.width * sinTheta + imageSize.height * cosTheta;
    final scale = math.min(
      size.width / rotatedWidth,
      size.height / rotatedHeight,
    );
    return MapTransform(
      scale: scale,
      imageSize: imageSize,
      focusImage:
          focusImage ?? Offset(imageSize.width / 2, imageSize.height / 2),
      focusScreen: focusScreen ?? Offset(size.width / 2, size.height / 2),
      rotationRadians: rotationRadians,
    );
  }

  Offset _rotate(Offset p, double radians) {
    final c = math.cos(radians);
    final s = math.sin(radians);
    return Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);
  }

  Offset imageToScreen(Offset p) {
    final centered = Offset(
      (p.dx - focusImage.dx) * scale,
      (p.dy - focusImage.dy) * scale,
    );
    return focusScreen + _rotate(centered, rotationRadians);
  }

  Offset screenToImage(Offset p) {
    final centered = _rotate(p - focusScreen, -rotationRadians);
    return Offset(
      centered.dx / scale + focusImage.dx,
      centered.dy / scale + focusImage.dy,
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<Offset> routeImage;
  final Offset? myImagePos;
  final Offset? destImagePos;
  final FloorKind floor;
  final ui.Image? mapImage;
  final Rect mapBounds;
  final MapTransform transform;
  final String mapTitle;
  final TextDirection textDirection;
  final List<FacilityMarker> facilityMarkers;
  final List<_EditorNode> editorNodes;
  final List<_EditorEdge> editorEdges;
  final String? selectedNodeId;
  final String? pendingEdgeFrom;
  final bool showEditor;

  _MapPainter({
    required this.routeImage,
    required this.myImagePos,
    required this.destImagePos,
    required this.floor,
    required this.mapImage,
    required this.mapBounds,
    required this.transform,
    required this.mapTitle,
    required this.textDirection,
    required this.facilityMarkers,
    required this.editorNodes,
    required this.editorEdges,
    required this.selectedNodeId,
    required this.pendingEdgeFrom,
    required this.showEditor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = transform.scale;
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    if (mapImage != null) {
      canvas.save();
      canvas.translate(transform.focusScreen.dx, transform.focusScreen.dy);
      canvas.rotate(transform.rotationRadians);
      canvas.scale(transform.scale, transform.scale);
      canvas.translate(-transform.focusImage.dx, -transform.focusImage.dy);
      canvas.drawImage(mapImage!, Offset.zero, Paint());
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          mapImage!.width.toDouble(),
          mapImage!.height.toDouble(),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
      canvas.restore();
    }

    if (showEditor) {
      final edgePaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, 2.5 * scale);
      for (final edge in editorEdges) {
        final a = transform.imageToScreen(edge.from);
        final b = transform.imageToScreen(edge.to);
        canvas.drawLine(a, b, edgePaint);
      }

      Color nodeColor(String kind) {
        switch (kind) {
          case 'entrance':
            return const Color(0xFF22C55E);
          case 'stairs':
            return const Color(0xFFF59E0B);
          case 'junction':
            return const Color(0xFF8B5CF6);
          case 'door':
            return const Color(0xFFEF4444);
          case 'label':
            return const Color(0xFF0F172A);
          case 'corridor':
          default:
            return const Color(0xFF60A5FA);
        }
      }

      for (final node in editorNodes) {
        final pos = transform.imageToScreen(node.imagePos);
        final color = nodeColor(node.kind);
        final isSelected = node.id == selectedNodeId;
        final isPending = node.id == pendingEdgeFrom;
        final radius = isSelected
            ? math.max(4.0, 6.0 * scale)
            : math.max(3.0, 5.0 * scale);
        canvas.drawCircle(
          pos,
          radius + (isPending ? 3.0 * scale : 0.0),
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(pos, radius, Paint()..color = color);
        if (isSelected || isPending) {
          canvas.drawCircle(
            pos,
            radius + math.max(3.0, 5.0 * scale),
            Paint()
              ..color = color.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1.0, 2.0 * scale),
          );
        }
      }

      final selected = editorNodes
          .where((n) => n.id == selectedNodeId)
          .toList();
      if (selected.isNotEmpty) {
        final node = selected.first;
        final pos = transform.imageToScreen(node.imagePos);
        _drawText(
          canvas,
          text: node.kind == 'label' ? node.label : node.id,
          offset: Offset(pos.dx + 8 * scale, pos.dy - 12 * scale),
          color: const Color(0xFF111827).withValues(alpha: 0.9),
          size: math.max(10.0, 12.0 * scale),
          weight: FontWeight.w700,
          textDirection: TextDirection.ltr,
        );
      }
    }

    if (routeImage.isNotEmpty) {
      final path = Path();
      for (var i = 0; i < routeImage.length; i++) {
        final screen = transform.imageToScreen(routeImage[i]);
        if (i == 0) {
          path.moveTo(screen.dx, screen.dy);
        } else {
          path.lineTo(screen.dx, screen.dy);
        }
      }
      final routeOutline = Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(6.0, 14.0 * scale)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final routeGlow = Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(8.0, 20.0 * scale)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final routePaint = Paint()
        ..color = const Color(0xFF16A34A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3.0, 8.0 * scale)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, routeGlow);
      canvas.drawPath(path, routeOutline);
      canvas.drawPath(path, routePaint);
    }

    if (facilityMarkers.isNotEmpty) {
      for (final marker in facilityMarkers) {
        final pos = transform.imageToScreen(marker.imagePos);
        final radius = math.max(7.0, 11.0 * scale);
        canvas.drawCircle(
          pos,
          radius + math.max(2.0, 3.0 * scale),
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          pos,
          radius,
          Paint()..color = marker.color.withValues(alpha: 0.92),
        );
        _drawIcon(
          canvas,
          icon: marker.icon,
          offset: Offset(pos.dx - radius * 0.65, pos.dy - radius * 0.65),
          size: radius * 1.3,
          color: Colors.white,
        );
      }
    }

    if (destImagePos != null) {
      final screen = transform.imageToScreen(destImagePos!);
      final paint = Paint()..color = const Color(0xFFF97316);
      canvas.drawCircle(
        screen,
        math.max(7.0, 10.0 * scale),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(screen, math.max(5.0, 8.0 * scale), paint);
      _drawText(
        canvas,
        text: 'X',
        offset: Offset(screen.dx - 4 * scale, screen.dy - 6 * scale),
        color: Colors.white,
        size: math.max(10.0, 12.0 * scale),
        weight: FontWeight.w900,
      );
    }

    if (myImagePos != null) {
      final screen = transform.imageToScreen(myImagePos!);
      canvas.drawCircle(
        screen,
        math.max(9.0, 13.0 * scale),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        screen,
        math.max(8.0, 12.0 * scale),
        Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        screen,
        math.max(4.0, 6.0 * scale),
        Paint()..color = const Color(0xFF2563EB),
      );
    }

    final topLeft = transform.imageToScreen(Offset.zero);
    final topRight = transform.imageToScreen(
      Offset(mapImage?.width.toDouble() ?? transform.imageSize.width, 0),
    );
    final bottomLeft = transform.imageToScreen(
      Offset(0, mapImage?.height.toDouble() ?? transform.imageSize.height),
    );
    final frameRect = Rect.fromPoints(
      Offset(
        math.min(topLeft.dx, math.min(topRight.dx, bottomLeft.dx)),
        math.min(topLeft.dy, math.min(topRight.dy, bottomLeft.dy)),
      ),
      Offset(
        math.max(topLeft.dx, math.max(topRight.dx, bottomLeft.dx)),
        math.max(topLeft.dy, math.max(topRight.dy, bottomLeft.dy)),
      ),
    );
    final frame = RRect.fromRectAndRadius(
      frameRect.inflate(2),
      const Radius.circular(14),
    );
    final framePaint = Paint()
      ..color = const Color(0xFF0B1220).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, 2.0 * scale);
    canvas.drawRRect(frame, framePaint);

    final titleOrigin = transform.imageToScreen(
      Offset(
        mapBounds.left + mapBounds.width * (18 / 63),
        mapBounds.top + mapBounds.height * (6 / 63),
      ),
    );
    final titleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        titleOrigin.dx,
        titleOrigin.dy,
        mapBounds.width * (28 / 63) * scale,
        mapBounds.height * (5.5 / 63) * scale,
      ),
      const Radius.circular(16),
    );
    final titleBg = Paint()
      ..color = const Color(0xFF1F6FEB).withValues(alpha: 0.09);
    final titleStroke = Paint()
      ..color = const Color(0xFF1F6FEB).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(titleRect, titleBg);
    canvas.drawRRect(titleRect, titleStroke);
    _drawText(
      canvas,
      text: mapTitle,
      offset: titleOrigin + Offset(8 * scale, 8 * scale),
      color: const Color(0xFF111827).withValues(alpha: 0.75),
      size: math.max(10.0, 12.0 * scale),
      weight: FontWeight.w800,
    );
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required Offset offset,
    required Color color,
    required double size,
    required FontWeight weight,
    TextDirection? textDirection,
  }) {
    final span = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight),
    );
    final tp = TextPainter(
      text: span,
      textDirection: textDirection ?? this.textDirection,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  void _drawIcon(
    Canvas canvas, {
    required IconData icon,
    required Offset offset,
    required double size,
    required Color color,
  }) {
    final span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontWeight: FontWeight.w700,
      ),
    );
    final tp = TextPainter(text: span, textDirection: textDirection);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.routeImage != routeImage ||
        oldDelegate.myImagePos != myImagePos ||
        oldDelegate.destImagePos != destImagePos ||
        oldDelegate.floor != floor ||
        oldDelegate.mapImage != mapImage ||
        oldDelegate.mapBounds != mapBounds ||
        oldDelegate.transform != transform ||
        oldDelegate.mapTitle != mapTitle ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.facilityMarkers != facilityMarkers ||
        oldDelegate.editorNodes != editorNodes ||
        oldDelegate.editorEdges != editorEdges ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.pendingEdgeFrom != pendingEdgeFrom ||
        oldDelegate.showEditor != showEditor;
  }
}

class _EditorNode {
  final String id;
  final String kind;
  final Offset imagePos;
  final String label;

  const _EditorNode({
    required this.id,
    required this.kind,
    required this.imagePos,
    required this.label,
  });
}

class _EditorEdge {
  final Offset from;
  final Offset to;

  const _EditorEdge({required this.from, required this.to});
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF5B6B86)),
        ),
      ],
    );
  }
}

