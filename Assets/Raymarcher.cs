using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Raymarcher : MonoBehaviour {

    private Material raymarchMat;

    void Start() {
        raymarchMat = new Material(Shader.Find("Unlit/Raymarch"));
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        raymarchMat.SetVector("_CameraDirection", this.transform.InverseTransformDirection(Vector3.forward));
        Graphics.Blit(source, destination, raymarchMat);
    }

}
