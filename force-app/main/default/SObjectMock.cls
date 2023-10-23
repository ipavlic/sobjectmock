public with sharing class SObjectMock {

	public class NoSuchFieldException extends Exception {}
	public class InvalidRelationshipException extends Exception {}

	private final Schema.DescribeSObjectResult sObjectDescription;
	private final Schema.SObjectType sObjectType;

	private final Map<String, Object> fields = new Map<String, Object>();
	private final Map<SObjectField, SObjectMock> parents = new Map<SObjectField, SObjectMock>();
	private final Map<ChildRelationship, List<SObjectMock>> children = new Map<ChildRelationship, List<SObjectMock>>();

	public static SObjectMock forType(Schema.SObjectType sobjectType) {
		return new SObjectMock(sobjectType);
	}

	private SObjectMock(Schema.SObjectType sObjectType) {
		this.sObjectType = sObjectType;
		this.sObjectDescription = sObjectType.getDescribe();
	}

	public SObjectMock setField(Schema.SObjectField field, Object value) {
		fields.put(field.getDescribe().getName(), value);
		return this;
	}

	public SObjectMock setField(String fieldName, Object value) {
		return setField(resolveField(fieldName), value);
	}

	public SObjectMock setId(Id recordId) {
		return setField('Id', recordId);
	}

	public SObjectMock setId() {
		return setField('Id', TestUtility.getFakeId(sObjectType));
	}

	public SObjectMock setFields(Map<String, Object> fieldsMap) {
		for (String fieldName : fieldsMap.keySet()) {
			setField(fieldName, fieldsMap.get(fieldName));
		}
		return this;
	}

	public SObjectMock setFields(Map<Schema.SObjectField, Object> fieldsMap) {
		for (Schema.SObjectField field : fieldsMap.keySet()) {
			setField(field, fieldsMap.get(field));
		}
		return this;
	}

	private Schema.SObjectField resolveParentRelationshipField(String relationshipName) {
		List<SObjectField> sObjectFields = sObjectDescription.fields.getMap().values();
		for (SObjectField field : sObjectFields) {
			String fieldRelationshipName = field.getDescribe().getRelationshipName();
			if (relationshipName.equalsIgnoreCase(fieldRelationshipName)) {
				return field;
			}
		}
		throw new InvalidRelationshipException(String.format('Parent relationship "{0}" does not exist on {1}.',
			new String[]{relationshipName, sObjectDescription.getName()
		}));
	}

	public SObjectMock setParent(String relationshipName, SObjectMock parentMock) {
		Schema.SObjectField parentField = resolveParentRelationshipField(relationshipName);
		return setParent(parentField, parentMock);
	}

	public SObjectMock setChildren(String relationshipName, List<SObjectMock> childrenMocks) {
		ChildRelationship childRelationship = resolveChildRelationship(relationshipName);
		SObjectType childSObjectType = childRelationship.getChildSObject();
		for (SObjectMock childMock : childrenMocks) {
			if (childSObjectType != childMock.sObjectType) {
				throw new InvalidRelationshipException(String.format('Wrong object type {0} for "{1}" relationship on {2}. Expected {3}.',
					new String[]{
						childMock.sObjectDescription.getName(),
						childRelationship.getRelationshipName(),
						sObjectDescription.getName(),
						childSObjectType.getDescribe().getName()
					}
				));
			}
		}
		children.put(childRelationship, childrenMocks);
		return this;
	}

	private ChildRelationship resolveChildRelationship(String relationshipName) {
		List<ChildRelationship> childRelationships = sObjectDescription.getChildRelationships();
		for (ChildRelationship relationship : childRelationships) {
			if (relationshipName.equalsIgnoreCase(relationship.getRelationshipName())) {
				return relationship;
			}
		}
		throw new InvalidRelationshipException(String.format('Child relationship "{0}" does not exist on {1}.',
			new String[]{relationshipName, sObjectDescription.getName()
		}));
	}

	/**
	 * @param lookupField A field on the current object that is a lookup. Because fields do not contain
	 * information on what their parent object is (for example Account.Id and Lead.Id are both Ids, with
	 * no ownership information), users should be careful to use the correct field.
	 * @param parentMock parentMcok
	 *
	 * @return this
	 */
	public SObjectMock setParent(Schema.SObjectField lookupField, SObjectMock parentMock) {
		DescribeFieldResult fieldDescription = lookupField.getDescribe();
		List<SObjectType> referenceTo = fieldDescription.getReferenceTo();
		if (referenceTo.isEmpty()) {
			throw new InvalidRelationshipException(String.format('Field "{0}" on {1} is not a lookup.',
				new String[]{lookupField.getDescribe().getName(), sObjectDescription.getName()}
			));
		}
		Set<SObjectType> acceptableObjectTypes = new Set<SObjectType>(referenceTo);
		if (!acceptableObjectTypes.contains(parentMock.sObjectType)) {
			List<String> acceptableTypeNames = new List<String>();
			for (SObjectType type : acceptableObjectTypes) {
				acceptableTypeNames.add(type.getDescribe().getName());
			}
			acceptableTypeNames.sort();
			throw new InvalidRelationshipException(String.format('Wrong object type {0} for "{1}" relationship on {2}. Expected ({3}).',
				new String[]{
					parentMock.sObjectDescription.getName(),
					lookupField.getDescribe().relationshipName,
					sObjectDescription.getName(),
					String.join(acceptableTypeNames, ', ')
				}
			));
		}
		parents.put(lookupField, parentMock);
		return this;
	}

	private SObjectField resolveField(String fieldName) {
		SObjectField field = sObjectDescription.fields.getMap().get(fieldName);
		if (field == null) {
			throw new NoSuchFieldException(String.format('Field "{0}" does not exist on {1}.',
				new String[]{fieldName, sObjectDescription.getName()}
			));
		}
		return field;
	}

	public Map<String, Object> getData() {
		Map<String, Object> data = new Map<String, Object>();
		for (SObjectField field : parents.keySet()) {
			SObjectMock parentMock = parents.get(field);
			if (parentMock.fields.containsKey('Id')) {
				setField(field, parentMock.fields.get('Id'));
			}
			data.put(field.getDescribe().getRelationshipName(), parents.get(field).getData());
		}
		for (String fieldName : fields.keySet()) {
			data.put(fieldName, fields.get(fieldName));
		}
		Object recordId = fields.get('Id');
		for (ChildRelationship relationship : children.keySet()) {
			SObjectField relationshipField = relationship.getField();
			List<Map<String, Object>> childData = new List<Map<String, Object>>();
			for (SObjectMock child : children.get(relationship)) {
				if (recordId != null) {
					child.setField(relationshipField, recordId);
				}
				childData.add(child.getData());
			}
			data.put(relationship.getRelationshipName(), new Map<String, Object>{
				'totalSize' => childData.size(),
				'done' => true,
				'records' => childData
			});
		}
		return data;
	}

	public SObject asSObject() {
		return (SObject) JSON.deserialize(JSON.serialize(getData()), Type.forName(sObjectType.getDescribe().getName()));
	}
}