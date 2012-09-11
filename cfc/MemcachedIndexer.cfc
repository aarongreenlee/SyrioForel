component {
	/**
		The list or array of fields to bind this index on
	**/
	function init(required string fields)
	{
		variables.instance = {
			// Create metadata pool
			poolMetadata = {},
			// Index ID
			indexID = createObject('java','java.lang.System').identityHashCode(this)
		};
		
		variables.fields = arguments.fields;
		
		return this;
	}
	
	function getFields() { return variables.fields; }
	
	function getPoolMetadata() {return variables.instance.poolMetadata;}
	
	function clearAll() { return; }
	
	function clear() { return; }
	
	function getKeys() {
		return ['Memcached does not support this operation.'];
	}
	
	function getObjectMetadata(required objectKey) {
		return instance.poolMetadata[ arguments.objectKey ];
	}
	
	function setObjectMetadata(required objectKey,required metadata){
		variables.instance.poolMetadata[ arguments.objectKey ] = arguments.metadata;
	}

	function objectExists(required objectKey) {
		return structKeyExists( variables.instance.poolMetadata, arguments.objectKey );
	}
	
	function getObjectMetadataProperty(objectKey,property)
	{
		return instance.poolMetadata[ arguments.objectKey ][ arguments.property ];
	} 
	function setObjectMetadataProperty(
		 required objectKey
		,required property
		,required value
	){
		instance.poolMetadata[ arguments.objectKey ][ arguments.property ] = arguments.value;
	}
	
	function getSize() {
		return 999;
	}
	
	function getSortedKeys() {
		return getKeys();
	}
}