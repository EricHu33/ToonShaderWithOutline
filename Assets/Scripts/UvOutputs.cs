using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UvOutputs : MonoBehaviour
{
    [SerializeField]
    private Camera m_cam;

    [SerializeField]
    public Shader m_uvOutputShader;

    private RenderTexture uvTex;

    public void OnEnable()
    {
        if (m_cam == null)
        {
            m_cam = GetComponent<Camera>();
        }
        if (m_uvOutputShader == null)
        {
            m_uvOutputShader = Shader.Find("Custom/OutputUVs");
        }

        Camera.main.depthTextureMode = m_cam.depthTextureMode | DepthTextureMode.Depth;
        uvTex = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBFloat);
        uvTex.Create();
    }

    public void OnDisable()
    {
        uvTex.Release();
    }

    public void Update()
    {
        m_cam.clearFlags = CameraClearFlags.SolidColor;
        m_cam.renderingPath = RenderingPath.Forward;
        m_cam.targetTexture = uvTex;

        m_cam.RenderWithShader(m_uvOutputShader, null);
        Shader.SetGlobalTexture("_ScreenUvColorMap", uvTex);
    }
}
