public without sharing class OrderHelper {
	/**
	 * @name AfterUpdate
	 * @description
	 * @param List<Order> newList
	 * @param List<Order> oldList
	 * @return void
	 **/
	public static void AfterUpdate(List<Order> newList, List<Order> oldList) {
		Set<Id> orderIds = new Set<Id>();
		for (Integer i = 0; i < newList.size(); i++) {
			if (
				(newList[i].Status != null &&
				oldList[i].Status != null) &&
				newList[i].Status == Constants.ACTIVATED_ORDER_STATUS &&
				oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS
			) {
				orderIds.add(newList[i].Id);
			}
		}

		RollUpOrderItems(orderIds);
	}

	/**
	 * @name RollUpOrderItems
	 * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
	 * @param Set<Id> activatedOrderIds
	 * @return void
	 **/
	public static void RollUpOrderItems(Set<Id> activatedOrderIds) {
		//ToDo: Declare a Map named "productMap" of Ids to Product2 records
		Map<Id, Product2> productMap = new Map<Id, Product2>();
		List<Id> productIds = new List<Id>();

		for (OrderItem item : [SELECT id, quantity, Product2Id FROM OrderItem WHERE orderId IN :activatedOrderIds]) {
			productIds.add(item.Product2Id);
		}

		//ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
		productMap = new Map<Id, Product2>([SELECT id, Quantity_Ordered__c FROM product2 WHERE id IN :productIds]);
		//ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
		AggregateResult[] groupedResult = [
			SELECT Product2Id, sum(Quantity) totalQuantity
			FROM OrderItem
			WHERE product2Id IN :productMap.keySet()
			GROUP BY product2Id
		];

		//ToDo: Perform an update on the records in the productMap
		for (AggregateResult result : groupedResult) {
			productMap.get((String) result.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(
				result.get('totalQuantity')
			);
		}

		if (productMap != null && productMap.size() > 0) {
			update productMap.values();
		}
	}
}
