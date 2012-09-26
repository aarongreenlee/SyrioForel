component
{
	this.name = "SyrioForel";
	this.sessionManagement = false;
	this.setClientCookies = false;
	this.root = this.root = getDirectoryFromPath(getCurrentTemplatePath()).ReplaceFirst("([^\\\/]+[\\\/]){1}$", "");
	
	this.mappings = {
		'/test' = this.root & 'test'
		,'/app' = this.root
		,'/mxunit' = 'C:\web\adobe\atv\adobetv\lib\shared\lib\mxunit'
		,'/coldbox' = 'C:\web\adobe\atv\adobetv\lib\coldbox'
	};
	
	// Load JARs
	// ColdFusion 10 method of loading them within the Application.cfc
	this.javaSettings={
		 LoadPaths = ['/app/lib']
		,loadColdFusionClassPath = true
		,reloadOnChange = false
	};

	function onRequestStart(required targetPage) {
		return true;
	}
}