import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:path/path.dart';
import 'package:io/ansi.dart' as ansi;
import 'package:quiver/iterables.dart';
import 'package:stack_trace/stack_trace.dart';

final _coreLibraryStyle = ansi.darkGray;

class StackTraceFormatter {
  StackTraceFormatter._(
    this._pkgNameToFileMap, {
    required this.useRelativePathsIfShorter,
  });

  final Map<String, Uri> _pkgNameToFileMap;
  final bool useRelativePathsIfShorter;

  static Future<StackTraceFormatter> create({
    Iterable<String> packageNamesToResolve = const [],
    bool useRelativePathsIfShorter = true,
  }) async {
    final entries = await Future.wait(
      packageNamesToResolve.map((pkgName) async {
        // This will resolve to the package's lib/ directory. Note that the
        // trailing slash is necessary to resolve successfully.
        final pkgUri = Uri.parse('package:$pkgName/');
        final fileUri = await Isolate.resolvePackageUri(pkgUri);
        if (fileUri == null) {
          throw ArgumentError(
              'stack_attack could not resolve $pkgUri to a file path');
        }
        return MapEntry(pkgName, fileUri);
      }),
      eagerError: true,
    );
    return StackTraceFormatter._(
      Map.fromEntries(entries),
      useRelativePathsIfShorter: useRelativePathsIfShorter,
    );
  }

  String format(StackTrace st) {
    return formatParsed(Trace.from(st));
  }

  String formatParsed(Trace trace) {
    final frames = trace.frames;
    final mappedLocations = _mapTraceLocations(trace);

    // Figure out the longest path so we know how much to pad
    var longest =
        mappedLocations.map((location) => location.length).fold(0, math.max);

    // Print out the stack trace nicely formatted
    return enumerate(frames).map((indexedFrame) {
      final i = indexedFrame.index;
      final frame = indexedFrame.value;

      if (frame is UnparsedFrame) return '$frame\n';

      final location = mappedLocations[i].padRight(longest);
      final frameStr = '$location   ${frame.member}\n';
      return frame.isCore ? _coreLibraryStyle.wrap(frameStr) : frameStr;
    }).join();
  }

  List<String> _mapTraceLocations(Trace trace) {
    return trace.frames.map((f) {
      if (_shouldMapPackage(f.package)) {
        final pkgLibRootPath = _pkgNameToFileMap[f.package]!.path;
        final relativeFilePath =
            f.library.substring(f.library.indexOf('/') + 1);

        final absFilePath = '$pkgLibRootPath$relativeFilePath';
        final filePath = useRelativePathsIfShorter ? _findShortestPath(absFilePath) : absFilePath;

        return '$filePath:${f.line}:${f.column}';
      } else {
        return '${f.library}:${f.line}:${f.column}';
      }
    }).toList();
  }

  bool _shouldMapPackage(String? pkg) {
    return pkg != null && _pkgNameToFileMap.containsKey(pkg);
  }

  String _findShortestPath(String absPath) {
    final relPath = relative(absPath, from: Directory.current.path);
    return relPath.length < absPath.length ? relPath : absPath;
  }
}
