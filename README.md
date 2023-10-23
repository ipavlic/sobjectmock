# SObjectMock

Simple light-weight `SObject` mocking utility. Provides a fluent interface for the standard JSON round-trip technique to set relationships and read-only fields.

When a provided parent has an `Id`, it is copied to the appropriate field. 
Likewise, when the current record has an `Id`, it is copied to the appropriate field on children records. 

# Example

```apex
Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
	.setFields(new Map<SObjectField, Object>{ // setting multiple fields with a map
		Account.Id => accountId,
		Account.Name => 'Account Name',
		Account.CreatedDate => Date.today() // read-only field
	})
	.setParent(Account.OwnerId, SObjectMock.forType(User.SObjectType) // setting a parent relationship with an SObjectField
		.setField(User.Id, userId) // setting a single field with an SObjectField
	)
	.setParent('Parent', SObjectMock.forType(Account.SObjectType)
		.setField('Id', parentAccountId) // setting a single field with a name string
	)
	.setChildren('Opportunities', new List<SObjectMock>{ // setting a child relationship
		SObjectMock.forType(Opportunity.SObjectType)
	})
	.asSObject();
```

