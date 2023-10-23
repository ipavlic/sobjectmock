# `SObjectMock`

Simple light-weight `SObject` mocking utility. Provides a fluent interface for the standard JSON round-trip technique to set relationships and read-only fields.

When a parent has an `Id`, it is automatically copied to the appropriate field on children records.

## Example

```apex
Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
	.setId() // sets a fake Id
	.setFields(new Map<SObjectField, Object>{ // setting multiple fields with a map
		Account.Name => 'Account Name',
		Account.CreatedDate => Date.today() // read-only field
	})
	.setParent(Account.OwnerId, SObjectMock.forType(User.SObjectType) // setting a parent relationship with an SObjectField
		.setField(User.Id, userId) // setting a single field with an SObjectField
	)
	.setParent('Parent', SObjectMock.forType(Account.SObjectType)
		.setId(parentAccountId) // Id field setting shorthand
		.setField('Name', 'Parent Account Name') // setting a field with a name
	)
	.setChildren('Opportunities', new List<SObjectMock>{ // setting a child relationship
		SObjectMock.forType(Opportunity.SObjectType)
	})
	.asSObject();
```

