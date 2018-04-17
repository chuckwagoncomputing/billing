import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: paidPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 3
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  currentBill.paid = paid.text
  if (currentBill.index < 0) {
   QmlBridge.newBill(currentBill.billJobId, currentBill.billed, currentBill.paid)
  }
  else {
   QmlBridge.editBill(currentBill.index, currentBill.billJobId, currentBill.billed, currentBill.paid)
  }
  stack.push("qrc:///qml/billListPage.qml")
 }
 TextField {
  width: parent.width
  id: paid
  placeholderText: "Paid Amount"
 }
 Component.onCompleted: {
  if (currentBill.paid.length > 0) {
   paid.text = currentBill.paid
  }
 }
}
