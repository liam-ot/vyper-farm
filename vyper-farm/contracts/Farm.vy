# @version ^0.2.0

owner: public(address)
num_farms: public(uint256)
num_farmers: public(uint256)
total_land: public(decimal)
land_available: public(decimal)

event FarmCreated:
    name: indexed(String[256])
    id: indexed(uint256)
    landSize: indexed(decimal)

event FarmerCreated:
    name: indexed(String[256])
    id: indexed(address)
    landSize: indexed(decimal)
    coordinates: decimal[4]

struct farm:
    name: String[256]
    id: uint256
    totalLand: decimal
    landAvailable: decimal
    border: bool

struct farmer: 
    name: String[256]
    id: address
    land: decimal
    coordinates: decimal[4]

idToFarm: HashMap[uint256, farm]
idToFarmer: HashMap[address, farmer]

@external
def __init__():
    self.owner = msg.sender
    self.num_farms = 0
    self.num_farmers = 0

# internal helper functions #


# view functions #
@view
@external
def getFarm(id: uint256) -> farm:
    assert id <= self.num_farms, 'That id is not yet associted with a farm.'
    return self.idToFarm[id]

@view
@external
def getNumFarms() -> uint256:
    return self.num_farms

@view
@external
def getTotalLand() -> decimal:
    return self.total_land

@view
@external
def getLandAvailable() -> decimal:
    return self.land_available

@view
@external
def getNumFarmers() -> uint256:
    return self.num_farmers

@view
@external
def getFarmer(_address: address) -> farmer:
    return self.idToFarmer[_address]

# external use functions #
@external
def createFarm(_name: String[256], _totalLand: decimal, _landAvailable: decimal = 0.0, _border: bool = False) -> bool:
    assert _totalLand > 0.0, 'Farm may not be of zero size to begin.'
    assert _landAvailable >= 0.0, 'You may not lease out a non-positive land amount.'
    
    new_farm: farm = farm({
        name: _name,
        id: self.num_farms,
        totalLand: _totalLand,
        landAvailable: _landAvailable,
        border: _border
    })

    self.idToFarm[self.num_farms] = new_farm

    self.num_farms += 1
    self.land_available += _landAvailable
    self.total_land += _totalLand

    log FarmCreated(_name, self.num_farms, _totalLand)

    return True

@external
def createFarmer(_name: String[256], _id: address, _land: decimal, _coordinates: decimal[4]) -> bool:
    assert _id != ZERO_ADDRESS, 'Zero address not allowed.'
    assert _land > 0.0, 'Lease may not be of zero size to begin.'
    
    new_farmer: farmer = farmer({
        name: _name,
        id: _id,
        land: _land,
        coordinates: _coordinates
    })

    self.idToFarmer[_id] = new_farmer

    self.num_farmers += 1
    self.land_available -= _land

    log FarmerCreated(_name, _id, _land, _coordinates)

    return True