import 'package:flutter/material.dart';
import '../../../../../components/trackers/media_list.dart';
import '../../../../../components/trackers/profile_page.dart';
import '../../../../../core/models/page_args/myanimelist_page.dart'
    as myanimelist_page;
import '../../../../../core/trackers/myanimelist/myanimelist.dart'
    as myanimelist;
import '../../../../../plugins/helpers/assets.dart';
import '../../../../../plugins/helpers/ui.dart';
import '../../../../../plugins/helpers/utils/string.dart';
import '../../../../../plugins/translator/translator.dart';

class Page extends StatelessWidget {
  const Page({
    required final this.args,
    final Key? key,
  }) : super(key: key);

  final myanimelist_page.PageArguments args;

  @override
  Widget build(final BuildContext context) => ProfilePage(
        title: () => '${Translator.t.myAnimeList()} - ${Translator.t.anime()}',
        tabs: myanimelist.AnimeListStatus.values
            .map(
              (final myanimelist.AnimeListStatus x) =>
                  PageTab(x, StringUtils.capitalize(x.pretty)),
            )
            .toList(),
        profile: ProfileTab(
          getLeft: (final dynamic _user) => Material(
            shape: const CircleBorder(),
            elevation: 5,
            child: SizedBox(
              width: remToPx(5),
              height: remToPx(5),
              child: Padding(
                padding: EdgeInsets.all(remToPx(0.6)),
                child: Image.asset(
                  Assets.myAnimeListLogo,
                  width: remToPx(4.4),
                ),
              ),
            ),
          ),
          getMid: (final dynamic _user) {
            final myanimelist.UserInfo user = _user as myanimelist.UserInfo;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).textTheme.overline?.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'ID: ${user.id}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            );
          },
          getRight: (final dynamic _user, final void Function() pop) =>
              Material(
            type: MaterialType.transparency,
            elevation: 2,
            color: Colors.white,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(remToPx(0.2)),
              ),
              child: InkWell(
                onTap: () async {
                  await myanimelist.MyAnimeListManager.auth.deleteToken();
                  pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(0.5),
                    vertical: remToPx(0.2),
                  ),
                  child: Text(
                    Translator.t.logOut(),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
        getUserInfo: () async => myanimelist.getUserInfo(),
        getMediaList: (final PageTab tab) {
          final myanimelist.AnimeListStatus status =
              tab.data as myanimelist.AnimeListStatus;

          return MediaList(
            type: args.type,
            status: status,
            getMediaList: (final int page) async =>
                myanimelist.getAnimeList(status, page),
            getItemCard: (final BuildContext context, final dynamic _item) {
              final myanimelist.AnimeListEntity x =
                  _item as myanimelist.AnimeListEntity;
              x.applyChanges();

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(remToPx(0.3)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: remToPx(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            remToPx(0.25),
                          ),
                          child: Image.network(
                            x.mainPictureMedium,
                          ),
                        ),
                      ),
                      SizedBox(width: remToPx(0.75)),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              x.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .fontSize! -
                                    remToPx(0.1),
                              ),
                            ),
                            SizedBox(
                              height: remToPx(0.1),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        '${Translator.t.progress()}: ${x.userStatus?.watched ?? 0}',
                                  ),
                                  TextSpan(
                                    text:
                                        ' / ${x.details?.totalEpisodes ?? '?'}',
                                  ),
                                ],
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            getItemPage: (final BuildContext context, final dynamic _item) {
              final myanimelist.AnimeListEntity x =
                  _item as myanimelist.AnimeListEntity;
              x.applyChanges();

              return x.getDetailedPage(context);
            },
          );
        },
      );
}
