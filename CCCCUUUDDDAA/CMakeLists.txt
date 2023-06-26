cmake_minimum_required(VERSION 3.12)
project(PrimeDecomposition CUDA CXX)

set(CMAKE_CUDA_STANDARD 14)

find_package(CUDA REQUIRED)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -std=c++14)

set(SOURCE_FILES main.cu)

cuda_add_executable(PrimeDecomposition ${SOURCE_FILES})

target_link_libraries(PrimeDecomposition CUDA::cudart)