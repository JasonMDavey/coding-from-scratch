using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LampSurface : MonoBehaviour
{
    public Material mat;
    public GameObject blobContainer;
    public float blobIntensityFactor = 0.1f;

    private List<Blob> blobs = new List<Blob>();

    // Start is called before the first frame update
    void Start()
    {
        foreach (Blob b in blobContainer.GetComponentsInChildren<Blob>())
        {
            blobs.Add(b);
        }
    }

    // Update is called once per frame
    void Update()
    {
        for (int i=0; i<10; i++)
        {
            Vector4 ballVec = Vector4.zero;
            if (blobs.Count > i)
            {
                ballVec.x = blobs[i].transform.localPosition.x + 0.5f;
                ballVec.y = blobs[i].transform.localPosition.y + 0.5f;
                ballVec.z = blobs[i].transform.localScale.x * blobIntensityFactor;
            }

            mat.SetVector("_Ball"+i, ballVec);
        }
    }
}
