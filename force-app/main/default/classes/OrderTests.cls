@isTest
private class OrderTests {
	@testSetup
	static void SetupTestData() {
		TestDataFactory.InsertTestData(20);
	}

	@IsTest
	static void OrderUpdate_UnitTest() {
		Order selectedOrder = [SELECT name, Status, Id FROM Order LIMIT 1];
		Product2 oldProd = [SELECT Quantity_Ordered__c, Name, Id FROM Product2 LIMIT 1];

		selectedOrder.Status = Constants.ACTIVATED_ORDER_STATUS;
		update selectedOrder;

		Product2 updatedProd = [SELECT Quantity_Ordered__c, Name, Id FROM Product2 LIMIT 1];

		TestDataFactory.VerifyQuantityOrdered(oldProd, updatedProd, Constants.DEFAULT_ROWS);
	}

	@IsTest
	static void OrderExtension_UnitTest() {
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
	}
}
