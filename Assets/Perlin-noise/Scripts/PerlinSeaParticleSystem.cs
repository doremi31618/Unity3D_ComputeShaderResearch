using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerlinSeaParticleSystem : MonoBehaviour
{
    [Header("Assign each script")]
    [SerializeField] Mesh mesh = default;
    [SerializeField] Material material = default;
    [SerializeField] ComputeShader computeShader = default;
    ComputeBuffer computeBuffer;
    ComputeBuffer uvBuffer;

    [Header("Custom Pattern Data")]
    [Range(10, 200)] public int resolution = 10;
    [Range(0.1f, 5f)] public float amplitude = 0.5f; 
    [Range(0, 1)] public float speed = 0.5f;
    int _resolution = 10;

    static readonly int
        resolutionId = Shader.PropertyToID("_Resolution"),
        positionsId = Shader.PropertyToID("_Positions"),
        amplitudeId = Shader.PropertyToID("_Amplitude"),
        speedId = Shader.PropertyToID("_Speed"),
        timeId = Shader.PropertyToID("_Time"),
        uvcoordId= Shader.PropertyToID("_UV_coord"),
        stepId = Shader.PropertyToID("_Step");
    

    void CreateComputeBuffer(){
        computeBuffer = new ComputeBuffer(resolution * resolution, 3 * sizeof(float));
    }

    void DiscardComputeBuffer(){
        computeBuffer.Release();
        computeBuffer = null;
    }

    void UpdateFunctionOnGPU(){

        //Update argument of compute shader 
        int kernelId = computeShader.FindKernel("PerlinSea");
        computeShader.SetInt(resolutionId, resolution);
        computeShader.SetFloat(amplitudeId, amplitude);
        computeShader.SetFloat(speedId, speed);
        computeShader.SetFloat(timeId, Time.time);
        computeShader.SetFloat(stepId, 2.0f/resolution);
        computeShader.SetBuffer(kernelId, positionsId, computeBuffer);

        //dipatch commpute shader
        int groupNumber = Mathf.CeilToInt(resolution / 8);
        computeShader.Dispatch(kernelId, groupNumber, groupNumber, 1);

        //update argument of material
        material.SetFloat(stepId, 2.0f/resolution);
        material.SetBuffer(positionsId, computeBuffer);

        //call gpu Instancing to draw the particles
        var bounds = new Bounds(Vector3.zero, Vector3.one * (2f + 2f/resolution));
        // first argument : mesh
        // second argument : sub-mesh index
        // third  argument : material
        Graphics.DrawMeshInstancedProcedural(mesh, 0, material, bounds, computeBuffer.count);
    }

    void OnValueChange(){
        //recreate a compute buffer (because the buffer size is different)
        if (_resolution != resolution){
            DiscardComputeBuffer();
            CreateComputeBuffer();
        }
    }

    void OnEnable(){
        CreateComputeBuffer();
    }

    void OnDisable(){
        DiscardComputeBuffer();
    }

    void Update(){
        // OnValueChange();
        UpdateFunctionOnGPU();
    }
    
}
