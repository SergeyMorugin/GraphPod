//
//  parsum.metal
//  GraphPod_Example
//
//  Created by Matthew on 11.07.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


typedef unsigned int uint;
typedef int DataType;

kernel void parsum(const device DataType* data [[ buffer(0) ]],
                   const device uint& dataLength [[ buffer(1) ]],
                   device DataType* sums [[ buffer(2) ]],
                   const device uint& elementsPerSum [[ buffer(3) ]],

                   const uint tgPos [[ threadgroup_position_in_grid ]],
                   const uint tPerTg [[ threads_per_threadgroup ]],
                   const uint tPos [[ thread_position_in_threadgroup ]]) {

    uint resultIndex = tgPos * tPerTg + tPos;

    uint dataIndex = resultIndex * elementsPerSum; // Where the summation should begin
    uint endIndex = dataIndex + elementsPerSum < dataLength ? dataIndex + elementsPerSum : dataLength; // The index where summation should end

    for (; dataIndex < endIndex; dataIndex++)
        sums[resultIndex] += data[dataIndex];
}
