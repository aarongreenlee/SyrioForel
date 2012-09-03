<cfinvoke component="DirectoryTestSuite"
          method="run"
          directory="#expandPath('.')#"
		  componentPath='app.test'
          recurse="true"
          returnvariable="results"/>

<cfoutput>#results.getResultsOutput('html')#</cfoutput>