package main

import (
 "os"
 "github.com/therecipe/qt/core"
 "github.com/therecipe/qt/gui"
 "github.com/therecipe/qt/qml"
 "github.com/therecipe/qt/quickcontrols2"
 "sync"
)

type QmlBridge struct {
 core.QObject

 _ func(errmsg string) `signal:"error"`

 _ func(t string, h string, p string, n string, u string, k string) `slot:"loadBills"`
 _ func(count int) `signal:"billsLoaded"`
 _ func(errmsg string) `signal:"errorLoadingBills"`
 _ func(j string, b string, p string) `slot:"newBill"`
 _ func(i int, j string, b string, p string) `slot:"editBill"`
 _ func(i int) `slot:"removeBill"`

 _ func(jdType string, jdHost string, jdPort string, jdName string, jdUsername string, jdPassword string) `slot:"loadJobs"`
 _ func(count int) `signal:"jobsLoaded"`

 _ func(cUrl string, cUsername string, cPassword string) `slot:"loadCustomers"`

 _ func(t string) `slot:"copyText"`
}

var qmlBridge *QmlBridge
var billModel *BillModel
var jobModel *JobModel
var customerModel *CustomerModel

// dbMutex is for controlling DB access.
var dbMutex sync.Mutex

var app *gui.QGuiApplication

func main() {
 qmlBridge = NewQmlBridge(nil)
 billModel = NewBillModel(nil)
 jobModel = NewJobModel(nil)
 customerModel = NewCustomerModel(nil)

 core.QCoreApplication_SetAttribute(core.Qt__AA_EnableHighDpiScaling, true)
 app = gui.NewQGuiApplication(len(os.Args), os.Args)
 quickcontrols2.QQuickStyle_SetStyle("material")
 view := qml.NewQQmlApplicationEngine(nil)

 qmlBridge.ConnectLoadBills(billModel.loadBillsShim)
 qmlBridge.ConnectNewBill(billModel.newBillShim)
 qmlBridge.ConnectEditBill(billModel.editBillShim)
 qmlBridge.ConnectRemoveBill(billModel.removeBillShim)
 qmlBridge.ConnectLoadJobs(jobModel.loadJobsShim)
 qmlBridge.ConnectLoadCustomers(customerModel.loadCustomersShim)
 qmlBridge.ConnectCopyText(copyText)

 view.RootContext().SetContextProperty("QmlBridge", qmlBridge)
 view.RootContext().SetContextProperty("BillModel", billModel)
 view.RootContext().SetContextProperty("JobModel", jobModel)
 view.RootContext().SetContextProperty("CustomerModel", customerModel)

 view.Load(core.NewQUrl3("qrc:///qml/main.qml", 0))
 gui.QGuiApplication_Exec()
}

func copyText(t string) {
 clipboard := app.Clipboard()
 clipboard.SetText(t, gui.QClipboard__Clipboard)
}

