import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/animations/size_expanded_widget.dart';
import 'package:dio_hub/common/misc/bottom_sheet.dart';
import 'package:dio_hub/common/misc/code_block_view.dart';
import 'package:dio_hub/common/misc/loading_indicator.dart';
import 'package:dio_hub/services/git_database/git_database_service.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:dio_hub/utils/parse_base64.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WrapIconButton extends StatelessWidget {
  const WrapIconButton(
      {Key? key, required this.wrap, this.size = 24, required this.onWrap})
      : super(key: key);
  final bool wrap;
  final ValueChanged<bool> onWrap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: smallBorderRadius,
        onTap: () {
          onWrap(!wrap);
        },
        child: Padding(
          padding: EdgeInsets.all(size / 2),
          child: Icon(
            Icons.wrap_text_rounded,
            size: size,
            color: wrap
                ? Provider.of<PaletteSettings>(context)
                    .currentSetting
                    .baseElements
                : Provider.of<PaletteSettings>(context).currentSetting.faded3,
          ),
        ));
  }
}

// Todo: I know this code is very messy. I wrote it 6 months ago and did not document it so I will figure this out and rewrite it later.
class PatchViewer extends StatefulWidget {
  const PatchViewer(
      {Key? key,
      this.patch,
      this.isWidget = false,
      this.wrap = false,
      this.initLoading = true,
      this.contentURL,
      this.limitLines,
      this.fileType,
      this.waitBeforeLoad = true})
      : super(key: key);
  final String? patch;
  final String? contentURL;
  final String? fileType;
  final bool wrap;
  final bool initLoading;
  final bool isWidget;
  final int? limitLines;

  /// Pass this as true before starting parsing to prevent lag.
  /// Todo: Remove?
  final bool waitBeforeLoad;

  @override
  _PatchViewerState createState() => _PatchViewerState();
}

class _PatchViewerState extends State<PatchViewer> {
  String? patch;
  int maxChars = 0;
  List<String>? rawData;
  late bool loading;

  @override
  void initState() {
    patch = widget.patch;
    loading = widget.initLoading;
    startUp();
    super.initState();
  }

  void startUp() async {
    final futures = <Future>[];
    if (widget.contentURL != null) {
      futures.add(fetchBlobFile());
    }
    await Future.wait(futures);
    regex();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future fetchBlobFile() async {
    final blob = await GitDatabaseService.getFileContents(widget.contentURL!);
    final data = blob.content!;
    rawData = parseBase64(data).split('\n');
    for (final str in rawData!) {
      if (str.length > maxChars) {
        maxChars = str.length;
      }
    }
  }

  void regex() async {
    final firstHeader = RegExp(r'(?:@@ )(.*)(?: @@)').firstMatch(patch!)!;
    makeCodeChunks(firstHeader);
    patch = patch!.replaceFirst(RegExp(r'(?=@@)(.*)(?<=@@)'), '', 0);
    RegExp(r'(?:\n)(?:@@ )(.*)(?: @@)')
        .allMatches(patch!)
        .forEach(makeCodeChunks);
    codeSplit.addAll(patch!.split(RegExp(r'(?:\n)(?=@@)(.*)(?<=@@)')));
    for (var i = 0; i < codeSplit.length; i++) {
      codeChunks[i]['code'] = codeSplit[i].split('\n');
      // log(codeChunks[i].toString());
      for (final String str in codeChunks[i]['code']) {
        if (str.length > maxChars) {
          maxChars = str.length;
        }
      }
    }
  }

  void makeCodeChunks(RegExpMatch element) {
    final info = CodeChunk();
    displayHeader.add('@@ ${element.group(1)} @@');
    final _splitHeader = element.group(1)!.split(' ');
    for (final element in _splitHeader) {
      final _headerValuesString = <String>[];
      final _headerValues = <int>[];
      _headerValuesString.addAll(element.split(','));
      _headerValues.add(int.parse(_headerValuesString[0]));
      _headerValues.add(int.parse(_headerValuesString[1]));

      if (_headerValues[0] < 0) {
        info.removeStartLine = _headerValues[0].abs();
        info.removeStartingLength = _headerValues[1];
      }
      if (_headerValues[0] > 0) {
        info.addStartLine = _headerValues[0];
        info.addStartingLength = _headerValues[1];
      }
    }
    codeChunks.add(info.getMap());
  }

  List<Map> codeChunks = [];
  List<String> codeSplit = [];
  List<String> displayHeader = [];

  Widget showCodeChunk(List displayCode, int chunkIndex, {int? onlyLast}) {
    int getSublist() {
      if (onlyLast != null && displayCode.length > onlyLast) {
        return displayCode.length - onlyLast;
      } else {
        return 1;
      }
    }

    int getRemoveIndex = codeChunks[chunkIndex]['startRemove'] ?? 1;

    int getAddIndex = codeChunks[chunkIndex]['startAdd'] ?? 1;

    final displayCodeWithoutFirstLine =
        displayCode.sublist(getSublist()) as List<String>;

    return ListView.builder(
        shrinkWrap: true,
        itemCount: displayCodeWithoutFirstLine.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, lineIndex) {
          return Container(
            color: getColor(displayCodeWithoutFirstLine[lineIndex], lineIndex),
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: 35,
                    child: Text.rich(
                      TextSpan(
                        text: displayCodeWithoutFirstLine[lineIndex][0] == '+'
                            ? ''
                            : '${getRemoveIndex++}',
                      ),
                      style: const TextStyle(fontFamily: 'monospace'),
                    )),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 35,
                  child: Text.rich(
                    TextSpan(
                      text: displayCodeWithoutFirstLine[lineIndex][0] == '-'
                          ? ''
                          : '${getAddIndex++}',
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                SizedBox(
                  width: 5,
                  child: Text(
                    displayCodeWithoutFirstLine[lineIndex].isNotEmpty
                        ? displayCodeWithoutFirstLine[lineIndex][0]
                        : ' ',
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: CodeBlockView(
                    displayCodeWithoutFirstLine[lineIndex].isNotEmpty
                        ? displayCodeWithoutFirstLine[lineIndex].substring(1)
                        : ' ',
                    language: widget.fileType,
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return loading
        ? Center(
            child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const LoadingIndicator(),
            ],
          ))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widget.wrap ||
                      maxChars.toDouble() * 10 <
                          MediaQuery.of(context).size.width
                  ? MediaQuery.of(context).size.width
                  : maxChars.toDouble() * 10,
              child: ListView.builder(
                  itemCount: codeChunks.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final List<String> displayCode = codeChunks[index]['code'];

                    return InkWell(
                      onTap: widget.limitLines != null &&
                              displayCode.length - 1 > widget.limitLines!
                          ? () {
                              var wrap = false;
                              showScrollableBottomActionsMenu(
                                context,
                                titleWidget: (context, setState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const IconButton(
                                            onPressed: null,
                                            icon: Icon(
                                              Icons.copy,
                                              color: Colors.transparent,
                                            )),
                                        const Text(
                                          'Patch Diff',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        WrapIconButton(
                                          wrap: wrap,
                                          onWrap: (value) {
                                            setState(() {
                                              wrap = !wrap;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: (context, scrollController, setState) {
                                  return SingleChildScrollView(
                                    controller: scrollController,
                                    child: PatchViewer(
                                      isWidget: true,
                                      patch: widget.patch,
                                      fileType: widget.fileType,
                                      waitBeforeLoad: false,
                                      wrap: wrap,
                                    ),
                                  );
                                },
                              );
                            }
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (codeChunks[index]['startAdd'] != null &&
                              !widget.isWidget)
                            ChunkHeader(
                              codeChunks: codeChunks,
                              displayCode: displayCode,
                              displayHeader: displayHeader,
                              index: index,
                              startRemove: codeChunks[index]['startRemove'],
                              maxChars: maxChars,
                              fileType: widget.fileType,
                              rawData: rawData,
                              wrap: widget.wrap,
                              startAdd: codeChunks[index]['startAdd'],
                            ),
                          if (widget.isWidget)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text.rich(
                                TextSpan(
                                    text:
                                        displayHeader[index] + displayCode[0]),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: Provider.of<PaletteSettings>(context)
                                        .currentSetting
                                        .faded3),
                              ),
                            ),
                          if (widget.limitLines != null &&
                              displayCode.length - 1 > widget.limitLines!)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '...Tap to view whole diff.',
                                style: TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          showCodeChunk(displayCode, index,
                              onlyLast: widget.limitLines),
                        ],
                      ),
                    );
                  }),
            ),
          );
  }

  Color getColor(String char, int index) {
    var str = char;
    str.isNotEmpty ? str = str[0] : str = '';
    switch (str) {
      case '+':
        return Provider.of<PaletteSettings>(context)
            .currentSetting
            .green
            .withOpacity(0.2);
      case '-':
        return Provider.of<PaletteSettings>(context)
            .currentSetting
            .red
            .withOpacity(0.2);
      default:
        if (index % 2 == 0) {
          return Provider.of<PaletteSettings>(context).currentSetting.primary;
        } else {
          return Provider.of<PaletteSettings>(context).currentSetting.secondary;
        }
    }
  }
}

class CodeChunk {
  CodeChunk(
      {this.code,
      this.addStartingLength,
      this.addStartLine,
      this.removeStartingLength,
      this.removeStartLine});
  int? addStartLine;
  int? addStartingLength;
  int? removeStartLine;
  int? removeStartingLength;
  List<String>? code;

  Map getMap() {
    return {
      'startAdd': addStartLine,
      'lengthAdd': addStartingLength,
      'startRemove': removeStartLine,
      'lengthRemove': removeStartingLength,
      'code': code,
    };
  }
}

class ChunkHeader extends StatefulWidget {
  const ChunkHeader(
      {this.codeChunks,
      this.startAdd,
      this.startRemove,
      this.displayHeader,
      this.index,
      this.fileType,
      required this.wrap,
      this.rawData,
      this.maxChars,
      this.displayCode,
      Key? key})
      : super(key: key);
  final List<String>? rawData;
  final int? index;
  final List<String>? displayCode;
  final int? startAdd;
  final int? startRemove;
  final String? fileType;
  final List<Map>? codeChunks;
  final int? maxChars;
  final bool wrap;
  final List<String>? displayHeader;

  @override
  _ChunkHeaderState createState() => _ChunkHeaderState();
}

class _ChunkHeaderState extends State<ChunkHeader> {
  bool expanded = false;
  late List<String> data;

  @override
  void initState() {
    setupData();

    if (widget.startAdd == 1 || widget.startRemove == 1) {
      expanded = true;
    }
    super.initState();
  }

  void setupData() {
    if (widget.index == 0) {
      data = widget.rawData!.sublist(0, widget.startAdd! - 1);
    } else {
      data = widget.rawData!.sublist(
          (widget.codeChunks![widget.index! - 1]['startAdd'] +
                  widget.codeChunks![widget.index! - 1]['lengthAdd']) ??
              1 - 1,
          widget.startAdd! - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return SizeExpandedSection(
        child: SizedBox(
          width: widget.wrap
              ? MediaQuery.of(context).size.width
              : widget.maxChars!.toDouble() * 10,
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                    color: index % 2 == 0
                        ? Provider.of<PaletteSettings>(context)
                            .currentSetting
                            .primary
                        : Provider.of<PaletteSettings>(context)
                            .currentSetting
                            .secondary,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 35,
                          child: Text(widget.index == 0
                              ? '${index + 1}'
                              : '${widget.codeChunks![widget.index! - 1]['startRemove'] + widget.codeChunks![widget.index! - 1]['lengthRemove'] + index}'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 35,
                          child: Text(widget.index == 0
                              ? '${index + 1}'
                              : '${widget.codeChunks![widget.index! - 1]['startAdd'] + widget.codeChunks![widget.index! - 1]['lengthAdd'] + index}'),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Flexible(
                          child: CodeBlockView(
                            data[index],
                            language: widget.fileType,
                          ),
                        ),
                      ],
                    ));
              }),
        ),
      );
    }
    return Material(
      color: Provider.of<PaletteSettings>(context)
          .currentSetting
          .accent
          .withOpacity(0.7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (widget.rawData != null) {
              expanded = true;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(
                Icons.expand,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                widget.displayHeader![widget.index!],
                style: const TextStyle(fontSize: 12),
              ),
              Flexible(
                child: Text(
                  widget.displayCode![0],
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
