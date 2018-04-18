package main

import (
 "github.com/therecipe/qt/core"
 "github.com/jinzhu/gorm"
 _ "github.com/jinzhu/gorm/dialects/postgres"
 _ "github.com/jinzhu/gorm/dialects/sqlite"
 _ "github.com/jinzhu/gorm/dialects/mysql"
 _ "github.com/jinzhu/gorm/dialects/mssql"
 "errors"
 "unsafe"
)

const (
 BillJobID = int(core.Qt__UserRole) + 1<<iota
 Billed
 Paid
)

type BillModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func() `constructor:"init"`

 _ func(*Bill) `slot:"addBill"`
 _ []*Bill `property:"bills"`

 _ func() `slot:"reset"`
}

func (bm *BillModel) init() {
 bm.SetRoles(map[int]*core.QByteArray{
  BillJobID: core.NewQByteArray2("billJobId", len("billJobId")),
  Billed: core.NewQByteArray2("billed", len("billed")),
  Paid: core.NewQByteArray2("paid", len("paid")),
 })
 bm.ConnectData(bm.data)
 bm.ConnectRowCount(bm.rowCount)
 bm.ConnectRoleNames(bm.roleNames)
 bm.ConnectAddBill(bm.addBill)
 bm.ConnectReset(bm.reset)
}

func (bm *BillModel) roleNames() map[int]*core.QByteArray {
 return bm.Roles()
}

func (bm *BillModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(bm.Bills()) {
  return core.NewQVariant()
 }

 b := bm.Bills()[index.Row()]

 switch role {
  case BillJobID:
   return core.NewQVariant14(b.BillJobID)
  case Billed:
   return core.NewQVariant14(b.Billed)
  case Paid:
   return core.NewQVariant14(b.Paid)
  default:
   return core.NewQVariant()
 }
}

func (bm *BillModel) rowCount(parent *core.QModelIndex) int {
 return len(bm.Bills())
}

type Bill struct {
 gorm.Model

 BillJobID string
 Billed string
 Paid string
}

type BillDB struct {
 dbType string
 dbHost string
 dbPort string
 dbName string
 dbUsername string
 dbPassword string
}

// Opens the database and returns a database object.
// Be sure to call db.Close() when you are done with it.
func (bd *BillDB) Open() (*gorm.DB, error) {
 var db *gorm.DB
 var err error
 switch bd.dbType {
  case "sqlite":
   db, err = gorm.Open("sqlite3", bd.dbHost)
  case "mysql":
   db, err = gorm.Open("mysql", bd.dbUsername + ":" + bd.dbPassword + "@tcp(" + bd.dbHost + ":" + bd.dbPort + ")/" + bd.dbName + "?charset=utf8&parseTime=True&loc=Local")
  case "mssql":
   db, err = gorm.Open("mssql", "sqlserver://" + bd.dbUsername + ":" + bd.dbPassword + "@" + bd.dbHost + ":" + bd.dbPort + "?database=" + bd.dbName)
  default:
   db, err = gorm.Open("postgres", "host=" + bd.dbHost + " port=" + bd.dbPort + " user=" + bd.dbUsername + " dbname=" + bd.dbName + " password=" + bd.dbPassword + " sslmode=disable")
 }
 if err != nil {
  return nil, errors.New("Could not connect to database: " + err.Error())
 }
 return db, nil
}

var billDb BillDB

func (bm *BillModel) loadBillsShim(t string, h string, p string, n string, u string, k string) {
 go bm.loadBills(t, h, p, n, u, k)
}

func (bm *BillModel) loadBills(t string, h string, p string, n string, u string, k string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 billDb = BillDB{t, h, p, n, u, k}
 db, err := billDb.Open()
 if err != nil {
  qmlBridge.ErrorLoadingBills(err.Error())
  return
 }
 defer db.Close()
 if err := db.AutoMigrate(&Bill{}).Error; err != nil {
  qmlBridge.ErrorLoadingBills("Failed to automatically migrate database.")
  return
 }
 var bills []Bill
 if err := db.Order("id").Find(&bills).Error; err != nil {
  qmlBridge.ErrorLoadingBills("Failed to load bills from database.")
  return
 }
 // Convert the array of Bills into an array of *Bills
 pBills := make([]*Bill, len(bills))
 for i, _ := range bills {
  pBills[i] = &bills[i]
 }
 bm.SetBills(pBills)
 qmlBridge.BillsLoaded(len(bm.Bills()))
}

func (bm *BillModel) newBillShim(j string, b string, p string) {
 go bm.buildBill(j, b, p)
}

func (bm *BillModel) buildBill(j string, b string, p string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 db, err := billDb.Open()
 if err != nil {
  qmlBridge.Error(err.Error())
  return
 }
 defer db.Close()
 bill := Bill{BillJobID: j, Billed: b, Paid: p}
 if (len(bm.Bills()) >= 1) {
  qmlBridge.BillsLoaded(len(bm.Bills()))
 }
 if err := db.Create(&bill); err.Error != nil {
  qmlBridge.Error("Could not create bill: " + err.Error.Error())
  return
 }
 bm.AddBill(&bill)
}

func (bm *BillModel) addBill(b *Bill) {
 bm.BeginInsertRows(core.NewQModelIndex(), len(bm.Bills()), len(bm.Bills()))
 bm.SetBills(append(bm.Bills(), b))
 bm.EndInsertRows()
 if (len(bm.Bills()) == 1) {
  qmlBridge.BillsLoaded(len(bm.Bills()))
 }
}

func (bm *BillModel) editBillShim(i int, j string, b string, p string) {
 go bm.editBill(i, j, b, p)
}

func (bm *BillModel) editBill(i int, j string, b string, p string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 if i < 0 || i >= len(bm.Bills()) {
  qmlBridge.Error("Could not edit job: Index not found.")
  return
 }
 db, err := billDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to edit bil: " + err.Error())
  return
 }
 defer db.Close()
 nr := bm.Bills()[i]
 nr.BillJobID = j
 nr.Billed = b
 nr.Paid = p
 if err := db.Save(nr); err.Error != nil {
  qmlBridge.Error("Could not save bill: " + err.Error.Error())
  return
 }
 nb := bm.Bills()
 nb[i] = nr
 bm.SetBills(nb)
 bm.DataChanged(bm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), bm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), []int{BillJobID, Billed, Paid})
}

func (bm *BillModel) removeBillShim(i int) {
 go bm.removeBill(i)
}

func (bm *BillModel) removeBill(i int) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 if i < 0 || i >= len(bm.Bills()) {
  qmlBridge.Error("Could not delete bill: Index not found.")
  return
 }
 db, err := billDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to delete bill: " + err.Error())
  return
 }
 defer db.Close()
 if err := db.Delete(bm.Bills()[i]); err.Error != nil {
  qmlBridge.Error("Could not delete bill: " + err.Error.Error())
  return
 }
 bm.BeginRemoveRows(core.NewQModelIndex(), i, i)
 bm.SetBills(append(bm.Bills()[:i], bm.Bills()[i+1:]...))
 bm.EndRemoveRows()
}

func (bm *BillModel) update() {
 bm.DataChanged(bm.CreateIndex(0, 0, unsafe.Pointer(new(uintptr))), bm.CreateIndex(len(bm.Bills()) - 1, 0, unsafe.Pointer(new(uintptr))), []int{BillJobID, Billed, Paid})
}

func (bm *BillModel) reset() {
 bm.BeginRemoveRows(core.NewQModelIndex(), 0, len(bm.Bills()) - 1)
 bm.SetBills([]*Bill{})
 bm.EndRemoveRows()
}
