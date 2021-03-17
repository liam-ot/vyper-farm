import brownie
from brownie import accounts, Farm
from brownie.test import given, strategy
import pytest

# contract deployment fixture #

@pytest.fixture
def deploy():
    return Farm.deploy({'from':accounts[0]})


# happy results #

def test_set_item_increments_total_items(deploy):
    num =  deploy.getNumItems()

    deploy.setItem(0, 'Valid Product Name', '1.00', 0, 'Active')

    assert deploy.getNumItems() == num + 1

@given(test_name=strategy('string', max_size=256))
def test_set_item_sets_correct_name(deploy, test_name):
    deploy.setItem(0, test_name, '1.00', 0, 'Active')

    name = deploy.getItemName(0)

    assert name == test_name

def test_set_item_sets_correct_category(deploy):
    category_id = 0

    deploy.setItem(category_id, 'Valid Product Name', '1.00', 0, 'Active')

    category = deploy.getItemCategory(0)

    assert category == category_id

@given(test_price=strategy('decimal', min_value='0.0000000001'))
def test_set_item_sets_correct_price(deploy, test_price):
    deploy.setItem(0, 'Valid Product Name', test_price, 0, 'Active')

    price = deploy.getItemPrice(0)

    assert price == test_price

@given(test_sales=strategy('uint256', max_value=(10**18) - 1))
def test_set_item_sets_correct_sales(deploy, test_sales):
    deploy.setItem(0, 'Valid Product Name', '1.00', test_sales, 'Active')

    sales = deploy.getItemSales(0)

    assert sales == test_sales

def test_set_item_sets_correct_status(deploy):
    deploy_status = 'Inactive'

    deploy.setItem(0, 'Valid Product Name', '1.00', 0, deploy_status)

    sales = deploy.getItemStatus(0)

    assert sales == deploy_status

# unhappy results #

@given(test_category=strategy('uint256', min_value=1, max_value=5))
def test_set_item_invalid_category(deploy, test_category):
    with brownie.reverts():
        deploy.setItem(test_category, 'Valid Product Name', '1.00', 0, 'Active')

@given(test_name_fail=strategy('string', min_size=257, max_size=258))
def test_set_item_name_length(deploy, test_name_fail):
    with brownie.reverts():
        deploy.setItem(0, test_name_fail, '1.00', 0, 'Active')

@given(test_price_fail=strategy('decimal', max_value='-1'))
def test_set_item_price_floor(deploy, test_price_fail):
    with brownie.reverts():
        deploy.setItem(0, 'Valid Product Name', test_price_fail, 0, 'Active')

@given(test_status_fail=strategy('string', min_size=9, max_size=10))
def test_set_item_name_length(deploy, test_status_fail):
    with brownie.reverts():
        deploy.setItem(0, 'Valid Product Name', '1.00', 0, test_status_fail)
