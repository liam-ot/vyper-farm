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
    location: String[1024]
    employees: uint256[32]
    wallet: address

#employee struct
struct employee:
    id: uint256
    name: String[128]
    wallet: address

#item struct
struct item:
    id: uint256
    category: uint256
    name: String[256]
    price: decimal

#data tracking
idToItem: HashMap[uint256, item]
idToCategory: HashMap[uint256, String[256]]
idToEmployee: HashMap[uint256, employee]
standInfo: HashMap[uint256, farmStand]

#initialize global data
@external
def __init__():
    self.owner = msg.sender
    self.num_categories = 0
    self.num_items = 0
    self.stand_created = False
    self.num_employees = 0

# internal functions #
@view
@internal
def _getItem(_id: uint256) -> item:
    #check for faulty id
    assert _id <= self.num_items, 'Item id not valid.'

    #return item
    return self.idToItem[_id]

@view
@internal
def _getCategory(_id: uint256) -> String[256]:
    #check for faulty id
    assert _id <= self.num_categories, 'Category id not valid.'

    #return category name: String[256]
    return self.idToCategory[_id]

@internal
def _setItem(_category: uint256, _name: String[256], _price: decimal) -> bool:
    #check for faulty data
    assert _category <= self.num_categories, 'Category is not valid.'
    assert len(_name) <= 256, 'Name is too long. Must be < 256 characters.'
    assert _price > 0.0, 'Cannot have a zero, or less, costing item.'

    #create item
    new_item: item = item ({
        id: self.num_items,
        category: _category,
        name: _name,
        price: _price
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
def _payEmployee(_id: uint256, _value: uint256) -> bool:
    assert _id <= self.num_employees, 'Invalid employee id.'

    send(self.idToEmployee[_id].wallet, _value)

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

@internal
def _createFarmStand(_name: String[256], _location: String[1024], _wallet: address) -> bool:
    #check data
    assert len(_name) <= 256, 'Name must be less than 256 characters.'
    assert len(_location) <= 1024, 'Location must be less than 1024 characters.'
    assert _wallet == self.owner, 'Address does not match contract owner.'
    assert self.stand_created == False, 'Farm stand already created on this contract.'

    #create farmStand object
    new_stand: farmStand = farmStand({
        name: _name,
        location: _location,
        employees: empty(uint256[32]),
        wallet: _wallet
    })

    #track farm stand
    self.standInfo[0] = new_stand

    #set creation boolean
    self.stand_created = True

    #return success boolean
    return True

@internal
def _employ(_name: String[128], _wallet: address) -> bool:
    #check data
    assert len(_name) <= 128, 'Name cannot be longer than 128 characters.'
    assert _wallet != ZERO_ADDRESS, 'Zero address not valid for wallet.'
    assert self.num_employees < 32, 'Cannot employ more than 32 people.'

    #create employee object
    new_employee: employee = employee({
        id: self.num_employees,
        name: _name,
        wallet: _wallet
    })

    #track new employee
    self.idToEmployee[self.num_employees] = new_employee

    #update records
    self.num_employees += 1

    #return success boolean
    return True

@internal
def _transferOwnership(_from: address, _to: address) -> bool:
    #ensure the person changing it is the owner
    assert _from == self.owner
    
    #transfer ownership
    self.owner = _to

    #return success boolean
    return True

#############################WARNING##################################
#THIS WILL DESTROY THE CONTRACT AND SEND TOTAL ETHER BALANCE TO '_to'#
#############################WARNING##################################
@internal
def _destroyContract(_to: address):
    assert _to == self.owner, 'Only the owner may terminate their farm stand.'

    selfdestruct(_to)