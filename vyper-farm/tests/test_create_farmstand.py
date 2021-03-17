import brownie
from brownie import accounts, Farm
from brownie.test import given, strategy
import pytest

# contract deployment fixture #

@pytest.fixture
def deploy():
    return Farm.deploy({'from':accounts[0]})

# happy results #

def test_stand_created_status_updates(deploy):
    deploy.createFarmStand('My Farm Stand', '123 Some Road West Virginia, 52634', accounts[0])
    
    status = deploy.getStandStatus()

    assert status == True

def test_stand_created_owner_updates(deploy):
    deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', accounts[0])
    
    owner = deploy.getOwner()

    assert owner == accounts[0]

@given(test_name=strategy('string', max_size=256))
def test_stand_name_set(deploy, test_name):
    deploy.createFarmStand(test_name, '123 Valid Location State, 00000', accounts[0])
    
    standName = deploy.getStandName()

    assert standName == test_name

@given(test_location=strategy('string', max_size=1024))
def test_stand_location_set(deploy, test_location):
    deploy.createFarmStand('My Farm Stand', test_location, accounts[0])
    
    standLocation = deploy.getStandLocation()

    assert standLocation == test_location

def test_stand_wallet_set(deploy):
    wallet = accounts[0]

    deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', wallet)
    
    standWallet = deploy.getStandWallet()

    assert standWallet == wallet

# unhappy results #

@given(test_location_fail=strategy('string', min_size=513, max_size=514))
def test_stand_created_location_length(deploy, test_location_fail):
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand', test_location_fail, accounts[0])

def test_stand_created_owner_verification(deploy):
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', accounts[9])

@given(test_name_fail=strategy('string', min_size=257, max_size=258))
def test_stand_created_name_length(deploy, test_name_fail):
    with brownie.reverts():
        deploy.createFarmStand(test_name_fail, '123 Valid Location State, 00000', accounts[0])

def test_stand_created_status_verification(deploy):
    deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', accounts[0])
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand 2', '123 Valid Location State, 00000', accounts[0])
