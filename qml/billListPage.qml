import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: billListPage
 anchors.fill: parent
 property bool backDisabled: true
 property bool addEnabled: true
 property bool settingsEnabled: true
 property bool indicatorEnabled: true
 property int indicatorIndex: 0
 property bool refreshEnabled: true
 signal add()
 onAdd: {
  currentBill.reset()
  if (JobModel.count() > 0) {
   stack.push("qrc:///qml/jobListPage.qml")
  }
  else {
   stack.push(["qrc:///qml/jobListPage.qml", "qrc:///qml/billedEntryPage.qml"])
  }
 }
 Loader {
  id: billLoader
  anchors.fill: parent
  sourceComponent: window.billLoaderSource
 }
}

