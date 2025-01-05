import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diohub/common/markdown_view/markdown_body.dart';
import 'package:diohub/common/misc/info_card.dart';
import 'package:diohub/common/misc/menu_button.dart';
import 'package:diohub/common/misc/profile_banner.dart';
import 'package:diohub/common/misc/reaction_bar.dart';
import 'package:diohub/common/misc/tappable_card.dart';
import 'package:diohub/graphql/__generated__/schema.schema.gql.dart';
import 'package:diohub/graphql/queries/issues_pulls/__generated__/timeline.data.gql.dart';
import 'package:diohub/providers/issue_pulls/comment_provider.dart';
import 'package:diohub/routes/router.gr.dart';
import 'package:diohub/utils/copy_to_clipboard.dart';
import 'package:diohub/utils/get_date.dart';
import 'package:diohub/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';

class BaseComment extends StatefulWidget {
  const BaseComment({
    required this.onQuote,
    required this.isMinimized,
    required this.reactions,
    required this.viewerCanDelete,
    required this.viewerCanMinimize,
    required this.viewerCannotUpdateReasons,
    required this.viewerCanReact,
    required this.viewerCanUpdate,
    required this.viewerDidAuthor,
    required this.createdAt,
    required this.author,
    required this.body,
    required this.lastEditedAt,
    required this.bodyHTML,
    required this.authorAssociation,
    super.key,
    // this.headerPadding = const EdgeInsets.symmetric(horizontal: 16),
    // this.header,
    this.minimizedReason,
    this.leading,
    this.description,
    this.footer,
    this.footerPadding = const EdgeInsets.only(top: 8, left: 8, right: 8),
    required this.resourceUri,
  });

  final Gactor? author;
  final GCommentAuthorAssociation authorAssociation;
  final String body;
  final IconData? leading;
  final String? bodyHTML;
  final List<GreactionGroups> reactions;
  final DateTime? lastEditedAt;
  final DateTime createdAt;
  final bool isMinimized;
  final String? minimizedReason;
  final bool viewerCanMinimize;
  final bool viewerCanDelete;
  final bool viewerCanUpdate;
  final bool viewerDidAuthor;

  // TODO(namanshergill): Temp nullable
  final List<GCommentCannotUpdateReason>? viewerCannotUpdateReasons;
  final bool viewerCanReact;
  final Widget? footer;
  final String? description;

  // final Widget? header;
  final VoidCallback onQuote;

  // final EdgeInsets headerPadding;
  final EdgeInsets footerPadding;
  final Uri resourceUri;

  @override
  BaseCommentState createState() => BaseCommentState();
}

class BaseCommentState extends State<BaseComment> {
  void addQuote(final String data) {
    context.read<CommentProvider>().addQuote(widget.body);
  }

  @override
  Widget build(final BuildContext context) => MenuButton(
        itemBuilder: (final BuildContext context) => <PullDownMenuEntry>[
          PullDownMenuActionsRow.medium(
            items: <PullDownMenuItem>[
              // PullDownMenuItem(
              //   onTap: () {
              //     // addQuote(widget.body);
              //     // widget.onQuote();
              //   },
              //   title: 'Edit',
              //   icon: Icons.edit_rounded,
              // ),
              // PullDownMenuItem(
              //   onTap: () {
              //     // addQuote(widget.body);
              //     // widget.onQuote();
              //   },
              //   title: 'History',
              //   icon: Icons.history_rounded,
              // ),
              PullDownMenuItem(
                onTap: () {},
                title: 'React (Placeholder)',
                iconWidget: AppReactionButton(
                  reactionGroups: widget.reactions,
                  loading: false,
                ),
              ),
              // PullDownMenuItem(
              //   onTap: () async => showDialog(
              //     context: context,
              //     builder: (final BuildContext cxt) =>
              //     ListenableProvider<CommentProvider>.value(
              //       value: Provider.of<CommentProvider>(context),
              //       builder: (final BuildContext context,
              //           final Widget? child) =>
              //           _SelectAndCopy(
              //             widget.body,
              //             onQuote: widget.onQuote,
              //           ),
              //     ),
              //   ),
              //   title: 'Select',
              //   icon: MdiIcons.clipboardSearch,
              // ),
            ],
          ),
          PullDownMenuActionsRow.medium(
            items: <PullDownMenuItem>[
              PullDownMenuItem(
                onTap: () async {
                  await Share.share(widget.resourceUri.toString());
                },
                title: 'Share',
                icon: Icons.adaptive.share_rounded,
              ),
              PullDownMenuItem(
                onTap: () {
                  addQuote(widget.body);
                  widget.onQuote();
                },
                title: 'Quote',
                icon: Icons.format_quote_rounded,
              ),
              PullDownMenuItem(
                onTap: () async => showDialog(
                  context: context,
                  builder: (final BuildContext cxt) =>
                      ListenableProvider<CommentProvider>.value(
                    value: Provider.of<CommentProvider>(context),
                    builder:
                        (final BuildContext context, final Widget? child) =>
                            SelectAndCopy(
                      widget.body,
                      onQuote: widget.onQuote,
                    ),
                  ),
                ),
                title: 'Select',
                icon: MdiIcons.clipboardSearch,
              ),
            ],
          ),
          const PullDownMenuDivider.large(),
          PullDownMenuHeader(
            leading: CachedNetworkImage(
              imageUrl: widget.author!.avatarUrl.toString(),
            ),
            title: widget.author!.login,
            subtitle: 'Go to profile',
            onTap: () async {
              await context.router.push(
                OtherUserProfileRoute(login: widget.author!.login),
              );
            },
          ).themed(context),
        ],
        builder: (
          final BuildContext context,
          final Widget button,
          final Future<void> Function() showMenu,
        ) =>
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CardHeader(
              child: _buildHeader(context, button),
            ),
            // const SizedBox(height: 8),

            BasicCard.linked(
              cardLinkType:
                  _reactionsNotEmpty() ? CardLinkType.both : CardLinkType.atTop,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8)
                    .copyWith(bottom: 8),
                child: Column(
                  children: <Widget>[
                    if (widget.description != null)
                      Text(
                        widget.description!,
                        // style: AppThemeTextStyles.basicIssueEventCardText(context)
                        //     .copyWith(
                        //   fontWeight: FontWeight.bold,
                        //   fontStyle: FontStyle.italic,
                        // ),
                      ),
                    if (widget.bodyHTML?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MarkdownBody(
                          widget.bodyHTML!,
                          buildAsync: false,
                          style: MarkdownBodyStyle(
                            codeBlockStyle: MarkdownBodyCodeBlockStyle(
                              elevation: 3,
                              headerColor:
                                  context.colorScheme.surfaceVariant.asHint(),
                            ),
                          ),
                        ),
                      ),
                    if (widget.footer != null)
                      Padding(
                        padding: widget.footerPadding,
                        child: widget.footer,
                      ),
                    if (widget.footer == null &&
                        (widget.bodyHTML?.isEmpty ?? false))
                      const SizedBox(
                        height: 8,
                      ),
                  ],
                ),
              ),
            ),

            if (_reactionsNotEmpty())
              CardHeader(
                // elevation: 0,
                cardLinkType: CardLinkType.atTop,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ReactionBar(
                    widget.reactions,
                    viewerCanReact: widget.viewerCanReact,
                  ),
                ),
              ),
          ],
        ),
      );

  bool _reactionsNotEmpty() => widget.reactions
      .where(
        (final GreactionGroups element) => element.reactors.totalCount > 0,
      )
      .isNotEmpty;

  Widget _buildHeader(
    final BuildContext context,
    final Widget button,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (widget.leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      widget.leading,
                      size: 16,
                      // color: Provider.of<PaletteSettings>(context)
                      //     .currentSetting
                      //     .faded3,
                    ),
                  ),
                const SizedBox(
                  width: 4,
                ),
                ProfileTile.avatar(
                  avatarUrl: widget.author?.avatarUrl.toString(),
                  userLogin: widget.author?.login,
                  padding: EdgeInsets.zero,
                  size: 32,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.author?.login ?? 'N/A',
                      style: context.textTheme.bodyMedium,
                    ),
                    if (widget.authorAssociation !=
                            GCommentAuthorAssociation.MEMBER &&
                        widget.authorAssociation !=
                            GCommentAuthorAssociation.NONE)
                      Builder(
                        builder: (final BuildContext context) {
                          String? str;
                          if (widget.authorAssociation ==
                              GCommentAuthorAssociation.COLLABORATOR) {
                            str = 'Collaborator';
                          } else if (widget.authorAssociation ==
                              GCommentAuthorAssociation.CONTRIBUTOR) {
                            str = 'Contributor';
                          } else if (widget.authorAssociation ==
                              GCommentAuthorAssociation.OWNER) {
                            str = 'Owner';
                          }
                          return Text(
                            str ?? '',
                            style: context.textTheme.bodySmall?.asHint(),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: getDate(widget.createdAt.toString()),
                        style: context.textTheme.bodySmall?.asHint(),
                        children: <InlineSpan>[
                          if (widget.lastEditedAt != null)
                            TextSpan(
                              text:
                                  ' • Edited ${getDate(widget.lastEditedAt.toString())}',
                              // style: context.textTheme.bodySmall?.asHint(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                button,
              ],
            ),
          ],
        ),
      );
}

class SelectAndCopy extends StatefulWidget {
  const SelectAndCopy(this.data, {super.key, this.onQuote});

  final String data;
  final VoidCallback? onQuote;

  @override
  _SelectAndCopyState createState() => _SelectAndCopyState();
}

class _SelectAndCopyState extends State<SelectAndCopy> {
  String selectedText = '';

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(
          'Select and copy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            widget.data,
            style: Theme.of(context).textTheme.bodyMedium,
            onSelectionChanged: (
              final TextSelection selection,
              final SelectionChangedCause? cause,
            ) {
              setState(() {
                selectedText = selection.textInside(widget.data);
              });
            },
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Cancel'),
            ),
          ),
          MaterialButton(
            onPressed: selectedText.isNotEmpty
                ? () async {
                    await copyToClipboard(selectedText);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Copy'),
            ),
          ),
          if (widget.onQuote != null)
            MaterialButton(
              onPressed: selectedText.isNotEmpty
                  ? () {
                      context.read<CommentProvider>().addQuote(selectedText);
                      Navigator.pop(context);

                      widget.onQuote!();
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Quote'),
              ),
            ),
        ],
      );
}
