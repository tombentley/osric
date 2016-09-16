import com.redhat.ceylon.common.tools {
    AbstractTestTool
}
import com.redhat.ceylon.common.config {
    DefaultToolOptions
}
import com.redhat.ceylon.common {
    Versions,
    OSUtil,
    ModuleUtil
}
import com.redhat.ceylon.cmr.api {
    ModuleQuery
}
import java.lang {
    System,
    JInteger=Integer,
    JString=String
}
import java.util {
    ArrayList,
    JList=List
}
import ceylon.modules.bootstrap {
    CeylonRunTool,
    CeylonTestFailureError,
    CeylonMessages
}
import ceylon.interop.java {
    javaClassFromInstance
}
shared class CeylonTestBrowserTool extends AbstractTestTool {
    String colorReset = "com.redhat.ceylon.common.tool.terminal.color.reset";
    String colorGreen = "com.redhat.ceylon.common.tool.terminal.color.green";
    String colorRed = "com.redhat.ceylon.common.tool.terminal.color.red";
    variable Boolean flatClasspath = DefaultToolOptions.defaultFlatClasspath;
    variable Boolean autoExportMavenDependencies = DefaultToolOptions.defaultAutoExportMavenDependencies;
    variable Boolean linkWithCurrentDistribution = false;
    shared new () extends AbstractTestTool(CeylonMessages.resourceBundle, 
        ModuleQuery.Type.jvm, JInteger(Versions.jvmBinaryMajorVersion), JInteger(Versions.jvmBinaryMinorVersion), null, null) {
    }
    
    shared void setFlatClasspath(Boolean flatClasspath) {
        this.flatClasspath = flatClasspath;
    }
    
    shared void setLinkWithCurrentDistribution(Boolean linkWithCurrentDistribution) {
        this.linkWithCurrentDistribution = linkWithCurrentDistribution;
    }
    
    shared void setAutoExportMavenDependencies(Boolean autoExportMavenDependencies) {
        this.autoExportMavenDependencies = autoExportMavenDependencies;
    }
    
    shared actual void run() {
        JList<JString> args = ArrayList<JString>();
        JList<JString> moduleAndVersionList = ArrayList<JString>();
        processModuleNameOptVersionList(args, moduleAndVersionList);
        args.remove(0);
        processTestList(args);
        processTagList(args);
        processArgumentList(args);
        processCompileFlags();
        processTapOption(args);
        processReportOption(args);
        processColors(args);
        resolveVersion(moduleAndVersionList);
        CeylonRunTool ceylonRunTool = CeylonRunTool();
        ceylonRunTool.setModule(`module`.name + "/" + `module`.version);
        ceylonRunTool.setRun(`function package.run`.qualifiedName);
        print(args);
        ceylonRunTool.setArgs(args);
        ceylonRunTool.setRepository(repos);
        ceylonRunTool.setFlatClasspath(flatClasspath);
        ceylonRunTool.setLinkWithCurrentDistribution(linkWithCurrentDistribution);
        ceylonRunTool.setAutoExportMavenDependencies(autoExportMavenDependencies);
        ceylonRunTool.setSystemRepository(systemRepo);
        ceylonRunTool.setCacheRepository(cacheRepo);
        ceylonRunTool.setOverrides(overrides);
        ceylonRunTool.setNoDefRepos(noDefRepos);
        ceylonRunTool.setOffline(offline);
        ceylonRunTool.setVerbose(verbose);
        ceylonRunTool.setCompile(compileFlags);
        //ceylonRunTool.setCwd(cwd);
        if (flatClasspath) {
            for (JString moduleAndVersion in moduleAndVersionList) {
                String moduleName = ModuleUtil.moduleName(moduleAndVersion.string);
                String moduleVersion = ModuleUtil.moduleVersion(moduleAndVersion.string);
                ceylonRunTool.addExtraModule(moduleName, moduleVersion);
            }
        }
        
        try {
            ceylonRunTool.run();
        } catch (Throwable x) {
            if (javaClassFromInstance(x).canonicalName.equals("ceylon.test.engine.internal.TestFailureException")) {
                throw CeylonTestFailureError();
            }
            
            throw x;
        }
    }
    
    void processColors(JList<JString> args) {
        String reset = OSUtil.Color.reset.escape();
        String green = OSUtil.Color.green.escape();
        String red = OSUtil.Color.red.escape();
        if (reset exists, green exists, exists red) {
            System.setProperty(colorReset, reset);
            System.setProperty(colorGreen, green);
            System.setProperty(colorRed, red);
        }
    }
}



