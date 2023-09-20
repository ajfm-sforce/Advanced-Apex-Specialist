/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
 **/
public with sharing class TestDataFactory {
	/**
	 * @name ConstructCollaborationGroup
	 * @description
	 **/
	public static CollaborationGroup constructCollaborationGroup() {
		//ToDo: Ensure this method returns a single Chatter CollaborationGroup
		//    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
		//    and configured so anyone can join, see and post updates.
		CollaborationGroup testCollaborationGroup = new CollaborationGroup(
			Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
			CollaborationType = 'Public'
		);
		return testCollaborationGroup;
	}

	/**
	 * @name CreateProducts
	 * @description Constructs a list of Product2 records for unit tests
	 **/
	public static List<Product2> constructProducts(Integer cnt) {
		//ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
		//  with all the required fields populated
		//  and IsActive = true
		//  an Initial Inventory set to 10
		//  and iterating through the product family picklist values throughout the list.
		List<Product2> testProductList = new List<Product2>();
		for (Integer i = 0; i < cnt; i++) {
			Product2 testProduct = new Product2(
				Name = 'testProduct' + i,
				IsActive = true,
				Initial_Inventory__c = 10,
				Family = Constants.PRODUCT_FAMILY.get(math.mod(i, 4)).getValue()
			);
			testProductList.add(testProduct);
		}
		return testProductList;
	}

	// System.debug('testProductList ' + TestDataFactory.ConstructProducts(5));

	/**
	 * @name CreatePricebookEntries
	 * @description Constructs a list of PricebookEntry records for unit tests
	 **/
	public static List<PricebookEntry> constructPricebookEntries(List<Product2> prods) {
		//ToDo: Ensure this method returns a corresponding list of PricebookEntries records
		//  related to the provided Products
		//  with all the required fields populated
		//  and IsActive = true
		//  and belonging to the standard Pricebook
		// Get standard price book ID.
		// This is available irrespective of the state of SeeAllData.
		List<PricebookEntry> testPricebookEntries = new List<PricebookEntry>();
		for (Product2 product : prods) {
			PricebookEntry testPricebookEntry = new PricebookEntry(
				Pricebook2Id = Test.isRunningTest() ? Test.getStandardPricebookId() : Constants.STANDARD_PRICEBOOK_ID,
				Product2Id = product.Id,
				UnitPrice = prods.indexOf(product) == 0 ? 9 * 100 : prods.indexOf(product) * 100,
				IsActive = true
			);
			testPricebookEntries.add(testPricebookEntry);
		}
		return testPricebookEntries;
	}

	// System.debug('testPricebookEntries ' + TestDataFactory.constructPricebookEntries(TestDataFactory.ConstructProducts(10)));

	/**
	 * @name CreateAccounts
	 * @description Constructs a list of Account records for unit tests
	 **/
	public static List<Account> constructAccounts(Integer cnt) {
		//ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
		//  with all of the required fields populated.
		List<Account> testAccounts = new List<Account>();
		for (Integer i = 0; i < cnt; i++) {
			testAccounts.add(new Account(Name = 'Test Account' + i));
		}
		return testAccounts;
	}

	/**
	 * @name CreateContacts
	 * @description Constructs a list of Contacxt records for unit tests
	 **/
	public static List<Contact> constructContacts(Integer cnt, List<Account> accts) {
		//ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
		//  related to the provided Accounts
		//  with all of the required fields populated.
		List<Contact> testContacts = new List<Contact>();
		for (Integer i = 0; i < cnt; i++) {
			Integer accountIndex = Math.mod(i, accts.size());
			testContacts.add(new Contact(LastName = 'TestContact' + i, AccountId = accts.get(accountIndex).Id));
		}
		return testContacts;
	}

	/**
	 * @name CreateOrders
	 * @description Constructs a list of Order records for unit tests
	 **/
	public static List<Order> constructOrders(Integer cnt, List<Account> accts) {
		//ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
		//  related to the provided Accounts
		//  with all of the required fields populated.
		List<Order> orders = new List<Order>();
		for (Integer i = 0; i < cnt; i++) {
			Order ord = new Order();
			ord.AccountId = accts.get(math.mod(i, accts.size())).Id;
			ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
			ord.Status = 'Draft';
			ord.EffectiveDate = System.today();
			orders.add(ord);
		}
		return orders;
	}

	/**
	 * @name CreateOrderItems
	 * @description Constructs a list of OrderItem records for unit tests
	 **/
	public static list<OrderItem> constructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords) {
		//ToDo: Ensure this method returns a list of size cnt of OrderItem records
		//  related to the provided Pricebook Entries
		//  and related to the provided Orders
		//  with all of the required fields populated.
		//  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
		List<OrderItem> items = new List<OrderItem>();
		for (Integer i = 0; i < cnt; i++) {
			OrderItem ord = new OrderItem();
			ord.PricebookEntryId = pbes.get(math.mod(i, pbes.size())).Id;
			ord.OrderId = ords.get(math.mod(i, ords.size())).Id;
			ord.Quantity = Constants.DEFAULT_ROWS;
			ord.UnitPrice = 250;
			items.add(ord);
		}

		return items;
	}

	/**
	 * @name SetupTestData
	 * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
	 **/
	public static void insertTestData(Integer cnt) {
		//ToDo: Ensure this method calls each of the construct methods
		//  and inserts the results for use as test data.
		//ToDo: Ensure this method calls each of the construct methods
		//  and inserts the results for use as test data.
		CollaborationGroup groups = constructCollaborationGroup();
		insert groups;

		List<Product2> products = constructProducts(cnt);
		insert products;

		List<PriceBookEntry> entries = constructPricebookEntries(products);
		insert entries;

		List<Account> accts = constructAccounts(cnt);
		insert accts;

		List<Contact> contacts = constructContacts(cnt, accts);
		insert contacts;

		List<Order> orders = constructOrders(cnt, accts);
		insert orders;

		List<OrderItem> items = constructOrderItems(cnt, entries, orders);
		insert items;
	}

	public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
		system.AssertEquals(updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered);
	}
}
