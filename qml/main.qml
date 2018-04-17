import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

ApplicationWindow {
 id: window
 visible: true
 title: "Billing"
 minimumWidth: 400
 minimumHeight: 400

 Settings {
  id: settings
  property alias x: window.x
  property alias y: window.y
  property alias width: window.width
  property alias height: window.height

  property string billDbType: "postgres"
  property string billDbHost: ""
  property string billDbPort: "5432"
  property string billDbName: ""
  property string billDbUsername: "postgres"
  property string billDbPassword: ""
  property string customerUrl: ""
  property string customerUsername: ""
  property string customerPassword: ""
 }

 Connections {
  target: QmlBridge
  onErrorLoadingBills: {
   window.billLabelMessage = "Error Loading Bills: " + errmsg + "\nHave you set up your server?"
   window.billLoaderSource = billLabel
   window.billsLoaded = 0
  }
  onBillsLoaded: {
   if (count === 0) {
    window.billLabelMessage = "No Bills Available. Use the + button to add a bill."
    window.billLoaderSource = billLabel
   }
   else {
    window.billLoaderSource = Qt.createComponent("qrc:///qml/billList.qml")
   }
   window.billsLoaded = count
  }

  onJobsLoaded: {
   window.jobsLoaded = count
  }

  onError: {
   errorTip.ToolTip.show(errmsg, 3000)
  }
 }

 property var billLoaderSource: billLabel
 property string billLabelMessage: "Loading Bills..."

 Component {
  id: billLabel
  Rectangle {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   Label {
    text: window.billLabelMessage
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 24
   }
  }
 }

 header: ToolBar {
  Material.foreground: "white"
  Label {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   id: titleLabel
   text: "Billing"
   font.pixelSize: 20
   horizontalAlignment: Qt.AlignHCenter
   verticalAlignment: Qt.AlignVCenter
   Layout.fillWidth: true
  }
  ToolButton {
   id: backButton
   visible: !stack.currentItem.backDisabled
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/back.png"
   }
   onClicked: {
    stack.pop()
   }
  }

  ToolButton {
   id: addButton
   visible: stack.currentItem.addEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/plus.png"
   }
   onClicked: {
    stack.currentItem.add()
   }
  }
  ToolButton {
   id: forwardButton
   visible: stack.currentItem.forwardEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/forward.png"
   }
   onClicked: {
    stack.currentItem.forward()
   }
  }

  ToolButton {
   id: settingsButton
   visible: stack.currentItem.settingsEnabled || false
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/settings.png"
   }
   onClicked: {
    stack.push("qrc:///qml/settingsPage.qml")
   }
  }

  ToolButton {
   id: editButton
   visible: stack.currentItem.editEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/edit.png"
   }
   onClicked: {
    stack.currentItem.edit()
   }
  }

  PageIndicator {
   id: editIndicator
   z: 1
   spacing: 10
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.top: titleLabel.bottom
   currentIndex: stack.currentItem.indicatorIndex || false
   visible: stack.currentItem.indicatorEnabled || false
   count: 4
   delegate: Loader {
    property var thisIndex: index
    sourceComponent: {
     switch (index) {
      case 0:
       if (window.billsLoaded > 0) {
        return indicatorRect
       }
       else if (window.billsLoaded === -1) {
        return indicatorLoading
       }
       else {
        return indicatorNa
       }
       break;
      case 1:
       if (window.jobsLoaded > 0) {
        return indicatorRect
       }
       else if (window.jobsLoaded === -1) {
        return indicatorLoading
       }
       else {
        return indicatorNa
       }
       break;
      default:
       return indicatorRect
     }
    }
   }
  }
 }

 property int billsLoaded: -1
 property int jobsLoaded: -1

 Component {
  id: indicatorLoading
  BusyIndicator {
   height: 28
   width: 28
   y: -8
   running: true
   opacity: parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
  }
 }

 Component {
  id: indicatorRect
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 15
    radius: width
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 Component {
  id: indicatorNa
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 5
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 StackView {
  id: stack
  anchors.fill: parent
  initialItem: "qrc:///qml/billListPage.qml"
 }

 Rectangle {
  id: errorTip
  width: parent.width
  anchors.top: parent.bottom
  ToolTip {
   id: errorToolTip
   width: parent.width
   contentItem: Text {
    text: errorToolTip.text
    font: errorToolTip.font
    color: "#000000"
    wrapMode: Text.Wrap
   }
  }
 }

 Item {
  id: currentBill
  property string billJobId: "-1"
  property string billed: ""
  property string paid: ""
  property int index: -1
  signal reset()
  onReset: {
   currentBill.billJobId = "-1"
   currentBill.billed = ""
   currentBill.paid = ""
   currentBill.index = -1
  }
 }

 Component.onCompleted: {
  QmlBridge.loadBills(settings.billDbType,
                      settings.billDbHost,
                      settings.billDbPort,
                      settings.billDbName,
                      settings.billDbUsername,
                      settings.billDbPassword)
  QmlBridge.loadJobs(settings.billDbType,
                      settings.billDbHost,
                      settings.billDbPort,
                      settings.billDbName,
                      settings.billDbUsername,
                      settings.billDbPassword)
  QmlBridge.loadCustomers(settings.customerUrl,
                          settings.customerUsername,
                          settings.customerPassword)
 }

 onClosing: {
  if (Qt.platform.os == "android" && backButton.visible) {
   stack.pop()
   close.accepted = false
  }
 }
}
