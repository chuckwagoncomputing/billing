import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: jobListPage
 anchors.fill: parent
 // Let the page indicator be visible, and this is the first page
 property bool indicatorEnabled: true
 property int indicatorIndex: 1
 property bool forwardEnabled: false
 signal forward()
 onForward: {
  stack.push("qrc:///qml/billedEntryPage.qml")
 }
 ListView {
  id: jobList
  model: JobModel
  anchors.fill: parent
  // Set this list so the last added items are at top
  verticalLayoutDirection: ListView.BottomToTop
  currentIndex: parseInt(currentBill.billJobId)
  delegate: ItemDelegate {
   anchors.left: parent.left
   anchors.right: parent.right
   highlighted: ListView.isCurrentItem
   Text {
    anchors.left: parent.left
    anchors.top: parent.top
    font.pixelSize: 20
    text: datetime
   }
   Text {
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    font.pixelSize: 14
    elide: Text.ElideRight
    // Remove newlines
    text: description.replace(/(\r\n|\n|\r)/gm, " ")
   }
   onClicked: {
    if (jobList.currentIndex != index) {
     jobList.currentIndex = index
    }
    currentBill.billJobId = String(index)
    parent.parent.parent.forwardEnabled = true
   }
  }
  // This header is added to push the items to the top of the view if there aren't enough to fill the view.
  header: Item {}
  onContentHeightChanged: {
   if (contentHeight < height) {
    headerItem.height += (height - contentHeight)
   }
   currentIndex = count-1
   positionViewAtEnd()
  }
  Component.onCompleted: {
   if (jobList.currentIndex >= 0) {
    parent.forwardEnabled = true
   }
   jobList.positionViewAtEnd()
  }
 }
}

