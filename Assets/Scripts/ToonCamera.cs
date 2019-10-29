using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToonCamera : MonoBehaviour
{
    [SerializeField]
    private Camera m_mainCamera;
    [SerializeField]
    public LayerMask m_targetLayer;

    public void Start()
    {
        if (m_mainCamera == null)
        {
            m_mainCamera = Camera.main;
        }

        //Instantiate sub camera for normal texture
        var normalCam = new GameObject();
        normalCam.transform.SetParent(m_mainCamera.transform);
        normalCam.transform.localPosition = Vector3.zero;

        var nCam = normalCam.AddComponent<Camera>();
        nCam.cullingMask = m_targetLayer;

        normalCam.AddComponent<NormalOutputs>();

        //Instantiate sub camera for Uv texture 
        var uvCam = new GameObject();
        uvCam.transform.SetParent(m_mainCamera.transform);
        uvCam.transform.localPosition = Vector3.zero;

        var uCam = uvCam.AddComponent<Camera>();
        uCam.cullingMask = m_targetLayer;

        uvCam.AddComponent<UvOutputs>();
    }
}
