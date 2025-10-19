@IsTest
private class SObjectMockTest {
	@IsTest
	static void fieldIsSetWithSObjectField() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setField(Account.Name, 'Account Name').asSObject();
		Assert.areEqual('Account Name', mockAccount.Name);
	}

	@IsTest
	static void fieldAreSetWithSObjectFields() {
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setFields(new Map<SObjectField, Object>{
				Account.Name => 'Account Name',
				Account.Id => accountId
			})
			.asSObject();
		Assert.areEqual('Account Name', mockAccount.Name);
		Assert.areEqual(accountId, mockAccount.Id);
	}

	@IsTest
	static void fieldIsSetWithName() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setField('Name', 'Account Name').asSObject();
		Assert.areEqual('Account Name', mockAccount.Name);
	}

	@IsTest
	static void fieldsAreSetWithNames() {
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setFields(new Map<String, Object>{
				'Name' => 'Account Name',
				'Id' => accountId
			})
			.asSObject();
		Assert.areEqual('Account Name', mockAccount.Name);
		Assert.areEqual(accountId, mockAccount.Id);
	}

	@IsTest
	static void readOnlyFieldsAreSet() {
		Date today = Date.today();
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setField(Account.CreatedDate, today).asSObject();
		Assert.areEqual(today, mockAccount.CreatedDate);
	}

	@IsTest
	static void parentIsSetWithSObjectField() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setParent(Account.OwnerId, SObjectMock.forType(User.SObjectType).setField(User.Name, 'User Name')).asSObject();
		Assert.areEqual('User Name', mockAccount.Owner.Name);
	}

	@IsTest
	static void parentIsSetWithRelationshipName() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setParent('Owner', SObjectMock.forType(User.SObjectType).setField(User.Name, 'User Name')).asSObject();
		Assert.areEqual('User Name', mockAccount.Owner.Name);
	}

	@IsTest
	static void childrenAreSet() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setChildren('Opportunities', new List<SObjectMock>{
				SObjectMock.forType(Opportunity.SObjectType).setField(Opportunity.Amount, 500)
			}).asSObject();
		Assert.areEqual(1, mockAccount.Opportunities.size());
		Assert.areEqual(500, mockAccount.Opportunities[0].Amount);
	}

	@IsTest
	static void parentIdIsCopiedToFieldWithSObjectField() {
		Id userId = TestUtility.getFakeId(User.SObjectType);

		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setParent(Account.OwnerId, SObjectMock.forType(User.SObjectType)
				.setField(User.Id, userId)
			)
			.asSObject();
		Assert.areEqual(userId, mockAccount.OwnerId);
	}

	@IsTest
	static void parentIdIsCopiedToFieldWithRelationshipName() {
		Id userId = TestUtility.getFakeId(User.SObjectType);

		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setParent('Owner', SObjectMock.forType(User.SObjectType)
				.setField(User.Id, userId)
			)
			.asSObject();
		Assert.areEqual(userId, mockAccount.OwnerId);
	}

	@IsTest
	static void recordIdIsCopiedToChildRelationshipField() {
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setChildren('Opportunities', new List<SObjectMock>{
				SObjectMock.forType(Opportunity.SObjectType)
			})
			.setField(Account.Id, accountId)
			.asSObject();
		Assert.areEqual(mockAccount.Opportunities[0].AccountId, accountId);
	}

	// Null safety tests
	@IsTest
	static void exceptionThrownWhenSObjectTypeIsNull() {
		try {
			SObjectMock.forType(null);
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('SObjectType cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenFieldIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setField((Schema.SObjectField) null, 'value');
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Field cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenFieldNameIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setField((String) null, 'value');
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Field name cannot be null or empty'));
		}
	}

	@IsTest
	static void exceptionThrownWhenFieldNameIsEmpty() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setField('', 'value');
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Field name cannot be null or empty'));
		}
	}

	@IsTest
	static void exceptionThrownWhenFieldsMapIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setFields((Map<String, Object>) null);
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Fields map cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenSObjectFieldsMapIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setFields((Map<Schema.SObjectField, Object>) null);
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Fields map cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenParentMockIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent('Owner', null);
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Parent mock cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenParentRelationshipNameIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent((String) null, SObjectMock.forType(User.SObjectType));
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Relationship name cannot be null or empty'));
		}
	}

	@IsTest
	static void exceptionThrownWhenLookupFieldIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent((Schema.SObjectField) null, SObjectMock.forType(User.SObjectType));
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Lookup field cannot be null'));
		}
	}

	@IsTest
	static void exceptionThrownWhenChildRelationshipNameIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setChildren(null, new List<SObjectMock>());
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Relationship name cannot be null or empty'));
		}
	}

	@IsTest
	static void emptyListIsAcceptedWhenChildrenMocksIsNull() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setChildren('Opportunities', null)
			.asSObject();
		Assert.areEqual(0, mockAccount.Opportunities.size());
	}

	@IsTest
	static void exceptionThrownWhenChildMockIsNull() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setChildren('Opportunities', new List<SObjectMock>{ null });
			Assert.fail('Expected IllegalArgumentException');
		} catch (IllegalArgumentException e) {
			Assert.isTrue(e.getMessage().contains('Child mock cannot be null'));
		}
	}

	// Invalid field/relationship tests
	@IsTest
	static void exceptionThrownForInvalidFieldName() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setField('NonExistentField', 'value');
			Assert.fail('Expected NoSuchFieldException');
		} catch (SObjectMock.NoSuchFieldException e) {
			Assert.isTrue(e.getMessage().contains('NonExistentField'));
			Assert.isTrue(e.getMessage().contains('does not exist'));
		}
	}

	@IsTest
	static void exceptionThrownForInvalidParentRelationship() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent('InvalidRelationship', SObjectMock.forType(User.SObjectType));
			Assert.fail('Expected InvalidRelationshipException');
		} catch (SObjectMock.InvalidRelationshipException e) {
			Assert.isTrue(e.getMessage().contains('InvalidRelationship'));
			Assert.isTrue(e.getMessage().contains('does not exist'));
		}
	}

	@IsTest
	static void exceptionThrownForInvalidChildRelationship() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setChildren('InvalidRelationship', new List<SObjectMock>());
			Assert.fail('Expected InvalidRelationshipException');
		} catch (SObjectMock.InvalidRelationshipException e) {
			Assert.isTrue(e.getMessage().contains('InvalidRelationship'));
			Assert.isTrue(e.getMessage().contains('does not exist'));
		}
	}

	@IsTest
	static void exceptionThrownForWrongParentType() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent(Account.OwnerId, SObjectMock.forType(Account.SObjectType));
			Assert.fail('Expected InvalidRelationshipException');
		} catch (SObjectMock.InvalidRelationshipException e) {
			Assert.isTrue(e.getMessage().contains('Wrong object type'));
			Assert.isTrue(e.getMessage().contains('Expected'));
		}
	}

	@IsTest
	static void exceptionThrownForWrongChildType() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setChildren('Opportunities', new List<SObjectMock>{
					SObjectMock.forType(Contact.SObjectType)
				});
			Assert.fail('Expected InvalidRelationshipException');
		} catch (SObjectMock.InvalidRelationshipException e) {
			Assert.isTrue(e.getMessage().contains('Wrong object type'));
			Assert.isTrue(e.getMessage().contains('Expected'));
		}
	}

	@IsTest
	static void exceptionThrownForNonLookupField() {
		try {
			SObjectMock.forType(Account.SObjectType)
				.setParent(Account.Name, SObjectMock.forType(User.SObjectType));
			Assert.fail('Expected InvalidRelationshipException');
		} catch (SObjectMock.InvalidRelationshipException e) {
			Assert.isTrue(e.getMessage().contains('is not a lookup'));
		}
	}

	// Complex scenarios
	@IsTest
	static void multipleChildRelationshipsAreSupported() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setId()
			.setChildren('Opportunities', new List<SObjectMock>{
				SObjectMock.forType(Opportunity.SObjectType)
			})
			.setChildren('Contacts', new List<SObjectMock>{
				SObjectMock.forType(Contact.SObjectType)
			})
			.asSObject();
		Assert.areEqual(1, mockAccount.Opportunities.size());
		Assert.areEqual(1, mockAccount.Contacts.size());
	}

	@IsTest
	static void nestedRelationshipsAreSupported() {
		SObjectMock ownerMock = SObjectMock.forType(User.SObjectType)
			.setId()
			.setField(User.Name, 'Owner Name');
		SObjectMock parentAccountMock = SObjectMock.forType(Account.SObjectType)
			.setId()
			.setField(Account.Name, 'Parent Account')
			.setParent('Owner', SObjectMock.forType(User.SObjectType)
				.setField(User.Name, 'Parent Owner'));
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setField(Account.Name, 'Child Account')
			.setParent('Owner', ownerMock)
			.setParent('Parent', parentAccountMock)
			.asSObject();
		Assert.areEqual('Child Account', mockAccount.Name);
		Assert.areEqual('Owner Name', mockAccount.Owner.Name);
		Assert.areEqual('Parent Account', mockAccount.Parent.Name);
		Assert.areEqual('Parent Owner', mockAccount.Parent.Owner.Name);
	}

	@IsTest
	static void emptyChildRelationshipIsSupported() {
		Account mockAccount = (Account) SObjectMock.forType(Account.SObjectType)
			.setChildren('Opportunities', new List<SObjectMock>())
			.asSObject();
		Assert.areEqual(0, mockAccount.Opportunities.size());
	}

	@IsTest
	static void toJsonReturnsValidJson() {
		String jsonOutput = SObjectMock.forType(Account.SObjectType)
			.setField(Account.Name, 'Test Account')
			.setField(Account.Id, TestUtility.getFakeId(Account.SObjectType))
			.toJson();
		Assert.isNotNull(jsonOutput);
		Assert.isTrue(jsonOutput.contains('Test Account'));
		Assert.isTrue(jsonOutput.contains('Name'));
	}

	@IsTest
	static void toJsonHandlesRelationships() {
		String jsonOutput = SObjectMock.forType(Account.SObjectType)
			.setField(Account.Name, 'Test Account')
			.setParent('Owner', SObjectMock.forType(User.SObjectType)
				.setField(User.Name, 'Test User'))
			.toJson();
		Assert.isNotNull(jsonOutput);
		Assert.isTrue(jsonOutput.contains('Test Account'));
		Assert.isTrue(jsonOutput.contains('Test User'));
		Assert.isTrue(jsonOutput.contains('Owner'));
	}
}