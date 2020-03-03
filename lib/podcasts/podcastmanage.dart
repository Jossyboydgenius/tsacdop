import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/podcasts/podcastgroup.dart';
import 'package:tsacdop/podcasts/podcastlist.dart';
import 'package:tsacdop/util/pageroute.dart';

class PodcastManage extends StatefulWidget {
  @override
  _PodcastManageState createState() => _PodcastManageState();
}

class _PodcastManageState extends State<PodcastManage> {
  Decoration getIndicator() {
    return const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.red, width: 0),
        insets: EdgeInsets.only(
          top: 10.0,
        ));
  }

  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Groups'),
            actions: <Widget>[
              IconButton(
                  onPressed: () => showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (BuildContext context, Animation animaiton,
                              Animation secondaryAnimation) =>
                          AddGroup()),
                  icon: Icon(Icons.add)),
              OrderMenu(),
            ],
          ),
          body: Consumer<GroupList>(builder: (_, groupList, __) {
            bool _isLoading = groupList.isLoading;
            List<PodcastGroup> _groups = groupList.groups;
            return _isLoading
                ? Center()
                : DefaultTabController(
                    length: _groups.length,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: TabBar(
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            labelPadding: EdgeInsets.all(5.0),
                            indicator: getIndicator(),
                            isScrollable: true,
                            tabs: _groups.map<Tab>((group) {
                              return  Tab(
                                  child: Container(
                                      height: 30.0,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: group.getColor(),
                                       // Theme.of(context).brightness ==
                                       //         Brightness.light
                                       //     ? Theme.of(context).primaryColorDark
                                       //     : Colors.grey[800],
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: Text(
                                        group.name,
                                      )),
                                );
                              
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: TabBarView(
                              children: _groups.map<Widget>((group) {
                                return Container(
                                    key: ObjectKey(group),
                                    child: PodcastGroupList(group: group));
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ));
          }),
        ),
      ),
    );
  }
}

class OrderMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 2,
      tooltip: 'Menu',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(Icons.all_out),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              Text('All Podcasts'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          Navigator.push(context, ScaleRoute(page: PodcastList()));
        }
      },
    );
  }
}

class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController _controller;
  String _newGroup;
  int _error;

  @override
  void initState() {
    super.initState();
    _error = 0;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var groupList = Provider.of<GroupList>(context);
    List list = groupList.groups.map((e) => e.name).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).brightness == Brightness.light
                  ? Color.fromRGBO(113, 113, 113, 1)
                  : Color.fromRGBO(5, 5, 5, 1),
          statusBarColor: Theme.of(context).brightness == Brightness.light
              ? Color.fromRGBO(113, 113, 113, 1)
              : Color.fromRGBO(15, 15, 15, 1),
        ),
        child: SafeArea(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            elevation: 1,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            titlePadding:
                EdgeInsets.only(top: 20, left: 20, right: 200, bottom: 20),
            actionsPadding: EdgeInsets.all(0),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  if (list.contains(_newGroup)) {
                    setState(() => _error = 1);
                  } else {
                    groupList.addGroup(PodcastGroup(_newGroup));
                    Navigator.of(context).pop();
                  }
                },
                child: Text('DONE',
                    style: TextStyle(color: Theme.of(context).accentColor)),
              )
            ],
            title: Text('Create new group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'New Group',
                    hintStyle: TextStyle(fontSize: 18),
                    filled: true,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).accentColor, width: 2.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).accentColor, width: 2.0),
                    ),
                  ),
                  cursorRadius: Radius.circular(2),
                  autofocus: true,
                  maxLines: 1,
                  controller: _controller,
                  onChanged: (value) {
                    _newGroup = value;
                  },
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: (_error == 1)
                      ? Text(
                          'Group existed',
                          style: TextStyle(color: Colors.red[400]),
                        )
                      : Center(),
                ),
              ],
            ),
          ),
        ));
  }
}
