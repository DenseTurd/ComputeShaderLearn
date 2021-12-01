using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct Structy
{
    public Vector3 pos;
}

public class CPUSidery : MonoBehaviour
{
    public ComputeShader shadery;
    public ComputeBuffer buffery;
    public int noOfTings = 128;
    public Structy[] arrayi;
    public int kernel;

    public GameObject sphere;
    public List<GameObject> spheres;

    bool setup;
    bool debug;
    void Start()
    {
        arrayi = new Structy[noOfTings];

        int j = 0;
        for (int i = 0; i < arrayi.Length; i++)
        {
            arrayi[i].pos = new Vector3(j,j,j);
            j++;
        }

        spheres = new List<GameObject>();
        for (int i = 0; i < arrayi.Length; i++)
        {
            GameObject newSphere = Instantiate(sphere);
            spheres.Add(newSphere); 
            spheres[i].transform.position = arrayi[i].pos;
            Debug.Log($"Pre shader value for index {i}: {arrayi[i].pos}");
        }

        buffery = new ComputeBuffer(arrayi.Length, 3 * sizeof(float));
        buffery.SetData(arrayi);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.G))
        {
            SetUp();
        }

        if (Input.GetKeyDown(KeyCode.R))
        {
            buffery.Release();
            Debug.Log("Released buffery");
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            Start();
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            debug = !debug;
            Debug.Log($"Debug set to {debug}");
        }

        if (setup)
        {
            Compute();
            GetDataBackFromShader();
            SetSpherePos();
        }

        if (Input.GetKeyDown(KeyCode.L))
        {
            Debug.Log(arrayi[65].pos);
        }
    }

    void SetSpherePos()
    {
        for (int i = 0; i < spheres.Count; i++)
        {
            spheres[i].transform.position = arrayi[i].pos;
        }
    }

    void GetDataBackFromShader()
    {
        buffery.GetData(arrayi);
    }

    void Compute()
    {
        shadery.Dispatch(kernel, 1, 1024, 1);
    }

    void SetUp()
    {
        kernel = shadery.FindKernel("CSGain");
        shadery.SetBuffer(kernel, "bufferTing", buffery);
        shadery.SetInt("nStructys", arrayi.Length);
        setup = true;
        Debug.Log("SetUp()");
    }

    private void OnDestroy()
    {
        buffery.Release();
        Debug.Log("On Destroy");

    }
}
