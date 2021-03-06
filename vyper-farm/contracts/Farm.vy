#@version ^0.2.0

#only allows one stand per contract
stand_created: public(bool)
#tracks num of items, used to track items in idToItem hashmap
num_items: public(uint256)
#tracks num of categoriesz, used to track categories in idToCategory hashmap
num_categories: public(uint256)
#tracks num of employees, used to track employees in idToEmployee
num_employees: public(uint256)
#contract owner, used for permissions checking and self destruct
owner: address

#fires when item created
event NewItem:
    id: indexed(uint256)
    name: indexed(String[256])

#farmStand struct
struct farmStand:
    name: String[256]
    location: String[512]
    wallet: address

#employee struct
struct employee:
    id: uint256
    name: String[128]
    wallet: address
    status: String[32]

#item struct
struct item:
    id: uint256
    category: uint256
    name: String[256]
    price: decimal
    sales: uint256
    status: String[8]

#data tracking
idToItem: HashMap[uint256, item]
idToCategory: HashMap[uint256, String[256]]
idToEmployee: HashMap[uint256, employee]
standInfo: farmStand[1]

#initialize global data
@external
def __init__():
    self.owner = msg.sender
    self.num_categories = 0
    self.num_items = 0
    self.stand_created = False
    self.num_employees = 0

# internal functions #

#
#   get/set functions
#

@view
@internal
def _getItem(_id: uint256) -> item:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item
    return self.idToItem[_id]

@view
@internal
def _getItemName(_id: uint256) -> String[256]:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item name
    return self.idToItem[_id].name

@view
@internal
def _getItemPrice(_id: uint256) -> decimal:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item price
    return self.idToItem[_id].price

@view
@internal
def _getItemCategory(_id: uint256) -> uint256:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item category
    return self.idToItem[_id].category

@view
@internal
def _getItemSales(_id: uint256) -> uint256:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item sales
    return self.idToItem[_id].sales

@view
@internal
def _getItemStatus(_id: uint256) -> String[8]:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item status
    return self.idToItem[_id].status

@view
@internal
def _getCategoryName(_id: uint256) -> String[256]:
    #check for faulty id
    assert _id <= self.num_categories, 'Category id not valid.'

    #return category name: String[256]
    return self.idToCategory[_id]

@view
@internal
def _getEmployee(_id: uint256) -> employee:
    #check for faulty id
    assert _id <= self.num_employees, 'Employee id not valid.'

    #return employee
    return self.idToEmployee[_id]

@view
@internal
def _getEmployeeStatus(_id: uint256) -> String[32]:
    #check for faulty id
    assert _id <= self.num_employees, 'Employee id not valid.'

    #return employee status: String[32]
    return self.idToEmployee[_id].status

@internal
def _setItem(_category: uint256, _name: String[256], _price: decimal, _sales: uint256, _status: String[8]) -> bool:
    #check for faulty data
    assert _category <= self.num_categories, 'Category is not valid.'
    assert len(_name) <= 256, 'Name is too long. Must be < 256 characters.'
    assert _price > 0.0, 'Price may not be less than or equal to zero.'
    assert len(_status) <= 8, 'Status must be either "Active" or "Inactive".'

    #create item
    new_item: item = item ({
        id: self.num_items,
        category: _category,
        name: _name,
        price: _price,
        sales: _sales,
        status: _status
    })

    #track changes
    self.idToItem[self.num_items] = new_item

    #log event
    log NewItem(self.num_items, _name)
    
    #update records
    self.num_items += 1

    #confirm success
    return True

@internal
def _setCategory(_name: String[256]) -> bool:
    assert len(_name) <= 256, 'Name is too long. Must be < 256 characters.'

    #track changes
    self.idToCategory[self.num_categories] = _name

    #update records
    self.num_categories += 1

    #confirm success
    return True

#
#    farm stand functions
#

#tested
@internal
def _createFarmStand(_name: String[256], _location: String[512], _wallet: address) -> bool:
    #check data
    assert len(_name) <= 256, 'Name must be less than 256 characters.'
    assert len(_location) <= 512, 'Location must be less than 512 characters.'
    assert _wallet == self.owner, 'Address does not match contract owner.'
    assert self.stand_created == False, 'Farm stand already created on this contract.'

    #create farmStand object
    new_stand: farmStand = farmStand({
        name: _name,
        location: _location,
        wallet: _wallet
    })

    #track farm stand
    self.standInfo[0] = new_stand

    #set creation boolean
    self.stand_created = True

    #return success boolean
    return True

@internal
def _transferOwnership(_from: address, _to: address) -> bool:
    #ensure the person changing it is the owner
    assert _from == self.owner, 'Only the owner may transfer ownership.'
    assert _to != ZERO_ADDRESS, 'You may not transfer ownership to a ZERO_ADDRESS.'
    
    #transfer ownership
    self.owner = _to

    #return success boolean
    return True


#
#    employee functions
#

@internal
def _employ(_name: String[128], _wallet: address) -> bool:
    #check data
    assert len(_name) <= 128, 'Name may not be longer than 128 characters.'
    assert _wallet != ZERO_ADDRESS, 'ZERO_ADDRESS not valid for wallet.'
    #create employee object
    new_employee: employee = employee({
        id: self.num_employees,
        name: _name,
        wallet: _wallet,
        status: 'Hired'
    })

    #track new employee
    self.idToEmployee[self.num_employees] = new_employee

    #update records
    self.num_employees += 1

    #return success boolean
    return True

@internal
def _payEmployee(_id: uint256, _value: uint256) -> bool:
    assert _id <= self.num_employees, 'Invalid employee id.'

    send(self.idToEmployee[_id].wallet, _value)

    return True

@internal
def _fire(_id: uint256, _owner: address, _reason: String[32]) -> bool:
    #check data
    assert _id <= self.num_employees, 'Invalid employee id.'
    assert _owner == self.owner, 'Only the owner may fire an employee.'
    assert len(_reason) <= 32, 'Reason must be less than 32 characters.'

    #set employee status
    #should be 'Fired' or 'Quit'
    self.idToEmployee[_id].status = _reason

    #track changes
    self.idToEmployee[_id] = empty(employee)

    #update records
    self.num_employees -= 1

    #return success boolean
    return True

#
#    destroy contract
#

#############################WARNING##################################
#THIS WILL DESTROY THE CONTRACT AND SEND TOTAL ETHER BALANCE TO '_to'#
#############################WARNING##################################
@internal
def _destroyContract(_to: address):
    #check data
    assert _to == self.owner, 'Only the owner may terminate their farm stand.'

    #call built in selfdestruct function
    selfdestruct(_to)

#external functions

@view
@external
def getItem(id: uint256) -> item:
    return self._getItem(id)

@view
@external
def getItemName(id: uint256) -> String[256]:
    return self._getItemName(id)

@view
@external
def getItemCategory(id: uint256) -> uint256:
    return self._getItemCategory(id)

@view
@external
def getItemPrice(id: uint256) -> decimal:
    return self._getItemPrice(id)

@view
@external
def getItemSales(id: uint256) -> uint256:
    return self._getItemSales(id)

@view
@external
def getItemStatus(id: uint256) -> String[8]:
    return self._getItemStatus(id)

@view
@external
def getCategory(id: uint256) -> String[256]:
    return self._getCategoryName(id)

@view
@external
def getEmployee(id: uint256) -> employee:
    return self._getEmployee(id)

@view
@external
def getEmployeeStatus(id: uint256) -> String[32]:
    return self._getEmployeeStatus(id)

@view
@external
def getNumEmployees() -> uint256:
    return self.num_employees

@view
@external
def getNumItems() -> uint256:
    return self.num_items

@view
@external
def getNumCategories() -> uint256:
    return self.num_categories

@view
@external
def getStandStatus() -> bool:
    return self.stand_created

@view
@external
def getStandName() -> String[256]:
    return self.standInfo[0].name

@view
@external
def getStandLocation() -> String[512]:
    return self.standInfo[0].location

@view
@external
def getStandWallet() -> address:
    return self.standInfo[0].wallet

@view
@external
def getOwner() -> address:
    return self.owner

@external
def setItem(category: uint256, name: String[256], price: decimal, sales: uint256, status: String[8]) -> bool:
    return self._setItem(category, name, price, sales, status)

@external
def setCategory(name: String[256]) -> bool:
    return self._setCategory(name)

@external
def createFarmStand(name: String[256], location: String[512], wallet: address) -> bool:
    return self._createFarmStand(name, location, wallet)

@external
def employ(name: String[128], wallet: address) -> bool:
    return self._employ(name, wallet)

@external
def payEmployee(id: uint256, _value: uint256) -> bool:
    return self._payEmployee(id, _value)

@external
def fire(id: uint256, owner: address, reason: String[32]) -> bool:
    return self._fire(id, owner, reason)

@external
def transferOwnership(_from: address, to: address) -> bool:
    return self._transferOwnership(_from, to)

@external
def destroyContract(to: address) -> bool:
    self._destroyContract(to)

    return True