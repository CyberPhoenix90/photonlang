import { MSBuildLocator } from 'Microsoft/Build/Locator';
import { Environment, Exception, PlatformID } from 'System';
import { Path, Directory } from 'System/IO';
import 'System/Linq';
import { Assembly, AssemblyName } from 'System/Reflection';

export class MsBuildUtils {
    public static InitializeMSBuild(): void {
        const msBuildPath = MsBuildUtils.GetMSBuildPath();
        Environment.SetEnvironmentVariable('MSBuildSDKsPath', Path.Combine(MsBuildUtils.GetFrameworkPath('7.0.202'), 'Sdks'));
        MSBuildLocator.RegisterMSBuildPath(msBuildPath);
        Assembly.Load(new AssemblyName('Microsoft.Build'));
    }

    public static GetMSBuildPath(): string {
        return MSBuildLocator.QueryVisualStudioInstances().First().MSBuildPath;
    }

    public static GetDotnetSdkPath(): string {
        const currentOs = Environment.OSVersion.Platform;
        let path = '';

        if (currentOs == PlatformID.Win32NT) {
            const programFiles = Environment.GetEnvironmentVariable('ProgramFiles(x86)');
            path = Path.Join(programFiles, 'Reference Assemblies', 'Microsoft', 'Framework');
        } else if (currentOs == PlatformID.Unix) {
            path = Path.Join('/usr/share/dotnet/sdk');
        } else {
            throw new Exception(`${currentOs} is not supported`);
        }

        if (!Directory.Exists(path)) {
            throw new Exception(`Could not find framework path ${path}`);
        }

        return path;
    }

    public static GetFrameworkPath(targetFramework: string): string {
        if (targetFramework.StartsWith('net')) {
            targetFramework = targetFramework.Substring(3);
        }

        const dotnetSdkPath = MsBuildUtils.GetDotnetSdkPath();
        const path = Directory.GetDirectories(dotnetSdkPath, targetFramework + '*').First();

        if (!Directory.Exists(path)) {
            throw new Exception(`Could not find framework path ${path}`);
        }

        return path;
    }

    public static GetFrameworkPackDLLs(pack: string, targetFramework: string): string[] {
        const version = targetFramework.Substring(3);
        const currentOs = Environment.OSVersion.Platform;
        let path = '';

        if (currentOs == PlatformID.Win32NT) {
            const programFiles = Environment.GetEnvironmentVariable('ProgramFiles(x86)');
            path = Path.Join(programFiles, 'dotnet', 'packs');
        } else if (currentOs == PlatformID.Unix) {
            path = Path.Join('/usr/share/dotnet/packs');
        } else {
            throw new Exception(`${currentOs} is not supported`);
        }

        if (!Directory.Exists(path)) {
            throw new Exception(`Could not find pack path ${path}`);
        }

        const packPath = Directory.GetDirectories(Path.Combine(path, pack + '.Ref'), version + '*').First();

        if (!Directory.Exists(packPath)) {
            throw new Exception(`Could not find pack path ${packPath}`);
        }

        const packDlls = Directory.GetFiles(Path.Combine(packPath, 'ref', targetFramework), '*.dll');

        return packDlls;
    }

    public static GetFrameworkReferenceAssemblies(targetFramework: string): string[] {
        const frameworkPath = MsBuildUtils.GetFrameworkPath(targetFramework);
        const referenceAssembliesPath = Path.Join(frameworkPath, 'ref');

        if (!Directory.Exists(referenceAssembliesPath)) {
            throw new Exception(`Could not find reference assemblies path ${referenceAssembliesPath}`);
        }

        const referenceAssemblies = Directory.GetFiles(referenceAssembliesPath, '*.dll');

        return referenceAssemblies;
    }
}
