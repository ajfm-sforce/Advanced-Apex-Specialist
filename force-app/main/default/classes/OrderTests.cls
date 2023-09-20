@IsTest
private class OrderTests {
	@TestSetup
	static void setupTestData() {
		TestDataFactory.insertTestData(5);
	}

	@IsTest
	static void OrderUpdate_UnitTest() {
		test.startTest();

		Order order = [SELECT Id, Status FROM Order LIMIT 1];

		Product2 prod = [
			SELECT Family, Id, Name, Quantity_Ordered__c, Quantity_Remaining__c
			FROM Product2
			WHERE Name = 'testProduct0'
			LIMIT 1
		];

		order.status = constants.ACTIVATED_ORDER_STATUS;

		update order;

		Product2 updatedProd = [
			SELECT Family, Id, Name, Quantity_Ordered__c, Quantity_Remaining__c
			FROM Product2
			WHERE Name = 'testProduct0'
			LIMIT 1
		];

		TestDataFactory.VerifyQuantityOrdered(prod, updatedprod, constants.DEFAULT_ROWS);

		Test.stopTest();
	}

	@IsTest
	static void testOrderExtension() {
		Test.startTest();
		PageReference reference = Page.OrderEdit;
		Test.setCurrentPage(reference);
		Order CurOrder = [SELECT Id, Status FROM Order LIMIT 1];
		ApexPages.StandardController controller = new Apexpages.StandardController(CurOrder);
		OrderExtension extension = new OrderExtension(controller);
		System.assertEquals(5, extension.orderItemList.size());
		extension.selectedFamily = 'Dessert';
		extension.SelectFamily();
		extension.OnFieldChange();
		extension.First();
		extension.Next();
		extension.Previous();
		extension.Last();
		extension.GetHasNext();
		extension.GetPageNumber();
		extension.GetHasPrevious();
		extension.GetTotalPages();
		extension.GetFamilyOptions();
		extension.Save();
		ChartHelper.GetInventory();
		Test.stopTest();
	}
}
