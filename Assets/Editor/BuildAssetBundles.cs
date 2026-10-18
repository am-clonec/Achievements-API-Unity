using System.IO;
using UnityEditor;

public static class BuildAssetBundles
{
    const string BundleName = "achievements";

    // Assets explicitly assigned to the bundle. Their dependencies
    // (sprites, fonts, materials) are pulled in automatically.
    // These are loaded by name in AchievementsAPI's Assets.cs.
    static readonly string[] ExtraAssets =
    {
        "Assets/AchievementsMenu/Toast.prefab",
        "Assets/AchievementsMenu/ToastCanvas.prefab",
        "Assets/AchievementsMenu/Star.png",
    };

    [MenuItem("Assets/Build AssetBundles/Windows")]
    public static void BuildWindows() => Build(BuildTarget.StandaloneWindows64);

    [MenuItem("Assets/Build AssetBundles/Android")]
    public static void BuildAndroid() => Build(BuildTarget.Android);

    // Entry point for command-line builds:
    // Unity.exe -batchmode -quit -projectPath <project> -executeMethod BuildAssetBundles.BuildAll
    public static void BuildAll()
    {
        BuildWindows();
        BuildAndroid();
    }

    static void AssignBundleNames()
    {
        foreach (string guid in AssetDatabase.FindAssets("", new[] { "Assets/Resources" }))
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            var importer = AssetImporter.GetAtPath(path);

            // PNGs must import as sprites so AssetBundle.LoadAsset<Sprite> works.
            if (importer is TextureImporter tex && tex.textureType != TextureImporterType.Sprite)
            {
                tex.textureType = TextureImporterType.Sprite;
                tex.spritePixelsPerUnit = 100;
                tex.SaveAndReimport();
            }

            importer.assetBundleName = BundleName;
        }

        foreach (string path in ExtraAssets)
            AssetImporter.GetAtPath(path).assetBundleName = BundleName;

        AssetDatabase.SaveAssets();
    }

    static void Build(BuildTarget target)
    {
        AssignBundleNames();

        string folderName = target == BuildTarget.StandaloneWindows64 ? "StandaloneWindows" : target.ToString();
        string outputDir = Path.Combine("AssetBundles", folderName);
        Directory.CreateDirectory(outputDir);

        BuildPipeline.BuildAssetBundles(outputDir, BuildAssetBundleOptions.None, target);
    }
}
