class SearchFilters {
  /// Create a [SearchFilters] instance with data of a repository search.
  /// Ref: https://docs.github.com/en/github/searching-for-information-on-github/searching-for-repositories
  SearchFilters.repositories({List<String> blacklist = const []})
      : _sortOptions = {
          'best': 'Best Match',
          'stars-desc': 'Most stars',
          'stars-asc': 'Fewest stars',
          'forks-desc': 'Most forks',
          'forks-asc': 'Least forks',
          'updated-desc': 'Recently updated',
          'updated-asc': 'Least Recently updated',
        },
        _searchType = SearchType.repositories {
    _filterQueries([
      searchQueries.archived,
      searchQueries.created,
      searchQueries.followers,
      searchQueries.fork
        ..addOptions({
          'true': '',
          'only': '',
        }),
      searchQueries.forks,
      searchQueries.goodFirstIssues,
      searchQueries.helpWantedIssues,
      searchQueries.iN
        ..addOptions({
          'name': 'Name',
          'description': 'Description',
          'readme': 'Readme',
        }),
      searchQueries.iS
        ..addOptions({
          'public': '',
          'internal': '',
          'private': '',
        }),
      searchQueries.language,
      searchQueries.license,
      searchQueries.mirror,
      searchQueries.org,
      searchQueries.pushed,
      searchQueries.repo,
      searchQueries.size,
      searchQueries.stars,
      searchQueries.topic,
      searchQueries.topics,
      searchQueries.user,
    ], blacklist);
  }

  /// Create a [SearchFilters] instance with data of issues and pull requests search.
  /// Ref: https://docs.github.com/en/github/searching-for-information-on-github/searching-issues-and-pull-requests
  SearchFilters.issuesPulls({List<String> blacklist = const []})
      : _sortOptions = {
          'best': 'Best Match',

          'created-desc': 'Newest',
          'created-asc': 'Oldest',
          'comments-desc': 'Most comments',
          'comments-asc': 'Least comments',
          'updated-desc': 'Recently updated',
          'updated-asc': 'Least recently updated',
          'reactions-desc': 'Most reactions',
          'reactions-asc': 'Least reactions',
          'reactions-+1-desc': 'Most 👍',
          // 'reactions-+1-asc': 'Least 👍',
          'reactions--1-desc': 'Most 👎',
          // 'reactions--1-asc': 'Least 👎',
          'reactions-smile-desc': 'Most 😄',
          // 'reactions-smile-asc': 'Least 😄',
          'reactions-thinking_face-desc': 'Most 😕',
          // 'reactions-thinking_face-asc': 'Least 😕',
          'reactions-heart-desc': 'Most ❤️',
          // 'reactions-heart-asc': 'Least ❤️',
          'reactions-tada-desc': 'Most 🎉',
          // 'reactions-tada-asc': 'Least 🎉',
          'reactions-rocket-desc': 'Most 🚀',
          // 'reactions-rocket-asc': 'Least 🚀',
          'reactions-eyes-desc': 'Most 👀',
          // 'reactions-eyes-asc': 'Least 👀',
        },
        _searchType = SearchType.issuesPulls {
    _filterQueries([
      searchQueries.archived,
      searchQueries.assignee,
      searchQueries.author,
      searchQueries.base,
      searchQueries.closed,
      searchQueries.commenter,
      searchQueries.comments,
      searchQueries.created,
      searchQueries.draft,
      searchQueries.head,
      searchQueries.iN
        ..addOptions({
          'title': 'Name',
          'body': 'Description',
          'comments': 'Readme',
        }),
      searchQueries.interactions,
      searchQueries.involves,
      searchQueries.iS
        ..addOptions({
          'open': '',
          'closed': '',
          'public': '',
          'internal': '',
          'private': '',
          'merged': '',
          'unmerged': '',
          'locked': '',
          'unlocked': '',
        }),
      searchQueries.label,
      searchQueries.language,
      searchQueries.linked
        ..addOptions({
          'pr': '',
          'issue': '',
        }),
      searchQueries.milestone,
      searchQueries.mentions,
      searchQueries.merged,
      searchQueries.no
        ..addOptions({
          'label': '',
          'milestone': '',
          'assignee': '',
          'project': '',
        }),
      searchQueries.org,
      searchQueries.project,
      searchQueries.reactions,
      searchQueries.repo,
      searchQueries.review
        ..addOptions({
          'none': '',
          'required': '',
          'approved': '',
          'changes_requested': '',
        }),
      searchQueries.reviewRequested,
      searchQueries.state
        ..addOptions({
          'open': '',
          'closed': '',
        }),
      searchQueries.status
        ..addOptions({
          'pending': '',
          'success': '',
          'failure': '',
        }),
      searchQueries.team,
      searchQueries.teamReviewRequested,
      searchQueries.type
        ..addOptions({
          'pr': 'Pull Request',
          'issue': 'Issue',
        }),
      searchQueries.updated,
      searchQueries.user,
    ], blacklist);
  }

  /// Create a [SearchFilters] instance with data of users search.
  /// Ref: https://docs.github.com/en/github/searching-for-information-on-github/searching-users
  SearchFilters.users({List<String> blacklist = const []})
      : _sortOptions = {
          'best': 'Best Match',
          'followers-desc': '',
          'followers-asc': '',
          'repositories-desc': '',
          'repositories-asc': '',
          'joined-desc': '',
          'joined-asc': '',
        },
        _searchType = SearchType.users {
    _filterQueries([
      searchQueries.created,
      searchQueries.followers,
      searchQueries.fullName,
      searchQueries.iN
        ..addOptions({
          'login': '',
          'name': '',
          'email': '',
        }),
      searchQueries.language,
      searchQueries.location,
      searchQueries.org,
      searchQueries.repos,
      searchQueries.type
        ..addOptions({
          'user': '',
          'org': '',
        }),
      searchQueries.user,
    ], blacklist);
  }
  final List<SearchQuery> _basicQueries = [];
  final List<SearchQuery> _sensitiveQueries = [];
  final List<SearchQuery> _blackList = [];
  final SearchType _searchType;
  final Map<String, String> _sortOptions;
  RegExp? _numberQRegExp;
  RegExp? _dateQRegExp;
  final SearchQueries searchQueries = SearchQueries();

  /// Get search type.
  SearchType get searchType => _searchType;

  /// Get regexp to match all valid queries in a string.
  RegExp get allValidQueriesRegexp => RegExp(
      '${validBasicQueriesRegExp.pattern}|${validSensitiveQueriesRegExp.pattern}');

  /// Get regexp to match all invalid queries in a string.
  RegExp get allInvalidQueriesRegExp =>
      _getIncompleteRegExp(_basicQueries + _sensitiveQueries + _blackList);

  /// Sort options for the given search filter.
  Map<String, String> get sortOptions => _sortOptions;

  /// Get regexp to match valid basic queries in a string.
  RegExp get validBasicQueriesRegExp => _getRegExp(_basicQueries);

  /// Get regexp to match valid sensitive queries in a string.
  RegExp get validSensitiveQueriesRegExp =>
      _getSensitiveQueryRegExp(_sensitiveQueries);

  /// Get regexp to match all blacklisted queries in a string.
  RegExp get blacklistRegExp => _getIncompleteRegExp(_blackList);

  /// Get regexp to match invalid basic queries in a string.
  RegExp get invalidBasicQueriesRegExp => _getIncompleteRegExp(_basicQueries);

  /// Get regexp to match invalid sensitive queries in a string.
  RegExp get invalidSensitiveQueriesRegExp =>
      _getIncompleteRegExp(_sensitiveQueries);

  /// Get regexp to match NOT operators in a string.
  static RegExp get notOperatorRegExp =>
      RegExp('(?:NOT)(?:\\s)(?!(NOT|OR|AND))(\\w+)');

  /// Get regexp to match AND operators in a string.
  static RegExp get andOperatorRegExp => RegExp(
      '(${optionalQuotes('(\\w[^(NOT|OR|AND| )]+)', allowSpace: true, spacedRegex: '((\\w|\\s+)+)')})?(?:(\\s)+)(?:AND)(?:(\\s)+)(?!(NOT|OR|AND))(${optionalQuotes('\\w+', allowSpace: true, spacedRegex: '((\\w|\\s+)+)')})');

  /// Get regexp to match OR operators in a string.
  static RegExp get orOperatorRegExp => RegExp(
      '(${optionalQuotes('(\\w[^(NOT|OR|AND| )]+)', allowSpace: true, spacedRegex: '((\\w|\\s+)+)')})?(?:(\\s)+)(?:OR)(?:(\\s)+)(?!(NOT|OR|AND))(${optionalQuotes('\\w+', allowSpace: true, spacedRegex: '((\\w|\\s+)+)')})');

  /// Get regexp to match number queries in a string.
  RegExp? get numberQRegExp => _numberQRegExp;

  /// Get regexp to match date queries in a string.
  RegExp? get dateQRegExp => _dateQRegExp;

  /// Get all whitelisted queries for the [SearchFilters] instance.
  List<SearchQuery> get whiteListedQueries {
    final list = _sensitiveQueries + _basicQueries;
    list.sort((a, b) => a.query.toLowerCase().compareTo(b.query.toLowerCase()));
    return list;
  }

  /// Get all whitelisted query strings for the [SearchFilters] instance.
  List<String> get whiteListedQueriesStrings =>
      whiteListedQueries.map((e) => e.query).toList();

  /// Get the corresponding [SearchQuery] instance in the lists from a given string.
  SearchQuery? queryFromString(String query) {
    var data = query;
    SearchQuery? value;
    if (data.startsWith('-')) {
      data = data.substring(1);
    }
    for (final element in _basicQueries + _sensitiveQueries + _blackList) {
      if (element.query == data) {
        value = element;
      }
    }
    return value;
  }

  /// Create regexp for sensitive queries.
  RegExp _getSensitiveQueryRegExp(List<SearchQuery> queries) {
    final optionQ = <SearchQuery>[];
    final dateQ = <SearchQuery>[];
    final numberQ = <SearchQuery>[];
    final userQ = <SearchQuery>[];
    final spacedQ = <SearchQuery>[];
    final customQ = <SearchQuery>[];
    for (final element in queries) {
      if (element.type == QueryType.date) {
        dateQ.add(element);
      } else if (element.type == QueryType.number) {
        numberQ.add(element);
      } else if (element.type == QueryType.user ||
          element.type == QueryType.org) {
        userQ.add(element);
      } else if (element.type == QueryType.spacedString) {
        spacedQ.add(element);
      } else if (element.type == QueryType.custom) {
        customQ.add(element);
      } else {
        optionQ.add(element);
      }
    }

    /*
        (?:-)? -> Optional [-] at start.
        (?:${spacedQs.join('|')}) -> Starts with the given queries.
        (?:") -> Checks for start quote.
        ((\\w|\\d| |[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Everything after start quote.
        (?:") -> Checks for end quote.
        (?=(\\s)(${spacedQs.join('|')})?|\$) ->  Ends with another query or end of line.
    */
    final spacedQs = spacedQ.map((e) => '${e.query}:').toList();
    final spacedRegExp =
        '(?:-)?(?:${spacedQs.join('|')})(((?:")((\\w|\\d| |[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)(?:"))|((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+))(?=(\\s))';

    /*
        (?:-)? -> Optional [-] at start.
        (?:${optionsQ.join('|')}) -> Starts with the given queries.
    */
    final optionsQ = optionQ
        .map((query) => query.options!.keys
            .map((option) => '${query.query}:($option|"$option")')
            .join('|'))
        .toList();
    final optionRegexp = '(?:-)?(?:${optionsQ.join('|')})(?=(\\s))';

    /*
    Common:
        (?:-)? -> Optional [-] at start.
        (?:${numbersQ.join('|')}) -> Starts with the given queries.
        (?:") -> Checks for start quote.
        (?:") -> Checks for end quote.
        (?=(\\s)(${numbersQ.join('|')})?|\$) ->  Ends with another query or end of line.
    Cases:
        ([><][=]?)?([0-9]+) -> [10], [>10], [>=10], [<=10]
        -----------------------
        ([0-9]+)([.][.][*]) -> [10..*]
        -----------------------
        ([*][.][.])([0-9]+) -> [*..10]
    */
    final numbersQ = numberQ.map((query) => '${query.query}:').toList();
    final numberRegexp =
        '(?:-)?(?:${numbersQ.join('|')})${optionalQuotes(rangeRegExp('([0-9]+)'))}(?=(\\s))';
    _numberQRegExp = RegExp(numberRegexp.replaceAll('(?=(\\s))', ''));

    final datesQ = dateQ.map((query) => '${query.query}:').toList();
    final dateRegexp =
        '(?:-)?(?:${datesQ.join('|')})${optionalQuotes(rangeRegExp('([12]\\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01]))'))}(?=(\\s))';
    _dateQRegExp = RegExp(dateRegexp.replaceAll('(?=(\\s))', ''));

    /*
        (?:-)? -> Optional [-] at start.
        (?:$filter) -> Starts with the given queries.
        (?:") -> Checks for start quote.
        (([a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Any character following.
        (?:") -> Checks for end quote.
        (?=(\\s)($filter)?|\$) -> Ends with another query or end of line.
    */
    final usersQ = userQ.map((query) => '${query.query}:').toList();
    final userRegExp =
        '(?:-)?(?:${usersQ.join('|')})${optionalQuotes('(([a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)')}(?=(\\s))';

    final finalRegex = <String>[];
    if (spacedQ.isNotEmpty) {
      finalRegex.add(spacedRegExp);
    }
    if (userQ.isNotEmpty) {
      finalRegex.add(userRegExp);
    }
    if (optionQ.isNotEmpty) {
      finalRegex.add(optionRegexp);
    }
    if (numberQ.isNotEmpty) {
      finalRegex.add(numberRegexp);
    }
    if (dateQ.isNotEmpty) {
      finalRegex.add(dateRegexp);
    }
    if (customQ.isNotEmpty) {
      for (final element in customQ) {
        finalRegex.add(element.customRegex!);
      }
    }
    return RegExp(finalRegex.join('|'));
  }

  RegExp _getRegExp(List<SearchQuery> queries) {
    final strings = queries.map((e) => '${e.query}:').toList();
    final filter = strings.join('|');
    /*
        (?:-)? -> Optional [-] at start.
        (?:$filter) -> Starts with the given queries.
        ((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Any character following.
        (?=(\\s)($filter)?|\$) -> Ends with another query or end of line.
    */
    var regex = '(?:-)?(?:$filter)${optionalQuotes('(.[^":]+)')}(?=(\\s))';
    if (queries.isEmpty) {
      regex = '(?!x)x';
    }
    return RegExp(regex);
  }

  RegExp _getIncompleteRegExp(
    List<SearchQuery> queries,
  ) {
    final strings = queries.map((e) => '${e.query}:').toList();
    final filter = strings.join('|');
    /*
        (?:-)? -> Optional [-] at start.
        (?:$filter) -> Starts with the given queries.
        (.*) -> Any character following.
        (?=(\\s)($filter)?|\$) -> Ends with another query or end of line.
    */
    var regex = '(?:-)?(?:$filter)(((?:")(.[^"]*)(?:"))|(.[^"| ]*))?(?:")?';
    if (queries.isEmpty) {
      regex = '(?!x)x';
    }
    return RegExp(regex);
  }

  /// Filter queries into basic, sensitive, or blacklist groups.
  void _filterQueries(List<SearchQuery> original, List<String> blacklist) {
    final allQueries = searchQueries.allQueries;
    for (final element in original) {
      if (!blacklist.contains(element.query)) {
        if (element.type != QueryType.basic || element.options != null) {
          _sensitiveQueries.add(element);
        } else {
          _basicQueries.add(element);
        }
      }
    }
    final filteredBlackList = <SearchQuery>[];
    for (final e in allQueries) {
      if (!whiteListedQueries.contains(e)) {
        filteredBlackList.add(e);
      }
    }
    _blackList.addAll(filteredBlackList);
  }

  /// Get regex for optional quotes around a string.
  static String optionalQuotes(String string,
      {bool allowSpace = false, String? spacedRegex}) {
    if (allowSpace) {
      return '(((?:")$spacedRegex(?:"))|($string))';
    }
    return '(((?:")$string(?:"))|($string))';
  }

  static String rangeRegExp(String string) {
    return '(($string)([.][.])($string))|(($string)([.][.][*]))|(([*][.][.])($string))|(([><][=]?)?($string))';
  }
}

class SearchQueries {
  static final String _teamRegex =
      '(?:-)?(?:${SearchQueryStrings.team}:)${SearchFilters.optionalQuotes('((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)(/)((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)')}(?=(\\s))';
  static final String _authorRegex =
      '(?:-)?(?:${SearchQueryStrings.author}:)${SearchFilters.optionalQuotes('((app)(/))?((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,])+)')}(?=(\\s))';

  /*
        (?:-)? -> Optional [-] at start.
        (?:${SearchQueryStrings.repo}:) -> Starts with the given queries.
        (?:") -> Checks for start quote.
        ((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Everything after start quote.
        (((/)((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)){1,2}) -> Everything after [/], min 1, max 2.
        (?:") -> Checks for end quote.
        (?:${SearchQueryStrings.repo}:) ->  Ends with given queries or end of line.
  */
  static final String _projectRegex =
      '(?:-)?(?:${SearchQueryStrings.project}:)${SearchFilters.optionalQuotes('((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)(((/)((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)){1,2})')}(?=(\\s))';

  /*
        (?:-)? -> Optional [-] at start.
        (?:${SearchQueryStrings.repo}:) -> Starts with the given queries.
        (?:") -> Checks for start quote.
        ((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Everything after start quote.
        (/) -> Checks that [/] is present.
        ((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+) -> Everything after [/].
        (?:") -> Checks for end quote.
        (?:${SearchQueryStrings.repo}:) ->  Ends with given queries or end of line.
  */
  static final String _repoRegex =
      '(?:-)?(?:${SearchQueryStrings.repo}:)${SearchFilters.optionalQuotes('((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)(/)((\\w|\\d|[a-zA-Z0-9!><=@#\$&\\(\\)\\-`.+,/])+)')}(?=(\\s))';

  SearchQuery archived =
      SearchQuery(SearchQueryStrings.archived, type: QueryType.bool);
  SearchQuery assignee =
      SearchQuery(SearchQueryStrings.assignee, type: QueryType.user);
  SearchQuery author = SearchQuery(SearchQueryStrings.author,
      customRegex: _authorRegex, type: QueryType.user);
  SearchQuery authorName = SearchQuery(SearchQueryStrings.authorName);
  SearchQuery authorEmail = SearchQuery(SearchQueryStrings.authorEmail);
  SearchQuery authorDate = SearchQuery(SearchQueryStrings.authorDate);
  SearchQuery base = SearchQuery(SearchQueryStrings.base);
  SearchQuery closed =
      SearchQuery(SearchQueryStrings.closed, type: QueryType.date);
  SearchQuery commenter =
      SearchQuery(SearchQueryStrings.commenter, type: QueryType.user);
  SearchQuery comments =
      SearchQuery(SearchQueryStrings.comments, type: QueryType.number);
  SearchQuery committer =
      SearchQuery(SearchQueryStrings.committer, type: QueryType.user);
  SearchQuery committerName = SearchQuery(SearchQueryStrings.committerName);
  SearchQuery committerEmail = SearchQuery(SearchQueryStrings.committerEmail);
  SearchQuery committerDate = SearchQuery(SearchQueryStrings.committerDate);
  SearchQuery created =
      SearchQuery(SearchQueryStrings.created, type: QueryType.date);
  SearchQuery draft =
      SearchQuery(SearchQueryStrings.draft, type: QueryType.bool);
  SearchQuery extension = SearchQuery(SearchQueryStrings.extension);
  SearchQuery filename = SearchQuery(SearchQueryStrings.filename);
  SearchQuery followers =
      SearchQuery(SearchQueryStrings.followers, type: QueryType.number);
  SearchQuery fork = SearchQuery(SearchQueryStrings.fork,
      options: {
        'true': 'Include forks.',
        'only': 'Only show forks.',
      },
      qualifierQuery: false);
  SearchQuery forks =
      SearchQuery(SearchQueryStrings.forks, type: QueryType.number);
  SearchQuery fullName =
      SearchQuery(SearchQueryStrings.fullName, type: QueryType.spacedString);
  SearchQuery goodFirstIssues =
      SearchQuery(SearchQueryStrings.goodFirstIssues, type: QueryType.number);
  SearchQuery hash = SearchQuery(SearchQueryStrings.hash);
  SearchQuery head = SearchQuery(SearchQueryStrings.head);
  SearchQuery helpWantedIssues =
      SearchQuery(SearchQueryStrings.helpWantedIssues, type: QueryType.number);
  SearchQuery iN = SearchQuery(SearchQueryStrings.iN, qualifierQuery: false);
  SearchQuery interactions =
      SearchQuery(SearchQueryStrings.interactions, type: QueryType.number);
  SearchQuery involves =
      SearchQuery(SearchQueryStrings.involves, type: QueryType.user);
  SearchQuery iS = SearchQuery(SearchQueryStrings.iS);
  SearchQuery label =
      SearchQuery(SearchQueryStrings.label, type: QueryType.spacedString);
  SearchQuery language = SearchQuery(SearchQueryStrings.language);
  SearchQuery license = SearchQuery(SearchQueryStrings.license);
  SearchQuery linked = SearchQuery(SearchQueryStrings.linked);
  SearchQuery location =
      SearchQuery(SearchQueryStrings.location, type: QueryType.spacedString);
  SearchQuery merge = SearchQuery(SearchQueryStrings.merge);
  SearchQuery merged =
      SearchQuery(SearchQueryStrings.merged, type: QueryType.date);
  SearchQuery mentions =
      SearchQuery(SearchQueryStrings.mentions, type: QueryType.user);
  SearchQuery milestone =
      SearchQuery(SearchQueryStrings.milestone, type: QueryType.spacedString);
  SearchQuery mirror =
      SearchQuery(SearchQueryStrings.mirror, type: QueryType.bool);
  SearchQuery no = SearchQuery(SearchQueryStrings.no);
  SearchQuery org = SearchQuery(SearchQueryStrings.org, type: QueryType.org);
  SearchQuery parent = SearchQuery(SearchQueryStrings.parent);
  SearchQuery path = SearchQuery(SearchQueryStrings.path);
  SearchQuery project =
      SearchQuery(SearchQueryStrings.project, customRegex: _projectRegex);
  SearchQuery pushed =
      SearchQuery(SearchQueryStrings.pushed, type: QueryType.date);
  SearchQuery reactions =
      SearchQuery(SearchQueryStrings.reactions, type: QueryType.number);
  SearchQuery repo =
      SearchQuery(SearchQueryStrings.repo, customRegex: _repoRegex);
  SearchQuery repos =
      SearchQuery(SearchQueryStrings.repos, type: QueryType.number);
  SearchQuery repositories = SearchQuery(SearchQueryStrings.repositories);
  SearchQuery review = SearchQuery(SearchQueryStrings.review);
  SearchQuery reviewedBy =
      SearchQuery(SearchQueryStrings.reviewedBy, type: QueryType.user);
  SearchQuery reviewRequested =
      SearchQuery(SearchQueryStrings.reviewRequested, type: QueryType.user);
  SearchQuery size =
      SearchQuery(SearchQueryStrings.size, type: QueryType.number);
  SearchQuery sort = SearchQuery(SearchQueryStrings.sort);
  SearchQuery stars =
      SearchQuery(SearchQueryStrings.stars, type: QueryType.number);
  SearchQuery state = SearchQuery(SearchQueryStrings.state);
  SearchQuery status = SearchQuery(SearchQueryStrings.status);
  SearchQuery team =
      SearchQuery(SearchQueryStrings.team, customRegex: _teamRegex);
  SearchQuery teamReviewRequested = SearchQuery(
      SearchQueryStrings.teamReviewRequested,
      customRegex: _teamRegex);
  SearchQuery topic =
      SearchQuery(SearchQueryStrings.topic, type: QueryType.spacedString);
  SearchQuery topics =
      SearchQuery(SearchQueryStrings.topics, type: QueryType.number);
  SearchQuery tree = SearchQuery(SearchQueryStrings.tree);
  SearchQuery type =
      SearchQuery(SearchQueryStrings.type, qualifierQuery: false);
  SearchQuery updated = SearchQuery(SearchQueryStrings.updated);
  SearchQuery user = SearchQuery(SearchQueryStrings.user, type: QueryType.user);

  List<SearchQuery> get allQueries => [
        archived,
        assignee,
        author,
        authorName,
        authorEmail,
        authorDate,
        base,
        closed,
        commenter,
        comments,
        committer,
        committerName,
        committerEmail,
        committerDate,
        created,
        draft,
        extension,
        filename,
        followers,
        fork,
        forks,
        fullName,
        goodFirstIssues,
        hash,
        head,
        helpWantedIssues,
        iN,
        interactions,
        involves,
        iS,
        label,
        language,
        license,
        linked,
        location,
        merge,
        merged,
        mentions,
        milestone,
        mirror,
        no,
        org,
        parent,
        path,
        project,
        pushed,
        reactions,
        repo,
        repos,
        repositories,
        review,
        reviewedBy,
        reviewRequested,
        teamReviewRequested,
        size,
        sort,
        stars,
        state,
        status,
        team,
        topic,
        topics,
        tree,
        type,
        updated,
        user
      ];
}

class SearchQueryStrings {
  static const String archived = 'archived';
  static const String assignee = 'assignee';
  static const String author = 'author';
  static const String authorName = 'author-name';
  static const String authorEmail = 'author-email';
  static const String authorDate = 'author-date';
  static const String base = 'base';
  static const String closed = 'closed';
  static const String commenter = 'commenter';
  static const String comments = 'comments';
  static const String committer = 'committer';
  static const String committerName = 'committer-name';
  static const String committerEmail = 'committer-email';
  static const String committerDate = 'committer-date';
  static const String created = 'created';
  static const String draft = 'draft';
  static const String extension = 'extension';
  static const String filename = 'filename';
  static const String followers = 'followers';
  static const String fork = 'fork';
  static const String forks = 'forks';
  static const String fullName = 'fullname';
  static const String goodFirstIssues = 'good-first-issues';
  static const String hash = 'hash';
  static const String head = 'head';
  static const String helpWantedIssues = 'help-wanted-issues';
  static const String iN = 'in';
  static const String interactions = 'interactions';
  static const String involves = 'involves';
  static const String iS = 'is';
  static const String label = 'label';
  static const String language = 'language';
  static const String license = 'license';
  static const String linked = 'linked';
  static const String location = 'location';
  static const String merge = 'merge';
  static const String merged = 'merged';
  static const String mentions = 'mentions';
  static const String milestone = 'milestone';
  static const String mirror = 'mirror';
  static const String no = 'no';
  static const String org = 'org';
  static const String parent = 'parent';
  static const String path = 'path';
  static const String project = 'project';
  static const String pushed = 'pushed';
  static const String reactions = 'reactions';
  static const String repo = 'repo';
  static const String repos = 'repos';
  static const String repositories = 'repositories';
  static const String review = 'review';
  static const String reviewedBy = 'reviewed-by';
  static const String reviewRequested = 'review-requested';
  static const String teamReviewRequested = 'team-review-requested';
  static const String size = 'size';
  static const String sort = 'sort';
  static const String stars = 'stars';
  static const String state = 'state';
  static const String status = 'status';
  static const String team = 'team';
  static const String topic = 'topic';
  static const String topics = 'topics';
  static const String tree = 'tree';
  static const String type = 'type';
  static const String updated = 'updated';
  static const String user = 'user';

  static const List<String> allQueries = [
    archived,
    assignee,
    author,
    authorName,
    authorEmail,
    authorDate,
    base,
    closed,
    commenter,
    comments,
    committer,
    committerName,
    committerEmail,
    committerDate,
    created,
    draft,
    extension,
    filename,
    followers,
    fork,
    forks,
    fullName,
    goodFirstIssues,
    hash,
    head,
    helpWantedIssues,
    iN,
    interactions,
    involves,
    iS,
    label,
    language,
    license,
    linked,
    location,
    merge,
    merged,
    mentions,
    milestone,
    mirror,
    no,
    org,
    parent,
    path,
    project,
    pushed,
    reactions,
    repo,
    repos,
    repositories,
    review,
    reviewedBy,
    reviewRequested,
    teamReviewRequested,
    size,
    sort,
    stars,
    state,
    status,
    team,
    topic,
    topics,
    tree,
    type,
    updated,
    user
  ];
}

class SearchQuery {
  SearchQuery(this.query,
      {this.description,
      this.options,
      this.customRegex,
      QueryType? type,
      this.qualifierQuery = true})
      : type =
            type ?? (customRegex != null ? QueryType.custom : QueryType.basic) {
    if (type == QueryType.bool && options == null) {
      options = {'true': '', 'false': ''};
    }
  }
  final String query;
  final String? description;
  final String? customRegex;
  final bool qualifierQuery;
  Map<String, String>? options;
  final QueryType type;

  String toQueryString(String data) =>
      data.contains(' ') ? '$query:"$data"' : '$query:$data';

  void addOptions(Map<String, String> options) {
    if (this.options == null) {
      this.options = {};
    }

    this.options!.addAll(options);
  }
}

enum QueryType { basic, spacedString, date, number, user, org, bool, custom }

enum SearchType {
  repositories,
  // topics,
  // code,
  // commits,
  issuesPulls,
  // discussions,
  users,
  // packages,
  // wiki
}

final searchTypeValues = EnumValues({
  'Repositories': SearchType.repositories,
  // "Topics": SearchType.topics,
  // "Code": SearchType.code,
  // "Commits": SearchType.commits,
  'Issues and Pulls Requests': SearchType.issuesPulls,
  // "Discussions": SearchType.discussions,
  'Users': SearchType.users,
  // "Packages": SearchType.packages,
  // "Wiki": SearchType.wiki,
});

class EnumValues<T> {
  EnumValues(this.map);
  Map<String, T> map;
  Map<T, String>? reverseMap;

  Map<T, String>? get reverse {
    return reverseMap ??= map.map((k, v) => MapEntry(v, k));
  }
}
