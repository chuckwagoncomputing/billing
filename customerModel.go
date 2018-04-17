package main

import (
 "io"
 "os"
 "github.com/therecipe/qt/core"
 dav "github.com/chuckwagoncomputing/gowebdav"
 "github.com/chuckwagoncomputing/vcard-go"
 "bytes"
 "strings"
)

const (
 CustomerID = int(core.Qt__UserRole) + 1<<iota
 CustomerName
 CustomerAddress
)

type CustomerModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func() `constructor:"init"`

 _ func(*Customer) `slot:"addCustomer"`
 _ []*Customer `property:"customers"`

 _ func(id string) int `slot:"findIndex"`
 _ func(id string, role int) *core.QVariant `slot:"getData"`

 _ func() int `slot:"count"`

 _ func() `slot:"reset"`
}

func (cm *CustomerModel) init() {
 cm.SetRoles(map[int]*core.QByteArray{
  CustomerID: core.NewQByteArray2("customerId", len("customerId")),
  CustomerName: core.NewQByteArray2("customerName", len("customerName")),
  CustomerAddress: core.NewQByteArray2("customerAddress", len("customerAddress")),
 })
 cm.ConnectData(cm.data)
 cm.ConnectRowCount(cm.rowCount)
 cm.ConnectRoleNames(cm.roleNames)
 cm.ConnectAddCustomer(cm.addCustomer)
 cm.ConnectFindIndex(cm.find)
 cm.ConnectGetData(cm.getData)
 cm.ConnectCount(cm.count)
 cm.ConnectReset(cm.reset)
}

func (cm *CustomerModel) roleNames() map[int]*core.QByteArray {
 return cm.Roles()
}

func (cm *CustomerModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(cm.Customers()) {
  return core.NewQVariant()
 }

 c := cm.Customers()[index.Row()]

 switch role {
  case CustomerID:
   return core.NewQVariant14(c.CustomerID)
  case CustomerName:
   return core.NewQVariant14(c.CustomerName)
  default:
   return core.NewQVariant()
 }
}

func (cm *CustomerModel) rowCount(parent *core.QModelIndex) int {
 return len(cm.Customers())
}

func (cm *CustomerModel) count() int {
 return len(cm.Customers())
}

// Find index by UID, e.g. 6d402d14-d0b9-4dba-91a8-4039fd76c9a0.vcf
func (cm *CustomerModel) find(id string) int {
 for i, c := range cm.Customers() {
  if c.CustomerID == id {
   return i
  }
 }
 return -1
}

// Get data by UID and role int. I haven't figured out yet how roles are assigned,
//  so this is kind of magic-number stuff
func (cm *CustomerModel) getData(id string, role int) *core.QVariant {
 i := cm.find(id)
 if i < 0 {
  return core.NewQVariant14("Customer Not Loaded")
 }
 switch role + CustomerID {
  case CustomerID:
   return core.NewQVariant14(cm.Customers()[i].CustomerID)
  case CustomerName:
   return core.NewQVariant14(cm.Customers()[i].CustomerName)
  case CustomerAddress:
   return core.NewQVariant14(cm.Customers()[i].CustomerAddress)
  default:
   return core.NewQVariant()
 }
}

type Customer struct {
 CustomerID string
 CustomerName string
 CustomerAddress string
}

func (cm *CustomerModel) loadCustomersShim(cUrl string, cUsername string, cPassword string) {
 go cm.loadCustomers(cUrl, cUsername, cPassword)
}

func (cm *CustomerModel) loadCustomers(cUrl string, cUsername string, cPassword string) {
 client := dav.NewClient(cUrl, cUsername, cPassword)
 if err := client.Connect(); err != nil {
  return
 }
 files, err := client.ReadDir("/")
 if err != nil {
  return
 }
 for i, f := range files {
  data, err := client.Read(f.Name())
  if err != nil {
   return
  }
  go cm.parseCustomer(bytes.NewReader(data), i, f)
 }
}

func (cm *CustomerModel) parseCustomer(data io.Reader, i int, f os.FileInfo) {
 vcards, err := vcard.GetVCardsByReader(data)
 if err != nil {
  return
 }
 cm.AddCustomer(&Customer{CustomerID: f.Name(), CustomerName: vcards[0].FormattedName, CustomerAddress: vcards[0].Addr})
}

func (cm *CustomerModel) addCustomer(c *Customer) {
 begin := len(cm.Customers())
 // Loop through until we find where the customer should be inserted for proper sorting.
 for i := 0; i < len(cm.Customers()); i++ {
  if strings.ToLower(cm.Customers()[i].CustomerName) > strings.ToLower(c.CustomerName) {
   begin = i
   break
  }
 }
 cm.BeginInsertRows(core.NewQModelIndex(), begin, begin)
 s := append(cm.Customers(), &Customer{"","",""})
 copy(s[begin+1:], s[begin:])
 s[begin] = c
 cm.SetCustomers(s)
 cm.EndInsertRows()
 billModel.update()
}

func (cm *CustomerModel) reset() {
 cm.BeginRemoveRows(core.NewQModelIndex(), 0, len(cm.Customers()) - 1)
 cm.SetCustomers([]*Customer{})
 cm.EndRemoveRows()
}
