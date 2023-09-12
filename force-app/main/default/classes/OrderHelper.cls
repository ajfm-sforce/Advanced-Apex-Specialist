public without sharing class OrderHelper {
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

		if (!orderIds.isEmpty()) {
			RollUpOrderItems(orderIds);
		}
	}

	public static void RollUpOrderItems(Set<Id> activatedOrderIds) {
		Map<Id, Product2> productMap = new Map<Id, Product2>();
		List<Id> productIds = new List<Id>();
		for (OrderItem item : [SELECT id, quantity, Product2Id FROM OrderItem WHERE orderId IN :activatedOrderIds]) {
			productIds.add(item.Product2Id);
		}

		productMap = new Map<Id, Product2>([SELECT id, Quantity_Ordered__c FROM product2 WHERE id IN :productIds]);
		AggregateResult[] groupedResult = [
			SELECT Product2Id, sum(Quantity) totalQuantity
			FROM OrderItem
			WHERE product2Id IN :productMap.keySet()
			GROUP BY product2Id
		];

		Savepoint sp = Database.setSavepoint();
		try {
			for (AggregateResult result : groupedResult) {
				Id productId = (Id) result.get('Product2Id');
				if (productMap.containsKey(productId)) {
					productMap.get(productId).Quantity_Ordered__c = (Decimal) result.get('totalQuantity');
				}
			}

			if (!productMap.isEmpty()) {
				update productMap.values();
			}
		} catch (Exception e) {
			// Roll back database to save point to undo any changes
			Database.rollback(sp);
			// Further error handling here like logging
			System.debug('Exception occurred: ' + e.getMessage());
			// Optionally throw the exception to be handled at a higher layer
			throw new CustomException(e);
		}
	}
}
