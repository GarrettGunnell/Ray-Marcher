using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Raymarcher : MonoBehaviour {

    private RenderTexture raymarchRender;

    private Material raymarchMat;

    void Start() {
        raymarchMat = new Material(Shader.Find("Unlit/Raymarch"));
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (raymarchRender == null) {
            raymarchRender = new RenderTexture(source.width, source.height, 0, source.format, RenderTextureReadWrite.Linear);
            raymarchRender.Create();
        }

        raymarchMat.SetVector("_CameraDirection", this.transform.InverseTransformDirection(Vector3.forward));
        Graphics.Blit(source, raymarchRender, raymarchMat);
        Graphics.Blit(raymarchRender, destination);
    }

    private void LateUpdate() {
        if (Input.GetKeyDown(KeyCode.Space)) {
            Texture2D screenshot = new Texture2D(raymarchRender.width, raymarchRender.height, TextureFormat.RGB24, false, true);
            RenderTexture.active = raymarchRender;
            
            /* Fix Gamma Correction */
            screenshot.ReadPixels(new Rect(0, 0, raymarchRender.width, raymarchRender.height), 0, 0);
            Color[] pixels = screenshot.GetPixels();
            for (int p = 0; p < pixels.Length; ++p)
                pixels[p] = pixels[p].gamma;
            screenshot.SetPixels(pixels);
            screenshot.Apply();

            string fileName = string.Format("{0}/../Examples/snap_{1}.png", Application.dataPath, System.DateTime.Now.ToString("HH-mm-ss"));
            System.IO.File.WriteAllBytes(fileName, screenshot.EncodeToPNG());
        }
    }
}
