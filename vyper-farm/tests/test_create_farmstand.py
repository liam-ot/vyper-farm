import brownie
from brownie import accounts, Farm
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

def test_stand_name_set(deploy):
    name = 'My Farm Stand'

    deploy.createFarmStand(name, '123 Valid Location State, 00000', accounts[0])
    
    standName = deploy.getStandName()

    assert standName == name

def test_stand_location_set(deploy):
    location = '123 Valid Location State, 00000'

    deploy.createFarmStand('My Farm Stand', location, accounts[0])
    
    standLocation = deploy.getStandLocation()

    assert standLocation == location

def test_stand_wallet_set(deploy):
    wallet = accounts[0]

    deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', wallet)
    
    standWallet = deploy.getStandWallet()

    assert standWallet == wallet

# unhappy results #

def test_stand_created_location_length(deploy):
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand', 'ax2aBrlbijRUBCGSCKsMmY3nmLHTKeL6fakJ94huAS9s7nsFjEmMUAg8nAYGldygkhdG4n0CUi0eyXzbpCaOnsrCLWR0nYl5DQecy2hNb9LImZd6miPEh8kdVSyAOkV2yd7xe8owMo6VCro7DdLdqLdPHcuJd6t0pLvkLBdSm8uMeROkXyuSlfz1fkF5fSZskfPARXDoQPelWeIJtvmK6SDMMkptGVV6J0EFnWeBhT46L537L1K5IjsbS0BaWxg1wL1wdQgDEAdnf334IgIlxjGNpJACPe8dhMY8IegrNGZy6QMAH2DmMPvPrxCkptdpCsT7heMCKYzETBambGZTR07xmlO102oQueF3CfBNg0mYIJ3BE192kdzjlLqC4KzaRGVLcaP2ltiG1sLr4mBcXO5aVferEqOO4W36ts1cl3kdEyHL5KR1fYsUXcOGkZXaj4086ZblaX1vgbM0p7sgQ72XXvSjBmOvgSnoUTCvIhZBUm8ibj8fkqaJYND3fDnS7RKhjqnEdUFytExZiLbDob6kd4gx3NbHsuCONqSfWDMfrbB88ovcsL71gOHOTNSIYuVBmOKWm7P6cwMhLMhThdQt6gSZWU7pqw9yvOoT6Ox9rc8AEftUTbBmSzkNUSsaC7l48dyRiGn9JkSsd13IPFJH17IgkzgL7eBC7GgwQT3eeGzTDQy92fWfj93VvEko3k9UchUwlbGMrZ8cMhi0Ra40dHjsw7yUCtF23obMfEDSAIf8CyT8PZ21PB9iWDtu8eVFPhG30LiSTtvPbCLhB736BiXmZi5pbF3EUDD6kM4etGhLvmHluFXrargMgcxHeYpIVNIMw3x0ERV78ci3fIFpmhkJBwAaDlQkTDTopuMyhm7pMyvKyk6DXmiHw9lxwkYZh0wWGPMq8TrKj7irgSxIvPlNTAYXxZHEy667WzTT3bL6dE1E1kSidHLGlpk46TS8EI1XGJHpRUtkFml7nHdW57M34WAyJQVbHEDUaLpMH9CZnw2A75JyivVCnPzey', accounts[0])

def test_stand_created_owner_verification(deploy):
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', accounts[9])

def test_stand_created_name_length(deploy):
    with brownie.reverts():
        deploy.createFarmStand('CEcHHttPZTeKTGkRnNjevfi8GNYU8qNvjVHwSQhxgMrfWjLWQfWRbkhtwMESiHTWZVG2GDk49jx6khbqzTnrpGxcNRSG3k3rTeEQZ2SMycj6bBx4ZdW92US3FPwAPCrLXaXRGEfd7iUCaxBiVQvzDgLLvZA2dnb8RdvgC8tXB8rWc5AWQnKywGYfG7WAkWVztcJTbhPChkBE9v2BiSvcD5c8P9m6Nb6VddX9CNDrDpEpKtqeZPxv9DZuve8awyiNu', '123 Valid Location State, 00000', accounts[0])

def test_stand_created_status_verification(deploy):
    deploy.createFarmStand('My Farm Stand', '123 Valid Location State, 00000', accounts[0])
    with brownie.reverts():
        deploy.createFarmStand('My Farm Stand 2', '123 Valid Location State, 00000', accounts[0])
