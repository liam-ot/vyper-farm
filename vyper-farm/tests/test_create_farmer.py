import brownie
from brownie import accounts, Farm
import pytest

# contract deployment fixture #

@pytest.fixture
def deploy():
    return Farm.deploy({'from':accounts[0]})

# happy results #

def test_create_farmer_adjusts_farmer_count(deploy):
    num_f = deploy.getNumFarmers()
    deploy.createFarmer('Farmer0', accounts[1], '25.0', ['0.0', '25.0', '25.0', '0.0'])

    assert deploy.getNumFarmers() == num_f + 1

def test_create_farmer_adjusts_land_available(deploy):
    land = deploy.getLandAvailable()
    land_deducted = '25.0'
    deploy.createFarmer('Farmer1', accounts[2], land_deducted, ['0.0', '25.0', '25.0', '0.0'])

    assert deploy.getLandAvailable() == land - land_deducted

def test_create_farmer_adds_farmerid(deploy):
    null_farmer = deploy.getFarmer(accounts[3])
    deploy.createFarmer('Farmer1', accounts[3], '25.0', ['25.0', '0.0', '0.0', '25.0'])

    assert deploy.getFarmer(accounts[3]) != null_farmer

# sad results #

def test_zero_address_fails(deploy):
    with brownie.reverts("Zero address not allowed."):
        result = deploy.createFarmer('NullFarmer', '0x0000000000000000000000000000000000000000', '50.0', ['50.0', '50.0', '100.0', '100.0'])

def test_zero_land_fails(deploy):
    with brownie.reverts("Lease may not be of zero size to begin."):
        result = deploy.createFarmer('NullFarmer', accounts[4], '0.0', ['0.0', '0.0', '0.0', '0.0'])
