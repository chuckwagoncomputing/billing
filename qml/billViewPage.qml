import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: billViewPage
 anchors.fill: parent
 property bool forwardEnabled: false
 property bool editEnabled: true
 signal edit()
 onEdit: {
  if (JobModel.count() > 0) {
   stack.push("qrc:///qml/jobListPage.qml")
  }
  else {
   stack.push("qrc:///qml/billedEntryPage.qml")
  }
 }
 ScrollView {
  anchors.top: parent.top
  anchors.bottom: copyButton.top
  width: parent.width
  Label {
   id: customerNameLabel
   width: parent.width
   text: CustomerModel.getData(JobModel.getData(parseInt(currentBill.billJobId), 0), 1)
   font.pixelSize: 26
   anchors.margins: 10
  }
  Label {
   id: billedLabel
   anchors.top: customerNameLabel.bottom
   width: parent.width
   text: "Billed: " + Number(currentBill.billed)
   font.pixelSize: 20
   anchors.margins: 10
  }
  Label {
   id: paidLabel
   anchors.top: billedLabel.bottom
   width: parent.width
   text: "Paid: " + Number(currentBill.paid)
   font.pixelSize: 20
   anchors.margins: 10
  }
  Label {
   id: descriptionLabel
   anchors.top: paidLabel.bottom
   width: parent.width
   text: JobModel.getData(parseInt(currentBill.billJobId), 7)
   wrapMode: Text.Wrap
   font.pixelSize: 18
   anchors.margins: 10
  }
 }
 Button {
  id: copyButton
  text: "Copy CSV"
  width: parent.width
  anchors.bottom: deleteButton.top
  onClicked: {
   var addrLine = CustomerModel.getData(JobModel.getData(parseInt(currentBill.billJobId), 0), 3)
   var addr = addrLine.split(";");
   var address = "";
   var city = "";
   var state = "";
   var zip = "";

   if (addr.length > 1) {
    if (addr[2].length > 0 && addr[3].length > 0) {
     address = addr[2];
    }

    if (addr[3].length > 0) {
     city = addr[3];
    }

    if (addr[4].length > 0) {
     state = addr[4];
    }

    if (addr[5].length > 0) {
     zip = addr[5];
    }

    if (address.length === 0 && city.length === 0) {
     var cutAddr = addr[2].split(" ").reverse();
     zip = cutAddr[0];
     state = cutAddr[1];
     city = cutAddr[2];
     address = cutAddr.slice(3).reverse().join(" ");
    }
   }
   var custom = JSON.parse(JobModel.getData(parseInt(currentBill.billJobId), 3))
   var csvText = "billed,paid,datetime,customername,customeraddress,customercity,customerstate,customerzip"
   for (var i = 0; i < Object.keys(custom).length; i++) {
    csvText += "," + Object.keys(custom)[i]
   }
   csvText += "\n"
   csvText += '"'
            + currentBill.billed
            + '","'
            + currentBill.paid
            + '","'
            + JobModel.getData(parseInt(currentBill.billJobId), 1)
            + '","'
            + CustomerModel.getData(JobModel.getData(parseInt(currentBill.billJobId), 0), 1)
            + '","'
            + address
            + '","'
            + city
            + '","'
            + state
            + '","'
            + zip
            + '"'
   for (var i = 0; i < Object.keys(custom).length; i++) {
    csvText += ',"' + custom[Object.keys(custom)[i]] + '"'
   }
   QmlBridge.copyText(csvText)
  }
 }
 Button {
  id: deleteButton
  text: "Delete"
  width: parent.width
  anchors.bottom: parent.bottom
  onClicked: {
   QmlBridge.removeBill(currentBill.index)
   stack.pop()
  }
 }
}
