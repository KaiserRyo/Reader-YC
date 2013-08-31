import bb.cascades 1.0
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

NavigationPane {
    id: askPage
    property variant theModel: theModel
    property alias loading: loading.visible
    property string whichPage: ""
    property string morePage: ""
    property string errorText: ""
    property string lastItemType: ""
    property bool busy: false

    onCreationCompleted: {
        Tart.register(askPage)
    }

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }

    onPushTransitionEnded: {
        if (page.objectName == 'commentPage') {
            Tart.send('requestPage', {
                    source: page.commentLink,
                    sentBy: 'commentPage',
                    askPost: page.isAsk,
                    deleteComments: "False"
                });
        }
    }

    function onAddaskStories(data) {
        lastItemType = 'item'
        morePage = data.moreLink;
        errorLabel.visible = false;
        var lastItem = theModel.size() - 1
        console.log("LAST ITEM: " + lastItemType);
        if (lastItemType == 'error') {
            theModel.removeAt(lastItem)
        }
        theModel.append({
                    type: 'item',
                    title: data.story['title'],
                    domain: data.story['domain'],
                    points: data.story['score'],
                    poster: data.story['author'],
                    timePosted: data.story['time'],
                    commentCount: data.story['commentCount'],
                    articleURL: data.story['link'],
                    commentsURL: data.story['commentURL'],
                    hnid: data.story['hnid'],
                    isAsk: data.story['askPost']
                });
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }

    function onAskListError(data) {
        lastItemType = 'error'
        if (theModel.isEmpty() != true) {
            var lastItem = theModel.size() - 1
            console.log(lastItemType);
            if (lastItemType == 'error') {
                theModel.removeAt(lastItem)
            }
            theModel.append({
                    type: 'error',
                    title: data.text
            });
        } else {
            errorLabel.text = data.text
            errorLabel.visible = true;
        }
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }
    
    function showSpacer() {
        if (errorLabel.visible == true || loading.visible == true) {
            return true;
        } else {
            return false;
        }
    }
    
    Page {
        Container {
            HNTitleBar {
                id: titleBar
                text: "Reader|YC - Ask HN"
                onRefreshPage: {
                    console.log("We are busy: " + busy)
                    if (busy != true) {
                        busy = true;
                        Tart.send('requestPage', {
                                source: 'askPage',
                                sentBy: 'askPage'
                            });
                        console.log("pressed")
                        theModel.clear();
                        refreshEnabled = ! busy;
                        loading.visible = true;
                    }
                }
            }

            Container {
                id: spacer
                visible: showSpacer()
                minHeight: 200
                maxHeight: 200
            }
            Container {
                visible: errorLabel.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: errorLabel
                    text: "<b><span style='color:#fe8515'>Error getting stories,</span></b>\nCheck your connection and try again!"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    visible: false
                }
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Container {
                    visible: loading.visible
                    ActivityIndicator {
                        id: loading
                        minHeight: 300
                        minWidth: 300
                        running: true
                        visible: true
                    }
                }
            }
            Container {

                ListView {
                    id: theList
                    dataModel: ArrayDataModel {
                        id: theModel
                    }
                    shortcuts: [
                        Shortcut {
                            key: "T"
                            onTriggered: {
                                theList.scrollToPosition(0, 0x2)
                            }
                        },
                        Shortcut {
                            key: "B"
                            onTriggered: {
                                theList.scrollToPosition(0, 0x2)
                            }
                        },
                        Shortcut {
                            key: "R"
                            onTriggered: {
                                if (! busy)
                                    refreshPage();
                            }
                        }
                    ]
                    function itemType(data, indexPath) {
                        if (data.type != 'error') {
                            lastItemType = 'item';
                            return 'item';
                        } else {
                            lastItemType = 'error';
                            return 'error';
                        }
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: 'item'
                            HNPage {
                                id: hnItem
                                property string type: ListItemData.type
                                postComments: ListItemData.commentCount
                                postTitle: ListItemData.title
                                postDomain: ListItemData.domain
                                postUsername: ListItemData.poster
                                postTime: ListItemData.timePosted + "| " + ListItemData.points
                                postArticle: ListItemData.articleURL
                                askPost: ListItemData.isAsk
                                commentSource: ListItemData.commentsURL
                                commentID: ListItemData.hnid
                            }
                        },
                        ListItemComponent {
                            type: 'error'
                            ErrorItem {
                                id: errorItem
                            }
                        }
                    ]
                    onTriggered: {
                        if (dataModel.data(indexPath).type == 'error') {
                            return;
                        }
                        var selectedItem = dataModel.data(indexPath);
                        console.log(selectedItem.isAsk);
                        if (selectedItem.isAsk == "true") {
                            console.log("Ask post");
                            var page = commentPage.createObject();
                            askPage.push(page);
                            console.log(selectedItem.commentsURL)
                            page.commentLink = selectedItem.hnid;
                            page.title = selectedItem.title;
                            page.titlePoster = selectedItem.poster;
                            page.titleTime = selectedItem.timePosted + "| " + selectedItem.points
                            page.isAsk = selectedItem.isAsk;
                            page.articleLink = selectedItem.articleURL;
                            page.titleComments = selectedItem.commentCount;
                            page.titlePoints = selectedItem.points
                            Tart.send('requestPage', {
                                    source: selectedItem.hnid,
                                    sentBy: 'commentPage',
                                    askPost: selectedItem.isAsk,
                                    deleteComments: "false"
                                });
                        } else {
                            console.log('Item triggered. ' + selectedItem.articleURL);
                            var page = webPage.createObject();
                            askPage.push(page);
                            page.htmlContent = selectedItem.articleURL;
                            page.text = selectedItem.title;
                        }
                    }
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if (atEnd == true && theModel.isEmpty() == false && morePage != "" && busy == false) {
                                    console.log('end reached!')
                                    Tart.send('requestPage', {
                                            source: morePage,
                                            sentBy: whichPage
                                        });
                                    busy = true;
                                }
                            }
                        }
                    ]
                    function pushPage(pageToPush) {
                        console.log(pageToPush)
                        var page = eval(pageToPush).createObject();
                        //                    page.title = details[0];
                        //                    page.titlePoster = details[1];
                        //                    page.titleTime = details[2];
                        askPage.push(page);
                        return page;
                    }
                }
            }
            attachedObjects: [
                ApplicationInfo {
                    id: appInfo
                },
                ComponentDefinition {
                    id: webPage
                    source: "webArticle.qml"
                },
                ComponentDefinition {
                    id: commentPage
                    source: "CommentPage.qml"
                },
                ComponentDefinition {
                    id: userPage
                    source: "UserPage.qml"
                }
            ]
        }
    }
}