import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: billedPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 2
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  currentBill.billed = billed.text
  stack.push("qrc:///qml/paidEntryPage.qml")
 }
 TextField {
  width: parent.width
  id: billed
  placeholderText: "Billed Amount"
 }
 Component.onCompleted: {
  if (currentBill.billed.length > 0) {
   billed.text = currentBill.billed
  }
 }
}
