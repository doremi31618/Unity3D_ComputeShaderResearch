using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointCloudCSharp : MonoBehaviour
{
    [SerializeField, Range(10, 200)]
    int resolution = 10;

    // [SerializeField]
    // FunctionLibrary.FunctionName function = default;
    [SerializeField] Mesh mesh = default;
    [SerializeField] Material material = default;
    [SerializeField] ComputeShader computeShader = default;
    ComputeBuffer positionsBuffer;

    static readonly int 
        positionsId = Shader.PropertyToID("_Positions"),
        resolutionId = Shader.PropertyToID("_Resolution"),
        stepId = Shader.PropertyToID("_Step"),
        timeId = Shader.PropertyToID("_Time");


    struct PositionStruct{
        float x_pos;
        float y_pos;
        float z_pos;
    }

    void UpdateFunctionOnGPU() {
        float step = 2f / resolution;
        computeShader.SetInt(resolutionId, resolution);
        computeShader.SetFloat(stepId, step);
        computeShader.SetFloat(timeId, Time.time);
        int kernelId = computeShader.FindKernel("FunctionKernel");
        computeShader.SetBuffer(kernelId, positionsId, positionsBuffer);
        int group = Mathf.CeilToInt(resolution / 8);
        computeShader.Dispatch(kernelId, group, group, 1);
        material.SetBuffer(positionsId, positionsBuffer);
        material.SetFloat(stepId, step);

        
        var bounds = new Bounds(Vector3.zero, Vector3.one * (2f + 2f/resolution));
        // first argument : mesh
        // second argument : sub-mesh index
        // third  argument : material
        Graphics.DrawMeshInstancedProcedural(mesh, 0, material, bounds, positionsBuffer.count);
    }
    
    private void OnEnable()
    {
        
       
        /*
        /// <summary>
        /// Build a Compute buffer storing data of number of resolution * resolution 
        /// and size of vector3 
        /// </summary>
        /// <param name="first argument "> the amount of elements of the buffer</param>
        /// <param name="second argument ">the exact size of each element in bytes </param>
        /// 
        /// <returns></returns>
        /// */
        positionsBuffer = new ComputeBuffer(resolution * resolution, 3 * sizeof(float));
   
    }

    private void OnDisable()
    {
        positionsBuffer.Release();
        positionsBuffer = null;
    }

    // Start is called before the first frame update
    void Start()
    {
        // UpdateFunctionOnGPU();
    }

    // Update is called once per frame
    void Update()
    {
        UpdateFunctionOnGPU();

        
        
    }
}
