trigger orderTrigger on Order(before insert, before update, after update) {
	try {
		// Invoke helper class methods
		OrderHelper.afterUpdate(Trigger.new, Trigger.old);
	} catch (CustomException e) {
		// Catch the custom exception and attach the error message to all records in Trigger.new
		for (Order o : Trigger.new) {
			o.addError(e.getMessage());
		}
	} catch (Exception e) {
		// Catch all other exceptions and attach a generic error message to all records in Trigger.new
		for (Order o : Trigger.new) {
			o.addError(Constants.ERROR_MESSAGE);
		}
	}

}
