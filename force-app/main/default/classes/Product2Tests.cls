@isTest(seeAllData=false)
private class Product2Tests {
	@TestSetup
	static void setupTestData() {
		TestDataFactory.insertTestData(5);
	}

	/**
	 * @name product2Extension_UnitTest
	 * @description UnitTest for product2Extension
	 **/
	static testMethod void Product2Extension_UnitTest() {
		PageReference pageRef = page.Product2New;
		Product2 prod = new Product2(Name = 'test', isActive = true);
		ApexPages.StandardController controller = new ApexPages.StandardController(prod);
		Test.startTest();
		Product2Extension ext = new Product2Extension(controller);
		System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
		ext.addRows();
		System.assertEquals(2 * Constants.DEFAULT_ROWS, ext.productsToInsert.size());

		for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
			Product2 newProduct = new Product2(
				Name = 'Product' + i,
				Initial_Inventory__c = 10,
				isActive = true,
				family = Constants.PRODUCT_FAMILY.get(math.mod(i, 4)).getValue()
			);
			ext.productsToInsert.get(i).productRecord = newProduct;

			PriceBookEntry entry = new PriceBookEntry(UnitPrice = 100, isActive = true);
			ext.productsToInsert.get(i).pricebookEntryRecord = entry;
		}
		ext.save();
		ext.GetFamilyOptions();
		ext.GetInventory();
		List<Product2> selectedProd = [SELECT id FROM Product2];
		System.assertEquals(Constants.DEFAULT_ROWS, selectedProd.size());
		Test.stopTest();
	}

	static testMethod void Product2Trigger_UnitTest() {
		Product2 prod = [
			SELECT Family, Id, Name, Quantity_Ordered__c, Quantity_Remaining__c
			FROM Product2
			WHERE Name = 'testProduct0'
			LIMIT 1
		];

		prod.Quantity_Ordered__c = 9;

		Test.startTest();
		update prod;
		Test.stopTest();
	}
}
