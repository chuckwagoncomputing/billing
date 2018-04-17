import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.3

Rectangle {
 id: settingsPage
 anchors.fill: parent
 property bool forwardEnabled: false

 TabBar {
  id: settingsTabs
  width: parent.width
  z: 1
  TabButton {
   text: "Bills"
  }
  TabButton {
   text: "Customers"
  }
 }
 StackLayout {
  id: settingsStack
  anchors.top: settingsTabs.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  currentIndex: settingsTabs.currentIndex
  Item {
   id: billsSettingsPage
   Column {
    width: parent.width
    ComboBox {
     id: billDbTypeField
     width: parent.width
     model: ["postgres", "mysql", "mssql", "sqlite3"]
     Component.onCompleted: {
      billDbTypeField.currentIndex = billDbTypeField.find(settings.billDbType)
     }
    }
    TextField {
     id: billDbHostField
     width: parent.width
     placeholderText: "Host/URL"
     text: settings.billDbHost
    }
    TextField {
     id: billDbPortField
     width: parent.width
     placeholderText: "Port"
     text: settings.billDbPort
    }
    TextField {
     id: billDbNameField
     width: parent.width
     placeholderText: "DB Name"
     text: settings.billDbName
    }
    TextField {
     id: billDbUsernameField
     width: parent.width
     placeholderText: "Username"
     text: settings.billDbUsername
    }
    TextField {
     id: billDbPasswordField
     width: parent.width
     echoMode: TextInput.Password
     placeholderText: "Password"
     text: settings.billDbPassword
    }
   }
  }
  Item {
   id: customerSettingsPage
   Column {
    width: parent.width
    TextField {
     id: customerUrlField
     width: parent.width
     placeholderText: "URL"
     text: settings.customerUrl
    }
    TextField {
     id: customerUsernameField
     width: parent.width
     placeholderText: "Username"
     text: settings.customerUsername
    }
    TextField {
     id: customerPasswordField
     width: parent.width
     placeholderText: "Password"
     echoMode: TextInput.Password
     text: settings.customerPassword
    }
   }
  }
 }
 StackView.onStatusChanged: {
  // Check for changes and save them
  if (StackView.status === StackView.Deactivating) {
   var billDbChanged, customerChanged = false
   if (settings.billDbType != billDbTypeField.currentText) {
    settings.billDbType = billDbTypeField.currentText
    billDbChanged = true
   }
   if (settings.billDbHost != billDbHostField.text) {
    settings.billDbHost = billDbHostField.text
    billDbChanged = true
   }
   if (settings.billDbPort != billDbPortField.text) {
    settings.billDbPort = billDbPortField.text
    billDbChanged = true
   }
   if (settings.billDbName != billDbNameField.text) {
    settings.billDbName = billDbNameField.text
    billDbChanged = true
   }
   if (settings.billDbUsername != billDbUsernameField.text) {
    settings.billDbUsername = billDbUsernameField.text
    billDbChanged = true
   }
   if (settings.billDbPassword != billDbPasswordField.text) {
    settings.billDbPassword = billDbPasswordField.text
    billDbChanged = true
   }
   if (settings.customerUrl != customerUrlField.text) {
    settings.customerUrl = customerUrlField.text
    customerChanged = true
   }
   if (settings.customerUsername != customerUsernameField.text) {
    settings.customerUsername = customerUsernameField.text
    customerChanged = true
   }
   if (settings.customerPassword != customerPasswordField.text) {
    settings.customerPassword = customerPasswordField.text
    customerChanged = true
   }
   if (billDbChanged) {
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
    window.billLabelMessage = "Loading Bills..."
    window.billLoaderSource = billLabel
    window.billsLoaded = -1
    window.jobsLoaded = -1
   }
   if (customerChanged) {
    CustomerModel.reset()
    QmlBridge.loadCustomers(settings.customerUrl,
                            settings.customerUsername,
                            settings.customerPassword)
   }
  }
 }
}
