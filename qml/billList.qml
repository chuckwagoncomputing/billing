import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

ListView {
 id: billList
 model: BillModel
 verticalLayoutDirection: ListView.BottomToTop
 delegate: ItemDelegate {
  anchors.left: parent.left
  anchors.right: parent.right
  Text {
   anchors.left: parent.left
   anchors.top: parent.top
   font.pixelSize: 20
   text: CustomerModel.getData(JobModel.getData(parseInt(billJobId), 0), 1)
  }
  Text {
   anchors.left: parent.left
   anchors.bottom: parent.bottom
   font.pixelSize: 14
   elide: Text.ElideRight
   text: Number(paid) + "/" + Number(billed) + " paid"
  }
  onClicked: {
   if (billList.currentIndex != index) {
    billList.currentIndex = index
   }
   currentBill.billJobId = model.billJobId
   currentBill.billed = model.billed
   currentBill.paid = model.paid
   currentBill.index = index
   stack.push("qrc:///qml/billViewPage.qml")
  }
 }
 header: Item {}
 onContentHeightChanged: {
  if (contentHeight < height) {
   headerItem.height += (height - contentHeight)
  }
  currentIndex = count-1
  positionViewAtEnd()
 }
 Component.onCompleted: {
  billList.positionViewAtEnd()
 }
}
