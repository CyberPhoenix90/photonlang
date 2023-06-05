import { MSBuildLocator } from 'Microsoft/Build/Locator';
import { Environment, Exception, PlatformID } from 'System';
import { Path, Directory } from 'System/IO';
import 'System/Linq';
import { Assembly, AssemblyName } from 'System/Reflection';
import Collections from 'System/Collections/Generic';

export class MsBuildUtils {
    public static InitializeMSBuild(): void {
        const msBuildPath = MsBuildUtils.GetMSBuildPath();
        Environment.SetEnvironmentVariable('MSBuildSDKsPath', Path.Combine(MsBuildUtils.GetFrameworkPath('7.0.*'), 'Sdks'));
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
            if (Directory.Exists('/usr/share/dotnet/sdk')) {
                path = '/usr/share/dotnet/sdk';
            } else {
                path = '/usr/lib/dotnet/sdk';
            }
        } else {
            throw new Exception(`${currentOs} is not supported`);
        }

        if (!Directory.Exists(path)) {
            throw new Exception(`Could not find framework path ${path}`);
        }

        return path;
    }

    public static GetFrameworkPath(version: string): string {
        if (version.StartsWith('net')) {
            version = version.Substring(3);
        }
        const expectedVersionSegments = new Collections.List<string>(version.Split('.'));
        while (expectedVersionSegments.Count() < 3) {
            expectedVersionSegments.Add('*');
        }

        const dotnetSdkPath = MsBuildUtils.GetDotnetSdkPath();
        const sdks = Directory.GetDirectories(dotnetSdkPath, '*').ToArray();

        if (sdks.Length == 0) {
            throw new Exception(`Could not find framework path ${dotnetSdkPath}`);
        }

        for (const sdk of sdks) {
            const versionSegments = version.Split('.');

            for (let i = 0; i < versionSegments.Length; i++) {
                if (expectedVersionSegments[i] != '*' && expectedVersionSegments[i] != versionSegments[i]) {
                    break;
                }

                if (i == versionSegments.Length - 1) {
                    return sdk;
                }
            }
        }

        throw new Exception(`Could not find framework path ${dotnetSdkPath} for version ${version}`);
    }

    public static GetFrameworkPackDLLs(pack: string, targetFramework: string): string[] {
        const version = targetFramework.Substring(3);
        const currentOs = Environment.OSVersion.Platform;
        let path = '';

        if (currentOs == PlatformID.Win32NT) {
            const programFiles = Environment.GetEnvironmentVariable('ProgramFiles(x86)');
            path = Path.Join(programFiles, 'dotnet', 'packs');
        } else if (currentOs == PlatformID.Unix) {
            if (Directory.Exists('/usr/share/dotnet/packs')) {
                path = '/usr/share/dotnet/packs';
            } else {
                path = '/usr/lib/dotnet/packs';
            }
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
