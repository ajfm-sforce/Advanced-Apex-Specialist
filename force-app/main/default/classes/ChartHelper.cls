public without sharing class ChartHelper {
	@AuraEnabled
	public static List<chartData> GetInventory() {
		List<chartData> cht = new List<chartData>();
		//ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
		//  And return a list of chartData
		//  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
		for (AggregateResult result : [
			SELECT Family, sum(Quantity_Remaining__c) remainingQuantity
			FROM product2
			WHERE Quantity_Remaining__c > 0 AND isActive = TRUE
			GROUP BY Family
		]) {
			ChartData data = new ChartData(
				String.valueOf(result.get('Family')),
				Integer.valueOf(result.get('remainingQuantity'))
			);
			cht.add(data);
		}
		return cht;
	}

	public class ChartData {
		public String name { get; set; }
		public Decimal val { get; set; }

		public ChartData(String name, Decimal val) {
			this.name = name;
			this.val = val;
		}
	}
}
