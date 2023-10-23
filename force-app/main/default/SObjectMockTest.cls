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
}