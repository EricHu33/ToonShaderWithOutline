using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalOutputs : MonoBehaviour
{

    [SerializeField]
    private Camera m_cam;

    [SerializeField]
    private Shader m_normalOutputShader;

    private RenderTexture normalTex;



    public void OnEnable()
    {
        if (m_cam == null)
        {
            m_cam = GetComponent<Camera>();
        }
        if (m_normalOutputShader == null)
        {
            m_normalOutputShader = Shader.Find("Custom/OutputNormals");
        }

        Camera.main.depthTextureMode = m_cam.depthTextureMode | DepthTextureMode.Depth;
        normalTex = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBFloat);
        normalTex.Create();
    }

    public void OnDisable()
    {
        normalTex.Release();
    }

    public void Update()
    {
        m_cam.clearFlags = CameraClearFlags.SolidColor;
        m_cam.renderingPath = RenderingPath.Forward;
        m_cam.targetTexture = normalTex;

        m_cam.RenderWithShader(m_normalOutputShader, null);
        Shader.SetGlobalTexture("_ScreenNormalColorMap", normalTex);
    }
}
